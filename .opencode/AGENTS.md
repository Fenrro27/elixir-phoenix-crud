# Agente: elixir-phoenix-crud (Mini E-Commerce)

## Contexto del Proyecto

**Nombre:** Shop - Mini E-Commerce Learning Project
**Stack:** Elixir 1.15+ | Phoenix 1.7+ (LiveView) | PostgreSQL 15+ | TailwindCSS
**Tipo:** Aplicación de aprendizaje nivel intermedio - E-Commerce completo
**Objetivo:** Aprender Phoenix/LiveView construyendo algo real, no "hello world"

---

## Arquitectura y Convenciones

### Estructura de Contexts (Bounded Contexts)

```
lib/
├── shop/                    # Core business logic
│   ├── accounts/           # Users, Authentication, Addresses
│   │   ├── user.ex
│   │   ├── address.ex
│   │   └── accounts.ex     # Public API
│   ├── catalog/            # Products, Categories, Inventory
│   │   ├── product.ex
│   │   ├── category.ex
│   │   └── catalog.ex
│   ├── orders/             # Orders, OrderItems, Checkout
│   │   ├── order.ex
│   │   ├── order_item.ex
│   │   └── orders.ex
│   └── shop.ex             # Facade para cross-context operations
└── shop_web/               # Web layer (LiveView, Components)
    ├── live/
    │   ├── product_live/   # Catalog browsing
    │   ├── cart_live/      # Shopping cart (drawer/modal)
    │   ├── checkout_live/  # Multi-step checkout
    │   ├── order_live/     # Order success/history
    │   ├── user_live/      # Profile, addresses (v2)
    │   └── admin_live/     # Admin dashboard (v3)
    └── components/
        ├── core_components.ex
        ├── product_card.ex
        ├── cart_drawer.ex
        ├── checkout_step.ex
        └── form_components.ex
```

### Convenciones de Código

| Aspecto | Convención |
|---------|------------|
| **Naming** | `snake_case` para funciones/vars, `PascalCase` para módulos |
| **Contexts** | Un archivo `<context>.ex` como API pública, schemas privados |
| **LiveViews** | Un directorio por feature, `index/show/new/edit` como acciones |
| **Components** | En `shop_web/components/`, reutilizables, sin estado propio |
| **Changesets** | Uno por acción (create, update, admin_update), en el schema |
| **Validaciones** | En changesets, no en BD (excepto unicidad/foreign keys) |
| **Queries** | En el context (`Catalog.list_products/1`), no en LiveViews |
| **Error Handling** | `{:ok, result} | {:error, changeset}` tuples, `with` para piping |

### Principios LiveView

- **Stateless components** - Solo reciben assigns, emiten eventos
- **LiveView como coordinador** - Maneja estado, llama a contexts
- **`phx-update="ignore"`** para componentes costosos (gráficos, mapas)
- **`phx-debounce`** en búsquedas (300ms default)
- **`handle_params`** para URLs compartibles (filtros, paginación)
- **Streams** para listas grandes (`stream/3`, `stream_insert/3`)

---

## Esquema de Base de Datos

### Tablas Principales

```sql
-- users (v2+)
users: id, email, password_hash, role, confirmed_at, created_at, updated_at

-- addresses (v2+)
addresses: id, user_id, type, first_name, last_name, street, city, postal_code, country, phone, default, created_at

-- categories (jerárquicas)
categories: id, name, slug, description, parent_id, position, created_at, updated_at

-- products
products: id, name, slug, description, price, stock, category_id, images (jsonb), active, created_at, updated_at

-- orders
orders: id, user_id, email, status, total, currency, address_id, notes, created_at, updated_at

-- order_items
order_items: id, order_id, product_id, product_name, product_price, quantity, total, created_at
```

### Relaciones

- `User` → `has_many :addresses`, `has_many :orders`
- `Category` → `has_many :products`, `belongs_to :parent` (self-ref), `has_many :children`
- `Product` → `belongs_to :category`, `has_many :order_items`
- `Order` → `belongs_to :user`, `belongs_to :address`, `has_many :order_items`
- `OrderItem` → `belongs_to :order`, `belongs_to :product`

### Índices Clave

- `products: [category_id, active]`, `products: [slug]` (unique)
- `orders: [user_id, created_at]`, `orders: [status]`
- `categories: [parent_id]`, `categories: [slug]` (unique)

---

## Gitflow Workflow

### Branch Strategy

