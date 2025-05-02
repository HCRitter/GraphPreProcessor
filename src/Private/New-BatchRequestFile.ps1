function New-BatchRequestFile {
    [CmdletBinding()]
    param (
        $path,
        $GraphCommands
    )
    
    begin {
        
    }
    
    process {
        $ID = 0
        $GraphCalls = foreach($GraphCommand in $GraphCommands | Sort-Object -Property LineNumber){

            [pscustomObject]@{
                id = [int]$ID
                method = $GraphCommand.Method
                URL = $GraphCommand.URI
            }
            $ID++
        }
        $BatchRequestBody = [PSCustomObject]@{requests = $GraphCalls }
        $JSONRequests = $BatchRequestBody | ConvertTo-Json -Depth 4
        $JSONRequests | Out-File -Path $path -Force -ErrorAction Stop
        Write-Verbose "Batch request file created at: $path"
    }
    
    end {
        
    }
}