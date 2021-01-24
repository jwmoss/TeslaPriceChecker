function Get-LoanAmount {
    [CmdletBinding()]
    param (
        [int32]
        $Price
    )   
    
    process {
        $2k = $price - 2000
        $4k = $price - 4000
        $5k = $price - 5000
        
        $2kfinal = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $2k, 0, 0))
        $4kfinal = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $4k, 0, 0))
        $5kfinal = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $5k, 0, 0))

        [PSCustomObject]@{
            Monthly = [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $price, 0, 0)) * 1.03
            MonthlyInsurance = ([int32]([Microsoft.VisualBasic.Financial]::Pmt(0.001999, 84, - $price, 0, 0)) * 1.03) + 50
            Monthly2K = $2kfinal * 1.03
            Monthly2KInsurance = ($2kfinal * 1.03)  + 50
            Monthly4K = $4kfinal * 1.03
            Monthly4KInsurance = ($4kfinal * 1.03)  + 50
            Monthly5K = $5kfinal * 1.03
            Monthly5KInsurance = ($5kfinal * 1.03) + 50
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