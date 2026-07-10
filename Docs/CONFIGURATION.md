# Configuration Guide

AbuserHunter is driven by three primary JSON files located in the `Config/` directory.

## 1. RiskWeights.json
**Purpose:** Defines the heuristic scoring values used by the `RiskEngine`.
**Schema:** Key-Value pair (String -> Integer).

**Example:**
```json
{
  "UnsignedBinary": 25,
  "UserWritableLocation": 20,
  "PublicConnection": 10,
  "TrustedPublisher": -15
}
```

## 2. TrustedPublishers.json
**Purpose:** Whitelists known-good software vendors to reduce heuristic noise. Processes signed by these vendors receive negative risk points.
**Schema:** `{"Publishers": [Array of Strings]}`

**Example:**
```json
{
  "Publishers": [
    "Microsoft Corporation",
    "Google LLC",
    "VMware, Inc."
  ]
}
```

## 3. SuspiciousLocations.json
**Purpose:** Flags directories that are commonly abused by malware (e.g., user-writable temp folders).
**Schema:** `{"Locations": [Array of Strings]}`

**Example:**
```json
{
  "Locations": [
    "\\AppData\\Local\\Temp\\",
    "\\ProgramData\\",
    "\\Users\\Public\\"
  ]
}
```
