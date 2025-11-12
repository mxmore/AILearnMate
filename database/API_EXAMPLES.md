# Database API Examples

## Connection Setup

### Python (asyncpg + motor)

```python
import asyncpg
from motor.motor_asyncio import AsyncIOMotorClient
import os

# PostgreSQL connection pool
async def create_pg_pool():
    return await asyncpg.create_pool(
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', 5432)),
        database=os.getenv('DB_NAME', 'ailearn_mate'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD'),
        min_size=10,
        max_size=50,
        command_timeout=60
    )

# MongoDB connection
def create_mongo_client():
    mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017')
    client = AsyncIOMotorClient(mongo_uri)
    return client.ailearn_mate
```

### Node.js (pg + mongoose)

```javascript
const { Pool } = require('pg');
const mongoose = require('mongoose');

// PostgreSQL
const pgPool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'ailearn_mate',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  max: 50,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// MongoDB
await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/ailearn_mate', {
  maxPoolSize: 50,
  minPoolSize: 10,
});
```

## Common Operations

### 1. User Authentication

#### Register New User

```python
async def register_user(pool, username, email, password_hash):
    async with pool.acquire() as conn:
        user_id = await conn.fetchval('''
            INSERT INTO users (username, email, password_hash, role)
            VALUES ($1, $2, $3, 'student')
            RETURNING id
        ''', username, email, password_hash)
        
        # Create user profile
        await conn.execute('''
            INSERT INTO user_profiles (user_id)
            VALUES ($1)
        ''', user_id)
        
        # Initialize statistics
        await conn.execute('''
            INSERT INTO user_statistics (user_id)
            VALUES ($1)
        ''', user_id)
        
        return user_id
```

```javascript
async function registerUser(username, email, passwordHash) {
  const client = await pgPool.connect();
  try {
    await client.query('BEGIN');
    
    const userResult = await client.query(
      `INSERT INTO users (username, email, password_hash, role)
       VALUES ($1, $2, $3, 'student')
       RETURNING id`,
      [username, email, passwordHash]
    );
    const userId = userResult.rows[0].id;
    
    await client.query(
      'INSERT INTO user_profiles (user_id) VALUES ($1)',
      [userId]
    );
    
    await client.query(
      'INSERT INTO user_statistics (user_id) VALUES ($1)',
      [userId]
    );
    
    await client.query('COMMIT');
    return userId;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}
```

#### Verify Login

```python
async def verify_login(pool, email, password_hash):
    async with pool.acquire() as conn:
        user = await conn.fetchrow('''
            SELECT id, username, email, role, is_active
            FROM users
            WHERE email = $1 AND password_hash = $2 AND is_active = true
        ''', email, password_hash)
        
        if user:
            # Update last login
            await conn.execute('''
                UPDATE users
                SET last_login_at = CURRENT_TIMESTAMP
                WHERE id = $1
            ''', user['id'])
        
        return user
```

### 2. Knowledge Point Management

#### Get Knowledge Point Hierarchy

```python
async def get_knowledge_hierarchy(pool, subject_id):
    async with pool.acquire() as conn:
        return await conn.fetch('''
            WITH RECURSIVE kp_tree AS (
                -- Root level
                SELECT id, name, code, parent_id, level, path, difficulty_level,
                       estimated_study_time, description
                FROM knowledge_points
                WHERE subject_id = $1 AND parent_id IS NULL
                
                UNION ALL
                
                -- Child levels
                SELECT kp.id, kp.name, kp.code, kp.parent_id, kp.level, kp.path,
                       kp.difficulty_level, kp.estimated_study_time, kp.description
                FROM knowledge_points kp
                INNER JOIN kp_tree kt ON kp.parent_id = kt.id
            )
            SELECT * FROM kp_tree
            ORDER BY path
        ''', subject_id)
```

#### Get User Mastery for Knowledge Points

```python
async def get_user_mastery(pool, user_id, subject_id):
    async with pool.acquire() as conn:
        return await conn.fetch('''
            SELECT kp.id, kp.name, kp.code,
                   COALESCE(ukm.mastery_level, 0) as mastery_level,
                   COALESCE(ukm.status, 'not_started') as status,
                   ukm.next_review_at,
                   ukm.srs_stage
            FROM knowledge_points kp
            LEFT JOIN user_knowledge_mastery ukm 
                ON kp.id = ukm.knowledge_point_id AND ukm.user_id = $1
            WHERE kp.subject_id = $2
            ORDER BY kp.path
        ''', user_id, subject_id)
```

