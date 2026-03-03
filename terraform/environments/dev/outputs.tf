output "couplesapp_frontend_url" {
  value = "http://${module.couplesapp_frontend.website_endpoint}"
}

output "couplesapp_bucket_name" {
  value = module.couplesapp_frontend.bucket_name
}
