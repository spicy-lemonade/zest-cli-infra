#!/usr/bin/env python3
"""
Pre-register a device for a test license (bypasses OTP).
"""

import sys
from datetime import datetime, timezone

try:
    import firebase_admin
    from firebase_admin import firestore
except ImportError:
    print("Error: firebase-admin not installed.")
    sys.exit(1)


def register_device(email: str, device_uuid: str, nickname: str, product: str = "q5"):
    """Pre-register a device on an existing license."""

    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app()

    db = firestore.client()
    license_ref = db.collection("licenses").document(email)
    doc = license_ref.get()

    if not doc.exists:
        print(f"Error: No license found for {email}")
        sys.exit(1)

    now = datetime.now(timezone.utc)
    device_data = {
        "uuid": device_uuid,
        "nickname": nickname,
        "registered_at": now.isoformat(),
        "registered_at_unix": int(now.timestamp()),
        "last_validated": now.isoformat(),
        "last_validated_unix": int(now.timestamp())
    }

    devices_field = f"{product}_devices"
    license_data = doc.to_dict()
    devices = license_data.get(devices_field, [])

    # Check if device already registered
    for d in devices:
        if d["uuid"] == device_uuid:
            print(f"Device already registered for {product}")
            return

    devices.append(device_data)
    license_ref.update({devices_field: devices})

    print(f"✅ Device registered for {email} ({product})")
    print(f"   Device UUID: {device_uuid}")
    print(f"   Nickname: {nickname}")


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python register_device.py <email> <device_uuid> <nickname> [product]")
        sys.exit(1)

    email = sys.argv[1]
    device_uuid = sys.argv[2]
    nickname = sys.argv[3]
    product = sys.argv[4] if len(sys.argv) > 4 else "q5"

    register_device(email, device_uuid, nickname, product)
