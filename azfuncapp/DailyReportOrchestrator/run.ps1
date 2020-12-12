param($Context)

    Write-Host "Invoking Send Email Activity Function"
    $output = Invoke-ActivityFunction -FunctionName 'Send-DailyReportToEmail' -Input 'Sample Input'
    $output