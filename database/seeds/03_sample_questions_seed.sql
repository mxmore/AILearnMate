-- Seed Data: Sample Questions
-- Sample questions for testing the system

DO $$
DECLARE
    dsa_subject_id UUID;
    arrays_kp_id UUID;
    demo_user_id UUID;
BEGIN
    -- Get subject and knowledge point IDs
    SELECT id INTO dsa_subject_id FROM subjects WHERE code = 'CS-DSA' LIMIT 1;
    SELECT id INTO arrays_kp_id FROM knowledge_points WHERE code = 'DSA-ARRAYS-BASIC' LIMIT 1;
    
    -- Create a demo user if needed
    INSERT INTO users (id, username, email, password_hash, full_name, role)
    VALUES (uuid_generate_v4(), 'demo_teacher', 'demo@ailearn.com', '$2b$12$demo_hash_placeholder', '演示教师', 'teacher')
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO demo_user_id;
    
    IF demo_user_id IS NULL THEN
        SELECT id INTO demo_user_id FROM users WHERE email = 'demo@ailearn.com' LIMIT 1;
    END IF;
    
    IF dsa_subject_id IS NOT NULL AND arrays_kp_id IS NOT NULL THEN
        -- Multiple Choice Question
        INSERT INTO questions (
            id, subject_id, question_type, difficulty_level, 
            question_text, options, correct_answer, explanation,
            points, source, is_verified, created_by
        ) VALUES (
            uuid_generate_v4(),
            dsa_subject_id,
            'multiple_choice',
            'easy',
            '在Python中，以下哪个操作的时间复杂度是O(1)？',
            '{
                "A": "在列表末尾添加元素 (list.append())",
                "B": "在列表开头插入元素 (list.insert(0, x))",
                "C": "删除列表中的特定元素 (list.remove(x))",
                "D": "对列表进行排序 (list.sort())"
            }'::jsonb,
            '{"answer": "A", "explanation": "append()操作在列表末尾添加元素，平均时间复杂度为O(1)"}'::jsonb,
            'append()在列表末尾添加元素通常是O(1)操作，因为Python列表实现为动态数组，在末尾有预留空间。其他操作：insert(0)需要移动所有元素O(n)，remove()需要查找和移动O(n)，sort()是O(n log n)。',
            1.0,
            'manual',
            true,
            demo_user_id
        );
        
        -- Link question to knowledge point
        INSERT INTO question_knowledge_points (question_id, knowledge_point_id, is_primary)
        SELECT q.id, arrays_kp_id, true
        FROM questions q
        WHERE q.question_text LIKE '%Python中，以下哪个操作的时间复杂度%'
        LIMIT 1;
        
        -- Multiple Select Question
        INSERT INTO questions (
            id, subject_id, question_type, difficulty_level,
            question_text, options, correct_answer, explanation,
            points, source, is_verified, created_by
        ) VALUES (
            uuid_generate_v4(),
            dsa_subject_id,
            'multiple_select',
            'medium',
            '以下哪些是稳定的排序算法？（多选）',
            '{
                "A": "冒泡排序",
                "B": "快速排序",
                "C": "归并排序",
                "D": "堆排序",
                "E": "插入排序"
            }'::jsonb,
            '{"answers": ["A", "C", "E"], "explanation": "稳定排序算法保持相等元素的相对顺序"}'::jsonb,
            '稳定排序算法在排序后保持相等元素的原始相对顺序。冒泡排序、归并排序和插入排序都是稳定的。快速排序和堆排序是不稳定的，因为它们会改变相等元素的相对位置。',
            2.0,
            'manual',
            true,
            demo_user_id
        );
        
        -- True/False Question
        INSERT INTO questions (
            id, subject_id, question_type, difficulty_level,
            question_text, correct_answer, explanation,
            points, source, is_verified, created_by
        ) VALUES (
            uuid_generate_v4(),
            dsa_subject_id,
            'true_false',
            'easy',
            '数组的随机访问时间复杂度是O(1)。',
            '{"answer": true, "explanation": "数组支持通过索引直接访问，时间复杂度为O(1)"}'::jsonb,
            '数组在内存中是连续存储的，通过基地址+偏移量可以直接计算出任意元素的地址，因此随机访问的时间复杂度是O(1)。这是数组的主要优势之一。',
            1.0,
            'manual',
            true,
            demo_user_id
        );
        
        -- Fill in the Blank Question
        INSERT INTO questions (
            id, subject_id, question_type, difficulty_level,
            question_text, correct_answer, explanation,
            points, source, is_verified, created_by
        ) VALUES (
            uuid_generate_v4(),
            dsa_subject_id,
            'fill_blank',
            'medium',
            '二分查找算法的时间复杂度是____，空间复杂度是____。',
            '{"blanks": ["O(log n)", "O(1)"], "acceptable_answers": [["O(log n)", "O(logn)", "logn"], ["O(1)", "O(1)空间", "常数"]]}'::jsonb,
            '二分查找通过每次将搜索区间减半来查找目标值，因此时间复杂度是O(log n)。如果使用迭代实现，只需要常数个变量，空间复杂度是O(1)。',
            2.0,
            'manual',
            true,
            demo_user_id
        );
        
        -- Short Answer Question
        INSERT INTO questions (
            id, subject_id, question_type, difficulty_level,
            question_text, correct_answer, explanation,
            points, source, is_verified, created_by
        ) VALUES (
            uuid_generate_v4(),
            dsa_subject_id,
            'short_answer',
            'hard',
            '请简述动态数组（如Python的list）在扩容时的策略，以及为什么这样设计？',
            '{"key_points": ["容量不足时分配更大空间", "通常增长因子约1.5-2倍", "摊还时间复杂度O(1)", "平衡时间和空间开销"], "min_length": 50}'::jsonb,
            '动态数组在容量不足时会分配一块更大的连续内存空间（通常是当前容量的1.5-2倍），然后将原有元素复制到新空间。这种策略使得虽然单次扩容成本较高，但通过摊还分析，append操作的平均时间复杂度仍为O(1)。增长因子选择1.5-2倍是为了在时间效率和空间利用率之间取得平衡。',
            3.0,
            'manual',
            true,
            demo_user_id
        );
        
        RAISE NOTICE 'Sample questions seed data inserted successfully';
    ELSE
        RAISE NOTICE 'Required subject or knowledge point not found, skipping questions seed';
    END IF;
END $$;
