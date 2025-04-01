# Create a VPC
# Create Public Subnet
# Create Private Subnet
# Enable VPC Flow Logs
# Setup NACL 
# Create NAT Gateway

# NAT Gateway is used here, but the best practice woudl be
# Route all inboud traffic for public content via CDN protected by WAF
# All secure API call via WAF and Network Firewall into public subnet
# Any application egress traffic via Proxy Server
# Any B2B egress traffic via Private Gateway

module "vpc_subnets" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr

  tags = var.coretags
}


# Create S3 Buckets for Logging and  Artifacts 

module "logs_bucket" {
  source = "./modules/s3bucket"

  bucket = join("-", [var.appname, local.account_id, "logging"])
  kms_master_key_id = "alias/s3"
  bucket_lifecycle_status = true

  tags = var.coretags
}

module "artifacts_bucket" {
  source = "./modules/s3bucket"

  bucket = join("-", [var.appname, local.account_id, "artifacts"])
  kms_master_key_id = "alias/s3"

  bucket_versioning_status = true

  tags = var.coretags
}

module "s3_kms_key" {
  source = "./modules/kms"
  tags = var.coretags
  is_key_enabled = true
  name = "alias/s3"
}


# Create a VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id             = module.vpc_subnets.vpc_id
  service_name       = "com.amazonaws.ap-southeast-2.s3"  
  route_table_ids    = [module.vpc_subnets.public_route_table, module.vpc_subnets.private_route_table]
  vpc_endpoint_type  = "Gateway"
  policy             = jsonencode({
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::*"
      }
    ]
  })
}

# ACM SSL Certificate for website 
# This assumes that the domain validation is already completed
resource "aws_acm_certificate" "web_cert" {
  domain_name       = "web.myexampleorg.com.au"
  validation_method = "DNS"

  subject_alternative_names = ["www.myexampleorg.com.au"]

  tags = var.coretags
}