variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
  default     = "authentik"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes cluster version"
  default     = "1.30"
}

variable "authentik_domain" {
  type        = string
  description = "Domain for Authentik"
  default     = "authentik.example.com"
}

variable "storage_class" {
  type        = string
  description = "Storage class for persistent volumes"
  default     = "gp3"
}