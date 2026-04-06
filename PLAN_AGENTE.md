# Plan de Implementación — Funcionalidad AGENTE

## Contexto
Sistema de fidelización Puntos (Rails 7.2). Se permite marcar clientes como AGENTE para asignación diferenciada de puntos. Los clientes pasan a llamarse BENEFICIARIOS en la UI (solo presentación, modelo sigue siendo Customer).

## Fase 1 (COMPLETADA)
- [x] Migración: `category` en customers (enum: cliente/agente)
- [x] Migración: `conversion_agent` en branch_settings (inicializado copiando conversion)
- [x] Migración: tabla `agent_requests` (customer_id, branch_id, user_id, status: pending/approved/cancelled)
- [x] Modelo `AgentRequest` con validaciones y scopes
- [x] Customer: enum category, relación `has_many :agent_requests`
- [x] BranchSetting: `default_value` para conversion_agent
- [x] Branch: método `today_conversion_agent`
- [x] Ability: permisos AgentRequest por rol
- [x] routes.rb: `resources :agent_requests` con cancel/approve/filter
- [x] branch_settings_controller: conversion_agent en params permitidos
- [x] branches_controller: conversion_agent en create de branch_settings

---

## Orden de ejecución: 3 → 6 → 2 → 4 → 5 → 7 → 8 → 9

---

### Paso 1: Columna Puntos AGENTE en Configuración de Sucursal (ex-Fase 3)

Archivos:
- `app/views/branch_settings/index.html.erb` — Agregar columna "Puntos AGENTE" con inline_edit para conversion_agent
- `app/controllers/branches_controller.rb` — Modificar `today_settings` para retornar `conversion_agent`
- `app/controllers/branch_settings_controller.rb` — Verificar params permitidos (ya hecho)
- `app/controllers/branches_controller.rb` — Verificar creación (ya hecho)

Tareas:
- [ ] 1.1 Agregar columna "Puntos AGENTE" en tabla Puntos/Descuento de branch_settings/index.html.erb
- [ ] 1.2 Verificar que branch_settings_controller ya tiene conversion_agent en params (ya hecho en Fase 1)
- [ ] 1.3 Verificar que branches_controller ya inicializa conversion_agent al crear sucursal (ya hecho en Fase 1)
- [ ] 1.4 Testear edición inline de conversion_agent en browser

---

### Paso 2: Renombramiento CLIENTE → BENEFICIARIO (ex-Fase 6) ~47 archivos

**Principio**: Solo vistas y locales. No se tocan modelos, rutas, ni controladores.

