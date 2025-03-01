param (
    [Parameter(Mandatory = $true, HelpMessage = "Número de veces que se ejecutará el comando")]
    [int]$RepeatCount,

    [Parameter(Mandatory = $true, HelpMessage = "El comando a ejecutar (entre comillas si contiene espacios)")]
    [string]$Command
)

for ($i = 1; $i -le $RepeatCount; $i++) {
    Write-Host "Ejecución $i de ${RepeatCount}: $Command"
    Invoke-Expression $Command

    # Opcional: comprobar si el comando se ejecutó correctamente
    if ($LASTEXITCODE -ne 0) {
        Write-Error "El comando falló en la iteración $i. Código de salida: $LASTEXITCODE"
        break
    }
}
