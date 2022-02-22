# AuriStorFS CSI Driver (Stand-Alone)

The AuriStorFS CSI Driver can be deployed in either of the below manners:

| Deployment Type | asta |
|---|---|
| [Stand Alone](./CSI-Standalone/README.md) | Assumes that the AuriStorFS or kAFS kernel modules are already installed on the node <BR>(Described here) | 
| [SRO Deployment](../../README.md) | The AuriStorFS Kernel Module is deployed along with the CSI Driver <BR>(Currently only available for OpenShift) |

## Deploying AuriStor CSI Stand-Alone

The AuriStor CSI Driver is deployed using Helm.  Below are the required steps

## Step 1: Creating the Namespace for the AuriStorFS Client

    apiVersion: v1
    kind: Namespace
    metadata:    
      name: auristorfs-client

## Step 2: Configure the AuriStorFS CSI Client

The csiDriver section of the Helm [values.yaml](values.yaml) file is configured in the same manner as documentented the corresponding section in Step 3 of the [SRO Deployment](../../README.md) 

 [values.yaml](values.yaml) 

	specialresource:
	  metadata:
	    name: auristorfs
	  spec:
	    namespace: auristorfs-client
	    
	groupName:
	  csiDriver: csi-driver   

	runArgs:
	  platform: "kubernetes"  

	csiDriver:
	  image:       ###   Registry and Version Values
	    auristorRegistry: ghcr.io/auristor
	    auristorCsiVersion: 2022.02-2
	    csiDriverImagePullPolicy: Always
	    k8sSigStorageRegistry: k8s.gcr.io/sig-storage
	    k8sSigStorageImagePullPolicy: Always

	  cacheManager:       ###  Cache Manager Values
	    defaultCacheManager: auristor
	    afsRootDir: "/afs"  ##  AFS Root on node

	  logging:
	    logLevel: INFO  # (DEBUG, INFO, WARNING, ERROR, or FATAL)


## Step 3: Deploy the AuriStorFS CSI Helm Chart

The AuriStorFS CSI Driver is deployed using HELM.  An examp

	helm install -n auristorfs-client auristorfs-csi-driver .


# Mounting AuriStorFS Volumes as Kubernetes Volumes
The AuriStorFS CSI Driver enables mounting of AuriStorFS Volumes as Kuberntes Persistent, Dynamic or Ephemeral Volumes.

CSI Examples [can be found here](../csi)