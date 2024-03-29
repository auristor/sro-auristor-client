# Mounting AuriStorFS Volumes using CSI

Below describes the approaches to mounting volumes using CSI along with their respective pros, cons, link to an example, and how to configure.

| <CENTER> Method </CENTER> | <CENTER> Pros </CENTER> | <CENTER> Cons </CENTER> | Example | <CENTER> Configuration Object </CENTER> |
| ------------- | ------------- | ------------- | ------------- |---|
| <CENTER>[Static PersistentVolumes (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes) </CENTER>| <UL>  <LI> Only Administrator Objects (PV) have AuriStorFS volume details/parameters </UL> | <UL>  <LI> PV Objects must be created <LI> One PV necessary for each Namespaces | <CENTER> [Static Example](staticVolume-svx) </CENTER> | <CENTER> PV Object </CENTER> |
| <CENTER>[Dynamic PersistentVolumes (StorageClasses)](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning) </CENTER>| <UL>  <LI> Only Administrator Objects (StorageClass)have AuriStorFS volume details/parameters <LI> A single StorageClass Object can be used for all Namespaces <LI> PV Objects are dynamically created for each PVC by the CSI Driver</UL> | <UL><LI> Must go through the CSI Dr Controller ‘createVolume’ pightly slower Volume Mounting </UL> | <CENTER> [Dynamic Example](dynamicVolume-dvx) </CENTER> |  <CENTER> StorageClass Object </CENTER> |
| <CENTER>[Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes) </CENTER>|<UL>  <LI> No need for PVC, PV or StorageClass Kuberenetes Objects <LI> Slightly faster Volume Mounting</UL> | <UL><LI> Not Administrator Controlled <LI> User’s Pod Objects must have AuriStorFS volume details/parameters</UL> | <CENTER> [Ephemeral Example](ephemeralVolume-evx) </CENTER> |  <CENTER> Pod Object </CENTER> |

## Specifying the AuriStorFS Volume to Mount

Each of the above options involve configuring a different Kubernetes Object. Regardless the following must always be specified:
* CSI Driver Provisioner
	* Always is **```auristorfs.csi.auristor.com```**
* For mounting of specific AuriStor Volume
	* **```mount-type: volume```**
	* AuriStorFS Cell Name
	* AuriStorFS Volume Name
* For mounting of AuriStorFS Root
	* **```mount-type: root```**

### The Kubernetes Object where the Driver/Cell/Volume Values are Specified

| Designated | Static PV <BR>(PV Object) | Dynamic PV <BR>(StorageClass Object) | Ephemeral Volume <BR>(Pod Object) |
|---|---|---|---|
| Specified in | PV Object | StorageClass Object | Pod Object |
| Driver Provisioner Name | ,spec.csi.driver| .provisioner | .spec.volumes.csi.driver  |
| Mount Type | ,spec.csi.volumeAttributes.csi.mount-type| .parameters.mount-type | .spec.volumes.csi.volumeAttributes.mount-type |
| Example | [pv-svx.yaml ](staticVolume-svx/pv-svx.yaml) | [storageClass-dvx.yaml](dynamicVolume-dvx/storageClass-dvx.yaml) | [pod-evx.yaml](ephemeralVolume-evx/pod-evx.yaml) |

Mount Type **```volume```** requres fileds to specify the volume and cell names:
| Designated | Static PV <BR>(PV Object) | Dynamic PV <BR>(StorageClass Object) | Ephemeral Volume <BR>(Pod Object) |
|---|---|---|---|
| AuriStorFS Volume Name | ,spec.csi.volumeAttributes.csi.volume-name| .parameters.volume-name | .spec.volumes.csi.volumeAttributes.volume-name |
| AuriStorFS Cell Name |,spec.csi.volumeAttributes.csi.cell-name| .parameters.cell-name | .spec.volumes.csi.volumeAttributes.volume-name |



