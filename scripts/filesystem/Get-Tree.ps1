# require -Version 7.0

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

# Valores por defecto
if (-not $Path) { $Path = "." }
if (-not $Exclude) { $Exclude = @() }
if (-not $ExcludeWellKnown) { $ExcludeWellKnown = @() }

# Mapas para exclusiones bien conocidas
$wellKnownExclusionsMap = @{
    "laravel" = @(".vscode", ".git", "vendor", "node_modules", "storage")
    # Puedes agregar más en el futuro como:
    # "react" = @("node_modules", "build", "dist"),
    # "nodejs" = @("node_modules", "logs")
}

# Agregar exclusiones de wellKnown a $Exclude
foreach ($wk in $ExcludeWellKnown) {
    if ($wellKnownExclusionsMap.ContainsKey($wk.ToLower())) {
        $Exclude += $wellKnownExclusionsMap[$wk.ToLower()]
    }
}

# Mostrar ayuda si se solicita
if ($Help.IsPresent) {
    Write-Host @"
🌳 SCRIPT DE ÁRBOL DE DIRECTORIOS CON EXCLUSIONES
================================================

DESCRIPCIÓN:
    Muestra la estructura de directorios en formato árbol con opción de 
    excluir carpetas específicas y mostrar contenidos de archivos.

SINTAXIS:
    Get-Tree [-Path <ruta>] [-Exclude <array>] [-ExcludeWellKnown <array>] [-Files] [-SelectContents] [-Help|-h]

PARÁMETROS:
    -Path <string>          Ruta del directorio a analizar (por defecto: directorio actual)
    -Exclude <string[]>     Array de directorios/archivos a excluir
    -ExcludeWellKnown <string[]> Opciones predefinidas de exclusión (ej: laravel)
    -Files                  Incluir archivos en el árbol (por defecto: solo directorios)
    -SelectContents         Mostrar ventana para seleccionar archivos y ver su contenido
    -Help, -h               Mostrar esta ayuda

EJEMPLOS DE USO:

    # Árbol básico del directorio actual
    Get-Tree

    # Árbol con exclusiones "laravel" y archivos
    Get-Tree -ExcludeWellKnown "laravel" -Files

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
    $FolderName = Split-Path -Leaf $BasePath.Path
}
catch {
    Write-Error "❌ No se pudo resolver la ruta '$Path'. Verifica que existe."
    exit 1
}

# Función para excluir rutas
function Get-ExcludedStatus {
    param($ItemFullPath)

    # No excluir archivos cuando -Files está activado
    if ($Files.IsPresent -and -not (Test-Path -Path $ItemFullPath -PathType Container)) {
        return $false
    }

    $itemName = Split-Path -Leaf $ItemFullPath

    foreach ($ex in $Exclude) {
        # Si es un patrón wildcard
        if ($ex -match '[\*\?]') {
            if ($itemName -like $ex) {
                return $true
            }
        }
        # Comparación exacta
        elseif ($itemName -eq $ex) {
            return $true
        }
    }
    return $false
}

# Función para mostrar árbol
function Show-Tree {
    param(
        [string]$CurrentPath,
        [string]$Prefix = "",
        [bool]$IsRoot = $false
    )

    if (-not $CurrentPath -or (Get-ExcludedStatus $CurrentPath)) {
        return
    }

    try {
        $items = @(Get-ChildItem -LiteralPath $CurrentPath -Force -ErrorAction Stop | 
            Sort-Object { -not $_.PSIsContainer }, Name)
    }
    catch {
        Write-Warning "⚠️ No se pudo acceder a '$CurrentPath': $_"
        return
    }

    $filteredItems = $items | Where-Object { -not (Get-ExcludedStatus $_.FullName) }
    $allItems = @($filteredItems)
    $count = $allItems.Count

    # Mostrar nombre de la carpeta raíz
    if ($IsRoot) {
        Write-Output "$($FolderName)/"
        # $newPrefix = "│   "
    }
    else {
        $newPrefix = $Prefix
    }

    for ($i = 0; $i -lt $count; $i++) {
        $item = $allItems[$i]
        $isLast = $i -eq ($count - 1)
        
        $connector = if ($IsRoot) {
            if ($isLast) { "└── " } else { "├── " }
        }
        else {
            if ($isLast) { "└── " } else { "├── " }
        }
        
        $displayName = if ($item.PSIsContainer) { "$($item.Name)/" } else { $item.Name }
        
        Write-Output "$Prefix$connector$displayName"

        if ($item.PSIsContainer) {
            $nextPrefix = $Prefix + ($isLast ? "    " : "│   ")
            Show-Tree -CurrentPath $item.FullName -Prefix $nextPrefix
        }
    }
}

# --- Ejecución principal ---
Write-Host "`n📁 Estructura de '$($BasePath.Path)'`n"
Show-Tree -CurrentPath $BasePath.Path -IsRoot $true

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