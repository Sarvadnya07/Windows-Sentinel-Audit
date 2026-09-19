Set-StrictMode -Version Latest

<#
.SYNOPSIS
Measures execution time and captures a script block result.

.PARAMETER ScriptBlock
Script block to execute and measure.
#>
function Measure-AuditExecution {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [scriptblock]$ScriptBlock
    )

    $sw = [Diagnostics.Stopwatch]::StartNew()

    try {
        $result = & $ScriptBlock
        $sw.Stop()

        return @{
            Success = $true
            Data = $result
            Errors = @()
            Duration = $sw.ElapsedMilliseconds
        }
    }
    catch {
        $sw.Stop()

        return @{
            Success = $false
            Data = $null
            Errors = @($_)
            Duration = $sw.ElapsedMilliseconds
        }
    }
}

Export-ModuleMember -Function Measure-AuditExecution
