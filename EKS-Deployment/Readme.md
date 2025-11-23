# Authentik EKS Deployment with Velero Backup

## 📋 Project Overview

This Terraform project deploys a complete Authentik identity provider solution on AWS EKS with automated backups using Velero.

## 🏗️ Architecture Components
###BCore Infrastructure

- AWS EKS Cluster with managed node groups

- VPC Networking with public/private subnets

- NGINX Ingress Controller with Network Load Balancer

- Authentik identity provider deployment

- Velero backup and disaster recovery

## Security & Access

- IAM Roles for Service Accounts (IRSA) for secure AWS access

- SSL/TLS ready ingress configuration

- Secure secret management for Authentik

## Backup & Recovery

- S3 Bucket for Velero backups

- EBS Snapshot capabilities

- Automated daily backups at 2 AM UTC

- 30-day retention policy

## 📁 Project Structure
```bash
authentik-eks-terraform/
├── 📄 README.md                          # Project documentation
├── 📄 main.tf                            # Main infrastructure (VPC, EKS)
├── 📄 providers.tf                       # Terraform provider configurations
├── 📄 variables.tf                       # Input variables with defaults
├── 📄 outputs.tf                         # Terraform outputs
├── 📄 locals.tf                          # Local variables and generated passwords
│
├── 🔧 Kubernetes Configuration
│   ├── 📄 kubernetes.tf                  # Authentik namespace, secrets, and Helm release
│   ├── 📄 k8s-providers.tf               # Kubernetes, Helm, Kubectl providers
│   ├── 📄 kubeconfig.tf                  # Kubeconfig file generation
│   ├── 📄 cluster-wait.tf                # Wait for EKS cluster readiness
│   └── 📄 ebs-csi-driver.tf              # EBS CSI Driver IAM and Helm installation
│
├── 🗂️ Application Configuration
│   └── 📄 authentik-values.yml           # Helm values for Authentik configuration
│
├── 💾 Backup & Storage
│   └── 📄 velero.tf                      # Velero S3 bucket, IAM, and Helm deployment
│
└── 📁 .terraform/                        # Terraform state and plugins (ignored in git)
```
## 🚀 Quick Start
Prerequisites
- Terraform >= 1.0.0
- AWS CLI configured
- helm

Deploy infrastructure

```bash
terraform init
terraform plan
terraform apply
```




# Velero Backup

- Automated daily backups of Authentik namespace

- S3 storage with encryption

- EBS volume snapshots

- 30-day retention policy

## 📊 Outputs
After deployment, Terraform will provide:

- EKS Cluster name and endpoint

- Generated admin password for Authentik

- Kubeconfig filename

- Velero S3 bucket name

- EBS CSI Driver status

## 🔧 Management
Access Authentik
- Get the NLB hostname from outputs

Configure DNS to point to the NLB
 ```bash
- Access Authentik at https://authentik.yourdomain.com
```
## Monitoring Backups
 Check Velero backups
 ```bash
kubectl get backups -n velero
```
# Check backup schedules
```bash
kubectl get schedules -n velero
```
# Create immediate backup
```bash
velero backup create authentik-manual --include-namespaces authentik
```
## Check NGINX ingress
```bash
kubectl logs -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx
```
## Check Velero
```bash
kubectl logs -l component=velero -n velero
```
## Check Authentik
```bash
kubectl logs -l app=authentik -n authentik
```
## 🗑️ Cleanup

Destroy all resources
```bash
terraform destroy
```
## Manual cleanup if needed
```bash
aws s3 rb s3://$(terraform output -raw velero_bucket_name) --force
```






