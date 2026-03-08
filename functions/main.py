"""
Zest CLI Cloud Functions - Main Entry Point

This module initializes the Firebase Admin SDK and re-exports all cloud functions
from their respective modules. Firebase Functions discovers and deploys all
exported functions from this entry point.

Module organization:
- config.py: Shared configuration constants
- helpers.py: Shared helper functions
- checkout.py: Payment and checkout functions (Polar.sh integration)
- otp.py: OTP generation and verification functions
- trial.py: Trial management functions
- devices.py: Device registration and management functions
- version.py: Version checking function
"""

from firebase_admin import initialize_app

# Initialize the Admin SDK once at the top level
initialize_app()

# Import and re-export checkout functions
from checkout import (
    create_checkout,
    polar_webhook,
    get_checkout_url,
)

# Import and re-export OTP functions
from otp import (
    send_otp,
    verify_otp_and_register,
)

# Import and re-export trial functions
from trial import (
    check_device_trial,
    start_trial,
    check_trial_status,
)

# Import and re-export device functions
from devices import (
    validate_device,
    replace_device,
    list_devices,
    deregister_device,
    license_heartbeat,
)

# Import and re-export version function
from version import check_version

# Import and re-export signed URL function
from signed_url import get_model_download_url

# Export all functions for Firebase Functions discovery
__all__ = [
    # Checkout
    "create_checkout",
    "polar_webhook",
    "get_checkout_url",
    # OTP
    "send_otp",
    "verify_otp_and_register",
    # Trial
    "check_device_trial",
    "start_trial",
    "check_trial_status",
    # Devices
    "validate_device",
    "replace_device",
    "list_devices",
    "deregister_device",
    "license_heartbeat",
    # Version
    "check_version",
    # Signed URL
    "get_model_download_url",
]
