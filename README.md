# AILearnMate

AI-powered exam learning platform with adaptive study system, spaced repetition, and personalized learning paths.

## 🚀 Quick Start

Get the database running in 5 minutes:

```bash
# Clone the repository
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate

# Start databases with Docker
cd database
docker-compose up -d

# Run migrations and seed data
cd migrations
./run_all.sh
./seed_all.sh
```

See [database/QUICKSTART.md](database/QUICKSTART.md) for detailed setup instructions.

## 📁 Project Structure

```
AILearnMate/
├── database/                    # Database schemas and migrations
│   ├── postgresql/             # PostgreSQL schema files
│   ├── mongodb/                # MongoDB schema definitions
│   ├── seeds/                  # Initial seed data
│   ├── migrations/             # Migration scripts
│   ├── README.md              # Database documentation
│   ├── QUICKSTART.md          # Quick setup guide
│   ├── SCHEMA_DESIGN.md       # Detailed schema design
│   ├── API_EXAMPLES.md        # Code examples
│   ├── docker-compose.yml     # Docker setup
│   └── .env.example           # Environment variables template
└── README.md                   # This file
```

## 🎯 Features

### Current Implementation

✅ **Comprehensive Database Schema**
- PostgreSQL: 40+ tables for relational data
- MongoDB: 8 collections for flexible document storage
- pgvector integration for semantic search
- Full-text search capabilities

✅ **User Management**
- Authentication and session management
- User profiles and preferences
- Statistics and achievements
- Role-based access control

✅ **Knowledge Structure**
- Hierarchical knowledge points
- Subject taxonomy
- Knowledge point relationships
- User mastery tracking with SRS

✅ **Question Bank**
- 8 question types supported
- AI quality scoring
- Vector similarity search
- User attempt tracking

✅ **Study Materials**
- PDF, video, audio support
- Hierarchical content sections
- Progress tracking
- User notes and highlights

✅ **Adaptive Learning**
- Spaced Repetition System (SRS)
- Adaptive question selection
- Performance analytics
- Personalized recommendations

✅ **AI Integration**
- Question extraction from documents
- Answer evaluation
- Study plan generation
- Conversation history

### Planned Features

- [ ] FastAPI/NestJS backend implementation
- [ ] React TypeScript Next.js frontend
- [ ] Real-time collaboration
- [ ] Mobile applications
- [ ] Azure cloud deployment
- [ ] Advanced analytics dashboard

## 🗄️ Database Architecture

### PostgreSQL Tables (40+)

**Core Categories:**
1. Users & Authentication (5 tables)
2. Knowledge Structure (6 tables)
3. Questions & Answers (7 tables)
4. Study Materials (6 tables)
5. Study Sessions & Plans (7 tables)
6. AI Agent & Tasks (7 tables)
7. Analytics & Reporting (9 tables)

### MongoDB Collections (8)

1. User activity logs (high-volume, 90-day TTL)
2. Question metadata and analytics
3. AI chat conversations with full context
4. Learning journey tracking
5. Active study sessions
6. Document processing logs
7. Notification queue
8. Computation cache

### Key Technologies

- **PostgreSQL 14+** with pgvector for embeddings
- **MongoDB 6.0+** for flexible document storage
- **Vector Embeddings** for semantic search (OpenAI ada-002)
- **Spaced Repetition System** for optimal learning
- **Full-text Search** with trigram similarity

## 📚 Documentation

- **[QUICKSTART.md](database/QUICKSTART.md)** - Get started in 5 minutes
- **[README.md](database/README.md)** - Complete database documentation
- **[SCHEMA_DESIGN.md](database/SCHEMA_DESIGN.md)** - Detailed schema design and decisions
- **[API_EXAMPLES.md](database/API_EXAMPLES.md)** - Code examples in Python and Node.js

## 🛠️ Development

### Prerequisites

- Docker & Docker Compose (recommended)
- OR PostgreSQL 14+ with pgvector
- OR MongoDB 6.0+
- Python 3.9+ or Node.js 18+ (for backend)

### Environment Setup

```bash
# Copy environment template
cp database/.env.example database/.env

# Edit with your values
nano database/.env
```

### Running Tests

```bash
# PostgreSQL connection test
psql -h localhost -U postgres -d ailearn_mate -c "SELECT COUNT(*) FROM subjects;"

# MongoDB connection test
mongosh mongodb://localhost:27017/ailearn_mate --eval "db.ai_prompt_templates.countDocuments()"
```

### Code Examples

See [database/API_EXAMPLES.md](database/API_EXAMPLES.md) for:
- Python (asyncpg + motor)
- Node.js (pg + mongoose)
- Common operations
- Vector similarity search
- SRS implementation
- Analytics queries

## 🔒 Security

- Password hashing with bcrypt (cost factor 12)
- Secure session management
- Row-level security support
- SQL injection prevention
- Rate limiting ready
- CORS configuration

## 📊 Monitoring

Key metrics to track:
- Connection pool usage
- Query execution time (p95, p99)
- Vector index performance
- MongoDB TTL operations
- Cache hit rates

See documentation for monitoring queries and dashboards.

## 🤝 Contributing

Contributions are welcome! Please:

1. Follow existing code style
2. Add tests for new features
3. Update documentation
4. Submit pull requests

## 📄 License

[License details to be added]

## 📞 Support

- GitHub Issues: [Report bugs and request features](https://github.com/mxmore/AILearnMate/issues)
- Documentation: See `/database` directory
- Email: [Contact information]

## 🙏 Acknowledgments

- pgvector for PostgreSQL vector support
- OpenAI for embedding models
- MongoDB for flexible document storage
- Community contributors

---

**Status**: Database schema completed ✅ | Backend in progress 🚧 | Frontend planned 📋