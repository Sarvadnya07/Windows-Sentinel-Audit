# Contributing to SystemWide-AbuserHunter

First off, thank you for considering contributing to SystemWide-AbuserHunter! 

## Workflow
1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests to `Tests/ModuleTests.ps1`.
3. Ensure your PowerShell code passes `PSScriptAnalyzer`.
4. Issue that pull request!

## Coding Standards
- Use **PascalCase** for functions (e.g., `Invoke-ProcessAudit`).
- Always use `Set-StrictMode -Version Latest` at the top of your `.psm1` files.
- Return structured objects matching the existing `Get-StandardResult` or `[PSCustomObject]@{Data=...}` pattern.
- Do not add any third-party dependencies (no NuGet, no compiled binaries).

## Branch Strategy
- `main` is always production-ready.
- Create feature branches (e.g., `feat/etw-integration` or `fix/cache-bug`).
