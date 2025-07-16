@{
    ModuleVersion     = '1.0'
    GUID              = '12345678-1234-1234-1234-123456789abc'
    Author            = 'LBCDev'
    Description       = 'Funciones helper para manejo de archivos'
    RootModule        = 'FileHelper.psm1'
    FunctionsToExport = @('Select-FileInteractive', 'Get-FileFromWeb', 'Expand-Zip', 'Test-Zip', 'Set-FileContentReplacement')
}
