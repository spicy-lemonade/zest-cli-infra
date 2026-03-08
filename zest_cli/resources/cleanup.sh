#!/bin/bash
# Zest CLI Shell Cleanup Script
# This script handles cleanup when the app bundle is deleted and Python is unavailable.
# It provides a fallback for --uninstall and orphan cleanup scenarios.

set -e

# Configuration
ZEST_DIR="$HOME/.zest"
CONFIG_DIR="$HOME/Library/Application Support/Zest"
CONFIG_FILE="$CONFIG_DIR/config.json"
API_BASE="https://europe-west1-nl-cli.cloudfunctions.net"
WRAPPER_PATH="/usr/local/bin/zest"

# Model paths
MODEL_PATH_LITE="$ZEST_DIR/qwen2_5_coder_7b_Q5_K_M.gguf"
MODEL_PATH_HOT="$ZEST_DIR/qwen2_5_coder_7b_fp16.gguf"
MODEL_PATH_EXTRA_SPICY="$ZEST_DIR/qwen2_5_coder_14b_Q5_K_M.gguf"

# App bundle paths
LITE_APP="/Applications/Zest-Lite.app"
HOT_APP="/Applications/Zest-Hot.app"
EXTRA_SPICY_APP="/Applications/Zest-Extra-Spicy.app"

# Get hardware UUID for deregistration
get_hw_id() {
    ioreg -d2 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $(NF-1)}'
}

# Read a value from config.json
read_config() {
    local key="$1"
    if [ -f "$CONFIG_FILE" ]; then
        grep -o "\"$key\": *\"[^\"]*\"" "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f4
    fi
}

# Read license data for a product
read_license() {
    local product="$1"
    local key="${product}_license"
    if [ -f "$CONFIG_FILE" ]; then
        # Check if the license key exists in config
        grep -q "\"$key\"" "$CONFIG_FILE" 2>/dev/null && echo "exists"
    fi
}

# Read email from license
read_license_email() {
    local product="$1"
    if [ -f "$CONFIG_FILE" ]; then
        # Extract email from nested license object - simplified extraction
        python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('${product}_license', {}).get('email', ''))" 2>/dev/null || echo ""
    fi
}

# Read device nickname from license
read_license_nickname() {
    local product="$1"
    if [ -f "$CONFIG_FILE" ]; then
        python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('${product}_license', {}).get('device_nickname', 'this device'))" 2>/dev/null || echo "this device"
    fi
}

# Deregister device from server
deregister_device() {
    local email="$1"
    local product="$2"
    local hw_id
    hw_id=$(get_hw_id)

    if [ -n "$email" ]; then
        curl -s -X POST "$API_BASE/deregister_device" \
            -H "Content-Type: application/json" \
            -d "{\"email\": \"$email\", \"device_uuid\": \"$hw_id\", \"product\": \"$product\"}" \
            --connect-timeout 10 >/dev/null 2>&1 || true
    fi
}

# Uninstall a specific product
uninstall_product() {
    local product="$1"
    local model_path
    local app_path
    local product_name

    case "$product" in
        lite)
            model_path="$MODEL_PATH_LITE"
            app_path="$LITE_APP"
            product_name="Lite"
            ;;
        hot)
            model_path="$MODEL_PATH_HOT"
            app_path="$HOT_APP"
            product_name="Hot"
            ;;
        extra_spicy)
            model_path="$MODEL_PATH_EXTRA_SPICY"
            app_path="$EXTRA_SPICY_APP"
            product_name="Extra Spicy"
            ;;
        *)
            echo "❌ Unknown product: $product"
            return 1
            ;;
    esac

    # Deregister from server if we have license data
    local email
    local nickname
    email=$(read_license_email "$product")
    nickname=$(read_license_nickname "$product")

    if [ -n "$email" ]; then
        printf "\033[2K\r🌶️ Deregistering \"%s\" from %s...\n" "$nickname" "$product_name"
        deregister_device "$email" "$product"
        echo "🍋 \"$nickname\" deregistered from $product_name license."
    fi

    # Delete model file
    if [ -f "$model_path" ]; then
        rm -f "$model_path"
        echo "🗑️  Deleted $product_name model file."

        # Create uninstall marker
        mkdir -p "$ZEST_DIR"
        touch "$ZEST_DIR/.${product}_uninstalled"

        # Remove setup marker
        rm -f "$ZEST_DIR/.${product}_setup_complete"
    fi

    # Delete app bundle if it exists
    if [ -d "$app_path" ]; then
        rm -rf "$app_path"
        echo "🗑️  Removed $product_name app from Applications."
    fi
}

