#!/usr/bin/env bash
# Grant a user execute access to AAP job template(s) via CLI.
# Standalone: includes AAP API config; does not source setup_env.sh.
# Pass-through: template name and username can be given as arguments or -e.
#
# Usage:
#   ./grant_template_execute_access.sh <template_name> <username>
#   ./grant_template_execute_access.sh -t <template_name> -u <username>
#   ./grant_template_execute_access.sh -t "vSphere-Nested-DEVQE-static" -u datucker
#
# Multiple templates (comma-separated):
#   ./grant_template_execute_access.sh -t "Template1,Template2" -u datucker
#
# If template is omitted on CLI, uses template_name_var or template_names_var
# (or env AAP_TEMPLATE_NAME / AAP_TEMPLATE_NAMES). Set them in the script or export before running.
#
# Run from repo root (spinupnestedviAAP) so playbooks/ and group_vars/ are found:
#   cd /path/to/spinupnestedviAAP && playbooks/grant_template_execute_access.sh -t "vSphere-Nested-DEVQE-static" -u datucker

# Edit the values below with your AAP instance details

# AAP Controller URL
export AAP_URL="https://aap.com"

# OAuth2 Token or Personal Access Token (PAT)
# Get this from AAP UI: User -> Tokens -> Create Token
export AAP_TOKEN=""

# Optional: SSL verification (true/false, default: true)
export AAP_VERIFY_SSL="true"


set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLAYBOOK="$SCRIPT_DIR/grant_template_execute_access.yml"

# --- AAP API configuration (edit for your instance; not sourced from setup_env.sh) ---
export AAP_URL="${AAP_URL:-https://aap.com}"
export AAP_TOKEN="${AAP_TOKEN:-}"   # OAuth2/PAT from AAP UI: User -> Tokens -> Create Token
export AAP_VERIFY_SSL="${AAP_VERIFY_SSL:-true}"
# Optional: use username/password instead of token
export AAP_USERNAME="${AAP_USERNAME:-}"
export AAP_PASSWORD="${AAP_PASSWORD:-}"

# Optional: default template(s) when not provided on CLI (env or set below)
#template_name_var="${AAP_TEMPLATE_NAME:-}"
#template_names_var="${AAP_TEMPLATE_NAMES:-}"  # comma-separated; or set a literal default below
# Literal defaults (used when env vars above are unset):
# template_name_var="vSphere-Nested-DEVQE-static"
template_names_var="vSphere-Nested-DEVQE,vSphere-Nested-DEVQE-static,vSphere-Nested-DEVQE-static-autoscript,vSphere-Nested-DEVQE-vSAN,vSphere-Nested-DEVQE-vSphere-9,vSphere-Nested-DEVQE-vSphere-9-static,vSphere-Nested-DEVQE-vSphere-9-static-autoscript,vSphere-Nested-DEVQE-vSAN-vsphere-9"

template_name=""
username=""

usage() {
  echo "Usage: $0 <template_name> <username>"
  echo "       $0 -t|--template <template_name> -u|--user <username>"
  echo "       $0 -t 'Template1,Template2' -u <username>"
  echo "       $0 -u <username>   (uses template_name_var or template_names_var if set)"
  echo ""
  echo "Grant execute access to an AAP job template for a user."
  echo "  -t, --template   Job template name (or comma-separated list); omit to use vars"
  echo "  -u, --user       AAP username to grant execute access"
  echo ""
  echo "If -t/--template is omitted, uses template_name_var or template_names_var"
  echo "(or env AAP_TEMPLATE_NAME / AAP_TEMPLATE_NAMES)."
  echo ""
  echo "Example: $0 -t vSphere-Nested-DEVQE-static -u datucker"
  exit 1
}

# Parse optional flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--template)
      template_name="$2"
      shift 2
      ;;
    -u|--user)
      username="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      # Positional: first = template, second = username
      if [[ -z "$template_name" ]]; then
        template_name="$1"
      elif [[ -z "$username" ]]; then
        username="$1"
      else
        echo "Extra argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

# If template not provided on CLI, use template_name or template_names var
if [[ -z "$template_name" ]]; then
  if [[ -n "${template_name_var:-}" ]]; then
    template_name="$template_name_var"
  elif [[ -n "${template_names_var:-}" ]]; then
    template_name="$template_names_var"
  fi
fi

if [[ -z "$template_name" ]] || [[ -z "$username" ]]; then
  echo "Error: template name and username are required (provide on CLI or set template_name_var/template_names_var or AAP_TEMPLATE_NAME/AAP_TEMPLATE_NAMES)." >&2
  usage
fi

cd "$REPO_ROOT"

# If template_name contains a comma, pass as template_names
if [[ "$template_name" == *","* ]]; then
  exec ansible-playbook "$PLAYBOOK" \
    -e "template_names=$template_name" \
    -e "username=$username" \
    "$@"
else
  exec ansible-playbook "$PLAYBOOK" \
    -e "template_name=$template_name" \
    -e "username=$username" \
    "$@"
fi
