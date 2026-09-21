# Firewall

## Estado comprobado

Tengo UFW instalado y `ufw.service` habilitado y activo. En los archivos vivos:

| Ajuste | Valor |
|---|---|
| `/etc/ufw/ufw.conf` | `ENABLED=yes`, `LOGLEVEL=low` |
| IPv6 | `yes` |
| INPUT / OUTPUT / FORWARD | `DROP` / `ACCEPT` / `DROP` |
| Política para aplicaciones | `SKIP` |
| `MANAGE_BUILTINS` | `no` |

`user.rules` y `user6.rules` no contienen aperturas de puertos ni reglas de
usuario. Las cadenas auxiliares IPv4 para rate limiting vienen del formato de
UFW; no son una excepción de entrada que tenga que recrear.

`pacman -Qii ufw` confirmó que before/after, sus variantes IPv6, sysctl,
user.rules/user6.rules y `/etc/default/ufw` están sin modificar respecto al paquete.
De esos archivos de backup, solo `ufw.conf` aparece modificado.

La auditoría pudo leer estos archivos y consultar systemd. `sudo -n ufw status
verbose` requirió contraseña: no doy por inspeccionado el ruleset efectivo del
kernel. Compruébalo localmente con:

```bash
sudo ufw status verbose
sudo ufw show added
systemctl is-enabled ufw.service
systemctl is-active ufw.service
```

## Restauración

La baseline confirmada es deny incoming, allow outgoing, deny routed y logging
low. No copio `iptables-save`, `nft list ruleset`, contadores, cadenas runtime,
reglas temporales de VPN/Docker ni archivos generados de UFW al repo.
`before.rules`, `after.rules` y sus variantes IPv6 los proporciona el paquete;
no los sustituyo con un volcado de esta máquina.

Instalar el paquete o ejecutar `install.sh services` NO activa UFW. Desde una
TTY local, después de configurar la red y antes de dar la reinstalación por
terminada, ejecuta:

```bash
./scripts/firewall.sh
./scripts/firewall.sh --apply
```

El script rechaza SSH y terminales que no sean una TTY local. Muestra el estado,
se detiene si encuentra reglas de usuario y conserva un firewall ya habilitado.
También rechaza modificaciones de las reglas base/políticas del paquete.
En un destino nuevo respalda `/etc/ufw` y `/etc/default/ufw`, aplica las políticas,
ejecuta `ufw enable` y habilita el servicio. **El filtrado comienza con `ufw enable`,
sin esperar al reboot.** No uso `ufw reset` ni `--force`.

Si se interrumpe después de habilitar UFW pero antes del último paso, comprueba
el estado y ejecuta `sudo systemctl enable ufw.service` manualmente si falta.
Si ya hay reglas propias o cambios en before/after, revísalos antes; este flujo
está pensado para la baseline de una instalación limpia, no para reemplazarlos.

## Próximas herramientas

Docker, Exegol, máquinas virtuales y VPN pueden añadir forwarding o reglas
independientes. No invento esas reglas ahora. Cuando configure esa capa, revisaré
las interfaces, servicios expuestos y el efecto real de Docker sobre el filtrado.
