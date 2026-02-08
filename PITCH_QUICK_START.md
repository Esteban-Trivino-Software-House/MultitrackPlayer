# 🎸 Guía Rápida: Feature de Cambio de Tono

## ¿Qué es la feature de Pitch Shifting?

La feature permite cambiar **TODO el multitrack** (no individual por pista). El rango es **±6 semitones** (no ±12).

**Cambios principales:**
- Pitch es GLOBAL (afecta todas las pistas simultáneamente)
- Rango reducido: ±6 semitones (3 tonos - estándar industria)
- UI: Menu button (no slider) en la toolbar principal
- Icon: Diapasón (tuningfork) - botón 44×44
- Menu: 13 opciones (+6 a +1, 0, -1 a -6)
- Cambio: Inmediato al seleccionar
- Persistencia: Automática en Core Data

## 🚀 Cómo Usarla

### Paso 1: Abre tu Multitrack
```
App Home → Selecciona un multitrack → Abre en modo reproducción
```

### Paso 2: Rota tu Dispositivo a Landscape (Horizontal)
- La interfaz de control de pistas solo aparece en landscape
- Verás todos los controles: Pan, Pitch, Mute, Volumen

### Paso 3: Busca el Control de Pitch
```
En cada pista ves:
┌─────────────────────┐
│ Pan options         │  ← Selector de Paneo
├─────────────────────┤
│ Pitch Slider        │  ← 👈 AQUÍ ESTá!
│ [♭ ───•──── ♯]     │
│    +2 st            │
├─────────────────────┤
│ [🔊] Mute button    │
├─────────────────────┤
│ 75% Volume          │
│ [Vertical slider]   │
├─────────────────────┤
│ Bass Track          │
│ (Track Name)        │
└─────────────────────┘
```

### Paso 4: Ajusta el Tono
- **Arrastra hacia la izquierda (♭)**: Nota más grave
- **Centro**: Tono original (sin cambios)
- **Arrastra hacia la derecha (♯)**: Nota más aguda

### Paso 5: Escucha el Resultado
- Los cambios son instantáneos
- Tu audio sonará en un tono diferente
- El tempo NO cambia
- La sincronización con otras pistas se mantiene

## 📝 Valores de Referencia

| Valor | Descripción | Uso |
|-------|-------------|-----|
| -12 | Una octava más grave | Nota 1 octava abajo |
| -7 | Una quinta más grave | Nota más baja común |
| -5 | Una cuarta más grave | Transposición por 4 semitones |
| 0 | **Tono Original** | Sin cambios ← VALOR POR DEFECTO |
| +5 | Una cuarta más aguda | Transposición por 5 semitones |
| +7 | Una quinta más aguda | Nota más alta común |
| +12 | Una octava más aguda | Una nota 1 octava arriba |

## 🎼 Ejemplos Prácticos

### Ejemplo 1: Practicar en tu Tonalidad
```
tu voz: tenor (requiere transposar 5 semitones arriba)
Pista original: Do Mayor

Solución:
1. Selecciona la pista de acompañamiento
2. Ajusta Pitch a +5 semitones
3. Ahora el acompañamiento está en Fa Mayor
4. Puedes cantar cómodamente en tu rango
```

### Ejemplo 2: Correo Armónico
```
Tienes 2 pistas de backing vocals y quieres distinto pitch:
Pista 1 (Lead vocal): Pitch = 0
Pista 2 (Harmony): Pitch = -5 (nota más baja)

Resultado: Acordes y armonía perfecta
```

### Ejemplo 3: Ensayo Flexible
```
Sesión de ensayo con banda:
- Hoy practico con un guitarrista en Clave de Re
- Pitch de backing: +2 semitones
- Mañana cambio a Sol Mayor
- Pitch de backing: +7 semitones
```

## 💾 Los Cambios se Guardan Automáticamente

✅ **Cuando ajustas el Pitch:**
1. El slider se mueve suavemente
2. El audio cambia instantáneamente
3. El cambio se guarda automáticamente en la app
4. Si cierras y reabres el multitrack → los valores se restauran

**No hay botón de Guardar - ¡todo se guarda solo!**

## 🎵 Tabla de Notas y Semitones

```
Referencia: Do (C) como nota 0
Do   → +0 st
Do#  → +1 st
Re   → +2 st
Re#  → +3 st
Mi   → +4 st
Fa   → +5 st
Fa#  → +6 st
Sol  → +7 st
Sol# → +8 st
La   → +9 st
La#  → +10 st
Si   → +11 st
Do (octava arriba) → +12 st
```

## ❓ Preguntas Frecuentes

### P: ¿Afecta el pitch al tempo?
**R:** ¡NO! El tempo se mantiene exacto. Solo cambia el tono/altura de la nota.

### P: ¿Puedo cambiar el pitch mientras se reproduce?
**R:** Sí, perfectamente. El cambio es instantáneo.

### P: ¿Qué pasa si cierro la app?
**R:** Los valores de pitch se guardan. La próxima vez que abras el multitrack, los valores estarán como los dejaste.

### P: ¿Cuál es el rango máximo?
**R:** -12 a +12 semitones (1 octava completa en cada dirección). Es el rango ideal para transposiciones musicales.

### P: ¿Puedo tener diferentes pitches en diferentes pistas?
**R:** ¡Sí! Cada pista tiene su propio control de pitch independiente. Puedes crear armonías y acordes complejos.

### P: ¿Hay latencia (retraso) en el audio?
**R:** No, el cambio es instantáneo sin retraso audible.

### P: ¿Funciona con todos los formatos de audio?
**R:** Sí, funciona con WAV, MP3 y M4A.

## 🛠️ Troubleshooting

### El slider de Pitch no aparece
- Rota tu dispositivo a landscape (horizontal)
- Los controles solo aparecen en landscape

### El pitch no cambia cuando lo ajusto
- Verifica que estés en landscape
- Verifica que la pista está cargada correctamente
- Intenta reabrir el multitrack

### El audio suena distorsionado después de cambiar pitch
- Baja el volumen de la pista
- El pitch extremo (+12 o -12) con volumen alto puede saturar
- 
### La pista se desincroniza
- Asegúrate que todas las pistas usan el mismo motor de audio
- Intenta pausar y reanudar la reproducción

## 📚 Más Información

Para información técnica detallada, ver:
- [Pitch Shifting Feature Complete Documentation](./PITCH_SHIFTING_FEATURE.md)
- [Implementation Summary](./PITCH_IMPLEMENTATION_SUMMARY.md)

---

## 💡 Tips Musicales

1. **Transposiciones Comunes:**
   - ±5 semitones: Perfecta transpuesta (muy común)
   - ±7 semitones: Quinta justa (harmonía traditional)
   - ±12 semitones: Octava (misma nota diferentes registros)

2. **Para Practicar Voces:**
   - Canta una nota referencia con la pista original (pitch 0)
   - Ajusta otros instrumentos para tu tonalidad cómoda
   - Esto es excelente para transposición vocal

3. **Crear Armonías:**
   - Pista 1: Pitch = 0 (Raíz/Fundamental)
   - Pista 2: Pitch = +4 (Tercera)
   - Pista 3: Pitch = +7 (Quinta)
   - Resultado: Acorde perfecto (fundamental, tercera, quinta)

4. **Ajústalo Gradualmente:**
   - No cambies ±12 de repente
   - Prueba primero con ±2 a ±5 semitones
   - Escucha cómo suena y ajusta finamente

---

**¡Disfruta transponiendo tu música!** 🎵🎸🎹
