# function New-DailyCostPerRGChart {
#     [CmdletBinding()]
#     param (
#         [Parameter()]
#         [string]
#         $ChartTitle = "Daily Total Cost Split by Resource Group",
#         # Parameter help description
#         [Parameter()]
#         [PSCustomObject[]]
#         $ChartInput
#     )
#     #$ChartInput
#     $chartSavePath = $PSScriptRoot
#     [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
#     # # Creating chart object
#     # # The System.Windows.Forms.DataVisualization.Charting namespace contains methods and properties for the Chart Windows forms control.
#     $chartobject = New-object System.Windows.Forms.DataVisualization.Charting.Chart
#     $chartobject.Width = 800
#     $chartobject.Height = 400
#     $chartobject.BackColor = [System.Drawing.Color]::AliceBlue
   
#     # Set Chart title 
#     [void]$chartobject.Titles.Add("Daily Total Cost Split by Resource Group")
#     $chartobject.Titles[0].Font = "Arial,13pt"
#     $chartobject.Titles[0].Alignment = "topLeft"
 
#     # create a chartarea to draw on and add to chart
#     $chartareaobject = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
#     $chartareaobject.Name = "ChartArea1"
#     $chartareaobject.AxisY.Title = "Total Cost"
#     $chartareaobject.AxisX.Title = "Date"
#     #$chartareaobject.AxisY.Interval = 0.25
#     $chartareaobject.AxisX.Interval = 1
#     $chartobject.ChartAreas.Add($chartareaobject)
 
#     # # Creating legend for the chart
#     # $chartlegend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
#     # $chartlegend.name = "Legend1"
#     # $chartobject.Legends.Add($chartlegend)

#     # $ChartInput | ForEach-Object { 
#     #     # data series $DailyCostPerResourceGroup
#     #     if ($chartobject.Series.IndexOf("$($_.ResourceGroupName)") -ne -1 ) {
#     #         # Series Exists
#     #         #Write-Output "Series already Exists"
#     #     }
#     #     else {
#     #         # Series Does Not Exist
#     #         [void]$chartobject.Series.Add("$($_.ResourceGroupName)") 
#     #         $chartobject.Series["$($_.ResourceGroupName)"].ChartType = "StackedColumn"
#     #         $chartobject.Series["$($_.ResourceGroupName)"].IsVisibleInLegend = $true
#     #         $chartobject.Series["$($_.ResourceGroupName)"].BorderWidth = 3
#     #         $chartobject.Series["$($_.ResourceGroupName)"].chartarea = "ChartArea1"
#     #         $chartobject.Series["$($_.ResourceGroupName)"].Legend = "Legend1"
#     #         #$chartobject.Series["$($_.ResourceGroupName)"].color = "#bf00ff"
#     #     }
#     #     $_ | ForEach-Object { 
#     #         [void]$chartobject.Series["$($_.ResourceGroupName)"].Points.addxy( $_.Date, $_.Cost) 
#     #     }
#     # }
  
#     # # save chart with the Time frame for identifying the usage at the specific time
#     # $chartFilePath = "$chartSavePath\Cost_Report_$(get-date -format `"yyyyMMdd_hhmmsstt`").png"
#     # $chartobject.SaveImage($chartFilePath, "png")
 
#     # $chartFilePathPngBase64Str = [convert]::ToBase64String((get-content $chartFilePath -AsByteStream))
#     # Remove-Item $chartFilePath -Force
#     # return $chartFilePathPngBase64Str
# }




