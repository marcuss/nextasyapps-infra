output "project_ref" {
  description = "Supabase project reference ID"
  value       = supabase_project.this.id
}

output "api_url" {
  description = "Supabase project API URL"
  value       = "https://${supabase_project.this.id}.supabase.co"
}
