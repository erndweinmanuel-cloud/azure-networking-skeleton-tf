# Curated Proofs – Azure Networking Skeleton (v2 ASG)

This folder contains the *minimum* screenshot set to prove:

1) Terraform config validates  
2) Outputs exist (public IP + RG + vnet id) + private IPs  
3) Backend service started on port 8080  
4) Backend is actually listening on 0.0.0.0:8080  
5) Frontend can reach backend on 8080 over the private network (ASG/NSG path)

## Files (ordered)

- **00_terraform_validate.png** – `terraform validate` succeeded  
- **01_terraform_output_all.png** – `terraform output` (public IP / RG / vnet id)  
- **02_terraform_output_private_ips.png** – `terraform output -raw frontend_private_ip` + `backend_private_ip`  
- **03_backend_start_http8080.png** – Start HTTP listener on backend via `az vm run-command invoke`  
- **04_backend_listen_8080.png** – Verify backend is listening on `0.0.0.0:8080` (`ss` / `lsof`)  
- **05_frontend_to_backend_curl_8080.png** – From frontend: `curl -m 3 -v http://10.0.2.4:8080` returns **HTTP/1.0 200 OK**

> Tip: keep these in `proofs/cli/` (or `docs/proofs/`) and link them from your main README.
