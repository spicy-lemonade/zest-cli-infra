# Zest CLI - Commercial Edition

Licensed version of Zest with 2-device activation, OTP verification, and macOS packaging.

## 📁 Structure

```
zest_cli/
├── main.py                 # Licensed CLI with activation flow
├── requirements.txt        # Python dependencies
├── build.sh               # PyInstaller build script
├── create_installer.sh    # .pkg installer creator
├── test/                  # Test utilities
└── README.md             # This file
```

## 🚀 Quick Start

### Usage

**During Development/Testing**:
```bash
python main.py "your query here"
```

**After Installation**:
```bash
zest "your query here"
```

**IMPORTANT**: Don't include "zest" in the query when testing!

✅ Correct:
```bash
python main.py "show me all running docker containers"
# Output: docker ps
```

❌ Wrong:
```bash
python main.py zest show me all running docker containers
# This includes "zest" in the query, confusing the model
```

### Setup

1. **Configure API endpoint** in `main.py` in the config section:
   ```python
   API_BASE = "https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net"
   ```

2. **Deploy backend**:
   ```bash
   cd ../functions
   firebase deploy --only functions
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Test locally**:
   ```bash
   python main.py "list files"
   ```

5. **Build for distribution**:
   ```bash
   ./build.sh                  # Creates .app bundle
   ./create_installer.sh       # Creates .pkg installer
   ```

## 🔐 How It Works

1. **Purchase**: User buys via Polar → Webhook creates Firestore license
2. **First Run**: CLI prompts for email → Backend sends OTP
3. **Activation**: User enters OTP → Backend registers device UUID
4. **Validation**: 14-day local lease with periodic online sync
5. **2-Device Limit**: Enforced server-side

## 🗑️ Cleanup Commands

Commands that work even after uninstalling (via standalone `main.py` fallback):

### `zest --status`
Shows installation and license status for all products:
```bash
zest --status
```

**Example output**:
```
🍋 Zest Status (CLI v1.0.0)
   Active model: Pro (Qwen2.5 Coder 7B FP16)

   Base (Qwen3 4B Q5):
      Installed: ❌ | Licensed: ❌ | Model v1.0.0
   Mid (Qwen2.5 Coder 7B Q5):
      Installed: ❌ | Licensed: ❌ | Model v1.0.0
   Pro (Qwen2.5 Coder 7B FP16):
      Installed: ✅ | Licensed: ✅ | Model v1.0.0
```

### `zest --logout`
Deregisters device and removes license data, but **keeps model files** on disk. Frees up a device slot on your account.

```bash
# Logout from all products
zest --logout

# Logout from specific product
zest --logout --base
zest --logout --mid
zest --logout --pro
```

**What gets removed**:
- License data from config
- Device registration on server

**What stays**:
- Model files in `~/.zest/`
- App bundle in `/Applications/`
- CLI wrapper at `/usr/local/bin/zest`

### `zest --uninstall`
Complete removal: deregisters device, removes license data, **deletes model files**, and removes app bundle from Applications.

```bash
# Uninstall all products
zest --uninstall

