locals {
  tags = merge(
    var.tags,
    { account_number = data.aws_caller_identity.current.account_id }
  )
  mandatory_bucket_policy_statement = [
    {
      Sid    = "AllowSSLRequestsOnly"
      Action = "s3:*"
      Effect = "Deny"
      Resource = [
        format("arn:aws:s3:::%s", var.bucket),
        format("arn:aws:s3:::%s/*", var.bucket)
      ],
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      },
      Principal = "*"
    },
    {
      Sid    = "AllowTLSRequestsOnly"
      Action = "s3:*"
      Effect = "Deny"
      Resource = [
        format("arn:aws:s3:::%s", var.bucket),
        format("arn:aws:s3:::%s/*", var.bucket)
      ],
      Condition = {
        NumericLessThan = {
          "s3:TlsVersion" = 1.2
        }
      },
      Principal = "*"
    }
  ]

  policy_statements = concat(local.mandatory_bucket_policy_statement, var.policy_statements)
}