Remove-Module teslapricechecker -ErrorAction SilentlyContinue
Import-module /Users/jmoss/TeslaPriceChecker/teslapricechecker.psm1

$results = @()

## Illinois
$results += Get-TeslaPrice -URL "https://teslacpo.io/vin/5YJ3E1EB6JF073858"

$results | ft -AutoSize

break

$url = "https://teslacpo.io/vin/5YJ3E1EB8JF112725"
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
    City = $city
    State = $state
    OriginalPrice        = $originalPrice 
    Price                = $price
    Monthly              = $monthly
    MonthlyWithInsurance = $monthly + "50"
}
Stop-SeDriver -Target $driver


$json = @"
{
    "query": {
      "model": "m3",
      "condition": "used",
      "options": {
        "TRIM": [
          "MRRWD",
          "LRRWD",
          "LRAWD"
        ],
        "AUTOPILOT": [
          "AUTOPILOT_FULL_SELF_DRIVING"
        ]
      },
      "arrangeby": "Price",
      "order": "asc",
      "market": "US",
      "language": "en",
      "super_region": "north america",
      "lng": -122.1257,
      "lat": 47.6722,
      "zip": "98052",
      "range": 0
    },
    "offset": 0,
    "count": 50,
    "outsideOffset": 0,
    "outsideSearch": false
  }
"@

Invoke-RestMethod -uri "https://www.tesla.com/inventory/api/v1/inventory-results" -Body $json -ContentType "application/json"

https://www.tesla.com/inventory/api/v1/inventory-results?query=%7B%22query%22%3A%7B%22model%22%3A%22m3%22%2C%22condition%22%3A%22used%22%2C%22options%22%3A%7B%22TRIM%22%3A%5B%22MRRWD%22%2C%22LRRWD%22%2C%22LRAWD%22%5D%2C%22AUTOPILOT%22%3A%5B%22AUTOPILOT_FULL_SELF_DRIVING%22%5D%7D%2C%22arrangeby%22%3A%22Price%22%2C%22order%22%3A%22asc%22%2C%22market%22%3A%22US%22%2C%22language%22%3A%22en%22%2C%22super_region%22%3A%22north%20america%22%2C%22lng%22%3A-122.1257%2C%22lat%22%3A47.6722%2C%22zip%22%3A%2298052%22%2C%22range%22%3A0%7D%2C%22offset%22%3A0%2C%22count%22%3A50%2C%22outsideOffset%22%3A0%2C%22outsideSearch%22%3Afalse%7D


$decode = [System.Web.HttpUtility]::URLDecode($query)

$json = @"
{
    "query": {
      "model": "m3",
      "condition": "used",
      "options": {
        "TRIM": [
          "MRRWD",
          "LRRWD",
          "LRAWD"
        ],
        "AUTOPILOT": [
          "AUTOPILOT_FULL_SELF_DRIVING"
        ]
      },
      "arrangeby": "Price",
      "order": "asc",
      "market": "US",
      "language": "en",
      "super_region": "north america",
      "lng": -122.1257,
      "lat": 47.6722,
      "zip": "98052",
      "range": 0
    },
    "offset": 0,
    "count": 50,
    "outsideOffset": 0,
    "outsideSearch": false
  }
"@

$search = $json | Convertfrom-Json