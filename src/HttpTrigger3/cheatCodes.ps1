switch ($Request.Method) {
        'GET' {
            $body = Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id
            if ($body.value.count -lt 1) {
                $body = $null
                $statusCode = [HttpStatusCode]::NotFound
            }
            else {
                $statusCode = [HttpStatusCode]::OK
            }    
        }
        'POST' {
            $existingItem = $body = Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id
            if ($existingItem.value) {
                $updateParams = @{
                    table        = $table
                    partitionKey = 'todo'
                    rowKey       = $Request.Params.id
                    property     = @{ 
                        Task  = $ExistingItem.Value.Task
                        State = !$existingItem.Value.State
                    }
                }
                $body = Update-StorageTableRow @updateParams
                $statusCode = [HttpStatusCode]::OK
            }
            else {
                $statusCode = [HttpStatusCode]::NotFound
            }
        }
            
        'PUT' {
            $existingItem = $body = Get-StorageTableRow -table $table -partitionKey 'todo' -rowKey $Request.Params.id
            if ($existingItem.value) {
                $updateParams = @{
                    table        = $table
                    partitionKey = 'todo'
                    rowKey       = $Request.Params.id
                    property     = @{ 
                        Task  = $Request.Body.Task
                        State = $existingItem.Value.State
                    }
                }
                $body = Update-StorageTableRow @updateParams
                $statusCode = [HttpStatusCode]::OK
            }
            else {
                $statusCode = [HttpStatusCode]::NotFound
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