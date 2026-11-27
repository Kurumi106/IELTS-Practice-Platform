const db = require("../config/database");

const getAllSkills = async () => {
    const [rows] = await db.query(
        "SELECT id, code, name FROM skills ORDER BY id"
    );

    return rows;
};

module.exports = {
    getAllSkills
};