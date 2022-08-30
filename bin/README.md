#  SRO Build and Deployment Scripts

## Primary Scripts

| Script | Description |
|---|---
| createServiceAccount | Create the auristorfs-csi ServiceAccount in the auristorfs-client namespace (does nothing if the serviceAccount already exists)
|	applyRBAC	|	RBAC must be applied prior to launching the CSI Driver and/or Special Resource.  These RBAC are associated with the	auristorfs-csi ServiceAccount in the auristorfs-client namespace |
|	deploy	|	User Deployment of the  Special Resource.  Both the RBAC and Volume Maps must be created prior to running this. See applyRBAC script below and [Sample Volume Maps](../example/volumeMaps)	|
|	undeploy	|	Deletes the Special Resource and Special Resource Chart.  Leaves RBAC and VolumeMaps in place	|

## Developer Scripts
| Script | Description |
|---|---|
|	buildSpecialResourceChart	|	Builds the Special Resource Chart based upon. The version is extracted from the chart version from the .spec.chart.version field in [auristorfs-client-special-resource.yaml](../auristorfs-client-special-resource.yaml).  |
|	redeploy	|	Developer Script. Single command undeploy followed by deploy	|
|	rebuildAndDeploy	|	Developer Script.  Undeploys SR, Rebuilds SR Chart, and redeploys SR	|

## Helper Scripts
| Script | Description |
|---|---|
|	deploySpecialResource	|	Validating Helper Script to deploy the special resource chart	|
|	deploySpecialResourceChart	|	Validating Helper Script to deploy the special resource	|
|	verifyVersions	|	Helper Script to verify that the Version in the Chart matches the version in the Special Resource	|
