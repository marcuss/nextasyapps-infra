# =============================================================================
# LoveCompass Production Infrastructure
# =============================================================================
#
# Domain: lovecompass.co (registered at GoDaddy, NS delegated to Route 53)
# Frontend: S3 (lovecompass-prod-frontend) → CloudFront → lovecompass.co
# Email: ImprovMX forwarding
#
# The prod S3 bucket (lovecompass-prod-frontend) was created before Terraform
# and is imported. See imports.tf for import blocks.
# =============================================================================

# --- Route 53 Hosted Zone ---------------------------------------------------

resource "aws_route53_zone" "lovecompass_co" {
  name    = "lovecompass.co"
  comment = "LoveCompass production domain"

  tags = {
    App = "lovecompass"
  }
}

# --- ACM Certificate ---------------------------------------------------------
# Already issued: lovecompass.co + *.lovecompass.co
# Managed outside Terraform (requested via CLI), referenced by ARN.

# --- CloudFront Distribution -------------------------------------------------

resource "aws_cloudfront_distribution" "lovecompass_prod" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  http_version        = "http2and3"
  comment             = "LoveCompass Production - lovecompass.co"

  aliases = ["lovecompass.co", "www.lovecompass.co"]

  origin {
    domain_name = "lovecompass-prod-frontend.s3-website-us-east-1.amazonaws.com"
    origin_id   = "prod-s3"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "prod-s3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  viewer_certificate {
    acm_certificate_arn      = var.lovecompass_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    App = "lovecompass"
  }
}

# --- DNS Records -------------------------------------------------------------

# A record: lovecompass.co → CloudFront
resource "aws_route53_record" "lovecompass_a" {
  zone_id = aws_route53_zone.lovecompass_co.zone_id
  name    = "lovecompass.co"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.lovecompass_prod.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID (constant)
    evaluate_target_health = false
  }
}

# A record: www.lovecompass.co → CloudFront
resource "aws_route53_record" "lovecompass_www_a" {
  zone_id = aws_route53_zone.lovecompass_co.zone_id
  name    = "www.lovecompass.co"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.lovecompass_prod.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# MX records: ImprovMX email forwarding
resource "aws_route53_record" "lovecompass_mx" {
  zone_id = aws_route53_zone.lovecompass_co.zone_id
  name    = "lovecompass.co"
  type    = "MX"
  ttl     = 300

  records = [
    "10 mx1.improvmx.com",
    "20 mx2.improvmx.com",
  ]
}

# SPF record for ImprovMX
resource "aws_route53_record" "lovecompass_spf" {
  zone_id = aws_route53_zone.lovecompass_co.zone_id
  name    = "lovecompass.co"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:spf.improvmx.com ~all",
  ]
}

# ACM validation CNAME (already validated, kept for reference)
resource "aws_route53_record" "lovecompass_acm_validation" {
  zone_id = aws_route53_zone.lovecompass_co.zone_id
  name    = "_3861ee920a7163a02bf3e5896c441e16.lovecompass.co"
  type    = "CNAME"
  ttl     = 300

  records = [
    "_94c47caf3b7f7eeab786d85e210bdcca.jkddzztszm.acm-validations.aws.",
  ]
}

# --- S3 Bucket (prod frontend) -----------------------------------------------

resource "aws_s3_bucket" "lovecompass_prod_frontend" {
  bucket = "lovecompass-prod-frontend"

  tags = {
    App = "lovecompass"
  }
}

resource "aws_s3_bucket_public_access_block" "lovecompass_prod_frontend" {
  bucket = aws_s3_bucket.lovecompass_prod_frontend.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "lovecompass_prod_frontend" {
  bucket = aws_s3_bucket.lovecompass_prod_frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "lovecompass_prod_frontend" {
  bucket     = aws_s3_bucket.lovecompass_prod_frontend.id
  depends_on = [aws_s3_bucket_public_access_block.lovecompass_prod_frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.lovecompass_prod_frontend.arn}/*"
      }
    ]
  })
}
