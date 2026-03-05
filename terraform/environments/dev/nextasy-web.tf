module "nextasy_website" {
  source = "../../modules/s3-spa"

  bucket_name = "nextasy-co-website"
  environment = "dev"

  # Custom domain + SSL configuration
  # ACM cert arn:aws:acm:us-east-1:092042970121:certificate/c5e8a312-39dd-4478-b592-d124ff61a38b
  # covers nextasy.co and *.nextasy.co
  custom_domain       = "nextasy.co"
  additional_domains  = ["www.nextasy.co"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:092042970121:certificate/c5e8a312-39dd-4478-b592-d124ff61a38b"

  tags = {
    App  = "nextasy-web"
    Team = "nextasy"
  }
}
