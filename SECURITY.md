# Security Policy

## Supported Versions

| Version | Supported |
| --- | --- |
| 1.x.x | :white_check_mark: |
| < 1.0 | :x: |

## Reporting a Vulnerability

Because AbuserHunter is a read-only auditing tool, reports generally fall
into categories such as:

1. **Denial of Service:** A defect that can cause excessive resource use.
2. **Evasion:** A methodology that can bypass or misclassify heuristic
   checks.

Please do not disclose security-sensitive evasion details in a public
issue. Use the repository's private security-reporting channel instead.

## Best Practices

- Execute the script from a trusted, write-blocked USB device during live
  incident response when appropriate.
- Treat generated audit files as sensitive forensic data.
- Do not upload audit results containing environment telemetry to public
  paste services.
