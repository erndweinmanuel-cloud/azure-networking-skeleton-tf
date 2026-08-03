# Azure Networking Skeleton with Terraform

A reproducible Azure networking lab built with Terraform.

The project demonstrates hub-and-spoke networking, private administration, traffic control, observability, remote state and a controlled GitHub Actions deployment lifecycle.

> This is a portfolio and learning project, not a complete production landing zone.

## Current Status

The infrastructure has been successfully:

- deployed through GitHub Actions
- validated against the Terraform configuration
- destroyed through GitHub Actions
- rebuilt without manually recreating the workload resource group or its deployment permissions

The complete Apply ? Validate ? Destroy lifecycle is operational.

## Architecture

```text
                         Azure Bastion
                               |
                        AzureBastionSubnet
                               |
                         +-------------+
                         |   Hub VNet  |
                         | 10.0.0.0/16 |
                         +-------------+
                               |
                         NVA 10.0.1.4
                               |
                 +-------------+-------------+
                 |                           |
          +--------------+            +---------------+
          |  App Spoke   |            |  Data Spoke   |
          | 10.10.0.0/16 |            | 10.20.0.0/16  |
          +--------------+            +---------------+
                 |                           |
             vm-web01                    vm-db01
```

Traffic between the App and Data spokes is routed through the network virtual appliance using user-defined routes.

## Implemented Components

### Networking

- Hub-and-spoke topology
- Hub VNet and two spoke VNets
- Bidirectional VNet peerings
- Dedicated Bastion and NVA subnets
- Azure Bastion with no public IPs on workload VMs
- Linux network virtual appliance with IP forwarding
- User-defined routes through the NVA
- Network Security Groups
- Application Security Groups
- Explicit SSH restrictions
- App-to-Data traffic rule on TCP 8080

### Compute and Identity

- App Linux VM
- Data Linux VM
- NVA Linux VM
- System-assigned managed identities
- Microsoft Entra SSH login extension
- Virtual Machine Administrator Login assignment

### Observability

- Azure Network Watcher
- Subnet Flow Logs v2
- Traffic Analytics
- Log Analytics Workspace
- Dedicated Flow Log Storage Account
- Retention configuration

### Terraform

- AzureRM provider 5.x
- Remote state in Azure Blob Storage
- Azure Blob state locking
- Blob versioning
- Blob and container soft delete
- Separate bootstrap and workload states
- Stable `for_each` keys
- Structured locals and variables
- Imported existing Azure resources
- State migration without resource recreation

## Repository Structure

```text
.
+-- .github/
¦   +-- workflows/
¦       +-- terraform-ci.yml
¦       +-- terraform-apply.yml
¦       +-- terraform-destroy.yml
¦
+-- bootstrap/
¦   +-- terraform-backend/
¦       +-- main.tf
¦       +-- variables.tf
¦       +-- outputs.tf
¦       +-- versions.tf
¦
+-- workload/
    +-- network.tf
    +-- routing.tf
    +-- compute.tf
    +-- nva.tf
    +-- bastion.tf
    +-- nsg_app.tf
    +-- nsg_data.tf
    +-- nsg_nva.tf
    +-- asg.tf
    +-- entra_id.tf
    +-- observability.tf
    +-- variables.tf
    +-- outputs.tf
```

## Separation of Lifecycles

The project uses two Terraform states.

### Bootstrap State

The persistent bootstrap stack manages:

- Terraform backend resource group
- Terraform state storage account
- private state container
- workload resource group `rg-networking-tf`
- GitHub Actions Contributor assignment
- GitHub Actions RBAC Administrator assignment

These resources remain available between workload deployments.

### Workload State

The workload stack manages temporary lab resources:

- VNets and subnets
- peerings
- route tables and routes
- NVA
- VMs and NICs
- Bastion
- NSGs and ASGs
- Flow Logs
- Log Analytics
- Flow Log Storage
- workload-specific role assignments

A workload destroy removes the lab infrastructure while preserving the backend, workload resource group and deployment permissions.

## GitHub Actions

Authentication between GitHub and Azure uses OpenID Connect.

No Azure client secret is stored in the repository.

### Continuous Integration

The CI workflow performs:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- Checkov security scanning
- bootstrap validation

### Manual Apply

The Apply workflow:

- runs only through `workflow_dispatch`
- uses the protected `production` environment
- authenticates with Azure through OIDC
- creates a saved Terraform plan
- applies the saved plan

### Manual Destroy

The Destroy workflow:

- runs only through `workflow_dispatch`
- requires the exact confirmation value `DESTROY`
- uses the protected `production` environment
- creates and displays a destroy plan
- applies only the saved destroy plan
- destroys only the workload stack

## Verified Lifecycle

The following lifecycle has been tested successfully:

```text
GitHub Apply
    ?
53 workload resources created
    ?
Terraform plan returns no changes
    ?
GitHub Destroy
    ?
Workload resources removed
    ?
Bootstrap, workload RG and permanent RBAC remain
```

## Recovery and State Operations

During implementation, the project also covered realistic failure and recovery scenarios:

- partial Azure deployment after an API polling failure
- existing Flow Logs imported into Terraform state
- workload resource group imported into Terraform
- resource group ownership moved from workload state to bootstrap state
- existing RBAC assignments imported into bootstrap state
- state entries removed without deleting Azure resources
- final idempotent plan with no infrastructure drift

## Security Decisions

- no public IPs on workload VMs
- administrative access through Azure Bastion
- Entra-based SSH authentication
- GitHub OIDC instead of stored client secrets
- backend access through Azure RBAC
- workload permissions scoped to the workload resource group where possible
- protected GitHub environment for Apply and Destroy
- explicit confirmation before destruction
- Checkov integrated into CI

## Example Commands

Initialize the workload backend:

```bash
terraform -chdir=workload init \
  -backend-config="resource_group_name=rg-tfstate-networking" \
  -backend-config="storage_account_name=<state-storage-account>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=networking.terraform.tfstate"
```

Validate the workload:

```bash
terraform -chdir=workload fmt -check
terraform -chdir=workload validate
terraform -chdir=workload plan
```

Deployments and destruction are normally performed through the manual GitHub Actions workflows.

## Lessons Learned

Key lessons from this project:

- infrastructure and its deployment foundation should have different lifecycles
- a destroyable workload must not remove the permissions required for its next deployment
- Azure resources can exist even when provider polling reports a failure
- Terraform imports are essential for recovering partially created infrastructure
- stable `for_each` keys must be known before apply
- local and CI variable values must be consistent to avoid misleading replacement plans
- saved plans provide a controlled boundary between review and execution
- idempotence is proven by a final `No changes` plan

## Next Steps

- add updated screenshots of CI, Apply and Destroy runs
- document the GitHub OIDC trust configuration
- review and further reduce monitoring-related RBAC scope
- add workflow status badges
- evaluate reusable Terraform modules where they provide clear value

## License

This project is licensed under the MIT License.
