output "couplesapp_frontend_url" {
  value = "http://${module.couplesapp_frontend.website_endpoint}"
}

output "couplesapp_bucket_name" {
  value = module.couplesapp_frontend.bucket_name
}

output "couplesapp_cloudfront_url" {
  value = module.couplesapp_frontend.cloudfront_url
}
