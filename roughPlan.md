# Building an API with powershell functions and azure tables

## Set up the resources in Azure

- Create the azure function
- Create an azure table in the storage account

## Set up the project and local environment

- Create new folder, init with git (or start new github repo and clone locally)
```
https://repo.new
```
- Set up dev container, reopen as container
- Look at devcontainer / dockerfile
- All available docker images: https://hub.docker.com/_/microsoft-azure-functions-powershell
- extra credit: if you want to set the name of the container:
```
"runArgs": ["--name", "PSCONFEU2022_devContainer"]
``` 
- Note that PowerShell is already out of date

## Create function app

- Choose PowerShell as our function app language
- Set your trigger to HTTP (for this example)
- Auth is "function"
- Let's spin up our function app locally and make sure it works

## Dive into request data

- Add some write-backs to show what data we get

```PowerShell
$MagnifyingGlass = @{
    Request = $($Request | ConvertTo-Json -Depth 20)
    TriggerMetadata = $($TriggerMetadata | ConvertTo-Json -Depth 20)
}
```
- Look at the request data and the triggermetadata
- Add queries to the URL
```
irm -Method Get http://localhost:7071/api/ExampleFunction?QueryName=Ben
```
- Add body params to the request
```
irm -Method Get http://localhost:7071/api/ExampleFunction -Body $(@{"BodyName" = "Ben"} | ConvertTo-Json)
```
- Change the request to a post
```
irm -Method Post http://localhost:7071/api/ExampleFunction -Body $(@{"BodyName" = "Ben"} | ConvertTo-Json)
```
- Limit function app methods. Remove post and try and post. Look at the error.
- Add in all the allowed methods:
    - Get
    - Post
    - Put
    - Delete