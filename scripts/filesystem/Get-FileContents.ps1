<#
.SYNOPSIS
Muestra el contenido de archivos especificados con sus rutas relativas.

.DESCRIPTION
Este script muestra el contenido de uno o más archivos, incluyendo la ruta relativa desde el directorio actual.
Soporta autocompletado con TAB y manejo de múltiples archivos.

.PARAMETER Paths
Rutas de los archivos a mostrar (acepta múltiples rutas separadas por espacios)

.EXAMPLE
.\Get-FileContents.ps1 .\config\app.php .\routes\web.php

.EXAMPLE
.\Get-FileContents.ps1 .\app\*.php
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true, ValueFromRemainingArguments = $true)]
    [Alias("File")]
    [string[]]$Paths
)

function Show-FileContents {
    param(
        [string[]]$FilePaths
    )

    $currentDir = (Get-Location).Path
    $output = @()

    foreach ($path in $FilePaths) {
        try {
            $resolvedPaths = Resolve-Path -Path $path -ErrorAction Stop
            foreach ($resolvedPathInfo in $resolvedPaths) {
                $filePath = $resolvedPathInfo.ProviderPath
                if (-not (Test-Path -Path $filePath -PathType Leaf)) {
                    continue
                }

                if ($filePath.StartsWith($currentDir)) {
                    $relativePath = $filePath.Substring($currentDir.Length + 1)
                }
                else {
                    $relativePath = $filePath
                }

                $content = Get-Content -Path $filePath -Raw -ErrorAction Stop

                # En lugar de Write-Host, guardamos en variable
                $output += "`n`n=== $relativePath ===`n`n$content"
            }
        }
        catch {
            Write-Warning "No se pudo procesar '$path': $_"
        }
    }

    # Devolvemos todo el contenido concatenado
    return $output -join "`n"
}


$output = Show-FileContents -FilePaths $Paths
Write-Output $output
