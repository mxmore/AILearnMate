-- AILearnMate PostgreSQL 种子数据
-- 版本: 1.0

-- ============================================================
-- 插入测试用户
-- ============================================================

-- 管理员用户 (密码: Admin123!)
INSERT INTO users (id, email, username, hashed_password, role, is_active, is_verified)
VALUES 
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin@ailearnmate.com', '管理员', 
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lMjKq3qz3q3q', 'admin', true, true);

-- 测试用户1 (密码: Test123!)
INSERT INTO users (id, email, username, hashed_password, role, is_active, is_verified)
VALUES 
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 'test1@example.com', '小明',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lMjKq3qz3q3q', 'user', true, true);

-- 测试用户2 (密码: Test123!)
INSERT INTO users (id, email, username, hashed_password, role, is_active, is_verified)
VALUES 
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', 'test2@example.com', '小红',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lMjKq3qz3q3q', 'vip', true, true);

-- ============================================================
-- 插入用户偏好设置
-- ============================================================

INSERT INTO user_preferences (user_id, daily_goal, notification_enabled, preferred_subjects, difficulty_preference)
VALUES 
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 30, true, ARRAY['数学', '物理'], 3),
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', 50, true, ARRAY['英语', '化学'], 4);

-- ============================================================
-- 插入知识点数据
-- ============================================================

-- 数学知识点
INSERT INTO knowledge_points (id, subject, name, description, level)
VALUES 
  ('d3hhef66-6f3e-7hi1-ee9g-9ee2eg613d44', '数学', '初中数学', '初中数学知识体系', 1),
  ('e4iifg55-5g4f-8ij2-ff0h-0ff3fh724e55', '数学', '代数', '代数基础知识', 2),
  ('f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66', '数学', '一元一次方程', '一元一次方程的解法', 3),
  ('g6kkhi33-3i6h-0kl4-hh2j-2hh5hj946g77', '数学', '几何', '几何基础知识', 2),
  ('h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88', '数学', '三角形', '三角形的性质与判定', 3);

-- 更新知识点的父子关系
UPDATE knowledge_points SET parent_id = 'd3hhef66-6f3e-7hi1-ee9g-9ee2eg613d44' 
WHERE id IN ('e4iifg55-5g4f-8ij2-ff0h-0ff3fh724e55', 'g6kkhi33-3i6h-0kl4-hh2j-2hh5hj946g77');

UPDATE knowledge_points SET parent_id = 'e4iifg55-5g4f-8ij2-ff0h-0ff3fh724e55'
WHERE id = 'f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66';

UPDATE knowledge_points SET parent_id = 'g6kkhi33-3i6h-0kl4-hh2j-2hh5hj946g77'
WHERE id = 'h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88';

-- 英语知识点
INSERT INTO knowledge_points (id, subject, name, description, level)
VALUES 
  ('i8mmjk11-1k8j-2mn6-jj4l-4jj7jl168i99', '英语', '高中英语', '高中英语知识体系', 1),
  ('j9nnkl00-0l9k-3no7-kk5m-5kk8km279j00', '英语', '语法', '英语语法知识', 2),
  ('k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11', '英语', '时态', '英语时态用法', 3),
  ('l1ppmn88-8n1m-5pq9-mm7o-7mm0mo491l22', '英语', '词汇', '英语词汇积累', 2);

UPDATE knowledge_points SET parent_id = 'i8mmjk11-1k8j-2mn6-jj4l-4jj7jl168i99'
WHERE id IN ('j9nnkl00-0l9k-3no7-kk5m-5kk8km279j00', 'l1ppmn88-8n1m-5pq9-mm7o-7mm0mo491l22');

UPDATE knowledge_points SET parent_id = 'j9nnkl00-0l9k-3no7-kk5m-5kk8km279j00'
WHERE id = 'k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11';

-- 物理知识点
INSERT INTO knowledge_points (id, subject, name, description, level)
VALUES 
  ('m2qqno77-7o2n-6qr0-nn8p-8nn1np502m33', '物理', '高中物理', '高中物理知识体系', 1),
  ('n3rrop66-6p3o-7rs1-oo9q-9oo2oq613n44', '物理', '力学', '力学基础知识', 2),
  ('o4sspq55-5q4p-8st2-pp0r-0pp3pr724o55', '物理', '牛顿运动定律', '牛顿三大运动定律', 3);

UPDATE knowledge_points SET parent_id = 'm2qqno77-7o2n-6qr0-nn8p-8nn1np502m33'
WHERE id = 'n3rrop66-6p3o-7rs1-oo9q-9oo2oq613n44';

UPDATE knowledge_points SET parent_id = 'n3rrop66-6p3o-7rs1-oo9q-9oo2oq613n44'
WHERE id = 'o4sspq55-5q4p-8st2-pp0r-0pp3pr724o55';

