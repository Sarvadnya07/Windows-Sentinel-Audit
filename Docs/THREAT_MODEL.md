# Threat Model

## 1. System Assets
- **The Execution Environment:** The Windows machine being audited.
- **The Telemetry Data:** Processes, network sockets, signatures, and registry keys gathered.
- **The Final Report:** HTML, JSON, and CSV outputs.

## 2. Trust Boundaries
- **Script vs. OS:** AbuserHunter relies on the native OS APIs (WMI, CIM, NetTCPConnection). If the OS API is hooked by a rootkit, AbuserHunter will ingest the spoofed data.
- **Script vs. User:** The script trusts the user running it to have legitimate administrative intent.

## 3. Threat Matrix
| Threat | Risk | Mitigation in AbuserHunter |
|--------|------|----------------------------|
| **Adversary Tampering** | Rootkits hiding processes from WMI. | *Limitation:* As a user-land script, we are bound by API truth. Future scope includes Direct System Call integration. |
| **Accidental Destructive Action** | An analyst altering system state during collection. | *Mitigation:* Framework is architecturally restricted to `Get-*` and `Test-*` cmdlets. |
| **Configuration Poisoning** | Adversary modifying `RiskWeights.json` to hide their IOCs. | *Mitigation:* The tool should be executed from read-only media (e.g., a write-blocked USB) during a live response. |

## 4. False Positives
Heuristics are inherently noisy. An unsigned internal line-of-business application running from a user's AppData folder will score highly. 
Analysts must contextualize these findings using the `InvestigationEngine` output, looking for compounding indicators (e.g., unexpected parent processes).
