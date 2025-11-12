# AILearnMate 系统架构文档 (System Architecture)

## 产品目标 (Product Goals)

AILearnMate 是一个 AI 驱动的智能考试学习平台，旨在通过自适应学习算法和间隔重复系统 (SRS) 帮助学生高效备考。

### 核心价值
- **智能刷题**: AI 根据学习进度自适应出题，针对薄弱知识点重点训练
- **资料管理**: 支持上传 PDF/图片等学习资料，自动 OCR 识别并提取知识点和题目
- **学习计划**: 基于 SRS 算法的智能学习计划，合理安排复习时间
- **数据分析**: 详细的学习报告和进度追踪，可视化学习效果

## 功能清单 (Feature List)

### 1. 用户系统
- 用户注册/登录（邮箱、手机号、第三方登录）
- 个人资料管理
- 学习偏好设置

### 2. 题库系统
- 多学科题库（支持单选、多选、判断、填空、简答等题型）
- 题目标签和知识点关联
- 题目难度分级
- 题目质量评分
- 用户提交题目审核

### 3. 刷题功能
- 智能组卷（根据知识点薄弱程度和 SRS 时间）
- 实时答题和即时反馈
- 错题本自动收集
- 答题历史记录
- 答题统计分析

### 4. 学习资料管理
- 上传学习资料（PDF、图片、Word 等）
- OCR 识别文字内容
- AI 自动提取知识点
- AI 从资料中生成题目
- 资料分类和标签管理
- 在线阅读和标注

### 5. 学习计划与打卡
- 基于 SRS 算法的智能复习计划
- 每日学习任务推荐
- 学习打卡和连续天数统计
- 学习提醒通知

### 6. 学习报告
- 知识点掌握程度热力图
- 答题准确率趋势
- 学习时长统计
- 薄弱知识点分析
- 学习建议生成

### 7. 社区功能（可选）
- 题目讨论区
- 学习笔记分享
- 学习小组

## 系统架构 (System Architecture)

### 技术栈选型

#### 前端
- **框架**: Next.js 14+ (React 18+, TypeScript)
- **UI 组件库**: shadcn/ui + Tailwind CSS
- **状态管理**: Zustand / React Query
- **表单处理**: React Hook Form + Zod
- **图表**: Recharts / Chart.js
- **移动端适配**: 响应式设计 + PWA

#### 后端
- **Web 框架**: FastAPI (Python 3.11+)
- **异步任务队列**: Celery + Redis
- **API 文档**: OpenAPI (Swagger)
- **认证**: JWT + OAuth2
- **文件处理**: python-multipart, PyPDF2, Pillow

#### 数据库
- **关系型数据库**: PostgreSQL 15+ with pgvector extension
  - 用户数据、学习记录、系统配置
  - 向量化搜索（题目和知识点的语义搜索）
- **文档数据库**: MongoDB 6+
  - 题库数据（灵活的题目结构）
  - 学习资料元数据
  - 日志和事件记录

#### AI 服务
- **LLM**: OpenAI GPT-4 / Qwen3
- **向量化**: text-embedding-3-small / BGE-M3
- **OCR**: Tesseract / PaddleOCR / 第三方 API (Google Vision API)

#### 存储
- **对象存储**: MinIO / AWS S3 / Cloudflare R2
- **缓存**: Redis 7+

#### 部署与监控
- **容器化**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **监控**: Prometheus + Grafana
- **日志**: ELK Stack / Loki
- **告警**: AlertManager

### 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                         客户端层                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Web 应用    │  │  移动端 PWA   │  │   管理后台    │     │
│  │  (Next.js)   │  │  (Next.js)   │  │  (Next.js)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        API 网关层                             │
│                      (Nginx / Traefik)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       应用服务层                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  认证服务     │  │  题库服务     │  │  学习服务     │     │
│  │  (FastAPI)   │  │  (FastAPI)   │  │  (FastAPI)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  资料服务     │  │  分析服务     │  │  通知服务     │     │
│  │  (FastAPI)   │  │  (FastAPI)   │  │  (FastAPI)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      异步处理层                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ OCR Worker   │  │ 题目抽取Worker│  │ 向量化Worker  │     │
│  │  (Celery)    │  │  (Celery)    │  │  (Celery)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        数据层                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  PostgreSQL  │  │   MongoDB    │  │    Redis     │     │
│  │  (+ pgvector)│  │              │  │   (Cache)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐                       │
│  │  对象存储     │  │   AI 服务     │                       │
│  │  (MinIO/S3)  │  │ (OpenAI/Qwen)│                       │
│  └──────────────┘  └──────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

