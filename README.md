# The AuriStor SRO Client

The AuriStor SRO Client can be built and deployed/undeployed with these scripts (recommended)
- [deploy](deploy)
- [undeploy](undeploy)


Manual Deployment of the SRO can be done with:


      $ oc create -f auristor-client-0.1.1
        



If (for example during debugging) you wish to use a different  kvc-auristor-client repo, change the driverContainer source repo (git:) and/or branch (ref:) in the 'driverContainer' section:

      driverContainer:
        source:
            git:
                uri: "https://github.com/GerrySeidman/kvc-auristor-client.git"
                ref: "fixing-repo-pull-failure"

This change can be done to eisther either/both to the SpecialResource yaml file(s):

- [charts/cm/auristor-client-from-configmap.yaml](charts/cm/auristor-client-from-configmap.yaml)
- [charts/auristor-client-0.0.1/auristor-client.yaml](charts/auristor-client-0.0.1/auristor-client.yaml)

Documentation on Special Resource Operators can be found here:

- [RedHat OpenShift Chapter 3.3: Using the Special Resource Operator](https://access.redhat.com/documentation/si-lk/openshift_container_platform/4.9/html/specialized_hardware_and_driver_enablement/special-resource-operator)
- [OKD - Special Resource Operator](https://docs.okd.io/latest/hardware_enablement/psap-special-resource-operator.html)




