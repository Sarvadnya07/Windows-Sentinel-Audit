# Deployment Guide

For enterprise DFIR teams, AbuserHunter is typically deployed dynamically during a response, rather than installed permanently.

## Methods of Deployment
1. **EDR Live Response (CrowdStrike / Defender for Endpoint)**
   - Zip the `SystemWide-AbuserHunter` folder.
   - Push to the host via Live Response terminal.
   - Execute: `powershell.exe -ExecutionPolicy Bypass -File SystemWide-AbuserHunter.ps1`
   - Pull the generated `Reports/` directory back to the console.

2. **Group Policy / SCCM**
   - In the event of a fleet-wide triage request, AbuserHunter can be executed as a system startup script or via an SCCM package.
   - **Important:** Modify `SystemWide-AbuserHunter.ps1` to output to a centralized UNC network share (e.g., `\\fileserver\Forensics\$env:COMPUTERNAME\`) instead of the local disk.

## Security Considerations
When deploying over a network share, ensure the target share is strictly write-only (AppendData) to prevent compromised hosts from reading or destroying other hosts' forensic reports.
