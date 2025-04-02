locals {

  mandatory_bucket_policy_statement = [
    {
      Sid = "KMSAllowView"
      Action = [
        "kms:List*",
        "kms:Describe*",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      Effect = "Allow"

      Principal = "*"

      condition = {
        StringEquals = {
          "aws:PrincipalAccount" = "${data.aws_caller_identity.current.account_id}"
        }
      }
      Resource = "arn:aws:kms:*:*:key/*"
    },
    {
      Sid = "KMSKeyAdmin"
      Action = [
        "kms:*"
      ]
      Effect = "Allow"

      Principal = {
        AWS = [
          format("arn:aws:iam::%s:role/EnterpriseAdminrole", data.aws_caller_identity.current.account_id),
          format("arn:aws:iam::%s:role/role", data.aws_caller_identity.current.account_id)
        ]
      }
      Resource = "arn:aws:kms:*:*:key/*"
    }
  ]

  policy_statements = concat(local.mandatory_bucket_policy_statement, var.policy_statements)

}