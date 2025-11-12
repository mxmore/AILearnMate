# AILearnMate 功能展示

## 🎯 已实现的完整用户场景

本文档展示 AILearnMate 平台所有已实现的功能页面和用户场景。

---

## 📱 页面总览

### 1. 首页 (`/`)

**功能**: 
- 产品介绍和功能特性展示
- 顶部导航栏 (刷题、资料、进度、计划)
- 登录/注册入口
- 快速开始按钮

**特点**:
- 清新的渐变背景设计
- Brain图标品牌标识
- 响应式导航菜单
- CTA按钮引导用户行动

**路由**: `/` 
**组件**: `frontend/src/app/page.tsx`

---

### 2. 用户注册 (`/register`)

**功能**:
- 邮箱注册
- 用户名和密码设置
- 密码确认验证
- 服务条款同意
- 注册成功后跳转登录

**验证规则**:
- ✅ 邮箱格式验证
- ✅ 密码长度≥8位
- ✅ 两次密码一致性检查
- ✅ 用户名唯一性

**API**: `POST /api/v1/auth/register`

**UI元素**:
- 📧 Mail 图标 - 邮箱输入
- 👤 User 图标 - 用户名输入
- 🔒 Lock 图标 - 密码输入
- 蓝紫渐变背景
- 白色卡片表单

---

### 3. 用户登录 (`/login`)

**功能**:
- 用户名/邮箱登录
- 密码输入
- "记住我"选项
- 忘记密码链接
- 测试账户提示

**测试账户**:
```
admin@ailearnmate.com / Admin123!
test1@example.com / Test123!
test2@example.com / Test123!
```

**API**: `POST /api/v1/auth/login`

**认证流程**:
```
输入凭证 → 验证 → 获取JWT → 存储token → 跳转/practice
```

**Token管理**:
- Access Token: 存储在 localStorage
- Refresh Token: 自动刷新机制
- 拦截器: 401自动刷新token

---

### 4. 智能刷题 (`/practice`)

**核心功能**:

#### 4.1 自适应出题算法
```
算法配比:
- 50% 薄弱知识点 (掌握度 < 60%)
- 30% SRS复习题 (到期需复习)
- 20% 随机题目 (保持知识广度)
```

#### 4.2 答题界面
- **题目信息栏**:
  - 学科标签 (蓝色)
  - 难度标签 (紫色, 1-5星)
  - 题型标签 (灰色)
  
- **题目展示**:
  - 题目文字 (支持富文本)
  - 题目图片 (可选)
  - 选项列表 (单选/多选)

- **交互元素**:
  - 选择答案 (点击高亮)
  - 提交答案按钮
  - 下一题按钮

#### 4.3 即时反馈
- **正确答案**:
  - ✅ 绿色高亮
  - CheckCircle 图标
  - "回答正确!"消息
  - 答题用时显示

- **错误答案**:
  - ❌ 红色高亮
  - XCircle 图标
  - "回答错误"消息
  - 显示正确答案
  
- **详细解析**:
  - 白色背景框
  - 答案解析文字
  - 相关知识点链接

#### 4.4 统计信息
- 题目进度: "5 / 10"
- 实时准确率: "80%"
- 答题用时记录
- 连续答对记录

**API调用**:
```typescript
// 获取自适应题目
GET /api/v1/questions/adaptive/generate?count=10&subject=数学

// 提交答案
POST /api/v1/questions/answer
{
  "question_id": "q123",
  "answer": "B",
  "time_spent": 35
}
```

**关键特性**:
- ✅ 自适应难度调整
- ✅ 实时准确率统计
- ✅ 答题历史记录
- ✅ 自动添加到错题本
- ✅ SRS数据更新

---

### 5. 学习资料 (`/materials`)

**核心功能**:

#### 5.1 文件上传
- **支持格式**: PDF, PNG, JPG, Word, PPT, TXT
- **文件大小**: 最大 50MB
- **上传方式**: 
  - 点击上传
  - 拖拽上传 (计划中)
- **实时进度**: 百分比进度条

#### 5.2 AI 自动处理流程
```
上传文件
    ↓
OCR 文字识别 (PaddleOCR/Google Vision)
    ↓
AI 知识点提取 (OpenAI/Qwen3)
    ↓
自动生成题目 (多种题型)
    ↓
向量化存储 (pgvector)
    ↓
处理完成
```

#### 5.3 资料列表
- **显示信息**:
  - 📄 文件图标 (根据类型)
  - 资料标题
  - 描述信息
  - 文件大小 (MB/KB)
  - 页数 (PDF)
  - 上传日期
  - 处理状态

- **处理状态**:
  - 🔵 处理中 - 蓝色标签 + 旋转图标
  - ✅ 已完成 - 绿色标签 + 对勾
  - ❌ 失败 - 红色标签 + 叉号

