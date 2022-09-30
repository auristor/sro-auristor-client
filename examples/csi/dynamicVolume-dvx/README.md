
# Dynamic Volume Example (SCX)

In this example there is Storage Class specifically for the desired AuriStorFS Volume referenced in the PVC

Note that the Volume Name is generated


Scripts To: 
* Run Example (Create Objects)
* Execute Example (Display file contents from running example podample)
* Terminate Example (Delete Objects)

Example Objects 

| Mount Type | Pod | PVC | Storage Class |
|---| :--- | :--- | :--- |
| Volume Mount | pod-dvx.yaml | pvc-dvx.yaml | storageClass-dvx.yaml |
| Root Mount | pod-dvx.yaml | pvc-dvx-root.yaml | storageClass-dvx-root.yaml |

Scripts
| Mount Type | Run Example | Exec in Pod | Terminate Example |
|---| :---: |:---:|:---:|
| Volume Mount | rx | xx | tx |
| Root Mount | rrx | xrx | txr |


