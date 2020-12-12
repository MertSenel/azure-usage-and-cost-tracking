# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

$currentUTCDateShortString = $currentUTCtime.ToString('dd-MM-yyyy')

$RequestBody = [pscustomobject]@{
    Dates = @(
        $currentUTCDateShortString
    )
}

$InputObject = $RequestBody | ConvertTo-Json | convertfrom-json -AsHashtable

$InstanceId = Start-NewOrchestration -FunctionName "DailyReportOrchestrator" -InputObject $InputObject
Write-Host "Started orchestration with ID = '$InstanceId'"

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
