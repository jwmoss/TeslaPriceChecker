Remove-Module teslapricechecker -ErrorAction SilentlyContinue
Import-module /Users/jmoss/TeslaPriceChecker/teslapricechecker.psm1

$report = @()

$rwd = Get-OnlyUsedTesla -Model 3 -Type RWD -PriceStart "35000" -PriceEnd "46000"
$awd = Get-OnlyUsedTesla -Model 3 -Type AWD -PriceStart "35000" -PriceEnd "46000" 

if ($null -ne $rwd) {
    $report += $rwd
}

if ($null -ne $awd) {
    $report += $awd
}

$final = foreach ($thing in $report) {
    if ($thing.Date -gt (Get-Date).AddDays(-1)) {
        $thing
    }
}

$final
