param([string]$BasePath)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Running as Standard User. Some telemetry (e.g. System processes, sensitive registry keys) will be unavailable. Proceeding in degraded mode."
}

. (Join-Path $BasePath "Core\DependencyLoader.ps1") -BasePath $BasePath