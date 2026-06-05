# These custom analytics are derived from the examples found at
# https://github.com/jamf/jamfprotect/tree/main/custom_analytic_detections
# and are provided as-is.
# OpenClaw Onboard Command Activity

resource "jamfprotect_analytic" "open_claw_onboard" {
  name        = "OpenClaw Onboard Command Activity"
  description = "Detection of OpenClaw onboard command to initiate setup."

  sensor_type = "Process Event"
  filter      = "$event.type == 1 AND $event.process.args.@count > 1 AND ( (ANY $event.process.args CONTAINS[c] \"openclaw\") AND (ANY $event.process.args == \"onboard\") ) AND $event.process.parent.path.lastPathComponent == \"node\""

  categories = ["Visibility"]
  severity   = "Informational"
  level      = 0
  tags = []

  snapshot_files = []

  context_item = []
}
