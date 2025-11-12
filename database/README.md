# AILearnMate Database Schema Documentation

## Overview

AILearnMate uses a hybrid database architecture combining **PostgreSQL** for relational data and **MongoDB** for flexible document storage and high-volume logs.

### Architecture Decisions

- **PostgreSQL**: Core relational data with strong ACID guarantees
  - User accounts and authentication
  - Structured learning content (subjects, knowledge points, questions)
  - Study progress and performance tracking
  - Relationships and foreign key constraints

- **MongoDB**: Flexible document storage
  - High-volume activity logs
  - AI conversation history with full context
  - Real-time session state
  - Cache and temporary data

- **pgvector Extension**: Semantic search capabilities
  - Question similarity matching
  - Content recommendations
  - Knowledge point relationships

## Database Structure

### PostgreSQL Schema (Relational)

```
postgresql/
├── 01_extensions.sql              # PostgreSQL extensions (uuid, pgvector, etc.)
├── 02_types_and_enums.sql         # Custom types and enums
├── 03_users_and_auth.sql          # User accounts and authentication
├── 04_knowledge_and_subjects.sql  # Subject taxonomy and knowledge points
├── 05_questions_and_answers.sql   # Question bank and user attempts
├── 06_study_materials.sql         # Learning materials and progress
├── 07_study_sessions_and_plans.sql # Study sessions and SRS scheduling
├── 08_ai_agent_and_tasks.sql      # AI agent tasks and processing
└── 09_analytics_and_reporting.sql  # Analytics and metrics
```

#### Key Tables

**Users & Authentication**
- `users` - Core user accounts
- `user_sessions` - Active login sessions
- `user_profiles` - Extended user profiles
- `user_statistics` - Aggregated performance stats

**Knowledge Structure**
- `subjects` - Top-level subjects/courses
- `knowledge_points` - Hierarchical knowledge taxonomy
- `knowledge_point_relations` - Relationships between concepts
- `user_knowledge_mastery` - User mastery tracking with SRS data

**Questions**
- `questions` - Question bank with various types
- `question_knowledge_points` - Question-concept mapping
- `question_attempts` - User answer history
- `question_reviews` - User feedback on questions

**Study Materials**
- `study_materials` - Learning resources (PDFs, videos, etc.)
- `material_sections` - Hierarchical content structure
- `user_material_progress` - Reading/viewing progress
- `material_notes` - User annotations and highlights

**Learning Management**
- `study_sessions` - Individual study sessions
- `study_plans` - Long-term learning plans
- `daily_study_records` - Daily activity for streak tracking
- `srs_review_schedule` - Spaced Repetition System scheduling

**AI & Processing**
- `ai_agent_tasks` - AI task execution tracking
- `ai_prompt_templates` - Reusable prompt templates
- `ai_conversations` - Chatbot conversations
- `document_processing_queue` - Document processing pipeline

### MongoDB Schema (Document)

```
mongodb/
└── schemas.js                     # MongoDB schema definitions
```

#### Key Collections

**Activity Tracking**
- `user_activity_logs` - High-volume user activity (90-day TTL)
- `learning_events` - Detailed learning analytics events

**AI & Chat**
- `ai_chat_conversations` - Full conversation context
- `question_metadata` - Question analytics and variations

**Session Management**
- `active_study_sessions` - Real-time session state
- `learning_journeys` - User learning path tracking

**Processing & Queues**
- `document_processing_logs` - Document processing details
- `notification_queue` - Notification delivery queue

**Performance**
- `computation_cache` - Cached expensive computations

## Getting Started

### Prerequisites

- PostgreSQL 14+ with pgvector extension
- MongoDB 6.0+
- psql command-line tool
- mongosh or mongo shell

### Installation

1. **Install pgvector extension**:
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-14-pgvector

# macOS with Homebrew
brew install pgvector

# Or build from source
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```

2. **Set environment variables**:
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=ailearn_mate
export DB_USER=postgres
export DB_PASSWORD=your_password
export MONGO_URI=mongodb://localhost:27017/ailearn_mate
```

3. **Run migrations**:
```bash
cd database/migrations
./run_all.sh
```

