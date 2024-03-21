using namespace System.Net

param($Request, $TriggerMetadata)

$ctx = New-AzStorageContext -ConnectionString $env:AzureWebJobsStorage
$cloudTable = (Get-AzStorageTable –Name appreg –Context $ctx).CloudTable
$rows = Get-AzTableRow -table $cloudTable -partitionKey app

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $rows | Select-Object -Property @{N='AppId';E={$_.RowKey}}, SecretDurationDays, SecretValidDays        
})