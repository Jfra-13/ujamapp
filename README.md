# ujamapp

> Gestor de actividades grupales y recaudos en tiempo real.
> "Crea un frasco, mete a tus amigos, llena la mermelada (la plata) y verifica que todos pusieron su parte."

`ujamapp` digitaliza y unifica el proceso de organizar un **recaudo grupal** (una salida, un regalo, un viaje, una parrillada) que hoy se hace de forma manual y caótica por WhatsApp + Yape + capturas de pantalla sueltas.

---

## Propuesta de Proyecto de Software: ujamapp (módulo "Jam")

### 1. Resumen Ejecutivo

- **Problema central:** Organizar un recaudo de dinero entre amigos hoy es desordenado, lento y manual. Se mezcla el chat de coordinación, los Yapes, y las capturas de "ya pagué" en un mismo grupo de WhatsApp. Nadie sabe con certeza quién pagó, quién falta, ni cuánto se juntó.
- **Solución propuesta:** Una app móvil (Flutter) donde un usuario crea un **Jam** (recaudo), invita participantes, y cada uno sube su comprobante de pago. La verificación es visual y de estado claro (semáforo gris → naranja → verde). Cada usuario tiene un **perfil con estadísticas de participación** que premia pagar rápido, fomentando el "buen comportamiento" del grupo.
- **Impacto esperado:** Recaudo más rápido, ordenado y verificable. Menos fricción social ("oe ya pagaste?"), menos tiempo perdido revisando capturas, transparencia total del estado del recaudo.
- **Inversión y tiempo:** Proyecto de aprendizaje/portafolio. MVP estimado en **6–8 semanas** part-time. Costo de infraestructura cercano a **$0** usando la capa gratuita de Firebase.

> **Nota de alcance honesta:** Yape **no expone una API pública** para integrarse. Esta propuesta NO automatiza el pago dentro de Yape. `ujamapp` es una app **externa** que *organiza y verifica* el recaudo; el Yape se sigue haciendo en la app de Yape, y aquí se sube el comprobante. La "integración real con Yape" queda explícitamente **fuera de alcance** (ver §3 y §7).

---

### 2. Planteamiento del Problema

- **Contexto actual:** Para juntar plata entre amigos, una persona define el monto y su número, lo manda al grupo de WhatsApp, y cada quien yapea cuando puede. La prueba de pago es una captura de pantalla pegada en el chat.
- **Limitaciones identificadas:**
  - **Desorden:** las capturas se pierden entre mensajes; el chat de coordinación se mezcla con los comprobantes.
  - **Falta de visibilidad:** nadie tiene una vista única de "quién pagó / quién falta / cuánto va".
  - **Verificación manual y lenta:** el organizador revisa captura por captura.
  - **Sin presión social estructurada:** los que pagan tarde no tienen ninguna consecuencia ni los que pagan rápido ningún reconocimiento.
  - **Sin historial:** terminado el recaudo, no queda registro reutilizable.
- **Impacto del problema:** Pérdida de tiempo del organizador, fricción y reclamos en el grupo, recaudos que se demoran o quedan incompletos, y desconfianza ("yo sí pagué, mira la captura").

---

### 3. Propuesta de Solución y Alcance

- **Descripción del software:** Aplicación **móvil multiplataforma** (Flutter, Android + iOS) con backend serverless (Firebase). Tiempo real vía Firestore: cuando alguien paga, todos ven el cambio de estado al instante.

- **Concepto central — el "Jam" (frasco):** Un recaudo es un frasco de mermelada. Los participantes están "dentro del frasco". Cada uno aporta su "cucharada" (su parte). El frasco se llena cuando todos pagan.

- **Estado de pago (semáforo):** cada participante tiene un `PaymentStatus`:
  - 🔘 **gris** — no ha pagado todavía.
  - 🟠 **naranja** — subió su comprobante, **pendiente de verificación**.
  - 🟢 **verde** — pago **verificado**.

#### Módulos y funcionalidades (EN alcance — MVP)

1. **Autenticación**
   - Registro / login (Firebase Auth: teléfono o correo).
2. **Gestión de Jams (recaudos)**
   - Crear un Jam: título, items con precio por persona (fijos/opcionales), tope de opcionales, fecha límite (`deadline`). Ver *Apéndice F*.
   - El creador es el **admin** del Jam.
   - Listar mis Jams (creados y en los que participo).
   - Cerrar / archivar un Jam.
