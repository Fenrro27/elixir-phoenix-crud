# Dockerfile multi-stage para producción
# Basado en la guía oficial de Phoenix: https://hexdocs.pm/phoenix/releases.html#docker

# ===== STAGE 1: Builder =====
FROM hexpm/elixir:1.16.3-erlang-26.2.5.21-ubuntu-noble-20260911 AS builder

# Argumentos de build
ARG MIX_ENV=prod
ARG SECRET_KEY_BASE

ENV MIX_ENV=${MIX_ENV} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    HEX_HTTP_CONCURRENCY=1 \
    HEX_HTTP_TIMEOUT=120

# Instalar dependencias del sistema (Ubuntu usa apt)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    nodejs \
    npm \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Instalar Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copiar archivos de configuración de dependencias
COPY mix.exs mix.lock ./
COPY config/config.exs config/${MIX_ENV}.exs config/runtime.exs config/

# Obtener y compilar dependencias
RUN mix deps.get --only $MIX_ENV && \
    mix deps.compile

# Copiar código de la aplicación
COPY lib lib
COPY priv priv

# Compilar la aplicación
RUN mix compile

# ===== STAGE 2: Assets =====
FROM builder AS assets

# Instalar herramientas de assets (esbuild, tailwind)
RUN mix assets.setup

# Copiar assets
COPY assets assets

# Compilar assets
RUN mix assets.deploy

# ===== STAGE 3: Release =====
FROM builder AS release

# Copiar assets compilados
COPY --from=assets /app/priv/static priv/static

# Crear el release
RUN mix release

# ===== STAGE 4: Runner (Imagen final mínima Ubuntu) =====
FROM ubuntu:noble-20260911 AS runner

# Argumentos
ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV} \
    HOME=/app

# Instalar dependencias runtime mínimas
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    libstdc++6 \
    openssl \
    libncurses6 \
    libgcc-s1 \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Usuario no-root para seguridad
RUN groupadd app 2>/dev/null || true && \
    useradd -g app -s /bin/bash app 2>/dev/null || true && \
    mkdir -p /home/app && \
    chown -R app:app /home/app

WORKDIR /app

# Copiar release desde builder
COPY --from=release --chown=app:app /app/_build/${MIX_ENV}/rel/shop ./

# Cambiar a usuario no-root
USER app

# Puerto expuesto
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD ./bin/shop eval "Shop.Repo.query('SELECT 1')" || exit 1

# Comando de inicio
CMD ["bin/shop", "start"]