# VPC and Subnet Configuration

## Overview
This Terraform configuration sets up a secure **AWS Route 53** public and private hosted zone with security best practices. The setup includes:
- **Public Hosted Zone** for external-facing domains
- **Private Hosted Zone** for internal services
- **DNS Query Logging** for auditing
- **DNSSEC** to protect against DNS spoofing
- **AWS Shield** for DDoS protection
- **CloudWatch Monitoring & Alerts**

---

## Prerequisites
Ensure you have the following before applying the Terraform configuration:
- **Terraform** installed (v1.0.6+ recommended)
- **Pipeline** configured with OIDC authentication
- An **S3 bucket** for Terraform state management (if using remote state)
- A **domain name** registered in Route 53 (for public hosted zones)

---

## Terraform Module Usage

### 1️⃣ Create a Public Hosted Zone
```hcl
module "example_public_hosted_zone" {
  source  =   ./modules/route53
  name    =   var.private_hosted_zone_name
  comment =   "Route 53 Private Hosted Zone for Belong"
  tags    =   {
    cost_center = "abcd1234"
  }
}
```

### 2️⃣ Create a Private Hosted Zone
```hcl
module "example_private_hosted_zone" {
  source  =   ./modules/route53
  name    =   var.private_hosted_zone_name
  comment =   "Route 53 Private Hosted Zone for Belong"
  vpc     =   var.vpc_id
  tags    =   {
    cost_center = "abcd1234"
  }
}
```

---

## Security Best Practices

- **Enable logging** → Monitor DNS queries for anomalies
- **Use DNSSEC** → Prevent DNS spoofing attacks
- **Deploy AWS Shield** → Protect against DDoS attacks
- **Monitor with CloudWatch** → Set up alerts for unauthorized changes

---


