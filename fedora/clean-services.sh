#!/usr/bin/env bash
set -euo pipefail

# Mapa paquete -> servicios asociados (Fedora/CentOS)
# Ajusta lo que no tengas o no quieras tocar.
declare -A MAP=(
  [openssh-server]="sshd.service sshd.socket"
  [httpd]="httpd.service"
  [nginx]="nginx.service"
  [samba]="smb.service nmb.service"
  [cups]="cups.service cups.socket"
  [bind]="named.service"
  [dnsmasq]="dnsmasq.service"
  [chrony]="chronyd.service"
  [ntp]="ntpd.service"
  [avahi]="avahi-daemon.service"          # avahi-daemon viene del paquete 'avahi'
  [miniupnpd]="miniupnpd.service"
  [libvirt-daemon]="libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket"
  [libvirt]="libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket"  # por si la provisión viene del meta-paquete
  [cockpit]="cockpit.socket"
)

# Requiere root
if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta como root: sudo $0"
  exit 1
fi

# Si exportas SKIP_CONFIRM=1, no pedirá confirmación antes de eliminar
SKIP_CONFIRM="${SKIP_CONFIRM:-0}"

for pkg in "${!MAP[@]}"; do
  svcs="${MAP[$pkg]}"

  # Salta si el paquete no está instalado
  if ! rpm -q "$pkg" &>/dev/null; then
    echo "[SKIP] Paquete no instalado: $pkg"
    continue
  fi

  echo "=== Procesando: $pkg (servicios: $svcs) ==="

  # Detener y deshabilitar servicios (si existen)
  for svc in $svcs; do
    if systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -qx "${svc}.service"; then
      echo " - Deteniendo $svc ..."
      systemctl stop "$svc" 2>/dev/null || true
      echo " - Deshabilitando $svc ..."
      systemctl disable "$svc" 2>/dev/null || true
    else
      echo " - Servicio $svc no existe en este sistema (saltando)"
    fi
  done

  # Pausa para que compruebes que nada se rompe
  if [[ "$SKIP_CONFIRM" != "1" ]]; then
    echo
    echo "Verifica que todo funciona. Se va a desinstalar: $pkg"
    read -r -p "Pulsa Enter para continuar o Ctrl+C para abortar..." _
  fi

  # Desinstalar paquete
  echo " - Desinstalando $pkg ..."
  dnf remove -y "$pkg" || {
    echo "   [WARN] No se pudo desinstalar $pkg (puede tener dependencias críticas). Continúo."
  }

  echo
done

echo "Listo."