# Terraforno

Thank you for using Terraforno to configure your Jamf environment.

# Custom Analytics

## openclaw_directory_created

### module: jamf-protect/custom-analytics/openclaw_gateway_persistence

This module creates a Custom Analytic within Jamf Protect that performs the detection of OpenClaw's gateway persistence (~/Library/LaunchAgents/ai.openclaw.gateway.plist).

This Terraforno module can be used with both Terraforno modes:
- Deploy
- Export

#### Deploy 

When using this mode Terraforno will deploy a copy of the accompanying Terraform configuration to the environment you choose.

Upon completion a copy of the deployed Terraform resource blocks will be left in a directory on your desktop for reference as to what was created. Terraforno will not maintain a Terraform state file for this deployment.


#### Export

If choosing to export the associated Terrform configuration you will be presented with a directory on your desktop containing the associated Terraform configuration that you can run as is, or copy the resource blocks out into your own Terraform configuration for inclusion. 

##### Example usage:

````bash
terraforno --module jamf-protect/custom-analytics/openclaw_gateway_persistence --profile prod --mode <deploy|export> --override <yes|no>
````