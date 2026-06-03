resource "jamfpro_package" "jamf_setup_manager" {
  category_id           = "-1"
  fill_existing_users   = false
  fill_user_template    = false
  ignore_conflicts      = false
  info                  = "Uploaded by Terraforno"
  os_install            = false
  package_file_source   = "# TODO: set path to Setup.Manager.1.1.1-498.pkg"
  package_name          = "Jamf Setup Manager"
  parent_package_id     = "-1"
  priority              = 10
  reboot_required       = false
  self_heal_notify      = false
  self_healing_action   = "nothing"
  suppress_eula         = false
  suppress_from_dock    = false
  suppress_registration = false
  suppress_updates      = false
  swu                   = false
}