Tareas:
- [ ] 2.1 Modificar `config/locales/es.yml` (7 refs: customer→Beneficiario, customers→Beneficiarios, etc.)
- [ ] 2.2 Modificar `app/views/customers/index.html.erb` — "Clientes"→"Beneficiarios", "Nuevo Cliente"→"Nuevo Beneficiario", "Todos los clientes"→"Todos los Beneficiarios"
- [ ] 2.3 Modificar `app/views/customers/show.html.erb` — "Cliente"→"Beneficiario"
- [ ] 2.4 Modificar `app/views/customers/edit.html.erb` — "Editar Cliente"→"Editar Beneficiario"
- [ ] 2.5 Modificar `app/views/customers/new.html.erb` — "Nuevo Cliente"→"Nuevo Beneficiario"
- [ ] 2.6 Modificar `app/views/customers/new_customer_wizard.html.erb` — "Nuevo Cliente"→"Nuevo Beneficiario"
- [ ] 2.7 Modificar `app/views/customers/_wizard_step_3.html.erb` — "Alta de cliente"→"Alta de beneficiario"
- [ ] 2.8 Modificar `app/views/customers/_table_customers.html.erb` — th "Cliente"→"Beneficiario"
- [ ] 2.9 Modificar `app/views/customers/_customer.html.erb` — "CLIENTE DE"→"BENEFICIARIO DE", "NO ES CLIENTE AUN"→"NO ES BENEFICIARIO AUN"
- [ ] 2.10 Modificar `app/views/customers/_form_current_account.html.erb` — "CLIENTE:"→"BENEFICIARIO:"
- [ ] 2.11 Modificar `app/views/customers/search_person_customer.turbo_stream.erb` — "Agregar cliente"→"Agregar beneficiario"
- [ ] 2.12 Modificar `app/views/shared/left_sidebar/_customers_section.html.erb` — "Clientes"→"Beneficiarios", "Alta de Clientes"→"Alta de Beneficiarios"
- [ ] 2.13 Modificar `app/views/shared/_enable_client.html.erb` — "Desactivar Cliente"→"Desactivar Beneficiario", "Activar Cliente"→"Activar Beneficiario"
- [ ] 2.14 Modificar `app/views/search_person/_data_customer.html.erb` — "CLIENTE DE"→"BENEFICIARIO DE", "NO ES CLIENTE AUN"→"NO ES BENEFICIARIO AUN"
- [ ] 2.15 Modificar `app/views/search_person/_customer.html.erb` — "YA ES CLIENTE"→"YA ES BENEFICIARIO", "NO ES CLIENTE AUN"→"NO ES BENEFICIARIO AUN"
- [ ] 2.16 Modificar `app/views/search_person/_link_add_customer.html.erb` — "Agregar Cliente"→"Agregar Beneficiario"
- [ ] 2.17 Modificar `app/views/movements/_link_add_customer.html.erb` — "Agregar Cliente"→"Agregar Beneficiario"
- [ ] 2.18 Modificar `app/views/movements/_filter_movements.html.erb` — "Nombre de Cliente"→"Nombre de Beneficiario"
- [ ] 2.19 Modificar `app/views/movements/_table_movements.html.erb` — th "Cliente"→"Beneficiario"
- [ ] 2.20 Modificar `app/views/movements/show.html.erb` — "CLIENTE:"→"BENEFICIARIO:"
- [ ] 2.21 Modificar `app/views/movements/_product_exchange_form.html.erb` — "puntos del cliente"→"puntos del beneficiario"
- [ ] 2.22 Modificar `app/views/qr_code/_customer.html.erb` — "YA ES CLIENTE"→"YA ES BENEFICIARIO", "NO ES CLIENTE AUN"→"NO ES BENEFICIARIO AUN"
- [ ] 2.23 Modificar `app/views/qr_branches/_customer.html.erb` — igual
- [ ] 2.24 Modificar `app/views/qr_branches/_customer_result.html.erb` — "CLIENTE DE"→"BENEFICIARIO DE", "NO ES CLIENTE AUN"→"NO ES BENEFICIARIO AUN"
- [ ] 2.25 Modificar `app/views/qr_branches/all_qr_branch.html.erb` — "Registrar Clientes"→"Registrar Beneficiarios", nombre archivo descarga
- [ ] 2.26 Modificar `app/views/companies/show.html.erb` — "Clientes"→"Beneficiarios"
- [ ] 2.27 Modificar `app/views/companies/all_qr_company.html.erb` — "Registrar Clientes"→"Registrar Beneficiarios", nombre archivo
- [ ] 2.28 Modificar `app/views/companies/_list_movements.html.erb` — "Cliente"→"Beneficiario"
- [ ] 2.29 Modificar `app/views/pages/general_data.html.erb` — "Cantidad Total de Clientes Activos"→"Beneficiarios Activos", "Clientes Dormidos"→"Beneficiarios Dormidos"
- [ ] 2.30 Modificar `app/views/pages/dashboard.html.erb` — comentarios y headings
- [ ] 2.31 Modificar `app/views/pages/dashboard_elements/_customer_graphs.html.erb` — "CLIENTES MASCULINOS"→"BENEFICIARIOS MASCULINOS", etc.
- [ ] 2.32 Modificar `app/views/pages/dashboard_elements/_customer_ranking.html.erb` — "TOP 10 MEJORES CLIENTES"→"TOP 10 MEJORES BENEFICIARIOS"
- [ ] 2.33 Modificar `app/views/people/_form_balance.html.erb` — "CLIENTE:"→"BENEFICIARIO:"
- [ ] 2.34 Modificar `app/views/branch_settings/_alert_settings.html.erb` — "clientes que realizaron"→"beneficiarios que realizaron"
- [ ] 2.35 Modificar `app/views/company_settings/index.html.erb` — "clientes que realizaron"→"beneficiarios que realizaron", "Clientes dormidos"→"Beneficiarios dormidos"
- [ ] 2.36 Modificar `app/views/companies/show_days_sleep.html.erb` — "dormir clientes"→"dormir beneficiarios"
- [ ] 2.37 Modificar `app/views/branches/_form.html.erb` — "clientes dormidos"→"beneficiarios dormidos"
- [ ] 2.38 Modificar comentarios HTML en: `_wizard_step_1`, `query_customer`, `new_customer_external` (qr_branches y qr_code), `_form` (movements), `_form_movement` (groups), `search_person_customer.turbo_stream.erb` (qr_branches), `_items_left_side.html.erb`
- [ ] 2.39 Verificar visualmente que todos los textos dicen "Beneficiario/Beneficiarios"

