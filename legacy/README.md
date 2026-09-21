# Archivos históricos que no se restauran

- `take_edit_copy.sh`: script de captura revisado, ausente del HOME actual.
  Conserva su comportamiento y firma gráfica histórica; usa grim, slurp,
  wl-clipboard y opcionalmente ImageMagick. Ambxst gestiona las capturas actuales.
- `.p10k.zsh.root`: configuración histórica de root. No representa el usuario
  actual y no se copia a `/root`.

Se retiraron del árbol activo `hyprland.conf` y los diez módulos `conf/*.conf`
después de comparar con el sistema Lua. Incluían NVIDIA, rutas de otro usuario,
un monitor HDMI que no está conectado, arranque duplicado de Ambxst, temas
obsoletos y llamadas a eww ausente. No se convirtieron ni mezclaron con Lua.

La versión completa anterior sigue en el historial, referencia de auditoría
`80d0a91`. Consultarla sin restaurarla al HOME:

```bash
git show 80d0a91:.config/hypr/hyprland.conf
git show 80d0a91:.config/hypr/conf/binds.conf
```
