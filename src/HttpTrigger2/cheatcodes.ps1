#region Simple
#####GET
try {
    $body = Get-StorageTableRow -table $table -partitionKey 'todo'
    $statusCode = [HttpStatusCode]::OK
}
catch {
    $body = @{ "errorMessage" = $_.Exception.Message }
    $statusCode = [HttpStatusCode]::BadRequest
}
####POST
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
$body = Add-StorageTableRow @newTodo -returnContent
$statusCode = [HttpStatusCode]::Created
#endregion

#region Advanced
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