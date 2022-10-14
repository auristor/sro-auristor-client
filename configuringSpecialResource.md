
# AuriStorFS KMOD/CSI Special Resource Configuration

## Understanding the Container Images used by the AuriStorFS SpecialResource
The AuriStorFS SpecialResource guarantees that a cache manager is running on each node in the OpenShift cluster. A "DriverContainer" is run as a Pod on each node. The DriverContainer installs the AuriStorFS cache manager. The AuriStorFS Cache Manager installed through the Driver Container uses the same configuration files, keytabs, etc and in the same way that it would be configured any machine.

AuriStor provides DriverContainer Images for each AuriStorFS/Linux-kernel version pair. It is only necessary to configure the SpecialResource with the desired AuriStorFS KMOD version. SRO (via NFD) provides the kernel version to the SpecialResource which automatically selects the appropriate AuriStorFS DriverContainer image for the node.

All necessary AuriStorFS cache manager configuration files (yfs-client.conf, cellservdb.conf, etc, keytabs, etc) and the yfs-cache locations are provided as mapped volumes into the DriverContainer on a per-directory basis for where the respecitve files are expected. These volume mappings are specified in the set.kmodDriverContainer.mapVolumes section. Each entry in that section specifies one volume map that can either be of type hostPath, configMap, or secret.

# Special Resource Configuration

A single YAML file is used to configure your AuriStorFS  SpecialResource object.  This contains the necessary configuration data to install the AuriStorFS kernel module and CSI Driver.  

## Selecting a Name for your SpecialResource

<style type="text/css"><!--  .redb  { color: red; font-weight:bold; } --> </style>
<style type="text/css"><!--  .standout  { color: blue;  font-style: italic; } --> </style>

You may use any valid Kubernetes name as the <span class=redb> [resource name]</span> for your SpecialResource.  However, due to a fragility in the SRO implementation, you must use the following pattern exactly in the preamble of the SpecialResource YAML.  

SpecialResource objects themselves are not name-spaced, so to keep scoping clear all related and SRO generated objects for that SpecialResource will be placed in a namespace  <span class=redb> [resource name]</span>


<style type="text/css"><!--  .tab  { margin-left: 30px;  margin-right: 30px;} --> </style>
<style type="text/css"><!--  .tab1 { margin-left: 20px; } --> </style>
<style type="text/css"><!--  .tab2 { margin-left: 40px; } --> </style>
<style type="text/css"><!--  .tab3 { margin-left: 60px; } --> </style>
<style type="text/css"><!--  .tab4 { margin-left: 80px; font-style: italic; } --> </style>

<TABLE border=3 <table style="background-color:#FFFFE0;">
    <TR><TD>
        <p class=tab>
        apiVersion: sro.openshift.io/v1beta1<BR>
        kind: SpecialResource<BR>
        metadata:<BR>
            <span class=tab1>
                name: <span class=redb> [resource name]</span><BR>
            </span>
        spec:<BR>
            <span class=tab1>
                namespace: <span class=redb> [resource name]</span><BR>
            <span class=tab1>
                chart:<BR>  
            </span>
                <span class=tab2>
                    name: <span class=redb>[resource name]</span>-chart<BR>
                </span>
                <span class=tab2>
                    version: 0.0.6<BR>
                </span>
                <span class=tab2>
                    repository<BR>
                </span>     
                    <span class=tab3>
                        name: <span class=redb>[resource name]</span><BR>
                    </span>     
                    <span class=tab3>
                        url: cm//<span class=redb>[resource name]</span>/<span class=redb>[resource name]</span>-chart<BR><BR>
                    </span>   
                    <span class=tab4>
                        [... Configuration  continues..]<BR>
                    </span>            
        </p>
    </TD></TD>
</TABLE>



For example, if you wanted to use the name <span class=redb> auristorfs-client</span> for your SpecialResource you would configure it this way:

