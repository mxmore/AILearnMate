# AILearnMate - AI 驱动的智能考试学习平台

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)](https://nextjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6+-green.svg)](https://www.mongodb.com/)

一个功能全面的 AI 驱动学习平台，支持自适应出题、智能复习计划、OCR 资料处理和学习数据分析。

[English](README.md) | [中文文档](README_CN.md)

</div>

## ✨ 核心特性

### 🧠 智能刷题系统
- **自适应出题算法**：根据用户知识点掌握度和 SRS 复习时间智能组卷
- **多种题型支持**：单选、多选、判断、填空、简答、论述题
- **即时反馈**：答题后立即显示正确答案和详细解析
- **错题本管理**：自动收集错题，支持重点复习

### 📚 资料智能处理
- **多格式支持**：PDF、Word、PPT、图片等
- **OCR 识别**：自动识别文字内容（支持中英文）
- **AI 知识点提取**：自动分析资料内容，提取关键知识点
- **自动生成题目**：从资料中智能生成高质量练习题

### 📈 学习计划与打卡
- **SRS 间隔重复算法**：基于 SuperMemo SM-2 算法的科学复习计划
- **个性化学习计划**：支持创建多个学习计划，设置不同目标
- **每日打卡**：记录学习连续天数，培养学习习惯
- **进度追踪**：详细记录每天的学习情况

### 📊 学习数据分析
- **知识点掌握度热力图**：可视化展示各知识点掌握情况
- **答题准确率趋势**：追踪学习进度和效果
- **薄弱知识点分析**：智能识别需要重点学习的内容
- **学习时长统计**：详细的学习时间记录和分析

### 🔍 知识图谱
- **层级知识点体系**：支持多级知识点结构
- **向量语义搜索**：基于 pgvector 的知识点语义搜索
- **知识点关联**：建立知识点之间的关联关系

## 🏗️ 技术架构

### 前端技术栈
- **框架**: Next.js 14 (React 18, TypeScript)
- **UI 组件**: shadcn/ui + Tailwind CSS
- **状态管理**: Zustand + React Query
- **表单处理**: React Hook Form + Zod
- **图表可视化**: Recharts

### 后端技术栈
- **Web 框架**: FastAPI (Python 3.11+)
- **任务队列**: Celery + Redis
- **认证**: JWT + OAuth2
- **API 文档**: OpenAPI (Swagger)

### 数据库
- **关系型数据库**: PostgreSQL 15+ (带 pgvector 扩展)
  - 用户数据、学习记录、知识点
  - 向量化搜索支持
- **文档数据库**: MongoDB 6+
  - 题库、学习资料、会话记录
  - 灵活的数据结构

### AI 服务
- **LLM**: OpenAI GPT-4 / Alibaba Qwen3
- **向量化**: text-embedding-3-small
- **OCR**: PaddleOCR / Google Vision API

### 基础设施
- **缓存**: Redis 7+
- **对象存储**: MinIO / AWS S3
- **容器化**: Docker + Docker Compose
- **监控**: Prometheus + Grafana

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- Node.js 20+ (本地开发)
- Python 3.11+ (本地开发)

### 使用 Docker 启动（推荐）

1. **克隆仓库**
```bash
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate
```

2. **配置环境变量**
```bash
# 后端配置
cp backend/.env.example backend/.env
# 前端配置
cp frontend/.env.example frontend/.env

# 编辑 .env 文件，填入必要的 API 密钥
# - OPENAI_API_KEY 或 QWEN_API_KEY
# - JWT_SECRET_KEY
# - 数据库密码等
```

3. **启动所有服务**
```bash
docker-compose up -d
```

4. **初始化数据库**
```bash
# PostgreSQL 会自动执行 schema 和 seed 脚本
# MongoDB 也会自动执行初始化脚本

# 或手动执行
docker-compose exec postgres psql -U ailearnmate -d ailearnmate -f /docker-entrypoint-initdb.d/01-schema.sql
docker-compose exec mongodb mongosh --host localhost --port 27017 -u ailearnmate -p ailearnmate_pass /docker-entrypoint-initdb.d/01-schema.js
```

5. **访问应用**
- 前端: http://localhost:3000
- 后端 API: http://localhost:8000
- API 文档: http://localhost:8000/docs
- Celery Flower (任务监控): http://localhost:5555
- MinIO 控制台: http://localhost:9001

### 本地开发

#### 后端开发

```bash
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件

# 启动后端服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 启动 Celery worker (另一个终端)
celery -A app.workers.celery_app worker --loglevel=info
```

#### 前端开发

```bash
cd frontend

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env.local

# 启动开发服务器
npm run dev
```

## 📁 项目结构

```
AILearnMate/
├── docs/                      # 文档
│   └── SYSTEM_ARCHITECTURE.md # 系统架构文档
│
├── database/                  # 数据库脚本
│   ├── postgresql_schema.sql # PostgreSQL 表结构
│   ├── seed_data.sql          # PostgreSQL 种子数据
│   ├── mongodb_schema.js      # MongoDB 集合结构
│   └── mongodb_seed_data.js   # MongoDB 种子数据
│
├── backend/                   # 后端 FastAPI 应用
│   ├── app/
│   │   ├── api/              # API 路由
│   │   │   └── v1/
│   │   │       ├── endpoints/ # API 端点
│   │   │       └── api.py    # 路由聚合
│   │   ├── core/             # 核心配置
│   │   │   ├── config.py     # 应用配置
│   │   │   ├── database.py   # 数据库连接
│   │   │   └── security.py   # 安全认证
│   │   ├── models/           # 数据模型
│   │   ├── schemas/          # Pydantic 模式
│   │   ├── crud/             # 数据库操作
│   │   ├── services/         # 业务逻辑
│   │   ├── workers/          # Celery 任务
│   │   │   ├── celery_app.py
│   │   │   └── tasks/
│   │   ├── utils/            # 工具函数
│   │   └── main.py           # 应用入口
│   ├── requirements.txt       # Python 依赖
│   ├── Dockerfile            # Docker 镜像
│   └── .env.example          # 环境变量示例
│
├── frontend/                  # 前端 Next.js 应用
│   ├── src/
│   │   ├── app/              # App Router 页面
│   │   ├── components/       # React 组件
│   │   │   ├── ui/          # UI 基础组件
│   │   │   ├── layout/      # 布局组件
│   │   │   └── features/    # 功能组件
│   │   ├── lib/              # 工具库
│   │   │   └── api.ts       # API 客户端
│   │   ├── types/            # TypeScript 类型
│   │   ├── hooks/            # 自定义 Hooks
│   │   ├── store/            # 状态管理
│   │   └── styles/           # 样式文件
│   ├── public/               # 静态资源
│   ├── package.json          # Node 依赖
│   ├── Dockerfile            # Docker 镜像
│   └── .env.example          # 环境变量示例
│
├── ai-prompts/                # AI 提示词库
│   ├── knowledge_extraction.txt  # 知识点提取
│   ├── question_generation.txt   # 题目生成
│   ├── quality_assessment.txt    # 质量评估
│   └── README.md
│
├── scripts/                   # 工具脚本
│   ├── init_db.sh            # 数据库初始化
│   └── deploy.sh             # 部署脚本
│
├── docker-compose.yml         # Docker Compose 配置
└── README.md                  # 项目说明
```

## 🔧 配置说明

### 数据库配置

**PostgreSQL** 需要安装 pgvector 扩展:
```sql
CREATE EXTENSION IF NOT EXISTS "pgvector";
```

**MongoDB** 使用默认配置即可。

### AI 服务配置

在 `.env` 文件中配置:
```env
# OpenAI
OPENAI_API_KEY=your-api-key
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_EMBEDDING_MODEL=text-embedding-3-small

# 或使用 Qwen
QWEN_API_KEY=your-qwen-api-key
QWEN_MODEL=qwen-turbo
```

### OCR 配置

支持多种 OCR 引擎:
- **PaddleOCR**: 开源免费，支持中英文
- **Google Vision API**: 需要 API 密钥，准确率更高

```env
OCR_ENGINE=paddleocr  # 或 google_vision
GOOGLE_VISION_API_KEY=your-key  # 如果使用 Google Vision
```

## 📖 API 文档

启动后端服务后，访问:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 主要 API 端点

#### 认证
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/refresh` - 刷新 token

#### 题目
- `GET /api/v1/questions` - 获取题目列表
- `GET /api/v1/questions/{id}` - 获取题目详情
- `POST /api/v1/questions/answer` - 提交答案
- `GET /api/v1/questions/adaptive/generate` - 生成自适应题目

#### 学习
- `GET /api/v1/study/plans` - 获取学习计划
- `POST /api/v1/study/plans` - 创建学习计划
- `POST /api/v1/study/check-ins/today` - 每日打卡
- `GET /api/v1/study/wrong-questions` - 获取错题本

#### 资料
- `POST /api/v1/materials/upload` - 上传学习资料
- `GET /api/v1/materials/{id}` - 获取资料详情
- `GET /api/v1/materials/{id}/processing-status` - 获取处理状态

## 🧪 测试

### 后端测试
```bash
cd backend
pytest
pytest --cov=app tests/
```

### 前端测试
```bash
cd frontend
npm test
npm run test:coverage
```

## 📦 部署

### Docker 部署（推荐）

1. 配置环境变量
2. 构建并启动:
```bash
docker-compose up -d --build
```

### 手动部署

详细部署指南请参考: [部署文档](docs/DEPLOYMENT.md)

## 🤝 贡献

欢迎贡献！请查看 [贡献指南](CONTRIBUTING.md)。

## 📄 许可证

本项目采用 MIT 许可证 - 详情请查看 [LICENSE](LICENSE) 文件。

## 📞 联系方式

- GitHub Issues: [提交问题](https://github.com/mxmore/AILearnMate/issues)
- 项目维护者: [@mxmore](https://github.com/mxmore)

## 🙏 致谢

感谢所有贡献者和以下开源项目:
- FastAPI
- Next.js
- PostgreSQL & pgvector
- MongoDB
- Celery
- PaddleOCR
- shadcn/ui

---

<div align="center">
Made with ❤️ by the AILearnMate Team
</div>
