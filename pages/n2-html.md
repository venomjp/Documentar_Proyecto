---
title: HTML en línea
description: Ejemplo de las etiquetas HTML disponibles.
layout: libdoc_page.liquid
permalink: /pages/n1-crear-contenido/n2-html/index.html
eleventyNavigation:
    key: HTML en línea
    parent: Crear contenido
    order: 2
tags:
    - html
    - abreviatura
    - cita en línea
    - entrada de teclado
    - salto de línea
    - enlaces internos
    - énfasis en texto
    - variables
date: 2026-03-27
---

Además del formato [Markdown](n2-markdown.md) habitual , es posible utilizar algunas etiquetas HTML sin formato.

# Abreviatura

Con <abbr title="Eleventy">11ty</abbr> puedes usar <abbr title="Cascading Style Sheets">CSS</abbr> para dar estilo a tu <abbr title="HyperText Markup Language">HTML</abbr>. El atributo `title` es opcional pero si se establece, las etiquetas `<abbr>` son clicables y se expanden una vez hacen clic.

<aside>
    <p class="alert alert-success">
        En Eleventy LibDoc, los elementos de abreviatura con atributo de título son clicables como este: <abbr title="Exempli Gratia">E.G.</abbr>
    </p>
</aside>

``` markdown
<abbr title="Eleventy">11ty</abbr>
```

# Cita en línea (para citar fuentes)

Y entonces Albus dijo a Harry <q cite="https://www.harrypotter.com/fr/features/pearls-of-wisdom-from-professor-dumbledore"> 
    Son nuestras decisiones, Harry, las que muestran quiénes somos realmente, mucho más que nuestras habilidades.
</q>.

``` html
Y entonces Albus dijo a Harry <q cite="https://www.harrypotter.com/fr/features/pearls-of-wisdom-from-professor-dumbledore"> 
    Son nuestras decisiones, Harry, las que muestran quiénes somos realmente, mucho más que nuestras habilidades.
</q>.
```
Este tipo de citas se utiliza para marcar una referencia, título de una obra (libro, película, web...) y no la cita en sí misma. Se muestra el contenido de la cita entre comillas y en cursiva. El atributo `cite` se utiliza para proporcionar la URL de la fuente de la cita (aunque no se puede acceder a ella ni es un enlace).

Este tipo de cita es diferente a la cita en bloque, sobre todo en el tamaño del texto, que es más pequeño. La cita en bloque se utiliza para citas más largas y se muestra en un bloque grande separado del texto principal.

Lo puedo utilizar sin incluir una url en el atributo `cite` <q cite=""> y que me sirva como una cita en línea normal</q>.

``` markdown
Lo puedo utilizar sin incluir una url en el atributo `cite` <q cite="">
y que me sirva como una cita en línea normal</q>.
```

# Entrada de teclado

Puedes usar <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> para actualizar la página y vaciar la caché.

``` html
Puedes usar <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> para actualizar la página y vaciar la caché.
```

# Salto de línea

* Soy un punto importante.<br>
    A veces necesitamos romper la línea dentro del markdown.
* Soy otro punto importante.
Aquí no se ha roto la línea.

``` markdown
* Soy un punto importante.<br>
    A veces necesitamos romper la línea dentro del markdown.
* Soy otro punto importante.
Aquí no se ha roto la línea aunque lo he escrito en otra línea.
```

# Enlaces internos
* **Estáticos** (una página interna) 
* **Dinámicos** (permalink).

# Énfasis en texto

Hay cosas que Markdown no puede hacer, como el resaltado de texto en amarillo, texto de salida, texto de tamaño reducido, tachado, subíndices (**H**<sub>2</sub>**O**<sub>2</sub>) y superíndices (**E**=**mc**<sup>2</sup>). Para eso tenemos el HTML.

[Modificadores de texto](./n3-enfasisTextoHtml.md)

# Variables
