terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.4"
    }
  }
}

resource "supabase_project" "this" {
  organization_id   = var.organization_id
  name              = var.project_name
  database_password = var.database_password
  region            = var.region
}

resource "supabase_settings" "auth" {
  project_ref = supabase_project.this.id

  auth = jsonencode({
    disable_signup     = var.disable_signup
    mailer_autoconfirm = var.mailer_autoconfirm
  })
}