3. **Unirse a un Jam** (ver detalle completo en *Apéndice C*)
   - **Ruta directa (sin aprobación):** el admin invita a un contacto de la plataforma, o genera un enlace de un solo uso.
   - **Ruta solicitud (requiere aprobación del admin):** QR, ID del Jam, o enlace reenviado por un participante.
4. **Aportes y comprobantes**
   - Un participante sube la **captura/voucher** de su Yape (`voucherUrl`).
   - Su estado pasa automáticamente a 🟠 naranja.
5. **Verificación**
   - El **admin** (MVP) marca el comprobante como válido → estado 🟢 verde.
   - El admin también es participante: él manda su parte como cualquiera.
6. **Vista de estado en tiempo real**
   - Panel del Jam: lista de participantes con su semáforo, monto recaudado vs. objetivo, cuántos faltan.
7. **Perfil con estadísticas (gamificación)**
   - Métricas por usuario: Jams creados, Jams completados, **velocidad promedio de pago**, racha de "pagos rápidos".
   - **Insignias/íconos** por buen comportamiento (ej. "Pagador veloz", "Nunca falta"). Esto es el gancho motivacional: querer el perfil "perfecto" para yapear rápido.

#### Exclusiones (FUERA de alcance — esta versión)

- ❌ **Integración real con Yape / BCP** (no existe API pública; no se mueve dinero dentro de la app).
- ❌ **Verificación automática del pago** por OCR/lectura del voucher (futuro).
- ❌ **Chat in-app** del Jam (futuro; el MVP puede apoyarse en el grupo existente).
- ❌ **Verificación por "usuario aleatorio"** en vez del admin (idea válida, pero se difiere a v2 por complejidad de reglas).
- ❌ Notificaciones push avanzadas, multimoneda, web/escritorio.

#### Arquitectura y tecnologías

| Capa | Tecnología | Estado |
|---|---|---|
| Frontend | **Flutter** (Dart, SDK ^3.11) | ✅ ya inicializado |
| Backend / DB | **Firebase Cloud Firestore** | ✅ ya configurado |
| Auth | Firebase Auth | ⬜ por agregar |
| Almacenamiento de vouchers | Firebase Storage | ⬜ por agregar |
| Lógica de servidor (verificación, stats) | Cloud Functions *(opcional)* | ⬜ futuro |

> Patrón sugerido: separar `models / repositories (Firestore) / services / ui`. Mantener simple — no sobre-arquitecturar el MVP.

#### Metodología de trabajo

- **Kanban ligero** con iteraciones de 1–2 semanas. Tablero simple (Por hacer / En curso / Hecho). Adecuado para proyecto individual de aprendizaje.

---

### 4. Entregables y Criterios de Aceptación

- **Entregables:**
  - Código fuente Flutter en este repositorio.
  - APK/build Android funcional (e iOS si se dispone de Mac).
  - Esquema de datos Firestore documentado.
  - Este README + diagrama de flujo del recaudo.
- **Criterios de éxito (MVP):**
  - Un usuario puede crear un Jam y compartir invitación.
  - Otros usuarios se unen con el código/enlace.
  - Cada participante sube su voucher y su estado cambia a naranja.
  - El admin verifica y el estado pasa a verde, **visible en tiempo real** para todos.
  - El perfil muestra al menos 2 estadísticas reales y 1 insignia.

---

### 5. Cronograma e Hitos (Milestones)

| Fase | Contenido | Estimado |
|---|---|---|
| **F1 — Diseño y modelo** | Refinar modelos (`Jam`, `Participant`, `User`), reglas Firestore, wireframes. | Semana 1 |
| **F2 — Auth + Jams** | Login, crear/listar Jams, unirse por código. | Semanas 2–3 |
| **F3 — Aportes + verificación** | Subir voucher, estados semáforo, panel en tiempo real. | Semanas 4–5 |
| **F4 — Perfil + gamificación** | Estadísticas e insignias. | Semana 6 |
| **F5 — QA + cierre** | Pruebas, pulido UI, build final. | Semanas 7–8 |

---

### 6. Presupuesto y Plan de Pagos

Proyecto personal / de aprendizaje. Sin facturación a cliente.

- **Infraestructura:** Firebase **Spark (gratis)** cubre el MVP. Coste estimado: **$0/mes** mientras el uso sea bajo.
- **Tiempo:** ~80–120 h de desarrollo part-time.
- Si en algún momento se busca cliente real, el modelo de pagos por hitos (30/40/30) aplicaría sobre las fases F2 / F4 / F5.

---

