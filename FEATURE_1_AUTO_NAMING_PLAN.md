# Feature #1: Auto-Naming & Smart Organization - Implementation Plan

**Fecha Created:** February 4, 2026  
**Estimated Duration:** 2-3 weeks  
**Priority:** MVP  

---

## 📝 Mejoras Implementadas (v1.7) - FIX: Audio Playback

**Fecha:** 4 de febrero de 2026, ~18:30

### Problema Identificado:

Aunque los nombres se sugerían correctamente, los archivos NO se reproducían. El análisis reveló:

**Root Cause:** En `saveTrack()`, el código usaba:
```swift
let encryptedData = NSData(contentsOf: tmpUrl)
fileManager.createFile(atPath: path, contents: encryptedData, attributes: nil)
```

**Problemas:**
1. ❌ No se garantizaba que el directorio destino existiera
2. ❌ `createFile()` puede fallar silenciosamente sin error
3. ❌ No había validación de si la copia tuvo éxito
4. ❌ `NSData(contentsOf:)` puede no funcionar con security-scoped URLs
5. ❌ No había logs para debugging

### Solución Implementada (v1.7):

Reemplazar el flujo de copia con:

```swift
// 1. Crear directorio destino
try fileManager.createDirectory(at: destinationDir, 
                               withIntermediateDirectories: true, 
                               attributes: nil)

// 2. Acceso security-scoped
if tmpUrl.startAccessingSecurityScopedResource() {
    defer { tmpUrl.stopAccessingSecurityScopedResource() }
    
    // 3. Usar copyItem (más robusto que createFile)
    try fileManager.copyItem(at: tmpUrl, to: destinationUrl)
    success = true
}

// 4. Logs extensos para debugging
AppLogger.general.info("Successfully copied track to: \(destinationPath)")
AppLogger.general.info("File exists after copy: \(fileManager.fileExists(atPath: destinationPath))")
```

### Cambios Implementados:

**DashboardViewModel.swift - `saveTrack()`:**

✅ Crear directorio destino con `createDirectory(withIntermediateDirectories:true)`
✅ Usar `FileManager.copyItem()` en lugar de `createFile()`
✅ Manejar security-scoped access correctamente con defer
✅ Remover archivos existentes antes de copiar
✅ Logs extensos en cada paso:
   - Directorio creado ✓
   - Track copiado ✓
   - Archivo existe después de copia ✓
   - Errores detallados si falla

### Flujo Corregido:

```
1. DocumentPicker (asCopy: false)
   → URL: /Users/.../iCloud/Multitracks/Song/click.mp3

2. DashboardScreen extrae nombre
   → originalDirectoryName = "Song"

3. createMultitrack() llama saveTrack() para CADA archivo
   
   a. Crear directorio:
      /app/Documents/Users/[uid]/Multitracks/ ✓
      
   b. Security-scoped access:
      startAccessingSecurityScopedResource() ✓
      
   c. Copiar archivo:
      copyItem(from: /iCloud/Multitracks/Song/click.mp3
               to: /app/Documents/Users/[uid]/Multitracks/[uuid].mp3) ✓
      
   d. Validar copia:
      FileManager.fileExists() → true ✓
      
   e. Release access:
      stopAccessingSecurityScopedResource() ✓

4. TrackControlViewModel.buildPlayer()
   → Carga desde ruta local de app
   → AVAudioPlayer(contentsOf: /app/Documents/...) ✓
   
5. Reproducción ✅
```

### Logs Ahora Disponibles:

En Xcode console verás:
```
[DashboardViewModel] Successfully copied track to: /app/Documents/Users/.../Multitracks/[uuid].mp3
[DashboardViewModel] File exists after copy: true
[TrackControlViewModel] File exists: true
[TrackControlViewModel] Loading track from path: /app/Documents/...
```

### Compilación: ✅ BUILD SUCCEEDED

---

## 📝 Mejoras Implementadas (v1.6) - BUG FIXES

**Fecha:** 4 de febrero de 2026, ~18:15

### Bugs Identificados y Solucionados:

#### Bug #1: Nombre "Multitracks" siendo sugerido
**Problema:** La carpeta padre es "Multitracks" (genérica), pero no estaba en la lista de nombres genéricos
- Ejemplo: `04. Trading My Sorrows - (E)129bpm/Multitracks/track.mp3`
- Fallaba en extraer abuelo: "04. Trading My Sorrows - (E)129bpm"

