function Get-IDParameter {
    [CmdletBinding()]
    param (
        $ParameterNames
    )
    
    begin {

    }
    
    process {
        $Replacements = foreach($ParameterName in @($ParameterNames)){
            if($ParameterName -like "*ID"){
                [pscustomobject]@{
                    ParameterName = $ParameterName
                    ReplacementValue = $ParameterName.Insert($ParameterName.Length - 2, "-")
                }
            }
        }
    }
    
    end {
        return $Replacements
    }
}