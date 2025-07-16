Aquí tienes el contenido del `README.md` sin formato de bloques de código, listo para copiar y pegar directamente en un archivo:

---

# Módulos PowerShell

Esta carpeta contiene varios módulos PowerShell desarrollados para facilitar tareas comunes y específicas en tus proyectos. Cada módulo está organizado en su propia carpeta con un archivo `.psm1` y un manifiesto `.psd1`.

---

## Módulos disponibles

**FileHelper**
Funciones de ayuda para manejo de archivos, incluyendo exploración interactiva, selección de archivos y utilidades relacionadas con el sistema de archivos.

**LBCFuncs**
Conjunto de funciones auxiliares personalizadas para facilitar tareas de desarrollo o administración (descripción genérica, detalles específicos por agregar).

**MySqlHelper**
Funciones para administrar y facilitar la interacción con bases de datos MySQL, como conexiones, consultas y operaciones comunes.

---

## Instalación

Para usar cualquiera de estos módulos, simplemente importa el módulo deseado especificando la ruta al archivo `.psd1`. Por ejemplo:

Import-Module C:\ruta\a\modulos\FileHelper\FileHelper.psd1

Si quieres que el módulo esté disponible en todas tus sesiones, considera añadir la importación a tu perfil de PowerShell (`$PROFILE`).

### Añadir el módulo al perfil ($PROFILE)

Puedes hacer que uno o más módulos se carguen automáticamente cada vez que abras una nueva sesión de PowerShell añadiendo la línea Import-Module al archivo de perfil.

1. Verifica si tienes un perfil:

```powershell
Test-Path $PROFILE
```

2. Si no tienes un perfil, créalo:

```powershell
New-Item -Path $PROFILE -ItemType File -Force
```

3. Abre el archivo de perfil en un editor:

```powershell
notepad $PROFILE
```

4. Añade una línea por cada módulo que quieras importar:

```powershell
Import-Module C:\Proyectos\powershell-scripts\modulos\FileHelper\FileHelper.psd1
Import-Module C:\Proyectos\powershell-scripts\modulos\MySqlHelper\MySqlHelper.psd1
Import-Module C:\Proyectos\powershell-scripts\modulos\LBCFuncs\LBCFuncs.psd1
```

5. Guarda el archivo y cierra el editor.

---

## Uso básico

Luego de importar un módulo, puedes listar las funciones disponibles con:

Get-Command -Module FileHelper

Y ejecutar cualquiera de las funciones exportadas directamente:

Select-FileInteractive

---

## Estructura del módulo

Cada módulo tiene:

-  Un archivo `.psm1` con el código de las funciones.
-  Un archivo `.psd1` que describe el módulo (manifiesto).
-  Posiblemente archivos adicionales para soporte, documentación o pruebas.

---

## Contribuciones y soporte

Para agregar funcionalidades o reportar problemas, abre un issue o pull request en el repositorio correspondiente.

---

Nota: Las descripciones de los módulos se actualizarán cuando se agregue la documentación específica y el código de cada uno.

---

## Contacto

Para consultas o ayuda, contacta al autor o administrador del repositorio.

---

¿Quieres que lo guarde como archivo o que avancemos con el README específico de algún módulo?
