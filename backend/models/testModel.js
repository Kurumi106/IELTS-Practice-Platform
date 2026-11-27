
const db = require("../config/database");

const getPublishedTests = async () => {
    const [rows] = await db.query(
        `SELECT
            id,
            title,
            description,
            test_type,
            duration_minutes,
            status,
            created_at
        FROM tests
        WHERE status = ?
        ORDER BY created_at DESC`,
        ["published"]
    );

    return rows;
};

const getPublishedTestById = async (id) => {
    // Lấy thông tin đề thi
    const [tests] = await db.query(
        `SELECT
            id,
            title,
            description,
            test_type,
            duration_minutes,
            status,
            created_at
        FROM tests
        WHERE id = ?
        AND status = 'published'`,
        [id]
    );

    // Không tìm thấy đề thi
    if (tests.length === 0) {
        return null;
    }

    // Lấy danh sách các phần thi
    const [sections] = await db.query(
        `SELECT
            ts.id,
            ts.skill_id,
            s.code AS skill_code,
            s.name AS skill_name,
            ts.section_order,
            ts.title,
            ts.instructions,
            ts.duration_seconds
        FROM test_sections ts
        JOIN skills s ON ts.skill_id = s.id
        WHERE ts.test_id = ?
        ORDER BY ts.section_order ASC`,
        [id]
    );

    return {
        ...tests[0],
        sections
    };
};

module.exports = {
    getPublishedTests,
    getPublishedTestById
};