function Measure-AuditExecution {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )
    $sw = [Diagnostics.Stopwatch]::StartNew()
    try {
        $result = & $ScriptBlock
        $sw.Stop()
        return @{ Success = $true; Data = $result; Errors = @(); Duration = $sw.ElapsedMilliseconds }
    } catch {
        $sw.Stop()
        return @{ Success = $false; Data = $null; Errors = @($_); Duration = $sw.ElapsedMilliseconds }
    }
}
Export-ModuleMember -Function Measure-AuditExecution
