---
title: Servidor de páginas web estáticas
description: Cómo instalar y configurar un servidor de páginas web estáticas con Caddy en un LXC.
layout: libdoc_page.liquid
permalink: "{{ libdocConfig.blogSlug }}/{{title | slugify}}/index.html"
tags:
    - post
    - caddy
    - web server
    - páginas estáticas
date: 2026-10-12
---

# Instalación

Ya tenemos un contenedor LXC con Caddy y un disco ***Antea*** montado en `/mnt/antea`. 

La idea es tener un script en Windows que haga todo el trabajo de subir un sitio web estático a nuestro servidor de webs estáticas, y que además genere automáticamente el índice de webs. Para ello, vamos a:

* Crear un usuario `webadmin` para subir los sitios web desde Windows
* Cargar los scripts `deploy-site` y `webs-index` al LXC de Caddy que permiten subir y eliminar sitios web y regenerar el índice de webs.
* Modificar el Caddyfile para que sirva nuestras webs estáticas desde `webs.fpgh.link` y que el índice de webs se genere automáticamente.
* Generar la clave SSH en Windows y copiarla al servidor de webs estáticas para poder subir los sitios web sin contraseña.
* Crear el script de subida de sitios `subir-sitio.ps1` para que funcione con el nuevo servidor de webs estáticas.
* Actualizar el lanzador `subir-sitio.cmd` para que acepte argumentos y pueda eliminar sitios web.
* Actualizar el PATH de Windows para que incluya la carpeta `Scripts` donde está el script `subir-sitio.ps1`.


## 1. Crear el usuario webadmin

Para esta instalación hay que entrar al nodo de Proxmox a través de SSH `ssh root@<IPdelNodo>` o por la IP del nodo `https://IPdelNodo:8006`, si entras por `https://proxmox.fpgh.link`, esa conexión pasa por el propio LXC de Caddy para generar una conexión segura y cuando hay que reiniciar Caddy se pierde la conexión con Proxmox.

En el host de **Proxmox** (el disco Antea ya está montado en `/mnt/antea`).

* Saca el ID del LXC de Caddy:
```bash
pct list
```

* Y ejecuta los siguientes comandos con el número de ID sin `<>`
```bash
pct set <ID> -mp0 /mnt/antea/webs,mp=/srv/webs
pct reboot <ID>
```

Después comprueba el mapeo de propietarios, como Caddy lo instalamos en un contenedor con proteción habilitada, no podemos mapear el propietario de los archivos a `www-data` (el usuario de Caddy) y por eso debemos deshabilitar la protección del contenedor para poder mapearlo correctamente.
```bash
pct set <ID> -protection 0
pct set <ID> -mp0 /mnt/antea/webs,mp=/srv/webs
pct set <ID> -onboot 1
pct reboot <ID>
pct set <ID> -protection 1
```

Cuando arranque, comprueba el mapeo:
```bash
pct exec <ID> -- ls -a -ln /srv/webs
```

Deberías ver `1000 1000` como dueño de `sites` y `.staging`. Si es así, desde proxmox puedes entrar al LXC con `pct enter <ID>` y luego ejecuta:

```bash
apt install -y openssh-server
adduser webadmin
id webadmin
```
Cuando se cree el usuario `webadmin` te pedirá crear una contraseña. Y luego comprueba que el usuario se ha creado correctamente con:

```bash
id webadmin
```

Devolverá algo como:
```
uid=1000(webadmin) gid=1000(webadmin) groups=1000(webadmin),100(users)
```

## 2. Cargar ficheros al servidor

Vamos a subir los ficheros:
* ***deploy-site*** - sirve para desplegar un sitio web en el servidor, se prepara en .staging, fuera de las páginas servidas pero en el mismo directorio, así el `mv` final es (atómico) rápido y no hay tiempo de inactividad. Regenera el índice de webs al final.
* ***webs-index*** - Regenera `/srv/webs/sites/index.html`. Lo llama `deploy-site`; también se puede lanzar a mano.

