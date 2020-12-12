function Start-AzUsageExport {
    [CmdletBinding()]
    param (
        [Parameter()][string]$subscriptionId = "9ba089ac-b8fc-496b-a408-e42840ba07de",
        [Parameter()][string]$resourceGroup = "AzUsageExportInfra-dev",
        [Parameter()][string]$AzFunctionAppName = "auepoc01devfnc",
        [Parameter()][string]$httpFunctionName = "AzUsageExportHttpTrigger",
        [Parameter()][datetime]$StartDateUTC = (get-date).ToUniversalTime(),
        [Parameter()][int]$NoOfDaysToRetroExport = 0, #Log Analytics Can Only Show up to 30 days in Default Retention
        [Parameter()][switch]$localhost
    )

    . $PSScriptRoot\lib\Invoke-AzUsageExport.ps1

    $InvokeAzUsageExportArgs = @{
        subscriptionId        = $subscriptionId
        resourceGroup         = $resourceGroup
        AzFunctionAppName     = $AzFunctionAppName
        httpFunctionName      = $httpFunctionName
        StartDateUTC          = $StartDateUTC
        NoOfDaysToRetroExport = $NoOfDaysToRetroExport
    }

    if ($localhost) {
        Invoke-AzUsageExport @InvokeAzUsageExportArgs -localhost
    }
    else {
        Invoke-AzUsageExport @InvokeAzUsageExportArgs
    }

}