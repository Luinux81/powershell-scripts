# Powershell Scripts

PowerShell Scripts - A collection of PowerShell scripts for various tasks

## **PowerShell WordPress Installation Script**

Este script de PowerShell automatiza la instalación de WordPress y la configuración de plugins de seguridad, SEO, optimización, frontend, y más. Además, permite la instalación opcional de plugins para sitios multilingües y eCommerce.

### **Requisitos previos**

Antes de ejecutar el script, asegúrate de cumplir con los siguientes requisitos:

1. **PowerShell**: Asegúrate de tener instalado PowerShell (versión 5.1 o superior) en tu sistema.
2. **wp-cli**: Debes instalar wp-cli, una herramienta de línea de comandos para gestionar instalaciones de WordPress.

#### **Instalar wp-cli**

Para instalar wp-cli, sigue las [instrucciones oficiales](https://wp-cli.org/). Asegúrate de que el comando `wp` esté disponible en tu variable `PATH`.

#### **Incluir wp-cli en el PATH en Windows**

Si no has agregado wp-cli al `PATH`, sigue estos pasos:

1. Abre el **Panel de Control** y navega a **Sistema y Seguridad** > **Sistema** > **Configuración avanzada del sistema**.
2. En la pestaña **Opciones avanzadas**, haz clic en **Variables de entorno**.
3. En **Variables del sistema**, selecciona la variable `Path` y haz clic en **Editar**.
4. Agrega la ruta completa donde se encuentra `wp-cli`. Ejemplo:
   ```
   C:\ruta\a\wp-cli
   ```
5. Haz clic en **Aceptar** en todas las ventanas y reinicia cualquier terminal que estuvieras usando para aplicar los cambios.

#### **Instalar dependencias**

Instala las dependencias necesarias con:

```powershell
Install-Module -Name "PSReadline" -Force -SkipPublisherCheck
```

### **Clonar el repositorio**

Primero, debes clonar este repositorio desde GitHub:

```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
cd tu-repositorio
```

### **Parámetros de entrada**

El script acepta varios parámetros, los cuales se pueden proporcionar al ejecutarlo. Si no se proporciona un parámetro, el script solicitará el valor correspondiente durante la ejecución.

#### **Parámetros**

-  `-projectName` _(string)_: Nombre del proyecto (creará un directorio con este nombre). Si no se especifica y el directorio existe, pedirá un nuevo nombre.
-  `-dbName` _(string)_: Nombre de la base de datos a crear. Se solicitará un nombre alternativo si la base de datos ya existe.
-  `-dbUser` _(string)_: Nombre de usuario para la base de datos. Valor predeterminado: `"root"`.
-  `-dbPassword` _(securestring)_: Contraseña para la base de datos. Se puede pasar como entrada segura.
-  `-siteUrl` _(string)_: URL del sitio WordPress. Valor predeterminado: `"http://localhost/{projectName}"`.
-  `-siteTitle` _(string)_: Título del sitio web. Valor predeterminado: `"Mi Web Wordpress"`.
-  `-adminUser` _(string)_: Usuario administrador de WordPress. Valor predeterminado: `"admin"`.
-  `-adminPassword` _(securestring)_: Contraseña para el usuario administrador.
-  `-adminEmail` _(string)_: Correo electrónico del administrador. Valor predeterminado: `"admin@example.com"`.

### **Instrucciones de uso**

Puedes ejecutar el script con o sin parámetros. Si no proporcionas los parámetros al inicio, el script te solicitará que los ingreses durante la ejecución.

#### **Ejemplo 1: Ejecución básica sin parámetros**

Al ejecutar sin parámetros, el script te pedirá ingresar la información faltante:

```bash
.\New-Wordpress.ps1
```

#### **Ejemplo 2: Ejecución con parámetros**

Puedes proporcionar algunos o todos los parámetros al invocar el script:

```bash
.\New-Wordpress.ps1 -projectName "mi_tienda" -dbName "mi_tienda_db" -dbUser "root" -siteUrl "http://localhost/mi_tienda" -siteTitle "Mi Tienda Online" -adminUser "admin" -adminEmail "admin@example.com"
```

### **Funcionamiento**

El script realiza las siguientes tareas:

1. **Comprobación del directorio del proyecto**: Si el directorio ya existe y no está vacío, solicita un nuevo nombre de proyecto.
2. **Comprobación de la base de datos**: Si la base de datos ya existe, solicita un nuevo nombre de base de datos.
3. **Configuración e instalación de WordPress**:
   -  Descarga la última versión de WordPress.
   -  Crea el archivo de configuración con la información de la base de datos.
   -  Crea la base de datos.
   -  Instala WordPress usando la información de entrada.
4. **Instalación de plugins**:
   -  Instala y activa plugins de varias categorías como seguridad, SEO, optimización, frontend, etc.
   -  Muestra el progreso de instalación de cada plugin.
   -  Pregunta si se desea instalar plugins adicionales para eCommerce y multilenguaje.
5. **Instalación de temas**: Instala y activa el tema `storefront` después de instalar los plugins.

#### **Categorías de plugins**

-  **Seguridad**: wordfence, wps-hide-login
-  **Mantenimiento**: all-in-one-wp-migration
-  **SEO**: seo-by-rank-math, wordpress-seo, google-site-kit
-  **Extensiones**: advanced-custom-fields, svg-support, contact-form-7
-  **Optimización**: litespeed-cache, redirection
-  **Frontend**: astra-sites, insert-headers-and-footers
-  **eCommerce (opcional)**: woocommerce
-  **Idiomas (opcional)**: polylang, woo-poly-integration

### **Contribuciones**

Sientete libre de contribuir con nuevas características o mejoras enviando un pull request al repositorio.

### **Licencia**

Este proyecto está licenciado bajo los términos de la [MIT License](https://opensource.org/licenses/MIT).
