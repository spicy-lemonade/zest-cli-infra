# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This project uses Python to train locally-running small language models (SLMs) to translate natural language into CLI commands. It uses fine-tuned models like Gemma3-1B or Qwen3-4b with QLoRA and GGUF quantization for CPU-optimized inference. The goal is 90%+ command accuracy with ~2.5GB footprint and <2s inference on CPU. This specific repo is the infrastructure for this project including terraform for provisioning resources, and all back end code.

## Important Rules

- *Never* run git commands without asking for user permission, even if 'auto-accept' is selected during a Claude Command session
- *Never* run files which use an LLM API without asking for user permission,  even if 'auto-accept' is selected during a Claude Command session
- *Never* attempt to re-engineer the code or alter data without asking for user permission
- *Never* make assumptions. Ask for more information and wait for the user response.
- Do *not* use numerical prefixes when writing comments
- Do *not* use newline characters in print statements
- Use double quotation marks instead of single quotation marks when possible
- Use type hinting
- Favor modular, resuable code
- Favor vectorised code
- When adding new datasets, follow the base → staging → mart pipeline
- Always run deduplication at both staging (per-file) and mart (cross-file) layers
- Using concurrency when processing data with an LLM API 


**Key Technologies:**
- Unsloth 2025.1+ with QLoRA for efficient fine-tuning
- GGUF quantization with llama.cpp for CPU inference
- Alpaca format for training data
- Google Cloud Storage for data versioning
- Gemini for processing data with an LLM

## Essential Information

### Data Pipeline
The data pipeline follows a three-layer, medallion-style architecture: base → staging → mart, with versioned GCS buckets:

**Base Layer** (raw unprocessed data):

Downloads and save raw data to GCS base bucket, for example:

```bash
python -m data.base.docker.dockerNLcommands
```

**Staging Layer** (Alpaca format with MD5 hashing):

Transforms base data to Alpaca format with "instruction", "input" and "output" columns. Additionally, a column
called "md5_hash" is added based on a combination of the "instruction" and "output" columns after they have been stripped of leading and trailing white space. The data is deduplicated using the md5 hash, and saved to GCS staging bucket, for example:

```bash
python -m data.staging.docker.dockerNLcommands
```

**Mart Layer** (model-specific training format):

Loads all staging data, joins it, performs cross-file deduplication, apply chat templates, save to GCS mart bucket, for example:

```bash
python -m data.mart.gemma_nl_cli_training
```
### Data Architecture

1. **Base Layer** (`data/base/`)
   - Raw unprocessed data from HuggingFace datasets
   - Organized by CLI tool: `bash/`, `docker/`, `git/`, `kubernetes/`, `aws/` etc.
   - Saved to GCS bucket: `nlcli-ml-training-base-03ca945a`

2. **Staging Layer** (`data/staging/`)
   - Transforms base data into Alpaca format: `instruction`, `input`, `output`. Also synthetically generated or modified datasets are placed in staging.
   - Adds MD5 hash column (`md5_hash`) for deduplication using `data/etl/utils/hashing.py`
   - Per-file deduplication based on `instruction + output` hash
   - Saved as Parquet files to GCS bucket: `nlcli-ml-training-staging-03ca945a`
   - Uses `data/etl/save/gcs_folder.py` for GCS operations

3. **Mart Layer** (`data/mart/`)
   - Loads all staging Parquet files
   - Cross-file deduplication (removes duplicates across all datasets)
   - Applies model-specific chat templates (e.g., Gemma's `<start_of_turn>` tokens)
   - Outputs training-ready JSONL to GCS bucket: `nlcli-ml-training-mart-03ca945a`

## Model Fine-tuning

Training happens on Google Colab with GPUs.

## Project notes
- The project uses Python 3.8+