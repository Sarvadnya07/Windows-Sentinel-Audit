Set-StrictMode -Version Latest

function Export-AbuserHunterJson {
    param(
        [Parameter(Mandatory)]$Report,
        [Parameter(Mandatory)][string]$OutputFolder
    )
    $File = Join-Path $OutputFolder ("Audit_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    $Report | ConvertTo-Json -Depth 8 | Out-File $File -Encoding UTF8
    return $File
}

function Export-AbuserHunterCsv {
    param(
        [Parameter(Mandatory)]$Report,
        [Parameter(Mandatory)][string]$OutputFolder
    )
    $Folder = Join-Path $OutputFolder "CSV"
    if(!(Test-Path $Folder)){
        New-Item -ItemType Directory $Folder | Out-Null
    }
    if ($Report.Processes) { $Report.Processes | Export-Csv (Join-Path $Folder "Processes.csv") -NoTypeInformation }
    if ($Report.Network) { $Report.Network | Export-Csv (Join-Path $Folder "Network.csv") -NoTypeInformation }
    if ($Report.Services) { $Report.Services | Export-Csv (Join-Path $Folder "Services.csv") -NoTypeInformation }
    if ($Report.Signatures) { $Report.Signatures | Export-Csv (Join-Path $Folder "Signatures.csv") -NoTypeInformation }
    if ($Report.Persistence) { $Report.Persistence | Export-Csv (Join-Path $Folder "Persistence.csv") -NoTypeInformation }
    if ($Report.Risk) { $Report.Risk | Export-Csv (Join-Path $Folder "Risk.csv") -NoTypeInformation }
    if ($Report.Investigation) { $Report.Investigation | Export-Csv (Join-Path $Folder "Investigation.csv") -NoTypeInformation }
    return $Folder
}

function Export-AbuserHunterHtml {
    param(
        [Parameter(Mandatory)]$Report,
        [Parameter(Mandatory)][string]$OutputFolder
    )
    $File = Join-Path $OutputFolder ("Audit_{0}.html" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    $Html = @"
<html>
<head>
<title>SystemWide-AbuserHunter Report</title>
<style>
body{font-family:Segoe UI;margin:40px;background:#fafafa;}
table{border-collapse:collapse;width:100%;}
th{background:#1f4e79;color:white;padding:6px;}
td{border:1px solid #ccc;padding:5px;}
h1,h2{color:#1f4e79;}
</style>
</head>
<body>
<h1>SystemWide-AbuserHunter</h1>
<h2>Summary</h2>
<table>
<tr><th>Computer</th><td>$($Report.Summary.ComputerName)</td></tr>
<tr><th>User</th><td>$($Report.Summary.UserName)</td></tr>
<tr><th>Generated</th><td>$($Report.Summary.GeneratedAt)</td></tr>
<tr><th>Processes</th><td>$($Report.Summary.ProcessCount)</td></tr>
<tr><th>Connections</th><td>$($Report.Summary.NetworkCount)</td></tr>
<tr><th>Services</th><td>$($Report.Summary.ServiceCount)</td></tr>
<tr><th>Persistence</th><td>$($Report.Summary.PersistenceCount)</td></tr>
<tr><th>High Risk</th><td>$($Report.Summary.HighRiskCount)</td></tr>
</table>
<h2>Highest Risk Findings</h2>
$(($Report.Risk | Sort-Object RiskScore -Descending | Select-Object -First 25 | ConvertTo-Html -Fragment))
<h2>Investigation Summary</h2>
$(($Report.Investigation | Sort-Object RiskScore -Descending | Select-Object -First 50 | ConvertTo-Html -Fragment))
</body>
</html>
"@
    $Html | Out-File $File -Encoding UTF8
    return $File
}
Export-ModuleMember -Function *
