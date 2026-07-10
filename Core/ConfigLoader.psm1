Set-StrictMode -Version Latest

function Import-AbuserHunterConfiguration {

    $configFolder = Join-Path $PSScriptRoot "..\Config"

    $config = @{}

    Get-ChildItem $configFolder -Filter *.json | ForEach-Object{

        try{

            $name = $_.BaseName

            $config[$name] = Get-Content $_.FullName -Raw | ConvertFrom-Json

        }

        catch{

            Write-Warning "Failed to load $($_.Name)"

        }

    }

    return $config

}

Export-ModuleMember -Function *