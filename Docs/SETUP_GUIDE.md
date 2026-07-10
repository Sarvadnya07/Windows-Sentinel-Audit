# Setup Guide

## Prerequisites
- **Operating System:** Windows 10, Windows 11, or Windows Server 2016/2019/2022.
- **PowerShell Version:** 5.1 or newer. (Core/7.x is supported for most modules, but some WMI integrations are best on 5.1).
- **Permissions:** Administrative rights are required to query all processes, services, and privileged Scheduled Tasks.

## Installation
Since AbuserHunter is a standalone script framework, there is no MSI or compiled installer.

1. **Clone the Repository:**
   ```powershell
   git clone https://github.com/yourorg/SystemWide-AbuserHunter.git
   ```
2. **Execution Policy:**
   Ensure your execution policy allows local scripts to run.
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. **Execution:**
   ```powershell
   cd SystemWide-AbuserHunter
   .\SystemWide-AbuserHunter.ps1
   ```

## Troubleshooting
- **AMSI/Antivirus Blocking:** If Microsoft Defender blocks `PersistenceAudit.psm1`, it is due to a false positive on the registry paths. You may need to add a temporary exclusion to the `SystemWide-AbuserHunter` directory.
- **Missing WMI Data:** If executed as a standard user, WMI will silently drop elevated processes from the return objects. Always run elevated during a real incident.
