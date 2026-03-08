# =============================================================================
# Email DNS Records for nextasy.co
# =============================================================================
# Provider: ImprovMX (https://improvmx.com) — Free email forwarding
# 
# How it works:
# - Emails sent to *@nextasy.co are forwarded to m4rkuz@gmail.com
# - ImprovMX handles the forwarding via their MX servers
# - SPF record authorizes ImprovMX to send on behalf of nextasy.co
#
# ImprovMX account: registered under m4rkuz@gmail.com
# Created: 2026-03-07
# =============================================================================

# MX records: Route incoming email through ImprovMX
resource "aws_route53_record" "nextasy_email_mx" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "nextasy.co"
  type    = "MX"
  ttl     = 300

  records = [
    "10 mx1.improvmx.com",
    "20 mx2.improvmx.com",
  ]
}

# SPF record: Authorize ImprovMX to send emails for nextasy.co
# This prevents emails forwarded by ImprovMX from being marked as spam
resource "aws_route53_record" "nextasy_email_spf" {
  zone_id = data.aws_route53_zone.nextasy_co.zone_id
  name    = "nextasy.co"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:spf.improvmx.com ~all",
  ]
}
