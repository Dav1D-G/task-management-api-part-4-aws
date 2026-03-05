# Terraform Remote State (AWS)

This stack creates a shared Terraform backend for other stacks in this repository.

## What is created

- S3 bucket for Terraform state (`terraform.tfstate`)
- DynamoDB table for state locking (`LockID`)
- S3 versioning and server-side encryption
- S3 public access block

## Apply

```powershell
cd aws/remote-state
terraform init
terraform apply -var-file=terraform.tfvars
```

## After deployment

Use output values `bucket_name` and `lock_table_name` in backend configs used by:

- `aws/jenkins-infra/backend.hcl`
- `aws/app-infra/backend.hcl`