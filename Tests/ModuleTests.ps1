Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$CorePath = Join-Path $Root "Core"
$ModulesPath = Join-Path $Root "Modules"
$ConfigPath = Join-Path $Root "Config"
$Failures = [System.Collections.Generic.List[string]]::new()

<#
.SYNOPSIS
Asserts a condition and throws a descriptive test failure.
#>
function Assert-Condition {
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

<#
.SYNOPSIS
Runs one module test and records failures.
#>
function Invoke-ModuleTest {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$Test
    )

    try {
        & $Test | Out-Null
        Write-Output "PASS: $Name"
    }
    catch {
        [void]$Failures.Add(("{0}: {1}" -f $Name, $_.Exception.Message))
        Write-Output "FAIL: $Name"
    }
}

Invoke-ModuleTest -Name "PowerShell syntax validation" -Test {
    $Files = @(
        Get-ChildItem -Path $CorePath, $ModulesPath -Recurse -File |
            Where-Object { $_.Extension -in @(".ps1", ".psm1") }
        Get-Item -LiteralPath (Join-Path $Root "SystemWide-AbuserHunter.ps1")
    )

    foreach ($File in $Files) {
        $Tokens = $null
        $ParseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$Tokens, [ref]$ParseErrors)
        Assert-Condition -Condition ($ParseErrors.Count -eq 0) -Message "Syntax errors found in $($File.FullName)."
    }
}

Invoke-ModuleTest -Name "Module discovery and import" -Test {
    $ModuleFiles = Get-ChildItem -Path $ModulesPath -Filter *.psm1 -File

    foreach ($ModuleFile in $ModuleFiles) {
        Import-Module $ModuleFile.FullName -Force -ErrorAction Stop
    }

    Assert-Condition -Condition ($null -ne (Get-Command Get-StandardResult -ErrorAction SilentlyContinue)) -Message "Get-StandardResult was not exported."
    Assert-Condition -Condition ($null -ne (Get-Command Invoke-SignatureAudit -ErrorAction SilentlyContinue)) -Message "Invoke-SignatureAudit was not exported."
}

Invoke-ModuleTest -Name "Bootstrap dependency registration" -Test {
    . (Join-Path $CorePath "Bootstrap.ps1") -BasePath $Root

    $RequiredCommands = @(
        "Initialize-AuditCache",
        "Update-AuditCache",
        "Get-AuditCache",
        "Invoke-ProcessAudit",
        "Invoke-NetworkAudit",
        "Invoke-ServiceAudit",
        "Invoke-SignatureAudit",
        "Invoke-PersistenceAudit",
        "Invoke-RiskEngine",
        "Invoke-InvestigationEngine",
        "New-AbuserHunterReport",
        "Export-AbuserHunterJson",
        "Export-AbuserHunterCsv",
        "Export-AbuserHunterHtml",
        "Get-ProcessStatistic",
        "Get-RegistryRunEntry",
        "Get-ScheduledTaskEntry",
        "Get-StartupFolderEntry"
    )

    foreach ($CommandName in $RequiredCommands) {
        Assert-Condition -Condition ($null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)) -Message "Required command is missing: $CommandName"
    }

    Assert-Condition -Condition ($null -ne (Get-Alias Build-AuditCache -ErrorAction SilentlyContinue)) -Message "Build-AuditCache alias is missing."
}

Invoke-ModuleTest -Name "Configuration load and fallback" -Test {
    $Config = Invoke-ConfigValidation -ConfigDir $ConfigPath

    Assert-Condition -Condition ($Config.RiskWeights.InvalidSignature -eq 20) -Message "RiskWeights.json did not load as expected."
    Assert-Condition -Condition ($Config.SuspiciousLocations.Locations.Count -gt 0) -Message "Suspicious locations configuration is empty."
    Assert-Condition -Condition ($Config.TrustedPublishers.Publishers.Count -gt 0) -Message "Trusted publishers configuration is empty."

    $TempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("WindowsSentinelAudit-" + [System.Guid]::NewGuid())
    New-Item -ItemType Directory -Path $TempPath | Out-Null

    try {
        $Fallback = Invoke-ConfigValidation -ConfigDir $TempPath
        Assert-Condition -Condition ($Fallback.RiskWeights.MissingExecutable -eq 15) -Message "Fallback risk weights were not returned."
        Assert-Condition -Condition ($Fallback.SuspiciousLocations.Locations.Count -eq 0) -Message "Fallback configuration was unexpected."
    }
    finally {
        [System.IO.Directory]::Delete($TempPath, $true)
    }
}

