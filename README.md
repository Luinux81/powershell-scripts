# PowerShell Scripts

Colección de scripts y módulos de PowerShell para facilitar tareas comunes en desarrollo, administración y automatización.

---

## 📦 Contenido

-  **scripts/**: Scripts PowerShell organizados por categorías (filesystem, proyectos, shell, etc.)
-  **modulos/**: Módulos PowerShell reutilizables para extender funcionalidades
-  **bin/**: Enlaces simbólicos a scripts para agregar fácilmente al PATH y usarlos como comandos

---

## 🚀 Instalación

### 1. Clonar el repositorio

Ejecuta en PowerShell:

```powershell
git clone https://github.com/Luinux81/powershell-scripts.git
cd powershell-scripts
```

---

### 2. Configurar el entorno para ejecutar scripts

Por seguridad, PowerShell podría bloquear la ejecución de scripts. Para permitirlo, ejecuta:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### 3. Crear enlaces simbólicos en `bin`

Para facilitar la ejecución de los scripts desde cualquier lugar, el directorio `bin` contiene enlaces simbólicos a los scripts ubicados en `scripts/`. Puedes crear o actualizar estos enlaces con un script provisto (`Create-Symlinks.ps1`) o manualmente.

---

## 📂 Uso

### Uso de Scripts

-  Añade la carpeta `bin` al PATH para poder ejecutar los scripts fácilmente.

Para la sesión actual:

```powershell
$env:PATH += ";$(Resolve-Path .\bin)"
```

Para añadirlo permanentemente (requiere permisos de administrador):

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ruta\a\powershell-scripts\bin", [EnvironmentVariableTarget]::Machine)
```

-  Ahora puedes ejecutar scripts directamente por su nombre, con parámetros, por ejemplo:

```powershell
Get-Tree -Path "." -Files -Exclude @(".git", "vendor")
New-LaravelPackage -Name "MiPaquete"
```

-  Si no deseas modificar el PATH, también puedes ejecutar scripts directamente usando el operador call `&`:

```powershell
& ".\scripts\filesystem\Get-Tree.ps1" -Path "." -Files
```

---

### Uso de Módulos

-  Los módulos están en la carpeta `modulos/`. Para usarlos, copia el módulo deseado a una carpeta dentro de tu `$env:PSModulePath` o añade la ruta del módulo a esta variable.

Para ver las rutas actuales de módulos:

```powershell
$env:PSModulePath -split ';'
```

-  Para importar un módulo en tu sesión:

```powershell
Import-Module FileHelper
```

-  Luego podrás usar las funciones que exporta el módulo, por ejemplo:

```powershell
Get-FileDetails -Path "C:\MiArchivo.txt"
```

---

## 📖 Documentación adicional

Cada carpeta dentro de `scripts/` y `modulos/` contiene un archivo `README.md` con descripciones específicas y ejemplos de uso para facilitar su comprensión.

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Para sugerir mejoras o añadir scripts, abre un pull request.

---

## ⚖️ Licencia

Este proyecto está licenciado bajo la [MIT License](https://opensource.org/licenses/MIT).
