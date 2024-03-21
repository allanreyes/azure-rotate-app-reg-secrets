using namespace System.Net

param($Request, $TriggerMetadata)

$appId = $Request.Body.AppId 
$secretDurationDays = [int]$Request.Body.SecretDurationDays 
$secretValidDays = [int]$Request.Body.SecretValidDays 

# Validate payload
$errorMessages = @()
if($null -eq $appId -or $null -eq $secretDurationDays -or $null -eq $secretValidDays){   
    $errorMessages += "You need to provide AppId, SecretDurationDays, and SecretValidDays in the request body"
}
if($appId.Length -eq 0){
    $errorMessages += "AppId cannot be empty"
} 
if ($secretDurationDays -lt 14) {
    $errorMessages += "SecretDurationDays cannot be less than 14"
} 
if ($secretValidDays -lt 7) {
    $errorMessages += "SecretValidDays cannot be less than 7"
}
if($errorMessages.Length -gt 0){
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = $errorMessages -join "`n"
    })
    return
}

$ctx = New-AzStorageContext -ConnectionString $env:AzureWebJobsStorage
$cloudTable = (Get-AzStorageTable -Name appreg -Context $ctx).CloudTable

$row = Get-AzTableRow -table $cloudTable -partitionKey app -rowKey $appId

# Upsert row
if($row){   

    $row.SecretDurationDays = $secretDurationDays
    $row.SecretValidDays = $secretValidDays

    $row | Update-AzTableRow -table $cloudTable

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = "Row updated successfully"
    })
    
} else {

    Add-AzTableRow `
    -table $cloudTable `
    -partitionKey app `
    -rowKey $appId -property @{"SecretDurationDays" = $secretDurationDays; "SecretValidDays"= $secretValidDays}

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::Created
    })
}

