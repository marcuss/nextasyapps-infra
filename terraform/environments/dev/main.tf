module "couplesapp_frontend" {
  source = "../../modules/s3-spa"

  bucket_name         = "couplesapp-dev-frontend"
  environment         = "dev"
  custom_domain       = "couplesapp.nextasy.co"
  acm_certificate_arn = var.acm_certificate_arn

  tags = {
    App  = "couplesapp"
    Team = "nextasy"
  }
}

# Route 53 record: couplesapp.nextasy.co → CloudFront
data "aws_route53_zone" "nextasy_co" {
  zone_id = "Z02633611RLKX976F44TP"
}

resource "aws_route53_record" "couplesapp" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "couplesapp.nextasy.co"
  type    = "A"

  alias {
    name                   = module.couplesapp_frontend.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID (always this value)
    evaluate_target_health = false
  }
}
