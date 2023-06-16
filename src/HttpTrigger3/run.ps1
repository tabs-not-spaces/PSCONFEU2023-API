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
        #Get item with correct ID
    }
    'POST' {
        #Update state of item with correct ID
    }
    'PUT' {
        #Update item task value with correct ID
    }
    'DELETE' {
        #Delete item with correct ID
    }
    Default {}
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $statusCode
        Body       = $body
    })