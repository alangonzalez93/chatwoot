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

Agregar dentro del bloque `namespace :api do namespace :v1 do resources :accounts do`:

```ruby
resource :example, only: [], controller: 'example' do
  collection do
    get :index
    post :create
    put :update
  end
end
```

**Ubicación:** Después de `resources :dashboard_apps` (línea ~109-115)

**❌ ERROR COMÚN:**
```ruby
# NO HACER ESTO - no sigue el patrón de Chatwoot
get 'example/index', to: 'example#index'
put 'example/update', to: 'example#update'
```

**Por qué:**
- No usa el patrón `resource` singular que es estándar en Chatwoot
- Rails puede no resolver correctamente el controller
- No es consistente con el resto de la codebase

**Verificar que genera las rutas correctas:**
- `GET /api/v1/accounts/:account_id/example/index`
- `POST /api/v1/accounts/:account_id/example/create`
- `PUT /api/v1/accounts/:account_id/example/update`

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

**`app/javascript/dashboard/i18n/locale/en/example.json`:**
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
  },
  "SIDEBAR": {
    "EXAMPLE": "Example"
  }
}
```

**`app/javascript/dashboard/i18n/locale/es/example.json`:**
```json
{
  "EXAMPLE": {
    "HEADER": "Configuración de Ejemplo",
    "DESCRIPTION": "Administra tu configuración de ejemplo",
    "API": {
      "ERROR": {
        "FETCH": "Error al cargar configuración",
        "UPDATE": "Error al actualizar configuración"
      },
      "SUCCESS": {
        "UPDATE": "Configuración actualizada exitosamente"
      }
    }
  },
  "SIDEBAR": {
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
