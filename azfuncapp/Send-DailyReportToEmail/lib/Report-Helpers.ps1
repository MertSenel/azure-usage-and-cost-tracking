function Measure-DailyCostPerResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter()][pscustomobject[]]$Rows,
        [Parameter()][double]$TaxMultiplier
    )
    $GroupedResults = $Rows | Group-Object -Property Currency, UsageDateTime, ResourceGroup 
    
    $DailyCostPerResourceGroup = foreach ($GroupedResult in $GroupedResults) {
        $GroupedResultDetails = ($GroupedResult.name -split ', ')
        [PSCustomObject]@{
            Date              = ($GroupedResultDetails[1].Split(' '))[0];
            ResourceGroupName = $GroupedResultDetails[2];
            Cost              = $([math]::Round((($GroupedResult.Group.PreTaxCost) | Measure-Object -Sum).sum, 4)*$TaxMultiplier);
            Currency          = $GroupedResultDetails[0];
        } 
    }

    return $DailyCostPerResourceGroup
}

function Measure-DailyCostPerDay {
    [CmdletBinding()]
    param (
        [Parameter()][pscustomobject[]]$Rows,
        [Parameter()][double]$TaxMultiplier
    )
    $GroupedResultsPerDay = $Rows | Group-Object -Property Currency, UsageDateTime

    $DailyCostPerDay = foreach ($GroupedResult in $GroupedResultsPerDay) {
        $GroupedResultDetails = ($GroupedResult.name -split ', ')
        [PSCustomObject]@{
            Date     = ($GroupedResultDetails[1].Split(' '))[0];
            Cost     = $([math]::Round((($GroupedResult.Group.PreTaxCost) | Measure-Object -Sum).sum, 4)*$TaxMultiplier); 
            Currency = $GroupedResultDetails[0];
        } 
    }
    $DailyCostPerDay = $DailyCostPerDay | Sort-Object -Property Date -Descending
    return $DailyCostPerDay
}

function Measure-TotalCostPerRG {
    [CmdletBinding()]
    param (
        [Parameter()][pscustomobject[]]$Rows,
        [Parameter()][double]$TaxMultiplier
    )
    $GroupedResultsTotalCostPerRG = $Rows | group-object -property Currency, ResourceGroup

    $TotalCostPerRG = foreach ($GroupedResult in $GroupedResultsTotalCostPerRG) {
        $GroupedResultDetails = ($GroupedResult.name -split ', ')
        [PSCustomObject]@{
            ResourceGroupName = $GroupedResultDetails[1];
            Cost              = $([math]::Round((($GroupedResult.Group.PreTaxCost) | Measure-Object -Sum).sum, 4)*$TaxMultiplier);
            Currency          = $GroupedResultDetails[0];
        } 
    }
    return $TotalCostPerRG
}

function Measure-TotalCostPerMeterCategory {
    [CmdletBinding()]
    param (
        [Parameter()][pscustomobject[]]$Rows,
        [Parameter()][double]$TaxMultiplier
    )
    $GroupedResultsTotalCostPerMeterCategory = $Rows | group-object -property Currency,MeterCategory

    $TotalCostPerMeterCategory = foreach ($GroupedResult in $GroupedResultsTotalCostPerMeterCategory) {
        $GroupedResultDetails = ($GroupedResult.name -split ', ')
        [PSCustomObject]@{
           MeterCategory =    $GroupedResultDetails[1];
           Cost              = $([math]::Round((($GroupedResult.Group.PreTaxCost) | Measure-Object -Sum).sum, 4)*$TaxMultiplier);
           Currency          = $GroupedResultDetails[0];
        } 
     }
     return $TotalCostPerMeterCategory
}