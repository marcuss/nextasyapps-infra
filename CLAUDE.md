# CLAUDE.md — Compounding Engineering Knowledge Base

## Terraform

### Regla: TODO cambio de infra va por Terraform
- Environments: `terraform/environments/{dev|prod}/`
- Nunca crear recursos AWS via CLI sin documentarlos en .tf
- Import: CLI import → plan → apply → verificar

### State remoto
- Dev: `s3://nextasyapps-terraform-state-dev`
- Prod: `s3://nextasy-terraform-state-prod`
- Nunca modificar state manualmente

### IAM
- `terraform-admin`: solo para GHA (full access)
- `clawbot-operator`: operaciones diarias (limited)
- Nunca usar terraform-admin keys fuera de GHA

## Supabase Migrations

### Migraciones siempre en este repo
Cada migración en `couplesapp/supabase/migrations/` debe copiarse a `supabase/migrations/`.
GHA `supabase-deploy.yml` las aplica al push a main.
Nunca correr `supabase db push` manualmente.

## Workflows

### terraform-prod requiere approval
GitHub Environment protection rule. Nunca hacer terraform apply en prod sin approval.

### Al rotar IAM keys
SIEMPRE actualizar GitHub repo secrets inmediatamente en TODOS los repos que los usen.

## SES SMTP para Supabase

### Setup requerido (Marcus lo quiere con custom SMTP propio, no Gmail)
- **IAM user:** `couplesapp-ses-smtp-dev` y `couplesapp-ses-smtp-prod` (gestionados por Terraform)
- **Terraform:** `terraform/environments/dev/ses-smtp.tf` y `terraform/environments/prod/ses-smtp.tf`
- **Outputs post-apply:** `ses_smtp_user_dev` y `ses_smtp_password_dev` (sensitive)
- **Después del apply:** guardar outputs en Infisical (`SUPABASE_SMTP_USER`, `SUPABASE_SMTP_PASS`) y actualizar Supabase via Management API
- **SMTP config Supabase:**
  - host: `email-smtp.us-east-1.amazonaws.com`
  - port: `587`
  - user: `<ses_smtp_user output>`
  - pass: `<ses_smtp_password output>` ← `ses_smtp_password_v4` (NO es el secret key)
  - from: `couplesapp-noreply@nextasy.co`
- **IMPORTANTE:** La pass SMTP es derivada del secret key via SigV4 — `aws_iam_access_key.ses_smtp_password_v4` en Terraform
- **Estado temporal (dev):** Gmail SMTP de Marcus (`m4rkuz@gmail.com`) mientras no se aplique Terraform

### Al rotar credentials SES SMTP
1. Terraform destroy + apply del `aws_iam_access_key` resource
2. Capturar nuevo output `ses_smtp_password_dev`
3. Actualizar Infisical + Supabase config via Management API
4. Verificar con `curl POST /auth/v1/recover` que responde 200

## Incidentes Codificados

### 2026-03-08: 3 workflows rotos al mismo tiempo
- **Qué pasó:** AWS keys, GHA permissions, e Infisical no configurado
- **Root cause:** Migración de IAM sin actualizar secrets en GHA
- **Fix:** Updated GitHub secrets + fixed workflow permissions
- **Regla:** Al rotar IAM keys, SIEMPRE actualizar GitHub repo secrets
