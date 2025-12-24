# Zest CLI - Commercial Edition

This directory contains the licensed, commercial version of Zest with 2-device activation, OTP verification, and complete packaging for macOS distribution.

## 📁 Directory Structure

```
zest_cli/
├── main.py                 # Licensed CLI with activation flow
├── requirements.txt        # Python dependencies
├── build.sh               # PyInstaller build script
├── create_installer.sh    # .pkg installer creator
├── SETUP.md              # Development and testing guide
├── SIGNING_GUIDE.md      # Code signing & notarization
└── README.md             # This file
```

## 🎯 What's Been Built

### ✅ Backend API (`../functions/main.py`)

Six Firebase Cloud Functions for license management:

1. **`stripe_webhook`** - Creates license on Stripe purchase
2. **`send_otp`** - Generates and emails 6-digit OTP
3. **`verify_otp_and_register`** - Validates OTP and registers device
4. **`replace_device`** - Swaps old device for new one
5. **`deregister_device`** - Removes device (for `--logout`)
6. **`validate_device`** - Quick check on every CLI run

### ✅ Licensed CLI (`main.py`)

Features:
- First-run activation with email + OTP
- Hardware UUID extraction (macOS IOPlatformUUID)
- 2-device limit enforcement
- Device nickname management
- Local license storage (`~/Library/Application Support/Zest/license.db`)
- `--logout` command (deregister device)
- `--uninstall` command (complete cleanup)
- Offline validation (with online sync)

### ✅ Packaging Scripts

- **`build.sh`** - PyInstaller compilation → `.app` bundle
- **`create_installer.sh`** - `.pkg` creation with postinstall
- **Postinstall script** - Creates symlink + shell aliases

### ✅ Documentation

- **`SETUP.md`** - Testing and development workflow
- **`SIGNING_GUIDE.md`** - Complete code signing guide
- **`README.md`** - This overview

## 🚀 Quick Start

### 1. Configure the API Endpoint

Edit `main.py` line 14 and replace `YOUR_PROJECT_ID`:

```python
API_BASE_URL = "https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net"
```

Get your project ID:
```bash
cd ../
firebase projects:list
```

### 2. Verify Email Service Configuration

The backend uses Resend to send OTPs. Configuration is already complete:

1. Resend API key is configured in Firebase Functions secrets as `RESEND_API_KEY`
2. OTP emails are sent from `onboarding@resend.dev` (Resend's default test domain)

If you need to update the Resend API key:
```bash
firebase functions:secrets:set RESEND_API_KEY
```

Note: For production, you should verify a custom domain in Resend and update the "from" address in `functions/main.py`.

### 3. Deploy Backend

```bash
cd ../functions
firebase deploy --only functions
```

### 4. Test Locally

```bash
cd ../zest_cli
pip install -r requirements.txt
python main.py "list files"
```

You'll be prompted for email/OTP on first run.

### 5. Build for Distribution

```bash
# Build the .app bundle
./build.sh

# Create the .pkg installer
./create_installer.sh

# Sign and notarize (requires Apple Developer account)
# See SIGNING_GUIDE.md
```

## 📋 Implementation Checklist

### Backend
- [x] 2-device licensing logic
- [x] OTP generation and validation
- [x] Device registration and management
- [x] Stripe webhook integration
- [x] Email service configuration (Resend)

### CLI
- [x] First-run activation flow
- [x] Hardware UUID extraction
- [x] Local license storage
- [x] `--logout` command
- [x] `--uninstall` command
- [x] Offline/online validation
- [ ] Update checking (TODO: See "Future Enhancements" below)

### Packaging
- [x] PyInstaller build script
- [x] .app bundle structure
- [x] .pkg installer with postinstall
- [x] Symlink creation
- [x] Shell alias setup
- [ ] Code signing (TODO: Requires Developer ID)
- [ ] Notarization (TODO: Requires Developer account)

## 🔐 Security Model

### How Licensing Works

1. **Purchase**: User buys via Stripe → Webhook creates Firestore license
2. **First Run**: CLI prompts for email → Backend sends OTP
3. **Activation**: User enters OTP → Backend verifies and registers device UUID
4. **Validation**: Every run checks local license (with periodic online sync)
5. **2-Device Limit**: Enforced server-side, can't be bypassed locally

### Why It's Secure

- **Binary Compilation**: PyInstaller makes source code unreadable
- **Hardware Binding**: UUID tied to Mac hardware, hard to spoof
- **Server Validation**: Device list stored server-side
- **OTP Verification**: Prevents email hijacking
- **Local + Cloud**: Works offline, syncs when online

## 📦 Distribution Workflow

```
1. Development → 2. Build → 3. Sign → 4. Notarize → 5. Distribute
     ↓              ↓          ↓          ↓             ↓
   Code          .app      Signed     Apple         Website
   Changes       Bundle    .pkg       Approves      Download
```

### For Testing (Unsigned)

1. Run `./build.sh`
2. Run `./create_installer.sh`
3. Test: `sudo installer -pkg ./dist/Zest-1.0.0.pkg -target /`

### For Production (Signed & Notarized)

1. Get Apple Developer account ($99/year)
2. Create Developer ID certificates
3. Sign with `codesign` and `productsign`
4. Notarize with `xcrun notarytool`
5. Staple with `xcrun stapler`
6. Distribute `.pkg` file

See `SIGNING_GUIDE.md` for complete instructions.

## 🧪 Testing the License Flow

### Test 1: First-Time Activation

1. Create test license in Firestore:
   ```
   Collection: licenses
   Document: test@example.com
   Fields:
     is_paid: true
     devices: []
   ```

2. Run CLI:
   ```bash
   python main.py "list files"
   ```

3. You'll see:
   - Email prompt
   - OTP sent (check logs or email)
   - OTP entry prompt
   - Device nickname prompt
   - Success message

### Test 2: Second Device

1. On another Mac (or delete `~/Library/Application Support/Zest/`)
2. Run `python main.py "list files"`
3. Same flow - second device registers

### Test 3: Device Limit

1. Try activating a third device
2. You'll see list of existing devices
3. Choose which to replace

### Test 4: Logout

```bash
python main.py --logout
```

Device deregistered, local license deleted.

### Test 5: Uninstall

```bash
python main.py --uninstall
```

Deregisters device, removes symlink, removes aliases, deletes app data.

## 🔧 Configuration

### API Endpoint

`main.py` line 14:
```python
API_BASE_URL = "https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net"
```

### Model Path

`main.py` line 12:
```python
MODEL_PATH = os.path.expanduser("~/.zest/gemma3_4b_Q4_K_M.gguf")
```

For the .app bundle, this should be:
```python
MODEL_PATH = os.path.join(os.path.dirname(__file__), "../Resources/models/gemma3_4b_Q4_K_M.gguf")
```

### Device Limit

`../functions/main.py` line 15:
```python
MAX_DEVICES = 2
```

### OTP Expiry

`../functions/main.py` line 16:
```python
OTP_EXPIRY_MINUTES = 5
```

## 📊 Firestore Schema

```
licenses/{email}
  ├─ is_paid: boolean
  ├─ devices: array
  │   ├─ [0]
  │   │   ├─ uuid: string
  │   │   ├─ nickname: string
  │   │   └─ registered_at: string (ISO 8601)
  │   └─ [1]
  │       ├─ uuid: string
  │       ├─ nickname: string
  │       └─ registered_at: string
  ├─ otp_code: string (temporary)
  ├─ otp_expiry: datetime (temporary)
  └─ created_at: timestamp
```

## 🚧 Future Enhancements

### Auto-Update System

Create an update manifest:

```json
{
  "version": "1.1.0",
  "url": "https://spicylemonade.com/downloads/Zest-1.1.0.pkg",
  "release_notes": "Bug fixes and performance improvements",
  "required": false
}
```

Add to CLI:
```python
def check_for_updates():
    response = requests.get("https://spicylemonade.com/zest/manifest.json")
    data = response.json()
    if version_compare(data["version"], CURRENT_VERSION) > 0:
        print(f"Update available: {data['version']}")
```

### Analytics (Optional)

Track anonymous usage:
```python
def send_analytics(event_type):
    requests.post(f"{API_BASE_URL}/analytics", json={
        "event": event_type,
        "version": VERSION,
        "os": platform.system()
    })
```

### License Transfer

Add endpoint to transfer license to new email:
```python
@https_fn.on_request
def transfer_license(req):
    # Validate ownership
    # Update email in Firestore
    # Send confirmation emails
```

## 🐛 Troubleshooting

### "No license found for this email"

- Verify Stripe webhook is working
- Check Firestore for the license document
- Make sure email matches exactly

### "Network error"

- Check API_BASE_URL is correct
- Verify Firebase Functions are deployed
- Check internet connection

### Build fails with "Model not found"

- Download model to `~/.zest/gemma3_4b_Q4_K_M.gguf`
- Or update MODEL_PATH in build.sh

### Installer doesn't create symlink

- Check postinstall script has execute permissions
- Run manually: `sudo /Applications/Zest.app/Contents/MacOS/zest`

## 📞 Support

For issues or questions:
- GitHub: [github.com/spicy-lemonade/zest](https://github.com/spicy-lemonade/zest)
- Email: support@spicylemonade.com
- Docs: [spicylemonade.com/docs](https://spicylemonade.com/docs)

## 📄 License

Copyright © 2025 Spicy Lemonade. All rights reserved.

This is commercial software. See LICENSE file for terms.
