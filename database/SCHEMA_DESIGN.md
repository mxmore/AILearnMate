# Database Schema Design - AILearnMate

## Design Principles

### 1. Separation of Concerns
- **PostgreSQL**: Structured, relational data requiring ACID properties
- **MongoDB**: Flexible schemas, high-write volumes, temporary data

### 2. Data Normalization
- Normalized to 3NF for core relational tables
- Denormalization where read performance is critical
- JSONB columns for flexible metadata

### 3. Scalability Considerations
- Partitioning strategy for large tables
- Index optimization for common queries
- TTL policies for temporary data
- Caching layer for expensive computations

### 4. Data Integrity
- Foreign key constraints in PostgreSQL
- Check constraints for data validation
- NOT NULL constraints where appropriate
- Unique constraints to prevent duplicates

## Entity Relationship Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER DOMAIN                              │
├─────────────────────────────────────────────────────────────────┤
│  users ←→ user_profiles ←→ user_statistics                      │
│    ↓                                                             │
│  user_sessions, user_achievements                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE STRUCTURE                           │
├─────────────────────────────────────────────────────────────────┤
│  subjects → knowledge_points (hierarchical)                      │
│              ↓                                                   │
│         knowledge_point_relations                                │
│              ↓                                                   │
│         user_knowledge_mastery (SRS)                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    LEARNING CONTENT                              │
├─────────────────────────────────────────────────────────────────┤
│  questions ←→ question_knowledge_points → knowledge_points       │
│      ↓                                                           │
│  question_attempts ← users                                       │
│  question_reviews                                                │
│                                                                  │
│  study_materials ←→ material_knowledge_points                    │
│       ↓                                                          │
│  material_sections (hierarchical)                                │
│  user_material_progress ← users                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   LEARNING ACTIVITIES                            │
├─────────────────────────────────────────────────────────────────┤
│  study_sessions → question_attempts                              │
│  study_plans → study_plan_milestones → study_plan_activities    │
│  daily_study_records                                             │
│  srs_review_schedule (Spaced Repetition)                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      AI & PROCESSING                             │
├─────────────────────────────────────────────────────────────────┤
│  ai_agent_tasks → ai_prompt_templates                            │
│  ai_conversations → ai_conversation_messages                     │
│  document_processing_queue                                       │
│  ai_feedback                                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  ANALYTICS & REPORTING                           │
├─────────────────────────────────────────────────────────────────┤
│  performance_snapshots                                           │
│  learning_events                                                 │
│  performance_reports                                             │
│  study_time_logs                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Core Data Flows

### 1. User Learning Flow

```
User Signs Up
    ↓
User Profile Created (user_profiles)
    ↓
Browse Subjects & Knowledge Points
    ↓
Start Study Session (study_sessions)
    ↓
Answer Questions (question_attempts)
    ↓
Update Knowledge Mastery (user_knowledge_mastery)
    ↓
Update SRS Schedule (srs_review_schedule)
    ↓
Record Daily Progress (daily_study_records)
    ↓
Generate Performance Report (performance_reports)
```

### 2. Content Ingestion Flow

```
Upload Document (document_processing_queue)
    ↓
AI Extract Content (ai_agent_tasks)
    ↓
Extract Questions → questions table
    ↓
Identify Knowledge Points → knowledge_points
    ↓
Link Questions to Knowledge Points
    ↓
Generate Embeddings (pgvector)
    ↓
Content Ready for Learning
```

### 3. Adaptive Learning Flow

```
User Completes Questions
    ↓
Record Performance (question_attempts)
    ↓
Update Knowledge Mastery
    ↓
AI Analyzes Weak Areas (ai_agent_tasks)
    ↓
Generate Recommendations (learning_recommendations)
    ↓
Update SRS Schedule
    ↓
Suggest Next Study Activities
```

## Vector Embeddings Strategy

### Purpose
- **Semantic Search**: Find related content by meaning, not just keywords
- **Recommendations**: Suggest similar questions and materials
- **Duplicate Detection**: Identify similar or duplicate questions
- **Knowledge Mapping**: Discover relationships between concepts

### Implementation

**Tables with Vector Columns**:
1. `knowledge_points.embedding` - Concept embeddings
2. `questions.embedding` - Question content embeddings
3. `study_materials.embedding` - Material content embeddings
4. `material_sections.embedding` - Section-level embeddings
5. `ai_conversation_messages.embedding` - Message embeddings for context retrieval

**Index Type**: IVFFlat (Inverted File with Flat compression)
- **Lists parameter**: 100 (good for 10K-1M vectors)
- **Distance metric**: Cosine similarity

