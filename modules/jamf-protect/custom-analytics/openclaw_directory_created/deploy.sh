#!/bin/bash
# ─────────────────────────────────────────
# ── Module Info ─────────────────────────────
# APIs:   Jamf Protect API
# Auth:   auth_jamf_protect_oauth2
# ─────────────────────────────────────────────

#  Custom Analytics — deploy.sh
#  Provider: Jamf Protect Terraform Provider
# ─────────────────────────────────────────

GITHUB_REPO="https://github.com/r0blee/terraforno.git"
MODULE="jamf-protect/custom-analytics"
WORK_DIR="/tmp/terraforno/jamf-protect/custom-analytics"

RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
CYN='\033[0;36m'
RST='\033[0m'
BLD='\033[1m'

source "$TERRAFORNO_DIR/lib/auth.sh"
source "$TERRAFORNO_DIR/lib/mode.sh"

echo ""
echo -e "${BLD}  ── Custom Analytics ──${RST}"
echo ""

# ── Variables ────────────────────────────
# ── Deployment mode ─────────────────────────
select_deploy_mode

if [ "$DEPLOY_MODE" = "export" ]; then
    export_terraform_config "$MODULE" "$GITHUB_REPO"
    exit 0
fi

# ── Authentication ───────────────────────────
auth_jamf_protect_oauth2

# TODO: add any jamf-protect/custom-analytics-specific variables here

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

# ── Verify Terraform configuration exists ────────────────────────
if [ -z "$(find . -maxdepth 1 -name '*.tf' 2>/dev/null)" ]; then
    echo -e "${RED}  Error: no Terraform configuration files found for this module.${RST}"
    echo -e "${YEL}  The module may not have its .tf files added to the repository yet.${RST}"
    auth_cleanup
    rm -rf "$WORK_DIR"
    exit 1
fi

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
    echo -e "${GRN}  ✔ Custom Analytics deployed successfully.${RST}"
else
    echo -e "${YEL}  Aborted — no changes applied.${RST}"
fi

# ── Clean up ─────────────────────────────
auth_cleanup
rm -rf "$WORK_DIR"
echo ""
