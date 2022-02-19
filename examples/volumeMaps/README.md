# MapVolume ConfigMaps and Secrets

All Directories containing AuriStorFS cache manager configuration files are provided to the AuriTorFS KMOD/CSI SpecialResource as ConfigMap and Secrets


**Note**: The mapVolume ConfigMaps and Secrets must be in the same namespace as the AuriStorFS KMOD/CSI SpecialResource, **aursitorfs-client**

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

Sample Scripts have been provided to create/deploy the ConfigMap and Secrets


| Script | Description |
|--|--|
| createMaps | Creates configmaps and secrets directly from files |
| deleteMaps | delete these configmaps and secrets |

