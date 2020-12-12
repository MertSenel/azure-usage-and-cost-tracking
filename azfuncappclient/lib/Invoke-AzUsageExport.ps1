function Invoke-AzUsageExport {
    [CmdletBinding()]
    param (
        [Parameter()][string]$subscriptionId,
        [Parameter()][string]$resourceGroup,
        [Parameter()][string]$AzFunctionAppName,
        [Parameter()][string]$httpFunctionName,
        [Parameter()][datetime]$StartDateUTC,
        [Parameter()][int]$NoOfDaysToRetroExport,
        [Parameter()][switch]$localhost
    )


    if ($localhost) {
        $functionAppUri = "http://localhost:7071/api/$($httpFunctionName)?code=$($funcHTTPFuncKey)"
    }
    else {
        . $PSScriptRoot\Get-AzFunctionKey.ps1
        $GetAzFunctionKeyArgs = @{
            subscriptionId    = $subscriptionId
            resourceGroup     = $resourceGroup
            AzFunctionAppName = $AzFunctionAppName
            httpFunctionName  = $httpFunctionName
        }
    
        $funcHTTPFuncKey = Get-AzFunctionKey @GetAzFunctionKeyArgs
        $functionAppUri = "https://$($AzFunctionAppName).azurewebsites.net/api/$($httpFunctionName)?code=$($funcHTTPFuncKey)"
    }

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $StartDateUTCStr = $StartDateUTC.ToString('dd-MM-yyyy')

    $DatesArrList = [System.Collections.ArrayList]@()
    [void]$DatesArrList.Add($StartDateUTCStr)

    for ($i = 1; $i -le $NoOfDaysToRetroExport; $i++) {
        $DateStrToAdd = ($StartDateUTC.AddDays(-$i)).ToString('dd-MM-yyyy')
        [void]$DatesArrList.Add($DateStrToAdd)
        Remove-Variable DateStrToAdd
    }

    $DatesArr = $DatesArrList.ToArray()

    $RequestBody = [pscustomobject]@{
        Dates = $DatesArr
    }

    $body = $RequestBody | ConvertTo-Json
   

    Write-Output "Invoking Function with Request Body:"
    $body

    $response = Invoke-RestMethod $functionAppUri -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json
}