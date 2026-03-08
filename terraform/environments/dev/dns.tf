# =============================================================================
# DNS Records for nextasy.co (Route 53)
# =============================================================================

# A record: nextasy.co → CloudFront (nextasy website)
resource "aws_route53_record" "nextasy_a" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "nextasy.co"
  type    = "A"

  alias {
    name                   = module.nextasy_website.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID (constant)
    evaluate_target_health = false
  }
}

# CNAME: www.nextasy.co → CloudFront
resource "aws_route53_record" "nextasy_www" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "www.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = [module.nextasy_website.cloudfront_domain_name]
}

# CNAME: *.nextasy.co → CloudFront (wildcard for v1-bento, v2-cinematic, etc.)
resource "aws_route53_record" "nextasy_wildcard" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "*.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = [module.nextasy_website.cloudfront_domain_name]
}

# --- Email Records (ImprovMX) -----------------------------------------------

# MX record for ImprovMX email forwarding
resource "aws_route53_record" "nextasy_mx" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "nextasy.co"
  type    = "MX"
  ttl     = 300
  records = [
    "10 mx1.improvmx.com",
    "20 mx2.improvmx.com",
  ]
}

# SPF record for ImprovMX
resource "aws_route53_record" "nextasy_spf" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "nextasy.co"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:spf.improvmx.com ~all",
  ]
}

# --- ACM Validation Records -------------------------------------------------

# ACM validation for nextasy.co certificate (c5e8a312)
resource "aws_route53_record" "nextasy_acm_validation" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "_63582f4f4a2bc63356c4959dfdc43ab8.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["_d6a942b9ec289905780229d923dad573.jkddzztszm.acm-validations.aws."]
}

# ACM validation for nextasy.co certificate (c5e8a312) - second record
resource "aws_route53_record" "nextasy_acm_validation_2" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "_9b7f11c0d5d84e3d679756c7c7cbb5c5.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["_43b54d653435e43cdfd05fe6f1b9fb68.jkddzztszm.acm-validations.aws."]
}

# ACM validation for couplesapp.nextasy.co certificate (b2571d4a)
resource "aws_route53_record" "couplesapp_acm_validation" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "_89adb090911b65a85273dfe66c4d4660.couplesapp.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["_3bfcb9324c1ffab3b9adbdf36e147e58.jkddzztszm.acm-validations.aws."]
}

# ACM validation for couplesapp.nextasy.co certificate (b2571d4a) - second record
resource "aws_route53_record" "couplesapp_acm_validation_2" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "_8cd76922c7b1dbafa6ed3b98a95290fb.couplesapp.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["_e324328d22a0ff095b39984f0b10bde3.jkddzztszm.acm-validations.aws."]
}

# --- SES DKIM Records -------------------------------------------------------

resource "aws_route53_record" "nextasy_dkim_1" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "47vclci3cjh2jyk5som24oy6lne2uqky._domainkey.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["47vclci3cjh2jyk5som24oy6lne2uqky.dkim.amazonses.com"]
}

resource "aws_route53_record" "nextasy_dkim_2" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "fhnsybbkti53ymaqwmtri4jnkttty62i._domainkey.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["fhnsybbkti53ymaqwmtri4jnkttty62i.dkim.amazonses.com"]
}

resource "aws_route53_record" "nextasy_dkim_3" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "goytbyuv7m6o3xwmeh4auz3i3lf3lqwe._domainkey.nextasy.co"
  type    = "CNAME"
  ttl     = 300
  records = ["goytbyuv7m6o3xwmeh4auz3i3lf3lqwe.dkim.amazonses.com"]
}
