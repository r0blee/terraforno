# These custom analytics are derived from the examples found at
# https://github.com/jamf/jamfprotect/tree/main/custom_analytic_detections
# and are provided as-is.
# Skills added to OpenClaw via Clawhub.

resource "jamfprotect_analytic" "open_claw_skills_install_clawhub" {
  name        = "OpenClaw skills installation"
  description = "Detection of skills installed from Clawhub via npx command."

  sensor_type = "Process Event"
  filter      = "$event.type == 1 AND $event.process.args.@count > 1 AND ( ( ( ( (ANY $event.process.args CONTAINS[c] \"/npx\") OR (ANY $event.process.args CONTAINS[c] \"/pnpm\") ) AND (ANY $event.process.args BEGINSWITH[c] \"clawhub\") ) OR ( (ANY $event.process.args CONTAINS[c] \"/bunx-\") AND (ANY $event.process.args CONTAINS[c] \"/clawhub\") ) ) AND (ANY $event.process.args == \"install\") AND $event.process.path.lastPathComponent == \"node\" )"

  categories = ["Visibility"]
  severity   = "Informational"
  level      = 0
  tags = []

  snapshot_files = []

  context_item = []
}
