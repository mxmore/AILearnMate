-- Custom Types and Enums for AILearnMate

-- User roles
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin', 'premium_student');

-- Question types
CREATE TYPE question_type AS ENUM (
    'multiple_choice',      -- 单选题
    'multiple_select',      -- 多选题
    'true_false',          -- 判断题
    'fill_blank',          -- 填空题
    'short_answer',        -- 简答题
    'essay',               -- 论述题
    'coding',              -- 编程题
    'matching'             -- 匹配题
);

-- Question difficulty levels
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard', 'expert');

-- Study material types
CREATE TYPE material_type AS ENUM (
    'pdf',
    'video',
    'audio',
    'text',
    'presentation',
    'webpage',
    'other'
);

-- Learning status
CREATE TYPE learning_status AS ENUM (
    'not_started',
    'in_progress',
    'completed',
    'mastered'
);

-- Review interval stages (SRS - Spaced Repetition System)
CREATE TYPE srs_stage AS ENUM (
    'new',           -- 新学习
    'learning',      -- 学习中
    'review',        -- 复习中
    'mastered'       -- 已掌握
);

-- Study session types
CREATE TYPE session_type AS ENUM (
    'practice',      -- 练习
    'exam',          -- 考试
    'review',        -- 复习
    'adaptive'       -- 自适应学习
);

-- AI agent task types
CREATE TYPE agent_task_type AS ENUM (
    'extract_questions',     -- 抽取题目
    'generate_questions',    -- 生成题目
    'evaluate_answer',       -- 评估答案
    'explain_solution',      -- 解释解答
    'suggest_materials',     -- 推荐材料
    'create_study_plan',     -- 创建学习计划
    'analyze_performance'    -- 分析表现
);

-- Processing status
CREATE TYPE processing_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'cancelled'
);

COMMENT ON TYPE user_role IS 'User roles in the system';
COMMENT ON TYPE question_type IS 'Types of questions supported';
COMMENT ON TYPE difficulty_level IS 'Difficulty levels for questions';
COMMENT ON TYPE material_type IS 'Types of study materials';
COMMENT ON TYPE learning_status IS 'Learning progress status';
COMMENT ON TYPE srs_stage IS 'Spaced Repetition System stages';
COMMENT ON TYPE session_type IS 'Types of study sessions';
COMMENT ON TYPE agent_task_type IS 'AI agent task types';
COMMENT ON TYPE processing_status IS 'Processing status for async tasks';
