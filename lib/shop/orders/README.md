# Shop.Orders

Context for order processing and management.

## Schemas
- `Order` - Orders (user_id, email, status, total, currency, address_id, notes)
- `OrderItem` - Line items (order_id, product_id, product_name, product_price, quantity, total)

## Status Flow
`draft` (cart) → `confirmed` → `paid` → `shipped` → `delivered` / `cancelled`

## Public API (orders.ex)
- `get_user_cart/1` (create draft order if none)
- `add_to_cart/3` (order, product, qty)
- `update_cart_item/3`, `remove_from_cart/2`
- `checkout/2` (cart → confirmed, calculate totals)
- `process_payment/2` (confirmed → paid via adapter)
- `list_user_orders/1`, `get_order!/1`
- `list_all_orders/1` (admin, with filters)
- `update_order_status/2` (admin)
