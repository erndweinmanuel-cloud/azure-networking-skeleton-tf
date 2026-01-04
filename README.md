# azure-networking-skeleton-tf (v1)

Two-tier Azure networking lab built with Terraform.

## What it deploys

- Resource Group
- VNet 10.0.0.0/16
- Subnets: frontend (10.0.1.0/24), backend (10.0.2.0/24), AzureBastionSubnet (optional)
- VM frontend with Public IP
- VM backend without Public IP
- NSG backend:
  - Allow TCP 8080 from frontend subnet
  - Deny all other inbound traffic from VirtualNetwork to backend
- NSG frontend:
  - Allow SSH (22) only from my public IP (/32)

## Files to create

Create this file in the repo root: `terraform.tfvars.example`

Content:
```hcl
my_public_ip_cidr = "YOUR_PUBLIC_IP/32"
```

## How to run

1) Create `terraform.tfvars` from the example and set your own public IP (/32)
```powershell
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
``` 

Example content inside `terraform.tfvars`:
```hcl
my_public_ip_cidr = "83.135.179.151/32"
```

2) Login + init + plan + apply
```powershell
az login --tenant 58bbca4b-2a3b-4da1-87f2-92bd05ee8968 --use-device-code
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

3) Destroy (to avoid costs)
```powershell
terraform destroy
``` 

Note: Your public IP may change. If SSH stops working, update `terraform.tfvars` and run:
```powershell
terraform apply
```

