param($Timer, $TableStorageRows)

Write-Host "Found $($TableStorageRows.Count) rows"

# Get all app registrations in scope
foreach($row in $TableStorageRows)
{   
    $appId = $row.RowKey # Client Id of the app registration
    Write-Host "Processing $appId"   
    Invoke-SecretRotation -AppId $appId -SecretDurationInDays ([int]$row.SecretDurationInDays) # Number of days before the new secret expires    
}
