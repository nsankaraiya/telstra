
# This route53 module is templated to create Public or Private hosted zone

resource "aws_route53_private_zone" "this" {
  
  name = var.name
  comment = var.comment
  tags = var.tags

  # Setting the VPC attribute below ensures that the DNS Zone is private hosted sone
  vpc {
    vpc_id = lookup(var.vpc, "vpc_id")
    vpc_region = lookup(var.vpc, "vpc_region")
  }

}


resource "aws_route53_public_zone" "this" {

  name = var.name
  comment = var.comment
  tags = local.tags

}

# Additionally Cloudwatch Alarm can be enabled to trigger alarm when route53 record is changes

# Protect agains DDoS attack by using AWS Shield Advanced

resource "aws_shield_protection" "route53_ddos" {
  name         = "Route53Protection"
  resource_arn = aws_route53_public_zone.this.arn
}

# Enable DNSSEC to prevent DNS spoofing
resource "aws_route53_key_signing_key" "dnssec_key" {
  hosted_zone_id      = aws_route53_public_zone.this.zone_id
  key_management_service_arn = aws_kms_key.dnssec_kms.arn
  name                = "dnssec-key"
}

resource "aws_kms_key" "dnssec_kms" {
  description = "KMS key for DNSSEC signing"
}