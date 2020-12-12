function Get-AzFunctionKey {
[CmdletBinding()]
param (
    [Parameter()][string]$subscriptionId,
    [Parameter()][string]$resourceGroup,
    [Parameter()][string]$AzFunctionAppName,
    [Parameter()][string]$httpFunctionName,
    [Parameter()][switch]$HostKey
)
Import-Module Az.Accounts

if ($HostKey) {
    #region Retrieve Host Level Function Default Key
    # Host level key, not recommended to used it. It's better to get it from
    $InvokeAzRestArgs = @{
        Path   = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Web/sites/$AzFunctionAppName/host/default/listKeys?api-version=2018-11-01"
        Method = 'POST'
    }
    $funcHostKeys = (Invoke-AzRestMethod @InvokeAzRestArgs).Content | convertfrom-json
    $funcHostDefaultKey = $funcHostKeys.default
    return funcHostDefaultKey
}
#endregion 

#region Retrieve function level key for the HTTP Trigger Function 
else {
    $InvokeAzRestArgs = @{
        Path   = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Web/sites/$AzFunctionAppName/functions/$httpFunctionName/listKeys?api-version=2018-11-01"
        Method = 'POST'
    }
    $funcHTTPFuncKeys = (Invoke-AzRestMethod @InvokeAzRestArgs).Content | convertfrom-json
    $funcHTTPFuncDefaultKey = $funcHTTPFuncKeys.default

    return $funcHTTPFuncDefaultKey
}
}