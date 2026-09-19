# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-11

### Added

- Core orchestrator and `DependencyLoader` system.
- WMI/CIM caching engine (`Cache.psm1`) for `Win32_Process` and
  `Win32_Service`.
- Audit modules for Process, Network, Service, Signature, and Persistence.
- Configurable `RiskEngine` utilizing JSON heuristics.
- Reporting engine outputting JSON, CSV, and HTML.
- Execution timing, isolated module error handling, and console dashboard.
