# Guía Rápida - Respuestas para App Store Connect

## Cuestionario de Privacidad de App Store Connect

### ¿Recopila datos de esta aplicación?
✅ **SÍ**

---

## TIPOS DE DATOS RECOPILADOS

### 1. Información de Contacto
#### Dirección de correo electrónico
- ✅ **Se recopila**
- ✅ **Vinculado a la identidad del usuario**
- ❌ **NO se utiliza para rastrearte**
- **Propósito:** Funcionalidad de la aplicación, Autenticación

---

### 2. Contenido del Usuario
#### Audio
- ✅ **Se recopila** (almacenado localmente)
- ❌ **NO vinculado a la identidad del usuario**
- ❌ **NO se utiliza para rastrearte**
- ❌ **NO se envía fuera del dispositivo**
- **Propósito:** Funcionalidad de la aplicación
- **Nota:** Los archivos de audio permanecen solo en el dispositivo del usuario

---

### 3. Identificadores
#### ID de Usuario
- ✅ **Se recopila** (de Google Sign-In)
- ✅ **Vinculado a la identidad del usuario**
- ❌ **NO se utiliza para rastrearte**
- **Propósito:** Funcionalidad de la aplicación, Autenticación

---

### 4. Datos de Uso
#### Interacciones con el producto
- ✅ **Se recopila** (vía Firebase Analytics)
- ✅ **Vinculado a la identidad del usuario**
- ❌ **NO se utiliza para rastrearte**
- **Propósito:** Analíticas, Mejora del producto

---

### 5. Diagnósticos
#### Datos de fallos / Datos de rendimiento
- ✅ **Se recopila** (vía Firebase Analytics)
- ✅ **Vinculado a la identidad del usuario**
- ❌ **NO se utiliza para rastrearte**
- **Propósito:** Analíticas, Mejora del producto

---

## DATOS QUE NO RECOPILAMOS

❌ **Historial de compras** - No hay compras in-app
❌ **Ubicación** - No accedemos a GPS
❌ **Datos de salud y fitness**
❌ **Datos financieros**
❌ **Contactos** - No accedemos a la agenda
❌ **Fotos o videos** - Solo archivos de audio
❌ **Historial de búsqueda**
❌ **Historial de navegación**
❌ **Información de pago**
❌ **Otros datos**

---

## PRÁCTICAS DE PRIVACIDAD ESPECÍFICAS

### ¿Usas datos para rastrear usuarios en apps y sitios web de terceros?
❌ **NO**

### ¿Vinculaste tus prácticas de privacidad con la app?
✅ **SÍ** 
- URL requerida: [Coloca aquí la URL pública de tu política de privacidad]
- Opciones:
  - Hospedar en GitHub Pages
  - Crear sitio web simple
  - Usar servicio como app-privacy-policy.com

### ¿Usas servicios de terceros que puedan recopilar datos?
✅ **SÍ**
- Google Sign-In (Autenticación)
- Firebase Analytics (Analíticas)

---

## FORMULARIO DETALLADO DE APP STORE CONNECT

### Sección: Información de Contacto

**Correo electrónico**
- Tipos de dato: Dirección de correo electrónico
- ¿Cómo se usan estos datos?
  - [✓] Funcionalidad de la aplicación
  - [✓] Autenticación/Gestión de cuenta
- ¿Los datos están vinculados a la identidad del usuario? **SÍ**
- ¿Usas estos datos para rastrear? **NO**

---

### Sección: Identificadores

**ID de Usuario**
- Tipos de dato: ID de usuario
- ¿Cómo se usan estos datos?
  - [✓] Funcionalidad de la aplicación
  - [✓] Autenticación/Gestión de cuenta
- ¿Los datos están vinculados a la identidad del usuario? **SÍ**
- ¿Usas estos datos para rastrear? **NO**

---

### Sección: Datos de Uso

**Interacciones con el producto**
- Tipos de dato: Interacciones del producto
- ¿Cómo se usan estos datos?
  - [✓] Analíticas
  - [✓] Mejora del producto
- ¿Los datos están vinculados a la identidad del usuario? **SI**
- ¿Usas estos datos para rastrear? **NO**

---

### Sección: Diagnósticos

**Datos de fallos y rendimiento**
- Tipos de dato: Datos de fallos, Datos de rendimiento
- ¿Cómo se usan estos datos?
  - [✓] Analíticas
  - [✓] Mejora del producto
- ¿Los datos están vinculados a la identidad del usuario? **SI**
- ¿Usas estos datos para rastrear? **NO**

---

## NOTAS IMPORTANTES

1. **URL de Política de Privacidad:**
   - Es OBLIGATORIA para publicar en App Store
   - Debe ser accesible públicamente
   - Sugerencias para hospedarla:
     - GitHub Pages (gratis): https://pages.github.com/
     - Sitio web personal
     - Servicios como Netlify o Vercel (gratis)

2. **Email de Contacto:**
   - Reemplaza `[TU_EMAIL_DE_CONTACTO]` en la política con tu email real
   - Debe ser un email que revises regularmente

3. **Servicios de Terceros:**
   - Google Sign-In y Firebase Analytics están documentados
   - Apple puede requerir confirmación de SDKs de terceros

4. **Actualizaciones:**
   - Si agregas nuevas funcionalidades que recopilen datos, actualiza la política
   - Notifica a los usuarios de cambios significativos

---

## CHECKLIST ANTES DE ENVIAR A REVISIÓN

- [ ] Reemplazar `[TU_EMAIL_DE_CONTACTO]` con email real
- [ ] Publicar la política de privacidad en una URL pública
- [ ] Agregar la URL en App Store Connect
- [ ] Verificar que todos los servicios de terceros estén documentados
- [ ] Completar el cuestionario de privacidad en App Store Connect
- [ ] Revisar que la información coincida con lo implementado en el código
- [ ] Preparar screenshots actualizados
- [ ] Escribir una buena descripción de la app

---

## RECURSOS ADICIONALES

- **Política de Privacidad de Apple:** https://developer.apple.com/app-store/review/guidelines/#privacy
- **Guía de Etiquetas de Privacidad:** https://developer.apple.com/app-store/app-privacy-details/
- **Firebase y Privacidad:** https://firebase.google.com/support/privacy
- **Google Sign-In Compliance:** https://developers.google.com/identity/protocols/oauth2

---

## OPCIONES PARA HOSPEDAR LA POLÍTICA DE PRIVACIDAD

### Opción 1: GitHub Pages (Recomendado - Gratis)
1. Crea un repositorio público en GitHub
2. Sube el archivo PRIVACY_POLICY_EN.md
3. Activa GitHub Pages en Settings
4. Tu URL será: `https://[tu-usuario].github.io/[nombre-repo]/PRIVACY_POLICY_EN.html`

### Opción 2: Crear página HTML simple
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Multitrack Player</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
               line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #333; }
        h1 { color: #1a1a1a; }
        h2 { color: #2c2c2c; margin-top: 30px; }
        h3 { color: #444; }
    </style>
</head>
<body>
    [Copiar el contenido de PRIVACY_POLICY_EN.md convertido a HTML]
</body>
</html>
```

### Opción 3: Servicios Gratuitos
- **Netlify:** https://www.netlify.com/ (gratis, fácil)
- **Vercel:** https://vercel.com/ (gratis, fácil)
- **Firebase Hosting:** https://firebase.google.com/docs/hosting (ya usas Firebase)

---

**Última actualización:** Enero 19, 2026
