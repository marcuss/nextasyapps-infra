# nextasyapps-infra

IaC (Terraform + Helm) para toda la infraestructura de Nextasy Apps.

## Estructura

```
terraform/
├── modules/
│   └── s3-spa/          ← módulo reutilizable para frontends SPA en S3
└── environments/
    ├── dev/             ← cuenta AWS Dev (AWS_ACCOUNT_ID_REDACTED)
    └── prod/            ← cuenta AWS Prod (511930354489)
```

## Uso

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```
