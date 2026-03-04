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
