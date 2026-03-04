# Backend configuration para estado de Terraform
# Opciones:
# 1. Local (desarrollo): por defecto, sin configuración adicional
# 2. Remoto (recomendado para CI/CD): descomentar la sección terraform cloud
#    o usar S3/GCS backend

# terraform {
#   cloud {
#     organization = "nextasyapps"
#     workspaces {
#       name = "couplesapp-supabase"
#     }
#   }
# }

# Para CI/CD con GitHub Actions, configurar backend remoto o usar:
# terraform init -backend-config="..."
