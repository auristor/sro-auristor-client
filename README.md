
# The AuriStorFS KMOD/CSI Special Resource

  

## Background

To access files stored in AuriStorFS volumes from containers running in Pods on an OpenShift/Kubernetes node, the following pre-requisites must be met:

- An AuriStorFS or kAFS client kernel module (aka cache manager) must be installed on the host node.
- The installed AuriStorFS/kAFS kernel module must match the Linux kernel running on the node.
- An AuriStorFS CSI Driver "Node" Pod must then be running on that Node.
- The AuriStorFS/kAFS kernel module must be loaded prior to starting the AuriStorFS CSI Driver "Node" Pod
- Other supporting AuriStorFS CSI Driver Pods must be running in the cluster that help coordinate the validation, creation, and maintainance of Kubernetes PersistentVolumes corresponding to the AuriStorFS Volumes being mounted into app;ication containers

The [Special Resource Operator (SRO)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html) is designed to help manage the deployment of kernel modules and drivers (such as for Distributed File Systems, GPUs, etc) on an existing OpenShift Container Platform cluster. SRO responds to the presence of **SpecialResource (SR)** Kubernetes objects which encapsulates all resource/vendor-specific information needed to guarantee the resource is properly installed and ready prior to scheduling Application Pods onto nodes.

SRO contains an internaly embedded Helm engine which uses charts that are referenced by the SpecialResource object along with Helm Values necessary to configure the resource. The Helm Values in the SpecialResource object are merged with node host information, such as the installed Linux kernel version, that are made available to SRO by the [Node Feature Discovery Operator (NFD)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-node-feature-discovery-operator.html)

  This Repository contains supporting scripts and objects necessary for creating and deploying the **AuriStorFS KMOD/CSI SpecialResource** Object.

  
# Using the AuriStorFS KMOD/CSI SpecialResource

The following Steps are all that is required to leverage AuriStorFS volumes in your OpenShift Cluster

1. Install the Special Resource Operator and Node Discovery Operators

2. Create the **auristorfs-client** namespace

3. Configure the AuriStorFS KMOD/CSI SpecialResource object ([auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml))

4. Copy Container Images accessible onto your private Registry (recommended)

5. Create **auristorfs-client** Service Account

6. Deploy the provided AuriStorFS Client configmaps that corresponds to the version specified in the SpecialResource object

7. Deploy the AuriStorFS KMOD/CSI SpecialResource
	* 7a. Applying the AuriStorFS CSI RBAC
	* 7b. Deploying the AuriStorFS Special Resource Chart ConfigMap
	* 7c. Deploying the AuriStorFS Special Resource Object


## Step 1: Installing SRO and NFD Operators

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

 - [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)

- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)

**Note**: There is an option to install these in a single namespace or all namespaces.  We recommend installing in a single namespace

## Step 2: Creating the Namespace for the AuriStorFS Client

Create a namespace 'auristorfs-client'

    oc create namespace auristorfs-client


## Step 3: AuriStorFS KMOD/CSI Special Resource Configuration

A single AuriStorFS Client SpecialResource object,  [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml), contains all necessary configuration data to manage the AuriStorFS kernel module and CSI Driver.  

In [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml) there are three primary configuration sections, each found under .spec:

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
		      version: 0.0.4
		      repository:
		         name: auristorfs-client-chart
		         url: cm://auristorfs-client/auristor-client-chart
		         
		   set:
		      kind: Values
		      apiVersion: sro.openshift.io/v1beta1
		      kmodNames: ["yfs"]

		      runArgs:
		         platform: "openshift-container-platform"
		         
		      kmodDriverContainer:
		         image:                           ##   Registry and Version Values
		            auristorRegistry: "ghcr.io/auristor"
		            auristorKmodVersion: "2021.05-15"
		            kmodImagePullPolicy: Always

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
		            auristorCsiVersion: 2022.02-2
		            csiDriverImagePullPolicy: Always
		            k8sSigStorageRegistry: k8s.gcr.io/sig-storage
		            k8sSigStorageImagePullPolicy: Always

		         cacheManager:       ###  Cache Manager Values
		            defaultCacheManager: auristor

		         logging:
		            logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)

---


##  KMOD Driver Container Configuration

The AuriStorFS SpecialResource guarantees that a cache manager is running on each node in the OpenShift cluster.   A  "DriverContainer"  is run as a Pod on each node. The DriverContainer installs the AuriStorFS cache manager. The AuriStorFS Cache Manager installed through the Driver Container uses the same configuration files, keytabs, etc and in the same way that it would be configured any machine.  

AuriStor provides DriverContainer Images for each AuriStorFS/Linux-kernel version pair.  It is only necessary to configure the SpecialResource with the desired AuriStorFS KMOD version.  SRO (via NFD) provides the kernel version to the SpecialResource which automatically selects the appropriate AuriStorFS DriverContainer image for the node.

