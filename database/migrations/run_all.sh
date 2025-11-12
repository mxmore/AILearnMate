#!/bin/bash
# Run all PostgreSQL migrations in order

set -e

# Database connection parameters
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-ailearn_mate}"
DB_USER="${DB_USER:-postgres}"

echo "Running PostgreSQL migrations for AILearnMate..."
echo "Database: $DB_NAME on $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
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

# Create database if it doesn't exist
echo "Ensuring database exists..."
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database already exists"

# Run schema files in order
cd "$(dirname "$0")/../postgresql"

echo "=== Phase 1: Extensions ==="
run_sql_file "01_extensions.sql"

echo "=== Phase 2: Types and Enums ==="
run_sql_file "02_types_and_enums.sql"

echo "=== Phase 3: Users and Authentication ==="
run_sql_file "03_users_and_auth.sql"

echo "=== Phase 4: Knowledge and Subjects ==="
run_sql_file "04_knowledge_and_subjects.sql"

echo "=== Phase 5: Questions and Answers ==="
run_sql_file "05_questions_and_answers.sql"

echo "=== Phase 6: Study Materials ==="
run_sql_file "06_study_materials.sql"

echo "=== Phase 7: Study Sessions and Plans ==="
run_sql_file "07_study_sessions_and_plans.sql"

echo "=== Phase 8: AI Agent and Tasks ==="
run_sql_file "08_ai_agent_and_tasks.sql"

echo "=== Phase 9: Analytics and Reporting ==="
run_sql_file "09_analytics_and_reporting.sql"

echo ""
echo "✓ All migrations completed successfully!"
echo ""
echo "To seed the database with initial data, run:"
echo "  ./seed_all.sh"
