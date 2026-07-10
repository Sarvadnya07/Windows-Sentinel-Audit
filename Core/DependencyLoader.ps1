param([string]$BasePath)

$modules = @(
    "Core\Logger.psm1",
    "Core\ConfigLoader.psm1",
    "Core\Cache.psm1",
    "Core\Diagnostics.psm1",
    "Modules\Helpers.psm1",
    "Modules\Utilities.psm1",
    "Modules\ProcessAudit.psm1",
    "Modules\ProcessTree.psm1",
    "Modules\NetworkAudit.psm1",
    "Modules\SignatureAudit.psm1",
    "Modules\ServiceAudit.psm1",
    "Modules\PersistenceAudit.psm1",
    "Modules\StartupAudit.psm1",
    "Modules\RegistryAudit.psm1",
    "Modules\ScheduledTaskAudit.psm1",
    "Modules\FileAudit.psm1",
    "Modules\DriverAudit.psm1",
    "Modules\ModuleAudit.psm1",
    "Modules\UserAudit.psm1",
    "Modules\FirewallAudit.psm1",
    "Modules\DNSAudit.psm1",
    "Modules\CertificateAudit.psm1",
    "Modules\EventLogAudit.psm1",
    "Modules\SystemAudit.psm1",
    "Modules\RiskEngine.psm1",
    "Modules\ReportEngine.psm1",
    "Modules\ExportEngine.psm1",
    "Modules\CorrelationEngine.psm1",
    "Modules\HeuristicEngine.psm1",
    "Modules\Statistics.psm1",
    "Modules\RegistryAudit.psm1",
    "Modules\StartupAudit.psm1",
    "Modules\ScheduledTaskAudit.psm1",
    "Modules\PersistenceAudit.psm1",
    "Modules\InvestigationEngine.psm1",
    "Modules\ConfigValidator.psm1"
)

foreach ($mod in $modules) {
    $path = Join-Path $BasePath $mod
    if (Test-Path $path) {
        Import-Module $path -Force
    }
}
