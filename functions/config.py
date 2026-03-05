"""
Shared configuration constants for Zest CLI cloud functions.
"""

import os

# Service account configuration
# Automatically construct the service account email from the project ID
# The service account is created by Terraform as "cloud-functions-sa"
_project_id = os.environ.get("GCLOUD_PROJECT") or os.environ.get("GCP_PROJECT")
SERVICE_ACCOUNT_EMAIL = f"cloud-functions-sa@{_project_id}.iam.gserviceaccount.com" if _project_id else None

# License configuration
MAX_DEVICES_PER_PRODUCT = 2
OTP_EXPIRY_MINUTES = 10
VALID_PRODUCTS = ["lite", "hot", "extra_spicy"]
TRIAL_DURATION_DAYS = 5
MAX_OTP_SENDS_PER_HOUR = 5
MAX_OTP_VERIFY_ATTEMPTS = 5

# Polar.sh product IDs (set via functions/.env.<project-id>)
POLAR_PRODUCT_IDS = {
    "lite": os.environ.get("POLAR_PRODUCT_ID_LITE", ""),
    "hot": os.environ.get("POLAR_PRODUCT_ID_HOT", ""),
    "extra_spicy": os.environ.get("POLAR_PRODUCT_ID_EXTRA_SPICY", ""),
}

# Model file configuration
MODEL_FILES = {
    "lite": "qwen2_5_coder_7b_Q5_K_M.gguf",
    "hot": "qwen2_5_coder_7b_fp16.gguf",
    "extra_spicy": "qwen2_5_coder_14b_Q5_K_M.gguf"
}
GCS_BUCKET = os.environ.get("GCS_BUCKET", "")