### 7. Gestión de Riesgos y Mitigación

| Riesgo | Impacto | Mitigación |
|---|---|---|
| **Yape no tiene API pública** | Alto | Diseñar como app externa de verificación por voucher. No prometer mover dinero. |
| **Comprobantes falsos** (captura editada) | Medio | Verificación humana del admin en MVP; OCR/validación de monto y fecha en futuro. |
| Verificación por "usuario aleatorio" es compleja (reglas, colusión) | Medio | Diferir a v2; arrancar con admin como verificador. |
| Reglas de seguridad de Firestore mal configuradas | Alto | Definir reglas estrictas desde F1 (solo miembros leen su Jam; solo admin verifica). |
| Sobre-ingeniería del MVP | Medio | Cortar features; semáforo + invitación por código primero. |
| Privacidad de datos (montos, teléfonos, vouchers) | Medio | Storage privado, acceso por reglas; no exponer vouchers públicamente. |

---

### 8. Términos, Condiciones y Próximos Pasos

- **Propiedad intelectual:** Código propiedad del autor (Juan Francisco Llamoja). Proyecto privado (`publish_to: none`).
- **Garantía y soporte:** N/A — proyecto de aprendizaje.
- **Vigencia / estado:** Documento vivo. La idea está **en proceso** y este README se actualizará conforme se definan requisitos.
- **Próximos pasos inmediatos:**
  1. Confirmar mecanismo de unión: **código/enlace de invitación** (recomendado) vs. por contactos vs. por solicitud.
  2. Decidir verificación MVP: **solo admin** (recomendado) vs. usuario aleatorio (v2).
  3. Definir el modelo `User` y qué estadísticas se calculan.
  4. Diseñar las reglas de seguridad de Firestore.

---

## Apéndice A — Requisitos (borrador para completar juntos)

### Requisitos Funcionales (RF)

- **RF-01** El usuario puede registrarse e iniciar sesión.
- **RF-02** El usuario puede crear un Jam con título, monto y fecha límite.
- **RF-03** El creador del Jam queda como admin.
- **RF-04** El admin puede invitar directamente a un contacto de la plataforma (ingreso sin aprobación).
- **RF-05** El admin puede generar un enlace de invitación de un solo uso (ingreso sin aprobación para quien lo use primero).
- **RF-05b** Un usuario puede solicitar unirse vía QR o ID del Jam (genera una solicitud).
- **RF-05c** El admin puede aprobar o rechazar solicitudes de ingreso.
- **RF-05d** Un enlace/QR reenviado por un participante (no admin) genera solicitud, no ingreso directo.
- **RF-06** Un participante puede subir el comprobante de su pago.
- **RF-07** Al subir comprobante, el estado del participante pasa a *naranja*.
- **RF-08** El admin puede verificar un comprobante y pasar el estado a *verde*.
- **RF-09** Todos los miembros ven el estado del Jam en tiempo real.
- **RF-10** El sistema calcula y muestra estadísticas por usuario (velocidad, cumplimiento, contadores, racha).
- **RF-11** El sistema otorga insignias según comportamiento de pago.
- **RF-12** El usuario puede enviar recordatorios de pago a otros miembros de un Jam.
- **RF-13** El sistema acumula puntos por acciones y deriva un rango (con slogan y logo).
- **RF-14** Los recordatorios otorgan puntos con tope para evitar spam.
- **RF-15** El admin define el Jam por items (nombre, precio, tipo fijo/opcional) y un tope de opcionales.
- **RF-16** Al ingresar, el miembro elige sus items opcionales (hasta el tope) en un bottom sheet.
- **RF-17** Cada item tiene un precio por persona fijo; la división automática es solo una calculadora al crear.
- **RF-18** El monto de un miembro es definitivo al confirmar y no cambia si entran nuevos miembros (sin devoluciones).
- **RF-19** El Jam tiene estados ABIERTO / VENCIDO / COMPLETADO gobernados por un único deadline.
- **RF-20** El deadline cierra a la vez ingreso, edición de selección y bonus de velocidad.
- **RF-21** Los pagos tardíos se aceptan sin bonus de velocidad.
- **RF-22** El admin puede extender el deadline mientras el Jam siga ABIERTO; reabrir un Jam VENCIDO requiere votación por mayoría (v2).
- **RF-23** El sistema notifica eventos clave (invitación, recordatorio, deadline próximo, verificación, frasco completo).

### Requisitos No Funcionales (RNF)

