#!/bin/bash
# ─────────────────────────────────────────
# ── Module Info ─────────────────────────────
# APIs:   Jamf Pro API
# Auth:   auth_jamf_pro (basic or OAuth2)
# ─────────────────────────────────────────────

#  Configure Jamf Connect Login — deploy.sh
#  Provider: Jamf Connect Terraform Provider
# ─────────────────────────────────────────

MODULE="jamf-connect/connect-login"
WORK_DIR="/tmp/terraforno/jamf-connect/connect-login"

RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
CYN='\033[0;36m'
RST='\033[0m'
BLD='\033[1m'

source "$TERRAFORNO_DIR/lib/auth.sh"
source "$TERRAFORNO_DIR/lib/mode.sh"

echo ""
echo -e "${BLD}  ── Configure Jamf Connect Login ──${RST}"
echo ""

# ── Variables ────────────────────────────
# ── Deployment mode ─────────────────────────
select_deploy_mode

if [ "$DEPLOY_MODE" = "export" ]; then
    export_terraform_config "$MODULE" "$GITHUB_REPO"
    exit 0
fi

# ── Authentication ───────────────────────────
auth_jamf_pro

# TODO: add any jamf-connect/connect-login-specific variables here

# ── Pull config from GitHub ───────────────
echo ""
echo -e "${YEL}  Pulling latest config from GitHub...${RST}"
rm -rf "$WORK_DIR"
git clone --depth=1 --branch main "$GITHUB_REPO" "$WORK_DIR" 2>&1 | sed 's/^/  /'

if [ ! -d "$WORK_DIR/modules/$MODULE" ]; then
    echo -e "${RED}  Error: module '$MODULE' not found in repo.${RST}"
    auth_cleanup
    exit 1
fi

cd "$WORK_DIR/modules/$MODULE" || { auth_cleanup; exit 1; }

# ── Terraform ────────────────────────────
echo ""
echo -e "${YEL}  Initialising Terraform...${RST}"
terraform init -input=false 2>&1 | sed 's/^/  /'

echo ""
echo -e "${YEL}  Planning...${RST}"
terraform plan -out=tfplan 2>&1 | sed 's/^/  /'

echo ""
read -rp "  Apply this plan? (yes/no): " confirm
if [ "$confirm" = "yes" ]; then
    terraform apply tfplan 2>&1 | sed 's/^/  /'
    echo ""
    echo -e "${GRN}  ✔ Configure Jamf Connect Login deployed successfully.${RST}"
else
    echo -e "${YEL}  Aborted — no changes applied.${RST}"
fi

# ── Clean up ─────────────────────────────
auth_cleanup
rm -rf "$WORK_DIR"
echo ""
