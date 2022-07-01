# MapVolume ConfigMaps and Secrets

ConfigMaps and Secrets are used by the CSI Driver to populate configuration files in directories as designated in [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml)

These samples corresponding to the volumeMap section in [auristorfs-client-special-resource.yaml](auristorfs-client-special-resource.yaml)


	      mapVolumes:         
	      
	      - label: etc-yfs
	         target: /etc/yfs
	         configMap:
	            configMapName: etc-yfs
	            
	      - label: usr-share-yfs
	         target: /usr/share/yfs
	         configMap:
	            configMapName: usr-share-yfs
	            
	      - label: etc-yfs-keytabs
	         target: /etc/yfs-keytabs
	         secret:
	            secretName: etc-yfs-keytabs


**Note**: The mapVolume ConfigMaps and Secrets must be in the same namespace as the AuriStorFS KMOD/CSI SpecialResource, **aursitorfs-client**

Sample Scripts are provided here to create/deploy the ConfigMap and Secrets


| Script | Description |
|--|--|
| [createMaps](createMaps) | Creates configmaps and secrets directly from files |
| [deleteMaps](deleteMaps) | Delete these configmaps and secrets |

