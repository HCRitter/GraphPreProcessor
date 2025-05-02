function New-ParameterTable {
    [CmdletBinding()]
    param (
        $Commands,
        $Path
    )
    
    begin {
        
    }
    
    process {
        $ID = 0
        $(foreach($Command in $Commands | Sort-Object -Property LineNumber){
            [pscustomobject]@{
                VariableName = $Command.VariableName.replace('$','')
                ID = [int]$ID
            } 
            $ID++
        })| Export-Csv -Path $Path -Delimiter ';' -NoTypeInformation -ErrorAction Stop -Force

    }
    
    end {
        
    }
}