- **RNF-01 (Rendimiento)** Los cambios de estado se reflejan en < 2 s (tiempo real Firestore).
- **RNF-02 (Disponibilidad)** Sobre infraestructura gestionada Firebase.
- **RNF-03 (Seguridad)** Solo miembros de un Jam acceden a sus datos; vouchers en almacenamiento privado.
- **RNF-04 (Usabilidad)** Estado de pago entendible de un vistazo (semáforo de color).
- **RNF-05 (Portabilidad)** Android e iOS desde una sola base de código (Flutter).
- **RNF-06 (Mantenibilidad)** Separación clara modelo / datos / UI.

---

## Apéndice B — Modelo de datos (estado actual del código)

Colecciones en Firestore: `users/{uid}`, `jams/{jamId}`, `jams/{jamId}/participants/{userId}`.

```
AppUser  (users/{uid})            // "AppUser" para no chocar con User de Firebase Auth
 ├─ id, nickname, avatarUrl?
 ├─ slogan: String                // derivado del rango
 ├─ points: int
 ├─ rank: Rank                    // frascoVacio..maestroMermelada
 ├─ badges: List<String>
 ├─ stats: UserStats {jamsCreated, jamsJoined, jamsCompleted,
 │                    avgPaySpeedMinutes, completionRate, currentStreak}
 └─ createdAt: DateTime

Jam  (jams/{jamId})
 ├─ id, title, description?, icon
 ├─ adminId: String
 ├─ deadline: DateTime
 ├─ status: JamStatus             // abierto | vencido | completado
 ├─ maxOpcionales: int?           // null = sin tope
 ├─ items: List<JamItem>          // embebidos
 └─ memberIds: List<String>       // "dentro del frasco"; para queries y reglas

JamItem
 ├─ id, name
 ├─ pricePerPerson: double        // POR PERSONA, fijo (no se divide en vivo)
 └─ kind: ItemKind                // fijo | opcional

Participant  (jams/{jamId}/participants/{userId})
 ├─ id (= userId), name
 ├─ status: PaymentStatus         // gris | naranja | verde
 ├─ voucherUrl: String?           // captura del Yape
 ├─ selectedItemIds: List<String> // opcionales elegidos
 └─ amountDue: double             // final al confirmar
```

Todos los modelos tienen `fromMap` / `toMap` para Firestore. Reglas de seguridad en `firestore.rules` (referenciadas desde `firebase.json`).

> **Pendiente de modelar (cuando se construya el ingreso, *Apéndice C*):** `JamInvite` y `JoinRequest`, con sus reglas finas (que un usuario solo pueda agregar su propio uid a `memberIds`).

---

## Apéndice C — Modelo de ingreso a un Jam

**Principio:** el admin controla quién entra. Que se necesite aprobación o no **depende del origen de la invitación, no del canal**. Solo los canales que el admin controla 1-a-1 permiten ingreso directo; todo lo demás pasa por solicitud.

### Ruta A — Ingreso directo (sin aprobación)

El admin es el origen verificable.

| Método | Cómo |
|---|---|
| **Contacto de plataforma** | El admin elige a un usuario de sus contactos en la app y lo invita. Entra directo. |
| **Enlace de un solo uso** | El admin genera un enlace/token de un uso y se lo manda a una persona. El primero que lo usa entra directo; reusarlo → expirado. |

### Ruta B — Solicitud (requiere aprobación del admin)

El origen no es verificable o es público.

| Método | Cómo |
|---|---|
| **QR del Jam** | Se escanea el QR → genera solicitud. |
| **ID del Jam** | Se ingresa el ID → genera solicitud. |
| **Enlace reenviado por un participante** | Un miembro (no admin) comparte → quien lo use cae en solicitud. |

> **Por qué QR/ID siempre son solicitud:** un QR o un ID, una vez compartido, es público. El sistema **no puede saber** si lo reenvió el admin o un participante. Por eso el único ingreso directo confiable es el canal 1-a-1 del admin (contacto o token de un uso). Esto evita prometer una garantía técnicamente imposible.

### Estados de membresía

```
invitado    → el admin lo invitó por ruta directa; al aceptar pasa a "miembro"
solicitante → pidió entrar por ruta B; espera aprobación
miembro     → dentro del frasco, participa del recaudo
rechazado   → el admin rechazó su solicitud
```

### Entidades nuevas a modelar

- **JamInvite** — `{ jamId, type: contacto | enlace_un_uso, issuerId, used, expiresAt }`
- **JoinRequest** — `{ jamId, userId, source: qr | id | enlace, status: pendiente | aprobada | rechazada }`

