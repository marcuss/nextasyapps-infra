terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }

  backend "s3" {
    bucket = "nextasyapps-terraform-state-dev"
    key    = "couplesapp/frontend/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev"
}
