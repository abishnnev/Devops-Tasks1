############################################################
# KUBERNETES NAMESPACE
############################################################
resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }

  depends_on = [time_sleep.wait_for_eks]
}

############################################################
# AUTHENTIK SECRETS
############################################################
resource "kubernetes_secret" "authentik_secrets" {
  metadata {
    name      = "authentik-secrets"
    namespace = kubernetes_namespace.authentik.metadata[0].name
  }

  data = {
    secret-key          = substr(sha256("${var.project_name}-admin"), 0, 50)
    admin-password      = local.admin_password
    postgresql-password = local.authentik_postgres_password
    redis-password      = local.authentik_redis_password
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.authentik]
}

############################################################
# AUTHENTIK HELM RELEASE
############################################################
resource "helm_release" "authentik" {
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  version    = "2023.10.2"
  namespace  = kubernetes_namespace.authentik.metadata[0].name

  values = [
    templatefile("${path.module}/authentik-values.yml", {
      storage_class = var.storage_class
      project_name  = var.project_name
    })
  ]

  timeout = 600

  # Set secret key directly instead of through values file
  set_sensitive {
    name  = "authentik.secret_key"
    value = substr(sha256("${var.project_name}-secret"), 0, 50)
  }

  depends_on = [
    kubernetes_secret.authentik_secrets,
    helm_release.ebs_csi_driver
  ]
}