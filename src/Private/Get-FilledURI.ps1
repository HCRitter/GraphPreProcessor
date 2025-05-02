function Get-FilledURI {
    param (
        $Parameters,
        $CommandName
    )
    $URI = $(if(@($Parameters.isIDParameter) -contains $True){
        $IDParameterCounter = @($Parameters | Where-Object {$_.isIDParameter}).count
        foreach($URI in (Find-MgGraphCommand -Command $CommandName).URI){
            if(([regex]::Matches($uri, "-id")).Count -eq $IDParameterCounter){
                foreach($Replacement in $Parameters | Where-Object {$_.isIDParameter}){    
                    $uri = $uri -Replace $Replacement.URIReplacementValue, $Replacement.ParameterValue
                }
                $uri -replace "{", "" -replace "}", "" -replace "\s+", ""
            }
        }
    }else{
        (Find-MgGraphCommand -Command $CommandName).URI | where-object { $_ -notlike "*-ID*" }
    })

    if(($Parameters | where-Object{-not ($_.isIDParameter)}).count -gt 0){
        $Uri += "?"
        $URIDecoration = $Parameters | where-Object{-not ($_.isIDParameter)} | ForEach-Object {
            "$($_.ParameterName)=$($_.ParameterValue)"
        }
        $Uri += $URIDecoration -join "&"
    }
    return $uri
}