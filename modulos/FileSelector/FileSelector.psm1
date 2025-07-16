function Select-FilesWithFzf {
    [CmdletBinding()]
    param(
        [string]$StartPath = (Get-Location).Path
    )

    # Obtener todos los archivos recursivamente desde $StartPath
    $files = Get-ChildItem -Path $StartPath -File -Recurse | Sort-Object FullName

    if (-not $files) {
        Write-Warning "No se encontraron archivos en $StartPath"
        return $null
    }

    # Crear lista de rutas relativas para mostrar en fzf
    $relativePaths = $files | ForEach-Object {
        $_.FullName.Substring($StartPath.Length + 1).TrimStart('\')
    }

    # Establecer FZF_DEFAULT_OPTS para ocultar preview
    $oldFzfOpts = $env:FZF_DEFAULT_OPTS
    $env:FZF_DEFAULT_OPTS = "--preview-window 'up:50%:hidden'"
    
    # Ejecutar fzf con selección múltiple y mostrar rutas relativas
    $selection = $relativePaths | fzf --multi --prompt "Selecciona archivos: "

    # Restaurar la configuración previa
    $env:FZF_DEFAULT_OPTS = $oldFzfOpts
    
    if (-not $selection) {
        return $null
    }

    # Convertir las rutas relativas seleccionadas a rutas absolutas
    $selectedFullPaths = $selection | ForEach-Object {
        Join-Path -Path $StartPath -ChildPath $_
    }

    return $selectedFullPaths
}


Export-ModuleMember -Function Select-FilesWithFzf
