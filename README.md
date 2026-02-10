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

2) Create your local tfvars:
```bash
cp terraform.tfvars.example terraform.tfvars
```
terraform.tfvars is ignored by .gitignore (correct). Never commit it.

---

## Deploy (reproducible workflow)
From Repo root:
```bash
terraform init
terraform fmt
terraform validate

terraform plan -out tfplan
terraform apply tfplan
```

optional sanity outputs:
```bash
terraform state list
terraform output -json
```

---

## Destroy (FinOps / cost control)
```bash
terraform destroy
```
Bastion Standard costs money if left running — the intended workflow is:
deploy → capture proofs → destroy.

---

## Proofs: audit-ready by design

The rule

✅ commit only curated screenshots + redacted outputs

❌ never commit raw logs, raw CLI dumps, tfstate, tfplan, keys, tenant/subscription identifiers

# What you publish

- Curated screenshots (portal):

- proofs/docs-proofs/run-<RUN_ID>/screens/

- 01_rg_overview.png

- 02_bastion_overview.png

- 03_vnet_subnets.png

# Redacted outputs (CLI/Terraform):

- proofs/audit/run-<RUN_ID>/raw/

- redacted az outputs

- redacted terraform outputs

- redacted plan/show/output JSON

Raw run folders stay local and ignored (by design).

---

## Step-by-step: one complete proof run (0–15)

Use a run id like: YYYY-MM-DD_HHMMSS
Example: 2026-02-09_145705

Create folders (PowerShell):
```powershell
$RUN_ID = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
New-Item -ItemType Directory -Force -Path "proofs\$RUN_ID\raw" | Out-Null
New-Item -ItemType Directory -Force -Path "proofs\docs-proofs\run-$RUN_ID\screens" | Out-Null
```

# Step 0: Run metadata
Create proofs/<RUN_ID>/raw/00_run_meta.txt with:

- timestamp

- repo + branch

- terraform version

- short note about what you deployed

# Step 1-2: Azure account context
```bash
az account show > proofs/<RUN_ID>/raw/01_az_account_show.json
az account show --query "{environmentName:environmentName,name:name,state:state,tenantId:tenantId,user:user,id:id,homeTenantId:homeTenantId}" \
  > proofs/<RUN_ID>/raw/02_az_account_min.json
```

# Step 3-6: Terraform baseline
```bash
terraform version > proofs/<RUN_ID>/raw/03_terraform_version.txt
terraform init > proofs/<RUN_ID>/raw/04_terraform_init.txt
terraform fmt -check -diff > proofs/<RUN_ID>/raw/05_terraform_fmt.txt
terraform validate > proofs/<RUN_ID>/raw/06_terraform_validate.txt
``` 

# Step 7-12: Plan / apply / outputs
```bash
terraform plan -out tfplan > proofs/<RUN_ID>/raw/07_terraform_plan.txt
terraform show -json tfplan > proofs/<RUN_ID>/raw/08_terraform_show_plan.json
```
PowerShell transcript for apply:
```powershell
Start-Transcript -Path "proofs\<RUN_ID>\raw\09_terraform_apply.txt" -Force
terraform apply tfplan
Stop-Transcript
```
```bash
terraform show -json > proofs/<RUN_ID>/raw/10_terraform_show_postapply.json
terraform state list > proofs/<RUN_ID>/raw/11_terraform_state_list.txt
terraform output -json > proofs/<RUN_ID>/raw/12_terraform_output.json
``` 

# Step 13-15: Azure resource checks (adapt names to your RG/VNet)
```bash
az group show -n <RG_NAME> > proofs/<RUN_ID>/raw/13_rg_show.json

az network vnet list --query "[].{name:name,resourceGroup:resourceGroup,location:location,addressSpace:addressSpace}" \
  > proofs/<RUN_ID>/raw/14_vnet_list.json

az network vnet subnet list -g <RG_NAME> --vnet-name <VNET_NAME> \
  > proofs/<RUN_ID>/raw/15_subnet_list.json
```

---

## Redaction: raw → audit-safe
Run after raw files exist and before committing anything:
```powershell
pwsh -File .\tools\redact.ps1 `
  -InputPath  "proofs\$RUN_ID\raw" `
  -OutputPath "proofs\audit\run-$RUN_ID\raw"
```
Expected redactions:

- subscription/tenant GUIDs

- tenant domains / UPNs / emails

- resource IDs

- (optionally) SSH public keys (you enabled this — good)

# Commit only the safe artifacts
```bash
git add proofs/docs-proofs proofs/audit
git commit -m "docs(proofs): add curated screenshots + redacted audit outputs (run <RUN_ID>)"
git push
``` 

## Lessons learned (real-world pitfalls)

- Proofs are not proofs if they leak IDs or contain raw dumps → publish only curated + redacted artifacts.

- tfplan / tfstate must never be committed → .gitignore hardening + remove from cache if ever tracked.

- Bastion changes the whole access model → remove internet-exposed SSH; allow only internal access paths.

- Portal screenshots can leak subscription/tenant info → crop/blur as needed.

## Roadmap (next)

- Network Watcher: NSG flow logs + troubleshooting artifacts (still redacted)

- Add “effective security rules” evidence (redacted)

- Optional: refactor into modules (network, security, compute, bastion)

## Evidence

- Curated portal screenshots: proofs/docs-proofs/

- Redacted audit outputs: proofs/audit/

