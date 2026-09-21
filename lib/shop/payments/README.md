# Shop.Payments

Payment abstraction layer (Adapter pattern).

## Behaviour
`Shop.Payments.Adapter` - Defines callbacks:
- `charge/1` - Process payment
- `refund/2` - Refund transaction
- `setup_intent/1` - Create payment intent (for Stripe)

## Implementations
- `Shop.Payments.Mock` - Current (v1-v3), simulates success
- `Shop.Payments.Stripe` - Future (v4+), real Stripe integration

## Config
```elixir
config :shop, :payments_adapter, Shop.Payments.Mock
```

## Usage
```elixir
adapter = Application.fetch_env!(:shop, :payments_adapter)
adapter.charge(%{amount: 1000, currency: "EUR", metadata: %{order_id: 123}})
```