### Decisiones abiertas (Ruta de ingreso)

1. ¿El admin puede delegar la aprobación a co-admins? (sugerido: v2)
2. ¿Las solicitudes expiran con el `deadline` del Jam? (sugerido: sí)
3. ¿Hay límite de participantes por Jam?

---

## Apéndice D — Modelo de Usuario y perfil

**Filosofía:** perfil **minimalista, intuitivo y estético**. Pocas métricas con sentido, no un tablero saturado. La gamificación premia un solo comportamiento central: **yapear rápido y nunca fallar**.

### Entidad `User`

```
User
 ├─ id: String
 ├─ nickname: String          // apodo o nombre visible
 ├─ avatarUrl: String?
 ├─ slogan: String            // derivado del rango (no se edita a mano)
 ├─ points: int               // puntaje acumulado
 ├─ rank: Rank                // derivado de points
 ├─ badges: List<BadgeId>     // insignias ganadas (logos)
 ├─ stats: UserStats
 └─ createdAt: DateTime

UserStats
 ├─ jamsCreated: int
 ├─ jamsJoined: int
 ├─ jamsCompleted: int        // pagó y fue verificado
 ├─ avgPaySpeedMinutes: num   // velocidad promedio de pago
 ├─ completionRate: num       // % de cumplimiento (completed / joined)
 └─ currentStreak: int        // jams seguidos pagando a tiempo
```

### Estadísticas (4 titulares — el resto se descarta a propósito)

| Stat | Definición | Por qué |
|---|---|---|
| ⚡ **Velocidad promedio de pago** | tiempo medio desde que entra al Jam hasta subir el voucher | Métrica núcleo del incentivo |
| ✅ **Tasa de cumplimiento** | `jamsCompleted / jamsJoined` | Confiabilidad |
| 🫙 **Jams creados / unidos** | contadores | Participación |
| 🔥 **Racha actual** | jams consecutivos pagando a tiempo | Enganche |

**Descartado a propósito:** dinero total movido (privacidad), ranking global comparativo (presión tóxica; evaluar en v2).

### Sistema de puntos

| Acción | Puntos | Tope |
|---|---|---|
| Pagar y ser verificado | +10 | por Jam |
| Pagar rápido (bajo el umbral del Jam) | +5 | por Jam |
| Crear un Jam que se completa | +15 | por Jam |
| Recordatorio útil (el compañero paga tras el aviso) | +2 | **máx 1 por compañero por Jam** (anti-spam) |

> El recordatorio da puntos para fomentar ayudar al grupo a "llenar el frasco", pero está **topeado**: sin límite se convierte en spam farmeable.

### Rangos (definen el slogan y el logo)

Derivados de `points`. El slogan se muestra bajo el nombre.

| Rango | Logo | Slogan sugerido |
|---|---|---|
| Frasco Vacío | 🫙 | "Recién empieza a llenar" |
| Cucharada | 🥄 | "Va sumando" |
| Buen Frasco | 🍯 | "Cumplidor" |
| Frasco de Oro | ⭐ | "Yapea sin que le digan" |
| Maestro Mermelada | 👑 | "El frasco siempre lleno" |

*(Umbrales de puntos por definir.)*

### Insignias (eventos puntuales, set chico)

| Insignia | Se gana cuando |
|---|---|
| ⚡ Pagador Veloz | pagó bajo el umbral en N Jams |
| ✅ Nunca Falta | 100% de cumplimiento en N Jams |
| 🏅 Organizador | creó N Jams completados |
| 🤝 Buen Compa | sus recordatorios ayudaron a completar frascos |
| 🌅 Madrugador | primero en pagar en un Jam |

### Layout del perfil (minimalista)

```
        ( avatar )
          Apodo
   "Yapea sin que le digan"     ← slogan del rango
   ──────────────────────────
     ⚡ 4 min       ✅ 95%
     🫙 12 jams      🔥 5
   ──────────────────────────
     🏅 ⚡ 👑 🍯              ← insignias ganadas
```

### Nota de implementación

`points`, contadores y rangos se guardan **denormalizados** y se actualizan en una transacción cuando un pago se verifica o un Jam se completa (no recalcular todo el historial en cada lectura). La velocidad promedio se mantiene como acumulador. No construir un "motor de estadísticas" para v1 — contadores + una transacción al verificar bastan.

---

## Apéndice E — Panel del Jam (vista principal)

