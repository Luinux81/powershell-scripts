
Add-Type -AssemblyName System.IO.Compression.FileSystem

Function Set-FileContentReplacement{
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$RutaArchivo,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Original,

        [Parameter(Mandatory=$true)]
        [string]$Reemplazo
    )

    $RutaArchivoMod = $RutaArchivo + ".tmp" 

    Get-Content $RutaArchivo -ReadCount 10000 |
        ForEach-Object {
            $linea = $_.Replace($original,$Reemplazo)
            Add-Content -Path $RutaArchivoMod -Value $linea
        }

    Remove-Item -Path $RutaArchivo

    Rename-Item $RutaArchivoMod $RutaArchivo
}

function Get-FileFromWeb {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$URL,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$File 
    )
    Begin {
        function Show-Progress {
            param (
                # Enter total value
                [Parameter(Mandatory)]
                [Single]$TotalValue,
        
                # Enter current value
                [Parameter(Mandatory)]
                [Single]$CurrentValue,
        
                # Enter custom progresstext
                [Parameter(Mandatory)]
                [string]$ProgressText,
        
                # Enter value suffix
                [Parameter()]
                [string]$ValueSuffix,
        
                # Enter bar lengh suffix
                [Parameter()]
                [int]$BarSize = 40,

                # show complete bar
                [Parameter()]
                [switch]$Complete
            )
            
            # calc %
            $percent = $CurrentValue / $TotalValue
            $percentComplete = $percent * 100
            if ($ValueSuffix) {
                $ValueSuffix = " $ValueSuffix" # add space in front
            }
            if ($psISE) {
                Write-Progress "$ProgressText $CurrentValue$ValueSuffix of $TotalValue$ValueSuffix" -id 0 -percentComplete $percentComplete            
            }
            else {
                # build progressbar with string function
                $curBarSize = $BarSize * $percent
                $progbar = ""
                $progbar = $progbar.PadRight($curBarSize,[char]9608)
                $progbar = $progbar.PadRight($BarSize,[char]9617)
        
                if (!$Complete.IsPresent) {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($CurrentValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"
                }
                else {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($TotalValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"                    
                }                
            }   
        }
    }
    Process {
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
        
            # invoke request
            $request = [System.Net.HttpWebRequest]::Create($URL)
            $response = $request.GetResponse()
  
            if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
                throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
            }
  
            if($File -match '^\.\\') {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") ($File -Split '^\.')[1]
            }
            
            if($File -and !(Split-Path $File)) {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") $File
            }

            if ($File) {
                $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
                if (!(Test-Path($fileDirectory))) {
                    [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
                }
            }

            [long]$fullSize = $response.ContentLength
            $fullSizeMB = $fullSize / 1024 / 1024
  
            # define buffer
            [byte[]]$buffer = new-object byte[] 1048576
            [long]$total = [long]$count = 0
  
            # create reader / writer
            $reader = $response.GetResponseStream()
            $writer = new-object System.IO.FileStream $File, "Create"
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB" -Complete
                    $finalBarCount++
                    #Write-Host "$finalBarCount"
                }

            } while ($count -gt 0)
        }
  
        catch {
        
            $ExeptionMsg = $_.Exception.Message
            Write-Host "Download breaks with error : $ExeptionMsg"
        }
  
        finally {
            # cleanup
            if ($reader) { $reader.Close() }
            if ($writer) { $writer.Flush(); $writer.Close() }
        
            $ErrorActionPreference = $storeEAP
            [GC]::Collect()
        }    
    }
}

function Expand-Zip {
    <#
    .Synopsis
        Extracts files or directories from a zip folder
    .Parameter Path
        The path to the Zip folder to extract
    .Parameter Destination
        The location to extract the files to
    .Parameter ZipDirectory
        The directory within the zip folder to extract. If not specified, extracts the whole zip file
    .Parameter ZipFileName
        The name of a specific file within ZipDirectory to extract
    .Example
        Expand-Zip c:\sample.zip c:\files\
         
        Description
        -----------
        This command extracts the entire contents of c:\sample.zip to c:\files\
    .Example
        Expand-Zip c:\sample.zip c:\sample\web\ -ZipDirectory web
         
        Description
        -----------
        This command extracts the contents of the web directory of c:\sample.zip to c:\sample\web
    .Example
        Expand-Zip c:\sample.zip c:\test\ -ZipDirectory documentation -zipFileName sample.txt
         
        Description
        -----------
        This command extracts the sample.txt file from the web directory of c:\sample.zip to c:\sample\sample.txt
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Zip $_ })]
        [string]$Path,
        [parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [ValidateScript({!$_ -or (Test-Path $_ -PathType Container -IsValid)})]
        [string]$ZipDirectory,
        [ValidateScript({!$_ -or (Test-Path $_ -PathType Leaf -IsValid)})]
        [string]$ZipFileName
    )

    $prefix = ''
    if($ZipDirectory){
        $prefix = ($ZipDirectory).Replace('\','/').Trim('/') + '/'
    }
    if (!(test-path $Destination -PathType Container)) {
        New-item $Destination -Type Directory | out-null
    }

    #Convert path requried to ensure
    $absoluteDestination = (Resolve-Path $Destination).ProviderPath
    $zipAbsolutePath = (Resolve-Path $Path).ProviderPath

    $zipPackage = [IO.Compression.ZipFile]::OpenRead($zipAbsolutePath)
    try {
        $entries = $zipPackage.Entries
        if ($ZipFileName){
            $entries = $entries |
                ? {$_.FullName.Replace('\','/') -eq "${prefix}${ZipFileName}"} |
                select -First 1
        }
        else {
            #Filter out directories
            $entries = $zipPackage.Entries |? Name
            if ($ZipDirectory) {
                #Filter out items not under requested directory
                $entries = $entries |? { $_.FullName.Replace('\','/').StartsWith($prefix, "OrdinalIgnoreCase")}
            }
        }

        $totalFileSize = ($entries |ForEach-Object length | Measure-Object -sum).Sum
        $processedFileSize = 0
        $entries |ForEach-Object {
            $destination = join-path $absoluteDestination $_.FullName.Substring($prefix.Length)
            
            Write-Progress 'Extracting Zip' `
                -CurrentOperation $_.FullName `
                -PercentComplete ($processedFileSize / $totalFileSize * 100)
            
            $itemDir = split-path $Destination -Parent
            if (!(Test-Path $itemDir -PathType Container)) {
                New-item $itemDir -Type Directory | out-null
            }
            [IO.Compression.ZipFileExtensions]::ExtractToFile($_, $Destination, $true)

            $processedFileSize += $_.Length
        }
        #Write-Progress 'Extracting-Zip' -Completed
        
    }
    finally {
        $zipPackage.Dispose()
    }
}

function Test-Zip {
    <#
    .Synopsis
        Tests whether a file exists and is a valid zip file.
 
    .Parameter Path
        The path to the file to test
 
    .Example
        Test-Zip c:\sample.zip
         
        Description
        -----------
        This command checks if the file c:\sample.zip exists
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    Test-Path $Path -PathType Leaf
    if((Get-Item $Path).Extension -ne '.zip') {
        throw "$Path is not a zip file"
    }
}

Export-ModuleMember -Function *