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

## Incidentes Codificados

### 2026-03-08: 3 workflows rotos al mismo tiempo
- **Qué pasó:** AWS keys, GHA permissions, e Infisical no configurado
- **Root cause:** Migración de IAM sin actualizar secrets en GHA
- **Fix:** Updated GitHub secrets + fixed workflow permissions
- **Regla:** Al rotar IAM keys, SIEMPRE actualizar GitHub repo secrets
