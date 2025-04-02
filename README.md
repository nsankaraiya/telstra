# Telstra Project

## Overview
This repository contains infrastructure and application components for the Telstra project. It follows best practices for cloud infrastructure management and deployment.

## Repository Structure
```
/
├── app_infra/         # Infrastructure for application components
├── core_infra/        # Core infrastructure setup
├── README.md          # Project documentation
```

## Getting Started
### Prerequisites
- Git
- Terraform
- AWS CLI
- Jenkins
- S3 Bucket to store state file


### Clone the Repository
```sh
git clone  https://github.com/nsankaraiya/telstra.git
cd telstra
```

## Infrastructure

### Core Infrastructure (`core_infra`)
Manages foundational cloud resources such as VPC, Networking, S3 Bucket etc.
This is the first infrastructure code that needs to be deployed.
Using Jenkins and the Jenkins pipeline script create a pipeline that will deploy the core infrastructure

### Application Infrastructure (`app_infra`)
Contains Terraform modules and configurations for deploying application-related resources.
This pipeline will deploy and ALB in public subnet which is setup with Auto Scaling Group to connect to NGINIX application in the backend EC2 instance

## Branches
1. nonprod (default)
2. prod (Golden Copy)

## Deployment
### Using Jenkins

1. Update the required variables in the default.yaml, nonprod.yaml and prod.yaml
2. Create a Jenkins Pipeline
3. Setup Jenkins with required AWS account credentials
4. Setup github webhook to trigger the pipeline when pull request is merged
5. Merge the pull request to nonprod or prod to trigger the pipeline 
    

## AWS Well Architeced Principles Used
1. Operational Efficiency
  a. Tagging Implemented with Cost_Cernter 
  b. Logging enabled at all levels (ALB and EC2)
   
2. Security
  a. Encrption at Rest and Encryption in Trasit implemented for S3 bucket
  b. Encryption at rest can be implemented for EBS volume (Not implemented here)
  c. Security group associated with ALB and EC2 instances allowing only required ports
  d. S3 bucket access enabled through VPCE gateway

3. Cost
  a. Use of spot instance along with reserved instance to serve the traffic
  b. Appropriate cost related tagging for cost management and reporting

4. Performance
  a. Auto scaling group and ALB SSL Termination for faster response

5. Reliability
  a. Health check enabled to ensure new instance is spun up when an instance becomes unhealthy

6. Sustainability (Not Required for this implementation as we do not have lot of archiving of data)
  

## Future Improvement

1. Create custom AMI with all apllications installed and avoid Launch configuration
2. Terraform module can be stored in separate repository and tagged so that appropriate versions can be fetched
3. Test the site accessibility after deployment
4. Create modules for app_infra resources
5. IaM roles refinement
6. NACL Rules refinement
7. Use proxy server for all outbound communication
8. Enable network firewall
9. Setup custom DNS 
10. Enable WAF for inbound requests
11. Access to SSH port directly using ssh key should be disabled and access provided only via approved interface and using short lived credentials provided by software like CyberArk