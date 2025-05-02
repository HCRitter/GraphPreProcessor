function Invoke-BatchRequest {
    [CmdletBinding()]
    param (
        $Path
    )
    
    begin {
        $JSONContent = Get-Content -Path $Path
        $JSONRequests = $JSONContent | ConvertFrom-JSON -Depth 4 -ErrorAction Stop
        $JSONRequests = $JSONRequests | ConvertTo-Json -Depth 4 -ErrorAction Stop
    }
    
    process {
        $Results = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/$batch' -Body $JSONRequests -ContentType 'application/json' -ErrorAction Stop
        if($Results.responses.Status -ne 200){
            Write-Warning "Batch request failed with status code: $($Results.responses.Status)"
            return
        }
    }
    
    end {
        return $Results
    }
}