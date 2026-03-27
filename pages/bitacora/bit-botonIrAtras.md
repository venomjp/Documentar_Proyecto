---
title: Boton Ir Atrás
description: Cambios realizados en el proyecto para incorporar un botón de "ir atrás" en el pie de página de las páginas de documentación.
layout: libdoc_page.liquid
permalink: "{{ libdocConfig.blogSlug }}/{{title | slugify}}/index.html"
tags:
    - post
    - modificaciones
    - botón
    - atrás
date: 2026-03-27
---
# libdocMessajes.json
Para que el botón de "ir atrás" tenga un texto personalizado, añadí el mensaje "Ir atrás" al archivo **libdocMessages.json** bajo la clave **goBack**. Esto permite que el botón muestre el texto correcto en cualquiera de los idiomas soportados.

```json
"goBack": {
	"en": "Go back",
	"fr": "Retour",
	"it": "Indietro",
	"es": "Ir atrás"
}
```

# libdoc_page.liquid
En la plantilla **libdoc_page.liquid**, añadí un nuevo bloque de código HTML para el botón de "ir atrás" dentro del pie de página (Footer), en la parte derecha donde el LibDoc original muestra la versión. Este bloque utiliza el mensaje definido en **libdocMessages.json** para mostrar el texto del botón.

Tiene en cuenta la estructura de ficheros que he decidido utilizar:
* Plantillas de cualquier nivel en el directorio de salida `_site/pages`
* Publicaciones del blog en el directorio de salida `_site/posts`
* La página de inicio (HOME) en el directorio de salida `_site/`

Funciona en los 3 niveles de anidamiento de las páginas y en el blog (bitácora) y su índice.

{% alertAlt 'info','Imporante' %}
No generar más niveles de anidamiento para las páginas.
{% endalertAlt %}

Funciona independientemente del nombre del proyecto, lo que facilita no tener que modificar el código en los archivos de configuración.

El bloque de código para el botón de "ir atrás" es el siguiente:

``` html
<a id="backBtn" class="btn btn-primary-light">
    <span class="icon-arrow-square-out"></span>
    {{ libdocMessages.goBack[libdocConfig.lang] }}
</a>                    
<script>
document.addEventListener("DOMContentLoaded", function() {
    const backBtn = document.getElementById("backBtn");

    let path = window.location.pathname;

    // Normalizar quitando / final (excepto si es solo "/")
    if (path.length > 1 && path.endsWith("/")) {
        path = path.slice(0, -1);
    }

    const segments = path.split("/").filter(Boolean);

    // Seguridad básica
    if (segments.length === 0) {
        disableBtn();
        return;
    }

    // Base automática: /NombreProyecto
    const base = "/" + segments[0];
    const pagesRoot = base + "/pages";
    const postsRoot = base + "/posts";

    // ========== HOME ==========
    if (path === base) {
        disableBtn();
        return;
    }

    // ========== PÁGINAS /pages/ ==========
    if (path.startsWith(pagesRoot)) {
        const depth = segments.length - 2; // quitamos [proyecto, pages]

        if (depth === 1) {
            // /Proyecto/pages/nivel1 -> home
            backBtn.href = base + "/";
        } else {
            // /Proyecto/pages/n1/n2 -> /Proyecto/pages/n1/
            const parent = path.split("/").slice(0, -1).join("/") + "/";
            backBtn.href = parent;
        }
        return;
    }

    // ========== BLOG /posts/ ==========
    if (path.startsWith(postsRoot)) {
        const depth = segments.length - 2; // quitamos [proyecto, posts]

        if (depth === 1) {
            // /Proyecto/posts/post-slug -> /Proyecto/posts/
            backBtn.href = postsRoot + "/";
        } else if (depth === 0) {
            // /Proyecto/posts -> home
            backBtn.href = base + "/";
        } else {
            // Por si en el futuro hubiera más profundidad dentro de posts
            const parent = path.split("/").slice(0, -1).join("/") + "/";
            backBtn.href = parent;
        }
        return;
    }

    // ========== CUALQUIER OTRA RUTA ==========
    disableBtn();
    function disableBtn() {
        backBtn.classList.add("disabled");
        backBtn.style.pointerEvents = "none";
        backBtn.style.opacity = "0.20";
        backBtn.style.cursor = "default";
        backBtn.style.filter = "grayscale(100%)";
        backBtn.removeAttribute("href");
    }
});
</script>
```