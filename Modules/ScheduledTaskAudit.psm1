Set-StrictMode -Version Latest

function Get-ScheduledTaskEntries {
    $Results=@()
    try{
        Get-ScheduledTask | ForEach-Object{
            $Action=$_.Actions | Select-Object -First 1
            $Trigger=$_.Triggers | Select-Object -First 1
            $Results += [PSCustomObject]@{
                Type="ScheduledTask"
                Name=$_.TaskName
                Path=$_.TaskPath
                State=$_.State
                Execute=$Action.Execute
                Arguments=$Action.Arguments
                TriggerType=$Trigger.TriggerType
            }
        }
    }
    catch{
    }
    return $Results
}

Export-ModuleMember -Function *
