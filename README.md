# azure-networking-skeleton-tf (v1)

Two-tier Azure networking lab built with Terraform (AzureRM).

## What it deploys

- Resource Group
- VNet `10.0.0.0/16`
- Subnets:
  - `frontend` (`10.0.1.0/24`)
  - `backend` (`10.0.2.0/24`)
  - `AzureBastionSubnet` (optional)
- VM `frontend` with Public IP
- VM `backend` without Public IP
- NSG `backend`
  - Allow TCP 8080 from `frontend` subnet
  - Deny all other inbound traffic from `VirtualNetwork` to backend
- NSG `frontend`
  - Allow SSH (22) only from **your** public IP (`/32`)

## Proof / Evidence

See the curated proof run (plan → apply → outputs → destroy): **[proofs.md](proofs.md)**

## Prereqs

- Azure CLI
- Terraform
- Azure subscription permissions to create networking + compute resources

## Configuration

Create a local `terraform.tfvars` (never commit it):

```powershell
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

Example
```hcl
my_public_ip_cidr = "YOUR_PUBLIC_IP/32"
``` 
Tip: your public IP may change. Update terraform.tfvars and re-apply.

Run
```powershell
az login --use-device-code
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
``` 

Destroy (avoid costs)
```powershell
terraform destroy
``` 


