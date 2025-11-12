-- Seed Data: Subjects
-- Initial subjects for the learning platform

INSERT INTO subjects (id, name, code, description, category, difficulty_level, color, display_order) VALUES
-- Mathematics
(uuid_generate_v4(), '高等数学', 'MATH-ADV', '高等数学包括微积分、线性代数、概率论等内容', '数学', 'hard', '#3B82F6', 1),
(uuid_generate_v4(), '线性代数', 'MATH-LA', '向量空间、矩阵理论、线性变换等', '数学', 'medium', '#60A5FA', 2),
(uuid_generate_v4(), '概率论与数理统计', 'MATH-PROB', '概率基础、随机变量、统计推断', '数学', 'medium', '#93C5FD', 3),

-- Computer Science
(uuid_generate_v4(), '数据结构与算法', 'CS-DSA', '基本数据结构和算法设计与分析', '计算机科学', 'hard', '#8B5CF6', 4),
(uuid_generate_v4(), '操作系统', 'CS-OS', '进程管理、内存管理、文件系统等', '计算机科学', 'hard', '#A78BFA', 5),
(uuid_generate_v4(), '计算机网络', 'CS-NET', '网络协议、TCP/IP、网络安全', '计算机科学', 'medium', '#C4B5FD', 6),
(uuid_generate_v4(), '数据库系统', 'CS-DB', 'SQL、事务处理、数据库设计', '计算机科学', 'medium', '#DDD6FE', 7),

-- Programming Languages
(uuid_generate_v4(), 'Python编程', 'PROG-PY', 'Python语言基础到高级应用', '编程语言', 'easy', '#10B981', 8),
(uuid_generate_v4(), 'JavaScript/TypeScript', 'PROG-JS', 'Web开发必备的编程语言', '编程语言', 'medium', '#34D399', 9),
(uuid_generate_v4(), 'Java编程', 'PROG-JAVA', 'Java语言和面向对象编程', '编程语言', 'medium', '#6EE7B7', 10),

-- English
(uuid_generate_v4(), '大学英语四级', 'ENG-CET4', '大学英语四级考试准备', '英语', 'medium', '#F59E0B', 11),
(uuid_generate_v4(), '大学英语六级', 'ENG-CET6', '大学英语六级考试准备', '英语', 'hard', '#FBBF24', 12),
(uuid_generate_v4(), '雅思(IELTS)', 'ENG-IELTS', '雅思考试准备', '英语', 'hard', '#FCD34D', 13),

-- Professional Certifications
(uuid_generate_v4(), 'AWS认证解决方案架构师', 'CERT-AWS', 'AWS云服务认证', '职业认证', 'hard', '#EC4899', 14),
(uuid_generate_v4(), 'PMP项目管理', 'CERT-PMP', '项目管理专业认证', '职业认证', 'medium', '#F472B6', 15);

COMMENT ON TABLE subjects IS 'Seed data includes common academic and professional subjects';
