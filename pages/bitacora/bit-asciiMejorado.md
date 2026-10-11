---
title: Texto ASCII Art mejorado
description: Como hacer esquemas sin depender de generadores automáticos.
layout: libdoc_page.liquid
permalink: "{{ libdocConfig.blogSlug }}/{{title | slugify}}/index.html"
tags:
    - post
    - ASCII
    - páginas estáticas
date: 2026-10-11
---

# Esquemas ASCII Art mejorado
Para hacer esquemas con Bloque de texto estructurado (estilo ASCII Art mejorado) y escribir tú mismo este tipo de esquemas directamente desde tu teclado sin depender de generadores automáticos, el secreto está en utilizar los caracteres de dibujo de caja (Box-drawing characters).
Si intentas usar los guiones medios (-) o barras normales (|), el diseño suele verse torcido o informal. En su lugar, los desarrolladores usamos este set de caracteres especiales.
Aquí tienes la "paleta" de caracteres que necesitas copiar y pegar para armar tus ramas:

## 📋 Los 4 caracteres esenciales

• │ (Barra vertical continua)

• ─ (Línea horizontal recta)

• ├─── (Conector en forma de 'T' para elementos intermedios)

• └─── (Conector en forma de 'L' para el último elemento de una lista)

## 🛠️ Guía paso a paso

Para que no te vuelvas loco con los espacios y las alineaciones, el truco está en escribir de arriba hacia abajo siguiendo esta lógica:

**Paso 1: El nodo raíz**

Escribe tu punto de partida.
```text
🌐 Dominio: fpgh.link
```

**Paso 2: Crear una bajada secuencial**

Si el siguiente paso es único (secuencial), tiras una línea vertical justo debajo de la primera letra del texto anterior, y en la siguiente línea abres con una esquina en 'L' (└───):
```
🌐 Dominio: fpgh.link
   │
   └───☁️ Cloudflare DNS
```

**Paso 3: Ramificar varios servicios (Estructura en 'T')**

Cuando llegues a un punto donde se abren varias opciones (como tus servicios internos), los elementos de arriba y del medio llevan el conector en 'T' (├───), y solo el último de todos lleva la esquina en 'L' (└───) para cerrar la rama:

```
🛠️ Servicios internos
     │
     ├───📁 Nextcloud   <-- Conector T (hay más abajo)
     ├───📸 Immich      <-- Conector T (hay más abajo)
     └───🎵 Navidrome   <-- Conector L (es el último)
```
## ⌨️ Trucos para escribirlo rápido

1. Usa siempre un bloque de código: En Markdown, encierra siempre tu esquema entre tres comillas invertidas y la palabra text (text ... ). Esto le dice a GitHub que use una fuente monoespaciada (donde una "W" ocupa exactamente el mismo espacio que una "I" o un espacio en blanco), evitando que el dibujo se desarme.
2. Copia y pega la plantilla: Guarda estos tres bloques en un bloc de notas y úsalos como si fueran tus pinceles: │ , ├─── , └───.
3. El truco del tabulador: Si usas un editor como VS Code o el propio editor de GitHub, selecciona varias líneas a la vez y pulsa Tab para mover bloques enteros de ramas hacia la derecha sin perder la alineación.

## 🖌️ Emojis

1. 🌐 Redes y Conectividad
Puedes escribir el código corto directamente, sin embargo, dentro de un bloque ```text``` no se renderizarán los emojis.

    ```text
    • 🌐 :globe_with_meridians: -> Dominio / Internet / Web pública
    • ☁️ :cloud: -> Cloudflare / Cloud / DNS
    • 🔒 :lock: -> VPN / Tailscale / Seguridad / HTTPS
    • 🔀 :twisted_right_arrows: -> Caddy / Reverse Proxy / Balanceador
    • 🛡️ :shield: -> Firewall / Autenticación
    • 📡 :satellite: -> Puertos / IP Pública / Conexión remota
    ```


2. 🛠️ Infraestructura y Servidores

    ```text
    • 🛠️ :hammer_and_wrench: -> Servicios / Configuración
    • 📦 :package: -> Docker / Contenedores
    • 🐳 :whale: -> Docker (Alternativo visual)
    • 🖥️ :desktop_computer: -> Servidor Físico / Host / PC
    • 🗄️ :file_cabinet: -> Servidor NAS / Almacenamiento local
    • 💾 :floppy_disk: -> Copias de seguridad / Backups
    ```

3. 📁 Servicios Internos Populares (Self-Hosted)

    ```text
    • 📁 :file_folder: -> Nextcloud / Owncloud / Archivos
    • 📸 :camera_with_flash: -> Immich / Photoprism / Fotos
    • 🎵 :musical_note: -> Navidrome / Jellyfin Audio / Música
    • 🎬 :clapper: -> Plex / Jellyfin / Vídeo
    • 🏠 :house: -> Home Assistant / Domótica
    • 📝 :memo: -> Notas / Wiki / Vaultwarden (Contraseñas)
    • 📊 :chart_with_upwards_trend: -> Grafana / Monitorización / Netdata
    ```
