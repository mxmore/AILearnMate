/**
 * MongoDB Seed Data for AILearnMate
 * 
 * Run with: mongosh < mongodb_seeds.js
 * Or use in your application startup
 */

// Switch to AILearnMate database
db = db.getSiblingDB('ailearn_mate');

// Drop existing collections (use with caution in production)
// db.ai_prompt_templates.drop();
// db.notification_queue.drop();

print('Seeding MongoDB collections...');

// AI Prompt Templates
db.ai_prompt_templates.insertMany([
  {
    _id: UUID(),
    name: 'question_extraction',
    taskType: 'extract_questions',
    description: '从文档中提取题目',
    systemPrompt: '你是一个专业的题目提取专家，能够从各种学习材料中准确识别和提取题目。',
    templateText: `请从以下文本中提取所有题目，包括题目类型、难度、选项（如果有）和答案。

文本内容：
{{content}}

要求：
1. 识别题目类型（单选、多选、判断、填空、简答等）
2. 评估难度等级（easy/medium/hard）
3. 提取完整的题目描述和选项
4. 识别正确答案
5. 提取解析内容（如果有）

请以JSON格式返回结果。`,
    variables: ['content'],
    modelConfig: {
      temperature: 0.3,
      maxTokens: 4000,
      topP: 0.9
    },
    isActive: true,
    version: 1,
    createdAt: new Date()
  },
  {
    _id: UUID(),
    name: 'answer_evaluation',
    taskType: 'evaluate_answer',
    description: '评估用户答案的正确性和质量',
    systemPrompt: '你是一个专业的学习评估专家，能够准确评估学生答案的质量，并提供有建设性的反馈。',
    templateText: `请评估以下学生答案：

题目：{{question_text}}
正确答案：{{correct_answer}}
学生答案：{{user_answer}}
题目类型：{{question_type}}

请提供：
1. 答案是否正确（true/false）
2. 如果部分正确，给出部分分数（0-100）
3. 具体的反馈说明，指出答案的优点和不足
4. 改进建议

请以JSON格式返回结果。`,
    variables: ['question_text', 'correct_answer', 'user_answer', 'question_type'],
    modelConfig: {
      temperature: 0.5,
      maxTokens: 1000,
      topP: 0.95
    },
    isActive: true,
    version: 1,
    createdAt: new Date()
  },
  {
    _id: UUID(),
    name: 'study_plan_generation',
    taskType: 'create_study_plan',
    description: '生成个性化学习计划',
    systemPrompt: '你是一个专业的学习规划师，能够根据学生的目标和现状制定科学合理的学习计划。',
    templateText: `请为学生制定学习计划：

学生信息：
- 当前水平：{{current_level}}
- 学习目标：{{learning_goals}}
- 可用时间：每天{{daily_time}}分钟，共{{total_days}}天
- 偏好：{{preferences}}

科目：{{subject_name}}
知识点：{{knowledge_points}}

请提供：
1. 学习阶段划分
2. 每个阶段的目标和任务
3. 具体的时间安排
4. 推荐的学习资源
5. 里程碑和检查点

请以JSON格式返回结果。`,
    variables: ['current_level', 'learning_goals', 'daily_time', 'total_days', 'preferences', 'subject_name', 'knowledge_points'],
    modelConfig: {
      temperature: 0.7,
      maxTokens: 2000,
      topP: 0.95
    },
    isActive: true,
    version: 1,
    createdAt: new Date()
  },
  {
    _id: UUID(),
    name: 'explanation_generation',
    taskType: 'explain_solution',
    description: '生成题目解答说明',
    systemPrompt: '你是一个优秀的教师，能够用清晰易懂的方式解释复杂的概念和问题。',
    templateText: `请为以下题目提供详细解答：

题目：{{question_text}}
答案：{{correct_answer}}
难度：{{difficulty}}
知识点：{{knowledge_points}}

请提供：
1. 题目分析（考察的知识点和解题思路）
2. 详细的解答步骤
3. 关键概念解释
4. 易错点提醒
5. 相关知识扩展

请用清晰的结构和通俗的语言讲解。`,
    variables: ['question_text', 'correct_answer', 'difficulty', 'knowledge_points'],
    modelConfig: {
      temperature: 0.6,
      maxTokens: 1500,
      topP: 0.9
    },
    isActive: true,
    version: 1,
    createdAt: new Date()
  }
]);

print('AI prompt templates seeded successfully');

// Sample active study session (for testing)
db.active_study_sessions.insertOne({
  _id: UUID(),
  sessionId: UUID(),
  userId: UUID(), // Replace with actual user ID
  sessionType: 'practice',
  currentState: {
    currentQuestionIndex: 0,
    startedAt: new Date(),
    lastActivityAt: new Date(),
    isPaused: false
  },
  questions: [],
  performance: {
    questionsAnswered: 0,
    correctAnswers: 0,
    currentStreak: 0,
    longestStreak: 0
  },
  configuration: {
    difficulty: 'medium',
    questionCount: 20,
    timeLimit: 3600
  },
  expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
  createdAt: new Date()
});

print('Sample study session created');

// Create indexes
print('Creating indexes...');

// AI Prompt Templates indexes
db.ai_prompt_templates.createIndex({ name: 1 }, { unique: true });
db.ai_prompt_templates.createIndex({ taskType: 1 });
db.ai_prompt_templates.createIndex({ isActive: 1 });

// User Activity Logs indexes
db.user_activity_logs.createIndex({ userId: 1, timestamp: -1 });
db.user_activity_logs.createIndex({ activityType: 1, timestamp: -1 });
db.user_activity_logs.createIndex({ timestamp: 1 }, { expireAfterSeconds: 7776000 }); // 90 days TTL

// Question Metadata indexes
db.question_metadata.createIndex({ questionId: 1 }, { unique: true });
db.question_metadata.createIndex({ 'analytics.totalAttempts': -1 });
db.question_metadata.createIndex({ lastUpdated: -1 });

// AI Chat Conversations indexes
db.ai_chat_conversations.createIndex({ conversationId: 1 }, { unique: true });
db.ai_chat_conversations.createIndex({ userId: 1, createdAt: -1 });
db.ai_chat_conversations.createIndex({ contextType: 1 });
db.ai_chat_conversations.createIndex({ isArchived: 1 });

// Learning Journeys indexes
db.learning_journeys.createIndex({ userId: 1 }, { unique: true });
db.learning_journeys.createIndex({ lastUpdated: -1 });

// Active Study Sessions indexes
db.active_study_sessions.createIndex({ sessionId: 1 }, { unique: true });
db.active_study_sessions.createIndex({ userId: 1, createdAt: -1 });
db.active_study_sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL

// Document Processing Logs indexes
db.document_processing_logs.createIndex({ processingId: 1 }, { unique: true });
db.document_processing_logs.createIndex({ userId: 1, createdAt: -1 });
db.document_processing_logs.createIndex({ overallStatus: 1 });

// Notification Queue indexes
db.notification_queue.createIndex({ notificationId: 1 }, { unique: true });
db.notification_queue.createIndex({ userId: 1, status: 1, createdAt: -1 });
db.notification_queue.createIndex({ status: 1, scheduledFor: 1 });
db.notification_queue.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL

// Computation Cache indexes
db.computation_cache.createIndex({ cacheKey: 1 }, { unique: true });
db.computation_cache.createIndex({ cacheType: 1, userId: 1 });
db.computation_cache.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL

print('Indexes created successfully');
print('MongoDB seeding completed!');
