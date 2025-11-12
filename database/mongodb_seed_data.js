// AILearnMate MongoDB 种子数据
// 版本: 1.0

// 使用 ailearnmate 数据库
db = db.getSiblingDB('ailearnmate');

// ============================================================
// 插入题目数据
// ============================================================

print("Inserting sample questions...");

// 数学题目
db.questions.insertMany([
  {
    type: "single_choice",
    subject: "数学",
    difficulty: 2,
    content: {
      question: "方程 2x + 5 = 13 的解是？",
      options: ["A. x = 3", "B. x = 4", "C. x = 5", "D. x = 6"],
      images: []
    },
    answer: {
      correct: "B",
      explanation: "2x + 5 = 13，移项得 2x = 8，两边同时除以2，得 x = 4",
      explanation_images: []
    },
    knowledge_points: ["f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66"],
    tags: ["一元一次方程", "基础"],
    source: "系统导入",
    quality_score: 0.92,
    usage_count: 45,
    correct_rate: 0.82,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  },
  {
    type: "single_choice",
    subject: "数学",
    difficulty: 3,
    content: {
      question: "在三角形ABC中，如果∠A = 50°，∠B = 60°，那么∠C等于多少度？",
      options: ["A. 60°", "B. 70°", "C. 80°", "D. 90°"],
      images: []
    },
    answer: {
      correct: "B",
      explanation: "三角形内角和为180°，所以∠C = 180° - 50° - 60° = 70°",
      explanation_images: []
    },
    knowledge_points: ["h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88"],
    tags: ["三角形", "内角和"],
    source: "系统导入",
    quality_score: 0.88,
    usage_count: 38,
    correct_rate: 0.75,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  },
  {
    type: "multiple_choice",
    subject: "数学",
    difficulty: 4,
    content: {
      question: "下列哪些是等腰三角形的性质？（多选）",
      options: [
        "A. 两腰相等",
        "B. 两底角相等",
        "C. 三边相等",
        "D. 顶角的平分线、底边上的中线和高重合"
      ],
      images: []
    },
    answer: {
      correct: "A,B,D",
      explanation: "等腰三角形的性质包括：两腰相等、两底角相等、顶角的平分线与底边上的中线和高重合。三边相等是等边三角形的性质。",
      explanation_images: []
    },
    knowledge_points: ["h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88"],
    tags: ["等腰三角形", "性质"],
    source: "系统导入",
    quality_score: 0.90,
    usage_count: 32,
    correct_rate: 0.65,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  }
]);

// 英语题目
db.questions.insertMany([
  {
    type: "single_choice",
    subject: "英语",
    difficulty: 2,
    content: {
      question: "I _____ to the cinema yesterday.",
      options: ["A. go", "B. went", "C. will go", "D. have gone"],
      images: []
    },
    answer: {
      correct: "B",
      explanation: "句中有明确的过去时间状语 'yesterday'，所以应该使用一般过去时 'went'。",
      explanation_images: []
    },
    knowledge_points: ["k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11"],
    tags: ["一般过去时", "时态"],
    source: "系统导入",
    quality_score: 0.91,
    usage_count: 56,
    correct_rate: 0.88,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  },
  {
    type: "single_choice",
    subject: "英语",
    difficulty: 3,
    content: {
      question: "By the time you arrive, I _____ my homework.",
      options: [
        "A. finish",
        "B. will finish",
        "C. will have finished",
        "D. have finished"
      ],
      images: []
    },
    answer: {
      correct: "C",
      explanation: "'by the time' 引导的时间状语从句，主句用将来完成时，表示在将来某个时间之前完成的动作。",
      explanation_images: []
    },
    knowledge_points: ["k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11"],
    tags: ["将来完成时", "时态"],
    source: "系统导入",
    quality_score: 0.87,
    usage_count: 41,
    correct_rate: 0.68,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  },
  {
    type: "fill_blank",
    subject: "英语",
    difficulty: 2,
    content: {
      question: "The book is very _____. (interest)",
      options: [],
      images: []
    },
    answer: {
      correct: "interesting",
      explanation: "形容物用 -ing 形式的形容词，表示'令人...的'，所以填 interesting。",
      explanation_images: []
    },
    knowledge_points: ["l1ppmn88-8n1m-5pq9-mm7o-7mm0mo491l22"],
    tags: ["形容词", "词汇变形"],
    source: "系统导入",
    quality_score: 0.89,
    usage_count: 48,
    correct_rate: 0.79,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  }
]);

