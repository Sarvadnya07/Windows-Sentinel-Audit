# Module Guide

This document catalogs the exported functions of the AbuserHunter modules.

## Core Modules

### `Cache.psm1`
- **`Initialize-AuditCache`**: Sets up the `$script:AuditCache` hashtable.
- **`Build-AuditCache`**: Populates the cache via `Get-CimInstance Win32_Process` and `Win32_Service`.

### `ConfigValidator.psm1`
- **`Invoke-ConfigValidation -ConfigDir <Path>`**: Reads all JSON configuration files, validating schema and falling back to safe defaults if missing.

## Audit Modules
All audit modules return a standardized object containing the `.Data` array.

- **`Invoke-ProcessAudit`**: Enemerates all active processes and resolves Authenticode signatures (if available).
- **`Invoke-NetworkAudit`**: Enumerates all active TCP connections.
- **`Invoke-ServiceAudit`**: Enumerates all running services and their binary paths.
- **`Invoke-PersistenceAudit`**: Aggregates Registry Run keys, Startup folders, and Scheduled Tasks.

## Engine Modules
- **`Invoke-CorrelationEngine`**: Binds network connections back to process IDs.
- **`Invoke-RiskEngine`**: Iterates over all collected processes, applying the heuristics defined in `RiskWeights.json`.
- **`Invoke-InvestigationEngine`**: Creates the final, flattened entity view that merges Risk, Network, Services, and Persistence data per process.