Invoke-ModuleTest -Name "Audit cache contract" -Test {
    Initialize-AuditCache
    $Cache = Get-AuditCache

    foreach ($Property in @("ProcessList", "ServiceList", "ProcessLookup", "ServiceLookup", "TCPConnections", "Initialized")) {
        Assert-Condition -Condition $Cache.ContainsKey($Property) -Message "Cache property missing: $Property"
    }

    Assert-Condition -Condition ($Cache.Initialized -eq $true) -Message "Audit cache was not initialized."
}

Invoke-ModuleTest -Name "Execution diagnostics" -Test {
    $Success = Measure-AuditExecution -ScriptBlock { "ok" }
    Assert-Condition -Condition ($Success.Success -eq $true) -Message "Successful execution was not reported as successful."
    Assert-Condition -Condition ($Success.Data -eq "ok") -Message "Execution result data was not preserved."

    $Failure = Measure-AuditExecution -ScriptBlock { throw "expected failure" }
    Assert-Condition -Condition ($Failure.Success -eq $false) -Message "Failed execution was not reported as failed."
}

Invoke-ModuleTest -Name "Heuristic evaluation" -Test {
    $Config = Invoke-ConfigValidation -ConfigDir $ConfigPath
    Assert-Condition -Condition (Test-SuspiciousLocation -Path "C:\Users\Public\tool.exe" -Config $Config) -Message "Suspicious-location detection failed."
    Assert-Condition -Condition (Test-TrustedPublisher -Publisher "CN=Microsoft Corporation" -Config $Config) -Message "Trusted-publisher detection failed."
}

Invoke-ModuleTest -Name "Risk-level boundaries" -Test {
    $Expected = @{
        10 = "Informational"
        25 = "Low"
        45 = "Medium"
        65 = "High"
        90 = "Critical"
    }

    foreach ($Score in $Expected.Keys) {
        $Actual = Get-RiskLevel -Score $Score
        Assert-Condition -Condition ($Actual -eq $Expected[$Score]) -Message "Score $Score mapped to '$Actual'."
    }
}

Invoke-ModuleTest -Name "Risk engine signature contract" -Test {
    $Config = Invoke-ConfigValidation -ConfigDir $ConfigPath

    $Processes = @([PSCustomObject]@{
        ProcessName = "test.exe"
        PID = 4242
        Path = "C:\Windows\System32\test.exe"
    })

    $ValidSignature = @([PSCustomObject]@{
        PID = 4242
        SignatureStatus = "Valid"
        Signer = "CN=Microsoft Corporation"
    })

    $InvalidSignature = @([PSCustomObject]@{
        PID = 4242
        SignatureStatus = "NotSigned"
        Signer = $null
    })

    $ValidResult = Invoke-RiskEngine -Processes $Processes -Signatures $ValidSignature -Connections @() -Config $Config
    $InvalidResult = Invoke-RiskEngine -Processes $Processes -Signatures $InvalidSignature -Connections @() -Config $Config

    Assert-Condition -Condition ($ValidResult[0].PID -eq 4242) -Message "Risk result did not preserve PID."
    Assert-Condition -Condition ($InvalidResult[0].RiskScore -gt $ValidResult[0].RiskScore) -Message "SignatureStatus was not used correctly by the risk engine."
}

Invoke-ModuleTest -Name "Correlation and investigation" -Test {
    $Process = [PSCustomObject]@{
        ProcessName = "test.exe"
        PID = 4242
        ParentPID = 1
        Path = "C:\Users\Public\test.exe"
    }

    $Network = @([PSCustomObject]@{
        ProcessId = 4242
        LocalAddress = "127.0.0.1"
        LocalPort = 5000
        RemoteAddress = "203.0.113.10"
        RemotePort = 443
        State = "Established"
    })

    $Correlation = Invoke-CorrelationEngine
    Assert-Condition -Condition ($null -ne $Correlation) -Message "Correlation engine returned no result."

    $Risk = @([PSCustomObject]@{
        PID = 4242
        RiskScore = 42
        RiskLevel = "Medium"
        Reasons = "test"
    })

    $Investigation = Invoke-InvestigationEngine -Processes @($Process) -Network $Network -Services @() -Persistence @() -Risk $Risk

    Assert-Condition -Condition ($Investigation[0].ConnectionCount -eq 1) -Message "Investigation correlation count is incorrect."
    Assert-Condition -Condition ($Investigation[0].RiskLevel -eq "Medium") -Message "Investigation risk level is incorrect."
}

