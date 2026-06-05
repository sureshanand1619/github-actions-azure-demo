# GitHub Actions + Azure VMSS Deployment

End-to-end CI/CD pipeline using GitHub Actions to build, scan, and deploy a containerized Node.js application to Azure VMSS via Terraform.

## Architecture

```
GitHub Push
     ↓
GitHub Actions CI
├── Unit Tests (Jest)
├── Docker Build
├── Trivy Image Scan
└── Push to Azure Container Registry (ACR)
     ↓
GitHub Actions CD
├── Terraform Format Check
├── Terraform Validate
├── TFLint
├── Checkov Security Scan
├── Terraform Plan
├── Manual Approval Gate
└── Terraform Apply → Azure VMSS
```

## Repository Structure

```
github-actions-azure-demo
├── app
│   ├── index.js              # Node.js Express app
│   ├── index.test.js         # Jest unit tests
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── terraform
│   ├── modules
│   │   ├── rg                # Resource Group
│   │   ├── network           # VNet + Subnets + NSG associations
│   │   ├── nsg               # Network Security Group
│   │   ├── acr               # Azure Container Registry
│   │   └── vmss              # VM Scale Set + Autoscaling
│   └── env
│       ├── dev
│       ├── staging
│       └── prod
├── .github
│   └── workflows
│       ├── ci.yml            # Build, test, scan, push to ACR
│       ├── tf-plan.yml       # Terraform validate + plan
│       └── tf-apply.yml      # Manual approval + apply
└── README.md
```

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | Push to main (app/**) | Tests → Docker Build → Trivy Scan → Push to ACR |
| `tf-plan.yml` | Manual | Validate → TFLint → Checkov → Plan → Upload artifact |
| `tf-apply.yml` | Manual | Plan → Manual Approval → Apply |

## Prerequisites

- Azure subscription
- Azure service principal with Contributor role
- Azure Storage Account for Terraform state
- GitHub repository secrets configured

## GitHub Secrets Required

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure service principal JSON |
| `ARM_CLIENT_ID` | Service principal client ID |
| `ARM_CLIENT_SECRET` | Service principal client secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `ACR_LOGIN_SERVER` | ACR login server (e.g. devghaacrdemopoc.azurecr.io) |
| `ACR_USERNAME` | ACR admin username |
| `ACR_PASSWORD` | ACR admin password |
| `VMSS_ADMIN_PASSWORD` | Admin password for VMSS instances |

## Setup

### 1. Create Azure Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth
```

Copy the full JSON output — this is your `AZURE_CREDENTIALS` secret.

### 2. Create GitHub Environments

Go to **GitHub → Settings → Environments** and create:
- `dev`
- `staging`
- `prod`

For `staging` and `prod`, add **Required reviewers** to enforce manual approval before apply.

### 3. Add GitHub Secrets

Go to **GitHub → Settings → Secrets and variables → Actions** and add all secrets from the table above.

### 4. Deploy Infrastructure

Run **Terraform Apply** workflow manually:
- Go to **Actions → Terraform Apply → Run workflow**
- Select environment: `dev`
- Click **Run workflow**

### 5. Build and Push App

Either push a change to `app/**` or run **CI - Build and Push** manually.

## Environments

| Environment | Instances | CPU Scale Out | CPU Scale In |
|---|---|---|---|
| dev | 1 (min 1, max 3) | 75% | 25% |
| staging | 2 (min 2, max 5) | 75% | 25% |
| prod | 3 (min 3, max 10) | 70% | 20% |

## Security Checks

Checkov skips applied for POC (to be addressed before prod):

| Check | Reason |
|---|---|
| CKV_AZURE_49, CKV_AZURE_178, CKV_AZURE_149 | Password auth on VMSS (SSH key in prod) |
| CKV_AZURE_97 | Encryption at host (enable in prod) |
| CKV_AZURE_119 | Public IP on NIC (use bastion in prod) |
| CKV_AZURE_160, CKV_AZURE_10 | HTTP/SSH open (intentional for web server) |

## Tech Stack

- **App**: Node.js + Express
- **Containerization**: Docker
- **Registry**: Azure Container Registry (ACR)
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Security Scanning**: Trivy (image), Checkov (IaC), TFLint
- **Cloud**: Microsoft Azure
