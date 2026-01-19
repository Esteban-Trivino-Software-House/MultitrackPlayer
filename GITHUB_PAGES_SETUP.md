# 🚀 Guía Paso a Paso - Publicar Política de Privacidad en GitHub Pages

## 📋 Archivos Creados

He creado una carpeta `docs/` con los siguientes archivos:
- ✅ `index.html` - Política de Privacidad en inglés (página principal)
- ✅ `privacy-es.html` - Política de Privacidad en español
- ✅ `README.md` - Documentación

## 🎯 Paso 1: Verificar que tienes Git instalado

Abre Terminal y ejecuta:
```bash
git --version
```

Si no tienes Git, instálalo desde: https://git-scm.com/download/mac

## 🎯 Paso 2: Inicializar repositorio Git (si no lo has hecho)

En la carpeta de tu proyecto, ejecuta:

```bash
cd /Users/estebantrivino/Documents/MultitrackPlayer
git init
```

## 🎯 Paso 3: Crear repositorio en GitHub

### Opción A: Desde la Web (Recomendado)

1. Ve a https://github.com/new
2. Nombre del repositorio: `multitrack-player-privacy` (o el nombre que prefieras)
3. Descripción: "Privacy Policy for Multitrack Player iOS App"
4. Selecciona: **Public** ⚠️ (debe ser público para GitHub Pages gratis)
5. **NO** marques "Initialize this repository with a README"
6. Click en "Create repository"

### Opción B: Desde Terminal (alternativa)

Si tienes GitHub CLI instalado:
```bash
gh repo create multitrack-player-privacy --public --source=. --remote=origin
```

## 🎯 Paso 4: Conectar tu proyecto local con GitHub

Copia los comandos que GitHub te muestra (algo como esto):

```bash
cd /Users/estebantrivino/Documents/MultitrackPlayer

# Agregar el remote
git remote add origin https://github.com/TU_USUARIO/multitrack-player-privacy.git

# Verificar que se agregó correctamente
git remote -v
```

## 🎯 Paso 5: Preparar archivos para subir

```bash
# Agregar solo la carpeta docs y archivos necesarios
git add docs/
git add PRIVACY_POLICY.md
git add PRIVACY_POLICY_EN.md
git add APP_STORE_PRIVACY_GUIDE.md

# Ver qué archivos se van a subir
git status

# Hacer commit
git commit -m "Add privacy policy for App Store Connect"
```

## 🎯 Paso 6: Subir a GitHub

```bash
# Renombrar rama a main (si es necesario)
git branch -M main

# Subir archivos
git push -u origin main
```

## 🎯 Paso 7: Activar GitHub Pages

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (Configuración) en la parte superior
3. En el menú lateral izquierdo, click en **Pages**
4. En "Source", selecciona:
   - Branch: `main`
   - Folder: `/docs`
5. Click en **Save**

⏱️ **Espera 2-3 minutos** mientras GitHub Pages construye tu sitio.

## 🎯 Paso 8: Obtener la URL

Después de unos minutos, verás un mensaje verde:

```
Your site is live at https://TU_USUARIO.github.io/multitrack-player-privacy/
```

✨ **¡Esa es tu URL para App Store Connect!**

## 🎯 Paso 9: Verificar que funciona

Abre la URL en tu navegador:
- Página principal (inglés): `https://TU_USUARIO.github.io/multitrack-player-privacy/`
- Página en español: `https://TU_USUARIO.github.io/multitrack-player-privacy/privacy-es.html`

## 🎯 Paso 10: Usar en App Store Connect

