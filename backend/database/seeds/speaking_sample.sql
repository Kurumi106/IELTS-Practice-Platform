START TRANSACTION;

-- 1. Đảm bảo có test 'IELTS Speaking Practice 01'
INSERT INTO tests (title, description, test_type, duration_minutes, status)
SELECT
    'IELTS Speaking Practice 01',
    'Speaking skill practice test',
    'skill_practice',
    15,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM tests WHERE title = 'IELTS Speaking Practice 01'
);

SET @speaking_test_id = (
    SELECT id FROM tests WHERE title = 'IELTS Speaking Practice 01' LIMIT 1
);

SET @speaking_skill_id = (
    SELECT id FROM skills WHERE code = 'speaking' LIMIT 1
);

-- 2. Tạo Test Section cho Speaking Practice 01
INSERT INTO test_sections (
    test_id,
    skill_id,
    section_order,
    title,
    instructions,
    duration_seconds
)
SELECT
    @speaking_test_id,
    @speaking_skill_id,
    1,
    'Speaking Practice - Full 3 Parts',
    'Complete Speaking Part 1, Part 2 and Part 3.',
    900
WHERE NOT EXISTS (
    SELECT 1 FROM test_sections
    WHERE test_id = @speaking_test_id
      AND skill_id = @speaking_skill_id
      AND section_order = 1
);

SET @speaking_section_id = (
    SELECT id FROM test_sections
    WHERE test_id = @speaking_test_id
      AND skill_id = @speaking_skill_id
      AND section_order = 1
    LIMIT 1
);

-- 3. Tạo Passage Cue Card cho Part 2
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
    @speaking_section_id,
    'Part 2 Cue Card - A Place with Natural Beauty',
    'text',
    'Describe a natural place (such as a park, mountain, or lake) that you enjoyed visiting.\nYou should say:\n- where this place is\n- when and with whom you went there\n- what you saw and did there\nand explain why you found this place memorable.',
    NULL,
    NULL,
    NULL
WHERE NOT EXISTS (
    SELECT 1 FROM passages
    WHERE section_id = @speaking_section_id
      AND title = 'Part 2 Cue Card - A Place with Natural Beauty'
);

SET @speaking_cue_id = (
    SELECT id FROM passages
    WHERE section_id = @speaking_section_id
      AND title = 'Part 2 Cue Card - A Place with Natural Beauty'
    LIMIT 1
);

-- Lấy ID question_types cho Speaking
SET @qt_part1 = (
    SELECT id FROM question_types
    WHERE skill_id = @speaking_skill_id AND code = 'part1'
    LIMIT 1
);

SET @qt_part2 = (
    SELECT id FROM question_types
    WHERE skill_id = @speaking_skill_id AND code = 'part2'
    LIMIT 1
);

SET @qt_part3 = (
    SELECT id FROM question_types
    WHERE skill_id = @speaking_skill_id AND code = 'part3'
    LIMIT 1
);

-- 4. Group 1: Speaking Part 1 (Questions 1-3)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @speaking_section_id,
    NULL,
    'Part 1 - Hometown & Environment',
    NULL,
    1
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 1 - Hometown & Environment'
);

SET @sg1_id = (
    SELECT id FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 1 - Hometown & Environment'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg1_id, @qt_part1, 1, 'Where is your hometown, and what do you like most about living there?', 9.00, JSON_OBJECT('recommended_seconds', 30)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg1_id AND question_number = 1);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg1_id, @qt_part1, 2, 'Are there many green parks or outdoor spaces near your home?', 9.00, JSON_OBJECT('recommended_seconds', 30)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg1_id AND question_number = 2);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg1_id, @qt_part1, 3, 'Do you prefer spending weekends indoors or outdoors? Why?', 9.00, JSON_OBJECT('recommended_seconds', 30)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg1_id AND question_number = 3);

-- 5. Group 2: Speaking Part 2 (Question 4)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @speaking_section_id,
    @speaking_cue_id,
    'Part 2 - Individual Long Turn',
    'You have 1 minute to prepare notes and should speak for 1-2 minutes.',
    2
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 2 - Individual Long Turn'
);

SET @sg2_id = (
    SELECT id FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 2 - Individual Long Turn'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg2_id, @qt_part2, 4, 'Describe a natural place you enjoyed visiting based on the cue card.', 9.00, JSON_OBJECT('prep_seconds', 60, 'speak_seconds', 120)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg2_id AND question_number = 4);

-- 6. Group 3: Speaking Part 3 (Questions 5-7)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @speaking_section_id,
    NULL,
    'Part 3 - Ecotourism & Conservation',
    NULL,
    3
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 3 - Ecotourism & Conservation'
);

SET @sg3_id = (
    SELECT id FROM question_groups
    WHERE section_id = @speaking_section_id
      AND title = 'Part 3 - Ecotourism & Conservation'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg3_id, @qt_part3, 5, 'Why do people living in large cities often want to travel to natural areas on holiday?', 9.00, JSON_OBJECT('recommended_seconds', 45)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg3_id AND question_number = 5);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg3_id, @qt_part3, 6, 'How can tourism negatively affect fragile natural environments?', 9.00, JSON_OBJECT('recommended_seconds', 45)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg3_id AND question_number = 6);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score, extra_data)
SELECT @sg3_id, @qt_part3, 7, 'Should governments limit the number of visitors to national parks? Why or why not?', 9.00, JSON_OBJECT('recommended_seconds', 45)
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @sg3_id AND question_number = 7);

COMMIT;