## 数据架构 (Data Architecture)

### PostgreSQL 表结构

#### users (用户表)
- id: UUID (主键)
- email: VARCHAR (唯一)
- phone: VARCHAR (唯一，可空)
- hashed_password: VARCHAR
- username: VARCHAR
- avatar_url: VARCHAR
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
- is_active: BOOLEAN
- is_verified: BOOLEAN

#### study_plans (学习计划表)
- id: UUID (主键)
- user_id: UUID (外键)
- name: VARCHAR
- description: TEXT
- start_date: DATE
- end_date: DATE
- status: ENUM (active, completed, paused)
- created_at: TIMESTAMP

#### study_records (学习记录表)
- id: UUID (主键)
- user_id: UUID (外键)
- question_id: VARCHAR (MongoDB 题目 ID)
- answer: JSONB
- is_correct: BOOLEAN
- time_spent: INTEGER (秒)
- answered_at: TIMESTAMP
- next_review_at: TIMESTAMP (SRS 计算的下次复习时间)
- review_count: INTEGER
- ease_factor: FLOAT (SRS 难度因子)

#### knowledge_points (知识点表)
- id: UUID (主键)
- subject: VARCHAR
- name: VARCHAR
- description: TEXT
- parent_id: UUID (外键，自关联，用于知识点层级)
- embedding: VECTOR(1536) (pgvector，用于语义搜索)
- created_at: TIMESTAMP

#### user_knowledge_mastery (用户知识点掌握度表)
- id: UUID (主键)
- user_id: UUID (外键)
- knowledge_point_id: UUID (外键)
- mastery_level: FLOAT (0-1，掌握程度)
- practice_count: INTEGER
- correct_count: INTEGER
- last_practiced_at: TIMESTAMP
- updated_at: TIMESTAMP

### MongoDB 集合结构

#### questions (题目集合)
```json
{
  "_id": "ObjectId",
  "type": "single_choice|multiple_choice|true_false|fill_blank|short_answer|essay",
  "subject": "数学|英语|物理|...",
  "difficulty": 1-5,
  "content": {
    "question": "题目内容",
    "options": ["A", "B", "C", "D"],
    "images": ["url1", "url2"]
  },
  "answer": {
    "correct": "A|B,C|true|答案文本",
    "explanation": "答案解析",
    "explanation_images": ["url1"]
  },
  "knowledge_points": ["UUID1", "UUID2"],
  "tags": ["tag1", "tag2"],
  "source": "用户上传|系统导入|AI生成",
  "quality_score": 0.0-1.0,
  "usage_count": 0,
  "correct_rate": 0.0-1.0,
  "created_by": "UUID",
  "created_at": "ISODate",
  "updated_at": "ISODate",
  "status": "draft|published|archived"
}
```

#### materials (学习资料集合)
```json
{
  "_id": "ObjectId",
  "user_id": "UUID",
  "title": "资料标题",
  "description": "资料描述",
  "type": "pdf|image|word|ppt",
  "file_url": "存储路径",
  "file_size": 1024,
  "page_count": 10,
  "processing_status": "pending|processing|completed|failed",
  "extracted_content": [
    {
      "page": 1,
      "text": "提取的文本内容",
      "images": ["url1", "url2"],
      "knowledge_points": ["UUID1"],
      "generated_questions": ["ObjectId1", "ObjectId2"]
    }
  ],
  "knowledge_points": ["UUID1", "UUID2"],
  "tags": ["tag1", "tag2"],
  "created_at": "ISODate",
  "updated_at": "ISODate"
}
```

#### study_sessions (学习会话集合)
```json
{
  "_id": "ObjectId",
  "user_id": "UUID",
  "session_type": "practice|review|mock_exam",
  "question_ids": ["ObjectId1", "ObjectId2"],
  "started_at": "ISODate",
  "ended_at": "ISODate",
  "total_questions": 20,
  "correct_count": 15,
  "time_spent": 1200,
  "avg_time_per_question": 60,
  "accuracy": 0.75
}
```

## AI Agent 工作流程

### 1. 资料处理流水线

```
上传文件 → 队列任务 → OCR 识别 → 文本清洗 → 
知识点提取 → 向量化 → 题目生成 → 质量评估 → 入库
```

