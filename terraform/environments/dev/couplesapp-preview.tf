# S3 + CloudFront for CouplesApp design preview (mockup)
# Used by the preview-deploy.yml CI workflow to publish design mockups per branch
# Workflow deploys to: s3://couplesapp-preview/branches/<branch-name>/

module "couplesapp_preview" {
  source      = "../../modules/s3-spa"
  bucket_name = "couplesapp-preview"
  environment = "dev"

  tags = {
    Project     = "couplesapp"
    Environment = "dev"
    Purpose     = "design-preview-mockups"
  }
}

output "couplesapp_preview_cloudfront_url" {
  value       = "https://${module.couplesapp_preview.cloudfront_domain_name}"
  description = "CloudFront URL for CouplesApp design preview"
}

output "couplesapp_preview_cloudfront_distribution_id" {
  value       = module.couplesapp_preview.cloudfront_distribution_id
  description = "CloudFront distribution ID for CouplesApp design preview"
}
