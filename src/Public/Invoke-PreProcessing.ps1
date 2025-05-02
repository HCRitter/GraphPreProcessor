function Invoke-PreProcessing {
    [CmdletBinding()]
    param (
        $Path
    )
    
    begin {
        $File = Get-ChildItem -Path $Path
        $ParentDir = Split-Path -Path $File.FullName -Parent

        New-Item -Path $(Join-Path -Path $ParentDir -ChildPath '.GPP\') -ItemType Directory -Force | Out-Null
        $MetaFilePath = $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.Meta")
        $MetaFileInfo = [pscustomobject]@{
            GPPJSONPath = $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.JSON")
            GPPParamPath = $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.PARAM")
            GPPPS1Path = $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.PS1")
            CreatedWhen = (Get-Date).ToShortDateString()
            FileHash = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
            FileName = $File.Name
        } 
        $MetaFileInfo | Export-Csv -Path $MetaFilePath -Delimiter ';' -NoTypeInformation -ErrorAction Stop -Force

        Write-Verbose "Meta file created at: $MetaFilePath"

        

        
    }
    
    process {
        $GraphCommands = Get-GraphCommands -Path $Path -ErrorAction Stop

        $ScriptHead = @()
        $ScriptHead += 'Param('
        $ScriptHead += $($GraphCommands.VariableName -join ',')
        $ScriptHead += ')'

        New-BatchRequestFile -Path $MetaFileInfo.GPPJSONPath -GraphCommands $GraphCommands -ErrorAction Stop

        Write-Verbose "Batch request file created at: $($MetaFileInfo.GPPJSONPath)"

        New-ParameterTable -Commands $GraphCommands -Path $MetaFileInfo.GPPParamPath -ErrorAction Stop

        Write-Verbose "Parameter table created at: $($MetaFileInfo.GPPParamPath)"


        write-verbose 'Creating PS1 file...'
        $IgnoredLines = $GraphCommands | Select-Object -ExpandProperty LineNumber

        $ReadingLine = 1

        $Content = switch -file ($Path){
            {$IgnoredLines -contains $ReadingLine}{
                Write-Verbose "Ignoring line: $($_.LineNumber)"
                $ReadingLine++
                continue
            }
            default {
                $ReadingLine++
                Write-Verbose "Reading line: $($_.LineNumber)"
                $_
            }
        }
        $Content = $ScriptHead + $Content

        $Content | Out-File -Path $MetaFileInfo.GPPPS1Path -Force -ErrorAction Stop
        Write-Verbose "PS1 file created at: $($MetaFileInfo.GPPPS1Path)"
    }
    
    end {

    }
}