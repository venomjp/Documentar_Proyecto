---
title: Configuraciones
description: Pasos previos para que funcione cualquier proyecto.
layout: libdoc_page.liquid
permalink: /pages/n1-configuracion/index.html
eleventyNavigation:
    key: Configuraciones
    order: 2
tags:
    - configuración
date: 2026-03-24
---

# Archivos de configuración

* `package.json` - archivo de **configuración de NodeJS** con los scripts para generar la documentación.
  * **Nombre del proyecto** - debe coincidir con el nombre del repositorio en GitHub.
  * **Versión** -  para indicar la versión inicial del proyecto.
  * **Descripción** - para proporcionar una breve descripción del proyecto, es como un subtítulo.
  * **main**: ***"index.js"*** aunque no se utiliza un archivo index.js en este proyecto, es necesario mantener esta propiedad para que NodeJS no genere errores al ejecutar los scripts.
  * **Licencia** - **CC BY-NC-SA 4.0** para que coincida con la licencia del proyecto.
  * Scripts:
    * `start` para iniciar el servidor local y comprobar que se visualiza la documentación en localhost.
    * `build-ghpages` para generar la carpeta de salida con el pathPrefix correcto para GitHub Pages.
    * `clean` para limpiar la carpeta de salida antes de generar la documentación.
* `settings.json` - este archivo contiene la configuración del home y general del sitio web, sobreescribe los valores por defecto de LibDoc.
  * **Título del sitio web** - para darle un título personalizado al sitio web.
  * **Descripción del sitio web** - para proporcionar una breve descripción del sitio web, es como un subtítulo.
  * **Autor** - para mostrar el nombre del autor en las entradas del blog (bitácora).
  * **Ubicación del favicon** - para mostrar un favicon personalizado en la pestaña del navegador.
  * **Título del blog** - para darle un título personalizado a la sección del blog, que en este caso es el cuaderno de bitácora donde se registran los cambios realizados en el proyecto.
  * **Descripción del blog** - para proporcionar una breve descripción de la sección del blog (bitácora).
  * **customLinks** para agregar enlaces personalizados en la barra de navegación, como el enlace a mi perfil de GitHub.
  * **Lenguaje** - para establecer el idioma del sitio web, en este caso español ("es").
  * **htmlBasePathPrefix** para que los enlaces a los archivos y recursos funcionen correctamente en GitHub Pages, ya que el sitio web se alojará en una subcarpeta con el nombre del repositorio.
  * **hljsLanguages** para incluir lenguajes de programación relevantes para el tipo de documentación que estoy creando, como arduino, python, c y gcode.
  * **tocEnabled** para mostrar una tabla de contenidos en cada página de la documentación (en el blog no aparecía).
* `README.md` - archivo de presentación del proyecto con información general y enlaces a la documentación.
* `myfavicon.png` - archivo de imagen para el favicon del sitio web. Recomendado usar una imagen PNG de 512x512 pixeles. [./assets/myfavicon.png]

# Niveles de Páginas
* `n1-nombreN1.md` - Este es el formato de las páginas de nivel 1, secciones principales.
* `n2-nombreN2.md` - Este es el formato de las páginas de nivel 2, subsecciones dentro de las secciones principales.
* `n3-nombreN3.md` - Este es el formato de las páginas de nivel 3, subsecciones dentro de las subsecciones de nivel 2.

# Entradas del cuaderno de Bitácora
* `bit-nombreEntrada.md` - Este es el formato de las entradas de la bitácora, con información sobre los cambios realizados en el proyecto, problemas encontrados, soluciones implementadas, etc. 