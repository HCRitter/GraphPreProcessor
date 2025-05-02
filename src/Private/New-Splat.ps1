function New-Splat {
    [CmdletBinding()]
    param (
        $ParamTablePath,
        $BatchResult
    )
    
    begin {
        $CallingSplat = @{}
        try {
            $ParamTable = import-csv -Path $ParamTablePath -Delimiter ';' -ErrorAction Stop
            
        }
        catch {
            Write-Error "Error importing parameter table: $($_.Exception.Message)"
            return
        }


    }
    
    process {
        foreach($ParamObject in $ParamTable){
            $CallingSplat["$($ParamObject.VariableName)"] = ($BatchResult.Responses | Where-Object { $_.Id -eq $ParamObject.Id }).Body.Value
        }
    }
    
    end {
        return $CallingSplat
    }
}