**Filosofía:** una acción primaria visible, el resto escondido hasta que se necesita. Evitar el FAB-menú (sobrecarga).

### Estructura (3 zonas)

1. **Header compacto** — avatar + saludo corto + menú overflow `⋯`. (Fusiona "icono de usuario" + "bienvenido" en una línea.)
2. **Carousel de Jams** — tarjeta con título, descripción, icono y **progreso del frasco** (recaudado vs objetivo). Swipe lateral = cambiar de Jam; dots de indicador. El menú `⋯` de este bloque contiene las acciones secundarias: **Compartir**, **Salir** (y para admin: editar/cerrar).
3. **Lista de miembros** — control "Ordenar ▾" arriba. Cada fila: avatar + apodo + semáforo de estado + tap para ir al perfil. El admin ve botón **validar** inline en los miembros en 🟠.

### FAB (botón flotante) — una sola acción contextual

| Estado del usuario | FAB muestra |
|---|---|
| No pagó (🔘) | **Subir voucher** |
| Pagó, pendiente (🟠) | oculto (ya solicitó validación al subir) |
| Verificado (🟢) | oculto |

> **Decisión:** subir el voucher **es** la solicitud de validación (pasa a 🟠). No existe un botón separado "solicitar validación" — sería un paso redundante.

> **Acciones secundarias fuera del FAB:** *Compartir* y *Salir* viven en el menú `⋯` del bloque del Jam, no en el FAB. Un FAB con 4 acciones es un menú disfrazado.

### Mockup

```
┌─────────────────────────────────┐
│ (avatar)  Hola, Apodo        ⋯  │
├─────────────────────────────────┤
│ ╭─────────────────────────────╮ │
│ │ 🍯  Salida playa            │ │
│ │     "viaje finde"           │ │
│ │     ▓▓▓▓▓▓░░░  S/120 / 200  │ │  ← progreso del frasco
│ ╰─────────────────────────────╯ │
│           • ○ ○                  │  ← dots (cambiar de Jam)
├─────────────────────────────────┤
│ Miembros          [Ordenar ▾]   │
│ ─────────────────────────────── │
│ (a) Lucho      🔘  →            │
│ (a) Maria      🟠  [validar]    │  ← admin valida inline
│ (a) Pedro      🟢               │
│ (a) Tú         🔘  →            │
└─────────────────────────────────┘
              (  ⬆ Subir voucher  )  ← FAB contextual
```

### Decisiones abiertas (Panel)

1. **Orden por defecto de la lista:** sugerido **por estado** (los que faltan arriba = presión social). El orden por monto queda como secundario.
2. ¿El progreso del frasco se mide por **monto** recaudado o por **cantidad de miembros** que pagaron? (sugerido: monto, sobre la suma de `amountDue` de los miembros — ver *Apéndice F*.)

---

## Apéndice F — Items, división de costos y selección

El admin arma el Jam por **items** (categorías de gasto), pero cada item tiene un **precio POR PERSONA fijo**, no un total que se divide en vivo. La división automática existe solo como **calculadora al crear** (el admin puede ingresar un total y un estimado de gente y la app sugiere el monto por cabeza), pero **lo que se guarda y se cobra es el monto por persona**, y ese monto **no cambia nunca**.

### Por qué precio por persona (y no split en vivo)

Si el monto se dividiera en vivo (`precio / N`), entraría gente nueva y **recalcularía lo que ya pagaron los demás**, generando saldos a favor y un sistema de devoluciones. La app **no mueve dinero** (no hay API de Yape), así que una devolución sería otro Yape manual con otro voucher a verificar — doble trabajo. **Precio por persona elimina todo eso de raíz:**

- El monto de cada miembro se conoce **al instante** y es **definitivo**.
- Sumar un miembro nuevo solo **agrega plata al total**; no toca a nadie que ya pagó.
- **Cero devoluciones.** No hace falta ledger de saldos.
- Sirve al objetivo de **recaudo rápido**: pagás apenas entrás, sin esperar a que cierre la selección.

### Tipos de item

| Tipo | Quién lo paga | Monto |
|---|---|---|
| **Fijo** | todos los participantes | precio por persona (lo paga sí o sí) |
| **Opcional** | solo quienes lo eligen | precio por persona (de la porción) |

### Entidad `JamItem`

```
JamItem
 ├─ id: String
 ├─ name: String          // "Carne", "Carbón", "Casa"
 ├─ pricePerPerson: double // monto POR PERSONA, fijo (no se divide en vivo)
 └─ kind: fijo | opcional
```

