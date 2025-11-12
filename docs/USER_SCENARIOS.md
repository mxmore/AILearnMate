# AILearnMate 用户场景文档

## 概述

本文档详细描述 AILearnMate 平台的核心用户场景和交互流程，帮助理解系统如何满足学习者的实际需求。

## 核心用户场景

### 场景 1: 新用户注册和首次使用

#### 用户故事
> 作为一名初三学生，我想使用 AILearnMate 备考，需要先注册账户并设置学习偏好。

#### 流程步骤
1. **访问首页** (`/`)
   - 浏览平台介绍和功能特性
   - 点击"免费注册"按钮

2. **注册账户** (`/register`)
   - 输入邮箱、用户名和密码
   - 同意服务条款
   - 提交注册信息
   - 系统创建用户账户（`POST /api/v1/auth/register`）

3. **登录系统** (`/login`)
   - 输入用户名和密码
   - 系统验证身份并返回 JWT token
   - 自动跳转到刷题页面

4. **设置学习偏好**
   - 选择主要学习的学科（数学、英语、物理等）
   - 设置每日学习目标
   - 系统保存用户偏好

#### 技术实现
- **前端页面**: `/register`, `/login`
- **API 端点**: 
  - `POST /api/v1/auth/register`
  - `POST /api/v1/auth/login`
  - `PUT /api/v1/users/me`
- **数据表**: `users`, `user_preferences`

---

### 场景 2: 自适应智能刷题

#### 用户故事
> 作为学生，我想通过刷题提高数学成绩，系统应该根据我的薄弱知识点智能推荐题目。

#### 流程步骤
1. **进入刷题页面** (`/practice`)
   - 查看当前学习统计（已答题数、正确率）
   - 系统自动生成自适应题目集

2. **智能出题算法**
   ```
   系统根据以下因素生成题目：
   - 50% 来自薄弱知识点（掌握度 < 60%）
   - 30% 来自需要复习的题目（SRS 算法判断）
   - 20% 随机题目（保持知识广度）
   ```

3. **答题过程**
   - 查看题目内容、难度和类型
   - 选择答案
   - 点击"提交答案"
   - 系统调用 API: `POST /api/v1/questions/answer`

4. **即时反馈**
   - 显示答案正确性（✓ 或 ✗）
   - 展示正确答案和详细解析
   - 记录答题时长和准确率
   - 更新知识点掌握度

5. **继续学习**
   - 点击"下一题"继续练习
   - 完成所有题目后跳转到进度页面
   - 查看本次学习成果

#### 技术实现
- **前端页面**: `/practice`
- **API 端点**:
  - `GET /api/v1/questions/adaptive/generate` - 生成自适应题目
  - `POST /api/v1/questions/answer` - 提交答案
  - `GET /api/v1/users/stats` - 获取学习统计
- **核心算法**: 
  - SRS (Spaced Repetition System) - SuperMemo SM-2
  - 知识点掌握度计算
  - 自适应难度调整
- **数据表**: `questions`, `study_records`, `user_knowledge_mastery`, `wrong_questions`

#### 示例数据流
```json
// 请求自适应题目
GET /api/v1/questions/adaptive/generate?count=10&subject=数学

// 响应
{
  "questions": [
    {
      "id": "q123",
      "type": "single_choice",
      "subject": "数学",
      "difficulty": 3,
      "question": "方程 2x + 5 = 13 的解是？",
      "options": ["A. x = 3", "B. x = 4", "C. x = 5", "D. x = 6"],
      "knowledge_points": ["一元一次方程"],
      "reason": "weak_point"  // 薄弱知识点
    },
    // ... 更多题目
  ],
  "strategy": {
    "weak_point_count": 5,
    "review_count": 3,
    "random_count": 2
  }
}

// 提交答案
POST /api/v1/questions/answer
{
  "question_id": "q123",
  "answer": "B",
  "time_spent": 35  // 秒
}

// 响应
{
  "is_correct": true,
  "correct_answer": "B",
  "explanation": "2x + 5 = 13，移项得 2x = 8，两边同时除以2，得 x = 4",
  "time_spent": 35,
  "mastery_updated": {
    "knowledge_point": "一元一次方程",
    "old_mastery": 0.65,
    "new_mastery": 0.72
  },
  "srs_data": {
    "next_review_at": "2024-11-14T10:00:00Z",
    "ease_factor": 2.5,
    "interval_days": 2
  }
}
```

