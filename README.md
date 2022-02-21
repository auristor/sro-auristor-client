# The AuriStorFS KMOD/CSI Special Resource 

## Background

To access files stored in AuriStorFS volumes from containers running in Pods on an OpenShift/Kubernetes cluster, has the following pre-requisites:

 - An AuriStorFS or kAFS client kernel module (aka cache manager) must be
   installed on the host node.  
   
- The installed AuriStorFS/kAFS kernel module must match the Linux kernel running on the node.
   
- An AuriStorFS CSI Driver "Node" Pod must then be running on that Node.  

- The AuriStorFS/kAFS kernel module must be loaded prior to starting the  AuriStorFS CSI Driver "Node" Pod 

The [Special Resource Operator (SRO)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html) is designed to help manage the deployment of kernel modules and drivers (such as for Distributed File Systems, GPUs, etc) on an existing OpenShift Container Platform cluster.  SRO responds to the presence of **SpecialResource (SR)** kubernetes objects which encapsulates all resource/vendor-specific information needed to guarantee the resource is properly installed and ready prior to scheduling Application Pods onto nodes.  

SRO contains an internaly embedded Helm engine which uses charts that are referenced by the SpecialResource object along with Helm Values necessary to configure the resource. The Helm Values in the SpecialResource object are merged with node host information, such as the installed Linux kernel version, that are made available to SRO by the [Node Feature Discovery Operator (NFD)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-node-feature-discovery-operator.html) 

 This Repository contains supporting scripts and objects necessary for creating and deploying the **AuriStorFS KMOD/CSI SpecialResource** Object.

# Using the AuriStorFS KMOD/CSI SpecialResource
The following Steps are all that is required to leverage AuriStorFS volumes in your OpenShift Cluster
 1. Install the Special Resource Operator and Node Discovery Operators
 2. Create the auristorfs-client namespace
 3. Configure the AuriStorFS KMOD/CSI SpecialResource object
 4. Copy Container Images accessible onto your private Registry (recommended)
 5.  Deploy the provided AuriStorFS Client configmap that corresponds to the version specified in the SpecialResource object
 6. Deploy the AuriStorFS KMOD/CSI SpecialResource object

## Step 1: Installing SRO and NFD Operators

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

- [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)


- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)

## Step 2: Creating the Namespace for the AuriStorFS Client

    apiVersion: v1
    kind: Namespace
    metadata:    
      name: auristorfs-client


## Step 3: AuriStorFS KMOD/CSI Special Resource Configuration


A single AuriStorFS Client SpecialResource object,  [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml), contains all necessary configuration data to manage the AuriStorFS kernel module and CSI Driver.  

The three primary configuration sections for the Special are under .spec:

| Section |Description |
|----|---|
| chart |  <UL><LI> The version of the AuriStorFS KMOD/CSI Helm Chart to use <LI>A URL reference to a ConfigMap object that contains the Helm Charts that will be used</UL> ConfigMaps for every Helm chart version are provided by AuriStorFS (see section on deplpoying the ConfigMap) |
| namespace | All Kubernetes Objects (DaemonSets, StatefulSets, Pods, ConfigMaps, etc.) created by the SpecialResource's Helm charts will be placed in this namespace|
| set | The set section contains all the AuriStorFS specific SpecialResource Helm 'Values' |

[auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml) 

	   apiVersion: sro.openshift.io/v1beta1
	   kind: SpecialResource
	   metadata:
	   name: auristor-client
	   spec:
		   namespace: auristorfs-client

		   chart:
		      name: auristor-client
		      version: 0.0.2
		      repository:
		         name: example
		         url: cm://auristorfs-client/auristor-client-chart
		         
		   set:
		      kind: Values
		      apiVersion: sro.openshift.io/v1beta1
		      kmodNames: ["yfs"]

		      runArgs:
		         platform: "openshift-container-platform"
		         
		      kmodDriverContainer:
		         image:               ###   Registry and Version Values
		            auristorRegistry: "ghcr.io/auristor"
		            auristorKmodVersion: "2021.05-15"
		            kmodImagePullPolicy: Always

		         yfsCache: /var/cache/yfs         ## Host Path to the local cache

		         mapVolumes:
		         - label: etc-yfs
		            target: /etc/yfs
		            configMap:
		               configMapName: etc-yfs 
		         - label: usr-share-yfs
		            target: /usr/share/yfs
		            configMap:
		               configMapName: usr-share-yfs
		         - label: etc-yfs-keytabs
		            target: /etc/yfs-keytabs
		            secret:
		               secretName: etc-yfs-keytabs

		      csiDriver:
		         image:       ###   Registry and Version Values
		            auristorRegistry: ghcr.io/auristor
		            auristorCsiVersion: 2022.02-2
		            csiDriverImagePullPolicy: Always
		            k8sSigStorageRegistry: k8s.gcr.io/sig-storage
		            k8sSigStorageImagePullPolicy: Always

		         cacheManager:       ###  Cache Manager Values
		            defaultCacheManager: auristor

		         logging:
		            logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)

---

###  KMOD Driver Container Configuration

The AuriStorFS SpecialResource guarantees that a cache manager is running on each node in the OpenShift cluster.   A  "DriverContainer"  is run in a Pod on each node which has a cache manager configured in the same manner as it would on any machine.  

