const db = require("../config/database");

const checkDatabase = async (req, res) => {
    try {
        const [rows] = await db.query("SELECT 1 AS result");

        res.json({
            status: "success",
            message: "MySQL connected successfully!",
            database: rows[0].result
        });
    } catch (error) {
        console.error("Database error:", error.message);

        res.status(500).json({
            status: "error",
            message: "Cannot connect to MySQL"
        });
    }
};

module.exports = {
    checkDatabase
};