# ============================================================
# VARIABLES PARA ENTORNO DEV/PROD - CouplesApp Supabase
# ============================================================
#
# Secrets requeridos (configurar en GitHub Actions o como env vars):
#
# TF_VAR_supabase_access_token  → Personal Access Token de Supabase
#   Obtener en: https://supabase.com/dashboard/account/tokens
#   NOTA: Este es un PAT personal, NO la service_role_key del proyecto.
#
# TF_VAR_supabase_org_id       → ID de la organización Supabase
#   Obtener en: https://supabase.com/dashboard/org (URL slug o ID)
#
# TF_VAR_supabase_dev_db_password  → Password para la DB de dev
# TF_VAR_supabase_prod_db_password → Password para la DB de prod
# ============================================================

variable "supabase_access_token" {
  description = <<-EOT
    Supabase Personal Access Token (PAT) para la Management API.
    Obtener en: https://supabase.com/dashboard/account/tokens
    
    IMPORTANTE: Este NO es la service_role_key del proyecto.
    Es un token personal de cuenta que permite crear/gestionar proyectos.
    Guardarlo como secret en GitHub Actions: SUPABASE_ACCESS_TOKEN
  EOT
  type        = string
  sensitive   = true
}

variable "supabase_org_id" {
  description = <<-EOT
    ID de la organización en Supabase.
    Obtener en: https://supabase.com/dashboard/org
    Es el slug de la URL (ej: "abcdefghijklmnop")
  EOT
  type        = string
}

variable "supabase_dev_db_password" {
  description = "Password para la base de datos del proyecto couplesapp-dev"
  type        = string
  sensitive   = true
}

variable "supabase_prod_db_password" {
  description = "Password para la base de datos del proyecto couplesapp-prod"
  type        = string
  sensitive   = true
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for couplesapp.nextasy.co. Stored as TF_VAR_ACM_CERTIFICATE_ARN in GitHub Actions secrets."
  type        = string
}

variable "nextasy_acm_certificate_arn" {
  description = "ARN of the ACM certificate for nextasy.co (*.nextasy.co + nextasy.co)"
  type        = string
  default     = "arn:aws:acm:us-east-1:092042970121:certificate/c5e8a312-39dd-4478-b592-d124ff61a38b"
}
