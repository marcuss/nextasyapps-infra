# =============================================================================
# Import blocks for resources that exist in AWS but not in Terraform state
# Created: 2026-03-10 — SES SMTP setup
# =============================================================================

# email-dns.tf resources (created outside Terraform)
import {
  to = aws_route53_record.nextasy_email_mx
  id = "Z02633611RLKX976F44TP_nextasy.co._MX"
}

import {
  to = aws_route53_record.nextasy_email_spf
  id = "Z02633611RLKX976F44TP_nextasy.co._TXT"
}

# ses-smtp.tf resources (SES domain already configured)
import {
  to = aws_ses_domain_identity.nextasy_co
  id = "nextasy.co"
}

import {
  to = aws_ses_domain_dkim.nextasy_co
  id = "nextasy.co"
}

import {
  to = aws_route53_record.ses_dkim[0]
  id = "Z02633611RLKX976F44TP_fhnsybbkti53ymaqwmtri4jnkttty62i._domainkey.nextasy.co._CNAME"
}

import {
  to = aws_route53_record.ses_dkim[1]
  id = "Z02633611RLKX976F44TP_47vclci3cjh2jyk5som24oy6lne2uqky._domainkey.nextasy.co._CNAME"
}

import {
  to = aws_route53_record.ses_dkim[2]
  id = "Z02633611RLKX976F44TP_goytbyuv7m6o3xwmeh4auz3i3lf3lqwe._domainkey.nextasy.co._CNAME"
}

import {
  to = aws_ses_domain_mail_from.nextasy_co
  id = "nextasy.co"
}

import {
  to = aws_route53_record.ses_mail_from_mx
  id = "Z02633611RLKX976F44TP_mail.nextasy.co._MX"
}

import {
  to = aws_route53_record.ses_mail_from_spf
  id = "Z02633611RLKX976F44TP_mail.nextasy.co._TXT"
}
