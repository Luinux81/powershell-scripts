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
            # Normalizar rutas
            $normalizedPath = $path -replace '^\.\\', '' -replace '^\./', ''
            $resolvedPath = Join-Path -Path $currentDir -ChildPath $normalizedPath

            # Manejar wildcards
            $files = if ($resolvedPath -match '[\*\?]') {
                Get-ChildItem -Path $resolvedPath -File -ErrorAction Stop
            }
            else {
                Get-Item -Path $resolvedPath -ErrorAction Stop | 
                Where-Object { -not $_.PSIsContainer }
            }

            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($currentDir.Length + 1)
                $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
                
                # Mostrar directamente sin crear objeto con FullPath
                Write-Host "`n=== $relativePath ===" -ForegroundColor Cyan
                Write-Host $content
                
                # Agregar a output solo si se necesita para pipeline
                $output += [PSCustomObject]@{
                    RelativePath = $relativePath
                    Content      = $content
                }
            }
        }
        catch {
            Write-Warning "No se pudo procesar '$path': $_"
        }
    }

    # Devolver solo lo necesario (sin FullPath)
    return $output
}

# Ejecutar y suprimir salida automática de objetos
$null = Show-FileContents -FilePaths $Paths