-- ============================================================
-- 插入用户知识点掌握度数据
-- ============================================================

INSERT INTO user_knowledge_mastery (user_id, knowledge_point_id, mastery_level, practice_count, correct_count, last_practiced_at)
VALUES 
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 'f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66', 0.75, 20, 15, NOW() - INTERVAL '2 days'),
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 'h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88', 0.60, 15, 9, NOW() - INTERVAL '3 days'),
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 'o4sspq55-5q4p-8st2-pp0r-0pp3pr724o55', 0.45, 10, 4, NOW() - INTERVAL '5 days'),
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', 'k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11', 0.85, 30, 27, NOW() - INTERVAL '1 day'),
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', 'f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66', 0.90, 25, 24, NOW() - INTERVAL '1 day');

-- ============================================================
-- 插入学习计划数据
-- ============================================================

INSERT INTO study_plans (id, user_id, name, description, subject, start_date, end_date, daily_target, status)
VALUES 
  ('p5ttrq44-4r5q-9tu3-qq1s-1qq4qs835p66', 'b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', 
   '初中数学强化', '针对薄弱知识点的强化训练', '数学', 
   CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 30, 'active'),
  ('q6uusр33-3s6r-0uv4-rr2t-2rr5rt946q77', 'c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33',
   '英语备考计划', '英语语法和词汇全面提升', '英语',
   CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '20 days', 50, 'active');

-- ============================================================
-- 插入学习计划知识点关联
-- ============================================================

INSERT INTO study_plan_knowledge_points (study_plan_id, knowledge_point_id, target_mastery, priority)
VALUES 
  ('p5ttrq44-4r5q-9tu3-qq1s-1qq4qs835p66', 'f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66', 0.90, 5),
  ('p5ttrq44-4r5q-9tu3-qq1s-1qq4qs835p66', 'h7llij22-2j7i-1lm5-ii3k-3ii6ik057h88', 0.85, 4),
  ('q6uusр33-3s6r-0uv4-rr2t-2rr5rt946q77', 'k0oolm99-9m0l-4op8-ll6n-6ll9ln380k11', 0.95, 5),
  ('q6uusр33-3s6r-0uv4-rr2t-2rr5rt946q77', 'l1ppmn88-8n1m-5pq9-mm7o-7mm0mo491l22', 0.90, 4);

-- ============================================================
-- 插入学习打卡记录
-- ============================================================

INSERT INTO study_check_ins (user_id, check_in_date, questions_completed, study_minutes, streak_days)
VALUES 
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', CURRENT_DATE - INTERVAL '2 days', 25, 45, 3),
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', CURRENT_DATE - INTERVAL '1 day', 30, 50, 4),
  ('b1ffcd88-8d1c-5fg9-cc7e-7cc0ce491b22', CURRENT_DATE, 28, 48, 5),
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', CURRENT_DATE - INTERVAL '1 day', 45, 70, 7),
  ('c2ggde77-7e2d-6gh0-dd8f-8dd1df502c33', CURRENT_DATE, 52, 75, 8);

-- ============================================================
-- 插入系统配置
-- ============================================================

INSERT INTO system_config (config_key, config_value, description)
VALUES 
  ('ai_model_primary', '{"provider": "openai", "model": "gpt-4-turbo-preview", "api_key_name": "OPENAI_API_KEY"}',
   '主要使用的 AI 模型配置'),
  ('ai_model_embedding', '{"provider": "openai", "model": "text-embedding-3-small", "dimensions": 1536}',
   '向量化模型配置'),
  ('ocr_service', '{"provider": "paddleocr", "language": ["ch", "en"], "use_angle_cls": true}',
   'OCR 服务配置'),
  ('storage_service', '{"provider": "minio", "endpoint": "http://minio:9000", "bucket": "ailearnmate"}',
   '对象存储服务配置'),
  ('rate_limit_default', '{"requests_per_minute": 60, "requests_per_hour": 1000}',
   'API 默认限流配置'),
  ('srs_config', '{"initial_interval": 1, "easy_bonus": 1.3, "hard_interval": 1.2, "minimum_ease": 1.3}',
   'SRS 算法配置参数'),
  ('question_generation_config', '{"max_questions_per_page": 5, "min_quality_score": 0.7, "temperature": 0.7}',
   '题目生成配置'),
  ('notification_config', '{"enabled": true, "channels": ["email", "push"], "daily_reminder_time": "09:00"}',
   '通知服务配置');

COMMIT;

-- ============================================================
-- 验证数据插入
-- ============================================================

SELECT 'Users inserted: ' || COUNT(*) FROM users;
SELECT 'Knowledge points inserted: ' || COUNT(*) FROM knowledge_points;
SELECT 'Study plans inserted: ' || COUNT(*) FROM study_plans;
SELECT 'System configs inserted: ' || COUNT(*) FROM system_config;