// 物理题目
db.questions.insertMany([
  {
    type: "single_choice",
    subject: "物理",
    difficulty: 3,
    content: {
      question: "一个物体从静止开始做匀加速直线运动，加速度为2m/s²，那么在第3秒末的速度是多少？",
      options: ["A. 4 m/s", "B. 5 m/s", "C. 6 m/s", "D. 8 m/s"],
      images: []
    },
    answer: {
      correct: "C",
      explanation: "根据速度公式 v = v₀ + at，初速度v₀=0，a=2m/s²，t=3s，所以 v = 0 + 2×3 = 6 m/s",
      explanation_images: []
    },
    knowledge_points: ["o4sspq55-5q4p-8st2-pp0r-0pp3pr724o55"],
    tags: ["匀加速直线运动", "运动学"],
    source: "系统导入",
    quality_score: 0.93,
    usage_count: 35,
    correct_rate: 0.71,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  },
  {
    type: "true_false",
    subject: "物理",
    difficulty: 2,
    content: {
      question: "牛顿第一定律又称惯性定律，它指出：一切物体在没有受到外力作用时，总保持静止或匀速直线运动状态。",
      options: ["正确", "错误"],
      images: []
    },
    answer: {
      correct: "正确",
      explanation: "这是牛顿第一定律（惯性定律）的准确表述。",
      explanation_images: []
    },
    knowledge_points: ["o4sspq55-5q4p-8st2-pp0r-0pp3pr724o55"],
    tags: ["牛顿第一定律", "惯性"],
    source: "系统导入",
    quality_score: 0.86,
    usage_count: 52,
    correct_rate: 0.92,
    created_by: "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    created_at: new Date(),
    updated_at: new Date(),
    status: "published"
  }
]);

print("Questions inserted successfully!");

// ============================================================
// 插入学习资料数据
// ============================================================

print("Inserting sample materials...");

db.materials.insertMany([
  {
    user_id: "b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22",
    title: "初中数学总复习资料",
    description: "包含代数、几何等各章节重点内容",
    type: "pdf",
    file_url: "/materials/math_review_2024.pdf",
    file_size: 2048576,
    page_count: 45,
    processing_status: "completed",
    extracted_content: [
      {
        page: 1,
        text: "第一章 一元一次方程\n\n一元一次方程的定义：只含有一个未知数，未知数的次数是1，且两边都是整式的方程...",
        images: [],
        knowledge_points: ["f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66"],
        generated_questions: []
      }
    ],
    knowledge_points: ["f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66", "h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88"],
    tags: ["数学", "初中", "复习资料"],
    created_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
    updated_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  },
  {
    user_id: "c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33",
    title: "高中英语语法大全",
    description: "系统总结高中英语各种语法点",
    type: "pdf",
    file_url: "/materials/english_grammar_complete.pdf",
    file_size: 3145728,
    page_count: 68,
    processing_status: "completed",
    extracted_content: [
      {
        page: 1,
        text: "英语时态总览\n\n一般现在时：表示经常发生的动作或存在的状态...",
        images: [],
        knowledge_points: ["k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11"],
        generated_questions: []
      }
    ],
    knowledge_points: ["k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11", "l1ppmn88-8n1m-5pq9-mm7o-7mm0mo491l22"],
    tags: ["英语", "高中", "语法"],
    created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
    updated_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000)
  }
]);

print("Materials inserted successfully!");

// ============================================================
// 插入学习会话数据
// ============================================================

print("Inserting sample study sessions...");

db.study_sessions.insertMany([
  {
    user_id: "b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22",
    session_type: "practice",
    subject: "数学",
    question_ids: [],
    started_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
    ended_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 45 * 60 * 1000),
    total_questions: 20,
    completed_questions: 20,
    correct_count: 15,
    time_spent: 2700,
    avg_time_per_question: 135,
    accuracy: 0.75
  },
  {
    user_id: "c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33",
    session_type: "review",
    subject: "英语",
    question_ids: [],
    started_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
    ended_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000 + 70 * 60 * 1000),
    total_questions: 30,
    completed_questions: 30,
    correct_count: 27,
    time_spent: 4200,
    avg_time_per_question: 140,
    accuracy: 0.90
  }
]);

print("Study sessions inserted successfully!");

// ============================================================
// 插入 AI 提示词模板
// ============================================================

print("Inserting AI prompt templates...");