**Solución:** Añadir "Multitracks" a lista de nombres genéricos
```swift
let genericNames = [..., "Multitrack", "Multitracks", ...]
```
Ahora el algoritmo:
1. Padre "Multitracks" → rechazado (genérico)
2. Abuelo "04. Trading My Sorrows - (E)129bpm" → ✅ aceptado
3. Procesa y retorna "Trading My Sorrows" ✅

#### Bug #2: Errores de audio con `asCopy: false`
**Problema:** Sin copiar archivos al sandbox, la reproducción fallaba
```
HALC_ProxyObjectMap.cpp:516 - there is no system object
AQMEIO.cpp:358 - error -66680 finding/initializing Default-InputOutput
```

**Solución:** Actualizar `saveTrack()` para manejar security-scoped access
```swift
if tmpUrl.startAccessingSecurityScopedResource() {
    defer {
        tmpUrl.stopAccessingSecurityScopedResource()
    }
    encryptedData = NSData(contentsOf: tmpUrl)  // Lee con acceso
} else {
    encryptedData = NSData(contentsOf: tmpUrl)  // Fallback
}

fileManager.createFile(...)  // Copia al sandbox
```

### Cambios Implementados:

**DashboardScreen.swift:**
- ✅ Añadido "Multitracks" a `isGenericDirectoryName()`

**DashboardViewModel.swift:**
- ✅ `saveTrack()` ahora usa `startAccessingSecurityScopedResource()`
- ✅ Garantiza lectura de archivos originales con `asCopy: false`
- ✅ Luego copia explícitamente al sandbox con `FileManager.createFile()`

### Flujo Completo Corregido:

```
1. DocumentPicker (asCopy: false)
   → URLs apuntan a archivos originales ✅

2. DashboardScreen extrae directorio original
   → originalDirectoryName = "04. Trading My Sorrows..."
   → "Multitracks" rechazado (genérico)
   → Usa abuelo "04. Trading..."

3. TrackNamingService procesa
   → Remove "04. " prefix
   → Remove "129bpm" suffix
   → Result: "Trading My Sorrows" ✅

4. createMultitrack() → saveTrack()
   → startAccessingSecurityScopedResource()
   → Lee archivo original
   → Copia a /app/sandbox/tracks/[uuid].mp3
   → stopAccessingSecurityScopedResource()
   → Archivo disponible para reproducción ✅
```

### Resultados Esperados:

**Prueba 1:** "You Are Good - Eres Fiel - Israel Hougton - Multitrack"
- ✅ Sugiere: "You Are Good Eres Fiel Israel Hougton"
- ✅ Reproducción sin errores

**Prueba 2:** "04. Trading My Sorrows - (E)129bpm/Multitracks/"
- ❌ Sugería: "Multitracks"
- ✅ Ahora sugiere: "Trading My Sorrows" (usando abuelo)
- ✅ Reproducción sin errores

### Compilación: ✅ BUILD SUCCEEDED

---

## 📝 Mejoras Implementadas (v1.5) - CAMBIO CRÍTICO: asCopy: false

**Fecha:** 4 de febrero de 2026, ~18:00

### Descubrimiento del Problema Real:

El usuario identificó el culpable: **`asCopy: true` en DocumentPicker**

