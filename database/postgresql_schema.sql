-- AILearnMate PostgreSQL 数据库架构
-- 版本: 1.0
-- 数据库: PostgreSQL 15+ with pgvector extension

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgvector";

-- 创建枚举类型
CREATE TYPE user_role AS ENUM ('user', 'vip', 'admin');
CREATE TYPE plan_status AS ENUM ('active', 'completed', 'paused');
CREATE TYPE subject_type AS ENUM ('数学', '英语', '物理', '化学', '生物', '历史', '地理', '政治', '计算机', '其他');

-- ============================================================
-- 用户相关表
-- ============================================================

-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    role user_role DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- 用户配置表
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    daily_goal INTEGER DEFAULT 20, -- 每日答题目标数
    notification_enabled BOOLEAN DEFAULT true,
    notification_time TIME DEFAULT '09:00:00',
    preferred_subjects VARCHAR(100)[], -- 偏好学科数组
    difficulty_preference INTEGER DEFAULT 3, -- 偏好难度 1-5
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- ============================================================
-- 知识点相关表
-- ============================================================

-- 知识点表
CREATE TABLE knowledge_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject subject_type NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES knowledge_points(id) ON DELETE SET NULL,
    level INTEGER DEFAULT 1, -- 知识点层级 1-顶层 2-二级 3-三级...
    embedding VECTOR(1536), -- 使用 text-embedding-3-small 的维度
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 为知识点名称创建索引
CREATE INDEX idx_knowledge_points_name ON knowledge_points(name);
CREATE INDEX idx_knowledge_points_subject ON knowledge_points(subject);
CREATE INDEX idx_knowledge_points_parent ON knowledge_points(parent_id);

-- 为向量搜索创建索引 (使用 HNSW 算法)
CREATE INDEX idx_knowledge_points_embedding ON knowledge_points 
USING hnsw (embedding vector_cosine_ops);

-- 用户知识点掌握度表
CREATE TABLE user_knowledge_mastery (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    mastery_level FLOAT CHECK (mastery_level >= 0 AND mastery_level <= 1) DEFAULT 0,
    practice_count INTEGER DEFAULT 0,
    correct_count INTEGER DEFAULT 0,
    last_practiced_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, knowledge_point_id)
);

-- 创建索引以提高查询性能
CREATE INDEX idx_user_knowledge_mastery_user ON user_knowledge_mastery(user_id);
CREATE INDEX idx_user_knowledge_mastery_level ON user_knowledge_mastery(mastery_level);

-- ============================================================
-- 学习计划相关表
-- ============================================================

-- 学习计划表
CREATE TABLE study_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    subject subject_type,
    start_date DATE NOT NULL,
    end_date DATE,
    daily_target INTEGER DEFAULT 20, -- 每日目标题数
    status plan_status DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_plans_user ON study_plans(user_id);
CREATE INDEX idx_study_plans_status ON study_plans(status);

-- 学习计划知识点关联表
CREATE TABLE study_plan_knowledge_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
    knowledge_point_id UUID NOT NULL REFERENCES knowledge_points(id) ON DELETE CASCADE,
    target_mastery FLOAT DEFAULT 0.8, -- 目标掌握度
    priority INTEGER DEFAULT 1, -- 优先级 1-5
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(study_plan_id, knowledge_point_id)
);

-- ============================================================
-- 学习记录相关表
-- ============================================================

-- 学习记录表（记录每次答题）
CREATE TABLE study_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    question_id VARCHAR(24) NOT NULL, -- MongoDB ObjectId
    session_id VARCHAR(24), -- 学习会话 ID (MongoDB)
    answer JSONB, -- 用户的答案
    is_correct BOOLEAN NOT NULL,
    time_spent INTEGER, -- 答题用时（秒）
    difficulty INTEGER CHECK (difficulty >= 1 AND difficulty <= 5),
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- SRS (间隔重复) 相关字段
    next_review_at TIMESTAMP WITH TIME ZONE,
    review_count INTEGER DEFAULT 0,
    ease_factor FLOAT DEFAULT 2.5, -- SuperMemo SM-2 算法的难度因子
    interval_days FLOAT DEFAULT 0, -- 当前间隔天数
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_records_user ON study_records(user_id);
CREATE INDEX idx_study_records_question ON study_records(question_id);
CREATE INDEX idx_study_records_answered_at ON study_records(answered_at);
CREATE INDEX idx_study_records_next_review ON study_records(next_review_at);