```
main (protected, tags: v1.0.0, v2.0.0, v3.0.0...)
  │
  ├── develop (integración continua, CI pasa siempre)
  │     │
  │     ├── feature/product-catalog
  │     ├── feature/shopping-cart
  │     ├── feature/checkout-flow
  │     ├── feature/order-management
  │     ├── feature/user-auth (v2)
  │     ├── feature/admin-dashboard (v3)
  │     └── feature/payment-integration (future)
  │
  ├── release/v1.0.0 → main + tag v1.0.0
  ├── release/v2.0.0 → main + tag v2.0.0
  ├── release/v3.0.0 → main + tag v3.0.0
  │
  └── hotfix/v1.0.1 → main + develop + tag v1.0.1
```

### Reglas de Merge

| Branch | Merge a | Requiere |
|--------|---------|----------|
| `feature/*` | `develop` | PR + CI pass + 1 approval |
| `release/*` | `main` + `develop` | PR + CI pass + CHANGELOG + version bump |
| `hotfix/*` | `main` + `develop` | PR + CI pass + version bump patch |

### Convenciones de Commits (Conventional Commits)

```
feat: nueva funcionalidad (product catalog)
fix: corrección de bug
refactor: refactor sin cambio de comportamiento
test: añadir/modificar tests
docs: documentación
chore: mantenimiento (deps, config)
ci: cambios en CI/CD
style: formatting (mix format)
perf: mejora de performance
```

**Ejemplos:**
- `feat(catalog): add product filtering by category`
- `fix(cart): prevent negative quantity on update`
- `refactor(orders): extract pricing calculation to service`

---

## Versionado Semántico (SemVer)

| Versión | Contenido | Branch de Release | Target |
|---------|-----------|-------------------|--------|
| **v1.0.0** | Catálogo productos, Carrito, Checkout (mock), Pedido exitoso | `release/v1.0.0` | Core E-Commerce sin auth |
| **v2.0.0** | Auth (registro/login), Perfil usuario, Direcciones, Historial pedidos | `release/v2.0.0` | Usuario autenticado |
| **v3.0.0** | Admin: CRUD productos, Gestión pedidos, Dashboard métricas | `release/v3.0.0` | Panel administrativo |
| **v4.0.0** | Integración pagos real (Stripe), Webhooks, Emails transaccionales | `release/v4.0.0` | Producción real |

---

## Decisiones Técnicas Documentadas

### Pagos (v1 = Mock, v4 = Real)

**v1-v3: Payment Mock Module**
```elixir
# lib/shop/payments/mock.ex
defmodule Shop.Payments.Mock do
  @behaviour Shop.Payments.Adapter
  
  def charge(%{amount: amount, currency: currency, metadata: metadata}) do
    # Simula procesamiento 1-2s
    Process.sleep(1500)
    {:ok, %{
      transaction_id: "mock_" <> System.unique_integer(),
      status: :succeeded,
      amount: amount,
      currency: currency
    }}
  end
  
  def refund(transaction_id, amount) do
    {:ok, %{refund_id: "refund_" <> System.unique_integer()}}
  end
end
```

**Interface para futuro (v4+):**
```elixir
# lib/shop/payments/adapter.ex
defmodule Shop.Payments.Adapter do
  @callback charge(map()) :: {:ok, map()} | {:error, term()}
  @callback refund(String.t(), integer()) :: {:ok, map()} | {:error, term()}
  @callback setup_intent(map()) :: {:ok, map()} | {:error, term()}
end
```

**Configuración:** `config :shop, :payments_adapter, Shop.Payments.Mock` → cambiar a `Shop.Payments.Stripe` en v4.

---

### CSS Framework: TailwindCSS (Native Phoenix 1.7+)

**Decisión:** Usar **TailwindCSS puro** (incluido en Phoenix 1.7) sin librerías extra.

**Razones:**
- Zero dependencies extra, ya viene configurado
- JIT compiler = CSS mínimo en producción
- Fácil de aprender, utility-first = consistencia
- `core_components.ex` ya usa Tailwind
- Fácil migrar a daisyUI/shadcn si se necesita después

**Configuración:** `assets/tailwind.config.js` + `assets/css/app.css`

---

### Testing Strategy

| Tipo | Herramienta | Qué testea | Cuándo |
|------|-------------|------------|--------|
| **Unit** | `ExUnit` | Contexts, schemas, changesets, utils | Siempre |
| **Integration** | `ExUnit` + `Phoenix.ConnTest` | Controllers, API endpoints | Siempre |
| **LiveView** | `LiveViewTest` | LiveViews, componentes, flujos UI | Siempre |
| **E2E** | `Wallaby` (opcional v2+) | Flujos completos usuario | Críticos فقط |

