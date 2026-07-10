# Development Guide

This guide explains how to extend AbuserHunter by adding a new audit module.

## Step 1: Create the Module
Create a new file in `Modules/`, for example: `Modules/DriverAudit.psm1`.

```powershell
Set-StrictMode -Version Latest

function Invoke-DriverAudit {
    $Output = @()
    # Your logic here
    return [PSCustomObject]@{
        Module = "Driver"
        Data = $Output
    }
}
Export-ModuleMember -Function *
```

## Step 2: Register the Module
Open `Core/DependencyLoader.ps1` and append your module to the `$modules` array:
```powershell
    "Modules\DriverAudit.psm1",
```

## Step 3: Invoke the Module
Open `SystemWide-AbuserHunter.ps1`, invoke your module inside a `try/catch` block, and capture the execution time using the existing `$sw` stopwatch.

## Step 4: Update the Report Engine
If your module generates data that should be exported, update `Modules/ReportEngine.psm1` to accept your new data as a parameter and include it in the returned `[PSCustomObject]`. Also update `Modules/ExportEngine.psm1` to dump it as a CSV.
