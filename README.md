
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

# <a name="rolling-updates"></A> AuriStorFS KMOD/CSI SpecialResource Versioning and Rolling Updates

AuriStor periodically releases new versions of the AuriStorFS Kernel Module and AuriStorFS CSI Drivers which can be configured for installation by the AuriStorFS SpecialResource.  

In order to support heterogenous versions concurrently in the Cluster, the SpecialResource configuration may include a node selector.  This allows for multiple AuriStorFS SpecialResources to be active at the same time, each targeting a different subset of nodes. Each of these  AuriStorFS SpecialResources are deployed in separate namespaces. This is particularly useful when providing a phased upgrade.

For example you might want two different versions deployed, differenciated by a node-selector ```auristor.com/auristorfs-group``` with nodes labled ```auristor.com/auristorfs-group-1``` and ```auristor.com/auristorfs-group-2```

You would then need to have two corresponding SpecialResources

* auristorfs-client-special-resource-1.yaml
	* with nodeSelector: { auristor.com/auristorfs-group: auristorfs-group-1 } <BR><BR>
* auristorfs-client-special-resource-2.yaml
	* with nodeSelector: { auristor.com/auristorfs-group: auristorfs-group-2 }


Details for the Configuration of the AuriStorFS SpecialResource can be found under the [AuriStorFS KMOD/CSI Special Resource Configuration](configuringSpecialResource.md)

# Using the AuriStorFS KMOD/CSI SpecialResource

The following Steps are all that is required to leverage AuriStorFS volumes in your OpenShift Cluster

