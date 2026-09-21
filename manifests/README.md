# Archivos que restaura el repo

`configs.txt` y `assets.txt` enumeran archivos/enlaces concretos revisados.
El restaurador NO descubre nuevos archivos mediante un recorrido de directorios.
Un archivo añadido al checkout no se restaura hasta que se revise y se añada
explícitamente a la lista correspondiente. Gitignore no sustituye esa revisión.

La ruta de origen es relativa al repo. El destino es la misma ruta bajo `$HOME`,
salvo `.fonts/*`, que se copia a `~/.local/share/fonts/dotfiles/*`.
No incluyas caches, credenciales, histories, sockets ni bases de clipboard.
Los scripts rechazan escapes de ruta y enlaces de origen que salen del repo.

La lista de assets es grande porque el repo ya contiene el árbol completo de
iconos Kora. Enumerarlo evita que una carpeta futura se copie implícitamente.
No se ha duplicado el árbol de iconos ni comprimido en un segundo archivo.
