#Import-Files
foreach($Script in $(Get-ChildItem -path $PSScriptRoot -Filter '*.ps1' -Recurse)){
    . $Script.FullName
}

Export-ModuleMember -Function Invoke-GraphScript,Invoke-PreProcessing
