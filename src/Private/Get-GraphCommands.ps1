function Get-GraphCommands {
    [CmdletBinding()]
    param (
        $Path
    )
    
    begin {
        $Scriptblock = Get-Content $Path -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Scriptblock,[ref]$null, [ref]$null)
    }
    
    process {
        $assignments = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.AssignmentStatementAst]}, $true)
        # Filter assignments where the right-hand side is a command
        $commands = $assignments | Where-Object {
            $rhs = $_.Right
            $rhs -is [System.Management.Automation.Language.CommandExpressionAst] -or
            $rhs -is [System.Management.Automation.Language.CommandAst] -or
            ($rhs -is [System.Management.Automation.Language.PipelineAst] -and $rhs.PipelineElements.Count -gt 0)
        }
        # Create a generic list to store command names and parameters
        $GraphCallList = [System.Collections.Generic.List[object]]::new()
        # Filter out commands that are not from Microsoft.Graph module
        $commands | Where-Object {
            (Get-Command -name $($_.Right).ToString().split(' ')[0]).source -like 'Microsoft.Graph*'
        } |ForEach-Object {
            $GraphCallList.add(
                [PSCustomObject]@{
                    VariableName    = '$'+$_.Left.VariablePath.UserPath
                    LineNumber      = $_.Extent.StartLineNumber
                    Command         = $Command      = $($_.Right.ToString().split("|")[0]).ToString()
                    CommandName     = $CommandName  = $_.Right.ToString().split(' ')[0]
                    Parameters      = $Parameters   = Get-CommandParameterInfo -Command $Command
                    Method          = Find-MgGraphCommand -Command $CommandName | Select-Object -ExpandProperty Method | Select-Object -First 1
                    URI             = Get-FilledURI -Parameters $Parameters -CommandName $CommandName
                    IsDependent     = $false
                }
            )
        }

        # Check if the command is dependent on another command
        foreach ($command in $GraphCallList) {
            foreach($VariableName in $GraphCallList.VariableName){
                if($command.command -like "*`$$VariableName.*"){
                    $command.IsDependent = $true
                }
            }  
        }
    }
    
    end {
        return $GraphCallList | Where-Object { $_.IsDependent -eq $false -and $_.Method -eq 'GET'} | Select-Object VariableName, LineNumber, Command, CommandName, Parameters, Method, URI
    }
}