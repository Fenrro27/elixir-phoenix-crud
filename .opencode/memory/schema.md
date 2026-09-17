# Esquema de Base de Datos - Referencia Actual

> **Actualizado:** 2025-09-17 (Inicial)
> **Fuente de verdad:** Migraciones en `priv/repo/migrations/`

---

## Tablas

### `users` (v2+)
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| email | varchar(255) | NOT NULL, UNIQUE | |
| password_hash | varchar(255) | NOT NULL | |
| role | varchar(20) | NOT NULL, CHECK (IN 'customer','admin') | 'customer' |
| confirmed_at | timestamptz | | NULL |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

**Índices:** `users_email_unique` (email), `users_role_idx` (role)

---

### `addresses` (v2+)
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| user_id | uuid | NOT NULL, FK → users.id (CASCADE) | |
| type | varchar(20) | NOT NULL, CHECK (IN 'billing','shipping') | 'shipping' |
| first_name | varchar(100) | NOT NULL | |
| last_name | varchar(100) | NOT NULL | |
| street | varchar(255) | NOT NULL | |
| city | varchar(100) | NOT NULL | |
| postal_code | varchar(20) | NOT NULL | |
| country | varchar(2) | NOT NULL, ISO 3166-1 alpha-2 | 'ES' |
| phone | varchar(30) | | NULL |
| default | boolean | NOT NULL | false |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

**Índices:** `addresses_user_id_idx` (user_id), `addresses_user_default_idx` (user_id, default) WHERE default

---

### `categories`
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| name | varchar(100) | NOT NULL | |
| slug | varchar(120) | NOT NULL, UNIQUE | |
| description | text | | NULL |
| parent_id | uuid | FK → categories.id (SET NULL) | NULL |
| position | integer | NOT NULL | 0 |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

**Índices:** `categories_slug_unique` (slug), `categories_parent_id_idx` (parent_id), `categories_position_idx` (position)

**Jerarquía:** Self-referential. Root categories tienen `parent_id = NULL`. Usar CTE recursivo para árbol completo.

---

### `products`
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| name | varchar(200) | NOT NULL | |
| slug | varchar(220) | NOT NULL, UNIQUE | |
| description | text | | NULL |
| price | integer | NOT NULL, CHECK (price >= 0) | 0 |
| stock | integer | NOT NULL, CHECK (stock >= 0) | 0 |
| category_id | uuid | NOT NULL, FK → categories.id (RESTRICT) | |
| images | jsonb | NOT NULL | '[]'::jsonb |
| active | boolean | NOT NULL | true |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

**Índices:** `products_slug_unique` (slug), `products_category_active_idx` (category_id, active), `products_active_idx` (active), `products_search_idx` (gin en name/description via pg_trgm)

**JSONB `images` structure:**
```json
[
  {"url": "/images/prod-1-main.jpg", "alt": "Producto vista frontal", "position": 0},
  {"url": "/images/prod-1-back.jpg", "alt": "Producto vista trasera", "position": 1}
]
```

---

### `orders`
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| user_id | uuid | FK → users.id (SET NULL) | NULL |
| email | varchar(255) | NOT NULL | |
| status | varchar(30) | NOT NULL, CHECK (IN 'pending','confirmed','processing','shipped','delivered','cancelled','refunded') | 'pending' |
| total | integer | NOT NULL, CHECK (total >= 0) | 0 |
| currency | varchar(3) | NOT NULL | 'EUR' |
| address_id | uuid | FK → addresses.id (SET NULL) | NULL |
| notes | text | | NULL |
| inserted_at | timestamptz | NOT NULL | now() |
| updated_at | timestamptz | NOT NULL | now() |

**Índices:** `orders_user_id_idx` (user_id), `orders_status_idx` (status), `orders_inserted_at_idx` (inserted_at DESC), `orders_email_idx` (email)

---

### `order_items`
| Columna | Tipo | Constraints | Default |
|---------|------|-------------|---------|
| id | uuid | PK | gen_random_uuid() |
| order_id | uuid | NOT NULL, FK → orders.id (CASCADE) | |
| product_id | uuid | FK → products.id (SET NULL) | NULL |
| product_name | varchar(200) | NOT NULL | |
| product_price | integer | NOT NULL, CHECK (product_price >= 0) | |
| quantity | integer | NOT NULL, CHECK (quantity > 0) | 1 |
| total | integer | NOT NULL, CHECK (total >= 0) | |
| inserted_at | timestamptz | NOT NULL | now() |

**Índices:** `order_items_order_id_idx` (order_id), `order_items_product_id_idx` (product_id)

**Nota:** `product_name` y `product_price` se copian al crear el order (snapshot histórico). Si `product_id` es NULL, el producto fue eliminado.

---

## Migraciones Planificadas por Versión

### v1.0.0 (Core E-Commerce)
1. `create_categories.exs` - Tabla categories
2. `create_products.exs` - Tabla products + FK category
3. `create_orders.exs` - Tabla orders (sin user_id FK, solo email)
4. `create_order_items.exs` - Tabla order_items + FKs
5. `add_indexes_v1.exs` - Índices compuestos + pg_trgm

### v2.0.0 (Auth + Usuario)
6. `create_users.exs` - Tabla users
7. `create_addresses.exs` - Tabla addresses + FK user
8. `add_user_fk_to_orders.exs` - Add user_id FK a orders
9. `add_confirmable_to_users.exs` - Confirmación email (opcional)

### v3.0.0 (Admin)
10. `add_role_to_users.exs` - Campo role (customer/admin)
11. `create_admin_audit_logs.exs` - Logs de acciones admin (opcional)

### v4.0.0 (Pagos Reales)
12. `create_payment_transactions.exs` - Transacciones Stripe
13. `add_stripe_fields_to_orders.exs` - payment_intent_id, etc.

---

## Convenciones de Migraciones

```elixir
# Nombrado: YYYYMMDDHHMMSS_descripcion_snake_case.exs
# Ejemplo: 20250917100000_create_categories.exs

# En la migración:
# - Usar UUIDs: primary_key: false + add :id, :uuid, primary_key: true
# - Timestamps: timestamps(type: :utc_datetime_usec)
# - FKs: on_delete: :nothing (explicit) o :cascade/:restrict/:set_null
# - Índices: create index concurrentemente en prod (no en migración)
```

---

## Queries Comunes (Referencia)

```elixir
# Árbol de categorías (CTE recursivo)
WITH RECURSIVE category_tree AS (
  SELECT id, name, slug, parent_id, 0 as level, name::text as path
  FROM categories WHERE parent_id IS NULL
  UNION ALL
  SELECT c.id, c.name, c.slug, c.parent_id, ct.level + 1, ct.path || ' > ' || c.name
  FROM categories c JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY path;

# Productos con categoría (para catálogo)
SELECT p.*, c.name as category_name, c.slug as category_slug
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.active = true AND c.active = true
ORDER BY p.inserted_at DESC;

# Orders con items y producto snapshot
SELECT o.*, oi.*, p.name as current_product_name
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN products p ON p.id = oi.product_id
WHERE o.user_id = $1
ORDER BY o.inserted_at DESC;
```