-- Inicialización de base de datos para desarrollo
-- Se ejecuta automáticamente al crear el contenedor PostgreSQL

-- Extensiones útiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Usuario de la app (opcional, para no usar superuser)
-- CREATE ROLE shop_app WITH LOGIN PASSWORD 'shop_app';
-- GRANT ALL PRIVILEGES ON DATABASE shop_dev TO shop_app;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO shop_app;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO shop_app;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO shop_app;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO shop_app;