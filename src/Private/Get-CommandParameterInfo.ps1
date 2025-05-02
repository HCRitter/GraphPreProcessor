function Get-CommandParameterInfo {
    param (
        [string]$Command
    )

    $scriptBlock = [scriptblock]::Create($Command)
    $ast = $scriptBlock.Ast

    $commandAst = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)[0]

    $parameterInfo = foreach ($element in $commandAst.CommandElements) {
        if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            $paramName = $element.ParameterName
            $nextElement = $commandAst.CommandElements[$commandAst.CommandElements.IndexOf($element) + 1]

            switch ($nextElement) {
                {$_ -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
                 $_ -is [System.Management.Automation.Language.VariableExpressionAst] -or
                 $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst] -or
                 $_ -is [System.Management.Automation.Language.ConstantExpressionAst]} {
                    $paramValue = $nextElement.Value
                }
                {$_ -is [System.Management.Automation.Language.ArrayExpressionAst]} {
                    $paramValue = $nextElement.SubExpressions.Value
                }
                default {
                    # It's a switch parameter (like -all)
                    $paramValue = $true  # Or $null, depending on how you want to represent it
                }
            }

            [PSCustomObject]@{
                ParameterName = $paramName
                ParameterValue = $paramValue
                isIDParameter = [bool]($paramName -like "*ID")  # Check if the parameter name ends with "ID"
                URIReplacementValue = if ($paramName -like "*ID") {
                    $paramName.Insert($paramName.Length - 2, "-")
                } else {
                    $null
                }
            }
        }
    }

    return $parameterInfo
}