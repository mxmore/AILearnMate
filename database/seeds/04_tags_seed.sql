-- Seed Data: Tags
-- Common tags for categorizing questions and materials

INSERT INTO tags (name, category, color) VALUES
-- Difficulty tags
('入门级', 'difficulty', '#10B981'),
('进阶', 'difficulty', '#F59E0B'),
('高级', 'difficulty', '#EF4444'),

-- Topic tags
('基础概念', 'topic', '#3B82F6'),
('算法设计', 'topic', '#8B5CF6'),
('代码实现', 'topic', '#EC4899'),
('理论证明', 'topic', '#6366F1'),
('应用实践', 'topic', '#14B8A6'),

-- Exam preparation tags
('考研真题', 'exam', '#DC2626'),
('面试常考', 'exam', '#EA580C'),
('竞赛题目', 'exam', '#CA8A04'),

-- Content type tags
('视频讲解', 'content', '#7C3AED'),
('图文教程', 'content', '#2563EB'),
('交互练习', 'content', '#059669'),
('实战项目', 'content', '#DB2777'),

-- Skill tags
('问题分析', 'skill', '#0891B2'),
('代码优化', 'skill', '#16A34A'),
('调试技巧', 'skill', '#C026D3'),
('系统设计', 'skill', '#9333EA')

ON CONFLICT (name) DO NOTHING;

COMMENT ON TABLE tags IS 'Seed data includes common tags for organizing content';
