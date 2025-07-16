# requires -Version 7.0

# 🔒 Verificación de versión mínima
# if ($PSVersionTable.PSVersion.Major -lt 7) {
#     Write-Host "`n🚫 Este script requiere PowerShell 7.0 o superior." -ForegroundColor Red
#     Write-Host "   Versión detectada: $($PSVersionTable.PSVersion)`n"
#     exit 1
# }

# 🧩 Parámetros de entrada
param(
    [Parameter(Position = 0)]
    [string]$Path,

    [string[]]$Exclude,

    [string[]]$ExcludeWellKnown,

    [switch]$Files,

    [switch]$SelectContents,

    [Alias('h')]
    [switch]$Help
)

# ✅ Valores por defecto
if (-not $Path) { $Path = "." }
if (-not $Exclude) { $Exclude = @() }

# 📦 Excepciones conocidas por tecnología
$WellKnownExclusions = @{
    "laravel" = @(".vscode", ".git", "vendor", "node_modules")
    "nodejs"  = @("node_modules", "dist", "build", ".git", ".vscode")
    "react"   = @("node_modules", "dist", "build", ".git", ".vscode", ".next")
}

# 🎯 Aplicar exclusiones conocidas si se solicitó
if ($ExcludeWellKnown) {
    foreach ($entry in $ExcludeWellKnown) {
        $key = $entry.ToLowerInvariant()
        if ($WellKnownExclusions.ContainsKey($key)) {
            $Exclude += $WellKnownExclusions[$key]
        }
        else {
            Write-Warning "⚠️ '$entry' no es una opción reconocida en -ExcludeWellKnown. Opciones válidas: $($WellKnownExclusions.Keys -join ', ')"
        }
    }
}

# 📖 Mostrar ayuda si se solicita
if ($Help.IsPresent) {
    Write-Host @"

🌳 SCRIPT DE ÁRBOL DE DIRECTORIOS CON EXCLUSIONES
================================================

DESCRIPCIÓN:
    Muestra la estructura de directorios en formato árbol con opción de 
    excluir carpetas específicas y mostrar contenidos de archivos.

SINTAXIS:
    Get-Tree [-Path <ruta>] [-Exclude <array>] [-ExcludeWellKnown <array>]
             [-Files] [-SelectContents] [-Help|-h]

PARÁMETROS:
    -Path <string>              Ruta del directorio a analizar (por defecto: directorio actual)
    -Exclude <string[]>         Array de directorios/archivos a excluir
    -ExcludeWellKnown <string[]> Excluir conjuntos conocidos (por ahora: laravel, nodejs, react)
    -Files                      Incluir archivos en el árbol (por defecto: solo directorios)
    -SelectContents             Mostrar ventana para seleccionar archivos y ver su contenido
    -Help, -h                   Mostrar esta ayuda

EJEMPLOS DE USO:
    
    Get-Tree
    Get-Tree -Path "C:\MiProyecto"
    Get-Tree -Path "C:\MiProyecto" -Exclude @("bin", "obj", "node_modules")
    Get-Tree -Path "." -Exclude @("C:\temp\logs", "build")
    Get-Tree -Files -Exclude @(".git", "dist")
    Get-Tree -SelectContents -Exclude @("vendor", "cache")
    Get-Tree -Path "C:\Proyecto" -Exclude @("bin", "obj", ".git") -Files -SelectContents
    Get-Tree -Exclude @("node_modules", "vendor", "bin", "obj", ".git", "dist", "build")

    # Excluir carpetas comunes automáticamente
    Get-Tree -ExcludeWellKnown laravel
    Get-Tree -ExcludeWellKnown react,nodejs -Exclude @("coverage")

NOTAS:
    - Las exclusiones pueden ser rutas relativas o absolutas
    - El parámetro -Files incluye archivos en la visualización del árbol
    - El parámetro -SelectContents abre una ventana para seleccionar archivos
    - Requiere PowerShell 7.0 o superior

"@ -ForegroundColor Green
    return
}

