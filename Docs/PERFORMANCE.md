# Performance Considerations

AbuserHunter is designed to execute as quickly as possible with the lowest CPU footprint to avoid crashing an already-struggling host during an incident.

## Optimizations Used
- **Single-Pass WMI Fetching:** WMI `Win32_Process` calls are notoriously slow. By caching them once in `$script:AuditCache`, we save seconds per downstream module.
- **Runspace Compatibility:** The architecture avoids global state aside from the Cache, preparing it for future multi-threaded Runspace pool execution.

## Bottlenecks
- **Digital Signatures:** The `Get-AuthenticodeSignature` cmdlet is I/O bound. Scanning 500 processes takes the bulk of the script's runtime (approx. 5-10 seconds depending on disk speed).
- **Network Sockets:** `Get-NetTCPConnection` is relatively fast, but correlating it against the process cache is O(N*M). We optimized this using PowerShell filtering instead of nested loops where possible.

## Scaling Strategy
If the tool takes longer than 30 seconds on a heavy server (e.g., a Citrix host with 2,000 processes), consider overriding the `SignatureAudit` to only scan binaries executing from non-Windows directories.
