Set-StrictMode -Version Latest

function Get-RiskLevel {
    param([int]$Score)
    switch ($Score) {
        {$_ -lt 20} { "Informational"; break }
        {$_ -lt 40} { "Low"; break }
        {$_ -lt 60} { "Medium"; break }
        {$_ -lt 80} { "High"; break }
        default { "Critical" }
    }
}

function Invoke-RiskEngine {
    param(
        [Parameter(Mandatory)]$Processes,
        [Parameter(Mandatory)]$Signatures,
        [Parameter(Mandatory)]$Connections,
        [Parameter(Mandatory)]$Config
    )

    $Weights = $Config.RiskWeights

    $SignatureLookup = @{}
    foreach($S in $Signatures){
        $SignatureLookup[$S.PID] = $S
    }

    $ConnectionCounts = @{}
    foreach($C in $Connections){
        if(!$ConnectionCounts.ContainsKey($C.ProcessId)){
            $ConnectionCounts[$C.ProcessId] = 0
        }
        $ConnectionCounts[$C.ProcessId]++
    }

    $Results = foreach($P in $Processes){
        $Score = 0
        $Reasons = New-Object System.Collections.Generic.List[string]

        $Sig = $SignatureLookup[$P.PID]

        if($Sig){
            if($Sig.Status -ne "Valid"){
                $Score += $Weights.InvalidSignature
                $Reasons.Add("Invalid digital signature")
            }
            if(Test-TrustedPublisher -Publisher $Sig.Signer -Config $Config){
                $Score += $Weights.TrustedPublisher
                $Reasons.Add("Trusted publisher")
            }
        }
        else{
            $Score += $Weights.MissingExecutable
            $Reasons.Add("Executable not available")
        }

        if($P.Path){
            if(Test-SuspiciousLocation -Path $P.Path -Config $Config){
                $Score += $Weights.UserWritableLocation
                $Reasons.Add("Running from Suspicious Location")
            }
            if($P.Path -match "^C:\\Windows\\System32"){
                $Score += $Weights.SystemDirectory
                $Reasons.Add("Windows system directory")
            }
        }

        if($ConnectionCounts.ContainsKey($P.PID)){
            $Count = $ConnectionCounts[$P.PID]
            if($Count -gt 15){
                $Score += $Weights.ManyConnections
                $Reasons.Add("Many active TCP connections")
            }
        }
        else{
            $Count = 0
        }

        [PSCustomObject]@{
            ProcessName = $P.ProcessName
            PID = $P.PID
            Path = $P.Path
            RiskScore = $Score
            RiskLevel = Get-RiskLevel $Score
            ConnectionCount = $Count
            Reasons = ($Reasons -join "; ")
        }
    }
    return $Results
}
Export-ModuleMember -Function *
