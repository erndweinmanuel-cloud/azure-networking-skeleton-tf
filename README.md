# azure-networking-skeleton-tf
**Azure Networking Security Baseline (Terraform)** — 2-tier VNet + private Linux VMs + **Azure Bastion (Standard)**, hardened **NSGs + ASGs**, and an **audit-ready proof pipeline** (curated screenshots + redacted CLI/Terraform outputs).

This repo is built to be:
- **Secure by default** (no VM Public IPs, Bastion access, NSG hardening)
- **Reproducible** (clean Terraform workflow: init → fmt → validate → plan → apply → destroy)
- **Recruiter-friendly** (proofs are curated + redacted; no raw dumps, no secrets)

---

## What this deploys
- A **Virtual Network** with **frontend** + **backend** subnets
- **Azure Bastion Standard** (in `AzureBastionSubnet`)
- Two **Linux VMs** (frontend + backend) **without Public IPs**
- **NSGs** to enforce least privilege traffic
- **ASGs** to group workloads and keep NSG rules clean

---

## Repo layout (based on the current TF files)
Terraform is intentionally split by concern:

- `providers.tf` — AzureRM provider config
- `variables.tf` — input variables
- `terraform.tfvars.example` — example vars (copy locally; never commit real `terraform.tfvars`)
- `main.tf` — core wiring / base resources
- `compute.tf` — Linux VMs (no public IPs)
- `bastion.tf` — Bastion Standard configuration
- `asg.tf` — Application Security Groups
- `nsg_frontend.tf` — frontend NSG rules
- `nsg_backend.tf` — backend NSG rules
- `outputs.tf` — outputs used for validation + proofs

Proof + tooling:
- `tools/redact.ps1` — redaction pipeline (raw → audit-safe)
- `proofs/` — **only** curated + redacted artifacts are allowed in Git
  - `proofs/docs-proofs/**` ✅ curated portal screenshots
  - `proofs/audit/**` ✅ redacted CLI/Terraform outputs
  - everything else under `proofs/**` ❌ ignored

---

## Security stance (the core selling point)
### No public exposure of VMs
- **No VM Public IPs**
- No inbound SSH/RDP from the internet
- Access is only via **Azure Bastion**

### NSG + ASG baseline
- NSGs enforce least privilege between tiers
- ASGs simplify rules (“frontend-asg → backend-asg” instead of IP-based rules)

---

## Prerequisites
- Terraform 1.x
- Azure CLI (`az`)
- An Azure subscription
- PowerShell (for the redaction pipeline) — Windows-friendly by design

---

## Configure
1) Login:
```bash
az login
az account show
``` 

### UNDER CONSTRUCTION, NOT DONE YET! ### 