param($name)

$SendGrid_APIKey = $env:SendGrid_APIKey


Write-Host "Email Activity function Started"
#Write-Host "Message from Orchestrator: $name"

#$Report = get-content "$PSScriptRoot\Azure-Cost-Report-Last7Days.html"
#$ChartBase64 = get-content "$PSScriptRoot\chartbase64"

#region Get Data And Generate Report
. $PSScriptRoot\lib\New-DailyCostPerRGChart.ps1
. $PSScriptRoot\lib\Report-Helpers.ps1
$TaxMultiplier = ("$($env:TaxMultiplier)") -as [double]

$AzStorageCtx = New-AzStorageContext -ConnectionString $env:AzureCostExportsStorage
$SubscriptionId = $env:SubscriptionId
$SubscriptionName = (Get-AzContext).Subscription.Name

$tableName = $env:AzUsageExportsAzureStorageTableName
$cloudTable = (Get-AzStorageTable -Name $tableName -Context $AzStorageCtx).CloudTable

$currentUTC = (get-date).ToUniversalTime()
$DateMinimum = $currentUTC.AddDays(-7)
$DateMinimumStr = $DateMinimum.Date.toString('o')

$customFilter = "(PartitionKey eq '$($SubscriptionId)') and (UsageDateTime ge datetime'$($DateMinimumStr)')"

$Rows = Get-AzTableRow -table $cloudTable -CustomFilter $customFilter
Remove-Variable cloudTable -force
$Rows.count

## Daily Cost Per RG Required for generating the Chart. 
$DailyCostPerResourceGroup = Measure-DailyCostPerResourceGroup -Rows $Rows -TaxMultiplier $TaxMultiplier
$DailyCostPerResourceGroup = $DailyCostPerResourceGroup | Sort-Object -Property Date
#$DailyCostPerResourceGroup
#$chartFilePathPngBase64Str = New-DailyCostPerRGChart -ChartInput $DailyCostPerResourceGroup

# Grouped per Day required for Daily Total Cost Report
$DailyCostPerDay = Measure-DailyCostPerDay -Rows $Rows -TaxMultiplier $TaxMultiplier

$Total = $([math]::Round((($DailyCostPerDay.Cost) | Measure-Object -Sum).sum, 4))
$Currency = "$($DailyCostPerDay[0].Currency)"

#Total Cost Per RG 
$TotalCostPerRG = Measure-TotalCostPerRG -Rows $Rows -TaxMultiplier $TaxMultiplier
$TotalCostPerRGTopResults = $TotalCostPerRG | Sort-Object -Property Cost -Descending | Select-Object -First 10

#Total Cost Per Meter Category
$TotalCostPerMeterCategory = Measure-TotalCostPerMeterCategory -Rows $Rows -TaxMultiplier $TaxMultiplier
$TotalCostPerMeterCategoryTopResults = $TotalCostPerMeterCategory | Sort-Object -Property Cost -Descending | Select-Object -First 10

#Create the HTML Report
#CSS codes
$header = get-content "$PSScriptRoot\assets\report.css"

#Header For Page
$SubscriptionNameHTMLHeading = "<h1>Subscription Name: $SubscriptionName</h1>"
#Total Cost for Report Period
$TotalCostForReportPeriod = "<h2>Total Cost For Last 7 Days: $Total $Currency</h2>"

#Report Chart for Daily Cost split by Resource Group
#$ReportChartHTML = "<img src=src='cid:cost_report_chart_image' alt=`"Daily Total Cost Split by Resource Group`"/>"

#Daily Total Cost Per Day as Table
$DailyCostPerDay | ForEach-Object { $_.Cost = "$($_.Cost)" }
$DailyCostPerDayTable = $DailyCostPerDay | ConvertTo-Html -As Table -Property Date, Cost, Currency -Fragment -PreContent "<h2>Daily Total Costs for Last 7 Days</h2>"

#Top X Costing Resource Groups for Report Period
$TotalCostPerRGTopResults | ForEach-Object { $_.Cost = "$($_.Cost)" }
$TotalCostPerRGTopResultsTable = $TotalCostPerRGTopResults | ConvertTo-Html -As Table -Property ResourceGroupName, Cost, Currency -Fragment -PreContent "<h2>Top 10 Costing Resource Groups for Last 7 Days</h2>"

#Top X Costing Meter Category for Report Period
$TotalCostPerMeterCategoryTopResults | ForEach-Object { $_.Cost = "$($_.Cost)" }
$TotalCostPerMeterCategoryTopResultsTable = $TotalCostPerMeterCategoryTopResults | ConvertTo-Html -As Table -Property MeterCategory, Cost, Currency -Fragment -PreContent "<h2>Top 10 Costing Meter Categories for Last 7 Days</h2>"

#The command below will combine all the information gathered into a single HTML report
$Report = ConvertTo-HTML -Body "$SubscriptionNameHTMLHeading $TotalCostForReportPeriod $DailyCostPerDayTable $TotalCostPerRGTopResultsTable $TotalCostPerMeterCategoryTopResultsTable" -Head $header -Title "Azure Cost Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p>"

#The command below will generate the report to an HTML file
#$Report | Out-File .\Azure-Cost-Report-Last7Days.html

#endregion

#region Send Email
Write-Host "Sending Email Message"

$mail = @{
    "personalizations" = @(
        @{
            "to" = @(
                @{
                    "email" = "report@receivermailbox.com" # Change with email
                }
            )
        }
    )
    "from"             = @{ 
        "email" = "azurecostreports@mertsenel.tech"
    }        
    "subject"          = "Azure Daily Cost Report"
    "content"          = @(
        @{
            "type"  = "text/html"
            "value" = "$Report"
        }
    )
    # "attachments"      = @(
    #     @{
    #         "content"     = "$chartFilePathPngBase64Str"
    #         "type"        = "image/png"
    #         "filename"    = "cost_report_chart_image"
    #         "disposition" = "inline"
    #         "content_id"  = "cost_report_chart_image"
    #     }
    # )
}

$MailJson = $mail | convertto-json -Depth 4

$Header = @{
    "authorization" = "Bearer $($SendGrid_APIKey)"
}
#send the mail through Sendgrid
$Parameters = @{
    Method      = "POST"
    Uri         = "https://api.sendgrid.com/v3/mail/send"
    Headers     = $Header
    ContentType = "application/json"
    Body        = $MailJson
}
Invoke-WebRequest @Parameters
#endregion