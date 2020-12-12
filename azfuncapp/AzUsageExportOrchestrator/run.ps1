param($Context)

$DatesToRetrieve = $Context.Input.Dates
$DatesToRetrieveArray = "$DatesToRetrieve" | convertfrom-json
Write-Host "Target Dates: "
Write-Host "$DatesToRetrieveArray"

foreach ($Date in $DatesToRetrieveArray) {
    Write-Host "Invoking Activity Function for $Date"
    $AzUsageDetailsForDateBlobname = Invoke-ActivityFunction -FunctionName 'Export-AzUsageDetailsForDate' -Input "$Date"
    Write-Host "Orch: AzUsageDetailsForDateBlobname: $AzUsageDetailsForDateBlobname"
    Invoke-ActivityFunction -FunctionName 'PushTo-AzStorageTable' -Input "$($AzUsageDetailsForDateBlobname)"
    Invoke-ActivityFunction -FunctionName 'PushTo-LogAnalyticsWS' -Input "$($AzUsageDetailsForDateBlobname)"
}
