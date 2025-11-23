locals {
  admin_password    = substr(sha256("${var.project_name}-admin"), 0, 16)
  authentik_postgres_password = substr(sha256("${var.project_name}-postgres"), 16, 16)
  authentik_redis_password    = substr(sha256("${var.project_name}-redis"), 32, 16)
}