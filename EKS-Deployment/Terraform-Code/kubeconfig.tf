############################################################
# KUBECONFIG OUTPUT
############################################################
resource "local_file" "kubeconfig" {
  content = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
        server: ${module.eks.cluster_endpoint}
      name: ${module.eks.cluster_name}
    contexts:
    - context:
        cluster: ${module.eks.cluster_name}
        user: ${module.eks.cluster_name}
      name: ${module.eks.cluster_name}
    current-context: ${module.eks.cluster_name}
    kind: Config
    preferences: {}
    users:
    - name: ${module.eks.cluster_name}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: aws
          args:
          - --region
          - ${var.region}
          - eks
          - get-token
          - --cluster-name
          - ${module.eks.cluster_name}
  EOT
  filename = "kubeconfig_${var.project_name}"
}