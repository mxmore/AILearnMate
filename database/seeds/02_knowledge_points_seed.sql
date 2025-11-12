-- Seed Data: Knowledge Points
-- Sample knowledge points for Data Structures & Algorithms subject

-- First, get the subject_id for 'Data Structures & Algorithms'
DO $$
DECLARE
    dsa_subject_id UUID;
    root_kp_id UUID;
    arrays_kp_id UUID;
    linked_lists_kp_id UUID;
    trees_kp_id UUID;
BEGIN
    -- Get subject ID
    SELECT id INTO dsa_subject_id FROM subjects WHERE code = 'CS-DSA' LIMIT 1;
    
    IF dsa_subject_id IS NOT NULL THEN
        -- Root knowledge points
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, NULL, '数组与字符串', 'DSA-ARRAYS', '数组的基本操作、字符串处理', 1, '1', 'easy', 180)
        RETURNING id INTO arrays_kp_id;
        
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, NULL, '链表', 'DSA-LINKEDLIST', '单链表、双链表、循环链表', 1, '2', 'medium', 240)
        RETURNING id INTO linked_lists_kp_id;
        
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, NULL, '树与图', 'DSA-TREES', '二叉树、二叉搜索树、图的遍历', 1, '3', 'hard', 360)
        RETURNING id INTO trees_kp_id;
        
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, NULL, '排序算法', 'DSA-SORTING', '冒泡排序、快速排序、归并排序等', 1, '4', 'medium', 300),
            (uuid_generate_v4(), dsa_subject_id, NULL, '查找算法', 'DSA-SEARCHING', '二分查找、哈希表', 1, '5', 'medium', 240),
            (uuid_generate_v4(), dsa_subject_id, NULL, '动态规划', 'DSA-DP', '动态规划的思想和经典问题', 1, '6', 'hard', 420);
        
        -- Child knowledge points for Arrays
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, arrays_kp_id, '数组基础操作', 'DSA-ARRAYS-BASIC', '插入、删除、查找', 2, '1.1', 'easy', 60),
            (uuid_generate_v4(), dsa_subject_id, arrays_kp_id, '双指针技巧', 'DSA-ARRAYS-TWOPTR', '双指针、滑动窗口', 2, '1.2', 'medium', 120),
            (uuid_generate_v4(), dsa_subject_id, arrays_kp_id, '字符串匹配', 'DSA-ARRAYS-STRM', 'KMP算法、字符串匹配', 2, '1.3', 'hard', 180);
        
        -- Child knowledge points for Linked Lists
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, linked_lists_kp_id, '单链表操作', 'DSA-LL-SINGLE', '插入、删除、反转', 2, '2.1', 'easy', 90),
            (uuid_generate_v4(), dsa_subject_id, linked_lists_kp_id, '双链表与循环链表', 'DSA-LL-DOUBLE', '双向链表的实现和应用', 2, '2.2', 'medium', 90),
            (uuid_generate_v4(), dsa_subject_id, linked_lists_kp_id, '链表高级技巧', 'DSA-LL-ADV', '快慢指针、链表环检测', 2, '2.3', 'hard', 120);
        
        -- Child knowledge points for Trees
        INSERT INTO knowledge_points (id, subject_id, parent_id, name, code, description, level, path, difficulty_level, estimated_study_time)
        VALUES 
            (uuid_generate_v4(), dsa_subject_id, trees_kp_id, '二叉树遍历', 'DSA-TREE-TRAV', '前序、中序、后序、层序遍历', 2, '3.1', 'medium', 120),
            (uuid_generate_v4(), dsa_subject_id, trees_kp_id, '二叉搜索树', 'DSA-TREE-BST', 'BST的性质和操作', 2, '3.2', 'medium', 120),
            (uuid_generate_v4(), dsa_subject_id, trees_kp_id, '平衡树', 'DSA-TREE-AVL', 'AVL树、红黑树', 2, '3.3', 'hard', 180),
            (uuid_generate_v4(), dsa_subject_id, trees_kp_id, '图的表示与遍历', 'DSA-GRAPH-BASIC', 'DFS、BFS、拓扑排序', 2, '3.4', 'hard', 180);
        
        RAISE NOTICE 'Knowledge points seed data inserted successfully';
    ELSE
        RAISE NOTICE 'Subject CS-DSA not found, skipping knowledge points seed';
    END IF;
END $$;
