function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# No funciona 
Function Invoke-ElevatedShell{
    Param (
        [switch] $ElevatedShell
    )

    $current_dir = (Get-Location).path

    if ((Test-Admin) -eq $false)  {
        if ($ElevatedShell) {
            # tried to elevate, did not work, aborting
            Write-Output 'tried to elevate, did not work, aborting'
        } else {
            # $params = '-noprofile -noexit -file "{0}" -elevated ' + $current_dir
            $params = '-noexit -file "{0}" -elevated ' + $current_dir
            
            Start-Process powershell.exe -Verb RunAs -ArgumentList ($params -f ($myinvocation.MyCommand.Definition)) 
        }
        exit
    }


}

Export-ModuleMember -Function *