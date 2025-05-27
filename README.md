# Terraform Template

## Project Structure

```
├── main.tf                # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
├── providers.tf           # Provider configuration
├── terraform.tfvars       # Variable values (customize per deployment)
└── modules/               # Terraform modules
    ├── database/          # Aurora MySQL database
    ├── ecr/               # ECR repository
    ├── ecs/               # ECS cluster and load balancer
    ├── frontend/          # S3 and CloudFront hosting
    ├── iam/               # IAM roles and policies
    ├── storage/           # S3 storage bucket
    └── vpc/               # VPC networking
```

---

This terraform will create the following services and resources:

- ECS Fargate API service with autoscaling
- RDS database MySQL
- S3 bucket for storage
- S3 bucket for frontend hosting
- ALB with HTTPS
- CloudFront distribution
- ECR repository
- IAM roles and policies
- CloudWatch logs
- CloudWatch alarms

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (v1.0.0+)
- AWS CLI with credentials (Policy: "AdministratorAccess")
- S3 bucket for Terraform state storage
- Docker

## Getting Started

1. Clone the repository
2. Copy the `terraform.tfvars.example` file to `terraform.tfvars` and customize the variables for your deployment:
3. Edit the `terraform.tfvars` file to set your own values for:
   - AWS region
   - Environment name
   - Feature toggle flags
   - ECS container specifications
   - Autoscaling parameters
4. Edit the `providers.tf` file to set your own values for:
   - AWS region
   - AWS S3 bucket for Terraform state storage

## Configuration Variables

The main variables you'll need to customize include:

| Variable | Description |
|----------|-------------|
| `aws_region` | AWS region to deploy resources |
| `environment_name` | Namespace for all resources |
| `db_name` | Database name |
| `db_username` | Database username |
| `db_password` | Database password |
| `storage_bucket_name` | S3 bucket name for application storage |
| `backend_image_url` | Docker image URL for backend |
| `frontend_bucket_name` | S3 bucket name for frontend hosting |
etc...

## Feature Toggle System

You can selectively enable or disable components of the infrastructure by setting the following toggle flags in your `terraform.tfvars` file:

| Toggle Flag | Description | Default |
|-------------|-------------|---------|
| `enable_vpc` | Deploy VPC and networking resources | `false` |
| `enable_ecr` | Deploy ECR repository | `false` |
| `enable_s3_storage` | Deploy S3 storage bucket | `false` |
| `enable_frontend` | Deploy frontend hosting resources | `false` |
| `enable_cloudfront` | Deploy CloudFront hosting resources | `false` |
| `enable_rds` | Deploy database resources | `false` |
| `enable_ecs` | Deploy ECS cluster and services | `false` |

### You should deploy the resources in this order:

1. VPC
2. ECR (upload the backend/api image*)
3. S3 storage
4. S3 frontend + CloudFront  (Together)
5. RDS database
6. ECS (with environment variables)



## Deployment

Run this in the root directory:
```bash
# Initialize Terraform (just once)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

You should initialize just once.
Then, for each resource you want to deploy, set the toggle flag to true in the `terraform.tfvars` file and run `terrafom plan` then `terraform apply`.

## *ECR Upload Instructions

1. Login to ECR with the AWS CLI 
    ```sh
    aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
    ```
2. Build the image
    ```sh
    docker build -t image_name .
    ```
3. Tag the image with the repository name
    ```sh
    docker tag image_name aws_account_id.dkr.ecr.region.amazonaws.com/repository_name:latest
4. Push the image to ECR
    ```sh
    docker push aws_account_id.dkr.ecr.region.amazonaws.com/repository_name:latest
    ```


## Specs

### VPC and Networking
- VPC with public subnets in two availability zones
- Internet Gateway and route tables
- No NAT gateways

### ECR
- ECR repository, no extra features

### S3 Storage
- S3 bucket with encryption
- Public access enabled

### S3 Frontend
- S3 bucket with encryption
- Public access enabled

### CloudFront
- CloudFront distribution with global content delivery
- Origin access identity enabled
- SSL/TLS termination enabled
- Minimum protocol version set to TLSv1.2_2019
- Viewer protocol policy set to allow-all

### RDS Database
- RDS MySQL 8
- Instance type: db.t4g.micro
- Autoscaling enabled
- Public access enabled
- No proxies
- No multi-AZ

### ECS Container Service
- 0.25 vCPU / 0.5 GB memory (AWS Fargate minimum)
- Simple autoscaling based on CPU utilization (70% threshold)
- Application Load Balancer for HTTP/HTTPS traffic



## Clean Up

To destroy the infrastructure:

```bash
terraform destroy
```
