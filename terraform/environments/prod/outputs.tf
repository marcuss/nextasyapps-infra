output "lovecompass_cloudfront_domain" {
  description = "CloudFront domain for lovecompass.co"
  value       = aws_cloudfront_distribution.lovecompass_prod.domain_name
}

output "lovecompass_cloudfront_id" {
  description = "CloudFront distribution ID for lovecompass.co"
  value       = aws_cloudfront_distribution.lovecompass_prod.id
}

output "lovecompass_route53_zone_id" {
  description = "Route 53 hosted zone ID for lovecompass.co"
  value       = aws_route53_zone.lovecompass_co.zone_id
}

output "lovecompass_nameservers" {
  description = "Route 53 nameservers for lovecompass.co (set in GoDaddy)"
  value       = aws_route53_zone.lovecompass_co.name_servers
}
