terraform {
  backend "s3" {
    bucket  = "nextasy-terraform-state-prod"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    profile = "prod"
    encrypt = true
  }
}