AuriStor provides DriverContainer Images for each AuriStorFS/Linux-kernel version pair.  It is only necessary to configure the SpecialResource with the desired AuriStorFS KMOD version.  SRO (via NFD) provides the kernel version to the SpecialResource which automatically selects the appropriate AuriStorFS DriverContainer image for the node.

All necessary AuriStorFS cache manager configuration files (yfs-client.conf, cellservdb.conf, etc, keytabs, etc) are mapped into the DriverContainer on a per-directory basis via  Kubernetes ConfigMap and Secret objects (see mapVolumes fields)

####  set.kmodDriverContainer  Fields
-   **image:**
	-   **auristorRegistry**: The Container Registry where the Driver Container Images are located
	-   **auristorKmodVersion**: The AuriStorFS kernel module version  
-   **yfsCache**:  The path on the host node where the persistent cache files will be stored ( Typically **/var/cache/yfs**).
-   **mapVolumes**:  Configuration directory file contents provided as ConfigMaps and Secrets
	-    **label**: Used within the Pod to associate volumeMounts with volumes
    - **target**: Path in the Driver Container for the mapped directory's files
    - **configMap.configMapName**: The ConfigMap object name associated with this entry
    - **secret.secretName**: The Secret object name that is associated with this entry

**More on VolumeMaps:** Example Values and other information about preparing the ConfigMap and Secrets corresponding to volumeMaps can be found at [examples/volumeMaps](examples/volumeMaps).  It is important to note that the mapVolume ConfigMaps and Secrets must be in the same namespace as the AuriStorFS KMOD/CSI SpecialResource

---

###  CSI Driver Configuration

The AuriStorFS CSI Driver is versioned independently from the AuriStorFS kmod version numbers.   Note however that the AuriStorFS KMOD/CSI versions will track closely to CSI Driver versions.

-   **image:**
	-  **auristorRegistry**: The Container Registry where the AuriStorFS CSI Container Images are located
	-   **auristorCsiVersion**: The AuriStorFS CSI Driver version
	-   **csiDriverImagePullPolicy**: The AuriStorFS CSI Driver Container Image Pull Policy
	-   **k8sSigStorageRegistry**: The Container Registry for the Kubernetes SigStorage CSI Sidecar Container Images
	-   **.csiDriverImagePullPolicy**: The CSI Sidecar Container Image Pull Policy 
-   **cacheManager:**
	- **defaultCacheManager**: "auristor" or "kafs"
-   **logging:**
	- **logLevel**: DEBUG, INFO, WARNING, ERROR, or FATAL


## Step 4: Copying Container Images to Private Registry

It is Strongly Recommended that you copy all Container Images used by the AuriStorFS KMOD/CSI SpecialResource into an organizational private container registry.

The locations for these container images are derived from the fields in the SpecialResource (under 'set')

---

**AuristorFS KMOD DriverContainer Image**

Templated Format:
**&lt;kmodDriverContainer.image.auristorRegistry&gt;**/auristor-kmod-**&lt;kmodDriverContainer.image.auristorKmodVersion&gt;**:
**&lt;Node Kernel Module Version&gt;**

Example:

    ghcr.io/auristor/auristor-kmod-2021.05-15:4.18.0-305.el8.x86_64

---
**AuristorFS CSI Driver Image**

Templated Format:
**&lt;csiDriver.image.auristorRegistry&gt;**/auristorfs-csi:**&lt;csiDriver.image.auristorCsiVersion&gt;**:

Example:

    ghcr.io/auristor/auristorfs-csi:2022.02-2
---

**AuriStorFS CSI Sidecar Images**

The CSI Driver Pods leverage sidecar containers images provided by the Kubernetes SigStorage.   

The specific sidecars and sidecar container image tags are embedded in the AuriStorFS KMOD/CSI SpecialResource chart.  

Detailed information on required images are found in the README of the corresponding AuriStorFS KMOD/CSI SpecialResource version (see [chartVersions](chartVersions)/&lt;version&gt;/README.md or the [README for the latest version](chart/README.md)

Example:

    k8s.gcr.io/sig-storage/csi-attacher:v3.4.0


## Step 5: Deploying the Configuration ConfigMap and Secrets

ConfigMaps and Secrets must be created and deployed into your cluster prior to Initialization of the Node



**See** [VolumeMap ConfigmMap and Secrets](examples/volumeMaps)

## Step 6: Deploying the AuriStorFS KMOD/CSI SpecialResource ConfigMap

Pre-build ConfigMap objects containing the charts corresponding to the versions referenced  AuriStorFS KMOD/CSI SpecialResource object  (spec.chart.version)  are available under [chartVersions](chartVersions) with the latest version at [chartVersions/latest](chartVersions/latest).  These charts must be considered Read-Only and need be deployed prior to the AuriStorFS KMOD/CSI SpecialResource object.

The latest version of the AuriStorFS KMOD/CSI SpecialResource charts will be found  at:

    chartVersions\latest\auristorfs-client-chart.yaml
	

A sample script for deploying these  directly from the ([auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml))  file can be found at [bin/deploySpecialResourceChart](bin/deploySpecialResourceChart)


## Step 7:  Deploy the AuriStorFS KMOD/CSI SpecialResource object

oc create -f auristorfs-client-special-resource.yaml

