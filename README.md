# Flux Flow

The project demonstrates a **production-grade GitOps implementation** using **Flux CD** to manage an Amazon EKS cluster. The setup showcases how modern Kubernetes cluster management can be fully automated through GitOps principles, with **Flux** handling infrastructure and application deployments, and **Karpenter** providing intelligent node provisioning.

This architecture leverages **GitOps practices** throughout, with **Flux** continuously syncing cluster state from Git, **Karpenter** managing dynamic node provisioning, and **Helm charts** deploying core infrastructure components. **Everything is declarative and version-controlled**, from infrastructure specifications to application configurations.

<br>

![Workflow Diagram](https://raw.githubusercontent.com/JunedConnect/project-eks-flux/main/images/fluxcd-workflow.jpg)

<br>

## Key Features

- **Flux CD** - GitOps engine for continuous deployment and reconciliation
- **GitHub Actions** - Automated CI/CD for infrastructure provisioning
- **Amazon EKS** - Managed Kubernetes with infrastructure node isolation
- **Infrastructure Components**:
  - **Karpenter** - Smart node provisioning that responds to workload demands
  - **Cert-Manager** - Automated SSL/TLS certificate management
  - **External-DNS** - Dynamic DNS record management in Route53
  - **NGINX Ingress** - Traffic management and routing
  - **Prometheus & Grafana** - Full observability stack
  - **Headlamp** - Modern Kubernetes dashboard
  - **External Secrets** - Secure secrets management
  - **Trivy Operator** - Security scanning for containers
- **Multi-Environment** - Separate configurations for dev, prod, and local
- **Node Isolation** - Dedicated nodes for infrastructure workloads

<br>

## Why GitOps with Flux

GitOps brings the same version control and pull-request workflow we use for application code to infrastructure management. Instead of manually running commands or pushing changes to the cluster, we declare the desired state in Git and let Flux automatically sync those changes to the cluster.

The combination of Flux and Karpenter creates a highly automated and efficient cluster:
- **Flux** continuously watches Git and applies changes to maintain desired state
- **Karpenter** intelligently provisions and scales nodes based on actual workload needs
- **Infrastructure-as-Code** ensures consistent, repeatable deployments
- **Git as source of truth** provides audit trail and easy rollbacks
- **Automated reconciliation** keeps cluster and Git in sync automatically

This approach eliminates manual cluster operations and ensures infrastructure changes go through the same review process as application code.

<br>

## Directory Structure

```
./
├── clusters/              # Environment-specific Flux Bootstrap
├── flux-apps/
│   ├── base/              # Base app components
│   └── overlay-xxx/       # App environment overlays
├── flux-infra/
│   ├── base/              # Base Infrastructure components (Helm releases)
│   ├── config/            # Helm resource deployment
│   └── overlay-xxx/       # Environment overlays
│       └── values/        # Environment-specific values
├── terraform/
│   ├── modules/           # Terraform modules
│   └── [i.e root .tf]     # Root Terraform configuration 
└── Makefile               # Automation commands
```

The project structure separates infrastructure management (flux-infra) from application deployment (flux-apps), with environment-specific configurations in overlays.This separation ensures clean boundaries between system components and business applications.

<br>

## How to Deploy

**Prerequisites**: 
- Terraform
- kubectl
- Flux CLI
- AWS CLI
- GitHub Personal Access Token (for your GitHub Repo)

<br>

1. Update `terraform/terraform.tfvars` (see Configuration Dependencies below) and deploy infrastructure:
   ```bash
   cd terraform && terraform init && terraform apply
   ```

2. Configure kubeconfig:
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

3. Update configuration values in `flux-infra` directory (see Configuration Dependencies below)

4. Update Flux Bootstrap configuration (see Configuration Dependencies below) and run Flux Bootstrap:
   ```bash
   make flux-bootstrap GITHUB_TOKEN=your_PAT_token_here
   ```

<br>

## Configuration Dependencies

Before deploying, update these configuration values:

**Terraform Configuration** (`terraform/terraform.tfvars`):
- Domain name (i.e. your domain)
- Cluster name (this can be called whatever you wish)

**Flux Infrastructure** (`flux-infra` directory):
- Domain name - Update in `config/issuer.yml` and `overlay-*/values/external-dns-values.yml` (use value from `terraform.tfvars`)
- Cluster name - Update in `overlay-*/values/karpenter-values.yml` and `config/karpenter.yml` (use value from `terraform.tfvars`)
- Ingress domain names - Update in `overlay-*/values/headlamp-values.yml` and `overlay-*/values/prom-graf-values.yml` (e.g. `headlamp.yourdomain.com`)
- Email address - Update in `config/issuer.yml` (your email for Let's Encrypt certificate notifications)
- IAM Role ARNs - Update in `overlay-*/values/*-values.yml` files (cert-manager, external-dns, external-secrets, karpenter) and `config/karpenter.yml`. These values will be outputted during the terraform apply

**GitHub Repository Settings** (`Makefile` - flux-bootstrap target):
- `--owner` - Your GitHub username or organisation
- `--repository` - Your GitHub Repository name
- `--branch` - GitHub Repository Branch name (e.g., `dev`, `main`)
- `--path` - Path to Flux configuration (e.g., `clusters/dev`)

<br>

## Accessing the Platform

Once deployed, you can access these components:

**Kubernetes Dashboard (Headlamp)** -
Access Headlamp through the ingress URL configured in your environment.
Note, create a token in order to access the Headlamp Dashboard:
   ```bash
   kubectl create token headlamp-admin -n headlamp --duration 100m
   ```

**Monitoring (Grafana)** -
Access Grafana through the ingress URL configured in your environment.

**Infrastructure Components** -
```bash
# Check Flux GitOps state
flux get helmreleases -A
```

<br>

## Debugging

### Flux Sync Issues

If Flux isn't syncing with Git:
```bash
# Check sync status
flux get all

# Force manual reconciliation
flux reconcile kustomization flux-infra
flux reconcile kustomization flux-infra-config

# View detailed errors
flux get kustomization flux-infra -n flux-system
flux get kustomization flux-infra-config -n flux-system
```

### Infrastructure Component Failures

Check events to identify issues:
```bash
# Check Helm release status
flux get helmreleases -A

# Check events for failing service
kubectl get events -n <namespace>

# Get pod name
kubectl get pods -n <namespace>

# View pod details and events
kubectl describe pod -n <namespace> <pod-name>

# View pod logs
kubectl logs -n <namespace> <pod-name>
```