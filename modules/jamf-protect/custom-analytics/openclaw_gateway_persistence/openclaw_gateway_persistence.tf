# These custom analytics are derived from the examples found at
# https://github.com/jamf/jamfprotect/tree/main/custom_analytic_detections
# and are provided as-is.
# LaunchAgent created for OpenClaw's gateway mechanism.

resource "jamfprotect_analytic" "open_claw_gateway_persistence" {
  name        = "OpenClaw Gateway Persistence"
  description = "Detection of OpenClaw's gateway persistence (~/Library/LaunchAgents/ai.openclaw.gateway.plist)."

  sensor_type = "File System Event"
  filter      = "(\"LaunchDaemon\" IN $tags OR \"LaunchAgent\" IN $tags) AND $event.path.lastPathComponent BEGINSWITH \"ai.openclaw.\""

  categories = ["Persistence"]
  severity   = "Informational"
  level      = 0
  tags = []

  snapshot_files = []

  context_item = []
}
