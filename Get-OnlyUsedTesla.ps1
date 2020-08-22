function Get-OnlyUsedTesla {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]  
        [ValidateSet("AWD", "RWD", "ALL")]
        [string]
        $Type
    )
    
    $url = "https://onlyusedtesla.com/listings/?"

    $body = @{
        "_sft_model"            = "model-3"
        "_sft_listing_type"     = "for-sale"
        "_sfm_out_asking_price" = "517+42000"
    }

    $Locations = @("Virginia|North Carolina|South Carolina|Georgia")

    switch ($type) {
        "AWD" {
            $body.Add("_sft_battery", "long-range-awd")
        }
        "RWD" {
            $body.Add("_sft_battery", "long-range-rwd")
        }
        "ALL" {
            $body.Add("_sft_battery", "long-range")
        }
    }
    
    try {
        $page = Invoke-WebRequest -uri $url -body $body
    }
    catch {
        Write-Warning "Could not find $s" 
        break
    }

    $rawhtml = ConvertFrom-Html $page.RawContent
    
    $table = ((($rawhtml.Descendants()).where{ $_.HasClass("search-filter-results") -eq "True" }))
    
    $cars = $table.Descendants().where{ $_.HasClass("out-list-item") -eq "True" }
    
    $cars | ForEach-Object {
        $carpage = $null
        $car = $_
        $linktoCarPage = Invoke-WebRequest $car.SelectSingleNode(".//a").Attributes["href"].Value
        $carpage = ConvertFrom-Html $linktoCarPage.rawContent
        $location = $car.Descendants().Where( { $_.InnerText -match "location" -and $_.Name -eq "li" }).Innertext -replace "Location"
        $state = ($location -split ",")[1]
        if ($state -match $Locations) {
            [PSCustomObject]@{
                AskingPrice = "{0:C2}" -f (([int](($car.Descendants().where{ $_.HasClass("asking-price") -eq "True" }).InnerText -replace '\D+(\d+)', '$1'))/100)
                Miles       = [int32](($car.Descendants().Where( { $_.InnerText -match "mileage" -and $_.Name -eq "li" })).InnerText -replace "\D")
                Battery     = $carpage.Descendants().Where( { $_.InnerText -match "Battery" -and $_.Name -eq "li" }).Innertext -replace "Battery"
                Location    = $car.Descendants().Where( { $_.InnerText -match "location" -and $_.Name -eq "li" }).Innertext -replace "Location"
                Date        = Get-Date ($car.Descendants().Where( { $_.InnerText -match "Listing Date" -and $_.Name -eq "li" }).Innertext -replace "Listing Date").Trim()
                Link        = $car.SelectSingleNode(".//a").Attributes["href"].Value
                #VIN         = $carpage.Descendants().Where( { $_.InnerText -match "VIN" -and $_.Name -eq "li" }).Innertext -replace "VIN #"
                Color       = $carpage.Descendants().Where( { $_.InnerText -match "Color" -and $_.Name -eq "li" }).Innertext -replace "Color"
                AutoPilot   = ($carpage.Descendants().Where( { $_.InnerText -match "AutoPilot" -and $_.Name -eq "li" }).Innertext -replace "AutoPilot").Trim()
            }   
        }
    }
}