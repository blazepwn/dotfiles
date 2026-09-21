# Correcciones aprobadas por etapas

Fecha: 2026-09-21. No se hicieron commit/push, instalación de paquetes, cambios
root, reboot, suspend ni cambios de modo GPU. Se recargó Hyprland para validar
los overrides aprobados. El firewall activo no se modificó.

## Alcance por hallazgo

| Hallazgo | Corrección |
|---|---|
| P01 | Restore permite el generado ausente; bootstrap Hyprland temporal separado, con guardas y secuencia real Ambxst → axctl → generación |
| P02 | `idle.listeners=[]` en repo y HOME; general/lockscreen conservados; hypridle 300/600/1800 intacto |
| P03 | README aclara actualización completa de kernel/firmware mediante pacman -Syu |
| P04 | Separación correcta entre nwg-look -a y -x |
| P05 | Unbinds explícitos en overrides; cero grupos duplicados cargados; solo tapa on/off propios |
| P06 | Cuatro resize con hl.dsp.window.resize relativo; generado intacto por parte del agente |
| P07 | PATH condicional y portable en el respaldo; no se reemplazó la Zsh viva ni se recargó el prompt |
| P08 | Archivo persistente nwg-look añadido y enumerado en el manifiesto |
| P09 | qt6ct incluido; ya estaba instalado |
| P10 | Telegram condicional en repo y HOME; no se instaló |
| P11 | visual-studio-code-bin y versión actual incorporados |
| P12 | Idiomas OCR desactivados separados como opcionales |
| P13 | sassc separado para reconstrucción; se conserva Murrine para GTK2 |
| P14 | Preflight común dentro del CLI de restore.py, sin bypass desde invocación directa |
| P15 | Rechazo de servicio hypridle enabled/activo y proceso ya corriendo al aplicar configs |
| P16 | Componentes manuales reanudables; verifica lo existente y publica solo checkouts completos |
| P17 | GNOME/TTY, bootstrap y comandos de la sesión Hyprland separados |
| P18 | Baseline UFW documentada; acción independiente, local y confirmada, sin volcado runtime |
| P19 | Manifiestos explícitos de archivos; no se recorren árboles al restaurar |
| P20 | Conclusiones iniciales de auditoría corregidas y distinguidas del histórico |
| P21 | Acciones lock/screen/suspend separadas del diagnóstico |
| P22 | README español, primera persona para estado/decisiones, imperativo para restore |

## Cambios en el sistema vivo

Solo se modificaron estos cuatro archivos, con backup previo en
`~/.local/state/dotfiles-backups/approved-stages-jd6og01n/`:

- `.config/ambxst/config/system.json`
- `.config/hypr/user/binds.lua`
- `.config/hypr/user/lid.lua`
- `.config/hypr/user/startup.lua`

No se editó `.local/share/ambxst/hyprland.lua`. Su hash se mantuvo idéntico
inmediatamente antes/después de los overrides. Ambxst puede regenerarlo después
por sus propios cambios de paleta/configuración.

## Límites que permanecen

- No se ejecutó la reinstalación gráfica completa en HOME vacío. El bootstrap
  sigue la implementación local, tiene guardas y sintaxis validada; falta esa prueba.
- No se cronometraron de nuevo 5/10/30 minutos ni se activaron los atajos para
  comprobar sus efectos. No hubo pruebas físicas de tapa ni suspend/resume nuevos.
- La disponibilidad del target IPC lockscreen no sustituye una prueba de bloquear
  y desbloquear. Se preservó su configuración y se dejó la prueba manual indicada.
- `sudo -n ufw status verbose` requirió contraseña. Se verificaron los archivos
  legibles, ausencia de aperturas en user.rules/user6.rules y servicio enabled/active;
  no se inspeccionó el ruleset efectivo del kernel con privilegios.
- El estado de GSettings, Iosevka ausente, excepciones dock/GNOME, paquetes NVIDIA
  residuales y monitor autodetectado se conservan y se documentan.
- `.zshrc` del repo sigue siendo una adaptación portable del archivo vivo, con
  carga única de P10k y PATH condicional. No se aplicó toda esa adaptación al HOME
  durante estas etapas para evitar cambiar el prompt fuera del alcance conductual.
- Los tres enlaces GTK4 son relativos en el repo y absolutos en HOME, con destinos
  equivalentes. Los CSS normalizan únicamente la línea vacía final respecto a
  la paleta viva tomada al cerrar la revisión.
- Las fuentes siguen en el árbol histórico de la máquina; el restore las coloca
  en el destino moderno. No se borraron las fuentes del HOME.

## Seguridad y restauración

Los manifiestos contienen 37 entradas de configuración y 117771 de assets.
La lista grande corresponde a iconos/assets ya presentes, no a archivos duplicados.
Las futuras altas exigen revisión explícita. Los paquetes normales son 144
oficiales y 8 AUR; otros 6 oficiales son opcionales. Todos estaban instalados.

Las pruebas del restaurador usan directorios temporales, nunca el HOME real.
El bootstrap, los instaladores manuales y el firewall se validaron sin ejecutar
sus acciones de instalación. La prueba real del primer arranque queda separada.

## Comprobación final de sesión

`check-session.py` pasó: cero grupos duplicados, solo switch:on/off de tapa,
lista idle de Ambxst vacía, un proceso hypridle y target IPC lockscreen disponible.
`hyprctl configerrors` quedó vacío. La invocación directa de `restore.py configs
--check` se detuvo por la sesión Hyprland activa antes de copiar.

Portales broker/Hyprland/GTK, PipeWire y WirePlumber activos; portal GNOME inactivo.
ASUS estático/activo, GDM y PPD habilitados/activos, RTKit disabled/activo.
UFW continúa enabled/active. GPU visible y renderer AMD Radeon 860M, Wi-Fi conectado.
Límite de carga 80 %, s2idle y nueve flags de curvas personalizadas en false.
El perfil al cierre fue `power-saver` y ACAD online=0 (batería); no se cambió.

Ambxst normalizó formato en varios JSON y añadió ocr.rus=false. Se copiaron esos
archivos tras comparar sus valores, sin inventar preferencias. La barra cambió
más de una vez durante el trabajo; el repo toma la última instantánea disponible.
La procedencia/hashes de esta fase están en [verified-state.json](verified-state.json).

Pasaron 13 pruebas de seguridad en temporales; sintaxis bash/sh/Zsh/Python/Lua/JSON,
y sintaxis de los bloques bash de la documentación. No hay una prueba nueva de
suspend, tapa, timeout completo, login limpio ni activación de firewall.

Pacman confirmó al cierre que las reglas before/after IPv4/IPv6, user.rules,
user6.rules, sysctl y /etc/default/ufw son los del paquete sin modificar.
El script de firewall rechaza reglas base/políticas modificadas antes de aplicar.
El escaneo de 334 archivos de texto nuevos/modificados no detectó secretos obvios;
es una revisión por patrones, no una garantía sobre todo el historial Git.
