# GitHub Actions Azure VMSS Deployment

[![CI-CD Pipeline](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions)](https://github.com/sureshanand1619/github-actions-azure-demo/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.9.8-7B42BC?logo=terraform)](https://www.terraform.io/)
[![Checkov](https://img.shields.io/badge/Checkov-Prisma_Cloud-EE3124?logo=prismacloud)](https://www.checkov.io/)
[![Azure](https://img.shields.io/badge/Azure-VMSS-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Docker](https://img.shields.io/badge/Docker-ACR-2496ED?logo=docker)](https://www.docker.com/)

> A production-ready, containerised application deployment platform using GitHub Actions, Terraform, and Azure — built to demonstrate real-world DevOps engineering practices across the full CI/CD lifecycle.

This project builds and deploys a Node.js Express application to Azure VMSS via a fully automated, gated pipeline — covering unit testing, Docker image builds, container security scanning, infrastructure provisioning, manual approval gates, and post-deployment smoke testing — all wired together with GitHub Actions.

---

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │            INTERNET                  │
                        └──────────────────┬──────────────────┘
                                           │
                        ┌──────────────────▼──────────────────┐
                        │         Azure Load Balancer          │
                        │    Public IP │ Health Probes         │
                        └──────────────────┬──────────────────┘
                                           │
                        ┌──────────────────▼──────────────────┐
                        │    Virtual Machine Scale Set         │
                        │    Ubuntu 22.04 LTS                  │
                        │    Docker → Node.js Express App      │
                        │    Min: N │ Max: N │ CPU Autoscale   │
                        └──────┬───────────────────┬──────────┘
                               │                   │
          ┌────────────────────▼───┐       ┌───────▼────────────────────┐
          │     Public Subnet      │       │      Private Subnet         │
          │  HTTP/HTTPS: open      │       │  Internal traffic only      │
          │  SSH: restricted CIDR  │       │  NSG protected              │
          └────────────────────────┘       └────────────────────────────┘
                               │
          ┌────────────────────┼───────────────────────┐
          │                                            │
┌─────────▼──────────┐                    ┌────────────▼───────────┐
│  Azure Container   │                    │   Azure Blob Storage   │
│  Registry (ACR)    │                    │   Terraform State      │
│  Docker images     │                    │   dev / staging / prod │
└────────────────────┘                    └────────────────────────┘
```

---

## What This Platform Provides

| Capability | Detail |
|---|---|
| Application CI | Unit tests, Docker build, Trivy image scan, push to ACR |
| Infrastructure CD | Terraform validate, TFLint, Checkov, plan, approval, apply |
| Auto Scaling | CPU-based scale out and scale in with configurable thresholds |
| Load Balancing | Azure Load Balancer with health probes and backend pool |
| Network Security | NSG-protected subnets, SSH restricted to allowed CIDRs |
| Container Registry | Azure Container Registry with admin-based image pulls |
| Multi-Environment | Independent dev / staging / prod configurations |
| Remote State | Azure Blob Storage with environment-scoped state files |
| Smoke Testing | Post-deploy health check and endpoint validation |

---

## Tech Stack

| Category | Tool / Service |
|---|---|
| Application | Node.js + Express |
| Containerisation | Docker |
| Container Registry | Azure Container Registry (ACR) |
| Infrastructure as Code | Terraform 1.9.8 |
| Cloud Provider | Microsoft Azure (azurerm) |
| CI/CD | GitHub Actions |
| State Backend | Azure Blob Storage |
| Image Security Scanning | Trivy (Aqua Security) |
| IaC Security Scanning | Checkov (Prisma Cloud) |
| IaC Linting | TFLint |
| Unit Testing | Jest + Supertest |

---

## Repository Structure

```
github-actions-azure-demo/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml            # Build → Approval → Deploy pipeline
│       └── tf-deploy.yml        # Terraform validate → plan → apply pipeline
├── app/
│   ├── index.js                 # Node.js Express application
│   ├── index.test.js            # Jest unit tests
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
└── terraform/
    ├── modules/
    │   ├── rg/                  # Resource Group
    │   ├── network/             # VNet, public + private subnets
    │   ├── nsg/                 # Network Security Group rules
    │   ├── acr/                 # Azure Container Registry
    │   └── vmss/                # VM Scale Set + Autoscaling
    └── env/
        ├── dev/                 # Dev environment entry point
        ├── staging/             # Staging environment entry point
        └── prod/                # Production environment entry point
```

---

## CI/CD Pipelines

### `ci-cd.yml` — Application Pipeline
Triggered automatically on push to `main` when files under `app/**` change.

```
Push to main (app/**)
        │
        ▼
┌──────────────────────────────────────────────┐
│  TEST                                        │
│  • npm ci                                    │
│  • Jest unit tests with coverage             │
└──────────────────────┬───────────────────────┘
                       │ tests pass
                       ▼
┌──────────────────────────────────────────────┐
│  BUILD & SCAN                                │
│  • Docker build                              │
│  • Trivy image scan (CRITICAL severity)      │
│  • Push to Azure Container Registry          │
└──────────────────────┬───────────────────────┘
                       │ image pushed
                       ▼
┌──────────────────────────────────────────────┐
│  APPROVAL                                    │
│  • Manual review gate (GitHub Environment)   │
│  • Reviewer approves before deploy runs      │
└──────────────────────┬───────────────────────┘
                       │ approved
                       ▼
┌──────────────────────────────────────────────┐
│  GET INFRA OUTPUTS                           │
│  • terraform init + output                   │
│  • Reads ACR server, RG, LB IP, VMSS name    │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  DEPLOY                                      │
│  • az vmss run-command → docker pull         │
│  • Stop/remove old container                 │
│  • Run new container with image tag          │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  SMOKE TEST                                  │
│  • curl /health → expect 200                 │
│  • curl / → expect app response              │
└──────────────────────────────────────────────┘
```

---

### `tf-deploy.yml` — Infrastructure Pipeline
Triggered automatically on push to `main` when files under `terraform/**` change, or manually with environment selection.

```
Push to main (terraform/**) or Manual trigger
        │
        ▼
┌──────────────────────────────────────────────┐
│  VALIDATE                                    │
│  • terraform fmt -check (format enforcement) │
│  • terraform init + validate                 │
│  • TFLint (typed variables, best practices)  │
│  • Checkov security scan (Prisma Cloud)      │
└──────────────────────┬───────────────────────┘
                       │ all checks pass
                       ▼
┌──────────────────────────────────────────────┐
│  PLAN                                        │
│  • terraform plan -out=tfplan                │
│  • tfplan uploaded as pipeline artifact      │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  APPROVAL                                    │
│  • Manual review gate (GitHub Environment)   │
│  • Reviewer inspects plan before approving   │
└──────────────────────┬───────────────────────┘
                       │ approved
                       ▼
┌──────────────────────────────────────────────┐
│  APPLY                                       │
│  • Downloads tfplan artifact from Plan job   │
│  • terraform apply (executes exact plan)     │
└──────────────────────────────────────────────┘
```

---

## Pipeline Design Decisions

**Path-based triggers** — `ci-cd.yml` only fires on `app/**` changes and `tf-deploy.yml` only fires on `terraform/**` changes. A README edit never triggers a deployment.

**Artifact-based plan promotion** — the `tfplan` binary is uploaded as a GitHub Actions artifact after Plan and downloaded in Apply. This guarantees Apply executes exactly what was reviewed — no drift, no surprises across fresh runners.

**Manual approval gate** — neither application deploy nor terraform apply runs automatically. A reviewer must inspect the output and explicitly approve via the GitHub Environment protection rule before the next job runs.

**Terraform outputs as CD source of truth** — the CD pipeline reads ACR login server, resource group name, VMSS name, and LB public IP directly from `terraform output` rather than hardcoding them. Infrastructure changes automatically flow into deployments.

**Image tag traceability** — the Docker image is tagged with the git commit SHA (`github.sha`), making every deployed image traceable back to the exact commit that built it.

**Security scanning before cloud touches** — Trivy runs against the built image before it is pushed to ACR. Checkov runs against Terraform before any Azure resources are touched. Known POC exceptions are explicitly documented in the skip list.

---

## Multi-Environment Configuration

Each environment has its own `terraform.tfvars` — fully independent, no shared state:

| Variable | Description |
|---|---|
| `environment` | Name tag applied to all resources |
| `location` | Azure region |
| `acr_name` | Azure Container Registry name (globally unique) |
| `vnet_cidr` | VNet address space |
| `public_subnet_cidr` | Public subnet CIDR |
| `private_subnet_cidr` | Private subnet CIDR |
| `allowed_ssh_ip` | CIDR allowed for SSH access |
| `vm_sku` | VMSS instance size |
| `instance_count` | Initial VMSS instance count |
| `min_instance_count` | Autoscale floor |
| `max_instance_count` | Autoscale ceiling |
| `scale_out_cpu_threshold` | CPU % to trigger scale out |
| `scale_in_cpu_threshold` | CPU % to trigger scale in |
| `image_tag` | Docker image tag to deploy |

---

## GitHub Secrets Required

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure service principal JSON (full SDK auth output) |
| `ARM_CLIENT_ID` | Service principal client ID |
| `ARM_CLIENT_SECRET` | Service principal client secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `ACR_LOGIN_SERVER` | ACR login server (e.g. devghaacrdemopoc.azurecr.io) |
| `ACR_USERNAME` | ACR admin username |
| `ACR_PASSWORD` | ACR admin password |
| `VMSS_ADMIN_PASSWORD` | Admin password for VMSS instances |

---

## Security Posture

- SSH access restricted to specified CIDR — no open-world SSH rules
- NSG enforced on both public and private subnets — validated by Checkov CKV2_AZURE_31
- Trivy image scan blocks push on CRITICAL vulnerabilities
- Checkov IaC scan blocks apply if security checks fail
- Image tags pinned to git SHA — no untracked `latest` deployments in prod
- Service principal scoped to subscription with Contributor role

---

## Running Locally

**Prerequisites:** Terraform >= 1.9.8, Docker, Node.js 20, Azure CLI authenticated

```bash
# Clone
git clone https://github.com/sureshanand1619/github-actions-azure-demo.git
cd github-actions-azure-demo

# Run app tests
cd app
npm ci
npm test

# Build and run app locally
docker build -t app:local .
docker run -p 3000:3000 app:local
curl http://localhost:3000/health

# Terraform format check
cd ..
terraform fmt -check -recursive terraform/

# Security scan
docker run --rm \
  -v $HOME/terraform/github-actions-azure-demo:/tf \
  bridgecrew/checkov \
  --directory /tf/terraform/env/dev \
  --skip-check CKV_AZURE_49,CKV_AZURE_97,CKV_AZURE_178,CKV_AZURE_149,CKV_AZURE_160,CKV_AZURE_137,CKV_AZURE_139,CKV_AZURE_163,CKV_AZURE_164,CKV_AZURE_165,CKV_AZURE_166,CKV_AZURE_167,CKV_AZURE_233,CKV_AZURE_237

# Plan for dev
cd terraform/env/dev
terraform init
terraform plan -var="admin_password=YourPassword" -var="image_tag=latest"
```

---

## About This Project

Built as a hands-on platform to demonstrate production-grade containerised application deployment skills for a DevOps / Cloud Engineer role. Every design decision — path-based triggers, artifact-promoted plans, Terraform output integration, image SHA tagging, gated approvals — reflects patterns used in real enterprise CI/CD environments.