-- 学习打卡记录表
CREATE TABLE study_check_ins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    check_in_date DATE NOT NULL,
    questions_completed INTEGER DEFAULT 0,
    study_minutes INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 1, -- 连续打卡天数
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, check_in_date)
);

CREATE INDEX idx_study_check_ins_user ON study_check_ins(user_id);
CREATE INDEX idx_study_check_ins_date ON study_check_ins(check_in_date);

-- ============================================================
-- 学习资料相关表
-- ============================================================

-- 学习资料处理任务表
CREATE TABLE material_processing_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_id VARCHAR(24) NOT NULL, -- MongoDB materials 集合的 ObjectId
    task_type VARCHAR(50) NOT NULL, -- 'ocr', 'extract_knowledge', 'generate_questions'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    progress INTEGER DEFAULT 0, -- 0-100
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_material_tasks_material ON material_processing_tasks(material_id);
CREATE INDEX idx_material_tasks_status ON material_processing_tasks(status);

-- ============================================================
-- 系统配置相关表
-- ============================================================

-- 系统配置表
CREATE TABLE system_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 审计日志表
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- 'create', 'update', 'delete', 'login', etc.
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'question', 'material', etc.
    entity_id VARCHAR(100),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================================
-- 触发器和函数
-- ============================================================

-- 自动更新 updated_at 字段的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要自动更新 updated_at 的表创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_knowledge_points_updated_at BEFORE UPDATE ON knowledge_points
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_knowledge_mastery_updated_at BEFORE UPDATE ON user_knowledge_mastery
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_study_plans_updated_at BEFORE UPDATE ON study_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_config_updated_at BEFORE UPDATE ON system_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 视图
-- ============================================================

-- 用户学习统计视图
CREATE VIEW user_study_stats AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(DISTINCT sr.id) as total_questions_answered,
    COUNT(DISTINCT CASE WHEN sr.is_correct THEN sr.id END) as correct_answers,
    CASE 
        WHEN COUNT(sr.id) > 0 THEN 
            ROUND((COUNT(CASE WHEN sr.is_correct THEN 1 END)::DECIMAL / COUNT(sr.id)::DECIMAL) * 100, 2)
        ELSE 0 
    END as accuracy_rate,
    COALESCE(SUM(sr.time_spent), 0) as total_study_seconds,
    COUNT(DISTINCT DATE(sr.answered_at)) as study_days,
    MAX(sc.streak_days) as max_streak_days,
    COUNT(DISTINCT sp.id) as active_study_plans
FROM users u
LEFT JOIN study_records sr ON u.id = sr.user_id
LEFT JOIN study_check_ins sc ON u.id = sc.user_id
LEFT JOIN study_plans sp ON u.id = sp.user_id AND sp.status = 'active'
GROUP BY u.id, u.username;

-- 知识点学习进度视图
CREATE VIEW knowledge_point_progress AS
SELECT 
    kp.id as knowledge_point_id,
    kp.name as knowledge_point_name,
    kp.subject,
    COUNT(DISTINCT ukm.user_id) as students_count,
    ROUND(AVG(ukm.mastery_level)::DECIMAL, 2) as avg_mastery_level,
    SUM(ukm.practice_count) as total_practice_count
FROM knowledge_points kp
LEFT JOIN user_knowledge_mastery ukm ON kp.id = ukm.knowledge_point_id
GROUP BY kp.id, kp.name, kp.subject;

-- ============================================================
-- 注释
-- ============================================================

COMMENT ON TABLE users IS '用户账户信息表';
COMMENT ON TABLE user_preferences IS '用户学习偏好设置表';
COMMENT ON TABLE knowledge_points IS '知识点表，支持层级结构';
COMMENT ON TABLE user_knowledge_mastery IS '用户对各知识点的掌握程度';
COMMENT ON TABLE study_plans IS '用户创建的学习计划';
COMMENT ON TABLE study_records IS '答题记录表，包含 SRS 算法所需字段';
COMMENT ON TABLE study_check_ins IS '每日学习打卡记录';
COMMENT ON TABLE material_processing_tasks IS '学习资料处理任务队列';
COMMENT ON TABLE system_config IS '系统配置键值对';
COMMENT ON TABLE audit_logs IS '系统审计日志';
