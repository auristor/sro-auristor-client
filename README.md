# TO DO Items
## For Gerry To do 
- Secrets
- Other than Inline Configmaps and Secretes
- Namespaces other than auristor-xyz (Refactor Build Scripts, create into /build)
- Better handle 'hidden' defaults (ie without needing to show them in values.yaml)

## Questions fro SRO Team
- How to do updates without shutting down cluster
- What happens if pod failing on one node prevents next stage (wait false?)
- How to do rolling updates 


# The AuriStorfs KMOD/CSI Special Resource 

## Background
To access data from AuriStorFS volumes, a kernel module (aka cache manager) must first be installed on the host node.

To mount AuriStorFS Volumes onto Pods running on that node, a AuriStor CSI Driver Pod must first be running on that Node

Additionally, the kernel module must be loaded prior to the starting of the AuriStor CSI driver

The kernel modules and CSI drivers are installed and managed utilizing the [Special Resource Operator (SRO)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html). 
 The Special Resource Operator itself is dependent upon the [Node Feature Discovery Operator (NFD)](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-node-feature-discovery-operator.html) which avails information such as the installed Kernel Version information to the Special Resource Operator from the host machine.

 The Special Resource Operator looks for **SpecialResource Objects** on your cluster.  These SpecialResource Objects encapsulate all resource/vendor-specific information necessary to install the resource prior to scheduling Application Pods onto nodes in your cluster. 

 This Repository contains supporting scripts and objects necessary for creating and deploying an AuriStorFS KMOD/CSI **SpecialResource** Object.

 SRO contains an internal embedded Helm engine. The primary components of a SpecialResource objects is a reference to a Helm Script along with values to be made available to the 

----


The examples in this section use the simple-kmod kernel module to demonstrate how to use the SRO to build and run a driver container. 

In the first example, the SRO image contains a local repository of Helm charts including the templates for deploying the simple-kmod kernel module. 

In this case, a SpecialResource manifest is used to deploy the driver container. 

In the second example, the simple-kmod SpecialResource object points to a ConfigMap object that is created to store the Helm charts.

[Using a ConfigMap](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#deploy-simple-kmod-using-configmap-chart)

---


## Installing OpenShift Special Resource Operator

The Special Resource Operator (SRO) and Node Feature Discovery Operator (NFD) must first be installed on your cluster in order to leverage the AuriStorFS KMOD/CSI SpecialResource. Instructions can be found on the official OpenShift site

- [OpenShift NFD Installation](https://docs.openshift.com/container-platform/4.8/scalability_and_performance/psap-node-feature-discovery-operator.html#installing-the-node-feature-discovery-operator_node-feature-discovery-operator)


- [OpenShift SRO Documentation](https://docs.openshift.com/container-platform/4.9/hardware_enablement/psap-special-resource-operator.html#installing-special-resource-operator)



## DOC

[Presentation on CSI](doc/TheAuriStorfs-SRO-KMOD-SpecialResource-20220207.pdf)

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




