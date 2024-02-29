function Invoke-SecretRotation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $AppId,
        
        [Parameter(Mandatory = $true)]
        [string]
        $ObjectId,
        
        [Parameter(Mandatory = $true)]
        [datetime]
        $NewExpiry
    )

    # Create new app registration secret
    $params = @{
        passwordCredential = @{
            displayName = "Password created on $($(Get-Date -Format 'yyyy-MM-dd'))"
            endDateTime = $NewExpiry
        }
    }
    $secret = Add-MgApplicationPassword -ApplicationId $ObjectId -BodyParameter $params

    # Convert new secret value to SecureString
    $secretvalue = ConvertTo-SecureString $secret.SecretText -AsPlainText -Force  

    # Add new secret to keyvault
    Set-AzKeyVaultSecret -VaultName $env:KeyVaultName -Name $AppId -SecretValue $secretvalue -Expires $NewExpiry

}