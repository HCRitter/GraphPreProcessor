function Invoke-GraphScript {
    [CmdletBinding()]
    param (
        $Path,
        [switch]$PreProcess
    )
    
    begin {
        if((Get-Item -Path $Path) -isnot [System.IO.FileInfo]) {
            Write-Warning "The path provided is not a valid file. Please provide a valid file path."
            return
        } 
        $ParentDir = Split-Path -Path $Path -Parent
        $File = Get-ChildItem -Path $Path
       
         
        if($PreProcess){
            $ReadyToExecute = $false
        }
        else{
            $ReadyToExecute = Test-PreProcessedFiles -Path $Path 
        }

    }
    
    process {
        
        if(-not $ReadyToExecute){ 
            Write-Warning "The script is not ready to be executed, and needs to be pre-processed."
            # Start Processing the script
            try{
                Invoke-PreProcessing -Path $Path
            }catch{
                Write-Error "An error occurred during pre-processing: $_"
                return
            }
        }

        # Invoke the GPP script

        Write-Verbose "Executing the script: $Path"

        # Read META file

        Write-Verbose "Reading the META file..."
        $MetaFileContent = Import-CSV -Path $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.Meta") -Delimiter ';'

        $BatchResult = Invoke-BatchRequest -Path $MetaFileContent.GPPJSONPath

        $ScriptSplat = New-Splat -ParamTablePath $MetaFileContent.GPPParamPath -BatchResult $BatchResult

        # Execute the script with the splatted parameters
        Write-Verbose "Executing the script with splatted parameters..."
        $Return = . $MetaFileContent.GPPPS1Path @ScriptSplat    
    }
    
    end {
        return $Return
    }
}