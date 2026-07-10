# Architecture Overview

SystemWide-AbuserHunter is built on a highly modular, decoupled architecture.

## Component Flow
```mermaid
graph TD
    Boot[Bootstrap.ps1] -->|Initializes| Cache[Cache.psm1]
    Boot -->|Loads| ConfigValidator[ConfigValidator.psm1]
    
    Cache -->|Provides Win32 Objects| Proc[ProcessAudit]
    Cache -->|Provides NetTCP| Net[NetworkAudit]
    Cache -->|Provides Win32 Objects| Svc[ServiceAudit]
    
    Proc --> Corr[CorrelationEngine]
    Net --> Corr
    
    Corr --> Risk[RiskEngine]
    ConfigValidator --> Risk
    
    Risk --> Inv[InvestigationEngine]
    Inv --> Rep[ReportEngine]
```

## Design Decisions
1. **The Cache:** We chose `$script:AuditCache` to ensure WMI data is queried exactly once.
2. **Standard Result Contract:** All audit modules return `[PSCustomObject]@{ Data = $Array }`. This allows the orchestrator to blindly iterate and aggregate without worrying about module-specific data schemas.
3. **Graceful Degradation:** The orchestrator utilizes aggressive `try/catch` wrapping around each module invocation. If `RegistryAudit` crashes due to permissions, the script logs the failure but successfully generates reports for Processes and Networks.
