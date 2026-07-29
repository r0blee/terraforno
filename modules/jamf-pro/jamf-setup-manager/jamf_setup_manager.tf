resource "jamfplatform_pro_macos_configuration_profile" "setup_manager" {
  general = {
    name     = "Terraforno - Jamf Setup Manager Template"
    level    = "Computer Level" # PayloadScope = System
    payloads = file("${path.module}/SetupManager.mobileconfig")

    distribution_method = "Install Automatically"
    user_removable       = false
  }

  # Fill in the audience for this profile. Replace with specific
  # computer_ids / computer_group_ids etc. if you don't want it tenant-wide.
  scope = {
    targets = {
      all_computers = true
    }
  }
}

resource "jamfplatform_pro_package" "jamf_setup_manager_1_4_7_652" {
  display_name        = "Jamf Setup Manager v1.4.7-652"
  file_name           = "Setup.Manager-1.4.7-652.pkg"
  package_file_source = "https://github.com/jamf/Setup-Manager/releases/download/v1.4.7/Setup.Manager-1.4.7-652.pkg"
}