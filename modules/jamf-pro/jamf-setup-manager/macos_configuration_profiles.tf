resource "jamfpro_macos_configuration_profile_plist" "jamf_setup_manager_example_profile" {
  category_id         = "-1"
  distribution_method = "Install Automatically"
  level               = "System"
  name                = "Jamf Setup Manager - Example Profile"
  payload_validate    = false
  payloads            = file("${path.module}/support_files/macos_configuration_profiles/Jamf Setup Manager - Example Profile.mobileconfig")
  redeploy_on_update  = "Newly Assigned"
  user_removable      = false

  scope {
    all_computers      = false
    all_jss_users      = false
    building_ids       = []
    computer_group_ids = []
    computer_ids       = []
    department_ids     = []
    jss_user_group_ids = []
    jss_user_ids       = []
  }
}