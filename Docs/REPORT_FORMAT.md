# Report Formats

When AbuserHunter completes an execution, it generates three distinct report formats in `Reports/YYYY-MM-DD_HHmmss/`.

## 1. Audit.json
The complete, nested state of the system audit.

**Structure:**
```json
{
  "Summary": {
    "ComputerName": "DESKTOP-123",
    "ProcessCount": 215,
    "HighRiskCount": 2
  },
  "Processes": [ ... ],
  "Network": [ ... ],
  "Risk": [ ... ],
  "Investigation": [ ... ]
}
```

## 2. CSV Files
For spreadsheet analysis, the data is flattened into distinct files:
- `Processes.csv`
- `Network.csv`
- `Services.csv`
- `Persistence.csv`
- `Investigation.csv` (The most critical file for analysts)

## 3. Audit.html
A standalone HTML dashboard containing embedded CSS.
Features:
- High-level overview table.
- Top 25 Highest Risk Findings.
- Investigation Summary table mapping Process -> Network -> Persistence.