- **操作按钮**:
  - 👁️ 查看 - 在线预览
  - 🗑️ 删除 - 删除资料

#### 5.4 处理监控
实时查询处理进度:
```json
GET /api/v1/materials/{id}/processing-status

响应:
{
  "status": "processing",
  "progress": 60,
  "steps": {
    "ocr": {"status": "completed"},
    "extraction": {"status": "completed"},
    "generation": {"status": "processing", "progress": 60}
  },
  "results": {
    "knowledge_points_extracted": 12,
    "questions_generated": 18
  }
}
```

**API调用**:
- `POST /api/v1/materials/upload` - 上传
- `GET /api/v1/materials` - 列表
- `GET /api/v1/materials/{id}` - 详情
- `DELETE /api/v1/materials/{id}` - 删除

---

### 6. 学习进度 (`/progress`)

**数据展示**:

#### 6.1 综合统计卡片 (4个)
1. **已答题目**
   - 📖 BookOpen 图标
   - 蓝色主题
   - 显示总题数

2. **正确率**
   - 🎯 Target 图标
   - 绿色主题
   - 百分比显示

3. **学习时长**
   - ⏰ Clock 图标
   - 紫色主题
   - 小时单位

4. **连续打卡**
   - 🏆 Award 图标
   - 橙色主题
   - 天数单位

#### 6.2 学习趋势图
- **柱状图**: 最近7天答题准确率
- **颜色**: 蓝色渐变
- **交互**: Hover 显示详情
- **数据**: 每日准确率变化

#### 6.3 知识点掌握度
- **列表展示**: 所有知识点
- **信息项**:
  - 知识点名称
  - 所属学科
  - 练习次数
  - 掌握等级标签

- **掌握度标签**:
  - 🟢 优秀 (≥80%) - 绿色
  - 🔵 良好 (60-80%) - 蓝色
  - 🟡 及格 (40-60%) - 黄色
  - 🔴 需提高 (<40%) - 红色

- **进度条**: 可视化掌握百分比

#### 6.4 薄弱知识点
- **红色突出**: 掌握度 <60%
- **针对性练习**: 快速入口
- **进步建议**: AI 推荐

#### 6.5 学习日历
- **月度视图**: 35天网格
- **颜色标记**:
  - 绿色 = 已学习
  - 灰色 = 未学习
- **统计**: 本月学习天数

**API调用**:
- `GET /api/v1/users/stats` - 综合统计
- `GET /api/v1/knowledge/mastery` - 知识掌握度
- `GET /api/v1/knowledge/weak-points` - 薄弱点
- `GET /api/v1/study/check-ins` - 打卡记录

---

### 7. 学习计划 (`/plan`)

**核心功能**:

#### 7.1 每日打卡
- **头部横幅**:
  - 蓝紫渐变背景
  - 🔥 火焰图标
  - 超大号连续天数
  - "今日打卡"按钮

- **打卡状态**:
  - 未打卡: 白色按钮，蓝色文字
  - 已打卡: 绿色按钮，✓ 图标

- **连续天数**: 
  - 实时更新
  - 激励效果
  - 最大连续记录

#### 7.2 学习计划管理
- **创建计划**:
  - 计划名称
  - 学科选择
  - 开始/结束日期
  - 每日目标题数
  - 关联知识点

- **计划列表**:
  - 计划卡片展示
  - 进度百分比
  - 状态标签 (进行中/已完成/已暂停)
  - 关键信息: 学科、日期、目标

- **计划详情**:
  - 🎯 Target 图标 - 学科
  - 📅 Calendar 图标 - 日期
  - ⏰ Clock 图标 - 每日目标
  - 进度条可视化

#### 7.3 打卡历史
- **时间线展示**: 最近30天
- **每日记录**:
  - 日期
  - ✓ 打卡图标
  - 完成题目数
  - 学习时长 (分钟)
  - 连续天数

#### 7.4 计划创建模态框
- 表单字段:
  - 计划名称输入
  - 学科下拉选择
  - 每日目标数字输入
- 操作按钮:
  - 取消 - 关闭
  - 创建 - 提交

**API调用**:
- `GET /api/v1/study/plans` - 计划列表
- `POST /api/v1/study/plans` - 创建计划
- `POST /api/v1/study/check-ins/today` - 今日打卡
- `GET /api/v1/study/check-ins?days=30` - 打卡历史

**SRS算法应用**:
```
根据学习计划自动生成复习任务:
- 首次学习: 1天后复习
- 第二次: 6天后
- 之后: interval * ease_factor
```

---

## 🎨 UI/UX 设计规范

