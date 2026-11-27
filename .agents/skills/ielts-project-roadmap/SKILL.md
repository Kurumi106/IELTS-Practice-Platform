---
name: ielts-project-roadmap
description: >-
  Implementation roadmap and phase-by-phase runbook for the IELTS Practice Platform project.
  Use this skill when the user asks to execute a project phase (e.g. "làm giai đoạn 1",
  "tiếp tục dự án"), check project progress, or plan new backend/frontend features aligned
  with the MySQL schema and existing codebase conventions.
---

# IELTS Practice Platform — Implementation Roadmap

Follow this roadmap when building, extending, or verifying phases of the IELTS Practice Platform (`f:\IELTS-Practice-Platform`). Always check `git status` and existing files before implementing a phase so completed work is not duplicated.

## Current Baseline (Phase 0 — Completed)

* **Database (`ielts_platform.sql`)**: 16 MySQL 8.0 tables (`roles`, `users`, `skills`, `tests`, `test_sections`, `passages`, `question_groups`, `question_types`, `questions`, `question_options`, `question_answers`, `test_attempts`, `user_answers`, `attempt_scores`, `writing_submissions`, `speaking_submissions`, `submission_feedback`) with 2 roles, 4 skills, and 28 question types pre-seeded.
* **Seeds & Media**:
  * Idempotent JSON importer: `backend/database/scripts/importTest.js` (`npm run seed` inside `backend/`).
  * SQL inspection helper: `backend/database/verify_tables.sql`.
  * Sample data: `backend/database/seeds/ielts_test_01_full.json`, `tests_seed.sql`, `listening_sample.sql`, `reading_sample.sql`, `writing_sample.sql`, `speaking_sample.sql`.
  * Static media served at `/uploads` (`backend/server.js`) from `backend/uploads/listening/*.wav` and `backend/uploads/writing/*.svg`.
* **Existing APIs**:
  * `GET /api/health/db` (`backend/routes/healthRoutes.js`)
  * `GET /api/skills` (`backend/routes/skillsRoutes.js`)
  * `GET /api/tests` and `GET /api/tests/:id` (`backend/routes/testRoutes.js`, metadata + `test_sections` only)
* **Frontend (`frontend/`)**: Vite + React 19 template (`frontend/src/App.jsx`); `axios` and `react-router-dom` not installed yet.

---

## Phase Execution Guide

### Phase 1: Authentication & RBAC (`roles`, `users`)
1. Install `bcryptjs` and `jsonwebtoken` in `backend/`. Add `JWT_SECRET` and `JWT_EXPIRES_IN` to `backend/.env` and `backend/.env.example`.
2. Create `authModel.js`, `authController.js`, and `authRoutes.js` (`/api/auth`):
   * `POST /api/auth/register`: validate input, hash password with `bcryptjs`, assign default role `'user'` (`role_id = 2`), enforce unique `username`/`email`.
   * `POST /api/auth/login`: verify password and `is_active = TRUE`, return JWT + safe user profile (never return `password_hash`).
   * `GET /api/auth/me`: return authenticated user info.
3. Implement `verifyToken` and `requireRole(...roles)` middleware in `backend/middleware/`.
4. **Verify**: Test register, login, `/api/auth/me` (valid token -> `200`, missing/invalid token -> `401`), and role guard (`403` for non-admin).

### Phase 2: Test Content API (`passages`, `question_groups`, `questions`, `question_options`)
1. Extend `GET /api/tests` in `backend/models/testModel.js` and `testController.js` to support optional query filters (`skill`, `test_type`, `search`).
2. Add `GET /api/tests/:id/content` (or `GET /api/sections/:sectionId`) returning nested `sections -> passages -> question_groups -> questions (with question_type metadata) -> question_options`.
3. **Security rule**: Never select or expose `question_answers` or `passages.transcript` in active test-taking endpoints.
4. **Verify**: Confirm `GET /api/tests/1/content` returns all 4 skills (`listening`, `reading`, `writing`, `speaking`), `media_url` values resolve under `/uploads/...`, and zero answer rows are present in the payload.