---

### 场景 3: 上传学习资料并自动生成题目

#### 用户故事
> 作为学生，我想上传老师发的 PDF 复习资料，让 AI 自动提取知识点并生成练习题。

#### 流程步骤
1. **进入资料页面** (`/materials`)
   - 查看已上传的资料列表
   - 点击"上传新资料"

2. **上传文件**
   - 选择文件（支持 PDF、图片、Word、PPT）
   - 可选：填写资料标题和描述
   - 点击上传
   - 系统调用: `POST /api/v1/materials/upload`

3. **异步处理流程** (Celery Worker)
   ```
   步骤 1: OCR 识别
   - 使用 PaddleOCR 或 Google Vision
   - 提取文字内容
   - 保存为纯文本
   
   步骤 2: AI 知识点提取
   - 调用 OpenAI/Qwen3 API
   - 使用 knowledge_extraction.txt 提示词
   - 解析返回的 JSON 格式知识点
   - 保存到数据库
   
   步骤 3: AI 自动出题
   - 针对每个知识点
   - 使用 question_generation.txt 提示词
   - 生成多种题型
   - 调用质量评估
   
   步骤 4: 向量化
   - 使用 text-embedding-3-small
   - 生成知识点向量
   - 存储到 pgvector
   ```

4. **查看处理状态**
   - 实时显示处理进度
   - 状态：处理中 → 已完成
   - 查看生成的题目数量

5. **使用资料**
   - 点击"查看"阅读原文
   - 查看提取的知识点
   - 直接练习生成的题目

#### 技术实现
- **前端页面**: `/materials`
- **API 端点**:
  - `POST /api/v1/materials/upload` - 上传文件
  - `GET /api/v1/materials/{id}/processing-status` - 查询状态
  - `GET /api/v1/materials` - 获取资料列表
  - `DELETE /api/v1/materials/{id}` - 删除资料
- **Celery 任务**: `material_processing.py`
- **AI 提示词**: 
  - `knowledge_extraction.txt`
  - `question_generation.txt`
  - `quality_assessment.txt`
- **数据表**: `materials`, `material_processing_tasks`, `knowledge_points`, `questions`
- **存储**: MinIO/S3 for files

#### 处理状态追踪
```json
GET /api/v1/materials/mat123/processing-status

{
  "material_id": "mat123",
  "status": "processing",
  "progress": 60,
  "steps": {
    "ocr": {"status": "completed", "duration": 15.3},
    "extraction": {"status": "completed", "duration": 8.7},
    "generation": {"status": "processing", "progress": 60},
    "vectorization": {"status": "pending"}
  },
  "results": {
    "knowledge_points_extracted": 12,
    "questions_generated": 18
  }
}
```

---

### 场景 4: 查看学习进度和数据分析

#### 用户故事
> 作为学生，我想查看自己的学习进度，了解哪些知识点掌握得好，哪些需要加强。

#### 流程步骤
1. **进入进度页面** (`/progress`)
   - 系统加载用户学习数据

2. **查看综合统计**
   - 已答题目总数
   - 整体正确率
   - 累计学习时长
   - 连续打卡天数

3. **学习趋势图**
   - 最近7天答题准确率
   - 每日学习时长变化
   - 答题数量趋势

4. **知识点掌握度**
   - 按学科查看所有知识点
   - 每个知识点的掌握度百分比
   - 颜色区分：
     * 绿色 (≥80%): 优秀
     * 蓝色 (60-80%): 良好
     * 黄色 (40-60%): 及格
     * 红色 (<40%): 需提高

5. **薄弱知识点分析**
   - 列出掌握度 <60% 的知识点
   - 显示练习次数和正确率
   - 提供"针对性练习"快捷入口

6. **学习日历**
   - 月度学习日历视图
   - 标记每天是否完成学习
   - 可视化学习连续性

#### 技术实现
- **前端页面**: `/progress`
- **API 端点**:
  - `GET /api/v1/users/stats` - 综合统计
  - `GET /api/v1/knowledge/mastery` - 知识点掌握度
  - `GET /api/v1/knowledge/weak-points` - 薄弱知识点
  - `GET /api/v1/study/check-ins` - 打卡记录
