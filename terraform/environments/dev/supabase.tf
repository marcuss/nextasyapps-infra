provider "supabase" {
  access_token = var.supabase_access_token
}

module "supabase_dev" {
  source            = "../../modules/supabase-project"
  organization_id   = var.supabase_org_id
  project_name      = "couplesapp-dev"
  database_password = var.supabase_dev_db_password
  region            = "us-east-1"
  disable_signup    = false   # Allow new user registrations
}

module "supabase_prod" {
  source            = "../../modules/supabase-project"
  organization_id   = var.supabase_org_id
  project_name      = "couplesapp-prod"
  database_password = var.supabase_prod_db_password
  region            = "us-east-1"
  disable_signup    = true    # Prod: controlled signups only
}

output "dev_project_ref" {
  value = module.supabase_dev.project_ref
}

output "dev_api_url" {
  value = module.supabase_dev.api_url
}

output "prod_project_ref" {
  value = module.supabase_prod.project_ref
}

output "prod_api_url" {
  value = module.supabase_prod.api_url
}
