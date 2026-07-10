# Future Scope (Technical Scalability)

This document outlines the technical evolutions planned for AbuserHunter.

## Scalability Evolution
Currently, AbuserHunter runs synchronously. The `Cache.psm1` fetches data, and then modules run one by one. 
For endpoints with massive workloads, we plan to transition to **PowerShell Runspaces**.
By utilizing `[runspacefactory]::CreateRunspacePool()`, we can execute `ProcessAudit`, `NetworkAudit`, and `ServiceAudit` entirely in parallel, dropping execution time from ~2.5 seconds to <0.8 seconds.

## AI & Automation Opportunities
- **Automated Risk Tuning:** By parsing historical `Investigation.csv` outputs, an AI agent could dynamically adjust `RiskWeights.json` to suppress consistent false positives unique to a specific enterprise environment.
- **LLM Summary Generation:** Piping the top 5 high-risk findings into an LLM via API to generate an English-readable hypothesis for the SOC team.
