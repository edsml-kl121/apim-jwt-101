#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Usage:  bash token.sh
#
# Reads credentials from .env (copy .env.example → .env and fill in values).
# Any variable already set in the environment takes precedence over .env.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ -f "${ENV_FILE}" ]]; then
  # Load only KEY=VALUE lines; skip comments and blank lines.
  set -o allexport
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
  set +o allexport
else
  echo "WARNING: .env file not found at ${ENV_FILE}." >&2
  echo "         Copy .env.example to .env and fill in your values." >&2
fi

: "${TENANT_ID:?ERROR: TENANT_ID is not set. Check your .env file.}"
: "${CLIENT_ID:?ERROR: CLIENT_ID is not set. Check your .env file.}"
: "${CLIENT_SECRET:?ERROR: CLIENT_SECRET is not set. Check your .env file.}"

# IMPORTANT: API_SCOPE must target YOUR API, not Microsoft Graph.
# Default: api://<CLIENT_ID>/.default (override in .env if the API app
# registration differs from the client app registration).
API_SCOPE="${API_SCOPE:-api://${CLIENT_ID}/.default}"

curl -X POST "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=${CLIENT_ID}" \
  --data-urlencode "client_secret=${CLIENT_SECRET}" \
  -d "scope=${API_SCOPE}"