# DFIR Methodology integration

SystemWide-AbuserHunter is designed to slot directly into the standard Digital Forensics and Incident Response (DFIR) lifecycle.

## 1. Collection (Telemetry Gathering)
In the initial moments of an incident, rapid situational awareness is critical. AbuserHunter collects ephemeral data (network connections, process memory footprints) before it vanishes.

## 2. Correlation
Isolated data is useless. The `CorrelationEngine` binds isolated network sockets back to the processes that spawned them, providing immediate context on *how* an external IP is interacting with the host.

## 3. Risk Engine (Triage)
During a widespread incident, analysts cannot review 500 processes per machine. The `RiskEngine` applies deterministic heuristics to bubble up the top 1% of suspicious activities for immediate human review.

## 4. Interpretation (Analyst Review)
The generated `Investigation.csv` and HTML dashboard are built for the human eye. 
- Look for **Parent Mismatches** (e.g., `cmd.exe` spawned by `spoolsv.exe`).
- Look for **Persistence Overlap** (e.g., a High-Risk process that also has a Scheduled Task).

## 5. Reporting
The `Audit.json` format is strictly typed for automated ingestion into SIEMs (Splunk, Elastic) for fleet-wide aggregation and hunting.
