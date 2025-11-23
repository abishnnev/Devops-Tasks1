output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "authentik_admin_password" {
  value     = local.admin_password
  sensitive = true
}

output "velero_s3_bucket" {
  value = aws_s3_bucket.velero.bucket
}

output "kubeconfig_filename" {
  value = local_file.kubeconfig.filename
}

output "authentik_load_balancer" {
  value = "Check with: kubectl get svc -n authentik authentik-authentik"
}

output "ebs_csi_driver_status" {
  value = helm_release.ebs_csi_driver.status
}