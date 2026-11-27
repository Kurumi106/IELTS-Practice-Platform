START TRANSACTION;

-- 1. Đảm bảo có test 'IELTS Reading Practice 01'
INSERT INTO tests (title, description, test_type, duration_minutes, status)
SELECT
    'IELTS Reading Practice 01',
    'Reading skill practice test',
    'skill_practice',
    60,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM tests WHERE title = 'IELTS Reading Practice 01'
);

SET @reading_test_id = (
    SELECT id FROM tests WHERE title = 'IELTS Reading Practice 01' LIMIT 1
);

SET @reading_skill_id = (
    SELECT id FROM skills WHERE code = 'reading' LIMIT 1
);

-- 2. Tạo Test Section cho Reading Practice 01
INSERT INTO test_sections (
    test_id,
    skill_id,
    section_order,
    title,
    instructions,
    duration_seconds
)
SELECT
    @reading_test_id,
    @reading_skill_id,
    1,
    'Reading Practice - Passage 1',
    'Read the passage carefully and answer Questions 1-8.',
    3600
WHERE NOT EXISTS (
    SELECT 1 FROM test_sections
    WHERE test_id = @reading_test_id
      AND skill_id = @reading_skill_id
      AND section_order = 1
);

SET @reading_section_id = (
    SELECT id FROM test_sections
    WHERE test_id = @reading_test_id
      AND skill_id = @reading_skill_id
      AND section_order = 1
    LIMIT 1
);

-- 3. Tạo Passage mẫu
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
    @reading_section_id,
    'The History and Science of Urban Microclimates',
    'text',
    'Cities do not merely sit inside regional climates; they actively reshape them. For over a century, meteorologists have observed that densely built urban centres consistently record higher air temperatures than surrounding rural farmland, a phenomenon known as the Urban Heat Island (UHI) effect. On calm, clear summer nights, the temperature gap between a metropolis and nearby countryside can exceed four degrees Celsius.\n\nThe primary driver of this warming is the replacement of soil and vegetation with dark, impermeable surfaces such as asphalt roads and concrete rooftops. Natural landscapes cool themselves through evapotranspiration, the combined process of water evaporating from soil and transpiring from plant leaves. By contrast, dark construction materials absorb short-wave solar radiation throughout the afternoon and release that stored thermal energy slowly after sunset.\n\nUrban geometry also plays a decisive role. Narrow streets flanked by tall buildings form what climatologists call urban canyons. These canyons trap outgoing long-wave radiation that would otherwise escape into the night sky and simultaneously obstruct cooling winds. Waste heat emitted by air-conditioning units, vehicles, and industrial machinery compounds the problem, particularly during peak summer heatwaves.\n\nIn response, municipal planners in cities from Melbourne to Singapore have experimented with passive cooling interventions. Coating roofs with high-albedo reflective paint lowers surface temperatures by bouncing sunlight back into the atmosphere, while expanding urban tree canopies provides direct shade and restores natural moisture exchange. Field measurements indicate that combining green corridors with reflective pavements can reduce peak street-level temperatures by up to two degrees Celsius without increasing electricity demand.',
    NULL,
    NULL,
    NULL
WHERE NOT EXISTS (
    SELECT 1 FROM passages
    WHERE section_id = @reading_section_id
      AND title = 'The History and Science of Urban Microclimates'
);

SET @reading_passage_id = (
    SELECT id FROM passages
    WHERE section_id = @reading_section_id
      AND title = 'The History and Science of Urban Microclimates'
    LIMIT 1
);

-- Lấy ID question_types
SET @qt_tfng = (
    SELECT id FROM question_types
    WHERE skill_id = @reading_skill_id AND code = 'true_false_not_given'
    LIMIT 1
);

SET @qt_mc = (
    SELECT id FROM question_types
    WHERE skill_id = @reading_skill_id AND code = 'multiple_choice'
    LIMIT 1
);

SET @qt_summary = (
    SELECT id FROM question_types
    WHERE skill_id = @reading_skill_id AND code = 'summary_completion'
    LIMIT 1
);

-- 4. Group 1: True / False / Not Given (Questions 1-3)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @reading_section_id,
    @reading_passage_id,
    'Questions 1-3: True / False / Not Given',
    'Do the following statements agree with the information given in the passage? Choose TRUE, FALSE, or NOT GIVEN.',
    1
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 1-3: True / False / Not Given'
);

SET @rg1_id = (
    SELECT id FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 1-3: True / False / Not Given'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg1_id, @qt_tfng, 1, 'On calm summer nights, large cities can be more than 4 degrees Celsius warmer than nearby rural areas.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg1_id AND question_number = 1);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg1_id, @qt_tfng, 2, 'Asphalt and concrete release all of their absorbed solar heat immediately at noon.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg1_id AND question_number = 2);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg1_id, @qt_tfng, 3, 'Singapore spends a larger proportion of its annual budget on tree planting than Melbourne.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg1_id AND question_number = 3);

