resource "jamfplatform_blueprints_blueprint" "set_and_forget_os_updates" {
  provider = jamfplatform

  deployed      = false
  device_groups = []
  name          = "Set and Forget OS updates"
  software_update = {

    deployment_time       = "17:00"
    details_url_value     = "https://support.apple.com/en-us/100100"
    enforce_after_days    = 7
    ignore_major_versions = false
  }
}