1. Para cargarlos, desde Windows, vamos a la carpeta de descargas y copiamos `webs-index` y `deploy-site` a Proxmox:

    ```bash
    cd $env:USERPROFILE\Downloads
    scp deploy-site webs-index root@192.168.1.100:/tmp/
    ```

2. Entra al LXC de Caddy y mueve los ficheros a `/usr/local/bin`:

    ```bash
    ls -l /tmp/deploy-site /tmp/webs-index
    pct push <ID> /tmp/deploy-site /usr/local/bin/deploy-site --perms 755
    pct push <ID> /tmp/webs-index /usr/local/bin/webs-index --perms 755
    pct exec <ID> -- sed -i 's/\r$//' /usr/local/bin/deploy-site /usr/local/bin/webs-index
    pct exec <ID> -- ls -l /usr/local/bin/deploy-site /usr/local/bin/webs-index
    ``` 

    La primera instrucción comprueba que los ficheros están en `/temp` y la segunda los copia a `/usr/local/bin` con permisos de ejecución. La tercera elimina los retornos de carro de Windows. La última comprueba que los ficheros están en `/usr/local/bin` y son ejecutables.

3. Prueba local dentro del LXC, sin red de por medio, para validar el despliegue y el generador antes de tocar Caddy. 
    Entra al LXC de caddy desde proxmox con `pct enter <ID>` y ejecuta:
    ```bash
    su - webadmin
    mkdir -p /tmp/prueba/assets && echo '<html><head><title>Prueba</title><meta name="description" content="Sitio de prueba"></head><body>hola</body></html>' > /tmp/prueba/index.html
    tar -cf - -C /tmp/prueba . | /usr/local/bin/deploy-site prueba
    ls -l /srv/webs/sites
    ```

    Debe imprimir `Sitio prueba publicado`. y listar `index.html`, `_icons` y la carpeta `prueba`.

    Para borrar la prueba vamos a usar el propio script, así también regeneramos el índice:
    ```bash
    /usr/local/bin/deploy-site --remove prueba
    rm -rf /tmp/prueba
    ls -l /srv/webs/sites
    ```

    Debe imprimir `Sitio prueba eliminado.` y dejar solo `_icons` e `index.html` (con 0 sitios). Este último ejercita el borrado, que aún no habíamos probado.

## 3. Modificar el Caddyfile
El bloque de Caddyfile que ya tenenmos no sirve las webs estáticas aún, hay que añadir un bloque handle para `webs.fpgh.link`, y tiene que estar antes del `handle { abort }`. El certificado wild card ya cubre `webs.fpgh.link`, así que no hay que tocar nada de TLS.
   1. Entra en el LXC de Caddy como root
        ```bash
        pct enter <ID>
        ```

   2. Edita el Caddyfile para añadir el bloque de `webs.fpgh.link`, justo despues del `handle @proxmox { ... }` y antes del `handle { abort }`:
        ```bash
        cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bak
        nano /etc/caddy/Caddyfile
        ``` 

   3. El archivo completo quedará así:
        ```text
        ##############################
        # Mi Caddyfile JP
        ##############################
        # 06/10/26 - Certificados TLS + Acceso a Proxmox
        # 11/10/26 - Acceso a webs estaticas

        ##############################

        *.fpgh.link {
                # Certificado TLS de Cloudflare
                tls {
                        dns cloudflare {env.CF_API_TOKEN}
                }
                # Acceso a Proxmox (100)
                @proxmox host proxmox.fpgh.link
                handle @proxmox {
                        reverse_proxy https://192.168.1.100:8006 {
                                transport http {
                                        tls_insecure_skip_verify
                                }
                        }
                }
                # Acceso a webs (caddy en 102 y webs en '/mnt/antea'
                @webs host webs.fpgh.link
                handle @webs {
                        root * /srv/webs/sites
                        file_server
                }
                # Fin de los manejadores
                handle {
                        abort
                }
        }
        ```

   4. Valida antes de recargar
        ```bash
        caddy validate --config /etc/caddy/Caddyfile
        ```
        Debe terminar con `Valid configuration`. Si no es así, revisa el Caddyfile y corrige los errores.

        Es posible que de un fallo de Token, lo almacena en `/etc/caddy/env`, valida cargándola solo para ese comando:
        ```bash
        sudo bash -c 'set -a; . /etc/caddy/caddy.env; set +a; caddy validate --config /etc/caddy/Caddyfile'
        ```
        Debería acabar con `Valid configuration`.

   5. Recarga Caddy
        ```bash
        systemctl reload caddy
        systemctl status caddy --no-pager
        journalctl -u caddy -n 20 --no-pager
        ``` 
        Si en el `status` aparece `active (running)` y el journal no muestra errores tras el reload, la configuración se aplicó.


   6. Puedes probarlo desde el propio LXC forzando la resolución:
        ```bash
        curl -I --resolve webs.fpgh.link:443:127.0.0.1 https://webs.fpgh.link/
        ```
        Debe responder `HTTP/2 200`. Con la prueba borrada el índice sale vacío, pero tiene que servirse. 

   7. Desde Windows, prueba con:
        ```powershell
        nslookup webs.fpgh.link
        ```
        Debe devolver la IP de Caddy `192.168.1.102`. Si lo hace, abre en navegador `https://webs.fpgh.link/`. Debería mostrarte el índice de webs, aunque esté vacío.