---

### Paso 3: AgentRequestsController + Vistas "Alta de Agente" (ex-Fase 2)

Archivos nuevos:
- `app/controllers/agent_requests_controller.rb`
- `app/views/agent_requests/index.html.erb`
- `app/views/agent_requests/_table_agent_requests.html.erb`
- `app/views/agent_requests/filter_agent_requests.js.erb`
- `app/helpers/agent_requests_helper.rb`

Archivos modificados:
- `app/javascript/modules/datatables.js` — Agregar `agent-requests-table`

Tareas:
- [ ] 3.1 Crear `app/controllers/agent_requests_controller.rb`
  - `index`: lista solicitudes del company/branch actual, ordenadas pending_first
  - `create`: crea AgentRequest (customer_id, branch_id=current_branch, user_id=current_user)
  - `cancel`: member action, verifica status_pending?, actualiza a cancelled
  - `approve`: member action, verifica status_pending?, cambia customer.category a :agente, actualiza request a approved
  - `filter_agent_requests`: filtra por status, branch, fecha. Responde JS
- [ ] 3.2 Crear `app/helpers/agent_requests_helper.rb`
  - `get_badges_agent_request_status(request)` — badge Bootstrap según status (pending=warning, approved=success, cancelled=secondary)
- [ ] 3.3 Crear `app/views/agent_requests/index.html.erb`
  - Card + filter form (status select, fecha desde/hasta) + tabla con columnas: Cajero, Beneficiario, Documento, Sucursal, Fecha, Estado, Acciones
  - Botón "Convertir en AGENTE" por fila (solo si pending y can?(:approve, request))
- [ ] 3.4 Crear `app/views/agent_requests/_table_agent_requests.html.erb`
- [ ] 3.5 Crear `app/views/agent_requests/filter_agent_requests.js.erb`
  - Reemplaza `#table-agent-requests` y llama `initializeTables()`
- [ ] 3.6 Agregar entrada `agent-requests-table` en `app/javascript/modules/datatables.js`
- [ ] 3.7 Testear: ver listado, filtrar, aprobar solicitud, cancelar solicitud

---

### Paso 4: Botones Cajero — Solicitud AGENTE (ex-Fase 4)

**Botón aparece en la card del cliente** (`_data_customer.html.erb`)

3 estados del botón:
1. **Sin solicitud pendiente y no es agente**: Botón "Solicitud AGENTE" (btn-outline-warning) → POST /agent_requests
2. **Solicitud pendiente**: Botón "Cancelar Solicitud AGENTE" (btn-outline-danger) → POST /agent_requests/:id/cancel
3. **Ya es agente**: Insignia `<span class="badge bg-warning">BENEFICIARIO AGENTE</span>` (solo lectura)

Archivos nuevos:
- `app/views/agent_requests/_agent_button.html.erb` — Partial con lógica de 3 estados
- `app/views/agent_requests/create.turbo_stream.erb` — Respuesta turbo al crear solicitud
- `app/views/agent_requests/cancel.turbo_stream.erb` — Respuesta turbo al cancelar

Archivos modificados:
- `app/views/search_person/_data_customer.html.erb` — Renderizar partial agent_button
- `app/views/search_person/return_person_movement.turbo_stream.erb` — Pasar agent_request al partial

Tareas:
- [ ] 4.1 Crear `app/views/agent_requests/_agent_button.html.erb` con 3 estados
- [ ] 4.2 Modificar `app/views/search_person/_data_customer.html.erb` — Agregar render del partial
- [ ] 4.3 Modificar `app/views/search_person/return_person_movement.turbo_stream.erb` — Pasar datos de agent_request
- [ ] 4.4 Crear `app/views/agent_requests/create.turbo_stream.erb`
- [ ] 4.5 Crear `app/views/agent_requests/cancel.turbo_stream.erb`
- [ ] 4.6 Testear flujo: botón solicitud → crear → cancelar → insignia agente

---

### Paso 5: Sidebar ALTA DE AGENTE (ex-Fase 5)

