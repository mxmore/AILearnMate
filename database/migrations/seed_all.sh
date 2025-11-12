#!/bin/bash
# Seed database with initial data

set -e

# Database connection parameters
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-ailearn_mate}"
DB_USER="${DB_USER:-postgres}"
MONGO_URI="${MONGO_URI:-mongodb://localhost:27017/ailearn_mate}"

echo "Seeding AILearnMate databases..."
echo ""

# Function to run SQL file
run_sql_file() {
    local file=$1
    echo "Running: $file"
    PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file"
    if [ $? -eq 0 ]; then
        echo "✓ $file completed successfully"
    else
        echo "✗ $file failed"
        exit 1
    fi
    echo ""
}

# PostgreSQL seeds
echo "=== Seeding PostgreSQL ==="
cd "$(dirname "$0")/../seeds"

run_sql_file "01_subjects_seed.sql"
run_sql_file "02_knowledge_points_seed.sql"
run_sql_file "03_sample_questions_seed.sql"
run_sql_file "04_tags_seed.sql"

echo "✓ PostgreSQL seeding completed!"
echo ""

# MongoDB seeds
echo "=== Seeding MongoDB ==="
if command -v mongosh &> /dev/null; then
    mongosh "$MONGO_URI" < mongodb_seeds.js
    echo "✓ MongoDB seeding completed!"
elif command -v mongo &> /dev/null; then
    mongo "$MONGO_URI" < mongodb_seeds.js
    echo "✓ MongoDB seeding completed!"
else
    echo "⚠ mongosh/mongo not found. Skipping MongoDB seeds."
    echo "  Install MongoDB Shell or run manually:"
    echo "  mongosh $MONGO_URI < seeds/mongodb_seeds.js"
fi

echo ""
echo "=== Seeding Summary ==="
echo "✓ Subjects: Created sample subjects across multiple categories"
echo "✓ Knowledge Points: Created hierarchical knowledge structure for DSA"
echo "✓ Questions: Added sample questions of various types"
echo "✓ Tags: Added common categorization tags"
echo "✓ AI Prompts: Added template prompts for AI tasks (MongoDB)"
echo ""
echo "Database seeding completed successfully!"
