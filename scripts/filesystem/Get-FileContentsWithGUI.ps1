<#
.SYNOPSIS
Permite seleccionar archivos gráficamente y muestra su contenido con rutas relativas.

.DESCRIPTION
Este script abre un diálogo gráfico para seleccionar uno o más archivos,
y luego muestra el contenido de cada archivo incluyendo su ruta relativa desde el directorio actual.

.EXAMPLE
.\Get-FileContentsWithGUI.ps1
#>

Add-Type -AssemblyName System.Windows.Forms

function Select-FilesGraphically {
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.InitialDirectory = (Get-Location).Path
    $ofd.Filter = "Todos los archivos (*.*)|*.*"
    $ofd.Multiselect = $true
    $ofd.Title = "Selecciona uno o más archivos"

    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileNames
    }
    else {
        return @()
    }
}

function Show-FileContents {
    param(
        [string[]]$FilePaths
    )

    $currentDir = (Get-Location).Path
    $output = @()

    foreach ($filePath in $FilePaths) {
        try {
            if (-not (Test-Path -Path $filePath -PathType Leaf)) {
                Write-Warning "El archivo no existe o no es un archivo: $filePath"
                continue
            }

            # Obtener ruta relativa si está dentro de currentDir, sino ruta absoluta
            if ($filePath.StartsWith($currentDir)) {
                $relativePath = $filePath.Substring($currentDir.Length + 1)
            }
            else {
                $relativePath = $filePath
            }

            $content = Get-Content -Path $filePath -Raw -ErrorAction Stop

            Write-Host "`n=== $relativePath ===" -ForegroundColor Cyan
            Write-Host $content

            $output += [PSCustomObject]@{
                RelativePath = $relativePath
                Content      = $content
            }
        }
        catch {
            Write-Warning "No se pudo procesar '$filePath': $_"
        }
    }

    return $output
}

# Programa principal
$selectedFiles = Select-FilesGraphically

if ($selectedFiles.Count -eq 0) {
    Write-Host "No se seleccionaron archivos. Saliendo..."
    exit
}

Show-FileContents -FilePaths $selectedFiles
