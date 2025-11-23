# Jenkins Server on AWS with Terraform

A modular Terraform infrastructure to deploy a production-ready Jenkins server on AWS with Docker Compose, Elastic IP, and automated EBS snapshots.

## Features
- Modular Terraform Code - Well-structured, reusable modules following best practices

- Docker Compose Deployment - Jenkins deployed using Docker from GitHub repository

- Data Persistence - EBS volume for Jenkins data with automatic mounting

- Elastic IP - Static public IP address assigned to Jenkins instance

- Automated Backups - Daily EBS snapshots with configurable retention

- Security Hardened - Proper security groups and networking setup

- Cost Optimized - Proper tagging and resource management

## 📁 Project Structure
```bash
jenkins-infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── modules/
│   ├── jenkins-server/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user-data.sh
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ebs-backup/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    └── setup-jenkins.sh
 ```
## 🛠️ Technologies Used

- Terraform v1.x

- AWS EC2, VPC, EBS, EIP, DLM (Lifecycle Manager)

- Docker & Docker Compose

- GitHub Repo for Docker Compose

## 🧩 Terraform Modules

### 1️⃣ VPC Module- backup_retention_days = 7
Creates:

VPC

- Public Subnets

- Internet Gateway

- Route Tables

### 2️⃣ Security Groups Module
Configures:

- SSH Access (port 22)

- Jenkins HTTP (port 8080)

- Restrictive inbound/outbound rules

### 3️⃣ EC2 Module
Creates:

- EC2 instance (Ubuntu 22.04)

- Attached EBS volume for Jenkins

 User Data to:

- Install Docker + Docker Compose

- Clone GitHub repo

- Start Jenkins container

### 4️⃣ Elastic IP Module

- Assigns an EIP to EC2 for static Jenkins access.

### 5️⃣ Snapshot Policy Module
Configures:

- AWS Lifecycle Manager (DLM)

- Daily scheduled EBS snapshots with retention

## ⚙️ Jenkins Deployment Flow

- 1.Terraform provisions infrastructure

- 2.EC2 instance launches with User Data

- 3.User Data script performs:

   - Install Docker & Docker Compose

   - Clone Jenkins docker-compose repo:

```bash
git clone https://github.com/<your-repo>/jenkins-docker
cd jenkins-docker
docker compose up -d
```
- 4.Jenkins starts and persists data to EBS volume

## 📦 Docker Compose File (Features)

- Jenkins LTS image

- Mounted persistent volume:
```bash
/var/jenkins_home
```
- ustom network

- Automatic restart policy

## 🌐 Accessing Jenkins

After Terraform apply:
```bash
http://<Elastic-IP>:8080
```
Retrieve initial admin password:
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
https://github.com/abishnnev/Devops-Tasks/blob/4fb56edf9dab9233219147e91fcb2d8e437b4d16/Jenkins-Aws-Cloud/screenshots/jenkins-outputs.JPG
## ▶️ How to Deploy

- 1. Initialize Terraform
```bash
terraform init
```
https://github.com/abishnnev/Devops-Tasks/blob/9a2eb54cce37a8880e666628432999351a03c3b1/Jenkins-Aws-Cloud/screenshots/terraform-init.JPG
- 2. Plan
```bash
terraform plan
```
https://github.com/abishnnev/Devops-Tasks/blob/9a2eb54cce37a8880e666628432999351a03c3b1/Jenkins-Aws-Cloud/screenshots/terraform-plan.JPG
- 3. Apply
```bash
terraform destroy -auto-approve
```
https://github.com/abishnnev/Devops-Tasks/blob/9a2eb54cce37a8880e666628432999351a03c3b1/Jenkins-Aws-Cloud/screenshots/terraform%20apply.JPG
## 🔐 Security Best Practices Followed

- No hard-coded credentials

- Restricted SG rules

- IAM roles instead of access keys

- Isolated VPC

- Automated backups via DLM

## 📸 EBS Snapshot Automation

Daily snapshot policy includes:

- Automatic tagging

- 7–30 day retention (configurable)

- Automatic cleanup of old snapshots

