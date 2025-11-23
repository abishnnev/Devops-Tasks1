############################################################
# VELERO S3 BUCKET
############################################################
resource "aws_s3_bucket" "velero" {
  bucket = "${var.project_name}-velero-backups-${substr(md5("${var.project_name}-${var.region}"), 0, 8)}"
  
  tags = {
    Name    = "velero-backups-${var.project_name}"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "velero" {
  bucket = aws_s3_bucket.velero.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################################
# VELERO IAM POLICY
############################################################
resource "aws_iam_policy" "velero" {
  name        = "${var.project_name}-velero-policy"
  description = "Policy for Velero backups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${aws_s3_bucket.velero.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.velero.arn
      }
    ]
  })
}

############################################################
# VELERO IAM ROLE
############################################################
resource "aws_iam_role" "velero" {
  name = "${var.project_name}-velero-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:velero:velero-server"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "velero" {
  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero.arn
}

############################################################
# VELERO KUBERNETES DEPLOYMENT
############################################################
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }

  depends_on = [module.eks]
}

resource "kubernetes_service_account" "velero_server" {
  metadata {
    name      = "velero-server"
    namespace = kubernetes_namespace.velero.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.velero.arn
    }
  }

  depends_on = [kubernetes_namespace.velero]
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = kubernetes_namespace.velero.metadata[0].name
  version    = "5.0.2"

  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }

  set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-aws:v1.8.0"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  set {
    name  = "credentials.useSecret"
    value = "false"
  }

  set {
    name  = "configuration.provider"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.name"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = aws_s3_bucket.velero.bucket
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.region
  }

  set {
    name  = "configuration.volumeSnapshotLocation.name"
    value = "aws"
  }

  set {
    name  = "configuration.volumeSnapshotLocation.config.region"
    value = var.region
  }

  set {
    name  = "serviceAccount.server.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.server.name"
    value = "velero-server"
  }

  depends_on = [
    kubernetes_service_account.velero_server,
    module.eks,
    aws_iam_role.velero
  ]
}