# Remove config entry for a product (simplified - just removes the whole config if all gone)
cleanup_config() {
    # Check if any models remain
    local lite_model_exists=false
    local hot_model_exists=false
    local extra_spicy_model_exists=false

    [ -f "$MODEL_PATH_LITE" ] && lite_model_exists=true
    [ -f "$MODEL_PATH_HOT" ] && hot_model_exists=true
    [ -f "$MODEL_PATH_EXTRA_SPICY" ] && extra_spicy_model_exists=true

    # If no models left, clean up everything
    if ! $lite_model_exists && ! $hot_model_exists && ! $extra_spicy_model_exists; then
        rm -f "$CONFIG_FILE"
        [ -d "$CONFIG_DIR" ] && rmdir "$CONFIG_DIR" 2>/dev/null || true

        # Clean up .zest directory if empty (except for markers)
        if [ -d "$ZEST_DIR" ]; then
            # Remove main.py fallback
            rm -f "$ZEST_DIR/main.py"
            # Check if only marker files remain
            local file_count
            file_count=$(find "$ZEST_DIR" -type f ! -name ".*_uninstalled" | wc -l | tr -d ' ')
            if [ "$file_count" = "0" ]; then
                rm -rf "$ZEST_DIR"
            fi
        fi
    fi
}

# Full cleanup - remove everything including this script and wrapper
full_cleanup() {
    echo "🍋 Cleanup complete."

    # Check if we should remove the wrapper
    local lite_exists=false
    local hot_exists=false
    local extra_spicy_exists=false
    [ -d "$LITE_APP" ] && lite_exists=true
    [ -d "$HOT_APP" ] && hot_exists=true
    [ -d "$EXTRA_SPICY_APP" ] && extra_spicy_exists=true

    # Only remove wrapper if no apps remain
    if ! $lite_exists && ! $hot_exists && ! $extra_spicy_exists; then
        # Remove wrapper (may need sudo, so try without first)
        rm -f "$WRAPPER_PATH" 2>/dev/null || sudo rm -f "$WRAPPER_PATH" 2>/dev/null || true

        # Remove this script
        rm -f "$0" 2>/dev/null || true
    fi
}

# Show status
show_status() {
    echo "🍋 Zest Status (Shell Fallback)"
    echo ""

    local lite_installed="❌"
    local hot_installed="❌"
    local extra_spicy_installed="❌"
    local lite_app="❌"
    local hot_app="❌"
    local extra_spicy_app="❌"

    [ -f "$MODEL_PATH_LITE" ] && lite_installed="✅"
    [ -f "$MODEL_PATH_HOT" ] && hot_installed="✅"
    [ -f "$MODEL_PATH_EXTRA_SPICY" ] && extra_spicy_installed="✅"
    [ -d "$LITE_APP" ] && lite_app="✅"
    [ -d "$HOT_APP" ] && hot_app="✅"
    [ -d "$EXTRA_SPICY_APP" ] && extra_spicy_app="✅"

    echo "   Lite:"
    echo "      Model: $lite_installed | App: $lite_app"
    echo "   Hot:"
    echo "      Model: $hot_installed | App: $hot_app"
    echo "   Extra Spicy:"
    echo "      Model: $extra_spicy_installed | App: $extra_spicy_app"
    echo ""

    if [ "$lite_app" = "❌" ] && [ "$hot_app" = "❌" ] && [ "$extra_spicy_app" = "❌" ]; then
        echo "   ⚠️  No app bundles found. Reinstall from DMG or run:"
        echo "      zest --uninstall"
    fi
}

