resource "aws_s3_bucket" "this" {
  bucket = var.bucket
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy

  tags = local.tags
}


resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode ({
    Version = "2012-10-17"
    Id = join ("_", ws_s3_bucket.this.id, "Bucket Policy")
    Statement = local.policy_statements
  })
}

# Encryption at Rest
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = var.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_master_key_id
      sse_algorithm = "aws:kms"
    }
  }
  
}

# Optionally enable S3 bucket versioning and lifecycle policy

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.s3-bucket-lifecycle.id
  versioning_configuration {
    status = var.bucket_versioning_status
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {

  bucket = aws_s3_bucket.this.bucket

  rule {
    id = "logarchival"

    filter {
      and {
        prefix = "/logs"

        tags = {
          rule      = "archival"
          autoclean = "false"
        }
      }
    }

    status = var.bucket_lifecycle_status

    transition {
      days          = var.object_transition_to_standard_ia
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.object_transition_to_glacier
      storage_class = "GLACIER"
    }
  }
}

# This resource can be separated out to another module if not mandatory in the organization
# This makes the bucket private

resource "aws_s3_bucket_acl" "this" {
  acl = "private"
  bucket = var.bucket
}

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

