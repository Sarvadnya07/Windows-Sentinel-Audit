# Roadmap & Project Timeline

## Completed Milestones
### v1.0 - Core Audit (Current)
- Basic Process, Network, Service, and Persistence audits.
- Centralized WMI caching.
- Correlation & Risk Engines.
- HTML/JSON/CSV outputs.

## Future Milestones
### v1.1 - Deep Inspection
- **Scheduled Tasks Audit Expansion:** Parse XML definitions for encoded commands.
- **WMI Persistence Audit:** Enumerate `__EventFilter` and `CommandLineEventConsumer`.
- **Driver Audit:** Enumerate loaded `.sys` files.

### v2.0 - Enterprise Features
- **YARA Integration:** Ability to run YARA rules against suspicious process memory.
- **ETW Telemetry:** Subscribe to Event Tracing for Windows to catch process injection in real-time.

### v3.0 - Fleet Aggregation
- **Cloud Dashboard:** A web portal to aggregate `Audit.json` uploads from thousands of endpoints, performing global frequency analysis (e.g., "Why is this hash only running on exactly one machine?").
