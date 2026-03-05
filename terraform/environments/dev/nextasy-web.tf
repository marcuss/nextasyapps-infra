module "nextasy_website" {
  source = "../../modules/s3-spa"

  bucket_name = "nextasy-co-website"
  environment = "dev"

  # Custom domain + SSL configuration
  # ACM cert ARN_REDACTED_USE_TF_VAR
  # covers nextasy.co and *.nextasy.co
  custom_domain       = "nextasy.co"
  additional_domains  = ["www.nextasy.co"]
  acm_certificate_arn = "ARN_REDACTED_USE_TF_VAR"

  tags = {
    App  = "nextasy-web"
    Team = "nextasy"
  }
}
