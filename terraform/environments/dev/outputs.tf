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

output "nextasy_website_url" {
  value = module.nextasy_website.website_url
}

output "nextasy_website_bucket_name" {
  value = module.nextasy_website.bucket_name
}

output "nextasy_cloudfront_url" {
  value = module.nextasy_website.cloudfront_url
}

output "nextasy_cloudfront_domain" {
  value = module.nextasy_website.cloudfront_domain_name
}

output "nextasy_cloudfront_distribution_id" {
  value = module.nextasy_website.cloudfront_distribution_id
}