### Extensiones al modelo

```
Jam (añade)
 ├─ items: List<JamItem>
 └─ maxOpcionales: int            // tope de opcionales que un miembro puede elegir

Participant (añade)
 ├─ selectedItemIds: List<String> // opcionales elegidos (los fijos son implícitos)
 └─ amountDue: double             // = Σ pricePerPerson(fijos) + Σ pricePerPerson(opcionales elegidos)
                                  //   FINAL desde que el miembro confirma; no cambia si entra gente
```

> `totalBudget` deja de ser el dato fuente. El total recaudado se calcula sumando los `amountDue` de los miembros (crece si entra gente, sin afectar a nadie).

### Selección del miembro (modal bottom sheet, no "splash")

Al ingresar al Jam, el miembro ve un **bottom sheet** (`showModalBottomSheet`, nativo de Flutter) con:

- **Items fijos** — solo lectura ("esto pagás sí o sí").
- **Items opcionales** — checkboxes, hasta `maxOpcionales`.
- **Total** (definitivo, no estimado) que se recalcula al marcar/desmarcar.

```
┌──────────────────────────┐
│ Tu parte                 │
│ FIJO (pagás sí o sí):    │
│   🏠 Casa      S/20      │
│   🔥 Carbón    S/5       │
│ OPCIONAL (elegí, máx 2): │
│   ☑ 🥩 Carne   S/20      │
│   ☐ 🍺 Cerveza S/10      │
│ ─────────────────────    │
│ Tu total: S/45           │
│        [ Confirmar ]     │
└──────────────────────────┘
```

### Borde a resolver (decisiones abiertas)

1. **Opcional sin elegir:** si nadie elige un opcional, ese item simplemente no se cobra. Confirmar (no afecta a nadie con precio por persona).
2. **Cambiar selección:** el miembro puede editar sus opcionales **mientras no haya pagado** y el Jam siga ABIERTO. Una vez en 🟠/🟢 queda fijo. (sugerido.)
3. ¿El admin puede editar el `pricePerPerson` de un item después de que alguien pagó? (sugerido: no; obligaría a ajustes.)

---

## Apéndice G — Ciclo de vida del Jam y plazos

**Filosofía:** un **único `deadline`** gobierna todo. No se configuran candados separados para ingreso, selección y pago — uno solo, fácil de entender. Lo que el usuario quería evitar ("que se modifique a cada rato") ya lo resuelve el congelamiento en el deadline (*Apéndice F*).

### Estados

```
ABIERTO     → recaudando: entra gente, edita selección, paga CON bonus de velocidad
   │ (deadline)
   ▼
VENCIDO     → sin ingreso nuevo, selección congelada, montos finales,
              pagos tardíos permitidos pero SIN bonus
   │ (todos verificados / admin cierra)
   ▼
COMPLETADO  → frasco lleno, estadísticas y puntos liquidados
```

### Qué cierra el deadline (todo a la vez)

| Acción | Antes del deadline (ABIERTO) | Después (VENCIDO) |
|---|---|---|
| Ingresar al Jam | ✅ | ❌ |
| Editar selección de opcionales | ✅ | ❌ (congelado) |
| Pagar / subir voucher | ✅ con **bonus +5** | ✅ pero **sin bonus** (solo +10 base) |
| Monto por persona | final desde que confirma (no cambia) | final |

### Pagos tardíos

Pasado el deadline el pago **sigue aceptándose** — el recaudo tiene que completarse — pero pierde el bonus de velocidad. "Tarde" tiene consecuencia (menos puntos) sin bloquear el frasco.

### Extender / reabrir

| Situación | MVP | v2 |
|---|---|---|
| Aún ABIERTO, necesitan más tiempo | El **admin extiende el deadline**; se notifica a todos. | igual |
| Ya VENCIDO, quieren reabrir o sumar un miembro | **No se reabre.** | **Votación por mayoría** de los miembros. |

> **Por qué reabrir necesita voto (v2):** sumar un miembro después del cierre **recalcula el monto de todos** (los fijos se dividen entre más gente; los opcionales cambian). Quien ya pagó quedaría con saldo a favor. Por eso no puede ser decisión unilateral del admin. En MVP se evita el problema cerrando duro: vencido = vencido.

### Notificaciones (eventos que disparan aviso)

Set mínimo para el MVP — usar notificaciones locales / push (Firebase Cloud Messaging, futuro):

