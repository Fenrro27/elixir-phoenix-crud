# Reglas Elixir/Phoenix para el Agente

## Formato y Estilo

- **Siempre** `mix format` antes de commit
- **Máximo 100 chars/linea** (configurado en `.formatter.exs`)
- **`alias`** al top del módulo, agrupados: `alias MyApp.{Context, Schema, Other}`
- **`import`** solo si se usa多次, preferir `alias` + nombre completo
- **Paréntesis opcionales** en llamadas sin args: `do_something()` → `do_something`
- **Pipe `|>`** para transformaciones encadenadas (mínimo 2 pasos)

## Patrones Phoenix/LiveView

### Contexts
```elixir
# ✅ BUENO - API pública en context.ex
defmodule Shop.Catalog do
  def list_products(filters \\ %{}) do
    Product
    |> apply_filters(filters)
    |> Repo.all()
  end
  
  defp apply_filters(query, %{"category" => slug}) do
    # ...
  end
end

# ❌ MALO - Llamar Repo directo desde LiveView
```

### LiveViews
```elixir
# ✅ BUENO - handle_params para URL state
def handle_params(%{"page" => page}, _uri, socket) do
  {:noreply, assign(socket, page: String.to_integer(page))}
end

# ✅ BUENO - Streams para listas
def handle_event("load_more", _params, socket) do
  products = Catalog.list_products(page: socket.assigns.page + 1)
  {:noreply, stream_insert(socket, :products, products)}
end

# ❌ MALO - assign lista completa en mount para listas grandes
```

### Components
```elixir
# ✅ BUENO - Stateless, solo assigns + eventos
defmodule ShopWeb.Components.ProductCard do
  def product_card(assigns) do
    ~H[<.card> ... </.card>]
  end
end

# ❌ MALO - Componente con socket/handle_event propio (salvo que sea LiveComponent necesario)
```

### Changesets
```elixir
# ✅ BUENO - Uno por acción
def create_changeset(product, attrs) do
  product
  |> cast(attrs, [:name, :price, :stock, :category_id])
  |> validate_required([:name, :price, :category_id])
  |> validate_number(:price, greater_than_or_equal_to: 0)
  |> unique_constraint(:slug)
  |> foreign_key_constraint(:category_id)
end

def update_changeset(product, attrs) do
  product
  |> cast(attrs, [:name, :price, :stock, :description])
  |> validate_required([:name, :price])
  # Sin unique_constraint(:slug) si no se edita slug
end
```

## Testing

- **Naming:** `test "description of behavior" do`
- **Setup:** `setup do ... end` para data común
- **LiveViewTest:** `live/2` + `element/3` + `render/1` + `assert_has/2`
- **Factories:** Usar `ex_machina` o functions privadas en test/support
- **Async:** `async: true` por defecto, `async: false` solo si DB shared state

## Database

- **Migraciones:** Siempre `timestamps(type: :utc_datetime_usec)`
- **PKs:** UUID (`primary_key: false` + `add :id, :uuid, primary_key: true`)
- **FKs:** Explícitas `on_delete: :cascade/:restrict/:set_null`
- **Índices:** En migración solo FKs + unique. Compuestos en migración separada.
- **Tipos dinero:** `integer` (centimos) + `currency` varchar(3), NUNCA float/decimal

## Seguridad

- **NUNCA** loggear passwords, tokens, secrets
- **`put_secure_browser_headers`** en endpoint (default Phoenix)
- **`protect_from_forgery`** en controllers (no necesario en LiveView)
- **Validar** en changeset, no confiar en frontend
- **Rate limiting** en auth endpoints (v2+)

## Performance

- **`select`** solo campos necesarios en queries (`select: [:id, :name, :price]`)
- **`preload`** associations para evitar N+1
- **Streams** para listas >50 items
- **`phx-update="ignore"`** en componentes estáticos costosos
- **Cache** con `Nebulex` o `Cachex` si needed (v3+)

## Git/Commits

- **Commits atómicos** por cambio lógico pequeño
- **Mensajes Conventional Commits** (ver AGENTS.md)
- **No commit** `_build`, `deps`, `cover`, `doc`, `.elixir_ls`, `*.ez`, `*.beam`
- **`mix.lock`** SÍ se commitea