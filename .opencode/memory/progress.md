# Progreso del Proyecto

> **Actualizado:** 2025-09-17
> **Versión actual:** v0.0.0 (pre-v1.0.0)
> **Branch actual:** `feature/project-setup` (CI passing ✅, PR listo para merge a `develop`)

---

## Resumen de Versiones

| Versión | Estado | Branch | Target | Features |
|---------|--------|--------|--------|----------|
| **v1.0.0** | 🟢 Planificado | `release/v1.0.0` (pendiente) | Core E-Commerce | Catálogo, Carrito, Checkout (mock), Orders |
| **v2.0.0** | ⏳ Pendiente | - | Auth + Usuario | Registro, Login, Perfil, Direcciones, Historial |
| **v3.0.0** | ⏳ Pendiente | - | Admin | Dashboard, CRUD Productos, Gestión Pedidos |
| **v4.0.0** | ⏳ Pendiente | - | Pagos Reales | Stripe, Webhooks, Emails transaccionales |

---

## v1.0.0 - Core E-Commerce (En curso)

### Feature Branches Planificadas

| Feature Branch | Estado | Descripción | Tasks |
|----------------|--------|-------------|-------|
| `feature/project-setup` | ✅ **COMPLETADA** | Phoenix new + Docker + CI + Config base | [x] AGENTS.md, [x] docker-compose, [x] Dockerfile, [x] CI, [x] Memory files, [x] mix phx.new, [x] Gitflow setup, [x] PR creado, [x] **CI passing** |
| `feature/product-catalog` | 🟡 **SIGUIENTE** | Category/Product CRUD + LiveView Index/Show + Filtros | [ ] Migraciones, [ ] Context Catalog, [ ] LiveViews, [ ] Components, [ ] Tests |
| `feature/shopping-cart` | ⏳ Pendiente | Cart session/DB + Drawer component + Persistencia | [ ] Cart context, [ ] LiveView Drawer, [ ] Session handling, [ ] Tests |
| `feature/checkout-flow` | ⏳ Pendiente | Multi-step: Address → Payment(Mock) → Confirm → Success | [ ] Checkout context, [ ] Multi-step LiveView, [ ] Mock payments, [ ] Tests |
| `feature/order-management` | ⏳ Pendiente | Order creation + Email mock + Success page | [ ] Orders context, [ ] Success LiveView, [ ] Email adapter, [ ] Tests |

### Checklist v1.0.0 - Definition of Done

- [x] **Proyecto Phoenix** inicializado y compila (`mix compile` ✅)
- [x] **Docker** PostgreSQL configurado (`docker-compose.yml` ✅)
- [x] **CI/CD** configurado en GitHub Actions (`.github/workflows/ci.yml` ✅)
- [x] **Formato/Lint**: `mix format` ✅, `mix credo` ✅ (3 design suggestions menores)
- [x] **CI passing** en GitHub Actions
- [ ] **Catálogo**: Listar productos, filtrar por categoría, buscar, ver detalle
- [ ] **Carrito**: Añadir/quitar/actualizar cantidades, persistir sesión, drawer UI
- [ ] **Checkout**: 3 pasos (Dirección → Pago Mock → Confirmar), validaciones
- [ ] **Pedido**: Crear order + items, stock decrement, success page
- [ ] **Tests**: >80% coverage contexts, >70% LiveViews
- [ ] **Release v1.0.0**: Tag + CHANGELOG + merge a main

---

## Log de Sesiones

### 2025-09-17 - Sesión 1: Setup Inicial
- ✅ Creado `.opencode/AGENTS.md` completo (arquitectura, gitflow, decisiones)
- ✅ Creado `docker-compose.yml` + `docker/init.sql` (PostgreSQL 15)
- ✅ Creado `Dockerfile` multi-stage (prod) + `Dockerfile.dev` (dev)
- ✅ Creado `.env.example` + `.github/workflows/ci.yml`
- ✅ Creado `.opencode/memory/decisions.md` (10 ADRs)
- ✅ Creado `.opencode/memory/schema.md` (esquema BD completo)
- ✅ Creado `.opencode/memory/progress.md` (este archivo)
- ✅ Creado `.opencode/rules/elixir.md` + `.opencode/rules/git.md`
- ✅ Ejecutado `mix phx.new` (via temp dir + copy) → proyecto Phoenix funcional
- ✅ Ejecutado `mix deps.get` + `mix compile` → compila sin errores
- ✅ Ejecutado `mix format` → código formateado
- ✅ Ejecutado `mix credo` → pasa (3 design suggestions menores en templates Phoenix)
- ✅ Configurado Gitflow: `main` → `develop` → `feature/project-setup`
- ✅ Commit atómico limpio: `feat(infra): initialize Phoenix project with Docker, CI, and documentation`
- ✅ Push a origin: `feature/project-setup` + `develop`
- ✅ PR creado: https://github.com/Fenrro27/elixir-phoenix-crud/pull/new/feature/project-setup
- ✅ **CI passing** en GitHub Actions (Elixir 1.16, OTP 26, Node 24, Ubuntu noble)

---

## Próximas Acciones Inmediatas

1. **Merge PR** `feature/project-setup` → `develop` en GitHub
2. **Crear branch** `feature/product-catalog` desde `develop`
3. **Iniciar migraciones** para categories + products
4. **Implementar Context Catalog** con CRUD básico
5. **Crear LiveViews** ProductLive.Index + ProductLive.Show

---

## Notas para Próxima Sesión

- **Merge PR** `feature/project-setup` → `develop` en GitHub (CI verde ✅)
- **El usuario debe iniciar Docker** manualmente: `docker-compose up -d` (Docker daemon no disponible en entorno actual)
- **Generar SECRET_KEY_BASE**: `mix phx.gen.secret` y añadir a `.env`
- **Verificar localmente**: `docker-compose up -d` → `mix ecto.setup` → `mix phx.server`
- **Siguiente feature**: `feature/product-catalog` - empezar con migración de categories