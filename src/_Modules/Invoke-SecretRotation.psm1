function Invoke-SecretRotation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $AppId,

        [Parameter(Mandatory = $true)]
        [int32]
        $SecretDurationInDays,

        [Parameter(Mandatory = $false)]
        [bool]
        $Force
    )

    Write-Warning $Force

    # Check if still logged in to graph before signing in
    $c = Get-MgContext
    if($null -eq $c){
        $token = Get-AzAccessToken -ResourceTypeName MSGraph -ErrorAction:Stop -WarningAction:Stop
        Write-Host "Acquired a token for $($token.UserId)"
        Connect-MgGraph -AccessToken (ConvertTo-SecureString $token.Token -AsPlainText -Force) -NoWelcome
    }

    # Verify whether we need to rotate
    $app = Get-MgApplication -Filter "AppId  eq '$appId'" -Property AppId, DisplayName, PasswordCredentials, Id  | 
        Select-Object -First 1
        
    if($null -eq $app){
        Write-Error "Application with client id $appId not found."
        return;
    }

    # There's likely more than one secret becuase we have an overlap
    # We need to get the end date of the last one to expire
    $lastSecretToExpire = $app.PasswordCredentials | 
        Sort-Object -Property endDateTime -Descending | 
        Select-Object -First 1

    if(!($Force) -and $lastSecretToExpire.endDateTime -gt $(Get-Date).AddDays([int]$env:DaysLeftBeforeExpiration)){
        Write-Host "Secret for $appId not yet within rotation period."
        # Let's do a cleanup of expired secrets in keyvault while we're here
        Disable-ExpiredSecretVersions -AppId $appId 
        return;
    }

    # At this point we've identified that we need to rotate the secret for the app registration
    # We need to get the larger of the 2 values so that it doesn't rotate unnecessarily 
    $newExpiry = ((Get-Date).AddDays($secretDurationInDays), $expiresOn | Measure-Object -Maximum).Maximum

    # Create new app registration secret
    $params = @{
        passwordCredential = @{
            displayName = "Password created on $($(Get-Date -Format 'yyyy-MM-dd'))"
            endDateTime = $NewExpiry
        }
    }
    $secret = Add-MgApplicationPassword -ApplicationId $app.Id -BodyParameter $params

    # Convert new secret value to SecureString
    $secretvalue = ConvertTo-SecureString $secret.SecretText -AsPlainText -Force  

    # Add new secret to keyvault
    Set-AzKeyVaultSecret -VaultName $env:KeyVaultName -Name $AppId -SecretValue $secretvalue -Expires $NewExpiry

     # Delete expired secrets in current app registration
     foreach($key in $app.PasswordCredentials | Where-Object { $_.endDateTime -lt (Get-Date) } ){
        $params = @{
            keyId = $key.keyId
        }        
        Remove-MgApplicationPassword -ApplicationId $ObjectId -BodyParameter $params
    }

    # Disable expired secrets in key vault
    Disable-ExpiredSecretVersions -AppId $appId

}