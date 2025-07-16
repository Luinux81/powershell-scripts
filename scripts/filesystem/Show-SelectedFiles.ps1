#!/usr/bin/env pwsh
#Requires -Version 5.0

<#
.SYNOPSIS
Selecciona archivos usando FZF y muestra su contenido.
.DESCRIPTION
Interactúa con FZF para selección múltiple de archivos y luego muestra su contenido via Get-FileContents.ps1.
.EXAMPLE
.\Show-SelectedFiles.ps1
#>

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host "📁 Repo raíz detectada:" $repoRoot -ForegroundColor Cyan

$modulePath = Join-Path $repoRoot 'modulos\FileHelper\FileHelper.psm1'
$getFileContentsScript = Join-Path $repoRoot 'scripts\filesystem\Get-FileContents.ps1'

# 3. Importar módulo de selección
if (-not (Get-Command Select-FilesWithFzf -ErrorAction SilentlyContinue)) {
    if (-not (Test-Path $modulePath)) {
        Write-Error "No se encontró el módulo FileSelector en: $modulePath"
        exit 1
    }
    Import-Module $modulePath -Force
}

# 4. Verificar script de Get-FileContents
if (-not (Test-Path $getFileContentsScript)) {
    Write-Error "No se encontró el script Get-FileContents.ps1 en: $getFileContentsScript"
    exit 1
}

# 5. Llamar a FZF para seleccionar archivos
$selectedFiles = Select-FilesWithFzf -StartPath $repoRoot

if (-not $selectedFiles) {
    Write-Host "⚠️ No se seleccionó ningún archivo." -ForegroundColor Yellow
    exit 0
}

# 6. Asegurar que la salida sea un array
if (-not ($selectedFiles -is [System.Array])) {
    $selectedFiles = @($selectedFiles)
}

# 7. Mostrar contenido de los archivos seleccionados
& $getFileContentsScript @selectedFiles
