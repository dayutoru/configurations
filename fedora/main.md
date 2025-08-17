
# 1. Pre-configuration

1. Eliminar programas innecesarios
1. Eliminar paquetes de idiomas prescindibles
1. Update

<br>
<br>

# 2. [Bloquear SSH y otros puertos / servicios](./ssh.md)

<br>
<br>

# 3. [`SELinux` y parches automáticos](./selinux.md)

<br>
<br>

# 4. Deshabilitar Bluetooth
``` bash
sudo systemctl disable --now bluetooth
sudo systemctl mask bluetooth
```

Añadir al archivo `/etc/bluetooth/main.conf` la siguiente línea: `AutoEnable=false`

<br>
<br>

# 5. Cuentas, sudo y bloqueo adicional

- [**Bloquear la cuenta root y endurecer sudo**](./users.md)

- **Políticas de contraseña y bloqueo por intentos (PAM/FAIllock):**
  ```bash
  sudo authselect enable-feature with-faillock
  sudo authselect apply-changes
  # Configura /etc/security/faillock.conf, p.ej.:
  # deny=5 unlock_time=600 even_deny_root
  ```
- **2FA (opcional):**
  Habilita pam_u2f o Google Authenticator para sudo/inicio de sesión si quieres un nivel extra.

<br>
<br>


# 6. Servicios, auditoría y comprobaciones

- **Auditoría y control de integridad:**

  Cuando instalas esos dos paquetes en una distro basada en DNF (como Fedora, CentOS o RHEL), en realidad estás añadiendo dos herramientas de seguridad complementarias:

  - audit: Es el subsistema de auditoría de Linux. Permite registrar eventos detallados del sistema: accesos a archivos, ejecuciones de comandos, cambios de configuración, etc. Sirve para cumplir normativas o investigar incidentes de seguridad, porque puedes saber quién hizo qué y cuándo. Funciona junto con el demonio auditd y las reglas que definas (auditctl).

  - aide (Advanced Intrusion Detection Environment): Es una herramienta de detección de cambios en archivos. Escanea el sistema y genera una base de datos con hashes, permisos, tamaños y fechas. En verificaciones posteriores, compara el estado actual con la base guardada y avisa si algo cambió sin autorización. Muy útil para descubrir modificaciones maliciosas o corrupción de archivos importantes.

  Resumen:
  - audit = Caja negra que registra eventos del sistema.
  - aide = Alarma que salta si cambian cosas donde no deberían.

  ```bash
  sudo dnf install -y audit aide
  sudo systemctl enable --now auditd
  sudo systemctl status auditd
  sudo aide --init
  sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
  ```
  [Guía completa aquí](./audit.md)

- **Revisión periódica de puertos y procesos:**
  ```bash
  # revisión de puertos
  sudo ss -tulpen

  # revisión de servicios en ejecución
  systemctl --type=service --state=running

  # mensajes de error recogidos
  sudo journalctl -p 3 -xb
  ```

<br>
<br>

# 7. [Proteger los puertos USB](./usb.md)

<br>
<br>

# 8. Desconectar Wi-Fi

Aislar el adaptador de red cuando no se necesite. Con `nmcli` puedes bajar la interfaz sin apagar el equipo:

```bash
nmcli device disconnect eth0
```