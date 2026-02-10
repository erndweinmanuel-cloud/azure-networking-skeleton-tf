# azure-networking-skeleton-tf

**Azure Networking Security Baseline (Terraform)**  
A production-style Azure networking setup with **private Linux VMs**, **Azure Bastion (Standard)**, and **hardened NSGs + ASGs** — designed to demonstrate **secure-by-default architecture**, clean Terraform workflows, and security-aware proof handling.

This repository intentionally focuses on **architecture, security posture, and reproducibility** rather than publishing raw infrastructure logs.

---

## Why this repo exists

This project demonstrates how to build a **secure Azure network baseline** that reflects real-world best practices:

- No public exposure of workloads
- Controlled administrative access via Azure Bastion
- Clear separation of tiers (frontend / backend)
- Least-privilege network rules
- Clean Terraform lifecycle (deploy → verify → destroy)
- Proofs that are **curated and security-safe**

It is built as a **portfolio-grade reference**, not a lab dump.

---

## Key characteristics

- **Secure by default**
  - No VM Public IPs
  - No inbound SSH/RDP from the internet
  - Bastion-based access only
- **Reproducible**
  - Deterministic Terraform workflow
  - Clear separation of concerns in code structure
- **Recruiter-friendly**
  - Curated evidence instead of raw dumps
  - No secrets, no state files, no leaked identifiers

---

## What this deploys

- **Virtual Network**
  - Dedicated frontend and backend subnets
- **Azure Bastion Standard**
  - Deployed into `AzureBastionSubnet`
- **Two Linux VMs**
  - Frontend VM
  - Backend VM
  - Both without Public IPs
- **Network Security Groups (NSGs)**
  - Enforcing least-privilege traffic between tiers
- **Application Security Groups (ASGs)**
  - Logical grouping of workloads for clean NSG rules

---

## Repository layout

### Terraform code
- `providers.tf` — AzureRM provider configuration
- `variables.tf` — input variables
- `terraform.tfvars.example` — example variables (never commit real values)
- `main.tf` — core wiring and base resources
- `compute.tf` — Linux VMs (private only)
- `bastion.tf` — Azure Bastion Standard
- `asg.tf` — Application Security Groups
- `nsg_frontend.tf` — frontend NSG rules
- `nsg_backend.tf` — backend NSG rules
- `outputs.tf` — outputs used for validation

### Proofs & tooling
- `tools/redact.ps1` — PowerShell redaction pipeline
- `proofs/docs-proofs/` — **curated portal screenshots** (published)
- `proofs/audit/` — **redacted audit artifacts** (published)
- `proofs/_local/` — local-only raw artifacts (ignored by Git)

Raw Terraform outputs, CLI dumps, tfstate files, and keys are **never committed**.

---

## Security stance (core design)

### No public exposure
- VMs have **no Public IPs**
- No direct inbound management traffic
- Administrative access only via **Azure Bastion**

### Network enforcement
- NSGs enforce explicit, minimal flows
- ASGs avoid IP-based rules and improve readability
- Frontend ↔ Backend communication is tightly scoped

---

## Prerequisites

- Terraform 1.x
- Azure CLI (`az`)
- An Azure subscription
- PowerShell (for the redaction pipeline)

---

## Typical workflow

## Step 1: Authenticate
```bash
az login
az account show
```

## Step 2: Configure variables
```bash
cp terraform.tfvars.example terraform.tfvars
```
terraform.tfvars is ignored by .gitignore and must never be committed.

## Step 3: Deploy
```bash
terraform init
terraform fmt
terraform validate

terraform plan -out tfplan
terraform apply tfplan
```
Optional sanity checks
```bash
terraform state list
terraform output
```
## Step 4: Destroy (cost control)
```bash
terraform destroy
```
Azure Bastion Standard incurs cost while running — the intended lifecycle is:
deploy → verify → destroy.

---

### Proofs: audit-ready by design

## What is published

# Curated portal screenshots

- proofs/docs-proofs/run-<RUN_ID>/screens/

- Resource Group overview

- Bastion deployment

- VNet & subnet layout

# These screenshots demonstrate actual deployment results without leaking identifiers.

- Redacted audit artifacts

- proofs/audit/run-<RUN_ID>/

- Sanitized CLI outputs

- Redacted Terraform verification artifacts

- No raw plans, no state, no secrets

# What is intentionally excluded

- Raw Terraform plans / shows

- Terraform state files

- Unfiltered CLI dumps

- Subscription IDs, tenant IDs, UPNs

- SSH keys (public or private)

- This is a deliberate security decision, not a missing feature.

### Lessons learned (real-world)

Publishing raw infrastructure logs is a liability, not proof

Security awareness includes knowing what not to publish

Bastion fundamentally changes access patterns — SSH exposure becomes unnecessary

Clean evidence beats verbose output

Roadmap

- Network Watcher integration (NSG Flow Logs, redacted)

- Effective security rule evidence

- Optional refactor into Terraform modules

- Expanded FinOps considerations