Invoke-ModuleTest -Name "Report and export engines" -Test {
    $TempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("WindowsSentinelAudit-Report-" + [System.Guid]::NewGuid())
    New-Item -ItemType Directory -Path $TempPath | Out-Null

    try {
        $ProcessData = @([PSCustomObject]@{ ProcessName = "test.exe"; PID = 4242; Path = "C:\Users\Public\test.exe" })
        $RiskData = @([PSCustomObject]@{ ProcessName = "test.exe"; PID = 4242; RiskScore = 42; RiskLevel = "Medium"; Reasons = "test" })
        $InvestigationData = @([PSCustomObject]@{ ProcessName = "test.exe"; PID = 4242; RiskScore = 42; RiskLevel = "Medium" })

        $Report = New-AbuserHunterReport -ProcessAudit @{ Data = $ProcessData } -NetworkAudit @{ Data = @() } -ServiceAudit @{ Data = @() } -SignatureAudit @{ Data = @() } -PersistenceAudit @{ Data = @() } -RiskResults $RiskData -Investigation $InvestigationData
        $JsonFile = Export-AbuserHunterJson -Report $Report -OutputFolder $TempPath
        $CsvFolder = Export-AbuserHunterCsv -Report $Report -OutputFolder $TempPath
        $HtmlFile = Export-AbuserHunterHtml -Report $Report -OutputFolder $TempPath

        Assert-Condition -Condition (Test-Path -LiteralPath $JsonFile) -Message "JSON export was not created."
        Assert-Condition -Condition (Test-Path -LiteralPath $HtmlFile) -Message "HTML export was not created."
        Assert-Condition -Condition (Test-Path -LiteralPath (Join-Path $CsvFolder "Processes.csv")) -Message "Processes.csv was not created."
    }
    finally {
        [System.IO.Directory]::Delete($TempPath, $true)
    }
}

Invoke-ModuleTest -Name "Utility and result helpers" -Test {
    Assert-Condition -Condition ((Convert-FileSize -Bytes 1024) -eq "1.00 KB") -Message "Convert-FileSize returned an unexpected result."
    Assert-Condition -Condition (Test-PrivateIP -IPAddress "192.168.1.5") -Message "Private IPv4 detection failed."
    Assert-Condition -Condition (-not (Test-PrivateIP -IPAddress "8.8.8.8")) -Message "Public IPv4 was classified as private."

    $Result = New-AuditResult -Module "Test" -Data "ok"
    $Standard = Get-StandardResult -Module "Test" -Data @("ok")

    Assert-Condition -Condition $Result.Success -Message "New-AuditResult returned an unsuccessful result."
    Assert-Condition -Condition ($Standard.Data.Count -eq 1) -Message "Get-StandardResult returned unexpected data."
}

Invoke-ModuleTest -Name "Read-only audit surface" -Test {
    $TargetFiles = @(
        Get-ChildItem -Path $CorePath, $ModulesPath -Recurse -File |
            Where-Object { $_.Extension -in @(".ps1", ".psm1") }
        Get-Item -LiteralPath (Join-Path $Root "SystemWide-AbuserHunter.ps1")
    )

    $Forbidden = '\b(Set-Item|Set-ItemProperty|Remove-Item|Remove-ItemProperty|Stop-Process|Stop-Service|Set-Service)\b'

    foreach ($File in $TargetFiles) {
        $Matches = Select-String -LiteralPath $File.FullName -Pattern $Forbidden -AllMatches -CaseSensitive
        Assert-Condition -Condition ($null -eq $Matches) -Message "State-mutating cmdlet reference found in $($File.FullName)."
    }
}

if ($Failures.Count -gt 0) {
    Write-Output ""
    Write-Output "Module test failures:"
    foreach ($Failure in $Failures) {
        Write-Output " - $Failure"
    }
    exit 1
}

Write-Output ""
Write-Output "All module tests passed."
exit 0