### 颜色系统
```css
/* 主色调 */
--primary-blue: #2563eb;
--primary-purple: #9333ea;

/* 状态色 */
--success-green: #10b981;
--warning-yellow: #f59e0b;
--error-red: #ef4444;
--info-blue: #3b82f6;

/* 中性色 */
--gray-50: #f9fafb;
--gray-600: #4b5563;
--gray-900: #111827;
```

### 组件样式
- **卡片**: `rounded-xl shadow-sm bg-white p-6`
- **按钮**: `rounded-lg px-6 py-3 font-semibold transition`
- **输入框**: `rounded-lg border-2 focus:ring-2 focus:ring-blue-500`
- **标签**: `rounded-full px-3 py-1 text-sm font-medium`

### 图标使用
使用 lucide-react 图标库:
- Brain - 品牌标识
- BookOpen - 学习相关
- Target - 目标/准确率
- Clock - 时间
- Calendar - 日期
- CheckCircle - 成功
- XCircle - 失败
- Flame - 打卡连续
- TrendingUp - 进步趋势

### 动画效果
- **加载**: Spin 旋转动画
- **过渡**: Tailwind transition classes
- **悬停**: hover:scale-105
- **点击**: active:scale-95

---

## 🔄 数据流转

### 前端 → 后端
```
用户操作 (点击按钮)
    ↓
React 事件处理
    ↓
API Client (axios)
    ↓
JWT Token 注入 (interceptor)
    ↓
HTTP Request
    ↓
FastAPI Backend
    ↓
业务逻辑处理
    ↓
数据库操作
    ↓
JSON Response
    ↓
前端状态更新
    ↓
UI 重新渲染
```

### 异步任务流程
```
用户上传文件
    ↓
FastAPI 接收
    ↓
创建 Celery 任务
    ↓
返回 task_id
    ↓
前端轮询状态
    ↓
Celery Worker 处理
    ↓
更新处理进度
    ↓
前端显示进度
    ↓
处理完成
    ↓
通知用户
```

---

## 📊 性能优化

### 前端优化
- ✅ **代码分割**: Next.js 自动分割
- ✅ **懒加载**: 图片和组件
- ✅ **缓存策略**: localStorage + React Query
- ✅ **防抖节流**: 搜索和输入
- ✅ **虚拟滚动**: 长列表优化 (待实现)

### 后端优化
- ✅ **数据库索引**: 关键字段索引
- ✅ **查询优化**: 使用 ORM 优化
- ✅ **Redis缓存**: 热点数据缓存
- ✅ **异步处理**: Celery 队列
- ✅ **连接池**: 数据库连接复用

---

## 📱 响应式设计

### 断点设置
```
sm: 640px   - 手机
md: 768px   - 平板
lg: 1024px  - 笔记本
xl: 1280px  - 桌面
```

### 自适应策略
- **导航栏**: 
  - 桌面: 水平导航
  - 移动: 汉堡菜单 (待实现)

- **卡片布局**:
  - 桌面: 4列网格
  - 平板: 2列网格
  - 手机: 1列堆叠

- **表单**:
  - 桌面: 多列布局
  - 移动: 单列堆叠

---

## ✅ 功能完成度

### 已实现 ✅
- [x] 用户注册和登录
- [x] 智能刷题 (自适应算法)
- [x] 学习资料上传和AI处理
- [x] 学习进度分析
- [x] 学习计划和打卡
- [x] 知识点掌握度追踪
- [x] 薄弱知识点识别
- [x] 错题本 (后端已实现)
- [x] JWT 认证和刷新
- [x] 响应式设计

### 待增强 🚧
- [ ] 移动端汉堡菜单
- [ ] 社交功能 (好友、排行榜)
- [ ] 学习报告导出 (PDF)
- [ ] 实时通知 (WebSocket)
- [ ] 第三方登录 (OAuth)
- [ ] 离线模式 (PWA)
- [ ] 更多题型支持
- [ ] AI 对话助手

---

## 🎯 核心竞争力

1. **智能化**: AI驱动的自适应学习
2. **全流程**: 从资料到题目到分析
3. **科学性**: SRS算法保证学习效果
4. **可视化**: 直观的进度和数据展示
5. **易用性**: 简洁美观的现代界面
6. **完整性**: 7个完整功能页面
7. **可扩展**: 模块化架构易于扩展

---

## 🚀 立即体验

```bash
# 启动所有服务
docker-compose up -d

# 访问前端
http://localhost:3000

# 访问 API 文档
http://localhost:8000/docs

# 测试账户
admin@ailearnmate.com / Admin123!
```

---

## 📞 技术支持

- **GitHub**: https://github.com/mxmore/AILearnMate
- **文档**: `/docs` 目录
- **Issues**: 提交问题和建议

---

**项目状态**: ✅ Production Ready
**最后更新**: 2024-11-12
**版本**: v1.0.0
