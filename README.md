# Azure Networking Skeleton with Terraform

A reproducible Azure networking lab built with Terraform. The repository focuses on hub-and-spoke networking, private administration, traffic control, observability, remote state and a controlled deployment lifecycle.

> This is a portfolio and learning project, not a complete production landing zone.

## Current status

The core infrastructure is implemented, validated and safely destroyable.

- Root and bootstrap configurations pass `terraform validate`
- Terraform state is stored in a separate Azure Blob backend
- The workload was successfully destroyed while the remote backend remained intact
- A clean rebuild was verified with: `54 to add, 0 to change, 0 to destroy`
- CI/CD with GitHub Actions, Checkov and Azure OIDC is the next milestone

## Architecture

```text
                           Azure Bastion
                                |
                         +------v------+
                         |   Hub VNet   |
                         | 10.0.0.0/16  |
                         |             |
                         | Linux NVA   |
                         | 10.0.1.4    |
                         +---+-----+---+
                             |     |
                  Peering + UDR   Peering + UDR
                             |     |
              +--------------+     +--------------+
              |                                   |
       +------v---------+                  +------v----------+
       | App Spoke      |                  | Data Spoke      |
       | 10.10.0.0/16   |                  | 10.20.0.0/16    |
       |                |                  |                 |
       | vm-web01       | -- TCP/8080 -->  | vm-db01         |
       | ASG: asg-app   |   via NVA        | ASG: asg-data   |
       +----------------+                  +-----------------+
```

### Network layout

| Component | Address space | Purpose |
|---|---:|---|
| Hub VNet | `10.0.0.0/16` | Shared services and transit |
| AzureBastionSubnet | `10.0.0.0/26` | Central administrative access |
| NVA subnet | `10.0.1.0/24` | Linux network virtual appliance |
| App Spoke | `10.10.0.0/16` | Application workload |
| App subnet | `10.10.1.0/24` | `vm-web01` |
| Data Spoke | `10.20.0.0/16` | Data workload |
| Data subnet | `10.20.1.0/24` | `vm-db01` |

## Implemented capabilities

### Networking

- Hub-and-spoke topology with four VNet peerings
- Linux NVA with NIC IP forwarding and OS-level forwarding
- User-defined routes for App-to-Data and Data-to-App traffic through the NVA
- Private workload VMs without public IP addresses
- Central Azure Bastion in the hub

### Security and identity

- NSGs for App, Data and NVA subnets
- ASG-based App-to-Data rule on TCP/8080
- Explicit SSH allow rules from Azure Bastion
- Explicit deny rules for SSH from all other sources
- Microsoft Entra ID SSH extension on all Linux VMs
- Explicit principal assignment for `Virtual Machine Administrator Login`

### Observability

- Azure Network Watcher integration
- Subnet Flow Logs v2 for App and Data
- Traffic Analytics
- Log Analytics Workspace
- Dedicated Storage Account for flow-log data

### Terraform state

The backend is managed separately under:

```text
bootstrap/terraform-backend/
```

It creates:

- a dedicated resource group
- an Azure Storage Account
- a private Blob container
- RBAC access using `Storage Blob Data Contributor`

The workload can therefore be destroyed without deleting its remote state infrastructure.

## Repository structure

```text
.
├── bootstrap/terraform-backend/   # Separate backend bootstrap stack
├── backend.tf                     # AzureRM backend declaration
├── backend.hcl.example            # Example backend configuration
├── network.tf                     # VNets, subnets and peerings
├── routing.tf                     # Route tables, routes and associations
├── nva.tf                         # Linux NVA configuration
├── bastion.tf                     # Azure Bastion and public IP
├── compute.tf                     # Workload VMs and NICs
├── entra_id.tf                    # Entra SSH and VM login RBAC
├── asg.tf                         # Application Security Groups
├── nsg_app.tf                     # App NSG rules
├── nsg_data.tf                    # Data NSG rules
├── nsg_nva.tf                     # NVA NSG rules
├── observability.tf               # Flow Logs and Log Analytics
├── locals.tf                      # Shared maps and naming data
├── variables.tf                   # Root input variables
└── outputs.tf                     # Useful deployment outputs
```

## Prerequisites

- Terraform compatible with the version constraint in `versions.tf`
- Azure CLI
- An Azure subscription
- Permission to create the required Azure resources and role assignments
- An SSH public key

## Usage

### 1. Bootstrap the remote backend

Create a local file from the example:

```powershell
Copy-Item .\bootstrap\terraform-backend\terraform.tfvars.example `
  .\bootstrap\terraform-backend\terraform.tfvars
```

Set the Entra object ID that should receive backend access:

```hcl
backend_operator_principal_id = "00000000-0000-0000-0000-000000000000"
```

Then run:

```powershell
Push-Location .\bootstrap\terraform-backend
terraform init
terraform plan
terraform apply
Pop-Location
```

### 2. Configure the workload backend

Create a local backend configuration from:

```text
backend.hcl.example
```

Initialize the root stack:

```powershell
terraform init -backend-config=backend.hcl
```

### 3. Configure workload variables

Create `terraform.tfvars` from `terraform.tfvars.example` and set at least:

```hcl
ssh_public_key      = "ssh-ed25519 AAAA..."
vm_admin_principal_id = "00000000-0000-0000-0000-000000000000"
```

### 4. Validate and plan

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan
```

### 5. Deploy or destroy the workload

```powershell
terraform apply
terraform destroy
```

Run workload commands only from the repository root. Do not run `destroy` inside `bootstrap/terraform-backend` unless the backend itself should be removed.

## Validation completed

The following lifecycle has been tested:

```text
bootstrap backend
      -> workload deploy
      -> connectivity and logging validation
      -> workload destroy
      -> backend retained
      -> clean rebuild plan
```

Latest verified rebuild plan:

```text
Plan: 54 to add, 0 to change, 0 to destroy.
```

## Security notes

The current implementation already uses private containers, Entra ID/RBAC access, TLS 1.2 and private workload VMs. Further backend hardening for a production environment could include:

- Blob versioning and soft delete
- Storage firewall rules or a Private Endpoint
- ZRS or GRS according to recovery requirements
- Resource Lock or another explicit deletion-protection strategy

Public network access must be designed together with the future GitHub Actions runner model. Disabling it without private runner connectivity would prevent hosted runners from reaching the backend.

## Roadmap

### v1.1 — Completed

- Remote Terraform state
- Hub-and-spoke topology
- Central Bastion
- Linux NVA and UDR routing
- Entra ID SSH
- NSG and ASG segmentation
- Flow Logs and Log Analytics
- Reproducible deploy/destroy lifecycle

### v1.2 — Next

- GitHub Actions CI
- `terraform fmt` and `terraform validate`
- Checkov security scanning
- Azure authentication through OIDC
- Terraform plan on pull requests
- Manual apply with GitHub Environment approval

### Possible later extensions

- NAT Gateway for deterministic outbound connectivity
- Private Endpoint and Private DNS
- Load Balancer with multiple App VMs
- KQL dashboards and automated smoke tests
- Azure Firewall as a managed replacement for the Linux NVA

## License

See [LICENSE](LICENSE).
