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
MODULE="jamf-protect/custom-analytics/openclaw_directory_created"
WORK_DIR="/tmp/terraforno/$MODULE"

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
git clone --depth=1 --branch main \
    "$GITHUB_REPO" "$WORK_DIR" 2>&1 | sed 's/^/  /'

if [ ! -d "$WORK_DIR/modules/$MODULE" ]; then
    echo -e "${RED}  Error: module '$MODULE' not found in repo.${RST}"
    auth_cleanup
    exit 1
fi

cd "$WORK_DIR/modules/$MODULE" || { auth_cleanup; exit 1; }

_write_provider_tf "auth_jamf_protect_oauth2"


# ── Verify Terraform configuration exists ────────────────────────
if [ -z "$(find . -maxdepth 1 -name '*.tf' 2>/dev/null)" ]; then
    echo -e "${RED}  Error: no Terraform configuration files found for this module.${RST}"
    echo -e "${YEL}  The module may not have its .tf files added to the repository yet.${RST}"
    auth_cleanup
    rm -rf "$WORK_DIR"
    exit 1
fi

# ── Terraform ────────────────────────────────
local _tf_log
_tf_log=$(mktemp)

echo ""
echo -e "${YEL}  Initialising...${RST}"
if ! terraform init -input=false > "$_tf_log" 2>&1; then
    sed 's/^/  /' < "$_tf_log"
    rm -f "$_tf_log"
    echo -e "${RED}  Error: terraform init failed.${RST}"
    auth_cleanup; rm -rf "$WORK_DIR"; exit 1
fi

echo -e "${YEL}  Applying configuration...${RST}"
if ! terraform apply -auto-approve > "$_tf_log" 2>&1; then
    sed 's/^/  /' < "$_tf_log"
    rm -f "$_tf_log"
    echo -e "${RED}  Error: terraform apply failed.${RST}"
    auth_cleanup; rm -rf "$WORK_DIR"; exit 1
fi
rm -f "$_tf_log"

echo ""
echo -e "${GRN}  ✔ Custom Analytics deployed successfully.${RST}"

# ── Save a copy of what was deployed ─────────
local _module_name
_module_name=$(basename "$MODULE")
local _dest="${HOME}/Desktop/terraforno/${_module_name}"
rm -rf "$_dest"
mkdir -p "$_dest"
cp -r . "$_dest/"
find "$_dest" -name "deploy.sh"  -delete
find "$_dest" -name "tfplan"     -delete
find "$_dest" -name "*.tfstate*" -delete
find "$_dest" -name ".terraform" -type d -prune -exec rm -rf {} + 2>/dev/null || true
open "$_dest" 2>/dev/null
echo -e "${GRN}  ✔ Deployed configuration saved to ~/Desktop/terraforno/${_module_name}/${RST}"
# ── Clean up ─────────────────────────────
auth_cleanup
rm -rf "$WORK_DIR"
echo ""