Archivos nuevos:
- `app/views/shared/left_sidebar/_agent_requests_section.html.erb`

Archivos modificados:
- `app/helpers/sidebar_helper.rb` — Agregar métodos
- `app/views/shared/_items_left_side.html.erb` — Renderizar partial

Tareas:
- [ ] 5.1 Agregar en `app/helpers/sidebar_helper.rb`:
  - `show_agent_requests?` — visible si can?(:access, AgentRequest) y hay company o branch
  - `pending_agent_requests_count` — conteo de pendientes
  - `show_agent_requests_badge?` — badge si hay pendientes
- [ ] 5.2 Crear `app/views/shared/left_sidebar/_agent_requests_section.html.erb`
  - Link a `agent_requests_path` con icono `mdi-account-star`
  - Badge con conteo de pendientes (igual que alerts_branch_section)
- [ ] 5.3 Modificar `app/views/shared/_items_left_side.html.erb` — Agregar render del partial después de Alertas
- [ ] 5.4 Testear visibilidad según roles (basic ve sidebar?, manager ve badge?)

---

### Paso 6: Conversión Automática Agentes (parte de ex-Fase 3)

El sistema detecta `customer.category == 'agente'` y usa `conversion_agent` en lugar de `conversion` tanto en frontend (JS) como backend.

Archivos modificados:
- `app/controllers/branches_controller.rb` — `today_settings` retornar `conversion_agent`
- `app/javascript/controllers/movements_controller.js` — Leer conversion_agent, usarla si customer es agente
- `app/controllers/movements_controller.rb` — `validate_common_data` usar conversion_agent si agente
- `app/views/movements/_nav_link_movement.html.erb` — Pasar `data-customer-is-agent`
- `app/views/search_person/return_person_movement.turbo_stream.erb` — Pasar flag

Tareas:
- [ ] 6.1 Modificar `app/controllers/branches_controller.rb#today_settings` — Agregar `conversion_agent` al JSON
- [ ] 6.2 Modificar `app/javascript/controllers/movements_controller.js`
  - `getBranchSetting()`: guardar `conversionAgentParam` del response
  - `updateValues()`: si customer es agente, usar `conversionAgentParam` en vez de `conversionParam`
  - Agregar `data-customer-is-agent` target o leer del dataset del elemento
- [ ] 6.3 Modificar `app/views/movements/_nav_link_movement.html.erb` — Agregar `data-customer-is-agent="<%= customer.agente? %>"` al div del controller
- [ ] 6.4 Modificar `app/controllers/movements_controller.rb#validate_common_data`
  - Si `data[:customer].category_agente?` → usar `branch_setting.conversion_agent`
- [ ] 6.5 Testear: movimiento con cliente normal usa conversion, con agente usa conversion_agent

---

### Paso 7: Columna Categoría + Filtros + Toggle (ex-Fase 7)

**Toggle con modal de confirmación** (igual que _enable_client.html.erb)

Archivos nuevos:
- `app/views/customers/_change_category_modal.html.erb` — Modal Bootstrap de confirmación

Archivos modificados:
- `app/helpers/customers_helper.rb` — Agregar `get_badges_customer_category`
- `app/views/customers/_table_customers.html.erb` — Columna "Tipo de Beneficiario"
- `app/views/customers/index.html.erb` — Filtro categoría + fix "Todos los Estados"
- `app/controllers/customers_controller.rb` — Filtro categoría + acción change_category
- `app/views/customers/show.html.erb` — Campo categoría + botón toggle
- `config/routes.rb` — Ruta change_category

Tareas:
- [ ] 7.1 Agregar `get_badges_customer_category(customer)` en `app/helpers/customers_helper.rb`
  - Agente → badge warning "AGENTE", Cliente → badge primary "CLIENTE"
- [ ] 7.2 Modificar `app/views/customers/_table_customers.html.erb`
  - Agregar columna "Tipo de Beneficiario" (entre Nombre y Estado)
- [ ] 7.3 Modificar `app/views/customers/index.html.erb`
  - Agregar select "Tipo de Beneficiario" con opciones: "Todos Beneficiarios", "Clientes", "Agentes"
  - Cambiar prompt de estado: "Todos los clientes" → "Todos los Estados"
- [ ] 7.4 Modificar `app/controllers/customers_controller.rb#filter_customers`
  - Agregar filtro por `params[:customer_category]`
