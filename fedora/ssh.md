
**Se puede hacer de dos maneras**: con **`firewalld`** o directamente con **`nftables`**. **No se han de usar ambas a la vez porque se generarían conflictos.**. Diferencias clave:
- Con `firewalld` es más granular y mantenible desde la CLI de firewall-cmd.
- Con el archivo de `nftables` es más directo y minimalista y bloquea casi todo salvo lo explícitamente permitido.

**Aquí se expondrá la primera, se expondrá cómo configurar `firewalld`**

## Eliminamos servicios:

Usamos el bash [clean-services.sh](./clean-services.sh).

> Algunos de los servicios que eliminamos:
>
> - `avahi-daemon` Implementación Linux de mDNS/DNS‑SD (descubrimiento automático de servicios en red local).
>
> - `cups` Sistema de impresión en red/local para Linux y macOS. Si no imprimes, sobra.
>
> - `libvirtd` Demonio de virtualización (KVM/QEMU, Xen). Solo necesario si usas máquinas virtuales locales.
>
> - `cockpit.socket` Socket que activa Cockpit, interfaz web de administración en el puerto 9090. Si no gestionas el PC por web, puedes bloquearlo.

## Configuración `firewalld`

> **Bloqueamos todos los puertos posibles. Hacemos que se rechace cualquier intento de conexión externa desde el puerto 22 y otros puertos de riesgo**

Antes de hacerlo podemos asegurarnos si usamos `IPv4` o `IPv6` para bloquear el otro. Aunque tampoco es recomendable quitar `IPv6` porque muchas redes las usan y bien configurado no es peligroso:

``` bash
# el que reciba respuesta está en uso
sudo dhclient -v -4
sudo dhclient -v -6
```


Usamos el bash [firewalld-conf.sh](./firewalld-conf.sh).

Pasos a seguir:

``` bash
sudo firewall-cmd --permanent --set-default-zone=public
sudo chmod +x ./firewalld-conf.sh
sudo ./firewalld-conf.sh
sudo firewall-cmd --reload

# mostrar cambios realizados
sudo firewall-cmd --zone=public --list-all
```

> `Cockpit` es una interfaz web de administración de sistemas Linux. Permite gestionar el servidor o PC desde un navegador, en el puerto 9090/TCP
>
> `mdns` (Multicast DNS) Es un sistema para que los dispositivos de una red local se descubran entre sí sin un servidor DNS central. Esto genera tráfico extra y expone nombres/servicios en la red local.
>
> `samba` Software libre que implementa el protocolo SMB/CIFS de Windows. Sirve para compartir carpetas, impresoras y autenticación entre Linux, Windows y macOS.


## Comprobar puertos abiertos

Comprobamos que se ha configurado el bloqueo correctamente / eliminamos cualquier brecha que pudiera quedar. Revisar periódicamente / tras instalar algún programa.

``` bash
sudo ss -tulpen   # o con sudo lsof -i -P -n
sudo firewall-cmd --list-all

# Como estábamos haciendo antes, si hubiera algún puerto activo indeseado:
sudo systemctl disable --now nombre_del_servicio
```

## Probar que los puertos están cerrados

``` bash
ss -ltnp | grep ':22'
# (sin salida = nadie escucha en 22)

systemctl status sshd
# debería aparecer “not found” o desactivado/ausente

# probando desde otra máquina
nmap -p 22 TU_IP
# “closed” = no hay servicio; “filtered” = firewall lo filtra; “open” = cuidado
```