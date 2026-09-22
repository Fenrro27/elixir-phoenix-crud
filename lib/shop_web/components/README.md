# ShopWeb.Components

Reusable HEEx components (stateless, no LiveView lifecycle).

## Structure
- `core_components.ex` - Phoenix generated (inputs, buttons, alerts, etc.)
- `product_card.ex` - Product display (grid/list variants)
- `cart_drawer.ex` - Slide-out cart panel
- `checkout_step.ex` - Step indicator + form wrapper
- `form_components.ex` - Custom form inputs (address, payment)
- `tables/` - Data table components (sortable, filterable)
- `forms/` - Form field wrappers
- `layouts/` - Layout components (sidebar, header, footer)

## Conventions
- Pure functions via `attr/3` + slots
- No internal state (receive assigns, emit events)
- `phx-target` for LiveView communication
- TailwindCSS classes
