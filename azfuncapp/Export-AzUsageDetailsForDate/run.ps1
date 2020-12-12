param($date)

. $PSScriptRoot\lib\Get-AzUsageDetailsForDate.ps1

$CultureFromAppSettings = $env:DateTimeCulture
$DateTime = ([datetime]::ParseExact($date,"dd-MM-yyyy",[Globalization.CultureInfo]::CreateSpecificCulture("$CultureFromAppSettings")))
$DateTimeStr = $DateTime.ToString("dd-MM-yyyy")

Write-Host "Getting Usage Details for $DateTime from API"
$Result  = Get-AzUsageDetailsForDate -Date $DateTime
Write-Host "Usage Details for $DateTimeStr from API has been retrieved"
Write-Host "Number of Rows Retrieved from API: $($Result.count)"

#Curate Blob Name
$dateParts = $DateTimeStr.split('-')
$year = $dateParts[2]
$month = $dateParts[1]
$day = $dateParts[0]
$blobnamePrefix = "$year/$month/$day"
$AzStorageCtx = New-AzStorageContext -ConnectionString $env:AzureCostExportsStorage

$blobContainerName = $env:AzureCostExportsContainer

Write-Host "Writing Result to Blob Storage as JSON"
$blobnameJSON = "$blobnamePrefix.json"
$TempFileJSON = New-TemporaryFile
$Result | ConvertTo-JSON | Out-File $TempFileJSON -Force
Set-AzStorageBlobContent -Context $AzStorageCtx -container $blobContainerName -Blob $blobnameJSON -File $TempFileJSON -Force | out-null
Remove-Item $TempFileJSON -Force
Write-Host "Result as JSON has been uploaded to Blob Storage"

Write-Host "Writing Result to Blob Storage as CSV"
$blobnameCSV = "$blobnamePrefix.csv"
$TempFileCSV = New-TemporaryFile
$Result | ConvertTo-CSV | Out-File $TempFileCSV -Force
Set-AzStorageBlobContent -Context $AzStorageCtx -container $blobContainerName -Blob $blobnameCSV -File $TempFileCSV -Force | out-null
Remove-Item $TempFileCSV -Force
Write-Host "Result as CSV has been uploaded to Blob Storage"

return $blobnamePrefix