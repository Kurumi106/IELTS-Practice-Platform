const fs = require("fs");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const db = require("../../config/database");

/**
 * Load skills and question_types lookup maps from the database.
 */
async function loadLookups(conn) {
    const [skillRows] = await conn.query("SELECT id, code FROM skills");
    const skillByCode = new Map(skillRows.map((row) => [row.code, row.id]));

    const [typeRows] = await conn.query(
        "SELECT id, skill_id, code FROM question_types"
    );
    const typeByKey = new Map(
        typeRows.map((row) => [`${row.skill_id}:${row.code}`, row.id])
    );

    return { skillByCode, typeByKey };
}

async function upsertTest(conn, testData) {
    const [existing] = await conn.query(
        "SELECT id FROM tests WHERE title = ? LIMIT 1",
        [testData.title]
    );

    if (existing.length > 0) {
        const testId = existing[0].id;
        await conn.query(
            `UPDATE tests
             SET description = ?, test_type = ?, duration_minutes = ?, status = ?
             WHERE id = ?`,
            [
                testData.description || null,
                testData.test_type || "full",
                testData.duration_minutes || null,
                testData.status || "published",
                testId
            ]
        );
        return testId;
    }

    const [result] = await conn.query(
        `INSERT INTO tests (title, description, test_type, duration_minutes, status)
         VALUES (?, ?, ?, ?, ?)`,
        [
            testData.title,
            testData.description || null,
            testData.test_type || "full",
            testData.duration_minutes || null,
            testData.status || "published"
        ]
    );
    return result.insertId;
}

async function upsertSection(conn, testId, skillId, sec) {
    const [existing] = await conn.query(
        `SELECT id FROM test_sections
         WHERE test_id = ? AND skill_id = ? AND section_order = ?
         LIMIT 1`,
        [testId, skillId, sec.section_order]
    );

    if (existing.length > 0) {
        const sectionId = existing[0].id;
        await conn.query(
            `UPDATE test_sections
             SET title = ?, instructions = ?, duration_seconds = ?
             WHERE id = ?`,
            [sec.title, sec.instructions || null, sec.duration_seconds || null, sectionId]
        );
        return sectionId;
    }

    const [result] = await conn.query(
        `INSERT INTO test_sections
         (test_id, skill_id, section_order, title, instructions, duration_seconds)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
            testId,
            skillId,
            sec.section_order,
            sec.title,
            sec.instructions || null,
            sec.duration_seconds || null
        ]
    );
    return result.insertId;
}

async function upsertPassage(conn, sectionId, passage) {
    const [existing] = await conn.query(
        `SELECT id FROM passages
         WHERE section_id = ? AND title = ?
         LIMIT 1`,
        [sectionId, passage.title]
    );

    if (existing.length > 0) {
        const passageId = existing[0].id;
        await conn.query(
            `UPDATE passages
             SET content_type = ?, content_text = ?, media_url = ?, transcript = ?, duration_seconds = ?
             WHERE id = ?`,
            [
                passage.content_type || "text",
                passage.content_text || null,
                passage.media_url || null,
                passage.transcript || null,
                passage.duration_seconds || null,
                passageId
            ]
        );
        return passageId;
    }

    const [result] = await conn.query(
        `INSERT INTO passages
         (section_id, title, content_type, content_text, media_url, transcript, duration_seconds)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            sectionId,
            passage.title,
            passage.content_type || "text",
            passage.content_text || null,
            passage.media_url || null,
            passage.transcript || null,
            passage.duration_seconds || null
        ]
    );
    return result.insertId;
}

async function upsertQuestionGroup(conn, sectionId, passageId, group) {
    const [existing] = await conn.query(
        `SELECT id FROM question_groups
         WHERE section_id = ? AND title = ?
         LIMIT 1`,
        [sectionId, group.title]
    );

    if (existing.length > 0) {
        const groupId = existing[0].id;
        await conn.query(
            `UPDATE question_groups
             SET passage_id = ?, instructions = ?, group_order = ?
             WHERE id = ?`,
            [passageId, group.instructions || null, group.group_order || 1, groupId]
        );
        return groupId;
    }

    const [result] = await conn.query(
        `INSERT INTO question_groups
         (section_id, passage_id, title, instructions, group_order)
         VALUES (?, ?, ?, ?, ?)`,
        [
            sectionId,
            passageId,
            group.title,
            group.instructions || null,
            group.group_order || 1
        ]
    );
    return result.insertId;
}

