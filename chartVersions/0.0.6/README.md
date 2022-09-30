
# AuriStorFS KMOD/CSI Special Resource Chart

The [buildSpecialResourceChart](../bin/buildSpecialResourceChart) script creates a ConfigMap corresponding to this chart and stores it at the current Chart version location corresponding to the .spec.chart.version field in [auristorfs-client-chart.yaml](../auristorfs-client-chart.yaml)

## CSI SideCar Images Used by this Chart

Specific Container Images, particularly for use by the AuriStorFS CSI Driver, are referenced that are required by this version of the Chart.

It is highly recommended that these container Images be copied into your organizational Container Registry  

| Container| Container Registry | Image Name | TAG |
|-------|-----|---|--|
| External Provisioner | k8s.gcr.io/sig-storage |csi-provisioner | v3.2.1 |
| External Attacher | k8s.gcr.io/sig-storage |csi-attacher | v3.5.0 |
| Node Driver Registrar | k8s.gcr.io/sig-storage |csi-node-driver-registrar | v2.5.1 |
| Liveness Probe | k8s.gcr.io/sig-storage |livenessprobe | v2.7.0 |

## Fully Qualified Container Images  

	k8s.gcr.io/sig-storage/csi-attacher:v3.5.0

	k8s.gcr.io/sig-storage/csi-provisioner:v3.2.1

	k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.1

	k8s.gcr.io/sig-storage/livenessprobe:v2.7.0