All necessary AuriStorFS cache manager configuration files (yfs-client.conf, cellservdb.conf, etc, keytabs, etc) and the yfs-cache locations are provided as mapped volumes into the DriverContainer on a per-directory basis for where the respecitve files are expected. These volume mappings are specified in the set.kmodDriverContainer.mapVolumes section.  Each entry in that section specifies one volume map that can either be of type hostPath, configMap, or secret.  


###  **set.kmodDriverContainer** Fields
-   **image:**
	-   **auristorRegistry**: The Container Registry where the Driver Container Images are located
	-   **auristorKmodVersion**: The AuriStorFS kernel module version  
-   **mapVolumes**:  Configuration directory file contents provided as ConfigMaps and Secrets
	-    **label**: Used within the Pod to associate volumeMounts with volumes
    - **target**: Path in the Driver Container for the mapped directory's files
	- **hostPath.path**: The local path on the node associated with this entry
    - **configMap.name**: The ConfigMap object name associated with this entry
    - **secret.name**: The Secret object name that is associated with this entry

For hostPaths, the constituent files would be expected to have been pre-installed and found under a hostPath on the nodes which had been pre-configured and/or pre-populated on that node using a OpenShift MachineConfig objects.
* The yfs-cache must always be a hostPath directory
* The key-tabs volume may be either a hostPath or a secret, depending upon whether you are using shared keytabs across all nodes or are using per-node keytabs

Alternatively files can via injected into the nodes via ConfigMap or Secret objects 
* The etc-yfs and usr-share-yfs volumes would typically be specified as configMaps.
* The key-tabs volume may be either a hostPath or a secret, depending upon whether you are using shared keytabs across all nodes or are using per-node keytabs

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


## Step 5: Create **auristorfs-csi** Service Account

Prior to deploying the AuriStorFS Special Resource and/or the AuriStorFS CSI Driver, the  **auristorfs-csi** in the **auristorfs-client** namespace

* The provided **bin/createServiceAccount** script applies the **rbac/csi-driver-rbac.yaml** file in the **auristorfs-client** namespace
* Alternatively the service account may be created via your Kubernetes IAM 

## Step 6: Deploying the Configuration ConfigMap and Secrets

ConfigMaps and Secrets must be created and deployed into your cluster prior to Initialization of the Node.  

**See** [VolumeMap ConfigMap and Secrets](examples/volumeMaps)

These are provided as examples because your configuration and keytabs will be specific to your organization/installation


## Step 7: Deploying the AuriStorFS Special Resource

The deployment of the AuriStorFS Special Resource can be done using the provided **bin/deploy** script

* Note: The **deploy** script verifys the service account exists with a call to the **bin/createSpecialResource** script which is a no-op if the Service Account already exists

Alternatively you may implement the following three steps in your organizational tooling

## Step 7a. Apply RBAC for AuriStorFS CSI Drivers

The AuriStorFS CSI Controller Pod requires various RBAC Roles, RoleBindings, ClusterRoles, ClusterRoleBindings which must be set prior to deploying the AuriStorFS SpecialResource

	oc apply -n auristorfs-client -f rbac/csi-driver-rbac.yaml

The **[bin/applyRBAC](bin/applyRBAC)** script is also provided which applies the **rbac/csi-driver-rbac.yaml** file to the **auristorfs-client** namespace


## Step 7b: Deploying the AuriStorFS KMOD/CSI SpecialResource ConfigMap

Pre-build ConfigMap objects containing the charts corresponding to the versions referenced  AuriStorFS KMOD/CSI SpecialResource object  (spec.chart.version)  are available under [chartVersions](chartVersions) with the latest version at [chartVersions/latest](chartVersions/latest).  These charts must be considered Read-Only and need be deployed prior to the AuriStorFS KMOD/CSI SpecialResource object.

	oc create -f chartVersions/$CHART_VERSION/auristorfs-client-chart.yaml

The latest version of the AuriStorFS KMOD/CSI SpecialResource charts will be found  at:

    chartVersions\latest\auristorfs-client-chart.yaml

The  **[bin/deploySpecialResourceChart](bin/deploySpecialResourceChart)** script is provided and may be used for deploying the correct version directly from the version tag in the ([auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml)) file

## Step 7c:  Deploy the AuriStorFS KMOD/CSI SpecialResource object

oc create -f auristorfs-client-special-resource.yaml

The  **[bin/deploySpecialResource](bin/deploySpecialResource)** script is provided which deploys the ([auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml)) 

# Mounting AuriStorFS Volumes as OpenShift Volumes
The AuriStorFS CSI Driver enables mounting of AuriStorFS Volumes as Kuberntes Persistent, Dynamic or Ephemeral Volumes.

CSI Examples [can be found here](examples/csi)