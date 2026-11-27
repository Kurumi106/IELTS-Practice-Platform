INSERT INTO tests
(title, description, test_type, duration_minutes, status)
VALUES
(
    'IELTS Test 01',
    'Full IELTS practice test',
    'full',
    165,
    'published'
),
(
    'IELTS Listening Practice 01',
    'Listening skill practice test',
    'skill_practice',
    30,
    'published'
),
(
    'IELTS Reading Practice 01',
    'Reading skill practice test',
    'skill_practice',
    60,
    'published'
),
(
    'IELTS Writing Practice 01',
    'Writing skill practice test',
    'skill_practice',
    60,
    'draft'
),
(
    'IELTS Speaking Practice 01',
    'Speaking skill practice test',
    'skill_practice',
    15,
    'published'
);

INSERT INTO test_sections
    (test_id, skill_id, section_order, title, instructions, duration_seconds)
VALUES
    (1, 1, 1, 'Listening Test',
     'Listen to the recordings and answer the questions.',
     1800),

    (1, 2, 2, 'Reading Test',
     'Read the passages and answer the questions.',
     3600),

    (1, 3, 3, 'Writing Test',
     'Complete Writing Task 1 and Task 2.',
     3600),

    (1, 4, 4, 'Speaking Test',
     'Complete Speaking Part 1, Part 2 and Part 3.',
     900);