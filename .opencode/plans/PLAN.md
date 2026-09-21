# Plan: Generic Shop MVC Implementation

## Domain Model

### Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| **Category** | Product categorization | `name`, `slug`, `description` |
| **Product** | Sellable items | `name`, `slug`, `description`, `price`, `stock`, `category_id`, `active` |
| **User** | Customers | `email`, `password_hash`, `name`, `role` |
| **Order** | Purchase records | `user_id`, `status`, `total`, `shipping_address`, `billing_address` |
| **OrderItem** | Line items in order | `order_id`, `product_id`, `quantity`, `unit_price` |

### Relationships
- Category `has_many` Products
- Product `belongs_to` Category
- User `has_many` Orders
- Order `belongs_to` User, `has_many` OrderItems
- OrderItem `belongs_to` Order, `belongs_to` Product

---

## Implementation Steps

### 1. Database Migrations (in order)
1. `create_categories` - categories table
2. `create_products` - products table (FK to categories)
3. `create_users` - users table (with secure password)
4. `create_orders` - orders table (FK to users)
5. `create_order_items` - order_items table (FK to orders + products)

### 2. Contexts & Schemas (`lib/shop/`)
- `Shop.Catalog` - Category & Product management
- `Shop.Accounts` - User authentication/registration
- `Shop.Orders` - Order processing

### 3. Controllers (`lib/shop_web/controllers/`)
- `CategoryController` - CRUD for admin
- `ProductController` - Public listing + admin CRUD
- `OrderController` - User orders + admin management
- `SessionController` - Login/logout
- `RegistrationController` - User signup

### 4. Views (HEEx Components)
**Public:**
- Product listing with filters
- Product detail page
- Cart (session-based)
- Checkout flow

**Admin:**
- Dashboard
- Category/Product CRUD forms
- Order management

### 5. Routes (`router.ex`)
```elixir
# Public (LiveView)
live "/", ProductLive.Index, :index
live "/products/:slug", ProductLive.Show, :show

# Cart (LiveView)
live "/cart", CartLive.Show, :show

# Checkout (LiveView multi-step)
live "/checkout", CheckoutLive.Address, :new
live "/checkout/address", CheckoutLive.Address, :edit
live "/checkout/payment", CheckoutLive.Payment, :edit
live "/checkout/confirm", CheckoutLive.Confirm, :edit

# Order success
live "/orders/:id/success", OrderLive.Success, :show

# Auth (phx.gen.auth - controllers tradicionales)
# /login, /register, /logout, /confirm-email, /reset-password

# User area (LiveView - v2+)
# live "/account", UserLive.Profile
# live "/account/orders", UserLive.Orders

# Admin (LiveView, protected)
scope "/admin", ShopWeb.AdminLive, as: :admin do
  pipe_through [:browser, :require_authenticated_user, :require_admin]
  
  live "/", DashboardLive, :index
  live "/categories", CategoryLive.Index, :index
  live "/categories/new", CategoryLive.Form, :new
  live "/categories/:id/edit", CategoryLive.Form, :edit
  
  live "/products", ProductLive.Index, :index
  live "/products/new", ProductLive.Form, :new
  live "/products/:id/edit", ProductLive.Form, :edit
  
  live "/orders", OrderLive.Index, :index
  live "/orders/:id", OrderLive.Show, :show
end
```

### 6. Authentication
- Guardian or Pow for JWT/session auth
- Role-based access (user, admin)

### 7. Extras
- Seeds with sample data
- Email notifications (order confirmation)
- Basic tests

---

## File Structure After Implementation

