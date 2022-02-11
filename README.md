# THIS MULTI-PHASE IS NOT READY

* Waiting for response from Red Hat regarding 'endpoint' and 'volumeattachment' privilege escallation
* 3000-csi-driver.yaml - is currently parked on the root.  It needs to be moved back to templates
* 2075-retry-csi.yaml - is the iterative test version. Currently in 'fairly' good shape.  Needs to be merged into csiDriver repo's chart
* Need to revisit values.yaml vs auristor-client.yaml  (namely )

        charts/auristor-client.yaml
        values.yaml

* Lots of cruft on the root still

        1000-driver-container.yaml
        2050-faux-csi-working.yaml
        2050-faux-csi.yaml
        2075-retry-csi.yaml
        2100-pookie.yaml
        3000-csi-driver.yaml
        bu
        cbu
        charts/auristor-client-0.0.1/templates/2075-retry-csi.yaml
        rbu
* Add validation: https://helm.sh/docs/topics/charts/#schema-files
* Add Defaults as a subchart: https://helm.sh/docs/topics/charts/#schema-files


# Original Docs below... under "The AuriStor SRO Client"

## BUILD

```
echo == Repackage Helm script for deployable yaml objects ===

cd charts

# Create ./auristor-client-0.0.1.tgz
helm package auristor-client-0.0.1

# Copy Helm Chart into ConfigMap (cm) directory
mkdir -p cm
cp auristor-client-0.0.1.tgz cm/auristor-client-0.0.1.tgz

# Create an index file specifying the Helm repo that contains the Helm chart
helm repo index cm --url=cm://auristor-client/auristor-client-chart

```

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




