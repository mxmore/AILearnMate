# AILearnMate - AI-Powered Adaptive Learning Platform

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)](https://nextjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6+-green.svg)](https://www.mongodb.com/)

A comprehensive AI-powered learning platform with adaptive question generation, intelligent review scheduling, OCR material processing, and learning analytics.

[English](README.md) | [中文文档](README_CN.md)

</div>

## ✨ Features

### 🧠 Intelligent Practice System
- **Adaptive Question Generation**: Smart question selection based on knowledge mastery and SRS timing
- **Multiple Question Types**: Single/multiple choice, true/false, fill-in-blank, short answer, essay
- **Instant Feedback**: Immediate answers and detailed explanations
- **Wrong Question Bank**: Automatic collection and focused review

### 📚 Smart Material Processing
- **Multiple Formats**: PDF, Word, PPT, images
- **OCR Recognition**: Automatic text extraction (Chinese & English)
- **AI Knowledge Extraction**: Automatic knowledge point extraction
- **Question Generation**: Intelligent question creation from materials

### 📈 Study Plans & Check-ins
- **SRS Algorithm**: SuperMemo SM-2 based spaced repetition
- **Personalized Plans**: Multiple study plans with different goals
- **Daily Check-ins**: Track study streaks
- **Progress Tracking**: Detailed daily study records

### 📊 Learning Analytics
- **Knowledge Mastery Heatmap**: Visualize knowledge point mastery
- **Accuracy Trends**: Track learning progress
- **Weak Point Analysis**: Identify areas needing focus
- **Study Time Statistics**: Detailed time tracking

## 🏗️ Architecture

### Frontend Stack
- **Framework**: Next.js 14 (React 18, TypeScript)
- **UI Components**: shadcn/ui + Tailwind CSS
- **State Management**: Zustand + React Query
- **Charts**: Recharts

### Backend Stack
- **Web Framework**: FastAPI (Python 3.11+)
- **Task Queue**: Celery + Redis
- **Authentication**: JWT + OAuth2
- **API Docs**: OpenAPI (Swagger)

### Databases
- **PostgreSQL 15+** with pgvector extension
- **MongoDB 6+** for flexible document storage
- **Redis 7+** for caching and message broker

### AI Services
- **LLM**: OpenAI GPT-4 / Alibaba Qwen3
- **Embeddings**: text-embedding-3-small
- **OCR**: PaddleOCR / Google Vision API

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (for local dev)
- Python 3.11+ (for local dev)

### Using Docker (Recommended)

1. **Clone the repository**
```bash
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate
```

2. **Configure environment variables**
```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
# Edit .env files with your API keys and configurations
```

3. **Start all services**
```bash
docker-compose up -d
```

4. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Celery Flower: http://localhost:5555
- MinIO Console: http://localhost:9001

### Local Development

See [README_CN.md](README_CN.md) for detailed local development setup.

## 📁 Project Structure

```
AILearnMate/
├── docs/                      # Documentation
├── database/                  # Database schemas and seeds
├── backend/                   # FastAPI backend
│   ├── app/
│   │   ├── api/v1/           # API routes
│   │   ├── core/             # Core configuration
│   │   ├── workers/          # Celery tasks
│   │   └── main.py
│   └── requirements.txt
├── frontend/                  # Next.js frontend
│   ├── src/
│   │   ├── app/              # App router pages
│   │   ├── components/       # React components
│   │   └── lib/              # Utilities
│   └── package.json
├── ai-prompts/                # AI prompt templates
└── docker-compose.yml         # Docker Compose config
```

## 📖 API Documentation

After starting the backend, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🤝 Contributing

Contributions are welcome! Please check out our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- GitHub Issues: [Submit an issue](https://github.com/mxmore/AILearnMate/issues)
- Maintainer: [@mxmore](https://github.com/mxmore)

---

<div align="center">
Made with ❤️ by the AILearnMate Team
</div>