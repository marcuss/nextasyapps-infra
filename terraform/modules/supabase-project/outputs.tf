output "project_ref" {
  description = "Supabase project reference ID"
  value       = supabase_project.this.id
}

output "api_url" {
  description = "Supabase project API URL"
  value       = "https://${supabase_project.this.id}.supabase.co"
}

output "anon_key" {
  description = "Supabase project anonymous key"
  value       = supabase_project.this.anon_key
}

output "service_role_key" {
  description = "Supabase project service role key"
  value       = supabase_project.this.service_role_key
  sensitive   = true
}
