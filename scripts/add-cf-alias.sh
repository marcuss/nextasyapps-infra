#!/usr/bin/env bash
# Usage: ./add-cf-alias.sh <slug>
# Adds {slug}.nextasy.co as a CloudFront alias so HTTPS works on the subdomain.
# Also creates/updates the Route 53 CNAME.

set -euo pipefail

SLUG="${1:-}"
if [ -z "$SLUG" ]; then
  echo "Usage: $0 <slug>  (e.g. dark-mode)"
  exit 1
fi

CF_ID="E640UP3DK37WP"
ZONE_ID="Z02633611RLKX976F44TP"
CF_DOMAIN="d3heh2lnt32ajw.cloudfront.net"
SUBDOMAIN="${SLUG}.nextasy.co"
AWS_PROFILE="${AWS_PROFILE:-dev}"

echo "Adding alias: $SUBDOMAIN -> CloudFront $CF_ID"

# 1. Get current config
TMPDIR=$(mktemp -d)
AWS_PROFILE="$AWS_PROFILE" aws cloudfront get-distribution-config \
  --id "$CF_ID" --output json > "$TMPDIR/raw.json"

ETAG=$(python3 -c "import json; print(json.load(open('$TMPDIR/raw.json'))['ETag'])")

# 2. Add alias to config
python3 << PYEOF
import json
with open('$TMPDIR/raw.json') as f:
    raw = json.load(f)
config = raw['DistributionConfig']
aliases = config['Aliases'].get('Items', [])
if '$SUBDOMAIN' not in aliases:
    aliases.append('$SUBDOMAIN')
config['Aliases'] = {'Quantity': len(aliases), 'Items': aliases}
with open('$TMPDIR/updated.json', 'w') as f:
    json.dump(config, f)
print(f"Aliases now: {aliases}")
PYEOF

# 3. Update CF distribution
AWS_PROFILE="$AWS_PROFILE" aws cloudfront update-distribution \
  --id "$CF_ID" \
  --distribution-config "file://$TMPDIR/updated.json" \
  --if-match "$ETAG" \
  --query 'Distribution.Status' \
  --output text

# 4. Upsert Route 53 CNAME
AWS_PROFILE="$AWS_PROFILE" aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$SUBDOMAIN\",
        \"Type\": \"CNAME\",
        \"TTL\": 300,
        \"ResourceRecords\": [{\"Value\": \"$CF_DOMAIN\"}]
      }
    }]
  }" --query 'ChangeInfo.Status' --output text

echo "✅ Done: https://$SUBDOMAIN"
rm -rf "$TMPDIR"
