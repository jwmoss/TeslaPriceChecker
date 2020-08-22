$url = "https://onlyusedtesla.com/listings/?"

## ?_sft_model=model-3&_sft_listing_type=for-sale&_sft_battery=long-range-awd&_sfm_out_asking_price=517+60202

$body = @{
    "_sft_model" = "model-3"
    "_sft_listing_type" = "for-sale"
    "_sft_battery" = "long-range-awd"
    "_sfm_out_asking_price" = "517+60202"
}

iwr -uri $url -body $body