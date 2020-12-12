using namespace System.Net

param($Request, $TriggerMetadata)

$FunctionName = "AzUsageExportOrchestrator"
$InputObject = $Request.Body

$InstanceId = Start-NewOrchestration -FunctionName $FunctionName -InputObject $InputObject
Write-Host "Started orchestration with ID = '$InstanceId'"

$Response = New-OrchestrationCheckStatusResponse -Request $Request -InstanceId $InstanceId
Push-OutputBinding -Name Response -Value $Response
