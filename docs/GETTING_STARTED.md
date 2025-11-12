# AILearnMate 快速开始指南

本指南将帮助你快速了解并启动 AILearnMate 项目。

## 🎯 项目概述

AILearnMate 是一个完整的 AI 驱动智能学习平台，包含以下核心功能：

1. **智能刷题系统** - 自适应出题算法，根据学习进度智能推荐
2. **资料智能处理** - OCR 识别 + AI 知识点提取 + 自动生成题目
3. **学习计划管理** - 基于 SRS 算法的科学复习计划
4. **学习数据分析** - 可视化学习进度和知识点掌握度

## 📋 系统要求

### 最低配置
- **CPU**: 2 核心
- **内存**: 4GB RAM
- **存储**: 20GB 可用空间
- **操作系统**: Linux / macOS / Windows (with WSL2)

### 推荐配置
- **CPU**: 4+ 核心
- **内存**: 8GB+ RAM
- **存储**: 50GB+ 可用空间

## 🚀 5 分钟快速启动

### 步骤 1: 安装 Docker

**macOS / Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Windows:**
下载并安装 [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)

### 步骤 2: 克隆项目

```bash
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate
```

### 步骤 3: 配置环境变量

```bash
# 复制环境变量模板
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 生成密钥 (Linux/macOS)
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(32))" >> backend/.env
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_urlsafe(32))" >> backend/.env
```

**必需配置** (编辑 `backend/.env`):
```env
# 强烈推荐配置 OpenAI API Key 以启用 AI 功能
OPENAI_API_KEY=sk-your-openai-api-key

# 或使用 Qwen
# QWEN_API_KEY=your-qwen-api-key

# 其他密码会使用示例值，生产环境请修改
```

### 步骤 4: 启动所有服务

```bash
docker-compose up -d
```

首次启动需要下载镜像和构建，大约需要 3-5 分钟。

### 步骤 5: 验证安装

```bash
# 查看服务状态
docker-compose ps

# 应该看到以下服务都在运行:
# - postgres
# - mongodb
# - redis
# - minio
# - backend
# - celery_worker
# - frontend
```

### 步骤 6: 访问应用

打开浏览器访问:

- **前端应用**: http://localhost:3000
- **API 文档**: http://localhost:8000/docs
- **任务监控**: http://localhost:5555 (Celery Flower)
- **存储管理**: http://localhost:9001 (MinIO, 用户名/密码: minioadmin)

## 👥 测试账户

系统已预置测试账户:

| 用户名 | 邮箱 | 密码 | 角色 |
|--------|------|------|------|
| 管理员 | admin@ailearnmate.com | Admin123! | admin |
| 小明 | test1@example.com | Test123! | user |
| 小红 | test2@example.com | Test123! | vip |

## 🎮 功能演示

### 1. 刷题功能

1. 登录后点击"开始刷题"
2. 选择学科和难度
3. 系统会根据你的学习情况推荐题目
4. 答题后立即查看详细解析

### 2. 上传学习资料

1. 进入"资料"页面
2. 点击"上传资料"
3. 选择 PDF、图片或 Word 文档
4. 系统自动进行 OCR 识别和知识点提取
5. 查看处理进度和生成的题目

### 3. 查看学习报告

1. 进入"进度"页面
2. 查看知识点掌握度热力图
3. 分析答题准确率趋势
4. 识别薄弱知识点

### 4. 创建学习计划

1. 进入"计划"页面
2. 点击"创建新计划"
3. 选择目标知识点和每日目标
4. 系统根据 SRS 算法安排复习

## 🔧 常见问题

### Q1: 端口被占用怎么办？

如果默认端口被占用，可以修改 `docker-compose.yml`:

```yaml
services:
  backend:
    ports:
      - "8001:8000"  # 改为 8001
  
  frontend:
    ports:
      - "3001:3000"  # 改为 3001
```

### Q2: 如何查看日志？

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f celery_worker
```

### Q3: 如何重启服务？

```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart backend
```

### Q4: 如何停止所有服务？

```bash
# 停止但保留数据
docker-compose stop

# 停止并删除容器（数据保留在 volumes 中）
docker-compose down

# 停止并删除所有数据（慎用）
docker-compose down -v
```

### Q5: 数据库初始化失败？

```bash
# 手动执行数据库脚本
docker-compose exec postgres psql -U ailearnmate -d ailearnmate -f /docker-entrypoint-initdb.d/01-schema.sql
docker-compose exec mongodb mongosh --host localhost -u ailearnmate -p ailearnmate_pass /docker-entrypoint-initdb.d/01-schema.js
```

### Q6: AI 功能不工作？

检查是否配置了 AI API Key:
```bash
docker-compose exec backend python -c "from app.core.config import settings; print(settings.OPENAI_API_KEY)"
```

如果没有配置，编辑 `backend/.env` 并重启:
```bash
docker-compose restart backend celery_worker
```

## 📚 下一步

- 阅读 [系统架构文档](SYSTEM_ARCHITECTURE.md) 了解系统设计
- 查看 [API 文档](http://localhost:8000/docs) 了解接口细节
- 阅读 [部署指南](DEPLOYMENT.md) 准备生产环境部署
- 浏览 `ai-prompts/` 目录了解 AI 提示词设计

## 🛠️ 本地开发

如果你想进行本地开发而不使用 Docker:

### 后端开发

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env

# 启动开发服务器
uvicorn app.main:app --reload --port 8000

# 启动 Celery worker (另一个终端)
celery -A app.workers.celery_app worker --loglevel=info
```

### 前端开发

```bash
cd frontend
npm install

# 配置环境变量
cp .env.example .env.local

# 启动开发服务器
npm run dev
```

确保数据库服务（PostgreSQL, MongoDB, Redis）已在本地或 Docker 中运行。

## 💡 提示

1. **首次使用建议配置 OpenAI API Key** 以体验完整的 AI 功能
2. **定期备份数据库** - 查看部署文档了解备份方法
3. **监控资源使用** - 使用 `docker stats` 查看资源消耗
4. **查看任务状态** - 访问 http://localhost:5555 监控后台任务

## 🤝 获取帮助

- **文档**: 查看 `docs/` 目录下的文档
- **Issues**: [提交问题](https://github.com/mxmore/AILearnMate/issues)
- **讨论**: [GitHub Discussions](https://github.com/mxmore/AILearnMate/discussions)

## 📝 许可证

本项目采用 MIT 许可证。详见 [LICENSE](../LICENSE) 文件。