db.prompt_templates.insertMany([
  {
    name: "知识点提取",
    type: "extract_knowledge",
    template: `你是一个教育专家，擅长从学习资料中提取知识点。

请分析以下文本内容，提取其中的关键知识点：

文本内容：
{content}

学科：{subject}

请以 JSON 格式返回提取的知识点，格式如下：
{
  "knowledge_points": [
    {
      "name": "知识点名称",
      "description": "知识点描述",
      "level": 1-5,
      "keywords": ["关键词1", "关键词2"]
    }
  ]
}`,
    variables: ["content", "subject"],
    version: "1.0",
    is_active: true,
    model: "gpt-4-turbo-preview",
    temperature: 0.3,
    max_tokens: 2000
  },
  {
    name: "题目生成",
    type: "generate_question",
    template: `你是一个专业的题目出题专家，擅长根据知识点生成高质量的练习题。

知识点：{knowledge_point}
学科：{subject}
难度：{difficulty} (1-5，1最简单，5最难)
题目类型：{question_type}

请根据上述信息生成一道题目，以 JSON 格式返回：
{
  "question": "题目内容",
  "options": ["A. 选项1", "B. 选项2", "C. 选项3", "D. 选项4"],  // 选择题才需要
  "correct_answer": "正确答案",
  "explanation": "详细的答案解析",
  "difficulty_justification": "为什么这道题是这个难度级别"
}

要求：
1. 题目表述清晰准确
2. 选项设计合理，干扰项有一定迷惑性
3. 解析要详细，帮助学生理解知识点
4. 难度要符合要求`,
    variables: ["knowledge_point", "subject", "difficulty", "question_type"],
    version: "1.0",
    is_active: true,
    model: "gpt-4-turbo-preview",
    temperature: 0.7,
    max_tokens: 1500
  },
  {
    name: "题目质量评估",
    type: "quality_assessment",
    template: `你是一个教育质量评估专家，负责评估题目的质量。

请评估以下题目：

题目：{question}
选项：{options}
答案：{answer}
解析：{explanation}

请从以下几个维度评估题目质量（每个维度0-1分）：
1. 准确性：题目和答案是否正确
2. 清晰度：题目表述是否清晰明确
3. 难度适宜性：题目难度是否合适
4. 教育价值：题目是否有助于学习和理解
5. 选项合理性：选项设计是否合理（选择题）

以 JSON 格式返回评估结果：
{
  "accuracy": 0.95,
  "clarity": 0.90,
  "difficulty_appropriateness": 0.85,
  "educational_value": 0.88,
  "option_quality": 0.92,
  "overall_score": 0.90,
  "feedback": "具体的反馈意见",
  "suggestions": ["改进建议1", "改进建议2"]
}`,
    variables: ["question", "options", "answer", "explanation"],
    version: "1.0",
    is_active: true,
    model: "gpt-4-turbo-preview",
    temperature: 0.2,
    max_tokens: 1000
  },
  {
    name: "答案评估",
    type: "answer_evaluation",
    template: `你是一个专业的教师，负责评估学生的答案。

题目：{question}
标准答案：{correct_answer}
学生答案：{user_answer}
题目类型：{question_type}

请评估学生的答案，返回 JSON 格式：
{
  "is_correct": true/false,
  "score": 0-100,
  "feedback": "对学生答案的反馈",
  "key_points_covered": ["覆盖的要点1", "要点2"],
  "missing_points": ["缺失的要点1"],
  "suggestions": "改进建议"
}

对于主观题（简答题、论述题），请给出详细的评分理由。`,
    variables: ["question", "correct_answer", "user_answer", "question_type"],
    version: "1.0",
    is_active: true,
    model: "gpt-4-turbo-preview",
    temperature: 0.3,
    max_tokens: 1000
  }
]);

print("Prompt templates inserted successfully!");

// ============================================================
// 插入错题本数据
// ============================================================

print("Inserting wrong questions data...");

// 获取一些题目的 ObjectId
const mathQuestion1 = db.questions.findOne({ "content.question": /方程 2x/ });
const mathQuestion2 = db.questions.findOne({ "content.question": /三角形ABC/ });

if (mathQuestion1 && mathQuestion2) {
  db.wrong_questions.insertMany([
    {
      user_id: "b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22",
      question_id: mathQuestion2._id,
      wrong_count: 2,
      first_wrong_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      last_wrong_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      is_mastered: false,
      notes: "容易忘记三角形内角和定理"
    }
  ]);
  print("Wrong questions inserted successfully!");
} else {
  print("Skipping wrong questions - sample questions not found");
}

// ============================================================
// 创建聚合视图
// ============================================================

print("Creating aggregation views...");

// 题目统计视图
db.createView(
  "question_statistics",
  "questions",
  [
    {
      $group: {
        _id: {
          subject: "$subject",
          difficulty: "$difficulty"
        },
        count: { $sum: 1 },
        avg_quality: { $avg: "$quality_score" },
        avg_usage: { $avg: "$usage_count" },
        avg_correct_rate: { $avg: "$correct_rate" }
      }
    },
    {
      $sort: { "_id.subject": 1, "_id.difficulty": 1 }
    }
  ]
);

print("Views created successfully!");

// ============================================================
// 验证数据
// ============================================================

print("\n=== Data Verification ===");
print("Questions count: " + db.questions.countDocuments());
print("Materials count: " + db.materials.countDocuments());
print("Study sessions count: " + db.study_sessions.countDocuments());
print("Prompt templates count: " + db.prompt_templates.countDocuments());
print("Wrong questions count: " + db.wrong_questions.countDocuments());

print("\n=== MongoDB seed data insertion completed! ===");