1. Inicia sesión en [App Store Connect](https://appstoreconnect.apple.com/)
2. Selecciona tu app
3. Ve a la sección **App Information**
4. En **Privacy Policy URL**, pega:
   ```
   https://TU_USUARIO.github.io/multitrack-player-privacy/
   ```
5. Guarda los cambios

---

## 🔧 Comandos Rápidos (Todo en Uno)

Si quieres hacerlo todo de una vez, copia y pega estos comandos (reemplaza TU_USUARIO con tu usuario de GitHub):

```bash
cd /Users/estebantrivino/Documents/MultitrackPlayer

# Inicializar Git (si no está inicializado)
git init

# Agregar archivos
git add docs/
git add PRIVACY_POLICY.md PRIVACY_POLICY_EN.md APP_STORE_PRIVACY_GUIDE.md

# Crear .gitignore si no existe
echo "# Xcode
*.xcuserstate
*.xcuserdatad
.DS_Store
DerivedData/
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3
xcuserdata/
*.moved-aside
*.hmap
*.ipa
*.dSYM.zip
*.dSYM" > .gitignore

git add .gitignore

# Commit
git commit -m "Add privacy policy for App Store Connect"

# Conectar con GitHub (REEMPLAZA TU_USUARIO)
git remote add origin https://github.com/TU_USUARIO/multitrack-player-privacy.git

# Subir
git branch -M main
git push -u origin main
```

---

## 🆘 Solución de Problemas

### ❌ Error: "remote origin already exists"

```bash
# Ver qué remote existe
git remote -v

# Eliminar y volver a agregar
git remote remove origin
git remote add origin https://github.com/TU_USUARIO/multitrack-player-privacy.git
```

### ❌ Error: "Permission denied"

Necesitas autenticarte. Opciones:

**Opción 1: Personal Access Token**
1. Ve a GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → Marca "repo"
3. Copia el token
4. Cuando hagas `git push`, usa el token como contraseña

**Opción 2: GitHub CLI (más fácil)**
```bash
# Instalar GitHub CLI
brew install gh

# Autenticarte
gh auth login

# Ahora puedes usar git push sin problemas
```

### ❌ Error: "GitHub Pages not working"

- Espera 5 minutos (puede tardar)
- Verifica que el repositorio sea **público**
- Verifica que en Settings → Pages esté seleccionado `/docs`
- Revisa que exista el archivo `docs/index.html`

### ❌ Quiero usar un repositorio existente

Si ya tienes un repositorio para tu app:

```bash
# Solo agregar los archivos nuevos
git add docs/
git add PRIVACY_POLICY*.md APP_STORE_PRIVACY_GUIDE.md
git commit -m "Add privacy policy"
git push
```

Luego activa GitHub Pages apuntando a `/docs`

---

## 📱 Alternativa: Subir solo la carpeta docs

Si no quieres subir todo tu código, crea un repositorio separado solo con la carpeta docs:

```bash
# Crear nuevo directorio
cd ~
mkdir multitrack-privacy-policy
cd multitrack-privacy-policy

# Copiar archivos
cp -r /Users/estebantrivino/Documents/MultitrackPlayer/docs .

# Inicializar Git
git init
git add docs/
git commit -m "Privacy policy for Multitrack Player"

# Conectar y subir
git remote add origin https://github.com/TU_USUARIO/multitrack-player-privacy.git
git branch -M main
git push -u origin main
```

---

## 🎨 Personalización (Opcional)

Si quieres personalizar los colores o estilos, edita el CSS dentro de `docs/index.html` y `docs/privacy-es.html`:

```css
/* Cambiar el color principal (actualmente azul Apple #007AFF) */
border-bottom: 3px solid #007AFF;  /* Cambia esto */
```

Después de cualquier cambio:
```bash
git add docs/
git commit -m "Update privacy policy styling"
git push
```

GitHub Pages se actualizará automáticamente en 1-2 minutos.

---

## ✅ Checklist Final

- [ ] Repositorio creado en GitHub
- [ ] Archivos subidos con `git push`
- [ ] GitHub Pages activado en Settings → Pages
- [ ] URL de GitHub Pages verificada en el navegador
- [ ] URL agregada en App Store Connect
- [ ] Página carga correctamente en móvil y escritorio

---

## 📞 ¿Necesitas Ayuda?

Si tienes problemas, avísame y te ayudo a resolverlos.

**Tu URL final será algo como:**
```
https://[tu-usuario].github.io/multitrack-player-privacy/
```

¡Eso es todo! 🎉
