# Parámetros de entrada
param (
    [string]$Name,
    [string]$Target
)

# Verificar si el script se está ejecutando con permisos de administrador
Function Test-Admin {
    $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning "Este script requiere permisos de administrador. Solicitando permisos..."
        Start-Process powershell "-ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
        Exit
    }
}

# Solicitar los permisos de administrador
Test-Admin

# Definir el directorio por defecto donde se creará el link simbólico
$defaultDirectory = "C:\laragon\www"

# Si no se proporcionaron los parámetros, solicitarlos al usuario
if (-not $Name) {
    $Name = Read-Host "Por favor, introduce el nombre del symlink"
}

if (-not $Target) {
    $Target = Read-Host "Por favor, introduce el camino (path) del destino del symlink"
}

# Comprobar si el directorio de destino existe
if (-not (Test-Path -Path $Target)) {
    Write-Warning "El directorio de destino '$Target' no existe."
    $createTarget = Read-Host "¿Desea crear este directorio? (S/N)"
    if ($createTarget -eq "S" -or $createTarget -eq "s") {
        New-Item -ItemType Directory -Path $Target -Force
        Write-Host "Directorio '$Target' creado con éxito."
    } else {
        Write-Host "Operación cancelada. No se creó el symlink."
        Exit
    }
}

# Informar al usuario del directorio por defecto y solicitar confirmación o cambio
Write-Host "El symlink se creará en el directorio por defecto: $defaultDirectory"
$confirm = Read-Host "¿Desea continuar con este directorio? (S/N)"
if ($confirm -eq "N" -or $confirm -eq "n") {
    $defaultDirectory = Read-Host "Por favor, introduce el nuevo directorio donde se creará el symlink"
}

# Crear el symlink
$LinkPath = Join-Path -Path $defaultDirectory -ChildPath $Name
New-Item -ItemType SymbolicLink -Path $LinkPath -Target $Target

# Confirmación de la creación
Write-Host "Symlink creado con éxito en: $LinkPath -> $Target"
