# Task Management API - Part 4 (AWS + Jenkins)

This repository contains a complete test setup for:
- Jenkins (controller + 3 dedicated agents) on AWS EC2
- Terraform remote state on AWS (S3 + DynamoDB lock table)
- Application infrastructure on AWS (ECS Fargate + ALB + ECR)
- CI/CD pipeline that builds and tests a Node.js app, pushes Docker image to ECR, and deploys with Terraform

## Repository Structure

- `jenkins-app/` - sample Node.js app, tests, Dockerfile, and Jenkins pipeline (`Jenkinsfile`)
- `jenkins-platform/` - Docker Compose and Dockerfiles for Jenkins + agents (`agent-ci`, `agent-docker`, `agent-infra`)
- `aws/remote-state/` - Terraform stack for shared remote backend
- `aws/jenkins-infra/` - Terraform stack for Jenkins EC2 infrastructure
- `aws/app-infra/` - Terraform stack for application infrastructure

## Pipeline Flow

The pipeline in `jenkins-app/Jenkinsfile` runs these steps:
1. Checkout source code
2. Install dependencies and run tests
3. Build Docker image locally
4. Run local health check (`/health`)
5. Ensure ECR repository exists (Terraform target apply)
6. Push image to ECR
7. Deploy app infrastructure to ECS (Terraform apply with `container_image`)
8. Optionally destroy app infrastructure after manual approval

## Prerequisites

- AWS account with required permissions
- Terraform >= 1.6
- Jenkins with three configured inbound agents:
  - `agent-ci`
  - `agent-docker`
  - `agent-infra`
- Jenkins VM IAM role permissions for:
  - `AmazonSSMManagedInstanceCore`
  - Terraform/ECR/ECS operations (currently `AdministratorAccess` in this test setup)

## Quick Start

1. Deploy remote state:
   - `cd aws/remote-state`
   - `terraform init`
   - `terraform apply -var-file=terraform.tfvars`
2. Deploy Jenkins infrastructure:
   - `cd aws/jenkins-infra`
   - `terraform init -backend-config=backend.hcl`
   - `terraform apply -var-file=terraform.tfvars`
3. Configure Jenkins agents and credentials.
4. Run pipeline from repository root with script path:
   - `jenkins-app/Jenkinsfile`

## Notes

- This environment is intentionally simplified for assignment/testing purposes.
- Jenkins UI access is expected via SSM port forwarding (`localhost:8080`).