# Handle orphan scenario (model exists but app deleted)
handle_orphan() {
    local product="$1"
    local model_path
    local app_path
    local product_name

    case "$product" in
        lite)
            model_path="$MODEL_PATH_LITE"
            app_path="$LITE_APP"
            product_name="Lite"
            ;;
        hot)
            model_path="$MODEL_PATH_HOT"
            app_path="$HOT_APP"
            product_name="Hot"
            ;;
        extra_spicy)
            model_path="$MODEL_PATH_EXTRA_SPICY"
            app_path="$EXTRA_SPICY_APP"
            product_name="Extra Spicy"
            ;;
        *)
            return 1
            ;;
    esac

    # Check for DMG installation markers (setup marker, main.py, or license)
    local setup_marker="$ZEST_DIR/.${product}_setup_complete"
    local main_py_marker="$ZEST_DIR/main.py"
    local has_license
    has_license=$(read_license "$product")

    local was_dmg_install=false
    [ -f "$setup_marker" ] && was_dmg_install=true
    [ -f "$main_py_marker" ] && was_dmg_install=true
    [ -n "$has_license" ] && was_dmg_install=true

    # Check if this is an orphan situation (model exists, app deleted, was DMG install)
    if [ -f "$model_path" ] && [ ! -d "$app_path" ] && $was_dmg_install; then
        echo ""
        echo "⚠️  Zest $product_name app was removed from Applications."
        echo "   Model files still exist on this device."
        echo ""
        echo "   Options:"
        echo "   1. Clean up (remove model files and free license slot)"
        echo "   2. Keep files (reinstall from DMG to continue using Zest)"
        echo ""

        while true; do
            printf "   Enter choice [1/2]: "
            read -r choice
            case "$choice" in
                1)
                    uninstall_product "$product"
                    cleanup_config
                    full_cleanup
                    exit 0
                    ;;
                2)
                    echo ""
                    echo "   Files kept. To reinstall:"
                    echo "   1. Download Zest-${product_name%% *}.dmg"
                    echo "   2. Drag the app to Applications"
                    echo "   3. Run 'zest' from Terminal"
                    exit 0
                    ;;
                *)
                    echo "   Invalid choice. Please enter 1 or 2."
                    ;;
            esac
        done
    fi
}

# Determine active product (checks both model files and app bundles)
get_active_product() {
    # Check config for preference
    local preferred
    preferred=$(read_config "active_product")

    if [ -n "$preferred" ]; then
        local model_path app_path
        case "$preferred" in
            lite) model_path="$MODEL_PATH_LITE"; app_path="$LITE_APP" ;;
            hot) model_path="$MODEL_PATH_HOT"; app_path="$HOT_APP" ;;
            extra_spicy) model_path="$MODEL_PATH_EXTRA_SPICY"; app_path="$EXTRA_SPICY_APP" ;;
        esac
        ( [ -f "$model_path" ] || [ -d "$app_path" ] ) && echo "$preferred" && return
    fi

    # Fallback: prefer extra_spicy > hot > lite
    ( [ -f "$MODEL_PATH_EXTRA_SPICY" ] || [ -d "$EXTRA_SPICY_APP" ] ) && echo "extra_spicy" && return
    ( [ -f "$MODEL_PATH_HOT" ] || [ -d "$HOT_APP" ] ) && echo "hot" && return
    ( [ -f "$MODEL_PATH_LITE" ] || [ -d "$LITE_APP" ] ) && echo "lite" && return

    echo ""
}

