 # AuriStorFS KMOD/CSI SpecialResource Version 0.0.2
 
## Location
**Direct Link to AuriStorFS KMOD/CSI SpecialResource ConfigMap for this chart**

[https://github.com/auristor/sro-auristor-client/blob/main/charts/auristor-client-2022.02.1/Chart.yaml](https://github.com/auristor/sro-auristor-client/blob/main/charts/auristor-client-2022.02.1/Chart.yaml)

**Repo Link to AuriStorFS KMOD/CSI SpecialResource ConfigMap for this chart** 

[chartVersions\0.0.2\auristorfs-chart.yaml](..\..\chartVersions\0.0.2\auristorfs-chart.yam)

**Example  AuriStorFS KMOD/CSI SpecialResource** 

[chartVersions\0.0.2\auristorfs-special-resource.yaml](..\..\chartVersions\0.0.2\auristorfs-special-resource.yam)

## Images Used by this Chart 

| Type | Container Registry | Image Name | TAG |
|-------|-----|---|--|
| AuristorFS CSI Driver | auristorfs-csi | auristorfs-csi | 2022-02.2 |
| External Provisioner | k8s.gcr.io/sig-storage |csi-provisioner | v3.1.0 |
| External Attacher | k8s.gcr.io/sig-storage |csi-attacher | v3.4.0 |
| Node Driver Registrar | k8s.gcr.io/sig-storage |csi-node-driver-registrar | v2.4.0 |
| Liveness Probe | k8s.gcr.io/sig-storage |livenessprobe | v2.5.0 |

## Fully Qualified Container Images


	ghcr.io/auristor/auristorfs-csi:2022-02.2

	k8s.gcr.io/sig-storage/csi-attacher:v3.4.0

	k8s.gcr.io/sig-storage/csi-provisioner:v3.1.0

	k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.4.0
	
	k8s.gcr.io/sig-storage/livenessprobe:v2.5.0
