# Reglas Git/Gitflow para el Agente

## Branching Model (Gitflow)

### Branches Principales (Protegidas)
- **`main`** - Solo releases tags (v1.0.0, v2.0.0...). Protegida: PR required, CI pass, no force push.
- **`develop`** - Integración continua. Protegida: PR required, CI pass.

### Branches de Trabajo

| Prefijo | Origen | Destino | Naming |
|---------|--------|---------|--------|
| `feature/` | `develop` | `develop` | `feature/short-description` |
| `release/` | `develop` | `main` + `develop` | `release/v1.0.0` |
| `hotfix/` | `main` | `main` + `develop` | `hotfix/v1.0.1` |

### Convenciones de Nombres
- **Kebab-case:** `feature/product-catalog`, `feature/shopping-cart`
- **Corto, descriptivo:** `feature/cart-persistence` no `feature/implement-shopping-cart-persistence-in-session-and-database`
- **Un feature = un branch** (aunque sea pequeño)

## Flujo de Trabajo Estándar

### Iniciar Feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/nombre-corto
# Trabajar... commits atómicos
```

### Commits (Conventional Commits)
```
<type>(<scope>): <descripción corta>

[cuerpo opcional: qué y por qué, no cómo]

[footer: BREAKING CHANGE, fixes #123]
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `style`, `perf`

**Scopes sugeridos:** `catalog`, `cart`, `checkout`, `orders`, `users`, `admin`, `payments`, `infra`, `deps`

**Ejemplos:**
```
feat(catalog): add category filter to product listing
fix(cart): prevent negative quantity on update
refactor(orders): extract pricing calculation to Orders.calculate_total/1
test(catalog): add tests for Product slug generation
chore(deps): update phoenix_live_view to 0.19.0
ci: add dialyzer to GitHub Actions
```

### Terminar Feature (Merge a develop)
```bash
# Actualizar con develop
git checkout develop
git pull origin develop
git checkout feature/nombre-corto
git merge develop  # o rebase si prefieres historial lineal

# Push y PR
git push origin feature/nombre-corto
# Crear PR en GitHub: feature/nombre-corto → develop
# Esperar CI + Review → Merge (Squash or Merge commit)
```

### Release (vX.Y.Z)
```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 1. Bump version en mix.exs: @version "1.0.0"
# 2. Actualizar CHANGELOG.md (Keep a Changelog format)
# 3. Commit: git commit -am "chore: release v1.0.0"

# Merge a main + tag
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "v1.0.0"
git push origin main --tags

# Merge a develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# Limpiar
git branch -d release/v1.0.0
git push origin --delete release/v1.0.0
```

### Hotfix (vX.Y.Z+1)
```bash
git checkout main
git pull origin main
git checkout -b hotfix/v1.0.1

# Fix + bump patch version + CHANGELOG
git commit -am "fix(cart): fix tax calculation on zero-quantity items"

# Merge a main + tag
git checkout main
git merge --no-ff hotfix/v1.0.1
git tag -a v1.0.1 -m "v1.0.1"
git push origin main --tags

# Merge a develop
git checkout develop
git merge --no-ff hotfix/v1.0.1
git push origin develop

# Limpiar
git branch -d hotfix/v1.0.1
git push origin --delete hotfix/v1.0.1
```

## Reglas de Commit

1. **Un commit = un cambio lógico** (no "wip", "fix", "update")
2. **Tests pasan** en cada commit (CI lo valida en PR)
3. **`mix format`** aplicado antes de commit
4. **`mix credo --strict`** pasa antes de commit
5. **No commits vacíos** ni solo whitespace (salvo formatting commit dedicado)

## PR Requirements

- [ ] CI pasa (test, format, credo, compile)
- [ ] Al menos 1 approval (si hay reviewers)
- [ ] Branch actualizado con `develop`/`main` (rebase o merge)
- [ ] Título PR = tipo convencional: `feat(catalog): add product filtering`
- [ ] Descripción: qué cambia, por qué, cómo testear
- [ ] Si breaking change: `BREAKING CHANGE:` en body/footer

## Tags

- **Formato:** `v<major>.<minor>.<patch>` (SemVer)
- **Annotated tags:** `git tag -a v1.0.0 -m "v1.0.0"`
- **Push tags:** `git push origin --tags` (o `git push origin v1.0.0`)

## .gitignore (Verificar existe)

```
/_build
/cover
/deps
/doc
/.fetch
erl_crash.dump
*.ez
*.beam
/config/*.secret.exs
.elixir_ls/
/.idea/
/.vscode/
*.swp
*.swo
*~
.env
.env.local
.DS_Store
```

## Aliases Útiles (añadir a ~/.gitconfig)

```ini
[alias]
  co = checkout
  cb = checkout -b
  st = status
  br = branch
  lg = log --oneline --graph --decorate -20
  lga = log --oneline --graph --decorate --all
  cm = commit -m
  ca = commit --amend
  ps = push
  pl = pull
  mg = merge --no-ff
  rb = rebase
  tags = tag -l "v*" --sort=-v:refname
  release = "!f() { git checkout develop && git pull && git checkout -b release/$1; }; f"
  hotfix = "!f() { git checkout main && git pull && git checkout -b hotfix/$1; }; f"
```