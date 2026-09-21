# AdminLive - Admin Dashboard & Management

## LiveViews
- `DashboardLive` - `/admin` - Metrics, recent orders, quick actions
- `CategoryLive.Index/Form` - `/admin/categories` - CRUD categories
- `ProductLive.Index/Form` - `/admin/products` - CRUD products
- `OrderLive.Index/Show` - `/admin/orders` - View/update orders

## Features
- Protected by `:require_admin` plug
- Streams for large datasets
- Inline editing (products)
- Status transitions (orders)
- Bulk actions (future)
