using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

#region DEFAULT
Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if ($name) {
    $body = "Hello, $name. This HTTP triggered function executed successfully."
}
#endregion

#region INTERROGATE
# $body = @{
#     Request = $Request
#     TriggerMetadata = $TriggerMetadata
# } | ConvertTo-Json -Depth 20
#endregion

#region PARSE REQUEST METHOD
# $body = switch ($Request.METHOD) {
#     "GET" {
#         "GET 🍻"
#     }
#     "POST" {
#         "POST 📨"
#     }
#     "PUT" {
#         "PUT 🩹"
#     }
#     "DELETE" {
#         "DELETE 🗑️"
#     }
#     default {
#         "UNKNOWN 🤷"
#     }
# }
#endregion

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
