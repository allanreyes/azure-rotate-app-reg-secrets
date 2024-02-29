Add-AzADAppPermission -ApplicationId "5e807530-fa6d-486e-9e4d-f50df0edf914" -ApiId 00000003-0000-0000-c000-000000000000 -PermissionId 1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9 # Application.ReadWrite.All 

# Function app managed identity object id

Get-AzADApplication



$name = "func-rotate-app-secrets"
$roleDefId = "00000000-0000-0000-0000-000000000000" # Application Administrator
$sp = Get-AzADServicePrincipal -DisplayName $name

Connect-MgGraph -TenantId "fb9cc0e8-f9b5-4d7a-baf2-64576dcded7b"

$params = @{
	principalId = $sp.Id
	resourceId = $sp.Id
	appRoleId = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
}

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -BodyParameter $params

$asdf =  Get-AzADServicePrincipal  | Where-Object { $_.DisplayName -eq $name }
$asdf.AppRoles


Get-AzADServiceAppRoleAssignment




Get-AzKeyVaultSecret -VaultName $vaultName -Name $appId -SecretValue $secretvalue