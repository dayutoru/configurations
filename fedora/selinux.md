`SELinux` (Security-Enhanced Linux) es un sistema de seguridad integrado en el kernel de Linux que añade una capa extra de control sobre quién y qué puede acceder a los recursos del sistema. A diferencia de los permisos tradicionales de Linux (DAC, Discretionary Access Control), que dependen de propietarios y grupos, `SELinux` aplica Control de Acceso Obligatorio (MAC):

- Las reglas no las decide el usuario o el propietario del archivo, sino políticas globales definidas por el administrador.

- Cada archivo, proceso, puerto o recurso tiene una etiqueta de seguridad (por ejemplo: `user_u:role_r:type_t:s0`).

- Cuando un proceso intenta acceder a un recurso, `SELinux` comprueba si la política lo permite. Si no, lo bloquea y registra el evento.

Modos de funcionamiento:
- `Enforcing` (código 1): aplica las políticas, bloquea accesos no permitidos y los registra.
- `Permissive` (código 0): no bloquea, pero registra lo que habría bloqueado (útil para pruebas).
- `Disabled`: desactivado (muy desaconsejable).

## Asegurar SELinux en enforcing:
```bash
# mostrar el modo actual
getenforce
# establecer el modo Enforcing
sudo setenforce 1
# establecer Enforcing por defecto cuando se arranque el sistema. Busca la línea donde pone SELINUX y la sustituye por SELINUX=enforcing
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
# en algunas distros se encuentra en una ruta distinta:
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/sysconfig/selinux
```

Para revisar los logs de `SELinux` y ver el registro de bloqueos:

1. Ver el archivo `/var/log/audit/audit.log`
2. `journalctl -t setroubleshoot`


## Actualizaciones de seguridad automáticas:
Con los siguientes cambios vamos a hacer que de manera periódica revise si hay actualizaciones de seguridad y que en caso de haberlas las instale y aplique sus cambios.

- DNF clásico, automatizaciones de seguridad automáticas:

  ```bash
  sudo dnf install -y dnf-automatic
  sudo sed -i 's/^apply_updates.*/apply_updates = yes/' /etc/dnf/automatic.conf
  cat /etc/dnf/automatic.conf
  sudo systemctl enable --now dnf-automatic.timer
  ```
- **DNF5 (si tu Fedora lo usa):**
  ```bash
  dnf5 --version
  sudo dnf5 install -y dnf5-automatic
  # en caso de no haberlo lanzado antes
  sudo sed -i 's/^apply_updates.*/apply_updates = yes/' /etc/dnf/automatic.conf
  cat /etc/dnf/automatic.conf
  sudo systemctl enable --now dnf5-automatic.timer
  ```