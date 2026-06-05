#!/bin/bash
# ─────────────────────────────────────────
# ── Module Info ──────────────────────────
# APIs:   Jamf Protect API
# Auth:   auth_jamf_protect_oauth2
# ─────────────────────────────────────────

#  Create analytic for Openclaw Directory Created — deploy.sh
#  Provider: Jamf-Concepts/jamfprotect
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
echo -e "${BLD}  ── Create analytic for Openclaw Directory Created ──${RST}"
echo ""

# ── Deployment mode ─────────────────────────
select_deploy_mode

if [ "$DEPLOY_MODE" = "export" ]; then
    export_terraform_config "$MODULE" "$GITHUB_REPO"
    exit 0
fi

# ── Authentication ───────────────────────────
auth_jamf_protect_oauth2

# ── Pull config from GitHub ──────────────────
echo ""
echo -e "${YEL}  Pulling module config from GitHub...${RST}"
rm -rf "$WORK_DIR"
git clone --depth=1 --branch main \
    "$GITHUB_REPO" "$WORK_DIR" 2>&1 | sed 's/^/  /'

if [ ! -d "$WORK_DIR/modules/$MODULE" ]; then
    echo -e "${RED}  Error: module '$MODULE' not found in repo.${RST}"
    auth_cleanup
    rm -rf "$WORK_DIR"
    exit 1
fi

cd "$WORK_DIR/modules/$MODULE" || { auth_cleanup; rm -rf "$WORK_DIR"; exit 1; }

# ── Generate provider configuration ──────────
_write_provider_tf "auth_jamf_protect_oauth2"

# ── Verify Terraform configuration exists ────
if [ -z "$(find . -maxdepth 1 -name '*.tf' 2>/dev/null)" ]; then
    echo -e "${RED}  Error: no Terraform configuration files found for this module.${RST}"
    echo -e "${YEL}  The module may not have its .tf files added to the repository yet.${RST}"
    auth_cleanup
    rm -rf "$WORK_DIR"
    exit 1
fi

# ── Terraform ────────────────────────────────
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
terraform apply -auto-approve > "$_tf_log" 2>&1
_apply_exit=$?

if [ "$_apply_exit" -ne 0 ]; then
    if grep -q "Provider produced inconsistent result after apply" "$_tf_log"; then
        echo ""
        echo -e "${YEL}  ⚠  Applied with a provider warning (inconsistent result).${RST}"
        echo -e "${YEL}     The resource was created. Add lifecycle { ignore_changes = [...] }${RST}"
        echo -e "${YEL}     to suppress this in future runs.${RST}"
    else
        sed 's/^/  /' < "$_tf_log"
        rm -f "$_tf_log"
        echo -e "${RED}  Error: terraform apply failed.${RST}"
        auth_cleanup; rm -rf "$WORK_DIR"; exit 1
    fi
fi
rm -f "$_tf_log"

echo ""
echo -e "${GRN}  ✔ Openclaw Directory Created analytic deployed successfully.${RST}"

# ── Next steps (deploy) ──────────────────────
echo ""
echo -e "${CYN}  What to do next:${RST}"
echo -e "    1. The analytic is now active in Jamf Protect."
echo -e "    2. Verify it appears under Analytics in your Jamf Protect tenant."
echo -e "    3. Check the exported configuration saved to your Desktop."
echo ""

# Call export mode to save a copy — suppresses export's own next steps
# since we've already shown the deploy next steps above.
_CALLED_FROM_DEPLOY=1 export_terraform_config "$MODULE" "$GITHUB_REPO"

# ── Clean up ─────────────────────────────────
auth_cleanup
rm -rf "$WORK_DIR"
echo ""
