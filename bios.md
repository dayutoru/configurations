
# Index
- [Intro](#intro)
- [BIOS Update](#bios-update)
- [BIOS Configuration](#bios-configuration)
    - [Main](#main)
    - [Advanced](#advanced)
    - [Boot](#boot)
    - [Security](#security)
- [Additional](#additional)
    - []()
    - []()
    - []()
    - []()
    - []()
    - []()




# Intro

Se recomienda empezar actualizando la BIOS si procede porque al hacerlo lo más seguro es que la configuración vuelva a su estado de fábrica.

Para poder ver todas las opciones de la BIOS, hemos de acceder al “Modo Avanzado”:
- Asus: F7
- Gigabyte: Ctrl+F
- MSI: F7
- HP/Lenovo: a veces hay un menú lateral “Advanced” o “System Configuration”

# BIOS Update

1. Identifica tu modelo exacto de placa base o portátil.
1. Ve al sitio oficial del fabricante (Dell, ASUS, Lenovo, etc.) y descarga la última versión del BIOS para tu modelo.
1. Formatea un USB en FAT32 y copia el archivo del BIOS.
1. Reinicia el equipo y entra al BIOS/UEFI (normalmente con F2, Del o Esc).
1. Busca la opción de actualización (puede llamarse “EZ Flash”, “M-Flash”, “BIOS Update”, etc.).
1. Selecciona el archivo desde el USB y confirma el proceso.
1. No apagues el equipo durante la actualización.


# BIOS Configuration
## Main
No precisa ningún cambio.

## Advanced

<table border="1">
  <thead><tr><th colspan="4">Advanced - Main</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>SATA Mode Selection</td><td>AHCI</td><td>Intel</td><td>En los sistemas Linux AHCI mejora rendimiento y compatibilidad con SSDs; también evita conflicto de controladores al ser nativo de Linux.</td></tr>
    <tr><td>Intel (R) SpeedStep (tm)</td><td>✅</td><td>✅</td><td>Permite ajustar dinámicamente la velocidad del procesador según la carga, mejorando eficiencia energética sin comprometer rendimiento.</td></tr>
    <tr><td>ERP Lot 3 Support</td><td>✅</td><td>✅</td><td>Reduce el consumo energético en modo apagado, desactivando funciones como carga por USB. Evita que pueda arrancarse de manera remota cuando está apagado.</td></tr>
    <tr><td>BACKSLASH/ALT Key Swap</td><td>❌</td><td>❌</td><td>No afecta seguridad, solo disposición de teclas.</td></tr>
    <tr><td>Network Stack</td><td>❌</td><td>❌</td><td>Evita arranque por red (PXE), bloqueando acceso remoto.</td></tr>
    <tr><td>Intel Virtualization Technology</td><td>❌</td><td>✅</td><td>También llamado VT-x, necesario para virtualizar máquinas. Desactivado en Linux si no usas máquinas virtuales; activo en Windows para compatibilidad.</td></tr>
    <tr><td>VT-d</td><td>❌</td><td>✅</td><td>Permite aislamiento de dispositivos cuando se usan VMs, útil para seguridad avanzada. Deshabilitar si no se van a usar MVs. Si VT-x está desabilitado no tiene utilidad real tenerlo activado, algunos expertos recomiendan por ello deshabilitarlo para reducir superficie de ataque.</td></tr>
    <tr><td>Hyper-Threading</td><td>❌</td><td>✅</td><td>Desactivado en Linux para evitar ataques tipo Spectre; activo en Windows por rendimiento.</td></tr>
    <tr><td>CPU C States</td><td>✅</td><td>✅</td><td>Permite ahorro energético sin comprometer seguridad.</td></tr>
    <tr><td>Allow BIOS Downgrade</td><td>❌</td><td>❌</td><td>Evita reinstalar versiones vulnerables del firmware.</td></tr>
  </tbody>
</table>

<table border="1">
  <thead><tr><th colspan="4">Advanced - BIOS Guard</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>BIOS Guard</td><td>✅</td><td>✅</td><td>Protege el firmware contra modificaciones maliciosas.</td></tr>
    <tr><td>Enable Tools Interface</td><td>❌</td><td>❌</td><td>Desactiva interfaces de depuración que podrían ser explotadas.</td></tr>
  </tbody>
</table>

<table border="1">
  <thead><tr><th colspan="4">Advanced - USB Configuration</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>Legacy USB Support</td><td>❌</td><td>❌</td><td>No se necesita en portátiles modernos sin periféricos externos.</td></tr>
    <tr><td>XHCI Hand-off</td><td>✅</td><td>✅</td><td>Permite al sistema operativo controlar puertos USB 3.0.</td></tr>
    <tr><td>USB Mass Storage Driver Support</td><td>❌</td><td>❌</td><td>Evita arranque desde USB, bloqueando acceso externo.</td></tr>
    <tr><td>USB transfer time-out</td><td>20 sec</td><td>20 sec</td><td>Tiempo razonable para evitar bloqueos por dispositivos lentos.</td></tr>
    <tr><td>Device reset time-out</td><td>20 sec</td><td>20 sec</td><td>Igual que arriba, para estabilidad.</td></tr>
    <tr><td>Device power-up delay</td><td>Auto</td><td>Auto</td><td>Permite que BIOS gestione tiempos según dispositivo.</td></tr>
  </tbody>
</table>

## Boot
<table border="1">
  <thead><tr><th colspan="4">Boot Configuration</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>Bootup NumLock State</td><td>❌</td><td>❌</td><td>Activa el teclado numérico al arrancar. Preferencia personal, no afecta seguridad ni rendimiento.</td></tr>
    <tr><td>Fast Boot</td><td>❌</td><td>✅</td><td>En Linux puede impedir detección de algunos periféricos; en Windows mejora tiempos de arranque.</td></tr>
    <tr><td>Boot Mode Select</td><td>UEFI</td><td>UEFI</td><td>UEFI ofrece mayor seguridad (Secure Boot, GPT) y compatibilidad moderna. Recomendado frente a Legacy o CSM.</td></tr>
  </tbody>
</table>

<table border="1">
  <thead><tr><th colspan="4">BOOT ORDER</th></tr></thead>
  <tbody>
    <tr><td>Deshabilitar todas las opciones menos la primera, donde dejaríamos el disco duro que contenga el SO.</td></tr>
  </tbody>
</table>


## Security

> **IMPORTANTE:** Creamos la contraseña de administrador y de usuario para poder acceder a la BIOS

<table border="1">
  <thead><tr><th colspan="4">Security - Main</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>Password Check</td><td>Always</td><td>Always</td><td>Requiere contraseña para entrar al BIOS y arrancar el dispositivo.</td></tr>
  </tbody>
</table>

<table border="1">
  <thead><tr><th colspan="4">Security - Trusted Computing</th></tr></thead>
  <tbody>
    <tr><td>Security Device Support</td><td>✅</td><td>✅</td><td>Activa TPM, útil para cifrado y autenticación segura.</td></tr>
    <tr><td>Disable Block SID</td><td>❌</td><td>❌</td><td>Permite acceso al identificador de seguridad del dispositivo.</td></tr>
  </tbody>
</table>

<table border="1">
  <thead><tr><th colspan="4">Security - Secure Boot</th></tr></thead>
  <tbody>
    <tr><td><strong>Configuración</strong></td><td><strong>Linux</strong></td><td><strong>Windows</strong></td><td><strong>Resumen</strong></td></tr>
    <tr><td>Secure Boot Support</td><td>✅</td><td>✅</td><td>La función está disponible en el firmware.</td></tr>
    <tr><td>Secure Boot</td><td>✅</td><td>✅</td><td>Verifica firmas digitales en el arranque, protección contra malware. Si no aparece como active tras seleccionar Secure Boot Support como Enabled y Boot Mode Select como UEFI puede ser normal, necesario reiniciar la BIOS para que se apliquen los cambios.</td></tr>
    <tr><td>Secure Boot Mode</td><td>Standard</td><td>Standard</td><td>Usa claves predeterminadas del fabricante (Microsoft).</td></tr>
  </tbody>
</table>

<br>
<br>

# Additional - por revisar

## Refuerza Secure Boot con tus propias claves

1. En UEFI, entra a la gestión de Secure Boot.
2. Borra las claves OEM/HP/Dell de fábrica (si el firmware lo permite).
3. Genera tu PK (Platform Key), KEK (Key Exchange Key) y db (firma de bootloaders):
   ``` bash
   # Ejemplo de generación de claves con sbsigntools
   openssl req -new -x509 -newkey rsa:2048 -keyout PK.key \
     -out PK.crt -days 3650 -subj "/CN=MiPK/"
   ```
4. Importa tus claves en el orden PK → KEK → db.
5. Firma GRUB o shim con tu db.key:
   ``` bash
   sbsign --key db.key --cert db.crt /boot/efi/EFI/fedora/shimx64.efi \
     --output /boot/efi/EFI/fedora/shimx64.efi
   ```
6. Comprueba que sólo arranque tu binario firmado.


## Añade contraseña al gestor de arranque (GRUB)

1. Crea un hash de tu contraseña:
   ```bash
   grub2-setpassword
   ```
   Esto te pedirá y generará `/etc/grub.d/user.cfg`.
2. Asegúrate de que en `/etc/default/grub` tengas:
   ```
   GRUB_DISABLE_RECOVERY=true
   GRUB_TERMINAL_INPUT=console
   GRUB_CMDLINE_LINUX="quiet splash"
   ```
3. Regenera la configuración:
   ```bash
   grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
4. Prueba reiniciar: GRUB pedirá contraseña antes de editar entradas o arrancar.



## Cifra tu disco con LUKS (Linux) o BitLocker (Windows)

- Linux + LUKS + TPM:
  1. Particiona `/boot` sin cifrar y el resto en volumen LUKS.
  2. Habilita `luks` en `/etc/crypttab`.
  3. Opcional: integra con TPM para liberar la clave sólo si no han cambiado las PCR (Anti-Evil-Maid).

- Windows + BitLocker:
  1. Habilita TPM 2.0 en UEFI.
  2. Activa BitLocker con “TPM + PIN”.
  3. Configura `group policy` para exigir PIN en cada arranque.


## Verificación de integridad y lockdown

- Linux:
  - Activa **kernel lockdown** (`GRUB_CMDLINE_LINUX="lockdown=integrity"`).
  - Instala AIDE o Tripwire y verifica el sistema en cada arranque.
- Windows:
  - Habilita **Device Guard** y **Credential Guard**.
  - Monitorea cambios con Windows Defender ATP o Sysmon.


## Barreras físicas y control de puertos

- Usa tapones físicos para bloquear puertos USB no críticos.
- Considera una jaula para SSD/HDD y candado de chasis.


## Refuerzos adicionales en la BIOS/UEFI

- Desactivar PXE/Network Boot
  - Ve a la sección de **Boot** y asegúrate de que no haya “Network/PXE” en el orden de arranque.
- Deshabilitar Wake-on-LAN en el adaptador integrado
  - Suele estar bajo **Advanced → Onboard Devices Configuration** o similar. Pon WoL en **Disabled**.
- Revisar Remote Management (AMT/iDRAC/ILO)
  - Si tu placa ofrece Intel AMT, iDRAC (Dell) o iLO (HP), desactívalos para impedir accesos fuera del sistema operativo.