* [Install the Special Resource Operator and Node Discovery Operators](#install-sro-nfd)

* Clone the branch release version of this repository.

* [Create a AuriStorFS KMOD/CSI SpecialResource object YAML file for the SpecialResource](#creating-sr)

* [Copy any of the Container Images referenced in the SpecialResource configuration onto your private Registry (recommended)](#copying-images)

* [Prepare ConfigMaps and Secrets containing configuration and keys for your deployment](#configmaps)

* [Deploy the Special Resource](#deploying)

* Repeat steps 3-6 for each AuriStorFS SpecialResource

# <a name="quick-start"></A> Quick-Start Lab:  Deploying the AuriStorFS SpecialResource


## User Provided Files

First Create user-defined configuration files:
- Create YAML File containing SpecialResource
	- For example a file named, ```my-auristorfs-sr.yaml``
	- see details below under 
	[Create a AuriStorFS KMOD/CSI SpecialResource object YAML file for the SpecialResource](#creating-sr)
- Create scripts for deploying and undeploying any supporting ConfigMap and Secrets
	- For example files named, ```create-my-sr-configmaps``` and ```delete-my-sr-configmaps```
	- see details below under [Prepare ConfigMaps and Secrets containing configuration and keys for your deployment](#configmaps)

## Clone the Repository

Clone the version of the AuriStorSpecialResource specified in my-auristorfs-sr.yaml` 
	
```bash
	$ clone https://github.com/auristor/sro-auristor-client.git
	$ cd sro-auristor-client
	$ git checkout release-0.0.6   ## Use the version my-auristorfs-sr.yaml
	$ cd sro-auristor-client
```

## Deploy AuriStorFS SpecialResource

Assuming that you have placed your configuration files under /usr/home/me, deploy your SpecialResource with

```bash
	$ cd sro-auristor-client

	$ source bin/setupEnvironment \
	       /usr/home/me/my-auristorfs-sr.yaml 			\
		   /usr/home/me/create-my-sr-configmaps.yaml 	\
		   /usr/home/me/delete-my-sr-configmaps.yaml

	$ bin/deploy
```
## Undeploying AuriStorFS SpecialResource

```bash
	$ bin/udeploy
```

* **Note:** it is critical that there are no Pods running on the nodes actively using any AuriStorFS volume (via CSI) prior to undeploying the SpecialResource. Otherwise the node will be rendered unstable and will require rebooting.

## IMPORTANT NOTES

* The above steps assume that 
	* The **OpenShift Special Resource Operator** and **OpenShift Node Feature Discovery** have been installed
	* If you are using a private registry, all container images referenced in the SpecialResource configuration file been downloaded

* Re-emphasising it is critical that there are no Pods running on the nodes actively using any AuriStorFS volume (via CSI) prior to undeploying the SpecialResource. Otherwise the node will be rendered unstable and will require rebooting.

* Addiitional explanation and details of these quick-start lab steps can be found below



# <a name="install-sro-nfd"></a>Installing SRO and NFD Operators

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

 - [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)

- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)

**Note**: There is an option to install these in a single namespace or all namespaces.  We recommend installing in a single namespace


# <a name="creating-sr"></a>Creating Special Resource

 Whether you are deploying the same SpecialResource to all nodes in the cluster or are using distict SpecialResources targeting groupings of nodes, you must create a SpecialResource YAML file for each SpecialResource.

 Each Special Resource must have a unique name, with full instructions for configuring the SpecialResource found in [AuriStorFS KMOD/CSI Special Resource Configuration](configuringSpecialResource.md)

 This SpecialResource object,  [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml), contains all necessary configuration data to manage the AuriStorFS kernel module and CSI Driver.  

# <a name="copying-images"></a>Copying Container Images to Private Registry

It is Strongly Recommended that you copy all Container Images used by the AuriStorFS KMOD/CSI SpecialResource into an organizational private container registry.

**AuristorFS KMOD DriverContainer Image**

DriverContainer Images must be available for each of the Linux kernel versions that may be running on your OpenShift Cluster for the corresponding DriverContainer Version.

* **Registry**: specified in Specified in the field **.spec.set.kmodDriverContainer.auristorRegistry**
* **DriverContainer Version**: specified in Specified in the field **.spec.set.kmodDriverContainer.auristorKmodVersion**
* **Template For Container Image**: <BR><BR>&nbsp;&nbsp;&nbsp;
**&lt;kmodDriverContainer.image.auristorRegistry&gt;**/auristor-kmod-**&lt;kmodDriverContainer.image.auristorKmodVersion&gt;**:***&lt;linux kernel version&gt;***

Note the encoding of the tag for the respective ***&lt;linux kernel version&gt;***.  For example for an OpenShift Node with:

```
	$ uname -r
	4.18.0-305.49.1.el8_4.x86_64
```

The corresponding DriverContainer Image tag for the ***&lt;linux kernel version&gt;*** would be 
```
4.18.0-305.el8.x86_64
```
A fully qualified example for the AuriStor DriverContainer verison 2021.05-20 and for the Linux kernel 4.18.0-305.49.1.el8_4.x86_64 :
```
    ghcr.io/auristor/auristor-kmod-2021.05-20:4.18.0-305.el8.x86_64
```

---
**AuristorFS CSI Driver Image**

* **Registry**: specified in Specified in the field **.spec.set.csiDriver.auristorRegistry**
* **Version**: specified in Specified in the field **.spec.set.csiDriver.auristorCsiVersion**
* **Template For Container Image**: <BR><BR>&nbsp;&nbsp;&nbsp;
**&lt;csiDriver.image.auristorRegistry&gt;**/auristorfs-csi:**&lt;csiDriver.image.auristorCsiVersion&gt;**


Example CSI Driver Container Image for CSI Driver Version 2022.02-2
```
    ghcr.io/auristor/auristorfs-csi:2022.02-2
```
---

**AuriStorFS CSI Sidecar Images**

The CSI Driver Pods leverage sidecar containers images provided by the Kubernetes SigStorage.   

The specific sidecars and sidecar container image tags are embedded in the AuriStorFS KMOD/CSI SpecialResource chart version

Detailed information on all required CSI Sidecar container images can be found in the [Chart README.md](chart/README.md)

For Example, from the documentation for [chart version 0.0.5](chartVersions/0.0.5)
```
	k8s.gcr.io/sig-storage/csi-attacher:v3.5.0

	k8s.gcr.io/sig-storage/csi-provisioner:v3.2.1

	k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.1

	k8s.gcr.io/sig-storage/livenessprobe:v2.7.0
```

## <a name="configmaps"></a>Preparing ConfigMaps and Secrets containing configuration and keys for your deployment
ConfigMaps and Secrets must be created and deployed into your cluster prior to Initialization of the Node. Details about these ConfigMaps and Secrets are found in the [AuriStorFS KMOD/CSI Special Resource Configuration](configuringSpecialResource) document.

It is necessary to create a script to create these supporting ConfigMaps and Secrets along with a script to destroy them.  The folowing are provided as examples only:

* [examples/volumeMaps/createMaps](examples/volumeMaps/createMaps)
* [examples/volumeMaps/deleteMaps](examples/volumeMaps/deleteMaps)


These are provided as examples because your configuration and keytabs will be specific to your organization/installation.  They do NOT correspond to real-life values.


# <a name="deploying"></a>Deploying the AuriStorFS Special Resource

The deployment, undeployment, or reployment of the Special Resources can be accomplished by 


| Script | Description |
|---|--- |
| bin/redeploy | undeploy followed by deploy an AuriStor SpecialResource into the cluster
| bin/deploy | Deploy an AuriStor SpecialResource into the cluster |
| bin/undeploy | Removes an AuriStor SpecialResource from the cluster |

None of these scripts take any command line arguments, however prior to deploying or undeploying a SpecialResoure, certain environment variables must be set using the privided ```bin/setupEnvironment``` command

```bash
$ source bin/setupEnvironment [SpecialResource YAML] [Create Map Script Name] [Delete Map Script Name]
```

Where:
- ```[SpecialResource YAML]``` is the location of the SpecialResource File
- ``` [Create Map Script Name]``` the name of a provided script that deploys any required ConfigMaps or Secrets referenced in the ```[SpecialResource YAML]```
- ```[Delete Map Script Name]``` the name of a provided script that deletes the ConfigMaps or Secrets created by the ```[Create Map Script Name]```

Additional details on these scripts can be found in the [SRO Build and Deployment Scripts](bin/README.md) document


# Prior to Updating SpecialResources 

All Pods must with AuriStor volumes mounted must be evicted from Nodes prior to updating the AuriStorFS Special Resource scoped to that node.  This must be done before removing (or updating) the AuriStorFS Special Resource because attempting to remove ANY kernel module that is in use will result in an unstable kernel.  If this occurs, you must reboot the node.  You can know if the AuriStorFS kernel module is loaded on any node by running 

	lsmod | grep yfs

This can be run on the node or any pod running on that node which has lsmod.

# <a name="mounting"></A> Mounting AuriStorFS Volumes as OpenShift Volumes using the AuriStorFS CSI Driver
The AuriStorFS CSI Driver enables mounting of AuriStorFS Volumes as Kubernetes Persistent, Dynamic or Ephemeral Volumes.

Specific volumes or the global root may be mounted to Pods.  Two mount-types may configured in your application YAML:

*  **```mount-type: volume```** -  Mounts a specific volume from a specific cell to a volume mount point in a Pod
* **```mount-type: root```** - For mounting of AuriStorFS Root to a volume mount point in a Pod

Additional details can be found in the [Mounting AuriStorFS Volumes using CSI](examples/csi/README.md) document

Examples can be found

* [Dynamic Volume Examples](examples/csi/dynamicVolume-dvx) 
* [Static Volume Examples](examples/csi/staticVolume-svx) 
* [Ephemeral Volume Examples](examples/csi/ephemeralVolume-evx) 

