#!/usr/bin/env bash
set -euo pipefail

# Zona por defecto
sudo firewall-cmd --permanent --set-default-zone=public

# Limpieza: quita servicios entrantes comunes (no necesarios para navegar)
for svc in ssh cockpit mdns samba ipp libvirt http https dhcpv6-client dns ntp; do
  sudo firewall-cmd --permanent --remove-service="$svc" || true
done

# Política estricta: todo lo que no se permita explícitamente, se DROP
sudo firewall-cmd --permanent --zone=public --set-target=DROP

# ======= SALIDA permitida (solo lo mínimo para navegar) =======

# DNS (necesario para resolver nombres)
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" destination port port="53" protocol="udp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" destination port port="53" protocol="tcp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" destination port port="53" protocol="udp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" destination port port="53" protocol="tcp" accept'

# HTTP/HTTPS (navegación web)
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" destination port port="80" protocol="tcp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" destination port port="443" protocol="tcp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" destination port port="80" protocol="tcp" accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" destination port port="443" protocol="tcp" accept'

# DHCP (para obtener/renovar IP)
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" destination port port="67" protocol="udp" accept'   # DHCPv4
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" destination port port="547" protocol="udp" accept'  # DHCPv6

# (Opcional, pero recomendado en IPv6) ICMPv6 para vecindad/RA
# Descomenta si usas IPv6 y ves problemas de conectividad:
# sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" protocol value="icmpv6" accept'

# ======= BLOQUEOS explícitos de puertos sensibles (entrante y saliente) =======
# No son estrictamente necesarios con target=DROP, pero los dejamos por claridad.
for p in 22 23 25 110 139 445 3389; do
  sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" port port=\"$p\" protocol=\"tcp\" reject"
  sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv6\" port port=\"$p\" protocol=\"tcp\" reject"
  sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" destination port port=\"$p\" protocol=\"tcp\" reject"
  sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv6\" destination port port=\"$p\" protocol=\"tcp\" reject"
done

# Aplicar cambios
sudo firewall-cmd --reload

# Mostrar resumen
echo
echo "=== Zona 'public' aplicada ==="
sudo firewall-cmd --zone=public --list-all