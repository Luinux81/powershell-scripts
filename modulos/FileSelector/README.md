# FileSelector Module

## Prerrequisitos

-  PowerShell 5.1 o superior (PowerShell Core / 7+ recomendado).
-  [fzf](https://github.com/junegunn/fzf) instalado y disponible en el PATH del sistema.

### Cómo instalar fzf en Windows

Puedes instalar `fzf` fácilmente usando gestores de paquetes:

-  Con **Scoop** (recomendado):

```powershell
iwr -useb get.scoop.sh | iex
scoop install fzf
```

-  Con **Chocolatey**:

```powershell
choco install fzf
```

-  Alternativamente, descarga el ejecutable desde la [página oficial](https://github.com/junegunn/fzf/releases) y agrega la ruta al PATH.

Para comprobar que `fzf` está correctamente instalado, abre PowerShell y ejecuta:

```powershell
fzf --version
```

Deberías ver la versión instalada si todo está correcto.

---

## Instalación del módulo

1. Copia la carpeta `FileSelector` que contiene `FileSelector.psm1` a la ruta de tus módulos, por ejemplo:

```
C:\Proyectos\powershell-scripts\modulos\FileSelector\
```

2. Importa el módulo en tu sesión de PowerShell:

```powershell
Import-Module C:\Proyectos\powershell-scripts\modulos\FileSelector\FileSelector.psm1
```

Opcionalmente, para que se importe automáticamente en todas las sesiones, añade la línea anterior a tu perfil de PowerShell (`$PROFILE`).

---

## Uso

Ejecuta la función para seleccionar archivos desde una carpeta específica (o desde la carpeta actual por defecto):

```powershell
$archivosSeleccionados = Select-FilesWithFzf -StartPath "C:\Ruta\A\Tu\Proyecto"
```

Aparecerá un menú interactivo en la terminal que te permitirá:

-  Navegar con las flechas arriba/abajo.
-  Usar TAB para seleccionar uno o más archivos.
-  Confirmar la selección con Enter.
-  Visualizar una previsualización de las primeras 20 líneas de cada archivo mientras navegas.

El resultado es un arreglo con las rutas completas de los archivos seleccionados.

---

## Ejemplo práctico: mostrar contenido de archivos seleccionados

```powershell
foreach ($archivo in $archivosSeleccionados) {
    Write-Host "=== $archivo ===" -ForegroundColor Cyan
    Get-Content -Path $archivo -Head 20
    Write-Host ""
}
```

---

## Notas

-  Si `fzf` no está instalado o no se encuentra en el PATH, la función mostrará un mensaje de error y no se ejecutará.
-  Puedes modificar la función para ajustar la cantidad de líneas de previsualización o adaptar el comportamiento según tus necesidades.

---

¡Disfruta tu selección interactiva de archivos en PowerShell!
