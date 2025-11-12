# Quick Start Guide - AILearnMate Database

## 🚀 5-Minute Setup

### Prerequisites
```bash
# Check if you have the required tools
psql --version        # PostgreSQL 14+
mongosh --version     # MongoDB 6.0+
# or
mongo --version       # Legacy MongoDB shell
```

### Option 1: Docker (Recommended)

```bash
# Start PostgreSQL with pgvector
docker run -d \
  --name ailearn-postgres \
  -e POSTGRES_DB=ailearn_mate \
  -e POSTGRES_PASSWORD=changeme \
  -p 5432:5432 \
  pgvector/pgvector:pg14

# Start MongoDB
docker run -d \
  --name ailearn-mongo \
  -p 27017:27017 \
  mongo:6

# Wait for containers to be ready (5-10 seconds)
sleep 10
```

### Option 2: Local Installation

**macOS**:
```bash
# Install PostgreSQL with pgvector
brew install postgresql@14
brew install pgvector

# Install MongoDB
brew tap mongodb/brew
brew install mongodb-community@6.0

# Start services
brew services start postgresql@14
brew services start mongodb-community@6.0
```

**Ubuntu/Debian**:
```bash
# PostgreSQL
sudo apt-get install postgresql-14 postgresql-14-pgvector

# MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start services
sudo systemctl start postgresql
sudo systemctl start mongod
```

## 📦 Initialize Database

### Step 1: Set Environment Variables

```bash
# PostgreSQL
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=ailearn_mate
export DB_USER=postgres
export DB_PASSWORD=changeme

# MongoDB
export MONGO_URI=mongodb://localhost:27017/ailearn_mate
```

### Step 2: Run Migrations

```bash
cd database/migrations
./run_all.sh
```

Expected output:
```
Running PostgreSQL migrations for AILearnMate...
✓ 01_extensions.sql completed successfully
✓ 02_types_and_enums.sql completed successfully
...
✓ All migrations completed successfully!
```

### Step 3: Seed Initial Data

```bash
./seed_all.sh
```

Expected output:
```
Seeding AILearnMate databases...
✓ 01_subjects_seed.sql completed successfully
✓ 02_knowledge_points_seed.sql completed successfully
✓ 03_sample_questions_seed.sql completed successfully
✓ 04_tags_seed.sql completed successfully
✓ MongoDB seeding completed!
```

## ✅ Verify Installation

### PostgreSQL

```bash
# Connect to database
psql -h localhost -U postgres -d ailearn_mate

# Run verification queries
SELECT COUNT(*) FROM subjects;  -- Should return 15
SELECT COUNT(*) FROM questions; -- Should return 5
SELECT COUNT(*) FROM tags;      -- Should return 16

# Check pgvector extension
SELECT * FROM pg_extension WHERE extname = 'vector';

# Exit
\q
```

### MongoDB

```bash
# Connect to database
mongosh mongodb://localhost:27017/ailearn_mate

# Run verification queries
db.ai_prompt_templates.countDocuments()  // Should return 4
db.getCollectionNames()                  // Should show all collections

# Exit
exit
```

## 🔧 Troubleshooting

### Issue: "database does not exist"
```bash
# Create database manually
psql -h localhost -U postgres -c "CREATE DATABASE ailearn_mate;"
```

### Issue: "extension vector not found"
```bash
# Install pgvector
# macOS
brew install pgvector

# Ubuntu
sudo apt-get install postgresql-14-pgvector

# Or build from source
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```

### Issue: "connection refused" (MongoDB)
```bash
# Check if MongoDB is running
sudo systemctl status mongod  # Linux
brew services list           # macOS

# Start if not running
sudo systemctl start mongod  # Linux
brew services start mongodb-community@6.0  # macOS
```

### Issue: Permission denied on scripts
```bash
chmod +x database/migrations/*.sh
```

## 🎯 What's Included

After successful setup, you'll have:

✅ **15 Subjects** across categories:
- Mathematics (3): Advanced Math, Linear Algebra, Probability
- Computer Science (4): DSA, OS, Networks, Databases
- Programming (3): Python, JavaScript, Java
- English (3): CET4, CET6, IELTS
- Certifications (2): AWS, PMP

