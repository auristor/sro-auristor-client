#  SRO Build and Deployment Scripts

## Deployment Environment

The Primary Scripts (below) perform all the work for installing or removing an AuriStor SpecialResource defined in yaml file, for example [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml)  These scripts depend upon environment variables that must be set prior to running them.  

It is recommended that these environment variables be set using the provided ```setEnvironment``` script which extracts the SPECIAL_RESOURCE_NAME and SPECIAL_RESOURCE_NAMESPACE directly from the SpecialResource YAML file.

```bash
$ source setupEnvironment [SpecialResource YAML] [Create Map Script Name] [Delete Map Script Name]
```

Where:
- ```[SpecialResource YAML]``` is the location of the SpecialResource File
- ``` [Create Map Command]``` the name of a provided script that deploys any required ConfigMaps or Secrets referenced in the ```[SpecialResource YAML]```
- ```[Delete Map Command]``` the name of a provided script that deletes the ConfigMaps or Secrets created by the ```[Create Map CommandL]```

| Environment Variable | Description |
|---|--- |
| SPECIAL_RESOURCE_FILE | Location of the SpecialResource file. The format of the Special Resource file is found at [Configuring the SpecialResource](../configuringSpecialResource.md )) |
| SPECIAL_RESOURCE_NAME | SpecialResource Name |
| SPECIAL_RESOURCE_NAMESPACE | SpecialResource Name |
| SPECIAL_RESOURCE_CREATE_MAP_COMMAND |  User supplied script that configures any dependent ConfigMaps and Secrets  |
| SPECIAL_RESOURCE_DELETE_MAP_COMMAND | User supplied script that deletes the dependent ConfigMaps and Secrets created by SPECIAL_RESOURCE_CREATE_MAP_COMMAND |

---
---
## Primary Scripts


| Script | Description |
|---|--- |
| bin/redeploy | undeploy followed by deploy an AuriStor SpecialResource into the cluster
| bin/deploy | Deploy an AuriStor SpecialResource into the cluster |
| bin/undeploy | Removes an AuriStor SpecialResource from the cluster |
| bin/setupEnvironment | Sets all the required environment variables (see above) |


---
---
## Helper Build and Deploy Scripts
| Script | Description |
|---|---|
|bin/ createServiceAccount | Creates the namespace and CSI ServiceAccount for the SpecialResource
|	bin/buildSpecialResourceChart	|	Builds and Deploys the Special Resource Chart based upon values found in the SPECIAL_RESOURCE_FILE.   |
|	bin/deploySpecialResource	|	Deploys the Special Resource |

---
---
## Helper Validator Scripts 
| Script | Description |
|---|---|
| bin/verifyEnvironment | Pre-flight test to confirm it is possible to deploy  SPECIAL_RESOURCE_FILE |
| bin/verifyPristine | Verifies that there are no artifacts corresponding to any prior deployments of the SpecialResource corresponding to the SPECIAL_RESOURCE_FILE that is about to be deployed |
| bin/verifyVersions	|	Verifies that the Chrt Version specified in  /charts/Chart.yaml (.version) matches the Chart Version specified in the SPECIAL_RESOURCE_FILE (spec.chart.version) |
| bin/listObjects	|	List all currently deployed configuration objects corresponding to the deployed SPECIAL_RESOURCE_FILE|