**Example Usage**:
```sql
-- Find similar knowledge points
SELECT kp.name, 
       1 - (kp.embedding <=> target.embedding) as similarity
FROM knowledge_points kp, knowledge_points target
WHERE target.code = 'DSA-ARRAYS'
  AND kp.id != target.id
ORDER BY kp.embedding <=> target.embedding
LIMIT 10;

-- Find questions covering similar concepts
SELECT q.question_text,
       1 - (q.embedding <=> $1) as similarity
FROM questions q
WHERE q.is_active = true
ORDER BY q.embedding <=> $1
LIMIT 20;
```

## Spaced Repetition System (SRS) Design

### Algorithm: Modified SuperMemo SM-2

**Core Tables**:
- `user_knowledge_mastery` - Per-knowledge-point mastery
- `srs_review_schedule` - Scheduled reviews
- `daily_study_records` - Daily activity tracking

**Key Fields**:
- `srs_stage`: new → learning → review → mastered
- `srs_interval`: Days until next review
- `srs_ease_factor`: Difficulty multiplier (1.3 - 2.5)
- `repetitions`: Successful review count

**Review Intervals**:
```
New Item: 0 days (learn immediately)
Learning: 1 day, 3 days
Review: 7 days, 14 days, 30 days, 60 days, ...
Mastered: 120+ days

Calculation: new_interval = old_interval × ease_factor
```

**Ease Factor Adjustment**:
```python
if quality >= 4:  # Good answer
    ease_factor += 0.1
elif quality <= 2:  # Poor answer
    ease_factor = max(1.3, ease_factor - 0.2)
    # Reset to learning stage
```

**Priority Scoring**:
```sql
-- Higher priority = should review sooner
priority_score = 
    CASE 
        WHEN scheduled_date < CURRENT_DATE THEN 100
        WHEN scheduled_date = CURRENT_DATE THEN 90
        WHEN scheduled_date <= CURRENT_DATE + 1 THEN 70
        ELSE 50
    END
    * (1.0 / ease_factor)  -- Harder items get higher priority
    * CASE srs_stage
        WHEN 'new' THEN 2.0
        WHEN 'learning' THEN 1.5
        WHEN 'review' THEN 1.0
        ELSE 0.5
    END
```

## Question Bank Design

### Question Types & Storage

**Structured Types (JSONB)**:

1. **Multiple Choice**:
```json
{
  "options": {
    "A": "Option text A",
    "B": "Option text B",
    "C": "Option text C",
    "D": "Option text D"
  },
  "correct_answer": {
    "answer": "A",
    "explanation": "Why A is correct"
  }
}
```

2. **Multiple Select**:
```json
{
  "options": { "A": "...", "B": "...", "C": "..." },
  "correct_answer": {
    "answers": ["A", "C"],
    "partial_credit": true,
    "scoring": {
      "all_correct": 1.0,
      "partial": 0.5
    }
  }
}
```

3. **Fill in Blank**:
```json
{
  "blanks": ["blank1", "blank2"],
  "correct_answer": {
    "blank1": ["answer1", "alt_answer1"],
    "blank2": ["answer2"]
  },
  "case_sensitive": false
}
```

### Quality Scoring

AI-evaluated quality metrics (0-100):
- **Clarity**: Question is clear and unambiguous
- **Relevance**: Matches target knowledge points
- **Difficulty**: Appropriate for stated level
- **Distractors**: Multiple choice options are plausible

```sql
-- Calculate overall quality score
quality_score = 
    (clarity_score * 0.3) +
    (relevance_score * 0.3) +
    (difficulty_accuracy * 0.2) +
    (distractor_quality * 0.2)
```

## Study Materials Schema

### Hierarchical Structure

```
study_materials (top-level resource)
    ↓
material_sections (chapters/sections)
    ↓ (recursive)
material_sections (subsections)
```

**Path Materialization**:
- Level 1: "1", "2", "3"
- Level 2: "1.1", "1.2", "2.1"
- Level 3: "1.1.1", "1.1.2"

**Benefits**:
- Fast hierarchical queries
- Easy breadcrumb navigation
- Efficient parent/child lookups

### Processing Pipeline

```
Upload File → document_processing_queue
    ↓
Extract Text (Azure Document Intelligence)
    ↓
Chunk Content (material_sections)
    ↓
Generate Embeddings
    ↓
Extract Key Concepts → knowledge_points
    ↓
Link to Existing Knowledge Graph
    ↓
Status: 'completed'
```

## MongoDB Document Design

### Design Patterns Used

1. **Embedded Documents**: Related data that's always accessed together
   - Example: `messages` array in `ai_chat_conversations`

2. **Extended Reference**: Store frequently accessed fields with reference
   - Example: Question metadata includes usage stats

