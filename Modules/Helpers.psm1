Set-StrictMode -Version Latest

function New-AuditResult {

    param(

        [string]$Module,

        [object]$Data,

        [System.Collections.ArrayList]$Errors = @()

    )

    [PSCustomObject]@{

        Module = $Module

        Success = ($Errors.Count -eq 0)

        Timestamp = Get-Date

        Data = $Data

        Errors = $Errors

    }

}

function Add-AuditError {

    param(

        [System.Collections.ArrayList]$Collection,

        [string]$Message

    )

    [void]$Collection.Add($Message)

}

Export-ModuleMember -Function *