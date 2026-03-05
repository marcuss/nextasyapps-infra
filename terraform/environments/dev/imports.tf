# Import existing AWS resources created before Terraform management

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
