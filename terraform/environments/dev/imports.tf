# Import existing AWS resources created before Terraform management

# CouplesApp CloudFront distribution (ID: ERLTLXEW7WTTN)
import {
  to = module.couplesapp_frontend.aws_cloudfront_distribution.this
  id = "ERLTLXEW7WTTN"
}

# CouplesApp S3 bucket (couplesapp-dev-frontend)
import {
  to = module.couplesapp_frontend.aws_s3_bucket.this
  id = "couplesapp-dev-frontend"
}

import {
  to = module.couplesapp_frontend.aws_s3_bucket_public_access_block.this
  id = "couplesapp-dev-frontend"
}

import {
  to = module.couplesapp_frontend.aws_s3_bucket_website_configuration.this
  id = "couplesapp-dev-frontend"
}

import {
  to = module.couplesapp_frontend.aws_s3_bucket_policy.this
  id = "couplesapp-dev-frontend"
}

# nextasy-co-website S3 bucket (created manually before Terraform)
import {
  to = module.nextasy_website.aws_s3_bucket.this
  id = "nextasy-co-website"
}

import {
  to = module.nextasy_website.aws_s3_bucket_public_access_block.this
  id = "nextasy-co-website"
}

import {
  to = module.nextasy_website.aws_s3_bucket_website_configuration.this
  id = "nextasy-co-website"
}

import {
  to = module.nextasy_website.aws_s3_bucket_policy.this
  id = "nextasy-co-website"
}

# Note: CORS was not configured on the existing bucket — Terraform will create it

# nextasy-co-website CloudFront distribution (ID: E640UP3DK37WP)
import {
  to = module.nextasy_website.aws_cloudfront_distribution.this
  id = "E640UP3DK37WP"
}

import {
  to = aws_cloudfront_distribution.e2e_reports
  id = "EYJ1QFLZNTBP"
}

import {
  to = aws_acm_certificate.couplesapp_nextasy
  id = "arn:aws:acm:us-east-1:092042970121:certificate/b2571d4a-52b4-4986-a8b5-aa8fc68a5e8f"
}
