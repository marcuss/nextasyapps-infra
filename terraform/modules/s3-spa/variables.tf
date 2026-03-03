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
