#region CHEAT CODES
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
    $body = @{"errorMessage" = "No task provided"}
    return
}

$newTodo = @{
    Table        = $table
    Partitionkey = 'todo'
    RowKey       = [guid]::NewGuid().ToString()
    property     = @{
        Task  = $Request.Body.Task
        State = $false
    }
}
$body = Add-StorageTableRow @newTodo -returnContent
$statusCode = [HttpStatusCode]::Created
#endregion