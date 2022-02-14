

# The AuriStorfs KMOD/CSI Special Resource 

## Background
To access files stored in AuriStorFS volumes, a kernel module (aka cache manager) must first be installed on the host node.

To mount AuriStorFS Volumes onto Pods running on that node, the AuriStor CSI Driver Pod must first be running on that Node

Additionally, the kernel module must be loaded prior to the starting of the AuriStor CSI driver

The orchestration of the installing and managing of the kernel modules and CSI drivers are accomplished using the [Special Resource Operator (SRO)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html).  SRO acts as a state machine to help bring an OpenShift node up to compliance for a particular resource/vendor-specific Special Resource.  

SRO was designed to guarantee that the proper kernel module is installed for the resource.  As such, SRO is dependent upon the [Node Feature Discovery Operator (NFD)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-node-feature-discovery-operator.html) which avails host information, such as the current Kernel Version, to the SRO.

 The Special Resource Operator responds to the presence of **SpecialResource Objects** on your cluster.  These SpecialResource Objects encapsulate all resource/vendor-specific information necessary to install the resource prior to scheduling Application Pods onto nodes in your cluster. 

 This Repository contains supporting scripts and objects necessary for creating and deploying the **AuriStorFS KMOD/CSI SpecialResource** Object.




## Installing OpenShift Special Resource Operator

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

- [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)


- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)

## AuriStor KMOD/CSI Special Resource Configuration


 The single AuriStorFS KMOD/CSI SpecialResource configuration file is [charts/auristor-client.yaml](charts/auristor-client.yaml)   

SRO contains an internaly embedded Helm engine. The SpecialResource objects encompases a reference to a Helm Scripts along with values to be made available to the internal Helm engine (along with additional information provided  by the NFD Operator)
 
The 'set' section in [charts/auristor-client.yaml](charts/auristor-client.yaml)   provides 'Values' for the Helm Chart.  These fields, along with additional runtime fields provided by NFD, are merged and provided as the 'Values' to the Special Resource Helm Charts

AuriStorFS KMOD/SRO Configuration file: [charts/auristor-client.yaml](charts/auristor-client.yaml)


	   apiVersion: sro.openshift.io/v1beta1
	   kind: SpecialResource
	   metadata:
	   name: auristor-client
	   spec:
	   namespace: auristorfs-client

	   chart:
	      name: auristor-client
	      version: 2022.02.1
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
            auristorCsiVersion: 2022-02.1
            csiDriverImagePullPolicy: Always
            k8sSigStorageRegistry: k8s.gcr.io/sig-storage
            k8sSigStorageImagePullPolicy: Always

         cacheManager:       ###  Cache Manager Values
            defaultCacheManager: auristor

         logging:
            logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)


### kmodDriverContainer  - Driver Container Configuration
-   **image:**
	-   **auristorRegistry**: The Container Registry for the Driver Container Images
	-   **auristorKmodVersion**: The AuriStor kernel module version  
-   **yfsCache**: The AuriStor kernel module version 
-   **mapVolumes**: Any ConfigMap or Secret can be mounted as configurations for the cache manager
	-    **label**: Used within the Pod to associate volumeMounts with volumes
    - **target**: Path in the Driver Container for the map files
    - **configMap.configMapName**: ConfigMap to associate with this entry
    - **secret.secretName**: Secret to associate with this entry


### csiDriver - CSI Driver Configuration

-   **image:**
	-  **auristorRegistry**: The Container Registry for the AuriStorFS CSI Container Images
	-   **auristorCsiVersion**: The AuriStor CSI Driver version
	-   **csiDriverImagePullPolicy**: The AuriStor CSI Driver Container Image Pull Policy
	-   **k8sSigStorageRegistry**: he Container Registry for the Kubernetes SigStorage CSI Sidecar Container Images
	-   **.csiDriverImagePullPolicy**: The CSI Sidecar Container Image Pull Policy 
-   **cacheManager:**
	- **defaultCacheManager**: "auristor" or "kafs"
-   **logging:**
	- **logLevel**: DEBUG, INFO, WARNING, ERROR, or FATAL



## Preparing to deploy the AuriStorFS KMOD/CSI Special Resource

