# 🎨 Guía de Personalización de Colores - Mileto

## Colores Principales de Chatwoot

Chatwoot usa un sistema de colores basado en Tailwind CSS y variables CSS personalizadas.

### Color Principal (Brand)

El color principal que se usa en:
- Botones primarios
- Links
- Elementos destacados
- Íconos activos

**Ubicación:** `theme/colors.js` línea 214

```javascript
brand: '#2781F6',  // Azul Chatwoot por defecto
```

### Paleta de Colores Completa

#### 1. Colores de Marca (woot)
**Archivo:** `theme/colors.js` líneas 17-30

```javascript
woot: {
  25: blue.blue2,   // Muy claro
  50: blue.blue3,
  100: blue.blue5,
  200: blue.blue7,
  300: blue.blue8,
  400: blueDark.blue11,
  500: blueDark.blue10,  // Principal
  600: blueDark.blue9,
  700: blueDark.blue8,
  800: blueDark.blue6,
  900: blueDark.blue2,   // Muy oscuro
}
```

## 📝 Ejemplos de Cambio de Color

### Ejemplo 1: Cambiar a Verde (#10B981)

```javascript
// theme/colors.js línea 214
brand: '#10B981',  // Verde
```

### Ejemplo 2: Cambiar a Morado (#8B5CF6)

```javascript
brand: '#8B5CF6',  // Morado
```

### Ejemplo 3: Cambiar a Naranja (#F97316)

```javascript
brand: '#F97316',  // Naranja
```

### Ejemplo 4: Color personalizado de Mileto

```javascript
brand: '#TU_COLOR_AQUI',  // Reemplaza con tu color
```

## 🎯 Cómo Aplicar los Cambios

### Paso 1: Editar el archivo de colores

```bash
# Edita theme/colors.js
# Cambia la línea 214:
brand: '#TU_COLOR',
```

### Paso 2: (Opcional) Cambiar paleta woot completa

Si quieres cambiar toda la paleta de azul a tu color:

```javascript
// Opción simple: usar colores personalizados
woot: {
  25: '#F0F9FF',   // Muy claro
  50: '#E0F2FE',
  100: '#BAE6FD',
  200: '#7DD3FC',
  300: '#38BDF8',
  400: '#0EA5E9',
  500: '#0284C7',  // Principal
  600: '#0369A1',
  700: '#075985',
  800: '#0C4A6E',
  900: '#082F49',  // Muy oscuro
}
```

### Paso 3: Rebuild y deploy

```bash
# 1. Rebuild la imagen
./build-and-push.sh

# 2. En EasyPanel, restart de los servicios
#    o espera a que auto-update (si configurado)
```

## 🔍 Variables CSS Adicionales

Si necesitas más control, puedes modificar variables CSS en:

**Archivo:** `app/javascript/dashboard/assets/scss/_variables.scss`

```scss
// Ejemplo de variables que puedes cambiar
$color-woot: #2781F6;
$color-primary: #2781F6;
$color-success: #10B981;
$color-warning: #F59E0B;
$color-error: #EF4444;
```

## 🎨 Herramientas Útiles

### Generador de Paletas
- https://uicolors.app/ - Genera paletas Tailwind desde un color
- https://coolors.co/ - Generador de paletas de colores
- https://color.adobe.com/ - Adobe Color Wheel

### Cómo usar uicolors.app:

1. Ve a https://uicolors.app/create
2. Ingresa tu color principal (ej: #10B981)
3. Copia los valores generados (50, 100, 200, etc.)
4. Pégalos en `woot: { ... }` en theme/colors.js

## 📋 Checklist de Cambio de Colores

- [ ] Decidir color principal de marca
- [ ] Editar `theme/colors.js` línea 214
- [ ] (Opcional) Generar y aplicar paleta completa
- [ ] (Opcional) Actualizar variables SCSS
- [ ] Rebuild imagen: `./build-and-push.sh`
- [ ] Deploy en EasyPanel
- [ ] Verificar en navegador (Ctrl+Shift+R)

## 🧪 Testing de Colores

Para probar rápidamente cambios de color sin rebuild completo:

```bash
# Opción 1: Dev local
pnpm dev

# Opción 2: Build assets solamente
pnpm build

# Esto te permite ver cambios antes de dockerizar
```

## 💡 Tips

1. **Contraste:** Asegúrate de que tu color tenga buen contraste con texto blanco
2. **Accesibilidad:** Usa herramientas como https://webaim.org/resources/contrastchecker/
3. **Consistencia:** Mantén el mismo color en toda la aplicación
4. **Paleta:** Genera variantes claras y oscuras del mismo color base

## 📞 Colores Recomendados para SaaS

```javascript
// Azul Profesional (Tech)
brand: '#2563EB',

// Verde Confianza (Fintech)
brand: '#10B981',

// Morado Creativo (Marketing)
brand: '#8B5CF6',

// Naranja Energético (E-commerce)
brand: '#F97316',

// Teal Moderno (Healthcare)
brand: '#14B8A6',
```
