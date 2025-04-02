resource "aws_kms_key" "this" {
  description             = var.kms_description
  multi_region            = var.enable_multi_region
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.kms_deletion_window
  is_enabled              = var.is_key_enabled
  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "Mandatory KMS Policy"
    Statement = local.policy_statements
  })

  tags = var.tags

}

resource "aws_kms_alias" "this" {
  name          = var.name
  name_prefix   = var.name == null ? var.name_prefix : null
  target_key_id = aws_kms_key.this.id
}