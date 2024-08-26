# Uso:
# Inicializar en el script donde se importe el módulo con:
#
# [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
#
# Import-Module MySqlHelper
#

[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")

Function Get-MySqlConnection {
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter()]
        [string]$Pass,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MySQLHost,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 3306,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$MySQLDatabase
    )

    if ( $PSBoundParameters.ContainsKey('MySQLDatabase')) {
        $ConnectionString = "server=" + $MySQLHost + ";port=" + $Port + ";uid=" + $User + ";pwd=" + $Pass + ";database="+$MySQLDatabase
    }
    else{
        $ConnectionString = "server=" + $MySQLHost + ";port=" + $Port + ";uid=" + $User + ";pwd=" + $Pass
    }

    [MySql.Data.MySqlClient.MySqlConnection]$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)

    return $conn
}

Function Test-MySqlDatabase{
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $NombreDB,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [MySql.Data.MySqlClient.MySqlConnection] $Connection        
    )

    $Query = "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '" + $NombreDB + "'"

    $RecordCount, $DataSet = Get-MySqlData -Query $Query -Connection $Connection

    return ($RecordCount -gt 0)
}

Function New-MySqlDatabase{
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $NombreDB,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [MySql.Data.MySqlClient.MySqlConnection] $Connection        
    )

    Begin {
        $Connection.Open()
        $Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = 'CREATE SCHEMA `' + $NombreDB + '`'
    }
    Process{
        $Command.ExecuteNonQuery()
    }
    End{
        $Connection.Close()
        return 
    }
}

Function Get-MySqlData {    
    [CmdletBinding()]   
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [MySql.Data.MySqlClient.MySqlConnection] $Connection        
    )

    Begin {
        $Connection.Open()
        $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
    }
    Process{
        $DataSet = New-Object System.Data.DataSet
        $RecordCount = $dataAdapter.Fill($DataSet, "data")
    }
    End{
        $Connection.Close()
        return $RecordCount, $DataSet
    }
}

Function Add-MySqlContent {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $DataFile,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [MySql.Data.MySqlClient.MySqlConnection] $Connection           
    )

    Begin {
        $Connection.Open()
        $Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = Get-Content $DataFile -Raw
    }
    Process{
        $salida = $Command.ExecuteNonQuery()
    }
    End{
        $Connection.Close()
        return $salida
    }    
}

Export-ModuleMember -Function *