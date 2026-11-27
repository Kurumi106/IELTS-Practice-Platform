START TRANSACTION;

-- 1. Đảm bảo có test 'IELTS Writing Practice 01'
INSERT INTO tests (title, description, test_type, duration_minutes, status)
SELECT
    'IELTS Writing Practice 01',
    'Writing skill practice test',
    'skill_practice',
    60,
    'draft'
WHERE NOT EXISTS (
    SELECT 1 FROM tests WHERE title = 'IELTS Writing Practice 01'
);

SET @writing_test_id = (
    SELECT id FROM tests WHERE title = 'IELTS Writing Practice 01' LIMIT 1
);

SET @writing_skill_id = (
    SELECT id FROM skills WHERE code = 'writing' LIMIT 1
);

-- 2. Tạo Test Section cho Writing Practice 01
INSERT INTO test_sections (
    test_id,
    skill_id,
    section_order,
    title,
    instructions,
    duration_seconds
)
SELECT
    @writing_test_id,
    @writing_skill_id,
    1,
    'Writing Practice - Task 1 (Process) & Task 2 (Problem-Solution)',
    'Complete Writing Task 1 and Task 2.',
    3600
WHERE NOT EXISTS (
    SELECT 1 FROM test_sections
    WHERE test_id = @writing_test_id
      AND skill_id = @writing_skill_id
      AND section_order = 1
);

SET @writing_section_id = (
    SELECT id FROM test_sections
    WHERE test_id = @writing_test_id
      AND skill_id = @writing_skill_id
      AND section_order = 1
    LIMIT 1
);

-- 3. Tạo Passages cho Task 1 (Process Diagram) & Task 2 (Causes & Solutions)
INSERT INTO passages (
    section_id,
    title,
    content_type,
    content_text,
    media_url,
    transcript,
    duration_seconds
)
SELECT
    @writing_section_id,
    'Writing Task 1 - Glass Bottle Recycling Process',
    'image',
    'The diagram below shows the process by which used glass bottles are recycled and manufactured into new products.',
    '/uploads/writing/task1-glass-recycling-process.svg',
    NULL,
    NULL
WHERE NOT EXISTS (
    SELECT 1 FROM passages
    WHERE section_id = @writing_section_id
      AND title = 'Writing Task 1 - Glass Bottle Recycling Process'
);

SET @wp1_id = (
    SELECT id FROM passages
    WHERE section_id = @writing_section_id
      AND title = 'Writing Task 1 - Glass Bottle Recycling Process'
    LIMIT 1
);

INSERT INTO passages (
    section_id,
    title,
    content_type,
    content_text,
    media_url,
    transcript,
    duration_seconds
)
SELECT
    @writing_section_id,
    'Writing Task 2 - Urban Traffic Congestion and Air Pollution',
    'text',
    'In many rapidly growing cities, traffic congestion and air pollution have become increasingly severe problems.',
    NULL,
    NULL,
    NULL
WHERE NOT EXISTS (
    SELECT 1 FROM passages
    WHERE section_id = @writing_section_id
      AND title = 'Writing Task 2 - Urban Traffic Congestion and Air Pollution'
);

SET @wp2_id = (
    SELECT id FROM passages
    WHERE section_id = @writing_section_id
      AND title = 'Writing Task 2 - Urban Traffic Congestion and Air Pollution'
    LIMIT 1
);

-- Lấy ID question_types cho Writing
SET @qt_task1 = (
    SELECT id FROM question_types
    WHERE skill_id = @writing_skill_id AND code = 'task1_general'
    LIMIT 1
);

SET @qt_task2 = (
    SELECT id FROM question_types
    WHERE skill_id = @writing_skill_id AND code = 'task2_essay'
    LIMIT 1
);

-- 4. Group 1: Writing Task 1 (Process)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @writing_section_id,
    @wp1_id,
    'Task 1',
    'You should spend about 20 minutes on this task. Write at least 150 words.',
    1
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @writing_section_id
      AND title = 'Task 1'
);

SET @wg1_id = (
    SELECT id FROM question_groups
    WHERE section_id = @writing_section_id
      AND title = 'Task 1'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT
    @wg1_id,
    @qt_task1,
    1,
    'Summarise the information by selecting and reporting the main features of the recycling process.',
    9.00,
    JSON_OBJECT('min_words', 150, 'recommended_minutes', 20, 'task_subtype', 'process_diagram')
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @wg1_id AND question_number = 1);

-- 5. Group 2: Writing Task 2 (Causes & Solutions)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @writing_section_id,
    @wp2_id,
    'Task 2',
    'You should spend about 40 minutes on this task. Write at least 250 words.',
    2
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @writing_section_id
      AND title = 'Task 2'
);

SET @wg2_id = (
    SELECT id FROM question_groups
    WHERE section_id = @writing_section_id
      AND title = 'Task 2'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT
    @wg2_id,
    @qt_task2,
    2,
    'What are the main causes of these urban issues, and what practical measures can governments and individuals take to solve them?',
    9.00,
    JSON_OBJECT('min_words', 250, 'recommended_minutes', 40, 'task_subtype', 'problem_solution')
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @wg2_id AND question_number = 2);

COMMIT;
