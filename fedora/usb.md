Bloquear la ejecución accidental de scripts desde USB sin romper el uso normal de los pendrives confiables.

---

## 1️⃣ Desactivar automontaje y acciones automáticas (GNOME) **cuando no se tenga pensado usarlos**
Evita que se monte o abra solo al conectarlo cuando no se tenga pensado usar los USB:
```bash
gsettings set org.gnome.desktop.media-handling automount false
gsettings set org.gnome.desktop.media-handling automount-open false
gsettings set org.gnome.desktop.media-handling autorun-never true
```

---

## 2️⃣ Montar siempre con opciones seguras (noexec, nosuid, nodev)
Evita ejecución de binarios desde el USB, incluso si lo montas:
```bash
sudo tee /etc/udisks2/mount_options.conf >/dev/null <<'EOF'
[defaults]
vfat_defaults=uid=$UID,gid=$GID,umask=0077,noexec,nodev,nosuid
exfat_defaults=uid=$UID,gid=$GID,umask=0077,noexec,nodev,nosuid
ntfs_defaults=uid=$UID,gid=$GID,umask=0077,noexec,nodev,nosuid
ext4_defaults=noexec,nodev,nosuid
EOF

sudo systemctl restart udisks2
```

---

## 3️⃣ Bloquear BadUSB y autorizar solo dispositivos conocidos
Instala y configura **USBGuard**:
```bash
sudo dnf install usbguard
sudo systemctl enable --now usbguard

sudo usbguard generate-policy | sudo tee /etc/usbguard/rules.conf
sudo sed -i 's/^ImplicitPolicyTarget=.*/ImplicitPolicyTarget=block/' /etc/usbguard/usbguard-daemon.conf
sudo systemctl restart usbguard
```
Cuando conectes un USB confiable:
```bash
sudo usbguard list-devices
sudo usbguard allow-device <ID>
```

---

## 4️⃣ Verificación rápida
Conecta un USB y comprueba:
```bash
findmnt /run/media/$USER -o TARGET,OPTIONS
```
Debes ver `noexec,nodev,nosuid` en las opciones de montaje.
Si el USB no aparece montado automáticamente, las políticas están funcionando.

---

💡 **Notas:**
- SELinux en modo `enforcing` (por defecto en Fedora) refuerza las restricciones.
- Esta configuración evita ejecución directa, pero **si llamas tú a un intérprete (bash, python, etc.) sobre un archivo del USB, éste se leerá**. Por seguridad extrema, copia a un directorio controlado y analiza el archivo antes de abrirlo.
- Si en algún momento quieres bloquear **por completo** el almacenamiento USB, se puede añadir blacklist a los módulos `usb-storage` y `uas`.

---

Si quieres, puedo prepararte también un **script único** que aplique todo esto de una vez y lo puedas ejecutar en tu sistema para dejarlo protegido sin ir paso a paso.