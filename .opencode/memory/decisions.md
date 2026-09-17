# Decisiones Técnicas (ADR Ligero)

## ADR-001: Arquitectura de Contexts (2025-09-17)
**Decisión:** Usar Contexts como bounded contexts (DDD-ligero) en lugar de schemas sueltos.
**Contexto:** Phoenix 1.3+ recomienda contexts para organizar lógica de negocio.
**Alternativas:** Todo en un context `Shop` / Sin contexts (anti-pattern).
**Consecuencias:** Mejor separación, testabilidad, escalabilidad. Ligeramente más verboso al inicio.

## ADR-002: LiveView sobre Controllers + JSON (2025-09-17)
**Decisión:** LiveView first para toda la UI (catálogo, carrito, checkout, admin).
**Contexto:** Phoenix 1.7+ trae LiveView nativo, es el camino moderno.
**Alternativas:** Controllers + API JSON + React/Vue frontend separado.
**Consecuencias:** Menos complejidad (un solo lenguaje), UX reactiva sin JS manual, SEO mejor. Curva de aprendizaje LiveView.

## ADR-003: TailwindCSS Puro (2025-09-17)
**Decisión:** Usar TailwindCSS nativo de Phoenix 1.7 sin daisyUI/shadcn.
**Contexto:** Ya viene configurado, JIT compiler, zero deps extra.
**Alternativas:** daisyUI (componentes pre-hechos), shadcn/ui (copiar/pegar), CSS custom.
**Consecuencias:** Más trabajo inicial para componentes, pero control total, bundle mínimo, fácil migración futura.

## ADR-004: Pagos Mock v1-v3, Stripe v4+ (2025-09-17)
**Decisión:** Adapter pattern con `Shop.Payments.Mock` inicial, swap a Stripe en v4.
**Contexto:** Aprender flujo checkout sin dependencias externas ni keys.
**Alternativas:** Stripe desde v1 (complejidad), Braintree, solo mock para siempre.
**Consecuencias:** Código extra para adapter, pero desacoplamiento total, tests fáciles, migración limpia.

## ADR-005: Gitflow con Versionado Semántico (2025-09-17)
**Decisión:** main/develop/feature/release/hotfix + tags v1.0.0, v2.0.0, v3.0.0.
**Contexto:** Proyecto de aprendizaje que simula flujo profesional.
**Alternativas:** Trunk-based, GitHub Flow, solo main.
**Consecuencias:** Más disciplina git, pero historial limpio, releases trazables, rollback fácil.

## ADR-006: Docker para DB, App local en dev (2025-09-17)
**Decisión:** `docker-compose.yml` solo para PostgreSQL, app corre en host (`mix phx.server`).
**Contexto:** Desarrollo más rápido (hot reload nativo), parity con prod via Dockerfile.
**Alternativas:** Todo en Docker (app + DB), DB local nativa.
**Consecuencias:** Mejor DX (recompilación instantánea), pero entorno ligeramente diferente a prod.

## ADR-007: Testing Strategy (2025-09-17)
**Decisión:** ExUnit + LiveViewTest obligatorio, Wallaby opcional v2+.
**Contexto:** Phoenix trae excelentes tools built-in, Wallaby añade complejidad (Chrome/Chromedriver).
**Alternativas:** Solo unit tests, Wallaby desde v1, Cypress/Playwright.
**Consecuencias:** Cobertura alta en lógica + LiveView, E2E solo para flujos críticos pagos/admin.

## ADR-008: Categorías Jerárquicas (2025-09-17)
**Decisión:** Self-referential `parent_id` en categories para subcategorías infinitas.
**Contexto:** E-commerce real necesita árbol de categorías (Electrónica → Móviles → Android).
**Alternativas:** Flat categories, tags only, fixed 2-level.
**Consecuencias:** Queries recursivas (CTE), más complejo pero realista. Usar `materialized_path` o `ltree` si escala.

## ADR-009: Carrito en Sesión + DB (2025-09-17)
**Decisión:** Cart en sesión (anonimous) + persistir en DB al login/checkout.
**Contexto:** UX sin fricción (cart sobrevive refresh), migración suave a usuario.
**Alternativas:** Solo sesión (pierde cart al login), solo DB (login requerido para añadir).
**Consecuencias:** Lógica de merge sesión→DB al autenticar, pero mejor UX.

## ADR-010: Imágenes de Producto como JSONB (2025-09-17)
**Decisión:** Campo `images jsonb` en products (array de URLs/metadata) en lugar de tabla separada.
**Contexto:** Simplicidad v1, un producto tiene 1-5 imágenes típicamente.
**Alternativas:** Tabla `product_images` (normalizado), ActiveStorage/Shrine style.
**Consecuencias:** Menos joins, flexible, pero menos queryable. Migrar a tabla si >10 imágenes/producto o metadata compleja.