- **数据来源**: `study_records`, `user_knowledge_mastery`, `study_check_ins`
- **可视化**: Recharts (前端图表库)

#### 知识点掌握度计算
```python
def calculate_mastery_level(user_id, knowledge_point_id):
    """
    计算知识点掌握度
    
    考虑因素:
    1. 正确率 (权重 50%)
    2. 练习次数 (权重 20%)
    3. 最近表现 (权重 20%)
    4. 难度递进 (权重 10%)
    """
    records = get_recent_records(user_id, knowledge_point_id, limit=20)
    
    # 正确率
    accuracy = sum(r.is_correct for r in records) / len(records)
    
    # 练习次数加成 (最多加 20%)
    practice_bonus = min(0.2, len(records) / 100 * 0.2)
    
    # 最近表现 (最近5次的权重更高)
    recent_accuracy = sum(r.is_correct for r in records[:5]) / 5
    
    # 难度递进 (能答对高难度题目加分)
    difficulty_bonus = calculate_difficulty_bonus(records)
    
    mastery_level = (
        accuracy * 0.5 +
        practice_bonus +
        recent_accuracy * 0.2 +
        difficulty_bonus * 0.1
    )
    
    return min(1.0, mastery_level)
```

---

### 场景 5: 创建学习计划并每日打卡

#### 用户故事
> 作为学生，我想创建一个为期30天的数学强化计划，每天做20道题，并坚持打卡。

#### 流程步骤
1. **进入计划页面** (`/plan`)
   - 查看当前连续打卡天数
   - 查看已有的学习计划

2. **创建新计划**
   - 点击"创建计划"
   - 填写计划信息：
     * 计划名称: "初中数学强化"
     * 学科: 数学
     * 开始日期: 今天
     * 结束日期: 30天后
     * 每日目标: 20道题
     * 关联知识点: 选择需要强化的知识点
   - 提交创建
   - API: `POST /api/v1/study/plans`

3. **执行计划**
   - 系统每天推荐题目（基于计划设置）
   - 完成每日目标后自动更新进度
   - 显示完成百分比

4. **每日打卡**
   - 完成学习后点击"今日打卡"
   - 系统记录打卡并更新连续天数
   - API: `POST /api/v1/study/check-ins/today`
   - 显示打卡成功动画

5. **查看打卡历史**
   - 最近30天的打卡记录
   - 每天的完成题目数
   - 每天的学习时长
   - 连续打卡天数变化

#### 技术实现
- **前端页面**: `/plan`
- **API 端点**:
  - `GET /api/v1/study/plans` - 获取计划列表
  - `POST /api/v1/study/plans` - 创建计划
  - `POST /api/v1/study/check-ins/today` - 打卡
  - `GET /api/v1/study/check-ins` - 打卡历史
- **数据表**: `study_plans`, `study_check_ins`, `study_sessions`
- **通知**: 每日学习提醒（可选）

#### SRS 复习计划
```python
def generate_review_schedule(plan_id, user_id):
    """
    基于 SuperMemo SM-2 算法生成复习计划
    
    参数:
    - E-Factor (ease_factor): 记忆难度系数 (初始 2.5)
    - Interval: 复习间隔天数
    - Quality: 回忆质量 (0-5)
    
    算法:
    - 首次复习: 1天后
    - 第二次复习: 6天后
    - 之后: interval = interval * ease_factor
    """
    
    # 获取所有需要复习的题目
    due_questions = get_due_for_review(user_id)
    
    schedule = []
    for question in due_questions:
        # 计算下次复习时间
        next_review = calculate_next_review_date(
            question.last_review_date,
            question.ease_factor,
            question.interval
        )
        
        schedule.append({
            'question_id': question.id,
            'next_review_date': next_review,
            'priority': calculate_priority(next_review)
        })
    
    return sorted(schedule, key=lambda x: x['priority'], reverse=True)
```

---

### 场景 6: 错题本重点复习

#### 用户故事
> 作为学生，我想重新练习之前答错的题目，直到完全掌握。

