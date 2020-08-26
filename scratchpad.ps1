Remove-Module teslapricechecker -ErrorAction SilentlyContinue
Import-module /Users/jmoss/TeslaPriceChecker/teslapricechecker.psm1

$report = Get-OnlyUsedTesla -Model 3 -Type RWD -PriceStart "35000" -PriceEnd "43000"
$report += Get-OnlyUsedTesla -Model 3 -Type AWD -PriceStart "35000" -PriceEnd "43000"