### 3. Question Bank Operations

#### Get Adaptive Questions

```python
async def get_adaptive_questions(pool, user_id, subject_id, count=10):
    """Get questions adapted to user's current level"""
    async with pool.acquire() as conn:
        return await conn.fetch('''
            WITH user_level AS (
                SELECT 
                    CASE 
                        WHEN AVG(mastery_level) < 30 THEN 'easy'
                        WHEN AVG(mastery_level) < 70 THEN 'medium'
                        ELSE 'hard'
                    END as difficulty
                FROM user_knowledge_mastery
                WHERE user_id = $1
            ),
            weak_knowledge_points AS (
                SELECT knowledge_point_id
                FROM user_knowledge_mastery
                WHERE user_id = $1 
                  AND mastery_level < 60
                ORDER BY mastery_level ASC
                LIMIT 5
            )
            SELECT DISTINCT q.id, q.question_text, q.question_type,
                   q.difficulty_level, q.options, q.points
            FROM questions q
            JOIN question_knowledge_points qkp ON q.id = qkp.question_id
            WHERE q.subject_id = $2
              AND q.is_active = true
              AND q.difficulty_level = (SELECT difficulty FROM user_level)
              AND (
                  qkp.knowledge_point_id IN (SELECT knowledge_point_id FROM weak_knowledge_points)
                  OR qkp.is_primary = true
              )
              AND q.id NOT IN (
                  SELECT question_id 
                  FROM question_attempts 
                  WHERE user_id = $1 
                    AND is_correct = true
                    AND attempted_at > CURRENT_TIMESTAMP - INTERVAL '7 days'
              )
            ORDER BY RANDOM()
            LIMIT $3
        ''', user_id, subject_id, count)
```

#### Submit Answer and Update Mastery

```python
async def submit_answer(pool, user_id, question_id, user_answer, is_correct, time_spent):
    async with pool.acquire() as conn:
        async with conn.transaction():
            # Record attempt
            attempt_id = await conn.fetchval('''
                INSERT INTO question_attempts 
                (user_id, question_id, user_answer, is_correct, time_spent)
                VALUES ($1, $2, $3, $4, $5)
                RETURNING id
            ''', user_id, question_id, user_answer, is_correct, time_spent)
            
            # Update question statistics
            await conn.execute('''
                UPDATE questions
                SET usage_count = usage_count + 1,
                    correct_rate = (
                        SELECT CAST(SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)
                        FROM question_attempts
                        WHERE question_id = $1
                    )
                WHERE id = $1
            ''', question_id)
            
            # Update knowledge point mastery
            knowledge_points = await conn.fetch('''
                SELECT knowledge_point_id, relevance_score
                FROM question_knowledge_points
                WHERE question_id = $1
            ''', question_id)
            
            for kp in knowledge_points:
                await update_knowledge_mastery(
                    conn, user_id, kp['knowledge_point_id'], 
                    is_correct, kp['relevance_score']
                )
            
            return attempt_id

async def update_knowledge_mastery(conn, user_id, kp_id, is_correct, relevance):
    """Update mastery using SRS algorithm"""
    mastery = await conn.fetchrow('''
        SELECT * FROM user_knowledge_mastery
        WHERE user_id = $1 AND knowledge_point_id = $2
        FOR UPDATE
    ''', user_id, kp_id)
    
    if mastery:
        # Calculate new mastery level
        adjustment = 5 * relevance if is_correct else -3 * relevance
        new_mastery = max(0, min(100, mastery['mastery_level'] + adjustment))
        
        # Update SRS parameters
        if is_correct:
            new_interval = int(mastery['srs_interval'] * mastery['srs_ease_factor'])
            new_ease = min(2.5, mastery['srs_ease_factor'] + 0.1)
        else:
            new_interval = 1  # Reset to 1 day
            new_ease = max(1.3, mastery['srs_ease_factor'] - 0.2)
        
        await conn.execute('''
            UPDATE user_knowledge_mastery
            SET mastery_level = $3,
                correct_attempts = correct_attempts + $4,
                total_attempts = total_attempts + 1,
                last_reviewed_at = CURRENT_TIMESTAMP,
                next_review_at = CURRENT_DATE + $5,
                srs_interval = $5,
                srs_ease_factor = $6,
                updated_at = CURRENT_TIMESTAMP
            WHERE user_id = $1 AND knowledge_point_id = $2
        ''', user_id, kp_id, new_mastery, 1 if is_correct else 0, 
             new_interval, new_ease)
    else:
        # Create new mastery record
        initial_mastery = 10 if is_correct else 0
        await conn.execute('''
            INSERT INTO user_knowledge_mastery 
            (user_id, knowledge_point_id, mastery_level, correct_attempts, 
             total_attempts, last_reviewed_at, next_review_at, srs_interval)
            VALUES ($1, $2, $3, $4, 1, CURRENT_TIMESTAMP, CURRENT_DATE + 1, 1)
        ''', user_id, kp_id, initial_mastery, 1 if is_correct else 0)
```