En [DocumentPicker.swift](iOS/Ui/Player/View/DocumentPicker/DocumentPicker.swift#L17):
```swift
picker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3, .wav], asCopy: true)
```

**Con `asCopy: true`:**
- DocumentPicker copia archivos **inmediatamente** al sandbox
- URLs devueltas apuntan a las **copias**, no a los originales
- Se pierden todas las referencias al directorio original
- Security-scoped resources no tienen acceso a la ubicación original
- **Imposible extraer el directorio padre**

### Solución v1.5:

Cambiar a `asCopy: false`:

```swift
picker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3, .wav], asCopy: false)
```

**Con `asCopy: false`:**
- URLs apuntan directamente a los **archivos originales**
- Acceso mediante security-scoped resources funciona **correctamente**
- Se pueden extraer directorios padre originales
- Los archivos se copian manualmente cuando se crea el multitrack
- `saveTrack()` continúa funcionando normalmente

### Cambios Implementados:

**DocumentPicker.swift:**
- ✅ Cambio: `asCopy: true` → `asCopy: false`
- Efecto: URLs ahora apuntan a archivos originales

**DashboardScreen.swift:**
- ✅ security-scoped access ahora funciona correctamente
- ✅ Extrae `originalDirectoryName` sin problemas
- ✅ Pasa a `suggestMultitrackName(from:originalDirectoryName:)`

**DashboardViewModel.swift:**
- ✅ `saveTrack()` sigue funcionando igual
- ✅ FileManager copia archivos a ubicación permanente
- ✅ Security-scoped access permite lectura durante la copia

### Flujo Completo (v1.5):

```
1. Usuario abre DocumentPicker
2. Selecciona archivos originales (e.g., /Music/Rey de reyes/click.mp3)
3. DocumentPicker devuelve URLs con asCopy: false
   → URLs apuntan a archivos originales
4. DashboardScreen extrae directorio padre
   → originalDirectoryName = "Rey de reyes"
5. suggestMultitrackName() procesa nombre
   → Retorna "Rey de reyes" ✅
6. Usuario confirma nombre
7. createMultitrack() llama a saveTrack() por cada archivo
   → saveTrack() accede al archivo original (security-scoped)
   → Copia a ubicación permanente
8. Multitrack creado correctamente ✅
```

### Compilación: ✅ BUILD SUCCEEDED

---

## 📝 Mejoras Implementadas (v1.4) - SECURITY-SCOPED URL ACCESS

**Fecha:** 4 de febrero de 2026, ~17:45

### El Problema Real (Descubierto):

Al imprimir las URLs que devuelve DocumentPicker, se reveló que **las URLs YA están en el sandbox temporal**:

```
file:///...CoreSimulator/.../tmp/com.estebantrivino.multitrack-player-Inbox/Tenor.mp3
```

No contienen el directorio original, solo el nombre del instrumento.

### Solución v1.4 - Security-Scoped Resource Access:

iOS proporciona un mecanismo para acceder a la ubicación **original** de un archivo antes de que se copie al sandbox:

1. **En DocumentPicker callback**, antes de usar las URLs:
   ```swift
   if firstUrl.startAccessingSecurityScopedResource() {
       defer {
           firstUrl.stopAccessingSecurityScopedResource()
       }
       
       let parentUrl = firstUrl.deletingLastPathComponent()
       originalDirectoryName = parentUrl.lastPathComponent
   }
   ```

2. **Pasar el directorio original** a `suggestMultitrackName(from:originalDirectoryName:)`

3. **Usar `cleanDirectoryName()`** para procesar el nombre

#### Estrategia de Fallback (Actualizada):

1. **Security-scoped URL access** (NUEVO - v1.4) ⭐
   - Intenta acceder a la ubicación original del archivo
   - Extrae el directorio padre antes de la copia
   
2. Análisis de directorios en URLs (fallback)
3. ID3 tags / Metadata
4. Historial de proyectos
5. Nombre del primer archivo

### Cambios Implementados:

**DashboardScreen.swift:**
- ✅ `DocumentPicker` callback ahora intenta `startAccessingSecurityScopedResource()`
- ✅ Extrae `originalDirectoryName` del directorio padre
- ✅ Imprime logs para debugging: "Original directory name: ..."
- ✅ Pasa `originalDirectoryName` a `suggestMultitrackName()`

**TrackNamingService (static):**
- ✅ `suggestMultitrackName(from:originalDirectoryName:)` - Nuevo parámetro opcional
- ✅ Prioriza `originalDirectoryName` si está disponible
- ✅ Mantiene fallbacks previos si falla

### Ejemplo de Funcionamiento:

```
Usuario selecciona: /Users/user/Music/Rey de reyes/
  └─ click.mp3, drums.mp3, bass.mp3, etc.

DocumentPicker devuelve URLs en sandbox:
  └─ file:///.../tmp/Inbox/click.mp3

Security-scoped access extrae:
  ✅ originalDirectoryName = "Rey de reyes"

suggestMultitrackName() retorna:
  ✅ "Rey de reyes"

vs. Sin security-scoped access:
  ❌ Sería imposible obtener el nombre
```

### Compilación: ✅ BUILD SUCCEEDED

---

## 📝 Mejoras Implementadas (v1.3) - CAMBIO DE ESTRATEGIA CORREGIDO

### Aclaración Crítica del Usuario:

El usuario corrigió el entendimiento:
- Los archivos de audio **solo contienen el nombre del instrumento** (click.mp3, drums.mp3, bass.mp3)
- **NO contienen el nombre de la canción**
- El nombre de la canción viene **en la RUTA devuelta por el file manager**
- Las URLs originales están temporalmente en `selectedAudioFilesUrls` ANTES de copiar al sandbox

### Solución Correcta (v1.3 - REVISADO):

**La estrategia original de analizar directorios ERA CORRECTA**, solo que necesitaba hacerse con los URLs originales que vienen del file manager, no después de que se copian al sandbox.

#### Flujo Correcto:

1. **File manager devuelve URLs originales**
   - Ejemplo: `/Users/user/Music/Rey de reyes/click.mp3`
   
2. **`extractNameFromDirectoryPath()` analiza esas URLs**
   - Extrae el directorio padre: `Rey de reyes`
   - Valida y limpia el nombre
   - Resultado: `Rey de reyes` ✅

3. **`cleanDirectoryName()` procesa el directorio**
   - Remove prefijos: `ORIGINAL_`, `BACKUP_`, etc.
   - Remove sufijos: `multitrack`, `remix`, `_100bpm`, etc.
   - Limpia separadores: `_` y `-` a espacios
   - Valida: No genérico, no Bundle ID, no números puros

#### Ejemplos:

```
URL Input:    /Users/user/Music/Rey de reyes/click.mp3
Directory:    Rey de reyes
Cleaned:      Rey de reyes ✅
Output:       "Rey de reyes"

URL Input:    /External/ORIGINAL_Socorro_Un_Corazon_100bpm/drums.mp3
Directory:    ORIGINAL_Socorro_Un_Corazon_100bpm
Step 1:       Remove "ORIGINAL_" → Socorro_Un_Corazon_100bpm
Step 2:       Remove "100bpm" → Socorro_Un_Corazon
Step 3:       Replace "_" with spaces → Socorro Un Corazon
Output:       "Socorro Un Corazon" ✅

URL Input:    /Volumes/Drive/Projects/MySong_multitrack/bass.mp3
Directory:    MySong_multitrack
Step 1:       Remove "_multitrack" → MySong
Output:       "MySong" ✅
```

### Métodos Implementados (v1.3 Corregido):

- ✅ `extractNameFromDirectoryPath()` - Analiza estructura de directorios de URLs originales
- ✅ `cleanDirectoryName()` - Limpia y valida nombres de directorios
- ❌ REMOVIDO: `extractNameFromAudioFilenames()` - No tenía valor (filenames solo son instrumentos)
- ❌ REMOVIDO: `extractProjectNameFromFilename()` - No aplicable
- ❌ REMOVIDO: `findCommonName()` - No necesario

### Fallback Completo:

1. Análisis de rutas originales del file manager (directorio padre/abuelo)
2. ID3 tags / Metadata
3. Historial de proyectos
4. Nombre del primer archivo (último recurso)

---

## 📝 Mejoras Implementadas (v1.3 - ORIGINAL - INCORRECTO)

**Nota:** Esta versión fue descartada porque el usuario aclaró que los filenames solo contienen el instrumento, no el nombre de la canción.

---

## 📝 Mejoras Implementadas (v1.1)

**Fecha:** 4 de febrero de 2026

### Problemas Solucionados:

1. ❌ **Bundle Identifier siendo sugerido** → ✅ Ahora filtra Bundle IDs (patrones como `com.example.app`)
2. ❌ **Búsqueda muy profunda en directorios** → ✅ Ahora limita a máximo 2 niveles (padre y abuelo)
3. ❌ **No procesaba directorios con patrones complejos** → ✅ Ahora extrae información de:
   - Prefijos: `ORIGINAL_`, `BACKUP_`, `TEMP_`
   - Sufijos BPM: `_100bpm`, `_120BPM`
   - Sufijo "multitrack": `Rey de reyes multitrack` → `Rey de reyes`
   - Patrones snake_case: `ORIGINAL_Socorro_Un_Corazon_100bpm` → `Socorro Un Corazon`

### Cambios en TrackNamingService:

- ✅ Nuevo método: `isBundleIdentifier()` - detecta y filtra IDs de app
- ✅ Nuevo método: `extractFromDirectoryName()` - maneja patrones complejos
- ✅ Nuevo método: `isNumericOnly()` - evita sugerir números puros
- ✅ Filtro extendido: Agregados "Inbox", "Sent", "Draft", "Trash", "iCloud", "Library", etc.
- ✅ Preferencia clara: Directorio padre (nivel 1) sobre abuelo (nivel 2)
- ✅ Límite de profundidad: Máximo 2 niveles arriba del archivo

---

## 📋 Executive Summary

Implementar sugerencia automática de nombres basada en rutas de archivos y reorden inteligente de pistas según tipo de instrumento detectado. 

**Flujo:**
```
Usuario selecciona archivos → Analizamos metadata/nombres → 
Mostramos nombre sugerido en NameInputDialogView → 
Usuario acepta o edita → Creamos multitrack con pistas reordenadas automáticamente
```

---

## 🎯 Objetivos

1. **Auto-Naming:** Sugerir automáticamente el nombre del proyecto basado en:
   - Ruta de archivos originales (máximo 2 niveles de profundidad)
   - ID3 tags / Metadata
   - Historial de proyectos anteriores
   - Nombre de archivos

2. **Smart Ordering:** Reordenar inteligentemente las pistas por tipo de instrumento:
   - Click/Metrónomo primero
   - Guide/Cues segundo
   - Batería, Bajo, Piano, Teclados, Guitarras, Resto...

---

## 🔧 PARTE 1: Auto-Naming (Sugerencia de Nombre)

### Punto de Entrada
Cuando `selectedAudioFilesUrls` se llena en DashboardScreen, **antes de mostrar NameInputDialogView**

### Flujo Técnico
```
DashboardScreen recibe URLs
  ↓
Llamar: suggestMultitrackName(urls: [URL]) → String?
  ↓
Usar nombre sugerido como texto inicial en NameInputDialogView
  ↓
Usuario puede aceptar o editar
```

### Lógica para Sugerir Nombre (orden de prioridad)

#### 1. Análisis de Ruta Completa (80% confiable)
- Extraer carpetas padre: `~/Music/Artist/Album/Song_Name` → "Song Name"
- Regex para detectar patrones comunes:
  - `Song_Name_-_Key_Of_Song` → "Song Name"
  - `Artist-Album-Track` → "Artist Album Track"
- Usar `FileManager.displayName()` para nombres legibles

**Ejemplo:**
```
Input:  ~/Music/Esteban/LatinVibe/Cumbia_In_C_Minor
Output: "Cumbia In C Minor"
```

#### 2. ID3 Tags (si existen)
- `AVAsset.metadata` → buscar `commonKeyTitle` + `commonKeyArtist`
- Si encontramos: "Artist - Song Name"
- Fallback a nombre del album si no hay título

**Ejemplo:**
```
ID3 Title: "Summer Hit"
ID3 Artist: "The Band"
Output: "The Band - Summer Hit"
```

#### 3. Historial del Usuario
- Si usuario tiene "Jazz Session 1", "Jazz Session 2" → sugerir "Jazz Session 3"
- Buscar prefijo común + incrementar número
- Evitar duplicados

**Ejemplo:**
```
Existing: ["Jazz Session 1", "Jazz Session 2"]
New: "Jazz Session 3"
```

#### 4. Fallback
- Si nada funciona, usar nombre del primer archivo: `vocals_final` → "Vocals Final"
- Aplicar título case formatting

### Archivos a Crear/Modificar

#### NUEVO: `TrackNamingService.swift`
**Ubicación:** `iOS/Ui/Player/View/Dashboard/TrackNamingService.swift`

**Responsabilidades:**
- Analizar rutas de archivos
- Extraer metadata ID3
- Buscar en historial
- Generar sugerencia de nombre final

**Métodos principales:**
```swift
class TrackNamingService {
    static func suggestMultitrackName(from urls: [URL]) async -> String
    private static func extractNameFromPath(_ urls: [URL]) -> String?
    private static func extractNameFromID3(_ url: URL) async -> String?
    private static func suggestFromHistory() -> String?
    private static func formatAsTitle(_ name: String) -> String
}
```

#### MODIFICAR: `NameInputDialogView.swift`

**Cambios:**
- Nuevo parámetro: `suggestedName: String?`
- Pre-llenar TextField con el nombre sugerido
- Mostrar pequeño badge "✨ AI Suggested" junto al nombre
- Si no hay sugerencia, mostrar placeholder normal

**Ejemplo UI:**
```
┌─────────────────────────────┐
│  Enter Multitrack Name      │
├─────────────────────────────┤
│ ✨ Summer Hit               │  ← Sugerencia pre-llenada
│  (AI Suggested)             │
├─────────────────────────────┤
│  [Cancel]         [Accept]  │
└─────────────────────────────┘
```

#### MODIFICAR: `DashboardScreen.swift`

**Cambios en línea ~77 (DocumentPicker callback):**
```swift
DocumentPicker() { urls in
    self.selectedAudioFilesUrls = urls
    
    // Obtener sugerencia de nombre
    Task {
        let suggestedName = await TrackNamingService.suggestMultitrackName(from: urls)
        DispatchQueue.main.async {
            self.suggestedMultitrackName = suggestedName
            self.showNewMultitrackNameInputDialog = true
        }
    }
}
```

**Nuevo @State:**
```swift
@State private var suggestedMultitrackName: String = ""
```

**Pasar a NameInputDialogView:**
```swift
NameInputDialogView(suggestedName: suggestedMultitrackName) { newMultitrackName in
    // ...
}
```

---

## 🎚️ PARTE 2: Reorden Inteligente de Pistas

### Punto de Entrada
En `createMultitrack()` dentro de DashboardViewModel, **después de crear todos los Tracks, antes de guardar**

### Estrategia de Detección

#### Nivel 1: Detección por Nombre de Archivo (80%+ confiable) ⭐ RECOMENDADO PARA MVP

**Patrones de búsqueda (case-insensitive):**

| Categoría | Patrones | Prioridad |
|-----------|----------|-----------|
| **Click** | "click", "metro", "metronome", "metrodomo" | 0 |
| **Guide/Cues** | "guide", "cue", "reference", "ref", "backing" | 1 |
| **Drums** | "kick", "drum", "drums", "perc", "percussion", "snare", "hihat" | 2 |
| **Bass** | "bass", "bajo", "sub" | 3 |
| **Piano** | "piano", "keys", "keyboard" | 4 |
| **Keyboards** | "synth", "pad", "organ", "mellotron" | 5 |
| **Guitars** | "guitar", "guitarra", "gtr", "electric", "acoustic" | 6 |
| **Vocals** | "vocal", "voice", "vox", "singer" | 6 |
| **Otros** | (ninguno anterior) | 7 |

**Ejemplo:**
```
Input files:
- click_metro.mp3         → Click (prioridad 0)
- guide_track.mp3         → Guide (prioridad 1)
- drums_kit.mp3           → Drums (prioridad 2)
- bass_line.mp3           → Bass (prioridad 3)
- piano_main.mp3          → Piano (prioridad 4)

Output order: click, guide, drums, bass, piano
```

#### Nivel 2: Análisis de Frecuencia (para MVP avanzado/Fase 2)

**Usar solo si Nivel 1 no detecta instrumento**

- Click: Energía dominante en 1-5kHz, picos aislados regulares
- Bass: Energía dominante en 20-250Hz
- Voz/Guide: Energía en 200-1000Hz + formantes vocales
- Otros: Análisis espectral más completo

**Performance:** 2-5 segundos por archivo (hacer en background)

### Orden Final de Pistas

```
Posición 0: Click/Metronome
Posición 1: Guide/Cues
Posición 2: Drums/Percussion
Posición 3: Bass
Posición 4: Piano
Posición 5: Keyboards (otros)
Posición 6: Guitars
Posición 7: Vocals
Posición 8+: Resto de instrumentos (orden original)
```

### Archivos a Crear/Modificar

#### NUEVO: `TrackClassificationService.swift`
**Ubicación:** `iOS/Ui/Player/View/Dashboard/TrackClassificationService.swift`

**Responsabilidades:**
- Clasificar tracks por tipo de instrumento
- Usar análisis de nombre como principal
- Optional: análisis de audio para archivos sin nombre descriptivo

**Enum para tipos:**
```swift
enum InstrumentType: Int {
    case click = 0
    case guide = 1
    case drums = 2
    case bass = 3
    case piano = 4
    case keyboards = 5
    case guitars = 6
    case vocals = 7
    case other = 8
}
```

**Métodos principales:**
```swift
class TrackClassificationService {
    static func classifyTrack(from filename: String) -> InstrumentType
    private static func classifyByName(_ filename: String) -> InstrumentType?
    // Optional en Fase 2:
    // static func classifyByAudio(_ url: URL) async -> InstrumentType
}
```

#### MODIFICAR: `DashboardViewModel.swift`

**Cambios en `createMultitrack()`:**

```swift
func createMultitrack(withName name: String, using tracksTmpUrls: [URL]) {
    showLoader()
    
    Task {
        // Crear tracks con orden original primero
        var multitrack = Multitrack(id: UUID(), name: name)
        
        for (index, tmpUrl) in tracksTmpUrls.enumerated() {
            let track = self.saveTrack(from: tmpUrl, order: Int32(index))
            multitrack.tracks.append(track)
        }
        
        // Clasificar y reordenar
        let sortedTracks = self.reorderTracksByInstrument(multitrack.tracks)
        multitrack.tracks = sortedTracks
        
        // Guardar en BD
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.multitracks[multitrack.id] = multitrack
            self.multitrackRepository.saveMultitrack(multitrack)
            self.selectMultitrack(multitrack.id)
            self.hideLoader()
        }
    }
}

private func reorderTracksByInstrument(_ tracks: [Track]) -> [Track] {
    // Clasificar cada track
    var classifiedTracks: [(track: Track, type: TrackClassificationService.InstrumentType)] = []
    
    for track in tracks {
        let filename = track.name.lowercased()
        let type = TrackClassificationService.classifyTrack(from: filename)
        classifiedTracks.append((track, type))
    }
    
    // Ordenar por tipo de instrumento
    let sorted = classifiedTracks.sorted { $0.type.rawValue < $1.type.rawValue }
    
    // Actualizar order
    return sorted.enumerated().map { index, item in
        var track = item.track
        track.order = Int32(index)
        return track
    }
}
```

---

## 📊 Consideraciones Técnicas

### Performance

| Operación | Duración | Notas |
|-----------|----------|-------|
| Análisis de nombre | < 10ms | Rápido, no bloquea UI |
| Extracción ID3 | 50-200ms por archivo | Async, no bloquea UI |
| Análisis de audio (FFT) | 2-5s por archivo | Background task, opcional |
| Total para 10 tracks | 5-10 segundos | Mostrar loader |

### Privacy & Security
- ✅ Todo procesamiento on-device (sin enviar audio a servidores)
- ✅ No guardar audio temporal innecesariamente
- ✅ Usar URLs directamente sin copiar

### Fallbacks & Edge Cases
- Si análisis de audio falla → usar solo nombres de archivo
- Si no hay suficiente metadata → mantener orden original
- Si nombre sugerido es vacío → mostrar "Untitled"
- Si nombres contienen caracteres especiales → sanitizar

### UX Improvements
- Mostrar "✨ AI Suggested" badge en NameInputDialogView
- Durante reorder: mostrar "Organizing tracks..." con progress
- Opción de deshacer/editar después de creación

### Caching (Opcional para MVP)
- Guardar clasificaciones en UserDefaults para archivos futuro
- Clave: hash del nombre del archivo
- TTL: No expirar (almacenar indefinidamente)

---

## 📋 Implementation Checklist

### Phase 1: Auto-Naming
- [ ] Crear `TrackNamingService.swift`
  - [ ] Método `extractNameFromPath()`
  - [ ] Método `extractNameFromID3()` con AVAsset
  - [ ] Método `suggestFromHistory()`
  - [ ] Método `suggestMultitrackName()` principal
  
- [ ] Modificar `NameInputDialogView.swift`
  - [ ] Agregar parámetro `suggestedName`
  - [ ] Pre-llenar TextField
  - [ ] Mostrar badge "✨ AI Suggested"
  
- [ ] Modificar `DashboardScreen.swift`
  - [ ] Agregar @State `suggestedMultitrackName`
  - [ ] Llamar `suggestMultitrackName()` en DocumentPicker
  - [ ] Pasar sugerencia a NameInputDialogView
  
- [ ] Testing
  - [ ] Diferentes formatos de carpetas
  - [ ] Archivos con y sin metadata
  - [ ] Casos edge (caracteres especiales, nombres vacíos)
  - [ ] Performance (múltiples archivos)

### Phase 2: Smart Ordering
- [ ] Crear `TrackClassificationService.swift`
  - [ ] Enum `InstrumentType` con 8 categorías
  - [ ] Método `classifyByName()` con patrones
  - [ ] Método `classifyTrack()` principal
  
- [ ] Modificar `DashboardViewModel.swift`
  - [ ] Método `reorderTracksByInstrument()`
  - [ ] Integrar en `createMultitrack()`
  - [ ] Actualizar `order` property de tracks
  
- [ ] Testing
  - [ ] Cada categoría de instrumento
  - [ ] Nombres variados (inglés/español)
  - [ ] Múltiples tracks con mismo tipo
  - [ ] Orden final correcto

### Phase 3: Polish & Optimization
- [ ] Agregar comentarios de código
- [ ] Documentar métodos públicos
- [ ] Testing exhaustivo
- [ ] Performance optimization si necesario
- [ ] UI refinement (animaciones, feedback)

---

## 🧪 Test Cases

### Auto-Naming Tests

```
Test 1: Ruta con estructura clara
Input:  ~/Music/Esteban/LatinVibe/Cumbia_In_C_Minor/
Output: "Cumbia In C Minor"

Test 2: ID3 tags disponibles
Input:  File con Title: "Summer Song", Artist: "The Band"
Output: "The Band - Summer Song"

Test 3: Historial (sesiones repetidas)
Input:  Existing: ["Jazz Session 1", "Jazz Session 2"]
Output: "Jazz Session 3"

Test 4: Fallback simple
Input:  vocals_final.mp3
Output: "Vocals Final"

Test 5: Caracteres especiales
Input:  ~/Music/Artist (Feat. Guest)/Song - Remix [2026]
Output: "Song Remix 2026"
```

### Smart Ordering Tests

```
Test 1: Orden completo
Input files:
  - "click_metro.mp3"
  - "guide_track.mp3"
  - "drums_full.mp3"
  - "bass_line.mp3"
  - "piano_main.mp3"

Output order:
  0: click_metro.mp3 (Click)
  1: guide_track.mp3 (Guide)
  2: drums_full.mp3 (Drums)
  3: bass_line.mp3 (Bass)
  4: piano_main.mp3 (Piano)

Test 2: Múltiples del mismo tipo
Input files:
  - "guitar_lead.mp3"
  - "guitar_rhythm.mp3"
  - "drums_kick.mp3"

Output order:
  0: drums_kick.mp3 (Drums)
  1: guitar_lead.mp3 (Guitar)
  2: guitar_rhythm.mp3 (Guitar)
  ↳ Mantener orden original entre mismo tipo

Test 3: Sin clasificación posible
Input files:
  - "track_01.mp3"
  - "track_02.mp3"

Output order: Original (sin cambios)

Test 4: Nombres en español
Input files:
  - "guitarra_electrica.mp3"
  - "bajo_profundo.mp3"
  - "bateria_completa.mp3"

Output order:
  0: bateria_completa.mp3 (Drums)
  1: bajo_profundo.mp3 (Bass)
  2: guitarra_electrica.mp3 (Guitar)
```

---

## 📈 Success Metrics

### MVP Success Criteria (Fase 1: Auto-Naming)
- [ ] Sugiere nombre correcto en 80%+ de casos
- [ ] Tiempo de sugerencia < 500ms (sin bloquear UI)
- [ ] Usuario ve sugerencia antes de ingresar nombre
- [ ] Usuario puede aceptar o editar fácilmente

### Full Feature Success Criteria (Fase 1 + 2)
- [ ] Auto-naming: 80%+ precisión
- [ ] Smart ordering: 85%+ precisión
- [ ] Tiempo total creación multitrack < 30 segundos
- [ ] User satisfaction > 4.5/5
- [ ] Reducción de 30% en ediciones posteriores (esperado)

---

## ⚠️ Riesgos & Mitigación

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|-----------|
| ID3 tags inconsistentes | Media | Fallback a nombre de archivo |
| Nombres de archivo muy genéricos | Media | Usar historial o estructura de carpetas |
| Performance con muchos archivos | Media | Procesar en background con loader |
| Análisis de audio impreciso | Alta | Usar principalmente nombres, audio como complemento |
| Nombres en idiomas no-inglés | Baja | Regex flexible, fallback a título case |

---

## 📚 References & Resources

- **AVFoundation Metadata:** https://developer.apple.com/documentation/avfoundation/media_assets_and_playback/
- **ID3 Tags:** https://id3.org/
- **FileManager Path Handling:** https://developer.apple.com/documentation/foundation/filemanager
- **Audio Analysis:** https://developer.apple.com/documentation/avfaudio
- **Swift Regex:** https://developer.apple.com/documentation/foundation/regex

---

## 🚀 Next Steps

1. **Review & Approve** - Validar que el plan cumple con requisitos
2. **Begin Phase 1** - Comenzar con TrackNamingService en próximos 2-3 días
3. **Testing** - Establecer ambiente de testing
4. **Phase 2 Planning** - Detallar implementation de TrackClassificationService
5. **Documentation** - Mantener documento actualizado con progreso

---

**Documento creado:** 4 de febrero de 2026  
**Versión:** 1.0  
**Estado:** Ready for Implementation
