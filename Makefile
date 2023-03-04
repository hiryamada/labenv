rdp:
	bash -eux commands.azcli

azuredeploy.json: main.bicep
	az bicep build -f $^ --outfile $@