### 4. Vector Similarity Search

#### Find Similar Questions

```python
async def find_similar_questions(pool, question_id, limit=10):
    async with pool.acquire() as conn:
        return await conn.fetch('''
            SELECT q2.id, q2.question_text, q2.difficulty_level,
                   1 - (q1.embedding <=> q2.embedding) as similarity
            FROM questions q1, questions q2
            WHERE q1.id = $1
              AND q2.id != $1
              AND q1.embedding IS NOT NULL
              AND q2.embedding IS NOT NULL
              AND q2.is_active = true
            ORDER BY q1.embedding <=> q2.embedding
            LIMIT $2
        ''', question_id, limit)
```

#### Semantic Knowledge Point Search

```python
async def search_knowledge_points(pool, query_embedding, subject_id=None, limit=10):
    async with pool.acquire() as conn:
        if subject_id:
            return await conn.fetch('''
                SELECT id, name, description,
                       1 - (embedding <=> $1::vector) as similarity
                FROM knowledge_points
                WHERE subject_id = $2
                  AND embedding IS NOT NULL
                ORDER BY embedding <=> $1::vector
                LIMIT $3
            ''', query_embedding, subject_id, limit)
        else:
            return await conn.fetch('''
                SELECT id, name, description,
                       1 - (embedding <=> $1::vector) as similarity
                FROM knowledge_points
                WHERE embedding IS NOT NULL
                ORDER BY embedding <=> $1::vector
                LIMIT $2
            ''', query_embedding, limit)
```

### 5. Study Session Management

#### Start Study Session

```python
from motor.motor_asyncio import AsyncIOMotorClient

async def start_study_session(pg_pool, mongo_db, user_id, session_config):
    # Create session in PostgreSQL
    async with pg_pool.acquire() as conn:
        session_id = await conn.fetchval('''
            INSERT INTO study_sessions 
            (user_id, session_type, subject_id, title, target_knowledge_points)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id
        ''', user_id, session_config['type'], session_config.get('subject_id'),
             session_config.get('title'), session_config.get('knowledge_points', []))
    
    # Create real-time state in MongoDB
    await mongo_db.active_study_sessions.insert_one({
        'sessionId': str(session_id),
        'userId': str(user_id),
        'sessionType': session_config['type'],
        'currentState': {
            'currentQuestionIndex': 0,
            'startedAt': datetime.utcnow(),
            'lastActivityAt': datetime.utcnow(),
            'isPaused': False
        },
        'questions': [],
        'performance': {
            'questionsAnswered': 0,
            'correctAnswers': 0,
            'currentStreak': 0,
            'longestStreak': 0
        },
        'configuration': session_config,
        'expiresAt': datetime.utcnow() + timedelta(hours=24),
        'createdAt': datetime.utcnow()
    })
    
    return session_id
```

### 6. AI Agent Tasks

#### Create Question Extraction Task

