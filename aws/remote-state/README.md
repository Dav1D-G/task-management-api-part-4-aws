# Terraform Remote State (AWS)

Ten stack tworzy wspólny backend Terraform dla pozostałych katalogów.

## Co jest tworzone

- Bucket S3 na `terraform.tfstate`
- Tabela DynamoDB do blokowania stanu (`LockID`)
- Versioning i szyfrowanie SSE po stronie S3
- Blokada publicznego dostępu do bucketu

## Uruchomienie

```powershell
cd C:\Users\Dawid\Desktop\Jenkins\part_4\AWS\remote-state
terraform init
terraform apply -var-file=terraform.tfvars
```

## Po wdrożeniu

Wartości `bucket_name` i `lock_table_name` muszą zgadzać się z `backend.hcl` w:

- `..\jenkins-infra\backend.hcl`
- `..\app-infra\backend.hcl`
