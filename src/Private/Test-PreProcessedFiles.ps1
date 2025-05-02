function Test-PreProcessedFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )
    
    begin {
        if((Get-Item -Path $Path) -isnot [System.IO.FileInfo]) {
            Write-Warning "The path provided is not a valid file. Please provide a valid file path."
            return
        } 
        $ParentDir = Split-Path -Path $Path -Parent
        $File = Get-ChildItem -Path $Path 
        $Result = $false
    }
    
    process {
        Write-Verbose "Processing file: $Path"
        if(Test-Path -Path $(Join-Path -Path $ParentDir -ChildPath '.GPP\')){
            Write-Verbose 'Found .GPP directory'
            Write-Verbose 'Checking for pre-processed files...'

            $PreProcessedFiles = Get-ChildItem -Path $(Join-Path -Path $ParentDir -ChildPath '\.GPP\') -Recurse -File 
            $GPPIntegrityCheck = [PSCustomObject]@{
                Meta = $false
                PS1 = $false
                JSON = $false
                PARAMS = $false
            }
            Switch($PreProcessedFiles){
                {$_.FullName -like "*$($File.BaseName).GPP.Meta"}{
                    $GPPIntegrityCheck.Meta = $true
                    Write-Verbose "Found Meta file: $($_.FullName)"

                }
                {$_.FullName -like "*$($File.BaseName).GPP.PS1"}{
                    $GPPIntegrityCheck.PS1 = $true
                    Write-Verbose "Found PS1 file: $($_.FullName)"
                }
                {$_.FullName -like "*$($File.BaseName).GPP.JSON"}{
                    $GPPIntegrityCheck.JSON = $true
                    Write-Verbose "Found JSON file: $($_.FullName)"
                }
                {$_.FullName -like "*$($File.BaseName).GPP.PARAM"}{
                    $GPPIntegrityCheck.PARAMS = $true
                    Write-Verbose "Found PARAM file: $($_.FullName)"
                }
                default {
                    Write-Verbose "$($_.BaseName) is not a pre-processed file."
                }
            }
            if($GPPIntegrityCheck.Meta -and $GPPIntegrityCheck.PS1 -and $GPPIntegrityCheck.JSON){
                Write-Verbose "All pre-processed files are present."
                $Result = $true
            } else {
                Write-Warning "Not all pre-processed files are present. Please check the .GPP directory."
                $Result = $false
            }
            Write-Verbose 'Checking Meta file...'
            $MetaFileContent = Import-CSV -Path $(Join-Path -Path $ParentDir -ChildPath ".GPP\$($File.BaseName).GPP.Meta") -Delimiter ';' 
            $FileHash = Get-FileHash -Path $Path -Algorithm SHA256
            $MetaFileHash = $MetaFileContent.FileHash
            if($FileHash.Hash -eq $MetaFileHash){
                Write-Verbose "The file hash matches the hash in the Meta file."
                $Result = $true
            } else {
                Write-Warning "The file hash does not match the hash in the Meta file."
                Write-Warning "File hash: $($FileHash.Hash)"
                Write-Warning "Meta file hash: $($MetaFileHash)"
                $Result = $false
            }
        }else{
            Write-Warning "The .GPP directory does not exist."
            $Result = $false
        }
    }
    
    end {
        return $Result
    }
}