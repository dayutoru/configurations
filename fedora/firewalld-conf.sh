#!/usr/bin/env bash
set -euo pipefail

# Zona por defecto
sudo firewall-cmd --set-default-zone=public

# Limpieza: quita servicios entrantes comunes (no necesarios para navegar)
for svc in ssh cockpit mdns samba ipp libvirt http https dhcpv6-client dns ntp; do
  sudo firewall-cmd --permanent --remove-service="$svc" || true
done

# Política estricta: todo lo que no se permita explícitamente, se DROP
sudo firewall-cmd --permanent --zone=public --set-target=DROP

# Permitir web y DNS salientes
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port port="53" protocol="udp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" port port="53" protocol="tcp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" port port="53" protocol="udp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" port port="53" protocol="tcp" accept'

# Bloquear DNS entrante
for proto in udp tcp; do
  sudo firewall-cmd --permanent --zone=public \
    --add-rich-rule="rule family=\"ipv4\" source address=\"0.0.0.0/0\" port port=\"53\" protocol=\"$proto\" reject"
  sudo firewall-cmd --permanent --zone=public \
    --add-rich-rule="rule family=\"ipv6\" source address=\"::/0\" port port=\"53\" protocol=\"$proto\" reject"
done

# Bloquear puertos peligrosos en entrada
for p in 22 23 25 110 139 445 3389; do
  for proto in tcp udp; do
    sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" port port=\"$p\" protocol=\"$proto\" reject"
    sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv6\" port port=\"$p\" protocol=\"$proto\" reject"
  done
done

# Aplicar cambios
sudo firewall-cmd --reload

# Mostrar resumen
echo
echo "=== Zona 'public' aplicada ==="
sudo firewall-cmd --zone=public --list-all