3. **Computed Pattern**: Pre-calculated aggregations
   - Example: `totalTokens` in conversation metadata

4. **Bucket Pattern**: Group time-series data
   - Example: Activity logs grouped by hour

5. **Attribute Pattern**: Flexible key-value pairs
   - Example: Various device info fields

### TTL Strategy

Automatic data expiration:
- **user_activity_logs**: 90 days (compliance)
- **active_study_sessions**: 24 hours (session timeout)
- **notification_queue**: 30 days (delivery window)
- **computation_cache**: Variable (based on cache type)

## Performance Optimization

### Query Patterns

**High-Frequency Queries**:
1. User authentication (sessions table)
2. Next questions to review (SRS schedule)
3. User progress dashboard (aggregated stats)
4. Similar content search (vector similarity)

**Optimization Strategies**:
- Covering indexes for dashboard queries
- Materialized views for complex aggregations
- Query result caching (Redis recommended)
- Connection pooling (pg-pool, mongoose)

### Partitioning Strategy

**Candidates for Partitioning**:

1. **question_attempts** (by date)
```sql
CREATE TABLE question_attempts_2024_01 
PARTITION OF question_attempts
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

2. **learning_events** (by date)
3. **study_time_logs** (by date)
4. **ai_model_usage** (by date - already has generated column)

### Caching Strategy

**What to Cache**:
- User session data (5-15 min TTL)
- Knowledge point hierarchies (1 hour TTL)
- Popular questions (30 min TTL)
- User statistics (5 min TTL)
- AI recommendations (1 hour TTL)

**Cache Invalidation**:
- Write-through for critical data
- Lazy invalidation for analytics
- Time-based expiry for low-consistency data

## Security & Privacy

### Sensitive Data

**PII Fields**:
- `users.email`
- `users.full_name`
- `user_profiles.bio`
- `user_sessions.ip_address`

**Protection Measures**:
1. Encryption at rest (database level)
2. Encryption in transit (SSL/TLS)
3. Row-level security (RLS) in PostgreSQL
4. Audit logging for sensitive operations
5. Data masking in non-production environments

### GDPR Compliance

**Right to Access**:
```sql
-- Generate user data export
SELECT * FROM users WHERE id = $user_id;
-- Include all related tables
```

**Right to Erasure**:
```sql
-- Soft delete (preferred)
UPDATE users SET is_active = false, deleted_at = NOW() WHERE id = $user_id;

-- Hard delete (after retention period)
DELETE FROM users WHERE id = $user_id; -- Cascades to related tables
```

**Data Retention**:
- Active users: Indefinite
- Inactive users: Anonymize after 2 years
- Deleted users: 30-day recovery period
- Activity logs: 90 days

## Monitoring Queries

### Health Checks

```sql
-- Database size
SELECT pg_size_pretty(pg_database_size('ailearn_mate'));

-- Table sizes
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND indexname NOT LIKE '%pkey';

-- Active connections
SELECT count(*), state 
FROM pg_stat_activity 
GROUP BY state;

-- Long-running queries
SELECT pid, now() - query_start as duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '30 seconds';
```

### MongoDB Health

```javascript
// Collection stats
db.user_activity_logs.stats()

// Index usage
db.user_activity_logs.aggregate([
  { $indexStats: {} }
])

// Current operations
db.currentOp()

// Slow queries
db.setProfilingLevel(1, { slowms: 100 })
db.system.profile.find().sort({ ts: -1 }).limit(10)
```

## Testing Strategy

### Data Integrity Tests

```sql
-- Check orphaned records
SELECT q.id FROM questions q
LEFT JOIN subjects s ON q.subject_id = s.id
WHERE q.subject_id IS NOT NULL AND s.id IS NULL;

-- Check SRS consistency
SELECT COUNT(*) FROM user_knowledge_mastery
WHERE next_review_at < last_reviewed_at;

-- Check question quality
SELECT COUNT(*) FROM questions
WHERE is_verified = true AND quality_score IS NULL;
```

### Performance Tests

- Load test with 10K concurrent users
- Measure query response time under load
- Test vector similarity search performance
- Benchmark write throughput for activity logs

### Seed Data for Testing

- 15 subjects across categories
- 100+ knowledge points
- 1000+ sample questions
- 10 AI prompt templates
- Sample user with learning history

## Changelog

### Version 1.0.0 (Initial Release)
- PostgreSQL schema with 40+ tables
- MongoDB schema with 8 collections
- pgvector integration for semantic search
- SRS implementation
- Comprehensive seed data
- Migration and deployment scripts

### Planned Enhancements
- Graph database integration for knowledge graphs
- Time-series optimization for analytics
- Multi-language support in schema
- Advanced partitioning for scale
- Real-time collaboration features
