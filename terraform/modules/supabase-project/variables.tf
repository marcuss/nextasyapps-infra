variable "organization_id" {
  description = "Supabase organization ID"
  type        = string
}

variable "project_name" {
  description = "Name of the Supabase project"
  type        = string
}

variable "database_password" {
  description = "Database password for the Supabase project"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region for the Supabase project"
  type        = string
  default     = "us-east-1"
}
