function Get-LoanAmount {
    [CmdletBinding()]
    param (
        [int32]
        $Price
    )   
    
    process {
        $price2 = $price - 2000
        $convertedprice = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $price2, 0, 0))
    
        [PSCustomObject]@{
            MonthlyWithDeposit = $convertedprice * 1.03
            MonthlyWithInsurance = ($convertedprice * 1.03)  + 50
        }
    }
}

function Get-TeslaPrice {
    [CmdletBinding()]
    param ( 
        [string]
        $URL
    )
    
    $driver = Start-SeFirefox -StartURL $Url -Headless
    $price = (Find-SeElement -By XPath -Selection "/html/body/div[1]/div/div[2]/div/div/div[2]/div[1]/p[3]" -Driver $driver).Text.Split(" ")
    
    $location = (Find-SeElement -By XPath -Selection "/html/body/div[1]/div/div[2]/div/div/div[2]/div[2]/p[2]/span" -Driver $driver).Text.Split(" ")
    
    $originalPrice = ((($Price[1] -replace "HISTORY:").Trim()) -replace "\$")
    $price = $originalPrice - 2000
    $monthly = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.002075, 84, - $price, 0, 0))
    
    $city = ($location[1..2] -replace "Full")[0]
    $state = ($location[1..2] -replace "Full")[1]
    
    if ($state -like "*,*") {
        [string]$city = ($location[1..2] -replace "Full")[0..1] -replace ","
        $state = (($location[3]) -replace "Full").Trim()
    }
    else {
        $city = $city -replace ","
    }
    
    [PSCustomObject]@{
        City                 = $city
        State                = $state
        OriginalPrice        = $originalPrice 
        Price                = $price
        Monthly              = $monthly
        MonthlyWithInsurance = $monthly + "50"
    }
    Stop-SeDriver -Target $driver
}

Export-ModuleMember -Function *