<TABLE border=3 <table style="background-color:#FFFFE0;">
    <TR><TD>
        <p class=tab>
        apiVersion: sro.openshift.io/v1beta1<BR>
        kind: SpecialResource<BR>
        metadata:<BR>
            <span class=tab1>
                name: <span class=redb> [auristorfs-client]</span><BR>
            </span>
        spec:<BR>
            <span class=tab1>
                namespace: <span class=redb> [auristorfs-client]</span><BR>
            <span class=tab1>
                chart:<BR>  
            </span>
                <span class=tab2>
                    name: <span class=redb>[auristorfs-client]</span>-chart<BR>
                </span>
                <span class=tab2>
                    version: 0.0.6<BR>
                </span>
                <span class=tab2>
                    repository<BR>
                </span>     
                    <span class=tab3>
                        name: <span class=redb>[auristorfs-client]</span><BR>
                    </span>     
                    <span class=tab3>
                        url: cm//<span class=redb>[auristorfs-client]</span>/<span class=redb>[auristorfs-client]</span>-chart<BR><BR>
                    </span>   
                    <span class=tab4>
                        [... Configuration  continues..]<BR>
                    </span>            
        </p>
    </TD></TD>
</TABLE>

Example SpecialResource can be found at: [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml) 

## AuriStorFS SpecialResource details

There are three primary configuration sections, each found under .spec:

| Section |Description |
|----|---|
| chart | The **.spec.chart.version** field specifies which version of the AuriStor Special Resource Chart to be used.  This ***MUST*** match the deployed Special Resource Chart ConfigMap. See 7b below on Deploying the AuriStorFS Special Resource Chart ConfigMap  |
| namespace | All Kubernetes Objects (DaemonSets, StatefulSets, Pods, ConfigMaps, etc.) created by the SpecialResource's Helm charts will be placed in this namespace  Recommended namespace name is: auristorfs-client|
| set | The set section contains all the AuriStorFS specific SpecialResource Helm 'Values' |

The below is from the sample SpecialResource [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml) 

```
apiVersion: sro.openshift.io/v1beta1
kind: SpecialResource
metadata:
  name: auristorfs-client
spec:
  namespace: auristorfs-client

  chart:
    name: auristorfs-client
    version: 0.0.6
    repository:
      name: auristorfs-client-chart
      url: cm://auristorfs-client/auristorfs-client-chart

  set:
    kind: Values
    apiVersion: sro.openshift.io/v1beta1
    kmodNames: ["yfs"]

    runArgs:
      platform: "openshift-container-platform"

    nodeSelector: { auristor.com/auristorfs-group: group-1 }

    kmodDriverContainer:
      image:
        auristorRegistry: "ghcr.io/auristor"
        auristorKmodVersion: "2021.05-20"
        kmodImagePullPolicy: Always
        terminationGracePeriodSeconds: 2

      mapVolumes:
        - label: yfs-cache
          target: /var/cache/yfs
          hostPath: 
            path: /var/cache/yfs
            
        - label: etc-yfs
          target: /etc/yfs
          configMap:
            name: etc-yfs

        - label: usr-share-yfs
          target: /usr/share/yfs
          configMap:
            name: usr-share-yfs

        # - label: etc-yfs-keytabs
        #   target: /etc/yfs-keytabs
        #   secret:
        #     name: etc-yfs-keytabs
        
        - label: etc-yfs-keytabs
          target: /etc/yfs-keytabs
          hostPath:
            path: /etc/yfs-keytabs           


    csiDriver:
      image:       ###   Registry and Version Values
        auristorRegistry: ghcr.io/auristor
        auristorCsiVersion: 2022.09-1
        csiDriverImagePullPolicy: Always
        k8sSigStorageRegistry: k8s.gcr.io/sig-storage
        k8sSigStorageImagePullPolicy: Always


      cacheManager:       ###  Cache Manager Values
        defaultCacheManager: auristor

      afsMount:
        mountSeLinuxFS: "true"
        auristorfsMountOptions: "-o context=system_u:object_r:container_file_t:s0"       

      logging:
        logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)

      debug: 
        debugShowMounts: false
        debugShowExecs: false
        debugShowCsiRequests: false		
```	

### Name Fields

As described in the section on Selecting a *Name for your SpecialResource*, there is a proscribed convention for these fields that must be followed

The following fields must follow the proscribed convention

* **.metadata.name:** The name of the SpecialResource
* **.spec.namespace** The namespace for this SpecialResource
* **.spec.chart.name:** The helm chart name for the SpecialResource
* **spec.chart.repository.name** The placeholder hel repo name, but this is unused because the charts are deployed as ConfigMaps created during deployment
* **.spec.chart.repository.url:** The URL format for ConfigMap contained Chart content

