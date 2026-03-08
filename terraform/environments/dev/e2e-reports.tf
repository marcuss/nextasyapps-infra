# S3 bucket for E2E test reports — public read, no CloudFront needed
resource "aws_s3_bucket" "e2e_reports" {
  bucket = "couplesapp-e2e-reports"
  tags = {
    Project     = "couplesapp"
    Environment = "dev"
    Purpose     = "e2e-test-reports"
  }
}

resource "aws_s3_bucket_public_access_block" "e2e_reports" {
  bucket                  = aws_s3_bucket.e2e_reports.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "e2e_reports" {
  bucket = aws_s3_bucket.e2e_reports.id
  index_document { suffix = "index.html" }
  error_document { key    = "index.html" }
}

resource "aws_s3_bucket_policy" "e2e_reports_public_read" {
  bucket     = aws_s3_bucket.e2e_reports.id
  depends_on = [aws_s3_bucket_public_access_block.e2e_reports]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.e2e_reports.arn}/*"
    }]
  })
}

output "e2e_reports_website_url" {
  value       = aws_s3_bucket_website_configuration.e2e_reports.website_endpoint
  description = "S3 static website URL for E2E reports"
}

# CloudFront for E2E reports (managed outside s3-spa module since it's just a report bucket)
resource "aws_cloudfront_distribution" "e2e_reports" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "CouplesApp E2E and Reports bucket"

  origin {
    domain_name = aws_s3_bucket_website_configuration.e2e_reports.website_endpoint
    origin_id   = "S3-Website-e2e-reports"

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
    target_origin_id       = "S3-Website-e2e-reports"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    App  = "couplesapp"
    Team = "nextasy"
  }
}
