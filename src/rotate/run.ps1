using namespace System.Net

param($Request, $TableStorageRows, $TriggerMetadata)

Write-Host "Found $($TableStorageRows.Count) rows"

# Check if still logged in to graph before signing in
$c = Get-MgContext
if($null -eq $c){
    $token = Get-AzAccessToken -ResourceTypeName MSGraph -ErrorAction:Stop -WarningAction:Stop
    Write-Host "Acquired a token for $($token.UserId)"
    Connect-MgGraph -AccessToken (ConvertTo-SecureString $token.Token -AsPlainText -Force) -NoWelcome
}

# Get all app registrations in scope
foreach($row in $TableStorageRows)
{   
    $appId = $row.RowKey # Client Id of the app registration
    $secretDurationInDays = [int]$row.SecretDurationInDays # Number of days before the new secret expires
    Write-Host "Processing $appId"
    
    # Verify whether we need to rotate
    $app = Get-MgApplication -Filter "AppId  eq '$appId'" -Property AppId, DisplayName, PasswordCredentials, Id  | 
        Select-Object -First 1
            
    if($null -eq $app){
        Write-Error "Application with client id $appId not found."
        continue;
    }

    # There's likely more than one secret becuase we have an overlap
    # We need to get the end date of the last one to expire
    $lastSecretToExpire = $app.PasswordCredentials | 
        Sort-Object -Property endDateTime -Descending | 
        Select-Object -First 1

    if($lastSecretToExpire.endDateTime -gt $(Get-Date).AddDays([int]$env:DaysLeftBeforeExpiration)){
        Write-Host "Secret for $appId not yet within rotation period."
        # Let's do a cleanup of expired secrets in keyvault while we're here
        Disable-ExpiredSecretVersions -AppId $appId 
        continue;
    }

    # At this point we've identified that we need to rotate the secret for the app registration
    # We need to get the larger of the 2 values so that it doesn't rotate unnecessarily 
    $newExpiry = ((Get-Date).AddDays($secretDurationInDays), $expiresOn | Measure-Object -Maximum).Maximum
    Invoke-SecretRotation -AppId $appId -ObjectId $app.Id -NewExpiry $newExpiry

    # Delete expired secrets in current app registration
    foreach($key in $app.PasswordCredentials | Where-Object { $_.endDateTime -lt (Get-Date) } ){
        $params = @{
            keyId = $key.keyId
        }        
        Remove-MgApplicationPassword -ApplicationId $ObjectId -BodyParameter $params
    }

    # Disable expired secrets in key vault
    Disable-ExpiredSecretVersions -AppId $AppId
    
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})
