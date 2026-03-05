variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "custom_domain" {
  description = "Primary custom domain for CloudFront (e.g. nextasy.co). Leave empty to use default CloudFront domain."
  type        = string
  default     = ""
}

variable "additional_domains" {
  description = "Additional custom domains for CloudFront (e.g. ['www.nextasy.co']). Requires custom_domain to be set."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1) for the custom domain. Required if custom_domain is set."
  type        = string
  default     = ""
}
