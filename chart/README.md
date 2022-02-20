
# AuriStorFS KMOD/CSI SpecialResource Version latest

## Location

**Public URL to the AuriStorFS KMOD/CSI SpecialResource ConfigMap for this chart**

[https://github.com/auristor/sro-auristor-client/blob/main/chartVersions/latest/auristorfs-client-chart.yaml](https://github.com/auristor/sro-auristor-client/blob/main/chartVersions/latest/auristorfs-client-chart.yaml)

 (Repo Link: [auristorfs-chart.yaml](auristorfs-chart.yam) )

**Example AuriStorFS KMOD/CSI SpecialResource for this Chart version**

[auristorfs-special-resource.yaml](auristorfs-special-resource.yam)

## Images Used by this Chart

It is highly recommended that these be copied into your organizational Container Registry  

| Container| Container Registry | Image Name | TAG |
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