# --- Inicialización de variables ---
try {
    $BasePath = Resolve-Path -Path $Path -ErrorAction Stop
}
catch {
    Write-Error "❌ No se pudo resolver la ruta '$Path'. Verifica que existe."
    exit 1
}

# Función para excluir rutas
function Get-ExcludedStatus {
    param($ItemFullPath)

    $itemName = [IO.Path]::GetFileName($ItemFullPath)
    $normalizedPath = [IO.Path]::GetFullPath($ItemFullPath).ToUpperInvariant()

    foreach ($ex in $Exclude) {
        # $exNormalized = $ex.ToUpperInvariant()

        if ($ex.Contains("*") -or $ex.Contains("?")) {
            if ($itemName -like $ex -or $normalizedPath -like $ex) {
                return $true
            }
        }
        elseif (-not [IO.Path]::IsPathRooted($ex)) {
            if ($itemName -eq $ex) {
                return $true
            }
        }
        else {
            $normalizedEx = [IO.Path]::GetFullPath($ex).ToUpperInvariant()
            if ($normalizedPath -eq $normalizedEx -or 
                $normalizedPath.StartsWith($normalizedEx + [IO.Path]::DirectorySeparatorChar)) {
                return $true
            }
        }
    }
    return $false
}

# Función para mostrar árbol
function Show-Tree {
    param(
        [string]$CurrentPath,
        [string]$Prefix = ""
    )

    if (-not $CurrentPath -or (Get-ExcludedStatus $CurrentPath)) {
        return
    }

    try {
        $items = Get-ChildItem -LiteralPath $CurrentPath -Force -ErrorAction Stop
    }
    catch {
        Write-Warning "⚠️ No se pudo acceder a '$CurrentPath': $_"
        return
    }

    $items = $items | Where-Object { -not (Get-ExcludedStatus $_.FullName) }

    $dirs = $items | Where-Object { $_.PSIsContainer }
    $files = $items | Where-Object { -not $_.PSIsContainer }

    $entries = @()
    $entries += $dirs
    if ($Files.IsPresent) {
        $entries += $files
    }

    $count = $entries.Count
    $i = 0

    foreach ($item in $entries) {
        $i++
        $isLast = $i -eq $count
        $connector = $isLast ? "└── " : "├── "
        Write-Output "$Prefix$connector$($item.Name)"

        if ($item.PSIsContainer) {
            $nextPrefix = $Prefix + ($isLast ? "    " : "│   ")
            Show-Tree -CurrentPath $item.FullName -Prefix $nextPrefix
        }
    }
}

# --- Ejecución principal ---
Write-Host "`n📁 Estructura de '$($BasePath.Path)'`n"
Show-Tree -CurrentPath $BasePath.Path

# Mostrar contenidos seleccionados si se solicita
if ($SelectContents.IsPresent) {
    Write-Host "`n📄 Selección de archivos (contenidos opcionales):`n"

    try {
        $allFiles = Get-ChildItem -Path $BasePath.Path -Recurse -File -Force | Where-Object {
            -not (Get-ExcludedStatus $_.FullName)
        } | Sort-Object FullName

        $relativeFiles = $allFiles | ForEach-Object {
            $_ | Select-Object @{Name = "RelativePath"; Expression = { $_.FullName.Substring($BasePath.Path.Length + 1) } }, FullName
        }

        $selected = $relativeFiles | Out-GridView -Title "Selecciona archivos para mostrar su contenido" -PassThru

        if ($selected) {
            foreach ($file in $selected) {
                Write-Host "`n==== [$($file.RelativePath)] ====" -ForegroundColor Cyan
                try {
                    Get-Content $file.FullName -Raw
                }
                catch {
                    Write-Warning "Error leyendo $($file.FullName): $_"
                }
            }
        }
    }
    catch {
        Write-Warning "⚠️ Ocurrió un error al obtener los archivos: $_"
    }
}