| Evento | A quién |
|---|---|
| Te invitaron / aprobaron en un Jam | al miembro |
| Recordatorio de pago (manual, *Apéndice D*) | al miembro que falta |
| Falta poco para el deadline | a los que no pagaron |
| El admin extendió el plazo | a todos |
| Tu pago fue verificado (🟢) | al miembro |
| Frasco completado | a todos |

### Decisiones abiertas (Ciclo de vida)

1. ¿Deadline obligatorio al crear, o puede haber Jam sin fecha (abierto indefinido)? (sugerido: obligatorio.)
2. ¿Cuántas veces puede el admin extender el plazo? (sugerido: con tope, o se vuelve eterno.)

---

## Apéndice H — Flujo de creación del Jam (admin)

**Filosofía:** **un solo formulario con secciones**, no un wizard de 5 pantallas. El admin completa de arriba a abajo y crea. Widgets nativos de Flutter (date picker para el deadline, etc.), sin librerías.

### Pasos (secciones del formulario)

**1. Datos básicos**
- Título (obligatorio).
- Descripción (opcional).
- Icono / emoji del Jam (opcional, default 🍯).
- **Deadline** (obligatorio) — `showDatePicker` nativo. Define el cierre (*Apéndice G*).

**2. Items**
- El admin agrega items uno por uno. Cada item:
  - Nombre ("Carne", "Casa", "Carbón").
  - **Precio por persona** (`pricePerPerson`).
  - Tipo: **fijo** (paga todo el mundo) u **opcional** (lo elige quien quiere).
- Ayuda opcional: botón "calcular por cabeza" → el admin mete un total y un estimado de gente, la app sugiere el monto por persona (pero guarda el por-persona, *Apéndice F*).

**3. Reglas de opcionales**
- `maxOpcionales`: cuántos items opcionales puede elegir cada miembro (default: sin tope).

**4. Invitar (puede ser después de crear)**
- Invitar contactos de la plataforma (ingreso directo), generar enlace de un solo uso, o mostrar QR / ID del Jam para solicitudes (*Apéndice C*).

**5. Crear**
- El Jam nace en estado **ABIERTO** (*Apéndice G*). El admin queda como participante y como verificador.

### Validaciones mínimas

- Título no vacío.
- Deadline en el futuro.
- Al menos **1 item**.
- `pricePerPerson > 0` en cada item.

### El admin también paga

Tras crear, el admin entra al Jam como un miembro más: elige sus opcionales en el bottom sheet (*Apéndice F*) y sube su voucher como cualquiera. Su rol extra es **validar** los pagos de los demás.

### Wireframe

```
┌─────────────────────────────────┐
│ ←  Nuevo Jam                    │
├─────────────────────────────────┤
│ Título      [ Salida playa    ] │
│ Descripción [ viaje finde     ] │
│ Icono       [ 🍯 ]              │
│ Deadline    [ 30 jun, 18:00 ▾ ] │
│ ─────────────────────────────── │
│ Items                    [ + ]  │
│  🏠 Casa     S/20  /pers  fijo  │
│  🔥 Carbón   S/5   /pers  fijo  │
│  🥩 Carne    S/20  /pers  opc.  │
│  🍺 Cerveza  S/10  /pers  opc.  │
│ ─────────────────────────────── │
│ Máx. opcionales por persona [2] │
│ ─────────────────────────────── │
│ Invitar     [ Contactos ][ QR ] │
│             [ Generar enlace   ] │
│                                 │
│        [   Crear Jam   ]        │
└─────────────────────────────────┘
```

### Decisiones abiertas (Creación)

1. ¿Invitar es parte del formulario o un paso posterior en el panel del Jam? (sugerido: poder hacer ambos — crear primero, invitar después.)
2. ¿Plantillas de Jam predefinidas (parrilla, viaje, regalo) que precarguen items? (idea linda, v2.)

---

## Flujo del recaudo (resumen)

```
1. Admin crea Jam ──► 2. Comparte código ──► 3. Amigos se unen
                                                   │
4. Cada uno yapea (en Yape) ──► 5. Sube voucher ──► estado 🟠 naranja
                                                   │
6. Admin verifica ──► estado 🟢 verde ──► 7. Frasco lleno = recaudo completo
                                                   │
                              8. Perfiles actualizan stats + insignias
```

---

## Getting Started (desarrollo)

Proyecto Flutter + Firebase.

```bash
flutter pub get
flutter run
```

Requiere `firebase_options.dart` configurado (ya presente) y un proyecto Firebase con Firestore habilitado.
