# Crear la carpeta bin si no existe
$binPath = Join-Path -Path $PSScriptRoot -ChildPath "bin"
if (-not (Test-Path -Path $binPath)) {
    New-Item -Path $binPath -ItemType Directory | Out-Null
}

# Ruta base de scripts
$scriptsPath = Join-Path -Path $PSScriptRoot -ChildPath "scripts"

# Obtener todos los scripts .ps1 recursivamente
$scripts = Get-ChildItem -Path $scriptsPath -Recurse -Filter *.ps1

foreach ($script in $scripts) {
    $linkName = $script.BaseName  # Nombre sin extensión
    $linkPath = Join-Path -Path $binPath -ChildPath $linkName

    # Si el enlace ya existe, lo eliminamos para actualizarlo
    if (Test-Path -Path $linkPath) {
        Remove-Item -Path $linkPath -Force
    }

    # Crear enlace simbólico (requiere permisos de administrador o política adecuada)
    New-Item -Path $linkPath -ItemType SymbolicLink -Value $script.FullName | Out-Null
    Write-Host "Enlace creado: $linkName -> $($script.FullName)"
}