# Uninstall specific product
zest --uninstall --base
zest --uninstall --mid
zest --uninstall --pro
```

**What gets removed**:
- License data from config
- Device registration on server
- Model files (`~/.zest/*.gguf`)
- App bundle from `/Applications/`
- Empty directories (`~/.zest/`, config dir)

**What stays**:
- CLI wrapper at `/usr/local/bin/zest` (for running cleanup commands)
- Standalone `main.py` at `~/.zest/` (if no models remain)
- Shell alias in `~/.zshrc` or `~/.bashrc`

**To completely remove Zest**:
```bash
sudo rm /usr/local/bin/zest
rm -rf ~/.zest
rm -rf ~/Library/Application\ Support/Zest
# Manually remove alias from ~/.zshrc or ~/.bashrc
```

### Key Difference: `--logout` vs `--uninstall`

- **`--logout`**: "Free up a device slot but keep model files locally"
- **`--uninstall`**: "Remove everything (license + model files + app)"

## 🧪 Testing

**Prerequisites**:
- Backend deployed
- `API_BASE` configured in `config.py`
- Model at `~/.zest/` (Base: qwen3_4b_Q5_K_M.gguf, Mid: qwen2_5_coder_7b_Q5_K_M.gguf, Pro: qwen2_5_coder_7b_fp16.gguf)
- Dependencies installed

### Test 1: First-Time Activation

```bash
# Clear existing license
rm -f "$HOME/Library/Application Support/Zest/license.json"

# Create test license
cd test
python create_test_license.py your-email@example.com
cd ..

# Run CLI
python main.py "list files"
```

**Expected**: Email prompt → OTP sent → Device registered → Command generated

**Verify**:
```bash
cat "$HOME/Library/Application Support/Zest/license.json"
firebase firestore:get licenses/your-email@example.com
```

### Test 2: Existing License

```bash
python main.py "list files"
```

**Expected**: No OTP prompt (14-day lease still valid)

### Test 3: Logout

```bash
python main.py --logout
```

**Expected**: Device deregistered, local license deleted

## 🔧 Configuration

| Setting | Location | Default |
|---------|----------|---------|
| API Endpoint | `config.py` | `europe-west1-nl-cli-dev.cloudfunctions.net` |
| Model Paths | `config.py` | `~/.zest/*.gguf` |
| Lease Duration | `config.py` | 14 days |
| Device Limit | `../functions/main.py` | 2 devices |
| OTP Expiry | `../functions/main.py` | 10 minutes |

## 🐛 Troubleshooting

### Authentication Issues

**Authentication doesn't trigger**
- Valid 14-day lease cached: `cat "$HOME/Library/Application Support/Zest/license.json"`
- Clear: `rm -f "$HOME/Library/Application Support/Zest/license.json"`

**"No license found"**
- Verify Polar webhook is working
- Check Firestore: `firebase firestore:get licenses/your-email@example.com`

**Network error**
- Check `API_BASE` in `main.py`
- Verify functions deployed: `firebase deploy --only functions`
- Test endpoint: `curl https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/send_otp`

### Model Issues

**Wrong command or repeats query**
- Don't include "zest" in test queries (see Usage section)
- Model exists: `ls -lh ~/.zest/*.gguf`
- Test examples:
  - `python main.py "list files"` → `ls`
  - `python main.py "show running processes"` → `ps aux`
  - `python main.py "show disk usage"` → `df -h`

**Model not found**
- Download to `~/.zest/` with one of:
  - Base: `qwen3_4b_Q5_K_M.gguf`
  - Mid: `qwen2_5_coder_7b_Q5_K_M.gguf`
  - Pro: `qwen2_5_coder_7b_fp16.gguf`

### Testing Issues

**Wrong directory**
- Run from `zest_cli/` directory, not `zest_cli/test/`

## 📦 Distribution

### Testing (Unsigned)
```bash
./build.sh
./create_installer.sh
sudo installer -pkg ./dist/Zest-1.0.0.pkg -target /
```

### Production (Signed & Notarized)
1. Get Apple Developer account ($99/year)
2. Create Developer ID certificates
3. Sign with `codesign` and `productsign`
4. Notarize with `xcrun notarytool`
5. Staple with `xcrun stapler`

See `SIGNING_GUIDE.md` for details.

## 📊 Firestore Schema

```
licenses/{email}
  ├─ base_is_paid: boolean
  ├─ base_devices: array[{uuid, nickname, registered_at}]
  ├─ mid_is_paid: boolean
  ├─ mid_devices: array[{uuid, nickname, registered_at}]
  ├─ pro_is_paid: boolean
  ├─ pro_devices: array[{uuid, nickname, registered_at}]
  ├─ otp_code: string (temporary)
  ├─ otp_expiry: datetime (temporary)
  └─ created_at: timestamp
```

## 📄 License

Copyright © 2025 Spicy Lemonade. All rights reserved.
