# Terraform — Supabase Projects (CouplesApp)

Este directorio gestiona los proyectos Supabase de CouplesApp (`couplesapp-dev` y `couplesapp-prod`) via Terraform.

## Prerequisitos

### 1. Supabase Personal Access Token (PAT)

El token de Management API **NO es** la `service_role_key` del proyecto.  
Es un **Personal Access Token** personal de cuenta.

**Cómo obtenerlo:**
1. Ir a https://supabase.com/dashboard/account/tokens
2. Crear un nuevo token con nombre descriptivo (ej: `terraform-nextasyapps`)
3. Copiar el token (solo se muestra una vez)

> ⚠️ El `sb_secret_...` de un proyecto individual NO funciona para crear proyectos vía Management API.

### 2. Supabase Organization ID

1. Ir a https://supabase.com/dashboard/org
2. El Organization ID está en la URL o en la sección Settings de la organización

### 3. Secrets de GitHub Actions

Configurar en el repo `nextasyapps-infra` → Settings → Secrets and Variables → Actions:

| Secret | Descripción |
|--------|-------------|
| `SUPABASE_ACCESS_TOKEN` | Personal Access Token de Supabase |
| `SUPABASE_DEV_PROJECT_REF` | Project ref de couplesapp-dev (tras creación) |
| `SUPABASE_PROD_PROJECT_REF` | Project ref de couplesapp-prod (tras creación) |
| `TF_VAR_supabase_access_token` | Igual que SUPABASE_ACCESS_TOKEN (para Terraform) |
| `TF_VAR_supabase_org_id` | Organization ID de Supabase |
| `TF_VAR_supabase_dev_db_password` | Password DB para dev (generar aleatoriamente) |
| `TF_VAR_supabase_prod_db_password` | Password DB para prod (generar aleatoriamente) |

## Uso local

```bash
cd terraform/environments/dev

# Exportar variables de entorno
export TF_VAR_supabase_access_token="tu_personal_access_token"
export TF_VAR_supabase_org_id="tu_org_id"
export TF_VAR_supabase_dev_db_password="$(openssl rand -base64 32)"
export TF_VAR_supabase_prod_db_password="$(openssl rand -base64 32)"

# Inicializar
terraform init

# Planificar
terraform plan

# Aplicar
terraform apply
```

## Estructura

```
terraform/
├── modules/
│   └── supabase-project/     # Módulo reutilizable para proyectos Supabase
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    └── dev/
        ├── supabase.tf       # Instancia dev y prod
        ├── variables.tf      # Definición de variables
        └── backend.tf        # Configuración de backend
```

## Outputs

Tras ejecutar `terraform apply`, los outputs disponibles son:
- `dev_project_ref` — Project ref de couplesapp-dev
- `dev_api_url` — URL de la API de couplesapp-dev
- `dev_anon_key` — Anon key de couplesapp-dev
- `prod_project_ref` — Project ref de couplesapp-prod
- `prod_api_url` — URL de la API de couplesapp-prod
- `prod_anon_key` — Anon key de couplesapp-prod