# Main entry point
main() {
    local args=("$@")
    local has_uninstall=false
    local has_status=false
    local has_help=false
    local product=""

    # Parse arguments
    for arg in "${args[@]}"; do
        case "$arg" in
            --uninstall) has_uninstall=true ;;
            --status) has_status=true ;;
            --help|-h) has_help=true ;;
            --lite) product="lite" ;;
            --hot) product="hot" ;;
            --extra-spicy) product="extra_spicy" ;;
        esac
    done

    # Handle --help
    if $has_help; then
        echo "Zest CLI (Shell Fallback)"
        echo ""
        echo "This is the shell fallback for cleanup operations."
        echo "For full functionality, reinstall Zest from the DMG."
        echo ""
        echo "Available commands:"
        echo "  --uninstall              Remove all Zest files and licenses"
        echo "  --uninstall --lite       Remove Lite only"
        echo "  --uninstall --hot        Remove Hot only"
        echo "  --uninstall --extra-spicy  Remove Extra Spicy only"
        echo "  --status                 Show installation status"
        exit 0
    fi

    # Handle --status
    if $has_status; then
        show_status
        exit 0
    fi

    # Handle --uninstall
    if $has_uninstall; then
        if [ -n "$product" ]; then
            # Uninstall specific product
            uninstall_product "$product"
        else
            # Determine what to uninstall (check both models and app bundles)
            local lite_exists=false
            local hot_exists=false
            local extra_spicy_exists=false
            ( [ -f "$MODEL_PATH_LITE" ] || [ -d "$LITE_APP" ] ) && lite_exists=true
            ( [ -f "$MODEL_PATH_HOT" ] || [ -d "$HOT_APP" ] ) && hot_exists=true
            ( [ -f "$MODEL_PATH_EXTRA_SPICY" ] || [ -d "$EXTRA_SPICY_APP" ] ) && extra_spicy_exists=true

            if ! $lite_exists && ! $hot_exists && ! $extra_spicy_exists; then
                echo "🍋 No Zest installations found."
                exit 0
            fi

            # Count how many are installed
            local count=0
            $lite_exists && count=$((count + 1))
            $hot_exists && count=$((count + 1))
            $extra_spicy_exists && count=$((count + 1))

            if [ "$count" -gt 1 ]; then
                echo "🍋 Multiple models are installed:"
                local option=1
                local options=()
                if $lite_exists; then
                    echo "   $option. Lite"
                    options+=("lite")
                    option=$((option + 1))
                fi
                if $hot_exists; then
                    echo "   $option. Hot"
                    options+=("hot")
                    option=$((option + 1))
                fi
                if $extra_spicy_exists; then
                    echo "   $option. Extra Spicy"
                    options+=("extra_spicy")
                    option=$((option + 1))
                fi
                echo "   $option. All"
                echo ""
                while true; do
                    printf "Which would you like to uninstall? [1-%d]: " "$option"
                    read -r choice
                    if [ "$choice" -ge 1 ] && [ "$choice" -lt "$option" ] 2>/dev/null; then
                        uninstall_product "${options[$((choice - 1))]}"
                        break
                    elif [ "$choice" -eq "$option" ] 2>/dev/null; then
                        for p in "${options[@]}"; do
                            uninstall_product "$p"
                        done
                        break
                    else
                        echo "❌ Invalid choice."
                    fi
                done
            elif $lite_exists; then
                uninstall_product "lite"
            elif $hot_exists; then
                uninstall_product "hot"
            else
                uninstall_product "extra_spicy"
            fi
        fi

        cleanup_config
        full_cleanup
        exit 0
    fi

    # No recognized command - check for orphan scenario
    local active_product
    active_product=$(get_active_product)

    if [ -z "$active_product" ]; then
        echo "❌ No Zest models are installed."
        echo ""
        echo "To install Zest:"
        echo "  1. Download Zest-Lite.dmg, Zest-Hot.dmg, or Zest-Extra-Spicy.dmg"
        echo "  2. Drag the app to Applications"
        echo "  3. Run 'zest' from Terminal"
        exit 1
    fi

    # Check for orphan situation
    handle_orphan "$active_product"

    # If we get here, app is deleted but user didn't choose cleanup
    # Show helpful message
    echo ""
    echo "⚠️  Zest app bundle not found."
    echo "   The model exists but the app is missing."
    echo ""
    echo "   To use Zest, either:"
    echo "   • Reinstall from the DMG"
    echo "   • Run 'zest --uninstall' to clean up"
    exit 1
}

main "$@"
