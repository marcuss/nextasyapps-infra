# =============================================================================
# SES SMTP IAM User — Dev
# =============================================================================
# Creates a dedicated IAM user for Supabase to send transactional emails
# via AWS SES SMTP. Credentials are output and must be stored in Infisical
# (SUPABASE_SMTP_USER / SUPABASE_SMTP_PASS) after apply.
#
# SMTP config for Supabase dev project:
#   host:   email-smtp.us-east-1.amazonaws.com
#   port:   587
#   user:   <ses_smtp_user output>
#   pass:   <ses_smtp_password output>  ← ses_smtp_password_v4 (NOT the secret key)
#   from:   couplesapp-noreply@nextasy.co
# =============================================================================

resource "aws_iam_user" "ses_smtp_dev" {
  name = "couplesapp-ses-smtp-dev"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Purpose     = "supabase-smtp"
  }
}

resource "aws_iam_user_policy" "ses_smtp_dev_send" {
  name = "ses-send-raw-email"
  user = aws_iam_user.ses_smtp_dev.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ses:SendRawEmail"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "ses_smtp_dev" {
  user = aws_iam_user.ses_smtp_dev.name
}

# SES Domain Identity for nextasy.co (shared between dev and prod)
resource "aws_ses_domain_identity" "nextasy_co" {
  domain = "nextasy.co"
}

# DKIM records for SES (add to Route53 after apply)
resource "aws_ses_domain_dkim" "nextasy_co" {
  domain = aws_ses_domain_identity.nextasy_co.domain
}

resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "${aws_ses_domain_dkim.nextasy_co.dkim_tokens[count.index]}._domainkey.nextasy.co"
  type    = "CNAME"
  ttl     = 1800
  records = ["${aws_ses_domain_dkim.nextasy_co.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# NOTE: SPF record for nextasy.co is defined in email-dns.tf (nextasy_email_spf).
# Update that record to also include amazonses.com:
#   "v=spf1 include:spf.improvmx.com include:amazonses.com ~all"

# MAIL FROM domain (improves deliverability)
resource "aws_ses_domain_mail_from" "nextasy_co" {
  domain           = aws_ses_domain_identity.nextasy_co.domain
  mail_from_domain = "mail.nextasy.co"
}

resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "mail.nextasy.co"
  type    = "MX"
  ttl     = 300
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "mail.nextasy.co"
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

# =============================================================================
# Outputs — store these in Infisical after apply
# =============================================================================
output "ses_smtp_user_dev" {
  description = "SMTP username for Supabase dev (= IAM Access Key ID)"
  value       = aws_iam_access_key.ses_smtp_dev.id
}

output "ses_smtp_password_dev" {
  description = "SMTP password for Supabase dev (derived from secret key, SigV4)"
  value       = aws_iam_access_key.ses_smtp_dev.ses_smtp_password_v4
  sensitive   = true
}
