# Jenkins Infrastructure (AWS)

This stack provisions infrastructure for Jenkins, separated from app infrastructure.

## What is created

- VPC with public and private subnets
- Internet Gateway and public routing
- Security groups for Jenkins EC2 and SSM endpoints
- Jenkins EC2 instance in a private subnet
- IAM role and instance profile for SSM and AWS access
- Key pair from a local public key
- Bootstrap via `user_data`:
  - Docker installation
  - Jenkins controller container
  - 3 Jenkins agents (`agent-ci`, `agent-docker`, `agent-infra`)

## Apply

```powershell
cd aws/jenkins-infra
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars
```

## Outputs

- `jenkins_instance_id`
- `jenkins_private_ip`

## Important note

This setup is optimized for assignment/testing speed, not production hardening. For production:
- add TLS and a proper domain for Jenkins
- restrict administrative access paths
- replace broad IAM permissions with least-privilege policies