# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability
Since AbuserHunter is a read-only auditing tool, vulnerabilities typically fall into two categories:
1. **Denial of Service:** A bug that causes the script to consume infinite memory or 100% CPU.
2. **Evasion:** A known methodology where a malicious actor can bypass the heuristic checks (e.g., spoofing a parent PID that we fail to validate).

Please do not open a public issue for evasion vulnerabilities. Email the maintainer team directly.

## Best Practices
- Execute the script from a secure, write-blocked USB drive during live incident response.
- Do not upload your `Audit.json` to public pastebins, as it contains your entire environment's process tree and network layout.