4. **Seed initial data**:
```bash
./seed_all.sh
```

### Docker Setup

```bash
# PostgreSQL with pgvector
docker run -d \
  --name ailearn-postgres \
  -e POSTGRES_DB=ailearn_mate \
  -e POSTGRES_PASSWORD=your_password \
  -p 5432:5432 \
  pgvector/pgvector:pg14

# MongoDB
docker run -d \
  --name ailearn-mongo \
  -p 27017:27017 \
  mongo:6
```

## Data Models

### Vector Embeddings

The system uses OpenAI's `text-embedding-ada-002` model (1536 dimensions) for:

- **Knowledge Points**: Semantic similarity for recommendations
- **Questions**: Find similar questions and duplicates
- **Study Materials**: Content-based recommendations
- **AI Messages**: Conversation context retrieval

Example query for similar questions:
```sql
SELECT id, question_text, 
       1 - (embedding <=> query_embedding) as similarity
FROM questions
WHERE embedding IS NOT NULL
ORDER BY embedding <=> query_embedding
LIMIT 10;
```

### Spaced Repetition System (SRS)

The SRS implementation tracks:
- **Stage**: new → learning → review → mastered
- **Interval**: Days until next review
- **Ease Factor**: Difficulty multiplier (default 2.5)
- **Repetitions**: Number of successful reviews

Algorithm based on SuperMemo SM-2 with modifications for adaptive learning.

### Question Types

Supported question types:
1. **Multiple Choice** - Single correct answer
2. **Multiple Select** - Multiple correct answers
3. **True/False** - Boolean answer
4. **Fill in the Blank** - One or more blanks to fill
5. **Short Answer** - Brief text response
6. **Essay** - Extended written response
7. **Coding** - Programming problems
8. **Matching** - Match items between lists

### AI Agent Tasks

Task types and their purposes:
- `extract_questions` - Extract questions from documents
- `generate_questions` - Generate new practice questions
- `evaluate_answer` - Assess user answer quality
- `explain_solution` - Provide detailed explanations
- `suggest_materials` - Recommend learning resources
- `create_study_plan` - Generate personalized study plans
- `analyze_performance` - Performance analysis and insights

## Indexes and Performance

### Key Indexes

**Vector Similarity (IVFFlat)**:
```sql
CREATE INDEX ON knowledge_points 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);
```

**JSONB (GIN)**:
```sql
CREATE INDEX ON questions USING gin(options);
CREATE INDEX ON questions USING gin(metadata);
```

**Full-Text Search**:
```sql
CREATE INDEX ON questions 
USING gin(to_tsvector('simple', question_text));
```

### Query Optimization Tips

1. Use covering indexes for frequently queried columns
2. Partition large tables (e.g., `user_activity_logs`) by date
3. Use `EXPLAIN ANALYZE` to optimize slow queries
4. Leverage MongoDB TTL indexes for automatic cleanup
5. Use connection pooling (recommended: 20-50 connections)

## Security Considerations

### Sensitive Data

- Passwords stored as bcrypt hashes (cost factor 12)
- User sessions use secure random tokens
- PII (Personally Identifiable Information) properly indexed
- Consider encryption at rest for production

### Access Control

```sql
-- Create read-only role
CREATE ROLE ailearn_readonly;
GRANT CONNECT ON DATABASE ailearn_mate TO ailearn_readonly;
GRANT USAGE ON SCHEMA public TO ailearn_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ailearn_readonly;

-- Create application role
CREATE ROLE ailearn_app;
GRANT CONNECT ON DATABASE ailearn_mate TO ailearn_app;
GRANT USAGE ON SCHEMA public TO ailearn_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ailearn_app;
```

### Data Retention

- User activity logs: 90 days (MongoDB TTL)
- Completed sessions: Moved to cold storage after 180 days
- AI task logs: 30 days for debugging
- User accounts: Soft delete with 30-day recovery period

## Backup and Recovery

### PostgreSQL Backup

```bash
# Full backup
pg_dump -h localhost -U postgres -Fc ailearn_mate > backup.dump

# Restore
pg_restore -h localhost -U postgres -d ailearn_mate backup.dump

# Automated daily backups
0 2 * * * pg_dump -h localhost -U postgres -Fc ailearn_mate > /backups/ailearn_$(date +\%Y\%m\%d).dump
```

