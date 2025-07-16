<#
.SYNOPSIS
Carga un módulo y ejecuta una de sus funciones, permitiendo pasar parámetros.

.DESCRIPTION
Script útil para desarrollo de módulos PowerShell. Permite importar un módulo (.psm1 o .psd1) y ejecutar una función del mismo, opcionalmente pasando parámetros mediante un hashtable.

.PARAMETER ModulePath
Ruta al archivo .psm1 o .psd1 del módulo.

.PARAMETER Function
Nombre de la función del módulo que deseas probar (por defecto: Select-FileInteractive)

.PARAMETER Parameters
Hashtable opcional con los parámetros a pasar a la función.

.PARAMETER Help
Muestra la ayuda y ejemplos de uso.

.EXAMPLE
Test-Modulo -ModulePath .\modulos\FileHelper\FileHelper.psm1

.EXAMPLE
Test-Modulo -ModulePath .\modulos\MySqlHelper\MySqlHelper.psm1 -Function Connect-MySql -Parameters @{ Host = 'localhost'; User = 'root' }

.EXAMPLE
Test-Modulo -Help

.NOTES
Puedes usar -h como alias de -Help
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [Alias("h")]
    [switch]$Help,

    [Parameter(Mandatory = $false)]
    [string]$ModulePath,

    [string]$Function = "Select-FileInteractive",

    [hashtable]$Parameters
)

if ($Help -or -not $ModulePath) {
    Write-Host ""
    Write-Host "USO:" -ForegroundColor Cyan
    Write-Host "  Test-Modulo -ModulePath <ruta> [-Function <función>] [-Parameters <hashtable>]"
    Write-Host ""
    Write-Host "EJEMPLOS:" -ForegroundColor Cyan
    Write-Host "  Test-Modulo -ModulePath .\modulos\FileHelper\FileHelper.psm1"
    Write-Host "  Test-Modulo -ModulePath .\modulos\FileHelper\FileHelper.psd1 -Function Select-FileInteractive"
    Write-Host "  Test-Modulo -ModulePath .\modulos\MySqlHelper\MySqlHelper.psm1 -Function Connect-MySql -Parameters @{ Host = 'localhost'; User = 'root' }"
    Write-Host ""
    Write-Host "NOTAS:" -ForegroundColor DarkGray
    Write-Host "  - Puedes usar -h como alias de -Help"
    Write-Host "  - El parámetro Parameters debe ser un hashtable válido"
    Write-Host ""
    return
}

try {
    if (-not (Test-Path $ModulePath)) {
        throw "No se encontró el módulo en: $ModulePath"
    }

    Write-Host "`nImportando módulo desde: $ModulePath" -ForegroundColor Cyan
    Import-Module $ModulePath -Force -ErrorAction Stop

    Write-Host "Ejecutando función: $Function" -ForegroundColor Green

    if (Get-Command -Name $Function -ErrorAction SilentlyContinue) {
        if ($Parameters) {
            & $Function @Parameters
        }
        else {
            & $Function
        }
    }
    else {
        Write-Warning "La función '$Function' no se encontró en el módulo."
    }

}
catch {
    Write-Error "`nError al probar el módulo: $_"
}
