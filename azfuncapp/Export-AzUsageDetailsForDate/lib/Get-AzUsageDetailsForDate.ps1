function Get-AzUsageDetailsForDate {
    [CmdletBinding()]
    param (
        # Start Date to Get the Azure Consumption Usage Details
        [Parameter()]
        [datetime]$Date
    )
    $DateArgs = @{
        StartDate = $Date
        EndDate   = $Date
    }

    try {
            
        Write-Verbose "Retrieving Usage Details for Date $($DateArgs.Startdate)"
        $ExportwAddInfo = Get-AzConsumptionUsageDetail @DateArgs -IncludeAdditionalProperties | Sort-Object -Property Id
        Start-Sleep 5
        $ExportwMeterDetails = Get-AzConsumptionUsageDetail @DateArgs -IncludeMeterDetails | Sort-Object -Property Id

        #region Curate the Object
        $OutputArrayList = [System.Collections.ArrayList]@()

        for ($i = 0; $i -lt $($ExportwMeterDetails.Count); $i++) {

            $ExportedRow = $ExportwMeterDetails[$i]
            $ExportedRowAddInfo = $ExportwAddInfo[$i]
            $instanceDetails = ($ExportedRow.InstanceId -split '/')

            $Row = [PSCustomObject]@{
                Id                = $ExportedRow.Id
                BillingPeriodId   = $ExportedRow.BillingPeriodId
                BillingPeriodName = $ExportedRow.BillingPeriodName
                SubscriptionGuid  = $ExportedRow.SubscriptionGuid.ToLower()
                ResourceGroup     = $instanceDetails[4].ToLower()
                ResourceLocation  = $ExportedRow.InstanceLocation
                UsageDateTime     = $ExportedRow.UsageStart.ToString("o")
                MeterCategory     = $ExportedRow.MeterDetails.MeterCategory
                MeterSubcategory  = $ExportedRow.MeterDetails.MeterSubCategory
                MeterId           = $ExportedRow.MeterId
                MeterName         = $ExportedRow.MeterDetails.MeterName
                MeterRegion       = $ExportedRow.MeterDetails.MeterLocation
                UsageQuantity     = $ExportedRow.UsageQuantity
                ResourceRate      = ($ExportedRow.PretaxCost / $ExportedRow.UsageQuantity)
                PreTaxCost        = $ExportedRow.PretaxCost
                ConsumedService   = $ExportedRow.ConsumedService
                ResourceType      = "$($instanceDetails[6])/$($instanceDetails[7])"
                InstanceId        = $ExportedRow.InstanceId
                InstanceName      = $ExportedRow.InstanceName.ToLower()
                Tags              = "$($ExportedRow.Tags | ConvertTo-Json -Compress)"
                AdditionalInfo    = "$($ExportedRowAddInfo.AdditionalInfo)"
                ServiceName       = $ExportedRow.MeterDetails.MeterCategory
                ServiceTier       = $ExportedRow.MeterDetails.MeterSubCategory
                Currency          = $ExportedRow.Currency
                UnitOfMeasure     = $ExportedRow.MeterDetails.Unit
            }

            $OutputArrayList.Add($Row) | Out-Null
            Remove-Variable 'Row'
        }   

        $OutputArrayList

        Write-Verbose "Usage Details for Date $($DateArgs.Startdate) has been retrieved"
        #endregion
    }
    catch {
        Write-Error "$_"
    }
}

