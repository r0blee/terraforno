# These custom analytics are derived from the examples found at
# https://github.com/jamf/jamfprotect/tree/main/custom_analytic_detections
# and are provided as-is.
# OpenClaw directory created in user's home folder.

resource "jamfprotect_analytic" "openclaw_directory_created" {
  name        = "OpenClaw Directory Created"
  description = "Detection of OpenClaw's hidden directory, created during setup."

  sensor_type = "File System Event"
  filter      = "$event.path MATCHES \"\\\\/Users\\\\/[^\\\\/]+\\\\/\\\\.openclaw\" AND $event.isNewDirectory == 1"

  categories = ["Visibility"]
  severity   = "Informational"
  level      = 0
  tags = []
  snapshot_files = []
  context_item = []

  lifecycle {
    ignore_changes = [filter]
  }
}
