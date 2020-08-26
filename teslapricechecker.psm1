function Get-LoanAmount {
    [CmdletBinding()]
    param (
        [int32]
        $price
    )   
    
    process {
        [int32]([Microsoft.VisualBasic.Financial]::Pmt(0.002075, 84, - $price, 0, 0))
    }
    
}

function Get-OnlyUsedTesla {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]  
        [ValidateSet("3", "S", "ALL")]
        [string]
        $Model,

        [ValidateSet("AWD", "RWD", "ALL")]
        [string]
        $Type,

        [string]
        $PriceStart = "33,000",

        [string]
        $PriceEnd = "41,000"
    )
    
    $url = "https://onlyusedtesla.com/listings/?"

    $Body = @{
        "_sft_listing_type"     = "for-sale"
        "_sfm_out_asking_price" = "$pricestart+$priceend"
    }

    switch ($Model) {
        "S" {  
            $body.Add("_sft_model","model-s")
        }
        "3" {
            switch ($Type) {
                "AWD" { 
                    $body.Add("_sft_model","model-3")
                    $body.Add("_sft_battery","long-range-awd")
                }
                "RWD" { 
                    $body.Add("_sft_model","model-3")
                    $body.Add("_sft_battery","long-range-rwd")
                }
                "ALL" {
                    $body.Add("_sft_model","model-3")
                }
                Default {
                    $body.Add("_sft_model","model-3")
                }
            }
        }
        "ALL" {
            $Body = @{
                "_sft_listing_type"     = "for-sale"
                "_sfm_out_asking_price" = "$pricestart+$priceend"
            }
        }
    }

    $Locations = @("Virginia|North Carolina|South Carolina|Georgia|Florida")
    
    try {
        $page = Invoke-WebRequest -uri $url -body $body
    }
    catch {
        Write-Warning "Could not download from $Url" 
        break
    }

    $rawhtml = ConvertFrom-Html $page.RawContent
    
    $table = ((($rawhtml.Descendants()).where{ $_.HasClass("search-filter-results") -eq "True" }))
    
    $cars = $table.Descendants().where{ $_.HasClass("out-list-item") -eq "True" }
    
    $cars | ForEach-Object {
        $carpage = $null
        $car = $_
        $linktoCarPage = Invoke-WebRequest $car.SelectSingleNode(".//a").Attributes["href"].Value
        $link = $car.SelectSingleNode(".//a").Attributes["href"].Value
        $carpage = ConvertFrom-Html $linktoCarPage.rawContent
        $location = $car.Descendants().Where( { $_.InnerText -match "location" -and $_.Name -eq "li" }).Innertext -replace "Location"
        $state = ($location -split ",")[1]
        $Year = $carpage.Descendants().Where( { $_.InnerText -match "Year" -and $_.Name -eq "li" }).Innertext -replace "Year"
        $battery = $carpage.Descendants().Where( { $_.InnerText -match "Battery" -and $_.Name -eq "li" }).Innertext -replace "Battery"
        $price = "{0:C2}" -f (([int](($car.Descendants().where{ $_.HasClass("asking-price") -eq "True" }).InnerText -replace '\D+(\d+)', '$1'))/100)
        $pricecalc = (([int32](($car.Descendants().where{ $_.HasClass("asking-price") -eq "True" }).InnerText -replace '\D+(\d+)', '$1'))/100)
        switch -Regex ($Battery) {
            "RWD" {  
                $zeroto60 = "5.0"
            }
            "AWD" {
                $zeroto60 = "4.4"
            }
            Default {
                $zeroto60 = $null
            }
        }

        if ($state -match $Locations) {
            [PSCustomObject]@{
                AskingPrice = $price
                Monthly     = Get-LoanAmount -Price $pricecalc
                Miles       = [int32](($car.Descendants().Where( { $_.InnerText -match "mileage" -and $_.Name -eq "li" })).InnerText -replace "\D")
                Battery     = $battery
                Location    = $location
                ZeroTo60    = $zeroto60
                Date        = Get-Date ($car.Descendants().Where( { $_.InnerText -match "Listing Date" -and $_.Name -eq "li" }).Innertext -replace "Listing Date").Trim()
                Year        = $year
                Link        = $link
                #VIN         = $carpage.Descendants().Where( { $_.InnerText -match "VIN" -and $_.Name -eq "li" }).Innertext -replace "VIN #"
                Color       = $carpage.Descendants().Where( { $_.InnerText -match "Color" -and $_.Name -eq "li" }).Innertext -replace "Color"
                AutoPilot   = ($carpage.Descendants().Where( { $_.InnerText -match "AutoPilot" -and $_.Name -eq "li" }).Innertext -replace "AutoPilot").Trim()
            }   
        }
    }
}

Export-ModuleMember -Function *