#### 流程步骤
1. **进入错题本**
   - 从导航栏选择"错题本"
   - 或从进度页面点击"错题复习"
   - API: `GET /api/v1/study/wrong-questions`

2. **查看错题列表**
   - 按学科筛选
   - 按掌握状态筛选（未掌握/已掌握）
   - 显示错误次数和最近错误时间

3. **重新练习**
   - 点击某个错题
   - 重新答题
   - 系统记录本次答题结果

4. **掌握状态更新**
   - 连续答对3次 → 标记为"已掌握"
   - 再次答错 → 重置状态为"未掌握"
   - 从错题本移除已完全掌握的题目

#### 技术实现
- **API 端点**: `GET /api/v1/study/wrong-questions`
- **数据表**: `wrong_questions`
- **逻辑**: 
  ```python
  def update_wrong_question_status(user_id, question_id, is_correct):
      wrong_q = get_wrong_question(user_id, question_id)
      
      if is_correct:
          wrong_q.consecutive_correct += 1
          if wrong_q.consecutive_correct >= 3:
              wrong_q.is_mastered = True
      else:
          wrong_q.consecutive_correct = 0
          wrong_q.error_count += 1
          wrong_q.last_error_at = now()
      
      wrong_q.save()
  ```

---

## 高级场景

### 场景 7: 知识点语义搜索

#### 用户故事
> 作为学生，我想搜索"勾股定理"相关的所有题目和知识点。

#### 流程步骤
1. 在搜索框输入"勾股定理"
2. 系统使用向量搜索（pgvector）
3. 返回语义相关的知识点和题目
4. API: `GET /api/v1/knowledge/search?query=勾股定理`

#### 技术实现
```python
# 向量化搜索
query_vector = openai.embeddings.create(
    model="text-embedding-3-small",
    input="勾股定理"
).data[0].embedding

# pgvector 查询
results = db.query(
    "SELECT *, embedding <-> $1 AS distance "
    "FROM knowledge_points "
    "WHERE embedding <-> $1 < 0.5 "
    "ORDER BY distance LIMIT 10",
    query_vector
)
```

---

### 场景 8: 学习报告生成和导出

#### 用户故事
> 作为家长，我想查看孩子本月的学习报告，了解学习情况。

#### 流程步骤
1. 选择时间范围（本周/本月/自定义）
2. 系统生成详细报告：
   - 学习时长统计
   - 答题数量和正确率
   - 知识点掌握度分布
   - 学科分布
   - 进步趋势
3. 导出为 PDF 或图片

#### 技术实现
- API: `GET /api/v1/users/report?start_date=2024-11-01&end_date=2024-11-30`
- 图表生成: Recharts
- PDF 导出: html2pdf 或后端生成

---

## 移动端适配场景

### 场景 9: 移动端刷题体验

#### 特点
- 响应式设计，自动适配小屏幕
- 手势操作：左滑查看解析，右滑下一题
- 离线模式：缓存题目，无网也能练习
- 快速模式：只显示题目和选项，节省流量

#### 技术实现
- Tailwind CSS 响应式类
- PWA (Progressive Web App)
- Service Worker 缓存策略

---

## 数据流转图

```
用户操作 → 前端页面 → API Gateway → 业务逻辑
                                      ↓
                            PostgreSQL / MongoDB
                                      ↓
                            Celery Worker (异步)
                                      ↓
                            OpenAI/Qwen3 (AI)
                                      ↓
                            结果返回 → 前端显示
```

---

## 性能指标

### 响应时间目标
- 页面加载: < 2秒
- API 响应: < 500ms
- 题目生成: < 3秒
- 文件上传: 进度实时更新
- 资料处理: 后台异步，1-5分钟完成

### 并发能力
- 支持 1000+ 并发用户
- 每秒处理 100+ API 请求
- Celery worker 池: 5-10 workers

---

## 总结

AILearnMate 通过以上场景覆盖了学习的完整流程：
1. ✅ 注册和登录
2. ✅ 智能刷题（自适应算法）
3. ✅ 资料上传和AI处理
4. ✅ 学习进度分析
5. ✅ 学习计划和打卡
6. ✅ 错题本复习
7. ✅ 知识点搜索
8. ✅ 学习报告导出

所有场景均已实现完整的前端页面和后端 API，可以直接使用和扩展。
