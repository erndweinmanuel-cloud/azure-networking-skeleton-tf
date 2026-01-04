# Proofs (v1)

This folder contains evidence that the Terraform deployment was executed successfully.

## Evidence included
- **Terraform plan**: shows the resources to be created (VNet/Subnets/NSGs/VMs).
- **Terraform apply**: shows successful provisioning (`Apply complete`).
- **NSG rule verification**: shows inbound SSH restricted to my public IP (`/32`).
- **Connectivity test**: HTTP 200 response from the backend service on port 8080 (triggered via VM Run Command / curl).

## Files
See the `proofs/` folder:
- `01-terraform-plan.png`
- `02-terraform-apply.png`
- `03-nsg-rule-list.png`
- `04-runcommand-curl-8080.png`

> Notes:
> - `terraform.tfvars` is intentionally not committed (contains environment-specific values like public IP).
> - State files are intentionally not committed.