**详细步骤**:
1. **文件上传**: 用户上传 PDF/图片等文件到对象存储
2. **创建任务**: 系统创建 Celery 任务，状态设为 pending
3. **OCR 识别**: Worker 调用 OCR 服务识别文本
4. **文本清洗**: 去除噪声、格式化文本
5. **知识点提取**: 调用 LLM 提取文本中的知识点，结构化存储
6. **向量化**: 使用 embedding 模型生成知识点向量，存入 pgvector
7. **题目生成**: 调用 LLM 基于内容生成题目
8. **质量评估**: 使用专门的 prompt 评估题目质量
9. **入库**: 将高质量题目存入 MongoDB

### 2. 自适应出题算法

```python
# 伪代码
def generate_adaptive_questions(user_id, count=10):
    # 1. 获取用户知识点掌握度
    mastery_data = get_user_knowledge_mastery(user_id)
    
    # 2. 识别薄弱知识点（掌握度 < 0.6）
    weak_points = [kp for kp in mastery_data if kp.mastery_level < 0.6]
    
    # 3. 获取需要复习的题目（基于 SRS）
    due_questions = get_due_questions(user_id)
    
    # 4. 组合策略：
    #    - 50% 薄弱知识点的新题
    #    - 30% 到期复习题
    #    - 20% 随机题（保持广度）
    questions = []
    questions.extend(get_questions_by_knowledge_points(weak_points, count * 0.5))
    questions.extend(due_questions[:int(count * 0.3)])
    questions.extend(get_random_questions(count * 0.2))
    
    return questions[:count]
```

### 3. SRS (间隔重复系统) 算法

使用改进的 SuperMemo SM-2 算法:

```python
def calculate_next_review(ease_factor, interval, quality):
    """
    ease_factor: 难度系数 (>=1.3)
    interval: 当前间隔天数
    quality: 答题质量 (0-5)
        5: 完美
        4: 正确但犹豫
        3: 正确但很困难
        2: 错误但记得
        1: 错误且不记得
        0: 完全忘记
    """
    if quality >= 3:
        if interval == 0:
            new_interval = 1
        elif interval == 1:
            new_interval = 6
        else:
            new_interval = interval * ease_factor
        
        # 更新难度系数
        new_ease = ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        new_ease = max(1.3, new_ease)
    else:
        new_interval = 1
        new_ease = ease_factor
    
    next_review_date = datetime.now() + timedelta(days=new_interval)
    return next_review_date, new_ease, new_interval
```

## 安全与合规

### 1. 认证与授权
- JWT Token 认证，access_token (15分钟) + refresh_token (7天)
- RBAC 角色权限控制：普通用户、VIP用户、管理员
- API Rate Limiting: 基于 IP 和 用户 ID

### 2. 数据安全
- 密码使用 bcrypt 加密存储
- 敏感数据加密传输 (HTTPS)
- SQL 注入防护（使用 ORM 参数化查询）
- XSS 防护（前端输入验证和转义）
- CSRF Token 保护

### 3. 隐私保护
- 用户数据最小化收集
- 数据脱敏（日志中不记录敏感信息）
- 遵守 GDPR 和国内数据保护法规
- 提供数据导出和删除功能

### 4. 文件安全
- 文件类型白名单验证
- 文件大小限制（单个文件 < 50MB）
- 病毒扫描（集成 ClamAV）
- 文件访问权限控制

## MVP 里程碑

### Phase 1: 核心功能 (4-6 周)
- [ ] 用户系统（注册、登录、个人资料）
- [ ] 基础题库管理
- [ ] 刷题功能（答题、查看解析、错题本）
- [ ] 简单的学习记录统计

### Phase 2: AI 增强 (4-6 周)
- [ ] 文件上传和 OCR 识别
- [ ] AI 自动提取知识点
- [ ] AI 生成题目
- [ ] 自适应出题算法

### Phase 3: 高级功能 (4-6 周)
- [ ] SRS 智能复习计划
- [ ] 学习报告和数据分析
- [ ] 知识图谱可视化
- [ ] 学习打卡和提醒

### Phase 4: 优化与扩展 (持续)
- [ ] 性能优化
- [ ] 社区功能
- [ ] 移动 App (React Native)
- [ ] 多语言支持

## 关键性能指标 (KPIs)

### 技术指标
- API 响应时间 < 200ms (P95)
- 题目生成时间 < 30s
- OCR 识别准确率 > 95%
- 系统可用性 > 99.9%

### 业务指标
- 用户日活 (DAU)
- 平均每日答题数
- 学习计划完成率
- 用户留存率（次日、7日、30日）
- AI 生成题目的质量分数 > 0.8
