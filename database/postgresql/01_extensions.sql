-- Extensions for AILearnMate Database
-- Enable required PostgreSQL extensions

-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Vector similarity search for semantic search and AI embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Full-text search capabilities
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- JSON operations
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- Timestamp utilities
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

COMMENT ON EXTENSION "uuid-ossp" IS 'UUID generation functions';
COMMENT ON EXTENSION vector IS 'Vector similarity search for embeddings (pgvector)';
COMMENT ON EXTENSION pg_trgm IS 'Trigram-based text similarity and fuzzy search';
COMMENT ON EXTENSION btree_gin IS 'GIN index support for btree-equivalent operators';
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions';