✅ **Knowledge Points** hierarchy:
- 20+ knowledge points for Data Structures & Algorithms
- Organized in 2-level hierarchy
- Ready for linking to questions and materials

✅ **Sample Questions**:
- Multiple choice questions
- Multiple select questions
- True/false questions
- Fill in the blank questions
- Short answer questions

✅ **AI Prompt Templates**:
- Question extraction
- Answer evaluation
- Study plan generation
- Explanation generation

✅ **Tags** for organization:
- Difficulty levels
- Topic categories
- Exam types
- Content types
- Skill areas

## 🧪 Test the Setup

### Create a Test User

```bash
psql -h localhost -U postgres -d ailearn_mate << EOF
INSERT INTO users (username, email, password_hash, full_name)
VALUES ('testuser', 'test@example.com', '\$2b\$12\$test_hash', 'Test User');

SELECT id, username, email FROM users WHERE username = 'testuser';
EOF
```

### Query Similar Questions (Vector Search)

```sql
-- Find questions similar to a specific question
SELECT q1.question_text as original,
       q2.question_text as similar,
       1 - (q1.embedding <=> q2.embedding) as similarity
FROM questions q1, questions q2
WHERE q1.id != q2.id
  AND q1.embedding IS NOT NULL
  AND q2.embedding IS NOT NULL
LIMIT 5;
```

### Check SRS Schedule

```sql
-- View knowledge points ready for review
SELECT kp.name, ukm.mastery_level, ukm.next_review_at
FROM user_knowledge_mastery ukm
JOIN knowledge_points kp ON ukm.knowledge_point_id = kp.id
WHERE ukm.next_review_at <= CURRENT_DATE
ORDER BY ukm.next_review_at;
```

## 📚 Next Steps

1. **Integrate with Backend**:
   - See `database/README.md` for API integration examples
   - Use connection pooling for production

2. **Add Real Data**:
   - Import your question banks
   - Upload study materials
   - Generate embeddings for vector search

3. **Configure Production**:
   - Set up backups (see README.md)
   - Configure monitoring
   - Enable SSL/TLS
   - Set up replication (if needed)

4. **Customize**:
   - Add your own subjects
   - Create custom AI prompts
   - Configure SRS parameters

## 🔗 Additional Resources

- [Full Documentation](README.md) - Complete database guide
- [Schema Design](SCHEMA_DESIGN.md) - Detailed schema documentation
- [GitHub Issues](https://github.com/mxmore/AILearnMate/issues) - Report problems

## 💡 Common Tasks

### Add a New Subject
```sql
INSERT INTO subjects (name, code, category, difficulty_level, color)
VALUES ('New Subject', 'SUBJ-CODE', 'Category', 'medium', '#3B82F6');
```

### Add a New Question
```sql
INSERT INTO questions (
  subject_id,
  question_type,
  difficulty_level,
  question_text,
  correct_answer,
  explanation,
  source
) VALUES (
  (SELECT id FROM subjects WHERE code = 'CS-DSA'),
  'multiple_choice',
  'medium',
  'What is the time complexity of binary search?',
  '{"answer": "A", "explanation": "Binary search halves the search space each time"}'::jsonb,
  'Binary search is O(log n) because it divides the problem in half each iteration.',
  'manual'
);
```

### Reset Database (⚠️ Destructive)
```bash
# Drop and recreate
psql -h localhost -U postgres -c "DROP DATABASE IF EXISTS ailearn_mate;"
psql -h localhost -U postgres -c "CREATE DATABASE ailearn_mate;"

# Re-run migrations and seeds
cd database/migrations
./run_all.sh
./seed_all.sh

# MongoDB
mongosh mongodb://localhost:27017/ailearn_mate --eval "db.dropDatabase()"
mongosh mongodb://localhost:27017/ailearn_mate < ../seeds/mongodb_seeds.js
```

---

**Need Help?** Check the full documentation in `README.md` or open an issue on GitHub.
