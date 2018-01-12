# copy-carthage-frameworks

If your app includes frameworks built by Carthage, you normally have to add a run script to call `/usr/local/bin/carthage copy-frameworks` and provide input and output files for all of the frameworks to be embedded as described [here]("https://github.com/Carthage/Carthage/blob/master/README.md").

Instead of that, do the following steps: 

- Include the frameworks in Embedded Binaries. Note that this differs from the Carthage docs 
(`carthage copy-frameworks` takes the place of this as described above), but this is the same way you would normally include any frameworks not built by Carthage. 
- Add a Run Script Build Phase *after* the Embed Frameworks Build Phase. Use `/bin/sh` as the Shell and provide the following script:

```
	Carthage/Checkouts/ios-tools/scripts/copy-carthage-frameworks
```

You do not have to provide input and output files to the script. 

## How it works

`copy-carthage-frameworks` will process embedded frameworks according to the following logic:

- For each embedded framework, 
	- If the framework is present in the `Carthage/Build` folder,
  		- If the framework is present in `BUILT_PRODUCTS_DIR`, use that one
  		- Else use the framework from the `Carthage/Build/iOS` folder
- Run `carthage copy-frameworks` and include each framework found above as inputs/outputs. 

This will provide the necessary processing that Carthage requires (stripping simulator architectures, collecting debug symbols, etc.) while also favoring frameworks built in a workspace for debug/development purposes.


