using namespace System.Net

   # Connect-MgGraph -Identity -TenantId  -Scopes "User.Read","Application.ReadWrite.All"
   # Connect-AzAccount  -TenantId 

param($Request, $AppEntity, $TriggerMetadata)

$vaultName = $env:KeyVaultName

# Login to Graph using same context
$token = Get-AzAccessToken -ResourceUri 'https://graph.microsoft.com/'
Write-Host "Acwuired a token for $($token.UserId)"
Connect-MgGraph -AccessToken (ConvertTo-SecureString $token.Token -AsPlainText -Force)

# Get all app registrations in scope
foreach($entity in $AppEntity)
{
    $appId = $entity.RowKey
    $apps = Get-MgApplication -Filter "AppId  eq '$appId'" -Property AppId, DisplayName, PasswordCredentials, Id 
    
    if($apps){
        $app = $apps | Select-Object -First 1
        $objectId = $app.Id

        $params = @{
            passwordCredential = @{
                displayName = "Password created on $($(Get-Date -Format 'yyyy-MM-dd'))"
                endDateTime = (Get-Date).AddDays(5)
            }
        }
        $secret = Add-MgApplicationPassword -ApplicationId $objectId -BodyParameter $params

        # Convert new secret value to SecureString
        $secretvalue = ConvertTo-SecureString $secret.SecretText -AsPlainText -Force

        # Upsert secret in keyvault
        Set-AzKeyVaultSecret -VaultName $vaultName -Name $appId -SecretValue $secretvalue

        # Delete Expired Secrets in App Registrations in scope
        foreach($key in $app.PasswordCredentials | Where-Object { $_.endDateTime -lt (Get-Date) } ){
            $params = @{
                keyId = $key.keyId
            }
            Remove-MgApplicationPassword -ApplicationId $objectId -BodyParameter $params
        }

} else {
    Write-Error "Application with client id $appId not found"
}
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})
