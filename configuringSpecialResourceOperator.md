




It is important to verify that the SRO ClusterRole Object  has been configured with permissions required for CSI.

Typically the name of the SRO ClusterRole Object 
Had to add to clusterrole openshift-special-resource-operator.4.9.0-2022082417-7f85885c95

```bash
    - apiGroups: ["storage.k8s.io"]
      resources: ["csistoragecapacities"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups:
      - storage.k8s.io
      resources:
      - volumeattachments/status
      verbs:
      - patch
```
