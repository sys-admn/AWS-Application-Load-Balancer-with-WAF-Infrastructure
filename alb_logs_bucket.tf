# Création du bucket S3 pour les logs ALB
resource "aws_s3_bucket" "alb_logs" {
  bucket = var.environment == "Production" ? "prod-alb-logs-bucket-prod" : "dev-alb-logs-bucket"
  
  tags = merge(
    {
      Name        = "${var.tag}-alb-logs-bucket"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )
}

# Configuration du cycle de vie pour les logs ALB
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_lifecycle" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "log-lifecycle"
    status = "Enabled"
    
    filter {
      prefix = ""
    }

    transition {
      days          = var.logs_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.logs_transition_to_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.logs_expiration_days
    }
  }
}

# Configuration de la politique du bucket pour permettre à l'ALB d'écrire des logs
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::009996457667:root"  # Compte de service ELB pour eu-west-3 (Paris)
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}

# Configuration de la protection contre l'accès public
resource "aws_s3_bucket_public_access_block" "alb_logs_public_access_block" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuration du chiffrement côté serveur
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_encryption" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}