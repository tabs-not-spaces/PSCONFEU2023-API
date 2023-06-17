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

#region switch intent based on method
switch ($Request.Method) {
    "GET" {
        # Get all items
        try {
            $tableEntityResults = Get-StorageTableRow -table $table -partitionKey 'todo'
            $tableEntities = [System.Collections.Generic.List[todoTableEntity]]::New()
            foreach ($entity in $tableEntityResults.Value) {
                $tableEntities.Add([todoTableEntity]::New($entity))
            }
            $body = $tableEntities
            $statusCode = [HttpStatusCode]::OK
        }
        catch {
            $body = @{ "errorMessage" = $_.Exception.Message }
            $statusCode = [HttpStatusCode]::BadRequest
        }
        
    }
    "POST" {
        # Post a new item
        if (-not $Request.Body) {
            $statusCode = [HttpStatusCode]::BadRequest
            $body = @{"errorMessage" = "No task provided" }
            return
        }
        
        $newTodo = @{
            Table        = $table
            Partitionkey = 'todo'
            RowKey       = [guid]::NewGuid().ToString()
            property     = @{
                Task      = $Request.Body.Task
                Completed = $false
            }
        }
        [TodoTableEntity]$postResult = Add-StorageTableRow @newTodo -returnContent
        $body = $postResult
        $statusCode = [HttpStatusCode]::Created
    }
    default {
        $body = @{}
        $body["message"] = "Method not supported"
    }
}
#endregion

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $statusCode
        Body       = $body
    })