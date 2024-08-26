param (
    [string]$projectName,
    [string]$dbName,
    [string]$dbUser,
    [securestring]$dbPassword,
    [string]$siteUrl,
    [string]$siteTitle,
    [string]$adminUser,
    [securestring]$adminPassword,
    [string]$adminEmail
)

# Funcion para comprobar si el directorio del proyecto existe y no está vacio
function Test-ProjectName {
    param (
        [string]$name
    )
    $path = Join-Path -Path (Get-Location) -ChildPath $name
    $directoryExists = Test-Path -Path $path

    if ($directoryExists) {
        # Comprobar si el directorio está vacío
        $isEmpty = -not (Get-ChildItem -Path $path -Recurse | Where-Object { $_.PSIsContainer -or $_.Name } )
        return -not $isEmpty # Si no está vacío, devolverá true
    }
    return $false # Si no existe, devolverá false
}

# Funcion para comprobar si la base de datos existe
function Test-DatabaseExists {
    param (
        [string]$name,
        [string]$user,
        [string]$password
    )
    $dbExists = wp db check --dbname=$name --dbuser=$user --dbpass=$password 2>&1 | Select-String "database exists"
    return $dbExists -ne $null
}

# Solicitar nombre del proyecto hasta que sea valido
do {
    if (-not $projectName) {
        $projectName = Read-Host "Ingrese el nombre del proyecto"
    }
    $projectExists = Test-ProjectName -name $projectName
    if ($projectExists) {		    
        Write-Host "El directorio '$projectName' ya existe y no está vacio. Por favor, ingrese otro nombre de proyecto." -ForegroundColor Red
        $projectName = $null
    }
} while ($projectExists)

$projectPath = Join-Path -Path (Get-Location) -ChildPath $projectName


# Solicitar usuario de la base de datos
if (-not $dbUser) {
	$default = "root"
	if (!($dbUser = Read-Host "Ingrese el usuario de la base de datos [${default}]")) { $dbUser = $default }
}

# Solicitar password de la base de datos
if (-not $dbPassword) {
    $dbPassword = Read-Host "Ingrese la contrasena de la base de datos" -AsSecureString
}

# Solicitar nombre de la base de datos hasta que sea valido
do {	
    if (-not $dbName) {        
		$default = "wpdb_${projectName}"
		if (!($dbName = Read-Host "Ingrese el nombre de la base de datos [${default}]")) { $dbName = $default }
    } 
	
	$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
	$dbExists = Test-DatabaseExists -name $dbName -user $dbUser -password $dbPasswordPlain
	if ($dbExists) {
		Write-Host "La base de datos '$dbName' ya existe. Por favor, ingrese otro nombre de base de datos." -ForegroundColor Red
		$dbName = $null
	}
    
} while (-not $dbName)


# Solicitar url del sitio
if (-not $siteUrl) {
	$default = "http://localhost/${projectName}"
	if (!($siteUrl = Read-Host "Ingrese la URL del sitio [${default}]")) { $siteUrl = $default }
}

# Solicitar titulo del sitio
if (-not $siteTitle) {
	$default = "Mi Tienda Online"
	if (!($siteTitle = Read-Host "Ingrese la URL del sitio [${default}]")) { $siteTitle = $default }
}

# Solicitar el usuario administrador
if (-not $adminUser) {
	$default = "admin"
	if (!($adminUser = Read-Host "Ingrese el nombre de usuario administrador [${default}]")) { $adminUser = $default }
}

if (-not $adminPassword) {
    $adminPassword = Read-Host "Ingrese la contrasena del administrador" -AsSecureString
}
$adminPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword))


# Solicitar email del usuario administrador
if (-not $adminEmail) {
	$default = "admin@example.com"
	if (!($adminEmail = Read-Host "Ingrese el email de usuario administrador [${default}]")) { $adminEmail = $default }
}


# Crear directorio del proyecto
New-Item -ItemType Directory -Path $projectPath -Force
Set-Location $projectPath

# Descargar WordPress
wp core download --locale=es_ES

# Crear archivo de configuracion
wp config create --dbname=$dbName --dbuser=$dbUser --dbpass=$dbPasswordPlain

# Crear base de datos
wp db create

# Instalar WordPress
wp core install --url=$siteUrl --title=$siteTitle --admin_user=$adminUser --admin_password=$adminPasswordPlain --admin_email=$adminEmail

# Instalar y activar plugins
$pluginsSeguridad = @("wordfence", "wps-hide-login")
$pluginsMantenimiento = @("all-in-one-wp-migration")
$pluginsSEO = @("seo-by-rank-math", "wordpress-seo", "google-site-kit")
$pluginsExtension = @("advanced-custom-fields", "svg-support", "contact-form-7")
$pluginsOptimizacion = @("litespeed-cache", "redirection")
$pluginsFrontend = @("astra-sites", "insert-headers-and-footers")
$pluginsEcommerce = @("woocommerce")

$plugins = $pluginsSeguridad + $pluginsMantenimiento + $pluginsSEO + $pluginsExtension + $pluginsOptimizacion + $pluginsFrontend + $pluginsEcommerce

# Contar el número total de plugins
$totalPlugins = $plugins.Count

# Inicializar contador
$pluginCounter = 1

foreach ($plugin in $plugins) {
	# Mostrar progreso
    Write-Host "Instalando plugin $pluginCounter de $totalPlugins" -ForegroundColor Yellow
	
	if ($plugin -eq "wps-hide-login"){
		$activar = ""
	}
	else{
		$activar = "--activate"
	}
	
    wp plugin install $plugin $activar
	
	# Incrementar contador
    $pluginCounter++
}


# Instalar y activar tema
wp theme install storefront --activate

Write-Output "La instalacion de $siteTitle se ha completado en $siteUrl"
