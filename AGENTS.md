# Chatwoot Development Guidelines

## Build / Test / Lint

- **Setup**: `bundle install && pnpm install`
- **Run Dev**: `pnpm dev` or `overmind start -f ./Procfile.dev`
- **Lint JS/Vue**: `pnpm eslint` / `pnpm eslint:fix`
- **Lint Ruby**: `bundle exec rubocop -a`
- **Test JS**: `pnpm test` or `pnpm test:watch`
- **Test Ruby**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Single Test**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- **Run Project**: `overmind start -f Procfile.dev`

## Code Style

- **Ruby**: Follow RuboCop rules (150 character max line length)
- **Vue/JS**: Use ESLint (Airbnb base + Vue 3 recommended)
- **Vue Components**: Use PascalCase
- **Events**: Use camelCase
- **I18n**: No bare strings in templates; use i18n
- **Error Handling**: Use custom exceptions (`lib/custom_exceptions/`)
- **Models**: Validate presence/uniqueness, add proper indexes
- **Type Safety**: Use PropTypes in Vue, strong params in Rails
- **Naming**: Use clear, descriptive names with consistent casing
- **Vue API**: Always use Composition API with `<script setup>` at the top

## Styling

- **Tailwind Only**:  
  - Do not write custom CSS  
  - Do not use scoped CSS  
  - Do not use inline styles  
  - Always use Tailwind utility classes  
- **Colors**: Refer to `tailwind.config.js` for color definitions

## General Guidelines

- MVP focus: Least code change, happy-path only
- No unnecessary defensive programming
- Break down complex tasks into small, testable units
- Iterate after confirmation
- Avoid writing specs unless explicitly asked
- Remove dead/unreachable/unused code
- Don’t write multiple versions or backups for the same logic — pick the best approach and implement it
- Don't reference Claude in commit messages

## Project-Specific

- **Translations**:
  - Only update `en.yml` and `en.json`
  - Other languages are handled by the community
  - Backend i18n → `en.yml`, Frontend i18n → `en.json`
- **Frontend**:
  - Use `components-next/` for message bubbles (the rest is being deprecated)

## Ruby Best Practices

- Use compact `module/class` definitions; avoid nested styles

## Enterprise Edition Notes

- Chatwoot has an Enterprise overlay under `enterprise/` that extends/overrides OSS code.
- When you add or modify core functionality, always check for corresponding files in `enterprise/` and keep behavior compatible.
- Follow the Enterprise development practices documented here:
  - https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38

Practical checklist for any change impacting core logic or public APIs
- Search for related files in both trees before editing (e.g., `rg -n "FooService|ControllerName|ModelName" app enterprise`).
- If adding new endpoints, services, or models, consider whether Enterprise needs:
  - An override (e.g., `enterprise/app/...`), or
  - An extension point (e.g., `prepend_mod_with`, hooks, configuration) to avoid hard forks.
- Avoid hardcoding instance- or plan-specific behavior in OSS; prefer configuration, feature flags, or extension points consumed by Enterprise.
- Keep request/response contracts stable across OSS and Enterprise; update both sets of routes/controllers when introducing new APIs.
- When renaming/moving shared code, mirror the change in `enterprise/` to prevent drift.
- Tests: Add Enterprise-specific specs under `spec/enterprise`, mirroring OSS spec layout where applicable.

---

# Guía Completa: Crear una Nueva Sección en Chatwoot (Dashboard Level)

Esta guía documenta el proceso completo para agregar una nueva sección al dashboard principal de Chatwoot, basada en la implementación de "Mileto Bot". Incluye todos los pasos necesarios, errores comunes a evitar, y patrones a seguir.

