START TRANSACTION;

-- 1. Tạo Passage
-- Chưa có file audio nên media_url để NULL.
-- Transcript dùng cho quản trị và phát triển nội dung.
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
    1,
    'Hotel Booking - Part 1',
    'audio',
    NULL,
    NULL,
    'Receptionist: Good morning, Green Hotel. How can I help you?
Customer: Hello. I would like to book a room for two nights.
Receptionist: Certainly. May I have your full name?
Customer: My name is David Wilson.
Receptionist: Could you spell your surname, please?
Customer: W-I-L-S-O-N.
Receptionist: Thank you. What date would you like to check in?
Customer: The 15th of August.
Receptionist: And how many guests?
Customer: Two adults.
Receptionist: Finally, could I have your telephone number?
Customer: Yes, it is 0794561238.
Receptionist: Thank you, Mr Wilson. Your booking request has been recorded.',
    150
WHERE NOT EXISTS (
    SELECT 1
    FROM passages
    WHERE section_id = 1
      AND title = 'Hotel Booking - Part 1'
);

-- Lấy ID Passage
SET @passage_id = (
    SELECT id
    FROM passages
    WHERE section_id = 1
      AND title = 'Hotel Booking - Part 1'
    LIMIT 1
);

-- 2. Tạo Question Group
INSERT INTO question_groups (
    section_id,
    passage_id,
    title,
    instructions,
    group_order
)
SELECT
    1,
    @passage_id,
    'Part 1 - Hotel Booking Form',
    'Listen to the conversation and complete the booking form. Write NO MORE THAN TWO WORDS AND/OR A NUMBER for each answer.',
    1
WHERE NOT EXISTS (
    SELECT 1
    FROM question_groups
    WHERE section_id = 1
      AND title = 'Part 1 - Hotel Booking Form'
);

-- Lấy ID Question Group
SET @group_id = (
    SELECT id
    FROM question_groups
    WHERE section_id = 1
      AND title = 'Part 1 - Hotel Booking Form'
    LIMIT 1
);

-- 3. Tạo 5 Questions
INSERT INTO questions (
    group_id,
    question_type_id,
    question_number,
    prompt,
    max_score
)
SELECT @group_id, 4, 1, 'Guest surname: ______', 1.00
WHERE NOT EXISTS (
    SELECT 1 FROM questions
    WHERE group_id = @group_id AND question_number = 1
);

INSERT INTO questions (
    group_id, question_type_id, question_number, prompt, max_score
)
SELECT @group_id, 4, 2, 'Check-in date: ______', 1.00
WHERE NOT EXISTS (
    SELECT 1 FROM questions
    WHERE group_id = @group_id AND question_number = 2
);

INSERT INTO questions (
    group_id, question_type_id, question_number, prompt, max_score
)
SELECT @group_id, 4, 3, 'Number of guests: ______', 1.00
WHERE NOT EXISTS (
    SELECT 1 FROM questions
    WHERE group_id = @group_id AND question_number = 3
);

INSERT INTO questions (
    group_id, question_type_id, question_number, prompt, max_score
)
SELECT @group_id, 4, 4, 'Guest first name: ______', 1.00
WHERE NOT EXISTS (
    SELECT 1 FROM questions
    WHERE group_id = @group_id AND question_number = 4
);

INSERT INTO questions (
    group_id, question_type_id, question_number, prompt, max_score
)
SELECT @group_id, 4, 5, 'Telephone number: ______', 1.00
WHERE NOT EXISTS (
    SELECT 1 FROM questions
    WHERE group_id = @group_id AND question_number = 5
);

-- 4. Tạo Answers
INSERT INTO question_answers (
    question_id, answer_text, is_primary, case_sensitive
)
SELECT q.id, 'Wilson', 1, 0
FROM questions q
WHERE q.group_id = @group_id
  AND q.question_number = 1
  AND NOT EXISTS (
      SELECT 1 FROM question_answers a
      WHERE a.question_id = q.id
        AND a.answer_text = 'Wilson'
  );

INSERT INTO question_answers (
    question_id, answer_text, is_primary, case_sensitive
)
SELECT q.id, '15th August', 1, 0
FROM questions q
WHERE q.group_id = @group_id
  AND q.question_number = 2
  AND NOT EXISTS (
      SELECT 1 FROM question_answers a
      WHERE a.question_id = q.id
        AND a.answer_text = '15th August'
  );

INSERT INTO question_answers (
    question_id, answer_text, is_primary, case_sensitive
)
SELECT q.id, '2', 1, 0
FROM questions q
WHERE q.group_id = @group_id
  AND q.question_number = 3
  AND NOT EXISTS (
      SELECT 1 FROM question_answers a
      WHERE a.question_id = q.id
        AND a.answer_text = '2'
  );

INSERT INTO question_answers (
    question_id, answer_text, is_primary, case_sensitive
)
SELECT q.id, 'David', 1, 0
FROM questions q
WHERE q.group_id = @group_id
  AND q.question_number = 4
  AND NOT EXISTS (
      SELECT 1 FROM question_answers a
      WHERE a.question_id = q.id
        AND a.answer_text = 'David'
  );

INSERT INTO question_answers (
    question_id, answer_text, is_primary, case_sensitive
)
SELECT q.id, '0794561238', 1, 0
FROM questions q
WHERE q.group_id = @group_id
  AND q.question_number = 5
  AND NOT EXISTS (
      SELECT 1 FROM question_answers a
      WHERE a.question_id = q.id
        AND a.answer_text = '0794561238'
  );

COMMIT;