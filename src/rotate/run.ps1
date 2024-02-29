using namespace System.Net

param($Request, $TableStorageRows, $TriggerMetadata)

$appId = $Request.Body.AppId # Client Id of the app registration

if(!($appId)){
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "You need to provide AppId in the request body"
    })
    return
}

$row = $TableStorageRows | Where-Object { $_.RowKey -eq $appId } | Select-Object -First 1

if($row)
{   
    Write-Host "Processing $appId"
    Invoke-SecretRotation -AppId $appId -SecretDurationInDays ([int]$row.SecretDurationInDays) -Force $true # Number of days before the new secret expires
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
    })
    return
} else {
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotFound
        Body = "$appId not found in appreg table"
    })
    return
}