### Phase 3: Test Attempts & Auto-Grading (`test_attempts`, `user_answers`, `attempt_scores`)
1. Protect attempt routes with `verifyToken`; always verify `attempt.user_id === req.user.id`.
2. Implement `/api/attempts`:
   * `POST /api/attempts`: start an attempt (`status = 'in_progress'`), compute `expires_at` from `tests.duration_minutes`.
   * `PUT /api/attempts/:attemptId/answers`: upsert into `user_answers` (`unique_attempt_question`) while `status = 'in_progress'` and `NOW() <= expires_at`.
   * `POST /api/attempts/:attemptId/submit`: mark `submitted` (or `timed_out`), grade Listening & Reading against `question_options` (`choice`) and `question_answers` (`text`, trimming whitespace and honoring `case_sensitive`), compute `raw_score`, `max_score`, and IELTS `band_score` into `attempt_scores`.
   * `GET /api/attempts` & `GET /api/attempts/:attemptId/result`: return history, section scores, correct answers (`question_answers`), and `transcript` only after submission.
3. **Verify**: Run an end-to-end attempt on Listening & Reading verifying draft save, submit, score calculation, and ownership check (`403` across different users).

### Phase 4: Writing, Speaking & Reviewer Feedback (`writing_submissions`, `speaking_submissions`, `submission_feedback`)
1. **Writing**: `PUT /api/attempts/:attemptId/writing/:questionId` — save `response_text` and compute `word_count` server-side.
2. **Speaking**: Configure `multer` into `backend/uploads/speaking/` (validate audio MIME type and size limit). Add `POST /api/attempts/:attemptId/speaking/:questionId` saving `audio_url` and `duration_seconds`.
3. **Reviewer / Admin grading**:
   * `GET /api/admin/submissions` (protected by `requireRole('admin')`): list pending Writing/Speaking submissions.
   * `POST /api/admin/submissions/:type/:id/feedback`: store `overall_band`, `criterion_scores` JSON, `comments` in `submission_feedback`, mark submission `reviewed`, and update `attempt_scores`.
4. **Verify**: Submit a Writing essay and a Speaking audio upload, then submit reviewer feedback and confirm `attempt_scores` updates.

### Phase 5: Student Frontend (`frontend/`)
1. Install `axios` and `react-router-dom` in `frontend/`. Create `src/api/axiosClient.js` targeting `http://localhost:5000/api` with JWT header interceptor.
2. Replace the default Vite template in `frontend/src/App.jsx` and clean up unused Vite template assets (`icons.svg`, `hero.png`, `react.svg`, `vite.svg`).
3. Implement core pages and workspaces:
   * Login / Register and protected route wrapper.
   * Test Library & Test Detail (filter by `skills` and `test_type`).
   * Test Workspace with countdown timer (`expires_at`), question palette, auto-save, and skill-specific UIs:
     * **Listening**: audio player (`media_url`) + completion/MCQ inputs.
     * **Reading**: split-pane passage + questions.
     * **Writing**: prompt/chart image + editor with live word counter.
     * **Speaking**: Cue Card + browser `MediaRecorder` audio capture & upload.
   * Result & Attempt History page (band scores, answer review, transcripts, and reviewer feedback).
4. **Verify**: Run `npm run lint` and `npm run build` inside `frontend/`, plus smoke-test key user flows in the browser.

### Phase 6: Admin CMS (`frontend/` + `backend/`)
1. Admin APIs (`requireRole('admin')`) for creating/updating/publishing `tests`, `test_sections`, `passages`, `question_groups`, `questions`, `question_options`, `question_answers`, and uploading media files.
2. Admin UI for test management and Writing/Speaking review queue.
3. **Verify**: Create a draft test, publish it, confirm it appears in `GET /api/tests`, and verify non-admin access is rejected (`403`).

### Phase 7: Testing, Hardening & Documentation
1. Add automated API/grading tests (e.g., `node --test` or Jest/Supertest) covering auth, answer hiding, auto-grading edge cases (`case_sensitive`, timeouts), and ownership checks.
2. Update `README.md` with complete environment variables, seed instructions (`npm run seed`), and API/test commands.
3. **Verify**: Run all backend tests and `frontend` `npm run lint && npm run build` with zero errors.
