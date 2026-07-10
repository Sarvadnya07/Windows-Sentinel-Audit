# Internals

This document details the internal mechanisms of SystemWide-AbuserHunter.

## Memory & Caching
Because querying `Get-CimInstance Win32_Process` is computationally expensive on Windows, we execute it exactly once in `Cache.psm1`. The results are stored in `$script:AuditCache.Processes`, which is a module-scoped variable that persists for the lifetime of the run.

## Module Lifecycle
1. `Bootstrap.ps1` dynamically loads all `.psm1` files defined in `DependencyLoader.ps1`.
2. `DependencyLoader.ps1` mandates the load order (Cache -> Config -> Audits -> Engines -> Exports).
3. The orchestrator catches exceptions at the module level. If a module fails, it is bypassed, and an empty array `@()` is substituted to prevent pipeline crashes.

## Execution Order Constraints
- `RiskEngine` MUST run after `ProcessAudit` and `NetworkAudit`, as it requires both objects to calculate compound risks (e.g., Unsigned + Network socket).
- `InvestigationEngine` MUST run last, as it merges all disparate objects into a single pane of glass.
