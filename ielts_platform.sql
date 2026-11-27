CREATE DATABASE IF NOT EXISTS ielts_platform
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ielts_platform;

CREATE TABLE IF NOT EXISTS roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id TINYINT UNSIGNED NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
        
        CONSTRAINT fk_users_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO roles (id, name, description)
VALUES
(1, 'admin', 'Quan tri he thong'),
(2, 'user', 'Nguoi dung thong thuong');

CREATE TABLE IF NOT EXISTS skills (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,

    test_type ENUM('full', 'skill_practice')
        NOT NULL DEFAULT 'full',

    duration_minutes SMALLINT UNSIGNED,

    status ENUM('draft', 'published', 'archived')
        NOT NULL DEFAULT 'draft',

    created_by BIGINT UNSIGNED,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tests_users
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS test_sections (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    test_id BIGINT UNSIGNED NOT NULL,
    skill_id TINYINT UNSIGNED NOT NULL,

    section_order TINYINT UNSIGNED NOT NULL,

    title VARCHAR(255) NOT NULL,
    instructions TEXT,

    duration_seconds INT UNSIGNED,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sections_tests
        FOREIGN KEY (test_id)
        REFERENCES tests(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_sections_skills
        FOREIGN KEY (skill_id)
        REFERENCES skills(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    UNIQUE KEY unique_test_section (
        test_id,
        skill_id,
        section_order
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO skills (id, code, name)
VALUES
(1, 'listening', 'Listening'),
(2, 'reading', 'Reading'),
(3, 'writing', 'Writing'),
(4, 'speaking', 'Speaking');

CREATE TABLE IF NOT EXISTS passages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    section_id BIGINT UNSIGNED NOT NULL,

    title VARCHAR(255),
    content_type ENUM('text', 'audio', 'image', 'mixed')
        NOT NULL DEFAULT 'text',

    content_text LONGTEXT,
    media_url VARCHAR(1000),
    transcript LONGTEXT,

    duration_seconds INT UNSIGNED,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_passages_sections
        FOREIGN KEY (section_id)
        REFERENCES test_sections(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS question_groups (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    section_id BIGINT UNSIGNED NOT NULL,
    passage_id BIGINT UNSIGNED,

    title VARCHAR(255),
    instructions TEXT,

    group_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_groups_sections
        FOREIGN KEY (section_id)
        REFERENCES test_sections(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_groups_passages
        FOREIGN KEY (passage_id)
        REFERENCES passages(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS question_types (
    id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    skill_id TINYINT UNSIGNED NOT NULL,

    code VARCHAR(80) NOT NULL,
    name VARCHAR(150) NOT NULL,

    response_mode ENUM(
        'choice',
        'text',
        'essay',
        'audio',
        'spoken'
    ) NOT NULL,

    grading_mode ENUM(
        'automatic',
        'manual',
        'assisted'
    ) NOT NULL,

    description TEXT,

    UNIQUE KEY unique_skill_question_type (
        skill_id,
        code
    ),

    CONSTRAINT fk_question_types_skills
        FOREIGN KEY (skill_id)
        REFERENCES skills(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    group_id BIGINT UNSIGNED NOT NULL,
    question_type_id SMALLINT UNSIGNED NOT NULL,

    question_number SMALLINT UNSIGNED NOT NULL,
    prompt TEXT NOT NULL,

    max_score DECIMAL(5,2) NOT NULL DEFAULT 1.00,

    extra_data JSON,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_questions_groups
        FOREIGN KEY (group_id)
        REFERENCES question_groups(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_questions_types
        FOREIGN KEY (question_type_id)
        REFERENCES question_types(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY unique_group_question (
        group_id,
        question_number
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS question_options (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    group_id BIGINT UNSIGNED NULL,
    question_id BIGINT UNSIGNED NULL,

    option_key VARCHAR(20) NOT NULL,
    option_text TEXT NOT NULL,

    media_url VARCHAR(1000),

    sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,

    CONSTRAINT fk_options_groups
        FOREIGN KEY (group_id)
        REFERENCES question_groups(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_options_questions
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    UNIQUE KEY unique_group_option (
        group_id,
        option_key
    ),

    UNIQUE KEY unique_question_option (
        question_id,
        option_key
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS question_answers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    question_id BIGINT UNSIGNED NOT NULL,

    answer_text VARCHAR(1000) NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT TRUE,
    case_sensitive BOOLEAN NOT NULL DEFAULT FALSE,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_answers_questions
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO question_types
(skill_id, code, name, response_mode, grading_mode)
VALUES

-- LISTENING
(1, 'multiple_choice', 'Multiple Choice', 'choice', 'automatic'),
(1, 'matching', 'Matching', 'choice', 'automatic'),
(1, 'map_labelling', 'Plan/Map/Diagram Labelling', 'text', 'automatic'),
(1, 'form_completion', 'Form Completion', 'text', 'automatic'),
(1, 'note_completion', 'Note Completion', 'text', 'automatic'),
(1, 'table_completion', 'Table Completion', 'text', 'automatic'),
(1, 'flow_chart_completion', 'Flow-chart Completion', 'text', 'automatic'),
(1, 'sentence_completion', 'Sentence Completion', 'text', 'automatic'),
(1, 'short_answer', 'Short Answer', 'text', 'automatic'),

-- READING
(2, 'multiple_choice', 'Multiple Choice', 'choice', 'automatic'),
(2, 'true_false_not_given', 'True/False/Not Given', 'choice', 'automatic'),
(2, 'yes_no_not_given', 'Yes/No/Not Given', 'choice', 'automatic'),
(2, 'matching_headings', 'Matching Headings', 'choice', 'automatic'),
(2, 'matching_information', 'Matching Information', 'choice', 'automatic'),
(2, 'matching_features', 'Matching Features', 'choice', 'automatic'),
(2, 'matching_sentence_endings', 'Matching Sentence Endings', 'choice', 'automatic'),
(2, 'summary_completion', 'Summary Completion', 'text', 'automatic'),
(2, 'note_completion', 'Note Completion', 'text', 'automatic'),
(2, 'table_completion', 'Table Completion', 'text', 'automatic'),
(2, 'flow_chart_completion', 'Flow-chart Completion', 'text', 'automatic'),
(2, 'sentence_completion', 'Sentence Completion', 'text', 'automatic'),
(2, 'short_answer', 'Short Answer', 'text', 'automatic'),
(2, 'diagram_labelling', 'Diagram Labelling', 'text', 'automatic'),

-- WRITING
(3, 'task1_general', 'Writing Task 1', 'essay', 'assisted'),
(3, 'task2_essay', 'Writing Task 2', 'essay', 'assisted'),

-- SPEAKING
(4, 'part1', 'Speaking Part 1', 'spoken', 'assisted'),
(4, 'part2', 'Speaking Part 2', 'spoken', 'assisted'),
(4, 'part3', 'Speaking Part 3', 'spoken', 'assisted');

CREATE TABLE IF NOT EXISTS test_attempts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,
    test_id BIGINT UNSIGNED NOT NULL,

    status ENUM(
        'in_progress',
        'submitted',
        'timed_out',
        'abandoned'
    ) NOT NULL DEFAULT 'in_progress',

    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at DATETIME NULL,
    expires_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_attempts_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_attempts_tests
        FOREIGN KEY (test_id)
        REFERENCES tests(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_attempts_user (user_id),
    INDEX idx_attempts_test (test_id),
    INDEX idx_attempts_status (status)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_answers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    attempt_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,

    selected_option_id BIGINT UNSIGNED NULL,
    answer_text TEXT NULL,
    response_data JSON NULL,

    is_correct BOOLEAN NULL,
    score_awarded DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    answered_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_answers_attempts
        FOREIGN KEY (attempt_id)
        REFERENCES test_attempts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_user_answers_questions
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_user_answers_options
        FOREIGN KEY (selected_option_id)
        REFERENCES question_options(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    UNIQUE KEY unique_attempt_question (
        attempt_id,
        question_id
    ),

    INDEX idx_user_answers_question (question_id)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attempt_scores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    attempt_id BIGINT UNSIGNED NOT NULL,
    skill_id TINYINT UNSIGNED NOT NULL,

    raw_score DECIMAL(6,2) NULL,
    max_score DECIMAL(6,2) NULL,

    band_score DECIMAL(2,1) NULL,

    grading_status ENUM(
        'pending',
        'in_progress',
        'completed'
    ) NOT NULL DEFAULT 'pending',

    feedback TEXT NULL,

    graded_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_scores_attempts
        FOREIGN KEY (attempt_id)
        REFERENCES test_attempts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_scores_skills
        FOREIGN KEY (skill_id)
        REFERENCES skills(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY unique_attempt_skill (
        attempt_id,
        skill_id
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS writing_submissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    attempt_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,

    response_text LONGTEXT,

    word_count INT UNSIGNED NOT NULL DEFAULT 0,

    status ENUM(
        'draft',
        'submitted',
        'under_review',
        'reviewed'
    ) NOT NULL DEFAULT 'draft',

    submitted_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_writing_attempts
        FOREIGN KEY (attempt_id)
        REFERENCES test_attempts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_writing_questions
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY unique_writing_response (
        attempt_id,
        question_id
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS speaking_submissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    attempt_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,

    audio_url VARCHAR(1000),
    transcript LONGTEXT,

    duration_seconds INT UNSIGNED,

    status ENUM(
        'draft',
        'submitted',
        'under_review',
        'reviewed'
    ) NOT NULL DEFAULT 'draft',

    submitted_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_speaking_attempts
        FOREIGN KEY (attempt_id)
        REFERENCES test_attempts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_speaking_questions
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY unique_speaking_response (
        attempt_id,
        question_id
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS submission_feedback (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    writing_submission_id BIGINT UNSIGNED NULL,
    speaking_submission_id BIGINT UNSIGNED NULL,

    reviewer_id BIGINT UNSIGNED NULL,

    overall_band DECIMAL(2,1),

    criterion_scores JSON,

    comments TEXT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_feedback_writing
        FOREIGN KEY (writing_submission_id)
        REFERENCES writing_submissions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_feedback_speaking
        FOREIGN KEY (speaking_submission_id)
        REFERENCES speaking_submissions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_feedback_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    UNIQUE KEY unique_writing_feedback (
        writing_submission_id
    ),

    UNIQUE KEY unique_speaking_feedback (
        speaking_submission_id
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;