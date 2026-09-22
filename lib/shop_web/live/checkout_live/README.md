# CheckoutLive - Multi-step Checkout

## LiveViews (Steps)
1. `Address` - `/checkout` - Shipping/billing address form
2. `Payment` - `/checkout/payment` - Payment method (mock)
3. `Confirm` - `/checkout/confirm` - Order summary, confirm

## Flow
- Step validation before next
- `phx-update="ignore"` for payment step
- Back navigation preserves data
- On confirm: `Orders.checkout/1` → `Payments.charge/1` → success
