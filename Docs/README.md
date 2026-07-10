# Getting Started

## Overview

**SystemWide-AbuserHunter** is a **read-only Windows Digital Forensics & Incident Response (DFIR)** toolkit written in **PowerShell 5.1+**.

It helps administrators and security analysts collect forensic information about:

* Running processes
* Parent-child process relationships
* Network connections
* Windows services
* Digital signatures
* Common persistence mechanisms
* Heuristic risk indicators

The toolkit **does not modify the system**, terminate processes, disable services, edit the registry, or change firewall settings. It is designed strictly for inspection and reporting.

---

# Requirements

* Windows 10, Windows 11, Windows Server 2019 or later
* Windows PowerShell 5.1 or newer
* Administrator privileges are recommended for complete visibility (the tool can still run with reduced visibility if not elevated)

Verify your PowerShell version:

```powershell
$PSVersionTable.PSVersion
```

---

# Project Structure

```
SystemWide-AbuserHunter/

├── SystemWide-AbuserHunter.ps1
├── Core/
├── Modules/
├── Config/
├── Reports/
├── Docs/
└── Tests/
```

---

# Installation

Clone the repository:

```powershell
git clone https://github.com/<your-username>/SystemWide-AbuserHunter.git
```

or download the project as a ZIP file and extract it.

Open PowerShell and navigate to the project directory:

```powershell
cd "C:\Path\To\SystemWide-AbuserHunter"
```

---

# Execution Policy

If your execution policy blocks local scripts, check it first:

```powershell
Get-ExecutionPolicy
```

If it returns `Restricted`, allow scripts for the current PowerShell session only:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

This change is temporary and applies only to the current PowerShell window.

---

# Running the Tool

Open **Windows PowerShell**.

For the most complete audit:

1. Right-click **Windows PowerShell**
2. Select **Run as administrator**
3. Navigate to the project folder

Run:

```powershell
.\SystemWide-AbuserHunter.ps1
```

---

# Generated Reports

Reports are written to the `Reports` directory.

Example:

```
Reports/

├── Logs/
├── CSV/
│   ├── Processes.csv
│   ├── Services.csv
│   ├── Network.csv
│   ├── Persistence.csv
│   └── Risk.csv
│
├── Audit.json
└── Audit.html
```

---

# Understanding the Output

The tool collects information only.

It does **not** classify a system as "infected."

Instead, it assigns heuristic risk scores to help prioritize review.

Example:

```
Risk Score

0–19    Informational

20–39   Low

40–59   Medium

60–79   High

80–100  Critical
```

A higher score means an item deserves closer inspection—not that it is malicious.

---

# Typical Investigation Workflow

1. Review the **Risk Summary**.
2. Examine **High** and **Critical** findings.
3. Verify the executable path.
4. Check the digital signature.
5. Review parent-child process relationships.
6. Inspect active network connections.
7. Review persistence entries.
8. Determine whether the software is expected in your environment.

---

# Administrator vs Standard User

Administrator mode provides more complete visibility into:

* System processes
* Services
* Some scheduled tasks
* Certain network information

Running as a standard user may result in incomplete data but the audit will continue.

---

# Troubleshooting

## Execution policy error

```
running scripts is disabled
```

Solution:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

---

## Access denied

Run PowerShell as Administrator.

---

## Empty network section

Possible causes:

* No active TCP connections
* Limited permissions
* Firewall restrictions
* Networking services unavailable

---

## Missing executable path

Some protected system processes intentionally do not expose their executable path.

---

# Security Notice

This project is intended for:

* Defensive security
* System auditing
* Incident response
* Digital forensics
* Security research
* Administrative troubleshooting

It is designed to be **read-only** and does not intentionally modify system configuration or state.

---

# Limitations

Because this project uses only native PowerShell and built-in Windows capabilities:

* It cannot accurately measure live per-process bandwidth usage.
* It does not perform memory forensics.
* It does not inspect encrypted network traffic.
* It does not identify malware with certainty.
* It does not replace a full Endpoint Detection and Response (EDR) solution.

Heuristic findings should always be validated through further investigation.

---

# Contributing

Contributions are welcome.

Before submitting a pull request:

* Follow the existing coding style.
* Keep modules focused and modular.
* Preserve the read-only design.
* Add or update documentation.
* Include tests for new functionality where practical.

---

# License

See the `LICENSE` file for licensing information.