```
lib/
├── shop/
│   ├── accounts/
│   │   ├── user.ex
│   │   ├── accounts.ex
│   │   └── credentials.ex
│   ├── catalog/
│   │   ├── category.ex
│   │   ├── product.ex
│   │   └── catalog.ex
│   ├── orders/
│   │   ├── order.ex
│   │   ├── order_item.ex
│   │   └── orders.ex
│   ├── payments/
│   │   ├── adapter.ex
│   │   └── mock.ex
│   └── shop.ex
└── shop_web/
    ├── live/
    │   ├── product_live/
    │   │   ├── index.ex
    │   │   ├── show.ex
    │   │   └── index.html.heex / show.html.heex
    │   ├── cart_live/
    │   │   ├── show.ex
    │   │   └── show.html.heex
    │   ├── checkout_live/
    │   │   ├── address.ex
    │   │   ├── payment.ex
    │   │   ├── confirm.ex
    │   │   └── *.html.heex
    │   ├── order_live/
    │   │   ├── success.ex
    │   │   ├── index.ex (historial)
    │   │   └── *.html.heex
    │   └── admin_live/
    │       ├── dashboard.ex
    │       ├── category_live/
    │       ├── product_live/
    │       └── order_live/
    ├── components/
    │   ├── core_components.ex
    │   ├── product_card.ex
    │   ├── cart_drawer.ex
    │   ├── checkout_step.ex
    │   ├── form_components.ex
    │   └── tables/
    ├── router.ex
    └── endpoint.ex
```
---

## Directory Structure to Create

### Contexts (`lib/shop/`)
```
lib/shop/
├── accounts/
├── catalog/
├── orders/
├── payments/
└── shop.ex (update)
```

### LiveViews (`lib/shop_web/live/`)
```
lib/shop_web/live/
├── product_live/
├── cart_live/
├── checkout_live/
├── order_live/
└── admin_live/
    ├── category_live/
    ├── product_live/
    └── order_live/
```

### Components (`lib/shop_web/components/`)
```
lib/shop_web/components/
├── forms/
├── tables/
└── layouts/
```

### Migrations (`priv/repo/migrations/`)
- Will be generated via `mix ecto.gen.migration`

### Templates (co-located with LiveViews)
- Each `*_live/` dir contains `.ex` + `.html.heex` files
```

---

## Decisiones Técnicas (Confirmadas)

| # | Decisión | Opción Elegida | Razón |
|---|----------|----------------|-------|
| 1 | **Auth** | `mix phx.gen.auth` (built-in) | Integrado, sessions seguras, menos deps, estándar Phoenix |
| 2 | **Admin** | Scope separado `/admin` | Aislamiento claro, pipelines propios, escalable |
| 3 | **Cart** | DB-persisted (Order + OrderItems draft) | Persistencia real, recovery, analytics, multi-device |
| 4 | **Payments** | Mock ahora, Stripe en v4 | Enfocar en core, adapter pattern para swap fácil |
| 5 | **UI** | **LiveView** para todo | Interactividad nativa, menos JS, SEO-friendly, Phoenix 1.7+ |

### Detalles de Implementación por Decisión

**Auth (`phx.gen.auth`):**
- Genera: User schema, registro, login, confirmación email, reset password
- Sessions en BD (tokens), `User` context
- Roles: `user` / `admin` (campo `role` en users)

**Admin Scope:**
```elixir
scope "/admin", ShopWeb.Admin, as: :admin do
  pipe_through [:browser, :require_authenticated_user, :require_admin]
  # recursos admin
end
```

**Cart (DB-backed):**
- `Order` con `status: "draft"` = carrito activo
- Un carrito por usuario (o session para guests)
- `OrderItem` = líneas del carrito
- Transición: draft → confirmed → paid → shipped

**Payments (Mock Adapter):**
```elixir
# lib/shop/payments/adapter.ex (behaviour)
# lib/shop/payments/mock.ex (implementación actual)
# config :shop, :payments_adapter, Shop.Payments.Mock
```

**LiveView:**
- `ProductLive.Index` / `Show` (catálogo público)
- `CartLive.Show` (drawer/modal)
- `CheckoutLive` (multi-step: address → payment → confirm)
- `AdminLive.*` (dashboard, CRUD)
- Componentes reutilizables en `ShopWeb.Components`

---

## Next Steps

Once you confirm the approach, I'll:
1. Generate migrations
2. Create contexts/schemas
3. Build controllers + views
4. Configure routes + auth
5. Add seeds + tests