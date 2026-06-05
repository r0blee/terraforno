# These custom analytics are derived from the examples found at
# https://github.com/jamf/jamfprotect/tree/main/custom_analytic_detections
# and are provided as-is.
# OpenClaw installation via commands found on openclaw.ai.

resource "jamfprotect_analytic" "open_claw_installation" {
  name        = "OpenClaw Installation"
  description = "Detection of OpenClaw installation commands from openclaw.ai."

  sensor_type = "Process Event"
  filter      = "$event.type == 1 AND $event.process.args.@count > 1 AND ( ( (ANY $event.process.args CONTAINS[c] \"npm\") AND (ANY $event.process.args BEGINSWITH \"openclaw\") AND ( (ANY $event.process.args == \"i\") OR (ANY $event.process.args == \"install\") OR (ANY $event.process.args == \"add\") OR (ANY $event.process.args == \"in\") OR (ANY $event.process.args == \"ins\") OR (ANY $event.process.args == \"inst\") OR (ANY $event.process.args == \"insta\") OR (ANY $event.process.args == \"instal\") OR (ANY $event.process.args == \"isnt\") OR (ANY $event.process.args == \"isnta\") OR (ANY $event.process.args == \"isntal\") OR (ANY $event.process.args == \"isntall\") ) AND $event.process.path.lastPathComponent == \"node\" ) OR ( (ANY $event.process.args BEGINSWITH \"openclaw\") AND (ANY $event.process.args == \"add\") AND $event.process.path.lastPathComponent == \"pnpm\" ) )"

  categories = ["Visibility"]
  severity   = "Informational"
  level      = 0
  tags = []

  snapshot_files = []

  context_item = []
}
