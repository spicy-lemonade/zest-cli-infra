================================================================================
                         ZEST CLI - INSTALLATION GUIDE
================================================================================

Thank you for purchasing Zest CLI!

================================================================================
                              QUICK START
================================================================================

1. Drag the Zest app to your Applications folder

2. IMPORTANT - First launch only:
   Right-click the app in Applications and select "Open"
   (This bypasses macOS Gatekeeper's extended scan which can take 30+ seconds)
   Click "Open" in the security dialog that appears

3. Open Terminal and run a command, for example:

   /Applications/Zest-[MODEL].app/Contents/MacOS/zest-launcher "your query"

   Replace [MODEL] with FP16 or Q5 depending on which version you purchased.

4. On first run, you'll be prompted to:
   - Enter your purchase email
   - Enter the 6-digit verification code sent to your email

5. (Recommended) Create a symlink for easier access:

   sudo ln -sf "/Applications/Zest-Q5.app/Contents/MacOS/zest-launcher" /usr/local/bin/zest

   Or for FP16:
   sudo ln -sf "/Applications/Zest-FP16.app/Contents/MacOS/zest-launcher" /usr/local/bin/zest

6. (Recommended) Add noglob alias to prevent shell expansion issues:

   For zsh (default on macOS), add this line to your ~/.zshrc:
   alias zest='noglob /usr/local/bin/zest'

   For bash, add this line to your ~/.bashrc:
   alias zest='noglob /usr/local/bin/zest'

   Then reload your shell:
   source ~/.zshrc    # or source ~/.bashrc

   This prevents special characters like * and ? from being expanded by the shell.

================================================================================
                              EXAMPLE USAGE
================================================================================

zest "find all python files modified in the last 7 days"
zest "show me the 10 largest files in Downloads"
zest "compress the logs folder into logs.tar.gz"
zest "what processes are using the most memory"
zest "list all running docker containers"

================================================================================
                          MODEL VERSIONS (FP16 vs Q5)
================================================================================

Zest is available in two model versions:

  FP16 (Full Precision)
  - Higher quality responses
  - Larger file size (~8GB)
  - More memory usage
  - Best for: Users with 16GB+ RAM who want maximum quality

  Q5 (Quantized)
  - Slightly lower quality (barely noticeable)
  - Smaller file size (~3GB)
  - Less memory usage
  - Best for: Most users, machines with 8GB RAM

Each version has its own license with 2 device slots. You can purchase both
and switch between them.

================================================================================
                           USING BOTH MODELS
================================================================================

If you've purchased both FP16 and Q5:

1. Install both apps to /Applications

2. Check your current status:
   zest --status

3. Switch between models:
   zest --model --fp      # Use FP16 model
   zest --model --q5      # Use Q5 model

Note: If both models are installed, Zest defaults to FP16 (higher quality).
You can override this with --model --q5.

================================================================================
                           DEVICE MANAGEMENT
================================================================================

Your license allows installation on up to 2 devices PER PRODUCT.

If you bought both FP16 and Q5, you have:
- 2 device slots for FP16
- 2 device slots for Q5

LOGOUT (keeps model files, frees device slot):

  zest --logout           # Log out from ALL products
  zest --logout --fp      # Log out from FP16 only
  zest --logout --q5      # Log out from Q5 only

  Use --logout to free a device slot while keeping the model on disk.
  You can re-activate later without re-downloading.

UNINSTALL (removes everything):

  zest --uninstall        # Full uninstall of ALL products
  zest --uninstall --fp   # Uninstall FP16 only
  zest --uninstall --q5   # Uninstall Q5 only

  Use --uninstall to completely remove the model file, license, and
  deregister the device. This frees disk space.

REINSTALLING:

If you try to install a model that's already on your device, you'll be
prompted to either continue (re-activate license) or cancel.

================================================================================
                              OFFLINE MODE
================================================================================

Zest runs entirely offline after initial activation!

- The AI model runs locally on your Mac
- License is verified every 14 days when online
- If offline during verification, Zest continues working
- No data is sent to any server except for license checks

================================================================================
                           AUTOMATIC UPDATES
================================================================================

Zest checks for updates once per day and notifies you when available.

MODEL UPDATES (downloaded automatically):
  When a new model version is available, you'll be prompted:

  ┌─────────────────────────────────────────────────┐
  │  🍋 Model Update available: v1.1.0
  │  Product: Q5 (Quantized)
  │  Size: 3.0 GB
  └─────────────────────────────────────────────────┘

  🍋 Download new model now? [y/n]:

  Select 'y' to download and install the new model automatically.
  The download shows progress and can be cancelled with Ctrl+C.

CLI UPDATES (manual download):
  For CLI updates, you'll see a notification with the download URL.
  Download the new DMG from https://zestcli.com to update.

MANUAL UPDATE CHECK:
  zest --update           Check all products for updates
  zest --update --fp      Check FP16 for updates
  zest --update --q5      Check Q5 for updates

================================================================================
                          APP REMOVAL CLEANUP
================================================================================

If you delete the Zest app from your Applications folder, the next time you
try to run 'zest' you'll be prompted to clean up:

- Remove leftover model files
- Deregister your device (freeing a device slot)

You can also choose to keep the files if you plan to reinstall.

================================================================================
                               REQUIREMENTS
================================================================================

- macOS 12.0 (Monterey) or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- Disk space:
  - Q5: ~3GB
  - FP16: ~8GB
- RAM:
  - Q5: 8GB minimum
  - FP16: 16GB recommended

================================================================================
                             COMMAND REFERENCE
================================================================================

USAGE:
  zest "your natural language query"

MODEL MANAGEMENT:
  zest --model --fp       Switch to FP16 model
  zest --model --q5       Switch to Q5 model

LOGOUT (keeps model files):
  zest --logout           Log out from all products
  zest --logout --fp      Log out from FP16 only
  zest --logout --q5      Log out from Q5 only

UNINSTALL (removes model files):
  zest --uninstall        Uninstall all products
  zest --uninstall --fp   Uninstall FP16 only
  zest --uninstall --q5   Uninstall Q5 only

UPDATES:
  zest --update           Check for and download updates
  zest --update --fp      Check for FP16 updates
  zest --update --q5      Check for Q5 updates

INFO:
  zest --status           Show current model and license status
  zest --version          Show version
  zest --help             Show help message

================================================================================
                                 SUPPORT
================================================================================

Website: https://zestcli.com
Email: info@zestcli.com

================================================================================
