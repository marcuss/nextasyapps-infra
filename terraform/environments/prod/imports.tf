# =============================================================================
# Terraform Import Blocks
# =============================================================================
# These resources were created via AWS CLI before Terraform management.
# Run `terraform plan` to verify state matches, then `terraform apply` to import.
# =============================================================================

import {
  to = aws_route53_zone.lovecompass_co
  id = "Z0581410V8FQJTMVTXVI"
}

import {
  to = aws_cloudfront_distribution.lovecompass_prod
  id = "E46OWDOILJWFC"
}

import {
  to = aws_route53_record.lovecompass_a
  id = "Z0581410V8FQJTMVTXVI_lovecompass.co_A"
}

import {
  to = aws_route53_record.lovecompass_www_a
  id = "Z0581410V8FQJTMVTXVI_www.lovecompass.co_A"
}

import {
  to = aws_route53_record.lovecompass_mx
  id = "Z0581410V8FQJTMVTXVI_lovecompass.co_MX"
}

import {
  to = aws_route53_record.lovecompass_spf
  id = "Z0581410V8FQJTMVTXVI_lovecompass.co_TXT"
}

import {
  to = aws_route53_record.lovecompass_acm_validation
  id = "Z0581410V8FQJTMVTXVI__3861ee920a7163a02bf3e5896c441e16.lovecompass.co_CNAME"
}

import {
  to = aws_s3_bucket.lovecompass_prod_frontend
  id = "lovecompass-prod-frontend"
}

import {
  to = aws_s3_bucket_website_configuration.lovecompass_prod_frontend
  id = "lovecompass-prod-frontend"
}
