# adavra-sales

Sistema de presupuestos, proyectos y cobranza de mantenimiento para una empresa de desarrollo de software.
Trabajo Práctico N.º 1 · Programación IV · UTN.

- **Back-office** (`/admin`): el equipo arma presupuestos por tareas, registra horas, administra contratos de mantenimiento y controla la cobranza.
- **API JSON** (`/api/v1`): los clientes consultan sus proyectos, aprueban o rechazan presupuestos, ven su estado de cuenta e informan pagos.

## Stack

| | |
|---|---|
| Framework | Ruby on Rails 8.1 (Ruby 3.4) |
| Base de datos | PostgreSQL (dominio) · SQLite para Solid Cache/Queue/Cable en producción |
| Autenticación | Back-office: sesión con `has_secure_password` (`rails generate authentication`) · API: token Bearer con `has_secure_token` |
| Vistas | ERB + Tailwind CSS 4 · API con Jbuilder |
| Calidad | Minitest · Rubocop (rails-omakase) · Brakeman · bundler-audit |

## Instalación

Requisitos: Ruby 3.4, PostgreSQL 14+ y `libpq-dev`.

```bash
bundle install
bin/rails db:prepare     # crea las bases, carga el esquema y los seeds
bin/dev                  # servidor + Tailwind en modo watch
```

La app queda en http://localhost:3000. En desarrollo la conexión a Postgres es por socket con el usuario del sistema
(sin contraseña). Para regenerar los datos de demo: `bin/rails db:seed:replant`.

### Usuarios de los seeds

Todos con contraseña **`password`**.

| Usuario | Rol | Para qué |
|---|---|---|
| `admin@adavra.com` | Admin | Back-office completo, incluida la gestión de usuarios |
| `marcos@adavra.com` / `lucia@adavra.com` | Developer | Back-office sin gestión de usuarios |
| `portal@clubsocial.com.ar` | Cliente | API · tiene un presupuesto **enviado** para aprobar o rechazar |
| `portal@ferreteriael.com.ar` | Cliente | API · cliente **moroso**: 4 cuotas vencidas y un pago en revisión |
| `portal@estudiocontable.com.ar` | Cliente | API · una cuota **parcial** y un presupuesto rechazado + uno aprobado |
| `portal@panaderiala.com.ar` | Cliente | API · cliente al día |

Las fechas de los seeds son relativas al día en que se cargan, así que los atrasos (30/60/90 días) siempre se ven.

## Modelo de datos

13 tablas. Diagrama entidad-relación completo en [`docs/der.pdf`](docs/der.pdf).

- **Presupuestación:** `Client` → `Project` → `Budget` (versiones) → `BudgetItem` → `TimeEntry`. Cada ítem guarda la `Rate` con la que se valorizó.
- **Cobranza:** `Client` → `MaintenanceContract` → `MaintenanceCharge` (una por mes). `Payment` y `MaintenanceCharge` se relacionan muchos a muchos a través de `PaymentApplication`.
- **Acceso:** `User` (roles `client` 50 · `developer` 80 · `admin` 100) y `Session`.

Importes en `decimal(12,2)` y horas en `decimal(8,2)`, nunca `float`.

## Reglas de negocio

Cada una está implementada en el modelo y cubierta por tests (`test/models`).

| # | Regla | Dónde |
|---|---|---|
| 1 | Total = Σ(horas × valor hora) × (1 + buffer) | `Budget#calculate_total!` |
| 2 | La tarifa queda congelada en el ítem; un cambio de tarifa no altera presupuestos emitidos | `BudgetItem#assign_current_rate`, `Rate.current_for` |
| 3 | Estados `borrador → enviado → aprobado \| rechazado`, sin vuelta atrás | `Budget#send_to_client`, `#approve`, `#reject` |
| 4 | Un presupuesto enviado no se modifica: se crea una nueva versión | `BudgetItem#budget_must_be_draft`, acción `new_version` |
| 5 | No se envía un presupuesto sin ítems o con total cero | `Budget#send_to_client` |
| 6 | Las tareas no facturables no suman al total del cliente | `Budget#calculate_total!` |
| 7 | Desvío = horas registradas − horas estimadas | `BudgetItem#deviation` |
| 8 | No se cargan horas en un proyecto cerrado | `TimeEntry#project_must_be_open` |
| 9 | Una carga no supera 24 horas | validación de `TimeEntry` |
| 10 | La cuota copia el monto vigente del contrato | `MaintenanceContract#generate_charge_for` |
| 11 | Generar dos veces el mismo período no duplica | índice único `(maintenance_contract_id, period)` + `find_or_create_by!` |
| 13 | Un contrato pausado no genera cuotas nuevas pero conserva las impagas | `MaintenanceContract#generate_charge_for` |
| 14 | Un pago cubre varias cuotas (primero las más viejas) y no se imputa por más de su monto | `Payment#apply_to_open_charges!`, validaciones de `PaymentApplication` |
| 15 | Estado de la cuota: pendiente, parcial, pagada o vencida según lo imputado | `MaintenanceCharge#refresh_status!` |
| 16 | Deuda del cliente = saldos de cuotas no pagadas | `Client#debt` |
| 17 | Un pago informado por el cliente queda en revisión y no imputa hasta que un admin lo confirma | `Payment#confirm!`, `Api::V1::PaymentsController#create` |

## Back-office

Entrar en http://localhost:3000 con `admin@adavra.com`. Solo acceden usuarios con rol developer o admin
(`Admin::BaseController`); un usuario del portal es rechazado aunque su contraseña sea correcta.

