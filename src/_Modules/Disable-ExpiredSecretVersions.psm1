function Disable-ExpiredSecretVersions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $AppId
    )
    
     # Select only secret versions that are expired and enabled
    $expiredSecretVersions = Get-AzKeyVaultSecret -VaultName $env:KeyVaultName -Name $appId -IncludeVersions | 
        Where-Object { $_.Expires -lt (Get-Date) -and $_.Enabled -eq $true}

    foreach($version in $expiredSecretVersions){

        $id = ($version.Id).Split('/') | Select-Object -Last 1  
        Write-Host "Disabling secret version $id of secret $AppId from keyvault $env:KeyVaultName"
        
        # Disable expired secret versions
        Set-AzKeyVaultSecretAttribute -VaultName $env:KeyVaultName -Name $AppId -Version $id -Enable $false        
    }

}