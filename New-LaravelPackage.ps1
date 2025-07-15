# Uso: .\create-laravel-package.ps1 mi-usuario mi-paquete

param (
    [string]$Vendor,
    [string]$Package
)

if (-not $Vendor -or -not $Package) {
    Write-Host "Uso: .\create-laravel-package.ps1 <vendor> <package>"
    Write-Host "Ejemplo: .\create-laravel-package.ps1 mi-usuario mi-paquete"
    exit 1
}

# Función para capitalizar cada palabra (tipo PascalCase)
function Edit-To-PascalCase($text) {
    return ($text -split '[-_]' | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }) -join ''
}

$VendorPascal = Edit-To-PascalCase $Vendor
$PackagePascal = Edit-To-PascalCase $Package

# Crear estructura de directorios
$paths = @(
    "$Package/src/Http/Controllers",
    "$Package/src/Http/Middleware",
    "$Package/src/Models",
    "$Package/src/Providers",
    "$Package/src/Services",
    "$Package/src/Traits",
    "$Package/config",
    "$Package/resources/views",
    "$Package/tests/Unit",
    "$Package/tests/Feature",
    "$Package/database/migrations",
    "$Package/database/seeders"
)

foreach ($path in $paths) {
    New-Item -Path $path -ItemType Directory -Force | Out-Null
}

# Crear composer.json
$composerJson = @"
{
    "name": "$Vendor/$Package",
    "description": "Descripción del paquete $Package",
    "type": "library",
    "license": "MIT",
    "authors": [
        {
            "name": "Tu Nombre",
            "email": "tu@email.com"
        }
    ],
    "require": {
        "php": "^8.2",
        "illuminate/support": "^10.0|^11.0"
    },
    "require-dev": {
        "phpunit/phpunit": "^11.0",
    },
    "autoload": {
        "psr-4": {
            "$VendorPascal\\\\$PackagePascal\\\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "$VendorPascal\\\\$PackagePascal\\\\Tests\\\\": "tests/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "$VendorPascal\\\\$PackagePascal\\\\Providers\\\\${PackagePascal}ServiceProvider"
            ]
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
"@
Set-Content -Path "$Package/composer.json" -Value $composerJson

# Crear Service Provider
$serviceProvider = @"
<?php

namespace $VendorPascal\\$PackagePascal\\Providers;

use Illuminate\Support\ServiceProvider;

class ${PackagePascal}ServiceProvider extends ServiceProvider
{
    public function register()
    {
        \$this->mergeConfigFrom(__DIR__ . '/../../config/$Package.php', '$Package');
    }

    public function boot()
    {
        // Publicar configuración
        \$this->publishes([
            __DIR__ . '/../../config/$Package.php' => config_path('$Package.php'),
        ], 'config');

        // Cargar vistas
        \$this->loadViewsFrom(__DIR__ . '/../../resources/views', '$Package');

        // Publicar vistas
        \$this->publishes([
            __DIR__ . '/../../resources/views' => resource_path('views/vendor/$Package'),
        ], 'views');
    }
}
"@
Set-Content -Path "$Package/src/Providers/${PackagePascal}ServiceProvider.php" -Value $serviceProvider

# Crear archivo de configuración
$configPhp = @"
<?php

return [
    'enabled' => true,
    // Configuración del paquete
];
"@
Set-Content -Path "$Package/config/$Package.php" -Value $configPhp

# Crear README.md
$readme = @"
# $Package

Descripción del paquete $Package

## Instalación

\`\`\`bash
composer require $Vendor/$Package
\`\`\`

## Uso

\`\`\`php
// Ejemplos de uso
\`\`\`

## Configuración

Publicar configuración:
\`\`\`bash
php artisan vendor:publish --provider="$VendorPascal\\$PackagePascal\\Providers\\${PackagePascal}ServiceProvider" --tag="config"
\`\`\`

## Licencia

MIT
"@
Set-Content -Path "$Package/README.md" -Value $readme

# Crear .gitignore
$gitignore = @"
/vendor/
/node_modules/
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
.DS_Store
Thumbs.db
"@
Set-Content -Path "$Package/.gitignore" -Value $gitignore

# Mensaje final
Write-Host "`n✅ Paquete $Vendor/$Package creado exitosamente!"
Write-Host "📁 Directorio: $Package"
Write-Host "🚀 Próximos pasos:"
Write-Host "   cd $Package"
Write-Host "   Edita el archivo composer.json con tus detalles"
Write-Host "   composer install"
Write-Host "   git init"
Write-Host "   git remote add origin https://github.com/$Vendor/$Package.git"
