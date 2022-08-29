# RBAC for the AuriStorFS CSI Driver

Prior to running the CSI Driver, a Service Account 'auristorfs-csi' in the SRO Namespace must be created with appropriate RBAC associated with it.  

* **csi-driver-service-account.yaml**: Service Account 
* **csi-driver-rbac.yaml**: Various Roles, RoleBindings, ClusterRoles, ClusterRoleBindings used by the AuriStorFS Controller Pod

The [bin/applyRBAC](../bin/applyRBAC) script may be used to achieve this when run under an account with sufficent permissions.