### Configuring the Cache Manager / DriverContainer
- Configuration files are made available to Driver Container via Kubernetes ConfigMap and Secrets objects that are then expanded into directories inside of the cache-manager/driver container  (yfs-client.conf, cellservdb.conf, keytabs, etc)  
	- **NOTE**: These directories may not be nested. 
- - [Example files](examples) are provided along with a sample scripts for creating/deleting sample ConfigMap and Secret objects
- It is highly recommended that kmodDriverContainer images are copied from the the ```ghcr.io/auristor``` Container Registry to your  organizational (internal) container registry from.

## Deploying the AuriStor KMOD/CSI SpecialResource
Deploying the AuriStor KMOD/CSI SpecialResource will most likely be integrated into your CI/CD pipeline.   

The KMOD and CSI containers are deploy in the ***auristorfs-client*** namespace. It is assumed that this namespace has been created prior to deploying the SpecialResources

	oc create namespace auristor-client

The following scripts are provided to help understand the steps to build and deploy the SpecialResource

### buildSpecialResource

	RELEASE_VERSION=${RELEASE_VERSION:-"2022.02.1"}

	cd charts
	
	# Create auristor-client-$RELEASE_VERSION.tgz
	helm package auristor-client-$RELEASE_VERSION		

	mkdir -p cm
	# Copy Helm Chart into ConfigMap (cm) directory
	mv auristor-client-$RELEASE_VERSION.tgz cm/auristor-client-$RELEASE_VERSION.tgz 
	
	# Create an index file specifying the Helm repo that contains the Helm chart
	helm repo index cm --url=cm://auristorfs-client/auristor-client-chart -n auristorfs-client 

### deploy
	RELEASE_VERSION=${RELEASE_VERSION:-"2022.02.1"}
	
	oc get namespace auristorfs-client >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo ERROR: Namespace does not exists, not deploying SpecialResource
		exit 1
	fi

	oc get namespace auristorfs-client >> /dev/null

	oc create -n auristorfs-client cm auristor-client-chart --from-file=charts/cm/index.yaml --from-file=charts/cm/auristor-client-$RELEASE_VERSION.tgz 
	oc create -f charts/auristor-client.yaml
	
###  undeploy

	oc delete specialresource auristor-client --ignore-not-found=true
	oc delete cm -n auristorfs-client auristor-client-chart --ignore-not-found=true


## Understanding the KMOD/CSI Container Images

It is strongly recommended that all container images are copied from their public location into an interal private registtry.  The following sections will help undertstand the conventions used for the various container images found in the respective Helm Templates


### Driver Containers Image ( 1000-driver-container.yaml )

- **Repository Field:** kmodDriverContainer.auristorRegistry
- **Image Version:**  kmodDriverContainer.auristorKmodVersion
- Template Format:  ***[auristorRegistry]/auristor-kmod-[auristorKmodVersion]:[kernel.arch]***

   | Type | Image Name | TAG |
   |-------|-----|---|
   | AuriStorFS KMOD | auristor-kmod-2021.05-15 | 4.18.0-305.el8.x86_64


### CSI Driver Container Image  (2000-csi-driver.yaml)

- **Repository Field:** ***csiDriver.image.auristorRegistry***
- **Image Version:**  ***csiDriver.image.auristorCsiVersion***
- Template Format:  ***[auristorRegistry]/auristorfs-csi:[auristorCsiVersion]***

###

   | Type | Image Name | TAG |
   |-------|-----|---|
   | AuristorFS CSI Driver | auristorfs-csi | 2022-02.1 |



### CSI Driver Sidecar Containers Images  (2000-csi-driver.yaml)
   **Repository Field:** csiDriver.image.k8sSigStorageRegistry
   - Template Format:  ***[k8sSigStorageRegistry]/[type]:[type-tag]***

   | Type | Image Name | TAG |
   |-------|-----|---|
   | External Provisioner | csi-provisioner | v3.1.0 |
   | External Attacher | csi-attacher | v3.4.0 |
   | Node Driver Registrar | csi-node-driver-registrar | v2.4.0 |
   | Liveness Probe | livenessprobe | v2.5.0 |



## Using The AuriStor CSI Driver

[See Separate README.md](docs/csi)
