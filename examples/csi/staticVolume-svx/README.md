
# Persistent Volume Example (SCX)

In this example there is a pre-created PersistentVolume specifically for the desired AuriStorFS Volume referenced in the PVC

In the PVC the actual Volume Name is provided 

Scripts To: 
* Run Example (Create Objects)
* Execute Example (Display file contents from running example podample)
* Terminate Example (Delete Objects)

Example Objects 

| Mount Type | Pod | PV |
|---| :--- | :--- | :--- |
| Volume Mount | pod-svx.yaml | pv-svx.yaml |
| Root Mount | pod-svx.yaml | pv-svx.yaml |yaml |

Scripts
| Mount Type | Run Example | Exec in Pod | Terminate Example |
|---| :---: |:---:|:---:|
| Volume Mount | rx | xx | tx |
| Root Mount | rrx | xrx | txr |

