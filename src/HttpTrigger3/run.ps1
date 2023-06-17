using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

#region authenticate / get context
$ctx = if ($env:MSI_SECRET) {
    New-AzStorageContext -StorageAccountName $env:STORAGE_ACCOUNT_NAME -UseConnectedAccount
}
else {
    New-AzStorageContext -StorageAccountName $env:STORAGE_ACCOUNT_NAME -StorageAccountKey $env:STORAGE_ACCOUNT_KEY
}
Write-Host $env:TABLE_NAME
Write-Host $ctx | ConvertTo-Json -Depth 20
$table = Get-AzStorageTable -Name $env:TABLE_NAME -Context $ctx
#endregion

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

switch ($Request.Method) {
    'GET' {
        [TodoTableEntity]$body = (Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id).Value[0]
        if ($body.count -lt 1) {
            $body = $null
            $statusCode = [HttpStatusCode]::NotFound
        }
        else {
            $statusCode = [HttpStatusCode]::OK
        }    
    }
    'POST' {
        [TodoTableEntity]$existingItem = (Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id).Value[0]
        if ($existingItem) {
            $existingItem.property.Completed = !$existingItem.property.Completed
            $updateParams = @{
                table        = $table
                partitionKey = 'todo'
                rowKey       = $Request.Params.id
                property     = @{
                    Task        = $existingItem.property.Task
                    Completed   = $existingItem.property.Completed
                }
            }
            $postResult = Update-StorageTableRow @updateParams
            $body = $existingItem
            $statusCode = [HttpStatusCode]::OK
        }
        else {
            $statusCode = [HttpStatusCode]::NotFound
        }
    }
            
    'PUT' {
        [TodoTableEntity]$existingItem = (Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id).Value[0]
        if ($existingItem) {
            $existingItem.property.Task = $Request.Body.Task
            $updateParams = @{
                table        = $table
                partitionKey = 'todo'
                rowKey       = $Request.Params.id
                property     = @{
                    Task        = $existingItem.property.Task
                    Completed   = $existingItem.property.Completed
                }
            }
            $postResult = Update-StorageTableRow @updateParams
            $body = $existingItem
            $statusCode = [HttpStatusCode]::OK
        }
    }
    'DELETE' {
        $deleteParams = @{
            table        = $table
            partitionKey = 'todo'
            rowKey       = $Request.Params.id
        }
        $body = Remove-StorageTableRow @deleteParams
        $statusCode = [HttpStatusCode]::NoContent
    }
    default {}
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $statusCode
        Body       = $body
    })