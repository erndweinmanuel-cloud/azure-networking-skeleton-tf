# Azure Networking Skeleton (Terraform)

Terraform-based Azure networking setup with:

- Private Linux VMs (no public IPs)
- Azure Bastion for SSH access
- NSGs attached at subnet level
- Application Security Groups (web/db separation)
- Subnet Flow Logs (v2)
- Log Analytics + KQL validation
- Full deploy → verify → destroy lifecycle

Region: westeurope

---

## Network Design Overview

Virtual Network: `10.0.0.0/16`

Subnets:

- `subnet-web` → 10.0.1.0/24 → `vm-web01`
- `subnet-db`  → 10.0.2.0/24 → `vm-db01`
- `AzureBastionSubnet` → 10.0.10.0/26 → Bastion

Design decisions:

- No VM has a Public IP
- SSH access only via Azure Bastion
- NSGs attached at subnet scope
- Explicit deny rules for SSH/RDP from non-Bastion sources
- App traffic rule: web → db on port 8080 (via ASGs)

---

## Observability Setup

Subnet Flow Logs (v2) enabled for:

- subnet-web
- subnet-db

Flow logs are sent to:

- Storage Account
- Traffic Analytics
- Log Analytics Workspace

Validation is performed using KQL queries in Log Analytics.

No raw JSON or CLI dumps are published in this repository.

---

## Validation Run – 2026-02-13

Screenshots are stored under:

`proofs/docs-proofs/run-2026-02-13_075327/screens/`

---

### 1) Deployment completed

Terraform apply completed successfully.

![01_apply_complete](proofs/docs-proofs/run-2026-02-13_075327/screens/01_apply_complete.png)

Resource Group overview:

![02_rg_overview](proofs/docs-proofs/run-2026-02-13_075327/screens/02_rg_overview.png)

---

### 2) Bastion SSH access

Bastion used to access vm-web01.

![03_bastion_connect_form](proofs/docs-proofs/run-2026-02-13_075327/screens/03_bastion_connect_form.png)

Hostname confirmation:

![04_bastion_ssh_hostname](proofs/docs-proofs/run-2026-02-13_075327/screens/04_bastion_ssh_hostname.png)

---

### 3) Allowed traffic test (8080)

Simple HTTP server running on db VM:

![05b_db_httpserver_8080](proofs/docs-proofs/run-2026-02-13_075327/screens/05b_db_httpserver_8080.png)

curl requests from web → db on port 8080:

![05_allowed_8080_curl](proofs/docs-proofs/run-2026-02-13_075327/screens/05_allowed_8080_curl.png)

Expected result: traffic allowed by NSG rule.

---

### 4) Denied traffic test (3389)

nc connection attempts from web → db on port 3389:

![06_denied_3389_nc](proofs/docs-proofs/run-2026-02-13_075327/screens/06_denied_3389_nc.png)

Expected result: inbound traffic denied by NSG rule.

---

### 5) Flow Logs enabled

Flow logs enabled on subnet-web:

![07_flowlog_subnet_web_enabled](proofs/docs-proofs/run-2026-02-13_075327/screens/07_flowlog_subnet_web_enabled.png)

Flow logs enabled on subnet-db:

![08_flowlog_subnet_db_enabled](proofs/docs-proofs/run-2026-02-13_075327/screens/08_flowlog_subnet_db_enabled.png)

---

### 6) Log ingestion verified

Log Analytics query view:

![09_law_logs_view](proofs/docs-proofs/run-2026-02-13_075327/screens/09_law_logs_view.png)

Sample NTA data:

![10_kql_ntanetanalytics_take50](proofs/docs-proofs/run-2026-02-13_075327/screens/10_kql_ntanetanalytics_take50.png)

---

### 7) KQL validation

FlowStatus distribution:

![11d_kql_flowstatus_values](proofs/docs-proofs/run-2026-02-13_075327/screens/11d_kql_flowstatus_values.png)

Allowed vs Denied summary:

![12_kql_allowed_denied_summary](proofs/docs-proofs/run-2026-02-13_075327/screens/12_kql_allowed_denied_summary.png)

Port-level summary (8080 vs 3389):

![13_kql_ports_8080_3389_summary](proofs/docs-proofs/run-2026-02-13_075327/screens/13_kql_ports_8080_3389_summary.png)

3389 direction detail:

![17_kql_3389_direction_detail](proofs/docs-proofs/run-2026-02-13_075327/screens/17_kql_3389_direction_detail.png)

8080 direction detail:

![18_kql_8080_direction_detail](proofs/docs-proofs/run-2026-02-13_075327/screens/18_kql_8080_direction_detail.png)

---

### 8) Cleanup

Environment destroyed using Terraform.

![19_terraform_destroy_complete](proofs/docs-proofs/run-2026-02-13_075327/screens/19_terraform_destroy_complete.png)

---

## Notes

- Raw Terraform/CLI outputs are not published.
- Manual redaction of JSON outputs was tested and discarded due to risk of incomplete sanitization.

---

## Evidence Strategy & Pivot

Initial approach:
- Terraform / Azure CLI JSON outputs
- Automated redaction via PowerShell script
- Publishing sanitized audit dumps

Issue:
- Regex-based redaction was not fully reliable.
- Sensitive fragments (e.g. SSH key material) could remain partially visible.
- Manual verification effort too high to guarantee safety.

Decision:
- No raw dumps are published.
- Only platform-generated evidence is used:
  - Azure Portal views
  - Flow Log configuration
  - Log Analytics (KQL) results

Rationale:
Security > completeness of raw output.
