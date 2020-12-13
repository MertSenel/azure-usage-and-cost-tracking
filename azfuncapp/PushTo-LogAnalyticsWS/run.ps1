param($blobnamePrefix)
$blobname = "$blobnamePrefix.json"

. $PSScriptRoot\lib\OMS-Helpers.ps1

"BlobName To Export To Log Analytics Workspace: $blobname"
$AzStorageCtx = New-AzStorageContext -ConnectionString $env:AzureCostExportsStorage
$Blob = Get-AzStorageBlob -Context $AzStorageCtx -Container "$($env:AzureCostExportsContainer)" -Blob "$blobname"
$memStream = New-Object System.IO.MemoryStream
$Blob.ICloudBlob.DownloadToStream($memStream)
$readStream = New-Object System.IO.StreamReader($memStream, [System.Text.Encoding]::Utf8)
$memStream.Position = 0
$BlobContent  = $readStream.ReadToEnd()
$Results = $BlobContent | ConvertFrom-JSON
Write-Host "Number of Rows to be Pushed to LogAnalytics Workspace $($Results.count)"

$logAnalyticsParams = @{
    CustomerId     = "$($env:LA_WSId)"
    SharedKey      = "$($env:LA_WSKey)"
    TimeStampField = "$($env:LA_TimeStampField)"
    LogType        = "$($env:LA_LogType)"
}
try {
    Write-Output "Pushing Usage Details for Blob $($blobname) to Log Analytics Workspace"
    Write-Output "Number of Rows being pushed: $($Results.count)"

    if($($Result.Count) -eq 0){
        Write-Host "Blob File is Empty. Nothing to send to Log Analytics Exiting."
        exit 0
    }
    

    ExportTo-LogAnalyticsWS @logAnalyticsParams $Results | out-null
        
    Write-Output "Usage Details for Date $($DateArgs.Startdate) has been Pushed to Log Analytics Workspace"
}
catch {
    Write-Error "$_"
}


