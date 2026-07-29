resource "jamfplatform_pro_macos_configuration_profile" "privilege_elevation" {
  general = {
    name     = "Terraforno - Privilege Elevation"
    level    = "Computer Level" # PayloadScope = System
    payloads = file("${path.module}/PrivilegeElevation.mobileconfig")

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