| Pantalla | Ruta |
|---|---|
| Dashboard de cobranza (cobrado, pendiente, vencido, atrasos 30/60/90, deudores, pagos en revisión) | `/admin` |
| Clientes, proyectos, contratos y usuarios (ABM) | `/admin/clients`, `/admin/projects`, `/admin/maintenance_contracts`, `/admin/users` |
| Presupuesto: ítems, tarifas, desvío de horas, envío al cliente y nueva versión | `/admin/budgets/:id` |
| Registro de horas | `/admin/time_entries` |
| Tarifas (no se editan: una tarifa nueva tiene su propia vigencia) | `/admin/rates` |
| Cuotas con filtro por estado | `/admin/maintenance_charges` |
| Pagos: registro con imputación automática y bandeja de pagos en revisión | `/admin/payments` |

## API v1

Base: `http://localhost:3000/api/v1`. Todas las respuestas son JSON. Salvo el login, cada request lleva el header
`Authorization: Bearer <token>`.

La colección de Postman está en [`docs/adavra-sales-api.postman_collection.json`](docs/adavra-sales-api.postman_collection.json):
el login guarda el token y "Mis proyectos" guarda los ids que usan las demás requests.

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/login` | Devuelve el token. Solo usuarios con rol cliente |
| DELETE | `/logout` | Rota el token: el anterior deja de funcionar |
| GET | `/projects` | Proyectos del cliente con su presupuesto vigente |
| GET | `/projects/:id` | Detalle del proyecto y versiones de presupuesto |
| GET | `/budgets/:id` | Presupuesto con ítems facturables agrupados por módulo |
| POST | `/budgets/:id/approve` | Aprueba un presupuesto enviado |
| POST | `/budgets/:id/reject` | Rechaza un presupuesto enviado |
| GET | `/account` | Deuda total, cuotas impagas y últimos pagos |
| GET | `/charges?status=overdue` | Cuotas, filtrables por `pending`, `partial`, `paid`, `overdue` |
| GET | `/payments` | Pagos del cliente |
| POST | `/payments` | Informa un pago (queda `pending_review`) |

### Ejemplos

```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email_address": "portal@clubsocial.com.ar", "password": "password"}'
```

```json
{
  "token": "xU1Pp4fiei9FsLBmPkDRhJzr",
  "token_type": "Bearer",
  "user": { "id": 35, "name": "Abril Frías Vázquez", "email_address": "portal@clubsocial.com.ar" },
  "client": { "id": 21, "business_name": "Club Social Berisso" }
}
```

```bash
curl -X POST http://localhost:3000/api/v1/budgets/23/approve -H "Authorization: Bearer <token>"
```

```json
{
  "budget": {
    "id": 23, "version": 1, "status": "approved", "total": "1918200.00",
    "project": { "id": 14, "name": "Sitio del club" },
    "estimated_hours": "62.00",
    "modules": [
      { "name": "Relevamiento", "items": [ { "description": "Entrevistas con la comisión directiva", "estimated_hours": "6.00" } ] },
      { "name": "Web", "items": [ { "description": "Sitio institucional con agenda de actividades", "estimated_hours": "40.00" } ] }
    ]
  }
}
```

```bash
curl -X POST http://localhost:3000/api/v1/payments \
  -H "Authorization: Bearer <token>" -H "Content-Type: application/json" \
  -d '{"amount": "120000.00", "paid_on": "2026-09-29", "payment_method": "transfer"}'
```

### Errores

Siempre con el mismo formato:

```json
{ "error": { "status": 422, "message": "No se pudo guardar.", "details": ["Monto debe ser mayor que 0"] } }
```

| Código | Cuándo |
|---|---|
| 400 | Falta un parámetro o un filtro es inválido |
| 401 | Token ausente, inválido o de un usuario que no es cliente |
| 404 | El recurso no existe **o pertenece a otro cliente** |
| 422 | Error de validación o transición de estado no permitida |
| 429 | Demasiados intentos de login (10 cada 3 minutos) |

### Decisiones de diseño

- **Separación de contextos.** `Api::V1::BaseController` hereda de `ActionController::API`, no de `ApplicationController`:
  no usa cookies ni sesión y tiene sus propios controladores y vistas Jbuilder.
- **Scoping por cliente.** Toda consulta arranca en `current_client` (`current_client.projects.find(id)`), nunca en
  `Project.find(id)`. Un recurso ajeno da **404 y no 403**, para no confirmar que existe.
- **Sin datos internos.** La API no expone tarifas, costos, márgenes, horas por persona ni tareas no facturables.
  Los presupuestos en borrador tampoco son visibles para el cliente.
- **Token opaco** (`has_secure_token`) en lugar de JWT: se puede revocar en el servidor (logout rota el token) y no
  hace falta más para este caso. El mismo mensaje de error para contraseña incorrecta y para usuarios del equipo evita
  revelar qué emails existen.
- **Importes como string** con dos decimales (`"1918200.00"`) para no perder precisión en clientes que usan `float`.

## Calidad y seguridad

```bash
bin/rails test        # 59 tests: reglas de negocio, API y acceso al back-office
bin/rubocop           # sin infracciones
bin/brakeman          # 0 advertencias
bin/bundler-audit     # sin vulnerabilidades conocidas
```

Los tests cubren las reglas 1 a 17 (`test/models`), la autenticación y el scoping de la API (`test/controllers/api/v1`)
y el control de acceso del back-office (`test/controllers/admin`).

## Pendiente

- Active Storage: comprobante adjunto al pago y PDF firmado del presupuesto.
- Action Mailer: presupuesto enviado, aviso de decisión, recordatorio de vencimiento y aviso de mora.
- Active Job + Solid Queue: generación mensual de cuotas y marcado diario de vencidas (hoy se hacen desde el back-office).
- Vencimiento de sesiones del back-office por inactividad.
- Deploy.
