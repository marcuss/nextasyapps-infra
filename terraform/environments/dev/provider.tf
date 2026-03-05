terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.4"
    }
  }

  backend "s3" {
    bucket = "nextasyapps-terraform-state-dev"
    key    = "couplesapp/frontend/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  # Profile only for local dev — in CI uses AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env vars
  dynamic "assume_role" {
    for_each = []
    content {}
  }
}
