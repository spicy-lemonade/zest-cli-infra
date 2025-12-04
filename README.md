# Natural language control for CLI tooling 

#### Using locally-trained small language models. No cloud. No API keys. Runs offline. Runs on CPU. Privacy first. No tracking. No Logging. No analytics.
![spicy](https://github.com/user-attachments/assets/9c3d925d-5c7b-44ed-a2c8-b73e5a897895)

## 🏗 Architecture & Data Flow

While the core agent runs **offline on CPU** (privacy-first, no tracking), the training pipeline utilizes Google Cloud Storage (GCS) to manage datasets before they are loaded into Google Colab for fine-tuning.

We utilize a **Medallion Architecture** pattern for data storage to ensure reproducibility and data quality:

| Layer | Bucket Role | Description |
| :--- | :--- | :--- |
| **🥉 Base** | `nlcli-ml-training-base-03ca945a` | Raw input data (e.g., scraped CLI help docs, raw command logs). |
| **🥈 Staging** | `nlcli-ml-training-staging-03ca945a` | Cleaned and deduplicated data (per dataset deduplication); intermediate processing. |
| **🥇 Mart** | `nlcli-ml-training-mart-03ca945a` | Final datasets training with deduplication (cross dataset deduplication). |
| **🪣 Models** | `nlcli-models` | Storage for final `.gguf` quantized models. We want to stay in a free tier so use Hugging Face.  |


---

## 🛠 Tech Stack

* **Terraform:** State management and resource provisioning.
* **Google Cloud Platform (GCP):**
    * **Cloud Storage (GCS):** Data persistence for training datasets.
    * **IAM:** Role-based access control for engineering teams.
    * **Cloud Billing:** Budget alerts by email and cost management.

---

## 🚀 Getting Started

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

## 🔐 IAM & Security

Access is managed via Google Groups to streamline permissions for the ML Engineering team.

* **Group:** `spicy-lemonage-nl-cli-ml-engineers@googlegroups.com`
* **Permissions:** Members of this group inherit read/write access to the storage buckets for ML and data work.

**To onboard a new engineer:**
1.  Add their email to the Google Group.
2.  Have them run the `gcloud` auth command listed in "Getting Started".

---

## 💰 Cost Strategy & Free Tier

**Goal:** Zero-cost infrastructure.

We intend to operate strictly within the **GCP Free Tier limits**:
* **Storage:** < 5GB-months of standard storage (US regions).
* **Compute:** None (Training occurs on Google Colab Free Tier T4 GPUs).
---

## 📋 Project Status & Roadmap

### Current Infrastructure
- [x] **Base/Staging/Mart Buckets:** Provisioned via Terraform.
- [x] **IAM Roles:** Engineering group created and assigned.
- [x] **Billing:** Account linked (Owned by Ciaran).

### To Do
- [ ] **Remote State:** Configure a GCS backend for Terraform state to allow team collaboration (To ensure "locking" in case 2 engineers make changes at the same time. Also to ensure we have a single source of truth for infra by having the tfstate on the cloud).
- [ ] **Billing Safeguard:** Implement the "Kill Switch" Cloud Function to automatically disable billing if the €10 threshold is reached.
- [ ] **Lifecycle Rules:** Add Terraform rules to auto-archive objects in the `base` bucket after 30 days to ensure we stay under the 5GB cap. Once base layer data has been process into staging, it won't be touched again most likely.

---

## Billing account
Ciaran currently owns the billing account under his personal email ciaranobrienmusic@gmail.com 
