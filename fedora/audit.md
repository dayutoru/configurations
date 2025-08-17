## Prerequisites and install

- **Scope:** Fedora, RHEL, CentOS, Rocky/Alma (DNF).
- **Install:**
  ```bash
  sudo dnf install -y audit aide
  ```
- **Enable audit daemon:**
  ```bash
  sudo systemctl enable --now auditd
  sudo systemctl status auditd
  ```

---

## Configure audit (auditd) — reglas útiles y seguras

Crea un archivo de reglas persistentes. Estas cubren cambios críticos de sistema, módulos del kernel y ejecuciones sensibles sin generar ruido excesivo.

- **Crear reglas base:**
  ```bash
  sudo tee /etc/audit/rules.d/hardening.rules >/dev/null <<'EOF'
  ## 1) Cambios en cuentas y configuración sensible
  -w /etc/passwd   -p wa -k etc_accounts
  -w /etc/shadow   -p wa -k etc_accounts
  -w /etc/group    -p wa -k etc_accounts
  -w /etc/gshadow  -p wa -k etc_accounts
  -w /etc/sudoers      -p wa -k sudo_config
  -w /etc/sudoers.d/   -p wa -k sudo_config
  -w /etc/ssh/sshd_config -p wa -k ssh_config

  ## 2) Carga/descarga de módulos del kernel
  -w /sbin/insmod  -p x  -k modules
  -w /sbin/rmmod   -p x  -k modules
  -w /sbin/modprobe -p x -k modules
  -a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules
  -a always,exit -F arch=b32 -S init_module,delete_module -k modules

  ## 3) Cambios de hora del sistema
  -a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k timechange
  -a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k timechange
  -w /etc/localtime -p wa -k timechange

  ## 4) Ejecuciones especialmente sensibles
  -w /usr/bin/sudo    -p x -k priv_esc
  -w /usr/bin/passwd  -p x -k priv_esc
  -w /usr/bin/chsh    -p x -k priv_esc
  -w /usr/bin/chfn    -p x -k priv_esc

  ## 5) Intentos de acceso a archivos inexistentes (detección de sondeos)
  -a always,exit -F arch=b64 -S open,openat,creat -F a0&0100000 -F exit=-2 -k missing
  -a always,exit -F arch=b32 -S open,openat,creat -F a0&0100000 -F exit=-2 -k missing
  EOF
  ```

- **Aplicar reglas sin reiniciar:**
  ```bash
  sudo augenrules --load
  # Ver lo cargado
  sudo auditctl -l
  ```

- **Opcional (endurecimiento):** bloquear cambios de reglas hasta reinicio (útil en producción; evita que un atacante las quite).
  ```bash
  echo "-e 2" | sudo tee /etc/audit/rules.d/immutable.rules >/dev/null
  sudo augenrules --load
  ```

- **Ajustes del demonio (rotación y tamaño):** revisa `/etc/audit/auditd.conf` (parámetros como `max_log_file`, `max_log_file_action`, `space_left_action`) para prevenir quedarte sin disco.

---

## Review audit events — cómo consultar y entender

- **Buscar por etiqueta de regla (key):**
  ```bash
  # Hoy, cambios en cuentas
  sudo ausearch -k etc_accounts -ts today
  # Cambios de hora esta semana
  sudo ausearch -k timechange -ts this-week
  ```
- **Por usuario, PID, syscall o resultado:**
  ```bash
  # Acciones del usuario 'pepito'
  sudo ausearch -ua pepito -ts today
  # Fallos (denegados)
  sudo ausearch -m AVC,USER_AVC -ts today
  ```
- **Informes de alto nivel (rápidos):**
  ```bash
  # Resumen general desde el último arranque
  sudo aureport --summary
  # Autenticación y sudo
  sudo aureport -au
  # Ejecuciones de binarios
  sudo aureport -x
  # Cambios en archivos vigilados
  sudo aureport -f
  ```
- **Ver servicio y fallos del demonio:**
  ```bash
  sudo journalctl -u auditd -b
  ```

> Tip: acostúmbrate a usar claves (`-k`) en tus reglas; te permiten filtrar con precisión con `ausearch -k`.

---

## Configure AIDE — baseline fiable

- **Revisar/ajustar política:** abre `/etc/aide.conf`. Las reglas por defecto son sensatas; añade rutas críticas si lo necesitas.
  - **Ejemplo de regla adicional:**
    ```
    /etc   NORMAL
    /boot  NORMAL
    /usr/sbin/sshd  NORMAL
    ```
- **Inicializar base de datos (baseline):**
  ```bash
  sudo aide --init
  # Mueve el baseline generado a la ubicación activa
  sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
  ```
- **Guardar baseline a prueba de manipulaciones:** si puedes, copia `/var/lib/aide/aide.db.gz` a un medio externo o montado como solo-lectura.

---

## Review AIDE checks — comprobar y gestionar cambios

- **Ejecutar verificación:**
  ```bash
  sudo aide --check
  ```
  - **Interpretación rápida:** verás secciones “Added files”, “Removed files”, “Changed files”. Cada archivo detalla qué atributo cambió (hash, permisos, tamaño, mtime, etc.).

- **Cambios esperados (tras actualizaciones):** valida que los cambios son legítimos y luego actualiza la base:
  ```bash
  sudo aide --update
  sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
  ```
- **Reducir ruido:** si hay rutas que cambian a menudo y no te importan, ajústalas en `/etc/aide.conf` con una regla más laxa o exclúyelas.

---

## Automatización y mantenimiento

- **Programar AIDE periódicamente:**
  - **Si existe timer de systemd:**
    ```bash
    systemctl list-timers | grep aidecheck || true
    sudo systemctl enable --now aidecheck.timer
    ```
  - **Si no existe, crea servicio y timer:**
    ```bash
    sudo tee /etc/systemd/system/aidecheck.service >/dev/null <<'EOF'
    [Unit]
    Description=AIDE integrity check

    [Service]
    Type=oneshot
    ExecStart=/usr/sbin/aide --check
    EOF

    sudo tee /etc/systemd/system/aidecheck.timer >/dev/null <<'EOF'
    [Unit]
    Description=Run AIDE check daily

    [Timer]
    OnCalendar=daily
    Persistent=true

    [Install]
    WantedBy=timers.target
    EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now aidecheck.timer
    ```
  - **Opcional (alertas por correo):** canaliza la salida a `mail` para recibir reportes si hay cambios.

- **Rotación y espacio (auditd):** verifica que `/var/log/audit/` rote adecuadamente (logrotate suele encargarse). Ajusta `max_log_file` y acciones de espacio bajo para no parar servicios.

- **Ritual operativo:**
  - **Después de parches/updates:** ejecuta `aide --check`, valida y luego `aide --update`.
  - **Semanalmente:** `aureport --summary` y una pasada por `ausearch -k` de tus claves importantes.
  - **Trimestralmente:** revisa tus reglas de audit y la política de AIDE según lo que realmente te aportó valor.

¿Tienes algún objetivo concreto (por ejemplo, vigilar un directorio de aplicaciones o cumplir una normativa específica)? Con eso te afino las reglas y la política para tu caso.