## Índice
1. [Estructura de Archivos](#estructura-de-archivos)
2. [Backend - Rails](#backend---rails)
3. [Frontend - Vue Router](#frontend---vue-router)
4. [Frontend - Componentes](#frontend---componentes)
5. [Sidebar Navigation](#sidebar-navigation)
6. [Traducciones (i18n)](#traducciones-i18n)
7. [Checklist Final](#checklist-final)
8. [Errores Comunes y Cómo Evitarlos](#errores-comunes-y-cómo-evitarlos)

---

## Estructura de Archivos

Para una nueva sección llamada `example`, crear la siguiente estructura:

```
app/
├── controllers/api/v1/accounts/
│   └── example_controller.rb
├── javascript/dashboard/
    ├── api/
    │   └── example.js
    ├── routes/dashboard/example/
    │   ├── Index.vue
    │   ├── Wrapper.vue
    │   └── example.routes.js
    ├── i18n/locale/
    │   ├── en/
    │   │   ├── example.json
    │   │   └── index.js (actualizar)
    │   └── es/
    │       ├── example.json
    │       └── index.js (actualizar)
    └── components-next/sidebar/
        └── Sidebar.vue (actualizar)
```

---

## Backend - Rails

### 1. Controller (`app/controllers/api/v1/accounts/example_controller.rb`)

**✅ PATRÓN CORRECTO:**

```ruby
class Api::V1::Accounts::ExampleController < Api::V1::Accounts::BaseController
  before_action :check_authorization

  def index
    # Tu lógica aquí
    render json: { data: 'example' }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Example API Error: #{e.message}")
    render json: { error: 'Failed to fetch data' }, status: :service_unavailable
  end

  private

  def check_authorization
    # IMPORTANTE: Usar este patrón para verificar permisos de administrador
    raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
  end
end
```

**❌ ERROR COMÚN:**
```ruby
# NO HACER ESTO - no funciona correctamente con Pundit
def check_authorization
  authorize Current.account, policy_class: AccountPolicy
end
```

**Por qué:** Pundit busca métodos como `index?` en la Policy, y si no existen, falla con error 500.

### 2. Routes (`config/routes.rb`)

**✅ PATRÓN CORRECTO:**

**HAY DOS PATRONES VÁLIDOS - elegir según el caso:**

#### Patrón A: Endpoints RESTful estándar (RECOMENDADO para CRUD)
Usar cuando tenés acciones estándar como `index`, `show`, `create`, `update`, `destroy`:

```ruby
resources :example, only: [:index, :show, :create, :update]
```

Genera:
- `GET /api/v1/accounts/:account_id/example` → `example#index`
- `GET /api/v1/accounts/:account_id/example/:id` → `example#show`
- `POST /api/v1/accounts/:account_id/example` → `example#create`
- `PUT /api/v1/accounts/:account_id/example/:id` → `example#update`

#### Patrón B: Endpoints custom (para acciones no-RESTful)
Usar cuando tenés acciones custom como `status`, `toggle`, `sync`:

```ruby
resource :example, only: [], controller: 'example' do
  collection do
    get :status
    put :toggle
  end
end
```

Genera:
- `GET /api/v1/accounts/:account_id/example/status` → `example#status`
- `PUT /api/v1/accounts/:account_id/example/toggle` → `example#toggle`

**Ubicación:** Después de `resources :dashboard_apps` (línea ~109-115)

**❌ ERROR COMÚN #1:**
```ruby
# NO HACER ESTO - mezclar patrones causa 404
resource :example, only: [], controller: 'example' do
  collection do
    get :index  # ← INCORRECTO: index es acción RESTful, usar resources
  end
end
```

**❌ ERROR COMÚN #2:**
```ruby
# NO HACER ESTO - no sigue ningún patrón
get 'example/index', to: 'example#index'
```

**❌ ERROR COMÚN #3:**
```ruby
# NUNCA hardcodear API keys en el código
request['X-API-Key'] = ENV.fetch('API_KEY', 'hardcoded-key-here')  # ← MAL

# CORRECTO: validar que exista
api_key = ENV['API_KEY']
raise 'API_KEY environment variable is not configured' if api_key.blank?
request['X-API-Key'] = api_key
```

---

## Frontend - Vue Router

### 1. Routes File (`app/javascript/dashboard/routes/dashboard/example/example.routes.js`)

**✅ PATRÓN CORRECTO:**

```javascript
import { frontendURL } from '../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/example'),
      name: 'example_wrapper',
      meta: {
        permissions: ['administrator'],
      },
      component: () => import('./Wrapper.vue'),
      children: [
        {
          path: '',
          name: 'example_index',
          meta: {
            permissions: ['administrator'],
          },
          component: () => import('./Index.vue'),
        },
      ],
    },
  ],
};
```

**IMPORTANTE:**
- El parent route tiene `name: 'example_wrapper'`
- El child route tiene `path: ''` y `name: 'example_index'`
- Ambos tienen `meta.permissions` si es necesario
- Se usan imports dinámicos con `() => import()`

### 2. Registrar en Dashboard Routes (`app/javascript/dashboard/routes/dashboard/dashboard.routes.js`)

**✅ PATRÓN CORRECTO:**

```javascript
// 1. Import al inicio del archivo
import exampleRoutes from './example/example.routes';

// 2. Spread dentro del array de children (línea ~33)
export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId'),
      component: AppContainer,
      children: [
        // ... otras rutas
        ...campaignsRoutes.routes,
        ...exampleRoutes.routes,  // ← Agregar aquí
      ],
    },
  ],
};
```

---

## Frontend - Componentes

### 1. Wrapper Component (`Wrapper.vue`)

**✅ PATRÓN CORRECTO:**

```vue
<template>
  <div class="flex flex-col justify-between flex-1 h-full m-0 overflow-auto bg-n-background px-6">
    <router-view v-slot="{ Component }">
      <component :is="Component" />
    </router-view>
  </div>
</template>

<script>
export default {
  name: 'ExampleSettingsWrapper',
};
</script>
```

**❌ ERROR COMÚN:**
```vue
<!-- NO HACER ESTO - causa problemas de navegación -->
<template>
  <div class="...">
    <router-view />
  </div>
</template>
```

**Por qué:**
- Vue Router 4+ requiere el patrón `v-slot="{ Component }"` para componentes dinámicos
- Sin esto, el componente no se renderiza correctamente al navegar desde otras secciones
- Solo funciona con refresh directo, no con navegación interna

**Referencias en el código:**
- `app/javascript/dashboard/routes/dashboard/campaigns/pages/CampaignsPageRouteView.vue`
- `app/javascript/dashboard/routes/dashboard/settings/SettingsWrapper.vue`
- `app/javascript/dashboard/routes/dashboard/settings/Wrapper.vue`

### 2. Index Component (`Index.vue`)

**✅ ESTRUCTURA RECOMENDADA:**

```vue
<template>
  <div class="py-4">
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-6">
        <h2 class="text-2xl font-semibold text-slate-900 dark:text-slate-100">
          {{ $t('EXAMPLE.HEADER') }}
        </h2>
      </div>

      <!-- Loading State -->
      <div v-if="uiFlags.isFetching" class="flex justify-center items-center py-12">
        <spinner size="large" />
      </div>

      <!-- Main Content -->
      <div v-else class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-4 sm:p-6">
        <!-- Tu contenido aquí -->
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner.vue';
import exampleAPI from '../../../api/example';
import { useAlert } from 'dashboard/composables';

export default {
  name: 'ExampleSettings',
  components: {
    Spinner,
  },
  data() {
    return {
      uiFlags: {
        isFetching: false,
      },
    };
  },
  computed: {
    ...mapGetters({
      currentAccountId: 'getCurrentAccountId',
      currentUser: 'getCurrentUser',
    }),
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.uiFlags.isFetching = true;
      try {
        const response = await exampleAPI.getData();
        // Procesar response
      } catch (error) {
        useAlert(this.$t('EXAMPLE.API.ERROR.FETCH'));
        console.error('Error fetching data:', error);
      } finally {
        this.uiFlags.isFetching = false;
      }
    },
  },
};
</script>
```

**IMPORTANTE - Clases de Layout:**
- Usar `py-4` en el div principal (no `flex-1 overflow-auto p-4`)
- Usar `max-w-4xl mx-auto` para centrar el contenido
- Seguir el patrón de responsive con `sm:` y `dark:` variants

**❌ ERROR COMÚN:**
```vue
<!-- NO HACER ESTO -->
<div class="flex-1 overflow-auto p-4">
```

**Por qué:** Causa conflictos con el overflow del Wrapper y puede dejar la pantalla vacía.

### 3. API Client (`app/javascript/dashboard/api/example.js`)

**✅ PATRÓN CORRECTO:**

```javascript
/* global axios */
import ApiClient from './ApiClient';

class ExampleAPI extends ApiClient {
  constructor() {
    super('example', { accountScoped: true });
  }

  /**
   * Get data
   * @returns {Promise} Promise object with data
   */
  getData() {
    return axios.get(`${this.url}/index`);
  }

  /**
   * Update data
   * @param {Object} data - Data to update
   * @returns {Promise} Promise object with response
   */
  updateData(data) {
    return axios.put(`${this.url}/update`, data);
  }
}

export default new ExampleAPI();
```

**IMPORTANTE:**
- Heredar de `ApiClient` con `{ accountScoped: true }`
- `this.url` genera automáticamente `/api/v1/accounts/:accountId/example`
- Agregar rutas adicionales como `${this.url}/status`, `${this.url}/toggle`, etc.
- **Verificar que los nombres de campos en el response coincidan con los que usás en el frontend**

**❌ ERROR COMÚN:**
```javascript
// Backend retorna: { botEnabled: true }
// Frontend lee:
this.enabled = response.data?.enabled || false; // ← INCORRECTO

// CORRECTO:
this.enabled = response.data?.botEnabled || false;
```

**Por qué:** Si los nombres de campos no coinciden, siempre obtendrás el valor default y el feature no funcionará.

### 4. Paneles/Modals Slide-in (IMPORTANTE)

Si tu sección incluye un panel lateral que se abre/cierra (como detalles de un item), **SIEMPRE usar el patrón con `<Transition>` component**.

**✅ PATRÓN CORRECTO para Panel Slide-in:**

```vue
<template>
  <Transition
    enter-active-class="transition-transform duration-300 ease-in-out"
    enter-from-class="ltr:translate-x-full rtl:-translate-x-full"
    enter-to-class="ltr:translate-x-0 rtl:-translate-x-0"
    leave-active-class="transition-transform duration-300 ease-in-out"
    leave-from-class="ltr:translate-x-0 rtl:-translate-x-0"
    leave-to-class="ltr:translate-x-full rtl:-translate-x-full"
  >
    <div
      v-if="isOpen"
      v-on-click-outside="[
        () => $emit('close'),
        { ignore: ['#panel-content-id'] }
      ]"
      id="panel-content-id"
      class="fixed top-0 ltr:right-0 rtl:left-0 h-full z-40 w-full max-w-md bg-n-background ltr:border-l rtl:border-r border-n-weak shadow-lg"
    >
      <!-- Contenido del panel -->
      <div class="overflow-y-auto h-full p-4">
        <!-- Tu contenido aquí -->
      </div>
    </div>
  </Transition>
</template>

<script>
import { vOnClickOutside } from '@vueuse/components';

export default {
  directives: {
    onClickOutside: vOnClickOutside,
  },
  props: {
    isOpen: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['close'],
};
</script>
```

**Elementos CRÍTICOS del patrón:**

1. **`<Transition>` wrapper** con classes de enter/leave explícitas
2. **`v-if="isOpen"` en el div interno**, NO en el Transition
3. **`v-on-click-outside` con opción `ignore`** usando array syntax: `[handler, { ignore: ['#id'] }]`
4. **`id` único en el contenedor** para referencia en la opción `ignore`
5. **NO usar `:class="isOpen ? ..."`** en el elemento raíz (la animación la maneja Transition)

**❌ ERRORES COMUNES - NUNCA HACER ESTO:**

```vue
<!-- ERROR #1: No usar Transition, usar :class directamente -->
<div
  v-on-click-outside="() => $emit('close')"
  :class="isOpen ? 'translate-x-0' : 'translate-x-full'"
>
  <!-- Contenido -->
</div>

<!-- ERROR #2: v-on-click-outside sin opción ignore -->
<div v-on-click-outside="() => $emit('close')">
  <!-- El click del botón que abre el panel se propaga y lo cierra inmediatamente -->
</div>

<!-- ERROR #3: v-if en Transition en lugar del contenido -->
<Transition v-if="isOpen">
  <div>
    <!-- Contenido -->
  </div>
</Transition>
```

**Por qué estos errores causan problemas:**

1. **Sin `<Transition>`**: El click del botón que abre el panel se propaga al `v-on-click-outside` y cierra el panel inmediatamente (~300ms después de abrir). No hay sincronización correcta entre el estado y la animación.

2. **Sin opción `ignore`**: Cualquier click, incluyendo el botón que abre el panel o clicks dentro del panel, disparan el evento de cierre.

3. **`v-if` en lugar equivocado**: Vue no puede manejar correctamente el ciclo de vida del componente durante las transiciones.

**Referencias de componentes que usan este patrón correctamente:**
- `app/javascript/dashboard/routes/dashboard/contacts/components/ContactsDetailsLayout.vue` (líneas 144-178)
- `app/javascript/dashboard/routes/dashboard/conversation/contact/ContactPanel.vue`
- `app/javascript/dashboard/components/widgets/conversation/ConversationSidebar.vue`

**Verificación Post-Implementación:**

Antes de hacer el build, verificar que el panel:
- [ ] Se abre con animación suave al hacer click en el botón
- [ ] El contenido se muestra completamente sin desaparecer
- [ ] Click dentro del panel NO lo cierra
- [ ] Click fuera del panel SÍ lo cierra
- [ ] El botón X cierra el panel con animación
- [ ] Se puede abrir/cerrar múltiples veces sin problemas

---

## Sidebar Navigation

**Ubicación:** `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`

**✅ PATRÓN CORRECTO:**

Agregar después del item de Settings (línea ~588):

```javascript
{
  name: 'Example',
  label: t('SIDEBAR.EXAMPLE'),
  icon: 'i-lucide-settings', // Elegir ícono de lucide
  to: accountScopedRoute('example_index'), // ← IMPORTANTE: apuntar a 'example_index', NO a 'example_wrapper'
  activeOn: ['example_wrapper', 'example_index'],
},
```

**❌ ERROR COMÚN:**
```javascript
// NO HACER ESTO
to: accountScopedRoute('example_wrapper'),
```

**Por qué:**
- El `to` debe apuntar a la ruta específica del contenido (`example_index`)
- `activeOn` incluye tanto wrapper como index para highlighting correcto
- Si apuntás al wrapper, la navegación puede no funcionar correctamente

**Referencias correctas en el código:**
- `campaigns_livechat_index` (no `campaigns_wrapper`)
- `settings_teams_list` (no `settings_wrapper`)
- `captain_assistants_index` (con params adicionales)

**Íconos disponibles:**
- Buscar en Lucide icons: https://lucide.dev/icons/
- Usar el prefijo `i-lucide-` seguido del nombre del ícono
- Ejemplos: `i-lucide-bot`, `i-lucide-settings`, `i-lucide-users`, `i-lucide-inbox`

---

## Traducciones (i18n)

### 1. Crear archivos de traducción

**⚠️ IMPORTANTE - NO incluir objeto SIDEBAR en archivos de módulo:**

Las traducciones del SIDEBAR deben estar SOLO en `settings.json`, NUNCA en los archivos de módulo individual.

**✅ CORRECTO - `app/javascript/dashboard/i18n/locale/en/example.json`:**
```json
{
  "EXAMPLE": {
    "HEADER": "Example Settings",
    "DESCRIPTION": "Manage your example settings",
    "API": {
      "ERROR": {
        "FETCH": "Failed to load settings",
        "UPDATE": "Failed to update settings"
      },
      "SUCCESS": {
        "UPDATE": "Settings updated successfully"
      }
    }
  }
}
```

**❌ INCORRECTO - NO hacer esto:**
```json
{
  "EXAMPLE": {
    "HEADER": "Example Settings",
    ...
  },
  "SIDEBAR": {
    "EXAMPLE": "Example"  // ← NUNCA agregar SIDEBAR aquí
  }
}
```

**Por qué:** Cuando se hace spread de las traducciones en `index.js`, si múltiples archivos definen el objeto `SIDEBAR`, el último spread reemplaza completamente el objeto anterior, eliminando todas las traducciones del sidebar existentes. Esto rompe TODA la navegación del sidebar.

**En su lugar, agregar traducciones de sidebar en `settings.json`:**

**`app/javascript/dashboard/i18n/locale/en/settings.json` (línea ~382):**
```json
{
  ...
  "SIDEBAR": {
    ...otras traducciones existentes...,
    "EXAMPLE": "Example"
  }
}
```

**`app/javascript/dashboard/i18n/locale/es/settings.json` (línea ~380):**
```json
{
  ...
  "SIDEBAR": {
    ...otras traducciones existentes...,
    "EXAMPLE": "Ejemplo"
  }
}
```

### 2. Registrar traducciones

**En `app/javascript/dashboard/i18n/locale/en/index.js`:**
```javascript
import example from './example.json';

export default {
  // ... otras traducciones
  ...example,
};
```

**En `app/javascript/dashboard/i18n/locale/es/index.js`:**
```javascript
import example from './example.json';

export default {
  // ... otras traducciones
  ...example,
};
```

**IMPORTANTE:**
- Solo actualizar `en.json` y `es.json` (según project guidelines)
- Otras traducciones las maneja la comunidad
- La estructura debe ser idéntica en ambos idiomas

---

## Checklist Final

Antes de hacer el build y deploy, verificar:

### Backend
- [ ] Controller creado en `app/controllers/api/v1/accounts/`
- [ ] Hereda de `Api::V1::Accounts::BaseController`
- [ ] `check_authorization` usa `raise Pundit::NotAuthorizedError unless`
- [ ] Rescue de errores con `StandardError => e`
- [ ] Routes agregadas en `config/routes.rb` usando `resource :example do collection do`
- [ ] Routes ubicadas dentro del bloque de `resources :accounts`

### Frontend - Routing
- [ ] Carpeta creada en `app/javascript/dashboard/routes/dashboard/example/`
- [ ] `example.routes.js` con estructura parent/child correcta
- [ ] Parent route tiene `name: 'example_wrapper'`
- [ ] Child route tiene `path: ''` y `name: 'example_index'`
- [ ] Imports dinámicos con `() => import()`
- [ ] Routes registradas en `dashboard.routes.js`

### Frontend - Componentes
- [ ] `Wrapper.vue` usa `<router-view v-slot="{ Component }">` + `<component :is="Component" />`
- [ ] `Index.vue` usa `py-4` (no `flex-1 overflow-auto`)
- [ ] `Index.vue` tiene loading states con `uiFlags.isFetching`
- [ ] API client hereda de `ApiClient` con `{ accountScoped: true }`
- [ ] Nombres de campos del response coinciden con el código frontend

### Frontend - Navigation
- [ ] Sidebar actualizado en `components-next/sidebar/Sidebar.vue`
- [ ] `to: accountScopedRoute('example_index')` apunta al index, NO al wrapper
- [ ] `activeOn: ['example_wrapper', 'example_index']` incluye ambas rutas
- [ ] Ícono correcto de Lucide con prefijo `i-lucide-`

### Frontend - i18n
- [ ] Archivos `en/example.json` y `es/example.json` creados
- [ ] Traducciones registradas en `en/index.js` y `es/index.js`
- [ ] Estructura de traducciones idéntica en ambos idiomas
- [ ] Todas las strings del template usan `$t('EXAMPLE.KEY')`

### Testing Manual
- [ ] Build local exitoso sin errores de compilación
- [ ] Navegación desde otras secciones funciona (sin refresh)
- [ ] Navegación directa a la URL funciona
- [ ] Loading states se muestran correctamente
- [ ] API calls funcionan correctamente
- [ ] Permisos se verifican correctamente (solo admin puede acceder)
- [ ] Responsive design funciona en mobile
- [ ] Dark mode funciona correctamente

---

## Errores Comunes y Cómo Evitarlos

### 1. ❌ Error 404 en API endpoint

**Síntoma:** `GET /api/v1/accounts/1/example/status 404 (Not Found)`

**Causas posibles:**
- Routes no siguen el patrón `resource :example do collection do`
- Controller no está en la ubicación correcta
- Typo en el nombre del controller o rutas

**Solución:**
```ruby
# En config/routes.rb
resource :example, only: [], controller: 'example' do
  collection do
    get :status
  end
end
```

### 2. ❌ Error 500 en API endpoint

**Síntoma:** `GET /api/v1/accounts/1/example/status 500 (Internal Server Error)`

**Causas posibles:**
- `check_authorization` usa `authorize Current.account` sin método en Policy
- Error en la lógica del controller
- Variable de entorno faltante

**Solución:**
```ruby
# En el controller
def check_authorization
  raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
end
```

### 3. ❌ Pantalla vacía al navegar desde otras secciones

**Síntoma:** La pantalla queda vacía al hacer click en el sidebar, pero funciona con refresh

**Causas posibles:**
- Wrapper usa `<router-view />` sin el patrón `v-slot`
- Sidebar apunta a `example_wrapper` en lugar de `example_index`

**Solución:**
```vue
<!-- Wrapper.vue -->
<router-view v-slot="{ Component }">
  <component :is="Component" />
</router-view>
```

```javascript
// Sidebar.vue
to: accountScopedRoute('example_index'), // NO 'example_wrapper'
```

### 4. ❌ Datos no se cargan correctamente

**Síntoma:** `this.enabled` siempre es `false` aunque el API retorna `true`

**Causa:** Nombres de campos no coinciden entre backend y frontend

**Solución:**
```javascript
// Backend retorna: { botEnabled: true }
// Frontend debe leer:
this.enabled = response.data?.botEnabled || false; // ← Usar el nombre correcto
```

### 5. ❌ Imports relativos incorrectos

**Síntoma:** `Could not resolve "../../../../api/example"`

**Causa:** Cambio en la profundidad de directorios

**Solución:**
- Contar niveles desde el componente hasta `dashboard/`
- Desde `dashboard/routes/dashboard/example/Index.vue` son 3 niveles: `../../../api/example`
- Verificar la estructura de directorios antes de cambiar rutas

### 6. ❌ Traducciones no aparecen

**Síntoma:** `{{ $t('EXAMPLE.HEADER') }}` se muestra literal en el template

**Causas posibles:**
- Archivo de traducción no importado en `index.js`
- Typo en la key de traducción
- Estructura JSON incorrecta

**Solución:**
```javascript
// en/index.js y es/index.js
import example from './example.json';

export default {
  ...example, // ← No olvidar el spread
};
```

### 6.5. ❌ Todas las traducciones del sidebar se rompieron después de agregar nueva sección

**Síntoma:** Después de agregar una nueva sección, todos los botones del sidebar muestran nombres de variables (ej: `SIDEBAR.SETTINGS`, `SIDEBAR.CONTACTS`) en lugar de los textos traducidos. Solo la nueva sección muestra el texto correcto.

**Causa:** El archivo de traducción del nuevo módulo (`example.json`) define un objeto `SIDEBAR` que reemplaza completamente el objeto `SIDEBAR` de `settings.json` durante el spread.

**Qué pasó:**
```javascript
// en/index.js
export default {
  ...settings,    // SIDEBAR con 50+ traducciones
  ...example,     // SIDEBAR con solo 1 traducción - ¡REEMPLAZA el anterior!
};
```

**Solución:**
1. **ELIMINAR** el objeto `SIDEBAR` de `en/example.json` y `es/example.json`
2. **AGREGAR** la traducción en `en/settings.json` y `es/settings.json`:

```json
// en/settings.json
{
  "SIDEBAR": {
    ...todas las traducciones existentes...,
    "EXAMPLE": "Example"  // ← Agregar aquí
  }
}
```

**Regla absoluta:** NUNCA definir objeto `SIDEBAR` en archivos de módulo individuales, SOLO en `settings.json`.

### 7. ❌ Layout roto o contenido cortado

**Síntoma:** El contenido no se ve completo, hay scrolling extraño

**Causa:** Clases de Tailwind conflictivas en Index.vue

**Solución:**
```vue
<!-- CORRECTO -->
<div class="py-4">
  <div class="max-w-4xl mx-auto">
    <!-- contenido -->
  </div>
</div>

<!-- INCORRECTO -->
<div class="flex-1 overflow-auto p-4"> <!-- ← Evitar esto -->
```

### 8. ❌ Permisos no funcionan correctamente

**Síntoma:** Usuarios no-admin pueden acceder a la sección

**Causa:** `meta.permissions` no configurado o `check_authorization` faltante

**Solución:**
```javascript
// En routes
meta: {
  permissions: ['administrator'],
}

// En controller
def check_authorization
  raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
end
```

### 9. ❌ Panel slide-in se abre y desaparece inmediatamente

**Síntoma:** Al hacer click en un botón para abrir un panel lateral, el panel aparece brevemente (~300ms) y luego desaparece automáticamente. El contenido se ve por un momento pero no se puede interactuar con él.

**Causa:** Event propagation del click del botón hacia el `v-on-click-outside` del panel. El patrón incorrecto con `:class` en lugar de `<Transition>` no maneja correctamente el ciclo de vida del componente.

**Código problemático:**
```vue
<!-- ❌ INCORRECTO -->
<div
  v-on-click-outside="() => $emit('close')"
  :class="isOpen ? 'translate-x-0' : 'translate-x-full'"
  class="fixed ... transition-transform"
>
  <!-- contenido -->
</div>
```

**Solución:**
```vue
<!-- ✅ CORRECTO -->
<Transition
  enter-active-class="transition-transform duration-300 ease-in-out"
  enter-from-class="ltr:translate-x-full rtl:-translate-x-full"
  enter-to-class="ltr:translate-x-0 rtl:-translate-x-0"
  leave-active-class="transition-transform duration-300 ease-in-out"
  leave-from-class="ltr:translate-x-0 rtl:-translate-x-0"
  leave-to-class="ltr:translate-x-full rtl:-translate-x-full"
>
  <div
    v-if="isOpen"
    v-on-click-outside="[
      () => $emit('close'),
      { ignore: ['#panel-content-id'] }
    ]"
    id="panel-content-id"
    class="fixed ..."
  >
    <!-- contenido -->
  </div>
</Transition>
```

**Cambios clave:**
1. Envolver en `<Transition>` con enter/leave classes
2. Mover `v-if="isOpen"` al div interno
3. Agregar `id` único al contenedor
4. Usar array syntax en `v-on-click-outside` con opción `ignore`
5. Eliminar `:class="isOpen ? ..."` (ahora lo maneja Transition)

Ver sección **"4. Paneles/Modals Slide-in"** arriba para el patrón completo.

### 10. ❌ Error de sintaxis en build: "Element is missing end tag"

**Síntoma:** El build de Vite falla con error como:
```
[vite:vue] app/javascript/.../Component.vue (10:5): Element is missing end tag.
```

**Causa:** Falta cerrar un `</div>` en el template Vue. Esto suele pasar cuando se refactoriza código y se agregan/quitan niveles de anidación.

**Cómo debuggear:**
1. Ir a la línea indicada en el error
2. Contar todos los `<div>` que abren vs todos los `</div>` que cierran
3. Verificar que cada apertura tenga su cierre correspondiente
4. Prestar especial atención a divs con `v-if`, `v-for`, o condicionales

**Tip:** Usar el auto-formatter del IDE (en VSCode: Shift+Alt+F) para identificar problemas de indentación que sugieren tags sin cerrar.

---

## Patrones de Referencia

Cuando tengas dudas, revisar estos componentes como referencia:

### Para Wrappers simples:
- `app/javascript/dashboard/routes/dashboard/settings/SettingsWrapper.vue`
- `app/javascript/dashboard/routes/dashboard/campaigns/pages/CampaignsPageRouteView.vue`

### Para Routes:
- `app/javascript/dashboard/routes/dashboard/settings/teams/teams.routes.js`
- `app/javascript/dashboard/routes/dashboard/settings/auditlogs/audit.routes.js`

### Para Controllers:
- `app/controllers/api/v1/accounts/campaigns_controller.rb`
- `app/controllers/api/v1/accounts/oauth_authorization_controller.rb`

### Para API Clients:
- `app/javascript/dashboard/api/ApiClient.js`
- Cualquier API client en `app/javascript/dashboard/api/`

### Para Backend Routes:
- Buscar patrones en `config/routes.rb` líneas 110-115 (donde están los resources dentro de accounts)

---

## Notas Finales

- **Siempre revisar ejemplos existentes** en el codebase antes de implementar
- **No adivinar patrones** - verificar cómo lo hace Chatwoot en componentes similares
- **Testear build localmente** antes de hacer push a producción
- **Los builds toman tiempo** - asegurarse de que todo esté correcto antes de ejecutar
- **Documentar cambios** si agregás algo no estándar

Esta guía debe ser consultada **SIEMPRE** antes de crear una nueva sección en Chatwoot.
