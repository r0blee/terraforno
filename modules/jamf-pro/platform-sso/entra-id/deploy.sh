#!/bin/bash
# ─────────────────────────────────────────
# ── Module Info ─────────────────────────────
# APIs:   Jamf Pro API
# Auth:   auth_jamf_pro (basic or OAuth2)
# ─────────────────────────────────────────────

#  Platform SSO — Entra ID — deploy.sh
#  Provider: Jamf Pro + Microsoft AzureAD
#            Terraform Providers
# ─────────────────────────────────────────

MODULE="jamf-pro/platform-sso/entra-id"
WORK_DIR="/tmp/terraforno/platform-sso-entra-id"

RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
CYN='\033[0;36m'
RST='\033[0m'
BLD='\033[1m'

source "$TERRAFORNO_DIR/lib/auth.sh"
source "$TERRAFORNO_DIR/lib/mode.sh"

echo ""
echo -e "${BLD}  ── Platform SSO — Entra ID ──${RST}"
echo ""

# ── Variables ────────────────────────────

# Jamf Pro credentials
# ── Deployment mode ─────────────────────────
select_deploy_mode

if [ "$DEPLOY_MODE" = "export" ]; then
    export_terraform_config "$MODULE" "$GITHUB_REPO"
    exit 0
fi

# ── Authentication ───────────────────────────
auth_jamf_pro

# Entra ID credentials (managed per-module — not in auth lib)
echo -e "${CYN}  Microsoft Entra ID${RST}"
echo ""
read -rp "  Entra Tenant ID: "       TF_VAR_entra_tenant_id
read -rp "  Entra Client ID: "       TF_VAR_entra_client_id
read -rsp "  Entra Client Secret: "  TF_VAR_entra_client_secret
echo ""
export TF_VAR_entra_tenant_id TF_VAR_entra_client_id TF_VAR_entra_client_secret

# TODO: add any additional Entra ID-specific variables here

# ── Pull config from GitHub ───────────────
echo ""
echo -e "${YEL}  Pulling latest config from GitHub...${RST}"
rm -rf "$WORK_DIR"
git clone --depth=1 --branch main "$GITHUB_REPO" "$WORK_DIR" 2>&1 | sed 's/^/  /'

if [ ! -d "$WORK_DIR/modules/$MODULE" ]; then
    echo -e "${RED}  Error: module '$MODULE' not found in repo.${RST}"
    auth_cleanup
    unset TF_VAR_entra_tenant_id TF_VAR_entra_client_id TF_VAR_entra_client_secret
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
    echo -e "${GRN}  ✔ Platform SSO — Entra ID deployed successfully.${RST}"
else
    echo -e "${YEL}  Aborted — no changes applied.${RST}"
fi

# ── Clean up ─────────────────────────────
auth_cleanup
rm -rf "$WORK_DIR"
unset TF_VAR_entra_tenant_id TF_VAR_entra_client_id TF_VAR_entra_client_secret
echo ""