async function upsertQuestion(conn, groupId, questionTypeId, q) {
    const extraData = q.extra_data ? JSON.stringify(q.extra_data) : null;
    const [existing] = await conn.query(
        `SELECT id FROM questions
         WHERE group_id = ? AND question_number = ?
         LIMIT 1`,
        [groupId, q.question_number]
    );

    if (existing.length > 0) {
        const questionId = existing[0].id;
        await conn.query(
            `UPDATE questions
             SET question_type_id = ?, prompt = ?, max_score = ?, extra_data = ?
             WHERE id = ?`,
            [questionTypeId, q.prompt, q.max_score ?? 1.0, extraData, questionId]
        );
        return questionId;
    }

    const [result] = await conn.query(
        `INSERT INTO questions
         (group_id, question_type_id, question_number, prompt, max_score, extra_data)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [groupId, questionTypeId, q.question_number, q.prompt, q.max_score ?? 1.0, extraData]
    );
    return result.insertId;
}

async function upsertQuestionOption(conn, questionId, opt, index) {
    const [existing] = await conn.query(
        `SELECT id FROM question_options
         WHERE question_id = ? AND option_key = ?
         LIMIT 1`,
        [questionId, opt.option_key]
    );

    if (existing.length > 0) {
        await conn.query(
            `UPDATE question_options
             SET option_text = ?, media_url = ?, sort_order = ?
             WHERE id = ?`,
            [opt.option_text, opt.media_url || null, opt.sort_order ?? index + 1, existing[0].id]
        );
        return;
    }

    await conn.query(
        `INSERT INTO question_options
         (question_id, option_key, option_text, media_url, sort_order)
         VALUES (?, ?, ?, ?, ?)`,
        [questionId, opt.option_key, opt.option_text, opt.media_url || null, opt.sort_order ?? index + 1]
    );
}

async function insertMissingAnswer(conn, questionId, ans) {
    const answerText = typeof ans === "string" ? ans : ans.answer_text;
    const isPrimary = typeof ans === "string" ? 1 : ans.is_primary === false ? 0 : 1;
    const caseSensitive = typeof ans === "string" ? 0 : ans.case_sensitive ? 1 : 0;

    const [existing] = await conn.query(
        `SELECT id FROM question_answers
         WHERE question_id = ? AND answer_text = ?
         LIMIT 1`,
        [questionId, answerText]
    );

    if (existing.length === 0) {
        await conn.query(
            `INSERT INTO question_answers
             (question_id, answer_text, is_primary, case_sensitive)
             VALUES (?, ?, ?, ?)`,
            [questionId, answerText, isPrimary, caseSensitive]
        );
    }
}

async function importSingleTest(conn, testData, lookups) {
    const testId = await upsertTest(conn, testData);

    for (const sec of testData.sections || []) {
        const skillId = lookups.skillByCode.get(sec.skill_code);
        if (!skillId) {
            throw new Error(`Unknown skill_code: ${sec.skill_code}`);
        }

        const sectionId = await upsertSection(conn, testId, skillId, sec);
        const passageMap = new Map();

        for (const passage of sec.passages || []) {
            const passageId = await upsertPassage(conn, sectionId, passage);
            passageMap.set(passage.title, passageId);
        }

        for (const group of sec.question_groups || []) {
            const passageId = group.passage_title
                ? passageMap.get(group.passage_title) || null
                : null;
            if (group.passage_title && !passageId) {
                throw new Error(
                    `Passage "${group.passage_title}" not found in section "${sec.title}"`
                );
            }

            const groupId = await upsertQuestionGroup(conn, sectionId, passageId, group);

            for (const q of group.questions || []) {
                const typeId = lookups.typeByKey.get(`${skillId}:${q.question_type}`);
                if (!typeId) {
                    throw new Error(
                        `Unknown question_type "${q.question_type}" for skill "${sec.skill_code}"`
                    );
                }

                const questionId = await upsertQuestion(conn, groupId, typeId, q);

                for (let i = 0; i < (q.options || []).length; i++) {
                    await upsertQuestionOption(conn, questionId, q.options[i], i);
                }

                for (const ans of q.answers || []) {
                    await insertMissingAnswer(conn, questionId, ans);
                }
            }
        }
    }

    return testId;
}

async function main() {
    const inputPath = process.argv[2]
        ? path.resolve(process.cwd(), process.argv[2])
        : path.resolve(__dirname, "../seeds/ielts_test_01_full.json");

    const raw = fs.readFileSync(inputPath, "utf8");
    const payload = JSON.parse(raw);
    const tests = Array.isArray(payload) ? payload : [payload];

    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const lookups = await loadLookups(conn);

        const importedIds = [];
        for (const testData of tests) {
            const id = await importSingleTest(conn, testData, lookups);
            importedIds.push({ id, title: testData.title });
        }

        await conn.commit();
        console.log("Seeded tests successfully:", importedIds);
    } catch (error) {
        await conn.rollback();
        console.error("Failed to seed tests:", error.message);
        process.exitCode = 1;
    } finally {
        conn.release();
        await db.end();
    }
}

main();
