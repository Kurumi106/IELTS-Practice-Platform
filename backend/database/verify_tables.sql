USE ielts_platform;

-- 1. Người dùng và phân quyền
SELECT * FROM roles;
SELECT * FROM users;

-- 2. Quản lý bài thi
SELECT * FROM skills;
SELECT * FROM tests;
SELECT * FROM test_sections;

-- 3. Nội dung và câu hỏi
SELECT * FROM passages;
SELECT * FROM question_groups;
SELECT * FROM question_types;
SELECT * FROM questions;
SELECT * FROM question_options;
SELECT * FROM question_answers;

-- 4. Quản lý lượt làm bài
SELECT * FROM test_attempts;
SELECT * FROM user_answers;

-- 5. Kết quả và điểm số
SELECT * FROM attempt_scores;

-- 6. Bài nộp và phản hồi
SELECT * FROM writing_submissions;
SELECT * FROM speaking_submissions;
SELECT * FROM submission_feedback;