- [ ] 7.5 Crear `app/views/customers/_change_category_modal.html.erb`
  - Modal Bootstrap con confirmación para cambiar categoría
  - Usa `button_to` hacia `change_category_customer_path`
- [ ] 7.6 Modificar `app/views/customers/show.html.erb`
  - Agregar row "Categoría" con badge + botón toggle (solo si can?(:enable_client, @customer))
- [ ] 7.7 Agregar ruta y acción en `config/routes.rb` y `app/controllers/customers_controller.rb`
  - `patch 'change_category'` en el resources :customers
  - Acción que togglea customer.category entre :cliente y :agente
- [ ] 7.8 Testear filtros, tabla con columna nueva, toggle de categoría

---

### Paso 8: Indicadores Agentes (ex-Fase 8)

Archivos nuevos:
- `app/views/pages/dashboard_elements/_agent_ranking.html.erb` — Top 10 Agentes (tabs mensual/histórico)

Archivos modificados:
- `app/helpers/pages_helper.rb` — Métodos para agentes
- `app/views/pages/general_data.html.erb` — Card "Cantidad de Agentes"
- `app/views/pages/periodic_data.html.erb` — Card "Puntos Mensuales Agentes"
- `app/views/pages/dashboard.html.erb` — Incluir partial agent_ranking

Tareas:
- [ ] 8.1 Agregar métodos en `app/helpers/pages_helper.rb`:
  - `get_count_agent_customers(customers)` — count where category: :agente
  - `get_agent_monthly_points(movements, customers)` — puntos mensuales de agentes
  - `get_monthly_top_ten_agents(customers, company)` — top 10 agentes mensual
  - `get_history_top_ten_agents(customers, company)` — top 10 agentes histórico
- [ ] 8.2 Modificar `app/views/pages/general_data.html.erb`
  - Agregar card: "Cantidad de Agentes Activos" con icono `mdi-account-star`
- [ ] 8.3 Modificar `app/views/pages/periodic_data.html.erb`
  - Agregar card: "Puntos Mensuales de Agentes"
- [ ] 8.4 Crear `app/views/pages/dashboard_elements/_agent_ranking.html.erb`
  - Tabla con tabs (mensual/histórico) igual que `_customer_ranking.html.erb`
  - Columnas: Nombre, Comercio, Monto
- [ ] 8.5 Modificar `app/views/pages/dashboard.html.erb`
  - Incluir `<%= render partial: 'pages/dashboard_elements/agent_ranking' %>`
- [ ] 8.6 Verificar que `app/controllers/pages_controller.rb` pasa datos necesarios para agentes
- [ ] 8.7 Testear indicadores en browser

---

### Paso 9: "Todas las sucursales" (ex-Fase 9)

Archivos modificados:
- `app/views/pages/select_branch.html.erb`

Tareas:
- [ ] 9.1 Modificar `app/views/pages/select_branch.html.erb` línea 16
  - Cambiar `TODAS` → `TODAS LAS SUCURSALES`
- [ ] 9.2 Testear selección de sucursal

---

## Notas Técnicas

### Modelo de datos actual (ya existente de Fase 1)
```
customers.category: enum { cliente: 'CLIENTE', agente: 'AGENTE' }
branch_settings.conversion_agent: float, default: 0.0
agent_requests: customer_id, branch_id, user_id, status (pending/approved/cancelled)
```

### Rutas ya definidas (Fase 1)
```ruby
resources :agent_requests do
  member do
    post 'cancel'
    post 'approve'
  end
  collection do
    post :filter_agent_requests
  end
end
```

### Permisos ya definidos (Fase 1)
- **Basic**: create, cancel AgentRequest
- **Manager/Owner/Intermediate**: create, access, index, approve AgentRequest
- **Admin**: manage all

### Patrones a seguir
- **Filtros**: POST → JS response → reemplaza div tabla → `initializeTables()`
- **Inline edit**: Turbo Frame con `_inline_edit` y `_inline_field` partials
- **Modales**: Bootstrap modal con `button_to` (ver `_enable_client.html.erb`)
- **Badges**: Helper methods retornando `html_safe` Bootstrap badges
- **DataTables**: Agregar entry en `datatables.js` con destroy-before-cache pattern
- **Sidebar**: Partial en `shared/left_sidebar/` + helper method en `sidebar_helper.rb` + render en `_items_left_side.html.erb`
