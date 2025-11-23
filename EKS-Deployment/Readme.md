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
authentik-eks-lab/
├── main.tf                 # Core EKS and VPC configuration
├── variables.tf            # Configurable variables
├── outputs.tf              # Terraform outputs
├── ingress-controller.tf   # NGINX ingress setup
├── velero.tf              # Backup infrastructure
├── authentik-values.yaml   # Authentik Helm chart values
└── README.md              # This file
```
## 🚀 Quick Start
Prerequisites
- Terraform >= 1.0.0
- AWS CLI configured
- kubectl
- helm

Deploy infrastructure

```bash
terraform init
terraform plan
terraform apply
```

bash
aws eks update-kubeconfig --name authentik-eks-lab --region us-east-1
Deploy Authentik

bash
# Update authentik-values.yaml with secure values
helm repo add authentik https://charts.goauthentik.io
helm install authentik authentik/authentik -f authentik-values.yaml
⚙️ Configuration
Authentik Configuration
Update authentik-values.yaml with:

Secure secret_key (50+ characters)

Strong initial_admin_password

Your domain in server.ingress.hosts

Velero Backup
Automated daily backups of Authentik namespace

S3 storage with encryption

EBS volume snapshots

30-day retention policy

## 📊 Outputs
After deployment, Terraform will provide:

kubeconfig_command - Command to configure kubectl

nginx_ingress_hostname - NLB DNS for ingress

velero_bucket_name - S3 bucket for backups

## 🔧 Management
Access Authentik
Get the NLB hostname from outputs

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