### MongoDB Backup

```bash
# Backup
mongodump --uri="mongodb://localhost:27017/ailearn_mate" --out=/backups/mongo

# Restore
mongorestore --uri="mongodb://localhost:27017/ailearn_mate" /backups/mongo/ailearn_mate

# Point-in-time recovery (requires replica set)
mongodump --uri="mongodb://localhost:27017/ailearn_mate" --oplog
```

## Monitoring

### Key Metrics to Monitor

**PostgreSQL**:
- Connection pool usage
- Query execution time (p95, p99)
- Table bloat and vacuum stats
- Index usage statistics
- Replication lag (if applicable)

**MongoDB**:
- Collection size and growth rate
- Index efficiency
- TTL delete operations
- Query performance

### Useful Queries

**Find slow queries (PostgreSQL)**:
```sql
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

**Check index usage**:
```sql
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

**Monitor vector index performance**:
```sql
SELECT COUNT(*) as total_vectors,
       COUNT(*) FILTER (WHERE embedding IS NOT NULL) as with_embeddings
FROM questions;
```

## Migration Strategy

### Adding New Tables

1. Create migration file: `database/postgresql/10_new_feature.sql`
2. Add rollback script: `database/postgresql/rollback_10.sql`
3. Test on development environment
4. Run migration: `psql -d ailearn_mate -f 10_new_feature.sql`
5. Update documentation

### Schema Changes

For backward-compatible changes:
1. Add new columns with defaults
2. Deploy application code
3. Backfill data if needed
4. Remove old columns after verification

For breaking changes:
1. Use dual-write pattern
2. Migrate data in batches
3. Switch reads to new schema
4. Clean up old schema

## Troubleshooting

### Common Issues

**pgvector not loading**:
```sql
-- Check if extension exists
SELECT * FROM pg_available_extensions WHERE name = 'vector';

-- Manual installation
CREATE EXTENSION vector;
```

**Connection pool exhausted**:
```sql
-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Kill idle connections
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'idle' AND state_change < now() - interval '1 hour';
```

**MongoDB TTL not working**:
```javascript
// Verify TTL index exists
db.user_activity_logs.getIndexes()

// Manually trigger TTL monitor (runs every 60 seconds)
db.adminCommand({setParameter: 1, ttlMonitorSleepSecs: 1})
```

## API Integration Examples

### Python (asyncpg + motor)

```python
import asyncpg
from motor.motor_asyncio import AsyncIOMotorClient

# PostgreSQL
pg_pool = await asyncpg.create_pool(
    host='localhost', 
    database='ailearn_mate',
    user='postgres',
    password='password',
    min_size=10,
    max_size=50
)

# MongoDB
mongo_client = AsyncIOMotorClient('mongodb://localhost:27017')
mongo_db = mongo_client.ailearn_mate
```

### Node.js (pg + mongoose)

```javascript
const { Pool } = require('pg');
const mongoose = require('mongoose');

// PostgreSQL
const pgPool = new Pool({
  host: 'localhost',
  database: 'ailearn_mate',
  user: 'postgres',
  password: 'password',
  max: 50
});

// MongoDB
await mongoose.connect('mongodb://localhost:27017/ailearn_mate');
```

## Future Enhancements

- [ ] Partitioning strategy for large tables
- [ ] Read replicas for analytics queries
- [ ] Sharding strategy for MongoDB collections
- [ ] Time-series data optimization
- [ ] Materialized views for complex aggregations
- [ ] GraphQL schema generation from database
- [ ] Automated schema migrations with version control
- [ ] Multi-tenancy support

## Contributing

When adding new database features:

1. Follow naming conventions (snake_case for tables/columns)
2. Add appropriate indexes
3. Include comments for complex logic
4. Update this README
5. Add migration scripts
6. Write tests for data integrity

## License

Database schema is part of the AILearnMate project.

## Support

For issues or questions:
- Open an issue on GitHub
- Contact: dev@ailearn.com
- Documentation: https://docs.ailearn.com