```python
async def create_extraction_task(pool, user_id, file_url, file_name):
    async with pool.acquire() as conn:
        task_id = await conn.fetchval('''
            INSERT INTO ai_agent_tasks 
            (user_id, task_type, input_data, priority)
            VALUES ($1, 'extract_questions', $2, 5)
            RETURNING id
        ''', user_id, {
            'file_url': file_url,
            'file_name': file_name,
            'extraction_config': {
                'min_quality_score': 70,
                'auto_verify': False
            }
        })
        
        # Also add to document processing queue
        await conn.execute('''
            INSERT INTO document_processing_queue
            (user_id, file_url, file_name, processing_type, priority)
            VALUES ($1, $2, $3, 'extract_questions', 5)
        ''', user_id, file_url, file_name)
        
        return task_id
```

### 7. Analytics and Reporting

#### Generate Performance Report

```python
async def generate_performance_report(pool, user_id, start_date, end_date):
    async with pool.acquire() as conn:
        # Get overall stats
        stats = await conn.fetchrow('''
            SELECT 
                COUNT(DISTINCT qa.question_id) as questions_attempted,
                COUNT(DISTINCT CASE WHEN qa.is_correct THEN qa.question_id END) as questions_correct,
                AVG(CASE WHEN qa.is_correct THEN 100 ELSE 0 END) as accuracy,
                SUM(qa.time_spent) / 60 as total_time_minutes,
                COUNT(DISTINCT DATE(qa.attempted_at)) as study_days
            FROM question_attempts qa
            WHERE qa.user_id = $1
              AND qa.attempted_at BETWEEN $2 AND $3
        ''', user_id, start_date, end_date)
        
        # Get knowledge point progress
        kp_progress = await conn.fetch('''
            SELECT 
                s.name as subject_name,
                kp.name as knowledge_point_name,
                ukm.mastery_level,
                ukm.status,
                ukm.total_attempts,
                ukm.correct_attempts
            FROM user_knowledge_mastery ukm
            JOIN knowledge_points kp ON ukm.knowledge_point_id = kp.id
            JOIN subjects s ON kp.subject_id = s.id
            WHERE ukm.user_id = $1
              AND ukm.updated_at BETWEEN $2 AND $3
            ORDER BY s.name, ukm.mastery_level DESC
        ''', user_id, start_date, end_date)
        
        # Create report
        report_id = await conn.fetchval('''
            INSERT INTO performance_reports
            (user_id, report_type, report_period_start, report_period_end,
             title, report_data, overall_score)
            VALUES ($1, 'custom', $2, $3, $4, $5, $6)
            RETURNING id
        ''', user_id, start_date, end_date,
             f'Performance Report ({start_date} to {end_date})',
             {'stats': dict(stats), 'knowledge_points': [dict(r) for r in kp_progress]},
             stats['accuracy'])
        
        return report_id
```

## MongoDB Operations

### Log User Activity

```python
async def log_activity(mongo_db, user_id, activity_type, activity_data):
    await mongo_db.user_activity_logs.insert_one({
        'userId': str(user_id),
        'activityType': activity_type,
        'activityData': activity_data,
        'timestamp': datetime.utcnow(),
        'metadata': {}
    })
```

### Store AI Conversation

```python
async def store_ai_message(mongo_db, conversation_id, role, content, tokens=0):
    await mongo_db.ai_chat_conversations.update_one(
        {'conversationId': str(conversation_id)},
        {
            '$push': {
                'messages': {
                    'messageId': str(uuid.uuid4()),
                    'role': role,
                    'content': content,
                    'tokens': tokens,
                    'timestamp': datetime.utcnow()
                }
            },
            '$inc': {
                'metadata.messageCount': 1,
                'metadata.totalTokens': tokens
            },
            '$set': {
                'updatedAt': datetime.utcnow()
            }
        },
        upsert=True
    )
```

## Best Practices

1. **Always use connection pooling** - Never create connections per request
2. **Use transactions** for multi-step operations
3. **Index frequently queried fields** - Monitor slow queries
4. **Batch operations** when possible to reduce round trips
5. **Use prepared statements** to prevent SQL injection
6. **Implement retry logic** for transient failures
7. **Monitor connection pool** usage and tune as needed
8. **Cache expensive computations** in Redis or MongoDB
9. **Use async/await** consistently for better performance
10. **Log query performance** in production for optimization
