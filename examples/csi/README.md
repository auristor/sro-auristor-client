# Mounting AuriStorFS Volumes using CSI

  

Below describes the approaches to mounting volumes using CSI along with their respective pros, cons and an example

  
  

| <CENTER> Method </CENTER> | <CENTER> Pros </CENTER> | <CENTER> Cons </CENTER> | Example |
| ------------- | ------------- | ------------- | ------------- |
| <CENTER>[Static PersistentVolumes (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes) </CENTER>| <UL>  <LI> Only Administrator Objects (PV) have AuriStorFS volume details/parameters </UL> | <UL>  <LI> PV Objects must be created <LI> One PV necessary for each Namespaces | <CENTER> [Static Example](persistentVolume-pvx) </CENTER> |
| <CENTER>[Dynamic PersistentVolumes (StorageClasses)](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning) </CENTER>| <UL>  <LI> Only Administrator Objects (StorageClass)have AuriStorFS volume details/parameters <LI> A single StorageClass Object can be u all Namespaces <LI> PV Objects are dynamically createdch PVC by the CSI Driver | <UL><LI> Must go through the CSI Dr Controller ‘createVolume’ pightly slower Volume Mounting | <CENTER> [Dynamic Example](dynamicVolume-dvx) </CENTER> |
| <CENTER>[Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes) </CENTER>|<UL>  <LI> No need for PVC, PV or StorageClass Kuberenetes Objects <LI> Slightly faster Volume Mounting | <UL><LI> No need for PVC, PV or StorageClass Kuberenetes Objects <LI> Slightly faster Volume Mounting | <CENTER> [Ephemeral Example](ephemeralVolume-evx) </CENTER> |