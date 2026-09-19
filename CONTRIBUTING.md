# Contributing to SystemWide-AbuserHunter

Thank you for considering a contribution.

## Workflow

1. Fork the repository and create a branch from `main`.
2. Add or update tests in `Tests/ModuleTests.ps1` when behavior changes.
3. Ensure PowerShell code passes PSScriptAnalyzer.
4. Run the documentation lint checks.
5. Open a pull request with a concise technical description.

## Coding Standards

- Use approved PowerShell verbs and singular nouns for exported functions.
- Use **PascalCase** for functions, such as `Invoke-ProcessAudit`.
- Use `Set-StrictMode -Version Latest` in PowerShell modules.
- Return structured audit results consistently.
- Do not add third-party binaries or package dependencies.
- Preserve the read-only security model.

## Branch Strategy

- `main` is the production branch.
- Create focused branches such as `feat/etw-integration` or
  `fix/cache-bug`.
