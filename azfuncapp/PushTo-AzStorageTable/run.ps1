param($blobnamePrefix)
$blobname = "$blobnamePrefix.json"

"BlobName To Upload To Table: $blobname"
$AzStorageCtx = New-AzStorageContext -ConnectionString $env:AzureCostExportsStorage
$Blob = Get-AzStorageBlob -Context $AzStorageCtx -Container "$($env:AzureCostExportsContainer)" -Blob "$blobname"
$memStream = New-Object System.IO.MemoryStream
$Blob.ICloudBlob.DownloadToStream($memStream)
$readStream = New-Object System.IO.StreamReader($memStream, [System.Text.Encoding]::Utf8)
$memStream.Position = 0
$BlobContent  = $readStream.ReadToEnd()
$Results = $BlobContent | ConvertFrom-Json
Write-Host "Number of Rows to be Inserted to Table $($Results.count)"

$tableName = "$($env:AzUsageExportsAzureStorageTableName)"
$cloudTable = (Get-AzStorageTable -Name $tableName -Context $AzStorageCtx).CloudTable

foreach ($Result in $Results) {
    $ResultHT = $Result | Convertto-json | convertfrom-json -AsHashtable 

    $IdParts = $ResultHT.Id -split '/'
    $RowKey = "$($IdParts[6])|$($IdParts[-1])"

    $AddTableRowArgs = @{
        Table          = $cloudTable
        PartitionKey   = $ResultHT.SubscriptionGuid.ToLower()
        RowKey         = $RowKey
        property       = $ResultHT
        UpdateExisting = $true
    }

    $AddTableOperation = Add-AzTableRow @AddTableRowArgs
}