Esas notas van orientadas a **endurecer la configuración de `sudo`** para que, aunque seas tú la única persona que usa el sistema, haya menos margen para que un proceso o intruso aproveche un descuido.

Te propongo una configuración segura y cómoda para uso personal:

---

## 1️⃣ Limitar `sudo` a tu usuario o grupo

1. **Edita la configuración**:
   ```bash
   sudo visudo
   ```
2. Busca la línea que permite `sudo` al grupo *wheel* o *sudo* y déjala solo si **tu usuario** está dentro.
   ```
   %wheel ALL=(ALL) ALL
   ```
3. Si no quieres grupos y prefieres algo explícito para tu usuario:
   ```
   tu_usuario ALL=(ALL) ALL
   ```

> Verifica que tu usuario esté en el grupo correcto:
> ```bash
> groups
> sudo usermod -aG wheel tu_usuario
> ```

---

## 2️⃣ Requerir contraseña siempre

Aunque estés logueado, `sudo` guarda por defecto un “vale” durante 5 minutos.
Para que **pida la contraseña cada vez** (más seguro) o acorte el tiempo:

- En `visudo`, añade al final:
  ```
  Defaults timestamp_timeout=5
  ```
  Esto caduca el permiso a los 5 minutos.
- Si quieres que siempre la pida (máxima seguridad):
  ```
  Defaults timestamp_timeout=0
  ```

---

## 3️⃣ Desactivar `NOPASSWD`

Asegúrate de **no** tener ninguna línea así:
```
%wheel ALL=(ALL) NOPASSWD: ALL
```
porque eliminaría la petición de contraseña.

---

## 4️⃣ Bloquear `root` directo

A nivel de seguridad general:
```bash
sudo passwd -l root
```
Esto impide login directo como root, pero puedes seguir usando `sudo`.

---

## 5️⃣ Revisar usuarios y limpiar

Como solo tú lo usas, asegúrate de que no hay cuentas innecesarias:
```bash
cat /etc/passwd | grep -vE 'nologin|false'
```
Deshabilita o borra usuarios que no reconozcas y no sean del sistema.

---

💡 **Flujo final seguro** para uso individual:
- Solo tu usuario en `wheel` o en la línea específica de `visudo`.
- `timestamp_timeout` reducido o a cero.
- `root` sin acceso directo.
- Cuentas innecesarias eliminadas o bloqueadas.
