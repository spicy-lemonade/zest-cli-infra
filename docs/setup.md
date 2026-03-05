# Setup & Operations

## Getting Started

### Prerequisites

1.  [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) installed.
2.  [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed.

### Setup & Deployment

1.  **Authenticate with GCP:**
    ```bash
    gcloud auth application-default login
    ```

2.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

3.  **Review the Plan:**
    ```bash
    terraform plan
    ```

4.  **Apply Changes:**
    ```bash
    terraform apply
    ```

---

## IAM & Security

Access is managed via Google Groups to streamline permissions for the ML Engineering team.

* **Group:** Set via `ml_group_email` in `terraform.tfvars`
* **Permissions:** Members of this group inherit read/write access to the storage buckets for ML and data work.

**To onboard a new engineer:**
1.  Add their email to the Google Group.
2.  Have them run the `gcloud` auth command listed above.

---

## Firebase Functions Secrets

The backend uses Firebase Cloud Functions with the following secrets:

### Polar.sh Payment Integration

1. **POLAR_ACCESS_TOKEN**: API token from Polar.sh dashboard
   ```bash
   firebase functions:secrets:set POLAR_ACCESS_TOKEN
   ```

2. **POLAR_WEBHOOK_SECRET**: Webhook signing secret from Polar.sh webhook settings
   ```bash
   firebase functions:secrets:set POLAR_WEBHOOK_SECRET
   ```

### Email Service (Resend)

3. **RESEND_API_KEY**: API key from Resend dashboard
   ```bash
   firebase functions:secrets:set RESEND_API_KEY
   ```

### Deployment

After setting secrets, deploy functions:
```bash
cd functions
firebase deploy --only functions
```

### Webhook Configuration

After deployment, configure this webhook URL in your Polar.sh dashboard:
```
https://europe-west1-<ZEST_PROJECT_ID>.cloudfunctions.net/polar_webhook
```

Enable the following webhook events:
- **order.created** (fires when a one-time purchase is completed)
- **order.paid** (fires when payment is confirmed)
- **order.refunded** (fires when a refund is processed)
- **checkout.updated** (fires when checkout status changes)
