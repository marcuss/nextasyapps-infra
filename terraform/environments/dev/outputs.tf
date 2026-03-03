output "couplesapp_frontend_url" {
  value = module.couplesapp_frontend.website_url
}

output "couplesapp_bucket_name" {
  value = module.couplesapp_frontend.bucket_name
}

output "couplesapp_cloudfront_url" {
  value = module.couplesapp_frontend.cloudfront_url
}

output "couplesapp_cloudfront_domain" {
  value = module.couplesapp_frontend.cloudfront_domain_name
}

output "couplesapp_cloudfront_distribution_id" {
  value = module.couplesapp_frontend.cloudfront_distribution_id
}
