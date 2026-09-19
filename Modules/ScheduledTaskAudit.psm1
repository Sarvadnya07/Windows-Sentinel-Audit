Set-StrictMode -Version Latest

<#
.SYNOPSIS
Reads scheduled-task metadata without changing task state.
#>
function Get-ScheduledTaskEntry {
    $Results = @()

    try {
        Get-ScheduledTask | ForEach-Object {
            $Action = $_.Actions | Select-Object -First 1
            $Trigger = $_.Triggers | Select-Object -First 1

            $Results += [PSCustomObject]@{
                Type = "ScheduledTask"
                Name = $_.TaskName
                Path = $_.TaskPath
                State = $_.State
                Execute = $Action.Execute
                Arguments = $Action.Arguments
                TriggerType = $Trigger.TriggerType
            }
        }
    }
    catch {
        Write-Verbose (
            "Scheduled-task enumeration failed: {0}" -f
            $_.Exception.Message
        )
    }

    return $Results
}

Set-Alias -Name Get-ScheduledTaskEntries -Value Get-ScheduledTaskEntry -Scope Script

Export-ModuleMember -Function Get-ScheduledTaskEntry -Alias Get-ScheduledTaskEntries
