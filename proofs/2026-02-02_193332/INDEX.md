# Proofs – Networking Skeleton (Bastion + Backend ASG/NSG)

This folder is ordered to tell a clean story from **preflight → IaC execution → runtime verification**.

## 0) Preflight (context + sanity)
- **00_preflight_az_account_show_table.png** – shows subscription/account context (you can redact subscription ID).
- **01_preflight_terraform_version.png** – Terraform version used.
- **02_preflight_git_status.png** – working tree state before running (shows which files changed).

## 1) Terraform (IaC lifecycle)
- **03_terraform_fmt.png** – `terraform fmt -recursive` (formatting).
- **04_terraform_validate.png** – `terraform validate`.
- **05_terraform_plan.png** – `terraform plan` summary.
- **06_terraform_apply.png** – `terraform apply` success.
- **07_terraform_output.png** – outputs (IPs, RG name, vnet id).
- **08_terraform_output_json.png** – outputs as JSON (better for audit trails).

## 2) Bastion + VM runtime proofs
- **09_bastion_backend_login.png** – Bastion SSH session into `vm-backend01` (proves private access path).
- **10_backend_8080_not_listening.png** – backend check shows 8080 not listening (baseline check).
- **11_backend_listen_8080.png** – backend check shows service listening on 8080.
- **12_frontend_to_backend_curl_8080.png** – frontend reaches backend via private IP (HTTP 200 OK).

### Optional (if you want to be extra-audit-ready)
Add 1–2 more proofs later:
- start of the backend listener command (systemd or python http server) + `ps`/`ss` output
- Azure Portal screenshot of NSG effective rules on backend NIC/subnet