**Cobertura objetivo:** >80% en contexts, >70% en LiveViews

**Comandos:**
```bash
mix test                    # Todos los tests
mix test --cover            # Con coverage
mix test.watch              # Watch mode (dev)
```

---

### Docker & Deployment

**Desarrollo:** `docker-compose.yml` con:
- `postgres:15-alpine` (DB)
- `app` (Phoenix server) - opcional, se puede correr local

**Producción:** `Dockerfile` multi-stage:
1. `builder` - compila assets, compila release
2. `runner` - imagen mínima con release

**Variables de entorno:** `.env` (no commitido) + `config/runtime.exs`

---

## Comandos Útiles

### Desarrollo Local

```bash
# Primera vez
docker-compose up -d          # Levantar PostgreSQL
mix setup                     # Deps + DB create/migrate + assets
mix phx.server                # Servidor en localhost:4000

# Día a día
mix phx.server                # Dev server
mix test                      # Tests
mix test.watch                # Tests en watch
mix format                    # Formatear código
mix credo --strict            # Linting
mix dialyzer                  # Type checking (si configurado)

# Base de datos
mix ecto.migrate              # Migraciones
mix ecto.rollback             # Rollback último
mix ecto.reset                # Drop + create + migrate + seed
mix ecto.gen.migration name   # Nueva migración
```

### Docker

```bash
docker-compose up -d          # Solo DB
docker-compose up             # DB + App (ver logs)
docker-compose down           # Parar todo
docker-compose down -v        # Parar + borrar volúmenes (reset DB)
docker-compose exec app bash  # Shell en container app
```

### Gitflow

```bash
# Nueva feature
git checkout develop
git pull origin develop
git checkout -b feature/nombre-corto

# Finish feature
git checkout develop
git merge --no-ff feature/nombre-corto
git push origin develop
git branch -d feature/nombre-corto

# Release
git checkout develop
git checkout -b release/v1.0.0
# Bump version en mix.exs + CHANGELOG.md
git commit -am "chore: release v1.0.0"
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "v1.0.0"
git push origin main --tags
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop
git branch -d release/v1.0.0
```

---

## Estructura de Archivos Clave del Repo

```
├── .github/
│   └── workflows/
│       └── ci.yml            # CI: test, format, credo, dialyzer
├── .opencode/
│   ├── AGENTS.md             # Este archivo
│   ├── memory/
│   │   ├── decisions.md      # Decisiones técnicas (ADR ligero)
│   │   ├── schema.md         # Esquema BD actualizado
│   │   └── progress.md       # Progreso por versión/feature
│   └── rules/
│       ├── elixir.md         # Reglas Elixir/Phoenix
│       └── git.md            # Reglas gitflow
├── config/
│   ├── runtime.exs           # Config runtime (prod + dev)
│   └── test.exs              # Config test
├── docker-compose.yml        # Dev: PostgreSQL
├── Dockerfile                # Prod: Multi-stage build
├── mix.exs                   # Dependencias + versión app
├── mix.lock                  # Lockfile (commitido)
├── .env.example              # Template variables entorno
├── .gitignore
├── README.md
└── CHANGELOG.md              # Keep a Changelog format
```

---

## Próximos Pasos Inmediatos (v1.0.0 - Feature Branches)

1. **`feature/project-setup`** - Phoenix new + Docker + CI + Config base
2. **`feature/product-catalog`** - Category/Product CRUD + LiveView Index/Show + Filtros
3. **`feature/shopping-cart`** - Cart session/DB + Drawer component + Persistencia
4. **`feature/checkout-flow`** - Multi-step: Address → Payment(Mock) → Confirm → Success
5. **`feature/order-management`** - Order creation + Email mock + Success page

Cada feature = branch + PR + merge a `develop` → al final `release/v1.0.0` → `main` + tag.

---

## Notas para el Agente (Memoria Persistente)

- **Siempre** leer `.opencode/memory/progress.md` al inicio de sesión
- **Actualizar** `.opencode/memory/progress.md` al completar cada task
- **Registrar** decisiones en `.opencode/memory/decisions.md` (formato ADR ligero)
- **Mantener** `.opencode/memory/schema.md` sincronizado con migraciones
- **No escribir código** sin antes haber documentado el plan en memory/
- **Commits atómicos** por feature pequeña, mensaje convencional
- **Tests primero** (TDD ligero): test fallando → implementar → test pasa → refactor