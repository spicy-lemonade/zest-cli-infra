# Zest CLI - Setup Guide

This directory contains the commercial version of Zest with licensing and device management.

## Testing the CLI Locally

Before packaging, you can test the licensing flow:

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure the API endpoint:**
   Edit `config.py` and set your Firebase project ID:
   ```python
   API_BASE = "https://europe-west1-<ZEST_PROJECT_ID>.cloudfunctions.net"
   ```

3. **Deploy Firebase Functions:**
   ```bash
   cd ../functions
   firebase deploy --only functions
   ```

4. **Test the CLI:**
   ```bash
   python main.py "list all files"
   ```

   On first run, you'll be prompted to enter your email and OTP.

## Commands

- `python main.py "your query"` - Generate and execute commands
- `python main.py --logout` - Deactivate this device
- `python main.py --uninstall` - Complete uninstall
- `python main.py --help` - Show help

## Next Steps

1. ✅ Backend API is ready (`functions/main.py`)
2. ✅ CLI with licensing is ready (`zest_cli/main.py`)
3. ⏳ Configure email service in `functions/main.py` (see line 24-50)
4. ⏳ Create PyInstaller build script
5. ⏳ Build .pkg installer
6. ⏳ Set up code signing

## Important Notes

### Email Service Setup

The backend currently logs OTPs to the console. You need to configure a real email service:

**Option 1: Firebase Email Extension (Easiest)**
```bash
firebase ext:install firestore-send-email
```

**Option 2: SendGrid**
1. Get API key from SendGrid
2. Add to Firebase secrets: `firebase functions:secrets:set SENDGRID_API_KEY`
3. Uncomment SendGrid code in `functions/main.py:39-50`

**Option 3: Mailgun or AWS SES**
- Similar process - get API key, store as secret, implement in `send_email_otp()`

### API Configuration

Update the API base URL in `config.py`:
```python
API_BASE = "https://europe-west1-<ZEST_PROJECT_ID>.cloudfunctions.net"
```

You can find your project ID with:
```bash
firebase projects:list
```

## Testing the License Flow

### 1. Create a test license in Firestore

Go to Firebase Console > Firestore and create:

```
Collection: licenses
Document ID: your-test-email@example.com
Fields:
  - is_paid: true
  - devices: [] (empty array)
```

### 2. Test the activation flow

```bash
python main.py "list files"
```

You'll see:
1. Email prompt
2. OTP sent (check console logs or email)
3. OTP verification
4. Device nickname prompt
5. Registration confirmation

### 3. Test device limit

- Run the activation on a second machine
- Try a third machine - you'll be prompted to replace

### 4. Test logout

```bash
python main.py --logout
```

### 5. Test uninstall

```bash
python main.py --uninstall
```

## Firestore Data Structure

After activation, your Firestore document will look like:

```json
{
  "is_paid": true,
  "devices": [
    {
      "uuid": "ABC-123-DEF-456",
      "nickname": "M3 MacBook Air",
      "registered_at": "2025-01-15T10:30:00"
    },
    {
      "uuid": "XYZ-789-GHI-012",
      "nickname": "Work iMac",
      "registered_at": "2025-01-16T14:20:00"
    }
  ],
  "created_at": "2025-01-15T09:00:00"
}
```

## Security Considerations

1. **API URL**: Hardcoded in the binary (users can't easily change it)
2. **Hardware UUID**: Unique to each Mac, can't be easily spoofed
3. **OTP**: Time-limited (5 minutes), single-use
4. **Device Limit**: Enforced server-side, can't be bypassed locally
5. **Compiled Binary**: PyInstaller/Nuitka makes it hard to modify the code

## Troubleshooting

### "No license found for this email"
- Make sure you've purchased Zest
- Check that Stripe webhook successfully created the license in Firestore

### "OTP expired"
- Request a new OTP (re-run the command)
- OTPs expire after 5 minutes

### "Device limit reached"
- Choose a device to replace
- Or use `--logout` on an old device first

### Network errors
- Check that Firebase Functions are deployed
- Verify the API_BASE_URL is correct
- Check internet connection
