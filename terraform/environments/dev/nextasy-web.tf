module "nextasy_website" {
  source = "../../modules/s3-spa"

  bucket_name = "nextasy-co-website"
  environment = "dev"

  # Custom domain + SSL configuration
  # covers nextasy.co and *.nextasy.co
  custom_domain       = "nextasy.co"
  additional_domains  = ["www.nextasy.co"]
  acm_certificate_arn = var.acm_certificate_arn

  tags = {
    App  = "nextasy-web"
    Team = "nextasy"
  }
}
