
# The AuriStorfs KMOD/CSI Special Resource 

## Background
To access data from AuriStorFS volumes, a kernel module (aka cache manager) must first be installed on the host node.

To mount AuriStorFS Volumes onto Pods running on that node, a AuriStor CSI Driver Pod must first be running on that Node

Additionally, the kernel module must be loaded prior to the starting of the AuriStor CSI driver

The kernel modules and CSI drivers are installed and managed utilizing the [Special Resource Operator (SRO)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html). 
 The Special Resource Operator itself is dependent upon the [Node Feature Discovery Operator (NFD)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-node-feature-discovery-operator.html) which avails information such as the installed Kernel Version information to the Special Resource Operator from the host machine.

 The Special Resource Operator looks for **SpecialResource Objects** on your cluster.  These SpecialResource Objects encapsulate all resource/vendor-specific information necessary to install the resource prior to scheduling Application Pods onto nodes in your cluster. 

 This Repository contains supporting scripts and objects necessary for creating and deploying an AuriStorFS KMOD/CSI **SpecialResource** Object.

 SRO contains an internal embedded Helm engine. The primary components of a SpecialResource objects is a reference to a Helm Script along with values to be made available to the 



## Installing OpenShift Special Resource Operator

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

- [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)


- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)

## Configuring the AuriStor KMOD/CSI Special Resource

The AuriStorFS KMOD/CSI Special Resource configuration is found in  [charts/auristor-client.yaml](charts/auristor-client.yaml)  

The Special Resource Operator has an embedded helm engine which generates then 'helm Values' by integrating information provided by the NFD Operator along with Special Resource specific values.  The 'Values' sent to this internal engine are synthesized by integrating NFD values along with values found in the 'set' section of the Special Resource Object. There is a separate block of values for the **kmodDriverContainer** and the **csiDriver** 

AuriStorFS KMOD/SRO Configuration file: [charts/auristor-client.yaml](charts/auristor-client.yaml)

      apiVersion: sro.openshift.io/v1beta1
      kind: SpecialResource
      metadata:
      name: auristor-client
      spec:
      namespace: auristorfs-client

      chart:
      name: auristor-client
      version: 0.0.1
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
            auristorRegistry: "ghcr.io/auristor"
            auristorKmodVersion: "2021.05-15"
            yfsCache: /var/cache/yfs            ## Host Path to the local cache

            mapVolumes:
               ### SEE BELOW FOR DETAILS ON THE MAP VOLUMES ###

         csiDriver:
            image:       ###   Registry and Version Values
               auristorRegistry: ghcr.io/auristor
               auristorCsiVersion: 2022-02.1
               csiDriverImagePullPolicy: Always
               k8sSigStorageRegistry: k8s.gcr.io/sig-storage
               k8sSigStorageImagePullPolicy: Always

            cacheManager:     ###  Cache Manager Values
               defaultCacheManager: auristor    # (auristor or kafs)

            logging:
               logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)


### KMOD Driver Container Configuration

The KMOD Driver Container configurations consists of specifying:
- The Container Registry for the Driver Container Images (the **auristorRegistry** field)
- The AuriStor kernel module version (the **auristorKmodVersion** field)
- The location of the AuriStorFS cache (the **yfsCache** field)
- The location and contents of AuriStorFS configuration files (the **mapVolumes** field)



### CSI Driver Configuration

The CSI Driver configurations consists of specifying:
- The Container Registry for the AuriStorFS CSI Container Images (the **image.auristorRegistry** field)
- The AuriStor CSI Driver version (the **image.auristorCsiVersion** field)
- The AuriStor CSI Driver Container Image Pull Policy (the **image.csiDriverImagePullPolicy** field)
- The Container Registry for the Kubernetes SigStorage CSI Sidecar Container Images (the **image.k8sSigStorageRegistry** field)
- The CSI Sidecar Container Image Pull Policy (the **image.csiDriverImagePullPolicy** field)


## Deploying the AuriStorFS KMOD/SRO Special Resource

## Deploying the AuriStorFS KMOD/CSI Special Resource

## Using The AuriStor CSI Driver

[See Separate README.md](docs/csi)