### Version Field

The version field must contain the value corresponding to the desired release branch obtaint from GitHub
* **.spec.chart.version:** Chart version of format ```0.0.N``` corresponding to GitHub branch ```version-0.0.N```

### Fields that should be left unchanged

* **.set.kind:*** <span class=standout> Values </span>
* **.set.apiVersion:** <span class=standout> sro.openshift.io/v1beta1 </span>
* **.set.kmodNames:*** <span class=standout> ["yfs"] </span>
* **.set.runArgs.platform:*** <span class=standout> "openshift-container-platform" </span>

### Node Selection

If this is a SpecialResource targeting a subset of nodes in the cluster, the node-selector field should be set with the corresponding node labels
* **.set.nodeSelector:** { auristor.com/auristorfs-group: group-1 }

If a single SpecialResource is to be deployed homogeneously to all nodes in the clustetr, leave the nodeSelector empty
* **.set.nodeSelector:** {  }


###  **.set.kmodDriverContainer** Fields
- **.image:**
	-   **.auristorRegistry**: The Container Registry where the Driver Container Images are located
	-   **.auristorKmodVersion**: The AuriStorFS kernel module version  
- **.mapVolumes**:  Configuration directory file contents provided as ConfigMaps and Secrets
	- **.label**: Used within the Pod to associate volumeMounts with volumes
    - **target**: Path in the Driver Container for the mapped directory's files
	- **,hostPath.path**: The local path on the node associated with this entry
    - **,configMap.name**: The ConfigMap object name associated with this entry
    - **,secret.name**: The Secret object name that is associated with this entry
,
For hostPaths, the constituent files would be expected to have been pre-installed and found under a hostPath on the nodes which had been pre-configured and/or pre-populated on that node using a OpenShift MachineConfig objects.
* The yfs-cache must always be a hostPath directory
* The key-tabs volume may be either a hostPath or a secret, depending upon whether you are using shared keytabs across all nodes or are using per-node keytabs

Alternatively files can via injected into the nodes via ConfigMap or Secret objects 
* The etc-yfs and usr-share-yfs volumes would typically be specified as configMaps.
* The key-tabs volume may be either a hostPath or a secret, depending upon whether you are using shared keytabs across all nodes or are using per-node keytabs

**More on VolumeMaps:** Example Values and other information about preparing the ConfigMap and Secrets corresponding to volumeMaps can be found at [examples/volumeMaps](examples/volumeMaps).  These are provided as examples ONLY because your configuration and keytabs will be specific to your organization/installation.  They do NOT correspond to real-life values.

It is necessary to create a script to create these supporting ConfigMaps and Secrets along with a script to destroy them.  The folowing are provided as examples only:

* [examples/volumeMaps/createMaps](examples/volumeMaps/createMaps)
* [examples/volumeMaps/deleteMaps](examples/volumeMaps/deleteMaps)


###  CSI Driver Configuration

The AuriStorFS CSI Driver is versioned independently from the AuriStorFS kmod version numbers.   Note however that the AuriStorFS KMOD/CSI versions will track closely to CSI Driver versions.

###  **.set.csiDriver** Fields

-   **.image:**
	-  **.auristorRegistry**: The Container Registry where the AuriStorFS CSI Container Images are located
	-   **.auristorCsiVersion**: The AuriStorFS CSI Driver version.
	-   **.csiDriverImagePullPolicy**: The AuriStorFS CSI Driver Container Image Pull Policy
	-   **.k8sSigStorageRegistry**: The Container Registry for the Kubernetes SigStorage CSI Sidecar Container Images
	-   **..csiDriverImagePullPolicy**: The CSI Sidecar Container Image Pull Policy 
-   **.cacheManager:**
	- **.defaultCacheManager**: "auristor" or "kafs"
-   **.afsMount:**
	- **.mountSeLinuxFS**: Expictly mount SeLinux (true/false)
	- **.auristorfsMountOptions**: Mount Options for AuriStor FS Root mounting
-   **.logging:**
	- **.logLevel**: DEBUG, INFO, WARNING, ERROR, or FATAL
-   **.debug:**
	- **.debugShowMounts**: Log mount commands and results	
	- **.debugShowExecs**: Log all 'exec' commands and results
	- **.debugShowCsiRequests**: Log all CSI requests and responses


