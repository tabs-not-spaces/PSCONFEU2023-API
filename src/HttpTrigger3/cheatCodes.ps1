#region cheat codes
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
#endregion