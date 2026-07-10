# Roadmap

See [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) for historical milestones and granular versioning.

## Current Focus
- Stabilization of the heuristic scoring engine to reduce false positives in highly-customized AD environments.
- Expanding the `PersistenceAudit` to cover WMI Event Consumers and BITS jobs.

## Under Consideration
- Porting the reporting engine to output natively to ELK/Splunk HTTP Event Collectors (HEC) rather than local disk.
- Packaging the orchestrator into a standalone PS1 using `Invoke-Build` so it can be deployed as a single obfuscation-free file for SCCM.
