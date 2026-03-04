# Jenkins Infra (AWS)

Stack platformowy dla Jenkins (oddzielony od infrastruktury aplikacyjnej).

## Co jest tworzone

- VPC oraz podsieci publiczne/prywatne
- Internet Gateway i routing dla części publicznej
- Security Groups dla ALB, Jenkins EC2 i endpointów SSM
- ALB (listener HTTP :80 -> target Jenkins :8080)
- EC2 z instalacją Jenkins przez `user_data`
- IAM role + instance profile dla SSM
- Key Pair z lokalnego klucza publicznego

## Uruchomienie

```powershell
cd C:\Users\Dawid\Desktop\Jenkins\part_4\AWS\jenkins-infra
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars
```

## Wynik

Output `jenkins_url` zwraca adres ALB do interfejsu Jenkins.

## Ważna uwaga

Aktualny wariant wystawia Jenkins po HTTP i ma otwarty SSH (`22`) do Internetu. To działa technicznie, ale nie domyka wymagań bezpieczeństwa z Part 3/4. W kolejnym kroku warto dodać TLS oraz ograniczenia dostępu administracyjnego.
