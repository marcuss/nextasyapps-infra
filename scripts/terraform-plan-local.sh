#!/usr/bin/env bash
# =============================================================================
# terraform-plan-local.sh
# =============================================================================
# Run terraform plan locally using secrets from Infisical.
# No secrets stored on disk — fetched at runtime and discarded.
#
# Prerequisites:
#   - infisical CLI installed (brew install infisical/infisical-cli/infisical)
#   - infisical login (run once)
#   - terraform CLI installed
#
# Usage:
#   ./scripts/terraform-plan-local.sh dev     # Plan for dev environment
#   ./scripts/terraform-plan-local.sh prod    # Plan for prod environment
#   ./scripts/terraform-plan-local.sh dev apply  # Apply (use with caution!)
#
# How it works:
#   1. Authenticates with Infisical using machine identity
#   2. Fetches AWS credentials + Supabase tokens for the target environment
#   3. Runs terraform init + plan (or apply) with those credentials as env vars
#   4. Credentials are never written to disk
# =============================================================================

set -euo pipefail

# --- Config ---
INFISICAL_PROJECT_ID="22ac1270-6b3d-409b-abb1-ea88f8517c9b"
INFISICAL_CLIENT_ID="d5755792-c38d-4590-85c2-55e49840a0e1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Args ---
ENV="${1:-}"
ACTION="${2:-plan}"

if [[ -z "$ENV" ]] || [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Usage: $0 <dev|prod> [plan|apply]"
  echo ""
  echo "Examples:"
  echo "  $0 dev          # terraform plan for dev"
  echo "  $0 prod         # terraform plan for prod"
  echo "  $0 dev apply    # terraform apply for dev (careful!)"
  exit 1
fi

WORKDIR="$REPO_ROOT/terraform/environments/$ENV"

if [[ ! -d "$WORKDIR" ]]; then
  echo "❌ Directory not found: $WORKDIR"
  exit 1
fi

# --- Authenticate with Infisical ---
echo "🔐 Authenticating with Infisical..."

# Check if INFISICAL_CLIENT_SECRET is set, otherwise prompt
if [[ -z "${INFISICAL_CLIENT_SECRET:-}" ]]; then
  echo "  ℹ️  Set INFISICAL_CLIENT_SECRET env var or enter it now:"
  read -s -p "  Client Secret: " INFISICAL_CLIENT_SECRET
  echo ""
fi

INFISICAL_TOKEN=$(curl -s --request POST \
  --url https://app.infisical.com/api/v1/auth/universal-auth/login \
  --header 'Content-Type: application/json' \
  --data "{
    \"clientId\": \"$INFISICAL_CLIENT_ID\",
    \"clientSecret\": \"$INFISICAL_CLIENT_SECRET\"
  }" | python3 -c "import json,sys; print(json.load(sys.stdin).get('accessToken',''))" 2>/dev/null)

if [[ -z "$INFISICAL_TOKEN" ]]; then
  echo "❌ Failed to authenticate with Infisical"
  exit 1
fi
echo "  ✅ Authenticated"

# --- Fetch secrets ---
echo "📦 Fetching secrets for environment: $ENV"

get_secret() {
  local name="$1"
  infisical secrets get "$name" \
    --env "$ENV" \
    --token "$INFISICAL_TOKEN" \
    --projectId "$INFISICAL_PROJECT_ID" \
    --plain 2>/dev/null
}

if [[ "$ENV" == "dev" ]]; then
  # Dev uses the terraform-admin keys stored as TF_AWS_* in Infisical
  # Falls back to AWS_ACCESS_KEY_ID if TF_* doesn't exist
  export AWS_ACCESS_KEY_ID=$(get_secret "TF_AWS_ACCESS_KEY_ID" 2>/dev/null || get_secret "AWS_ACCESS_KEY_ID")
  export AWS_SECRET_ACCESS_KEY=$(get_secret "TF_AWS_SECRET_ACCESS_KEY" 2>/dev/null || get_secret "AWS_SECRET_ACCESS_KEY")
  
  # Supabase vars (required for dev which manages Supabase resources)
  export TF_VAR_supabase_access_token=$(get_secret "SUPABASE_PAT")
  export TF_VAR_supabase_org_id=$(get_secret "SUPABASE_ORG_ID" 2>/dev/null || echo "")
  export TF_VAR_supabase_dev_db_password=$(get_secret "SUPABASE_DEV_DB_PASSWORD" 2>/dev/null || echo "dummy-for-plan")
  export TF_VAR_supabase_prod_db_password=$(get_secret "SUPABASE_PROD_DB_PASSWORD" 2>/dev/null || echo "dummy-for-plan")
  export TF_VAR_acm_certificate_arn=$(get_secret "ACM_CERTIFICATE_ARN" 2>/dev/null || echo "arn:aws:acm:us-east-1:092042970121:certificate/b2571d4a-52b4-4986-a8b5-aa8fc68a5e8f")
  
elif [[ "$ENV" == "prod" ]]; then
  # Prod uses PROD_AWS_* keys
  export AWS_ACCESS_KEY_ID=$(get_secret "PROD_AWS_ACCESS_KEY_ID" 2>/dev/null || get_secret "AWS_ACCESS_KEY_ID")
  export AWS_SECRET_ACCESS_KEY=$(get_secret "PROD_AWS_SECRET_ACCESS_KEY" 2>/dev/null || get_secret "AWS_SECRET_ACCESS_KEY")
fi

export AWS_DEFAULT_REGION="us-east-1"

echo "  ✅ Secrets loaded (key: ${AWS_ACCESS_KEY_ID:0:10}...)"

# --- Run Terraform ---
cd "$WORKDIR"

echo ""
echo "🏗️  Running terraform init..."
terraform init -input=false -no-color 2>&1 | tail -3

echo ""
echo "🔍 Running terraform $ACTION..."
echo "   Working dir: $WORKDIR"
echo "   Environment: $ENV"
echo "   AWS Account: $(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo 'unknown')"
echo ""

if [[ "$ACTION" == "apply" ]]; then
  echo "⚠️  You are about to APPLY changes to $ENV!"
  read -p "   Are you sure? (yes/no): " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "Cancelled."
    exit 0
  fi
  terraform apply -auto-approve -no-color
else
  terraform plan -no-color
fi

echo ""
echo "✅ Done!"
