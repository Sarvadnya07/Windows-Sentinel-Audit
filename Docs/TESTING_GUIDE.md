# Testing Guide

SystemWide-AbuserHunter relies on native OS state, making deterministic unit testing difficult. However, we provide integration tests in the `Tests/` directory.

## Running Tests
Execute the test harness to validate module imports, schema integrity, and cache availability:
```powershell
.\Tests\ModuleTests.ps1
```

## Test Strategy
- **Module Import Tests:** Ensures no `.psm1` has a syntax error that would break `DependencyLoader.ps1`.
- **WMI Integrity:** Validates that `Get-CimInstance Win32_Process` successfully returns objects on the host OS.
- **Report Generation:** Generates a mock report and asserts that `Export-AbuserHunterJson` creates a valid file.

## Edge Cases
- **Non-Admin Execution:** The script gracefully downgrades if run without Admin. You should manually test this path to ensure no terminating errors occur.
- **Air-Gapped Systems:** Test the signature verification in an environment without internet access to ensure `Get-AuthenticodeSignature` doesn't hang on CRL checks.
