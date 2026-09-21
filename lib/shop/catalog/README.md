# Shop.Catalog

Context for product catalog management.

## Schemas
- `Category` - Product categories (name, slug, description, parent_id, position)
- `Product` - Products (name, slug, description, price, stock, category_id, images, active)

## Public API (catalog.ex)
- `list_categories/0`, `get_category!/1`, `create_category/1`, `update_category/2`, `delete_category/1`
- `list_products/1` (filters: category, active, search, pagination)
- `get_product!/1`, `get_product_by_slug!/1`
- `create_product/1`, `update_product/2`, `delete_product/1`
- `update_stock/2` (for orders)

## Relationships
- Category `has_many` :products, `belongs_to` :parent, `has_many` :children
- Product `belongs_to` :category
