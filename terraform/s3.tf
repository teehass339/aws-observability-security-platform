resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "alb-logs" {
  bucket        = "alb-access-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:PutObject"
        Principal = {
          AWS = data.aws_elb_service_account.current.arn
        }
        Resource = "${aws_s3_bucket.alb-logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "cloudtrail-logs" {
  bucket        = "cloudtrail-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "cloudtrail-logs" {
  bucket = aws_s3_bucket.cloudtrail-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail-logs" {
  bucket = aws_s3_bucket.cloudtrail-logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_caller_identity" "current" {
}
data "aws_elb_service_account" "current" {
}


resource "aws_s3_bucket_policy" "cloudtrail-logs" {
  bucket = aws_s3_bucket.cloudtrail-logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Action = "s3:PutObject"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.cloudtrail-logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Action = "s3:GetBucketAcl"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource = aws_s3_bucket.cloudtrail-logs.arn
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Action    = "s3:*"
        Principal = "*"
        Resource = [
          aws_s3_bucket.cloudtrail-logs.arn,
          "${aws_s3_bucket.cloudtrail-logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyDelete"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${aws_s3_bucket.cloudtrail-logs.arn}/*"
      }
    ]
  })
}