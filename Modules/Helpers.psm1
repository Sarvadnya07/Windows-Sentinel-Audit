Set-StrictMode -Version Latest

<#
.SYNOPSIS
Creates a structured result object for an audit module.

.PARAMETER Module
Logical module name.

.PARAMETER Data
Audit data returned by the module.

.PARAMETER Errors
Errors collected during execution.
#>
function New-AuditResult {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Scope = 'Function',
        Target = '*',
        Justification = 'This function constructs an in-memory result object only.'
    )]
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

<#
.SYNOPSIS
Returns a standard audit result with optional data and errors.

.PARAMETER Module
Logical module name.

.PARAMETER Data
Audit data returned by the module.

.PARAMETER Errors
Errors collected during execution.
#>
function Get-StandardResult {
    param(
        [string]$Module = "Unknown",
        [object]$Data = @(),
        [object[]]$Errors = @()
    )

    $collection = [System.Collections.ArrayList]::new()

    foreach ($ErrorItem in $Errors) {
        if ($null -ne $ErrorItem) {
            [void]$collection.Add($ErrorItem)
        }
    }

    return New-AuditResult -Module $Module -Data $Data -Errors $collection
}

<#
.SYNOPSIS
Adds an audit error to an error collection.

.PARAMETER Collection
ArrayList that receives the message.

.PARAMETER Message
Error message to add.
#>
function Add-AuditError {
    param(
        [System.Collections.ArrayList]$Collection,
        [string]$Message
    )

    [void]$Collection.Add($Message)
}

Export-ModuleMember -Function New-AuditResult, Get-StandardResult, Add-AuditError