## 4. Generar la clave SSH y copiarla al servidor

Para subir el sitio web desde Windows, primero hay que generar la clave SSH en Windows y copiarla clave pública al servidor de webs estáticas. Para ello, abre PowerShell y ejecuta:

```powershell
Test-Path $env:USERPROFILE\.ssh\id_ed25519.pub
```
Si devuelve `False`, genera la clave (te pregunta una passphrase, déjala vacía con Enter):
```powershell
ssh-keygen -t ed25519
```
Después copia la clave pública al servidor de webs estáticas (el LXC de Caddy):
```powershell
scp $env:USERPROFILE\.ssh\id_ed25519.pub webadmin@webs.fpgh.link:/tmp/k.pub
ssh webadmin@webs.fpgh.link "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat /tmp/k.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm /tmp/k.pub"
```
Y comprueba que puedes entrar sin contraseña:
```powershell
ssh webadmin@webs.fpgh.link "echo ok"
```
Debe imprimir `ok` sin pedir nada. 

## 5. Crear el script de subida de sitio (subir-sitio.ps1)

  El script de Windows se ubica en la carpeta `C:\Users\juanp\Scripts\`. Contiene:

   * ***subir-sitio***: publica _site como /`<nombre-carpeta>`/
   * ***subir-sitio -Eliminar***: elimina el sitio del servidor

En PowerShell, el bloque siguiente guarda una copia del script antiguo (se probó anteriormente en una RPi3), instala el nuevo y lo vuelve a guardar con BOM para que Windows PowerShell 5.1 lea bien los acentos. Asume que el fichero descargado está en `Downloads` y que `Scripts` existe de la versión anterior:
```powershell
$dst = "$env:USERPROFILE\Scripts\subir-sitio.ps1"
if (Test-Path $dst) { Copy-Item $dst "$dst.old" -Force }
Copy-Item "$env:USERPROFILE\Downloads\subir-sitio.ps1" $dst -Force
(Get-Content $dst -Raw -Encoding UTF8) | Set-Content $dst -Encoding UTF8
```

## 6. Actualizar el lanzador (subir-sitio.cmd)

Hay que cambiarlo para que acepte argumentos `(%*)` y poder usar `subir-sitio` y `subir-sitio -Eliminar`.

```powershell
Set-Content -Path "$env:USERPROFILE\Scripts\subir-sitio.cmd" -Encoding ASCII -Value @'
@echo off
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\subir-sitio.ps1" %*
if errorlevel 1 (
echo.
echo ERROR: La operacion ha fallado.
echo.
pause
exit /b 1
)
echo.
pause
'@
```

## 7. Añadir el script a la variable de entorno PATH

Para poder ejecutar el script `subir-sitio` desde cualquier lugar del sistema, hay que añadir la carpeta `Scripts` al PATH, se puede hacer en el PATH del sistema o en el del usuario, en este caso lo haremos en el PATH del usuario. Para ello, sigue estos pasos:

   1. En PowerShell ejecuta:
        ```powershell   
        [Environment]::SetEnvironmentVariable(
            "Path",
            [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Users\juanp\Scripts",
            "User"
            )
        ```
   2. Cierra la sesión de PowerShell y vuelve a abrirla para que los cambios surtan efecto.

       * En la nueva PowerShell: `$env:Path -split ";"`

       * Entre las entradas debería aparecer: `C:\Users\juanp\Scripts`

       * También puedes comprobar directamente: `$env:Path -like "*C:\Users\juanp\Scripts*"`

       * Debe devolver: `True`

   3. Uso del script

        Para usar el script, abre una terminal de Windows (PowerShell o CMD) y navega hasta la carpeta donde tienes tu sitio web estático. Luego ejecuta:

* ***subir-sitio*** para subir el sitio web al servidor y devolverá algo como esto:

```text
    ============================================
       SUBIDA DE SITIO WEB ESTÁTICO
    ============================================
    Proyecto : Plantilla_Proyecto
    Origen   : C:\Users\juanp\Proyectos\Plantilla_Proyecto\_site
    Destino  : https://webs.fpgh.link/Plantilla_Proyecto
    ¿Continuar con la subida? [S/N]: s

    [1/3] Empaquetando 285 archivos...
    Paquete de 6,24 MB

    [2/3] Subiendo al servidor...
    subir-sitio-Plantilla_Proyecto-20261011105949.tar   0%    0     subir-sitio-Plantilla_Proyecto-20261011105949.tar  16% 1056KB 96subir-sitio-Plantilla_Proyecto-20261011105949.tar  30% 1920KB 95subir-sitio-Plantilla_Proyecto-20261011105949.tar  44% 2848KB 95subir-sitio-Plantilla_Proyecto-20261011105949.tar  62% 4000KB 97subir-sitio-Plantilla_Proyecto-20261011105949.tar  80% 5120KB 98subir-sitio-Plantilla_Proyecto-20261011105949.tar  96% 6144KB 98subir-sitio-Plantilla_Proyecto-20261011105949.tar 100% 6395KB   1.0MB/s   00:06

    [3/3] Instalando en el servidor...
    Sitio 'Plantilla_Proyecto' publicado.

    ============================================
        SITIO PUBLICADO
    ============================================
    URL    : https://webs.fpgh.link/Plantilla_Proyecto/
    Tiempo : 9,5 s
```

* ***subir-sitio -Eliminar*** para eliminar el sitio web del servidor.

```text
    PS C:\Users\juanp\Proyectos\Plantilla_Proyecto> subir-sitio -Eliminar

    Se eliminará del servidor: Plantilla_Proyecto
    ¿Continuar? [S/N]: s
    Sitio 'Plantilla_Proyecto' eliminado.
```

## 8. Descargar los archivos

Los navegadores al detectar que son archivos de texto les asignan la extensión .txt, hay que quitársela.

{% iconCard 'deploy-site', 'sirve para desplegar un sitio web en el servidor <br> <a href="/files/scripts/server/deploy-site" download="deploy-site">Descargar deploy-site</a>', 'arrow-line-down' %}


{% iconCard 'webs-index', 'regenera el índice de sitios web <br> <a href="/files/scripts/server/webs-index" download="webs-index">Descargar webs-index</a>', 'arrow-line-down' %}


{% iconCard 'subir-sitio.ps1', 'script que permite subir el sitio a mi servidor <br> <a href="/files/scripts/windows/subir-sitio.ps1" download="subir-sitio.ps1">Descargar subir-sitio.ps1</a>', 'arrow-line-down' %}


{% iconCard 'subir-sitio.cmd', 'lanzador para ejecutar el script de subida de sitio <br> <a href="/files/scripts/windows/subir-sitio.cmd" download="subir-sitio.cmd">Descargar subir-sitio.cmd</a>', 'arrow-line-down' %}