-- Options cho TFNG (Questions 1-3)
INSERT INTO question_options (question_id, option_key, option_text, sort_order)
SELECT q.id, opt.k, opt.k, opt.s
FROM questions q
JOIN (
    SELECT 'TRUE' AS k, 1 AS s
    UNION ALL SELECT 'FALSE', 2
    UNION ALL SELECT 'NOT GIVEN', 3
) opt
WHERE q.group_id = @rg1_id
  AND q.question_number IN (1, 2, 3)
  AND NOT EXISTS (
      SELECT 1 FROM question_options qo
      WHERE qo.question_id = q.id AND qo.option_key = opt.k
  );

-- Answers cho TFNG
INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'TRUE', 1, 0 FROM questions q
WHERE q.group_id = @rg1_id AND q.question_number = 1
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'TRUE');

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'FALSE', 1, 0 FROM questions q
WHERE q.group_id = @rg1_id AND q.question_number = 2
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'FALSE');

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'NOT GIVEN', 1, 0 FROM questions q
WHERE q.group_id = @rg1_id AND q.question_number = 3
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'NOT GIVEN');

-- 5. Group 2: Multiple Choice (Questions 4-5)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @reading_section_id,
    @reading_passage_id,
    'Questions 4-5: Multiple Choice',
    'Choose the correct letter, A, B, C, or D.',
    2
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 4-5: Multiple Choice'
);

SET @rg2_id = (
    SELECT id FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 4-5: Multiple Choice'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg2_id, @qt_mc, 4, 'How do urban canyons contribute to higher temperatures?', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg2_id AND question_number = 4);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg2_id, @qt_mc, 5, 'What benefit of combining green corridors and reflective pavements is mentioned in the final paragraph?', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg2_id AND question_number = 5);

-- Options cho Q4
INSERT INTO question_options (question_id, option_key, option_text, sort_order)
SELECT q.id, opt.k, opt.t, opt.s
FROM questions q
JOIN (
    SELECT 'A' AS k, 'They trap outgoing heat and block cooling breezes.' AS t, 1 AS s
    UNION ALL SELECT 'B', 'They increase evaporation from nearby rivers.', 2
    UNION ALL SELECT 'C', 'They reflect solar radiation back into space.', 3
    UNION ALL SELECT 'D', 'They prevent vehicles from entering city centres.', 4
) opt
WHERE q.group_id = @rg2_id AND q.question_number = 4
  AND NOT EXISTS (SELECT 1 FROM question_options qo WHERE qo.question_id = q.id AND qo.option_key = opt.k);

-- Options cho Q5
INSERT INTO question_options (question_id, option_key, option_text, sort_order)
SELECT q.id, opt.k, opt.t, opt.s
FROM questions q
JOIN (
    SELECT 'A' AS k, 'It completely eliminates the need for air conditioning.' AS t, 1 AS s
    UNION ALL SELECT 'B', 'It lowers street-level peak temperatures without using extra power.' AS t, 2
    UNION ALL SELECT 'C', 'It doubles the lifespan of asphalt highways.' AS t, 3
    UNION ALL SELECT 'D', 'It reduces rainfall runoff in rural farmland.' AS t, 4
) opt
WHERE q.group_id = @rg2_id AND q.question_number = 5
  AND NOT EXISTS (SELECT 1 FROM question_options qo WHERE qo.question_id = q.id AND qo.option_key = opt.k);

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'A', 1, 0 FROM questions q
WHERE q.group_id = @rg2_id AND q.question_number = 4
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'A');

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'B', 1, 0 FROM questions q
WHERE q.group_id = @rg2_id AND q.question_number = 5
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'B');

-- 6. Group 3: Summary Completion (Questions 6-8)
INSERT INTO question_groups (
    section_id, passage_id, title, instructions, group_order
)
SELECT
    @reading_section_id,
    @reading_passage_id,
    'Questions 6-8: Summary Completion',
    'Complete the summary below. Choose ONE WORD ONLY from the passage for each answer.',
    3
WHERE NOT EXISTS (
    SELECT 1 FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 6-8: Summary Completion'
);

SET @rg3_id = (
    SELECT id FROM question_groups
    WHERE section_id = @reading_section_id
      AND title = 'Questions 6-8: Summary Completion'
    LIMIT 1
);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg3_id, @qt_summary, 6, 'Natural areas cool down through ______ from soil and plant leaves.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg3_id AND question_number = 6);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg3_id, @qt_summary, 7, 'Extra heat from vehicles and air-conditioning units worsens urban warming during summer ______.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg3_id AND question_number = 7);

INSERT INTO questions (group_id, question_type_id, question_number, prompt, max_score)
SELECT @rg3_id, @qt_summary, 8, 'Planners use reflective paint with high ______ to bounce sunlight off rooftops.', 1.00
WHERE NOT EXISTS (SELECT 1 FROM questions WHERE group_id = @rg3_id AND question_number = 8);

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'evapotranspiration', 1, 0 FROM questions q
WHERE q.group_id = @rg3_id AND q.question_number = 6
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'evapotranspiration');

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'heatwaves', 1, 0 FROM questions q
WHERE q.group_id = @rg3_id AND q.question_number = 7
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'heatwaves');

INSERT INTO question_answers (question_id, answer_text, is_primary, case_sensitive)
SELECT q.id, 'albedo', 1, 0 FROM questions q
WHERE q.group_id = @rg3_id AND q.question_number = 8
  AND NOT EXISTS (SELECT 1 FROM question_answers a WHERE a.question_id = q.id AND a.answer_text = 'albedo');

COMMIT;
