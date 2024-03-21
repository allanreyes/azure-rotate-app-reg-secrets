using namespace System.Net

param($Request, $TriggerMetadata)

$appId = $Request.Body.AppId 

if(!($appId)){
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "AppId is required"
    })
    return
} 

$ctx = New-AzStorageContext -ConnectionString $env:AzureWebJobsStorage
$cloudTable = (Get-AzStorageTable -Name appreg -Context $ctx).CloudTable

$row = Get-AzTableRow -table $cloudTable -partitionKey app -rowKey $appId

# Upsert row
if($row){   

    $row | Remove-AzTableRow -table $cloudTable

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = "Row deleted successfully"
    })
    
} else {

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::NotFound
        Body = "AppId not found"
    })

}
