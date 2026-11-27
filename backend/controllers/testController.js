
const testModel = require("../models/testModel");

const getPublishedTests = async (req, res) => {
    try {
        const tests = await testModel.getPublishedTests();

        res.status(200).json({
            status: "success",
            total: tests.length,
            data: tests
        });
    } catch (error) {
        console.error("Get tests error:", error.message);

        res.status(500).json({
            status: "error",
            message: "Cannot retrieve tests"
        });
    }
};

const getPublishedTestById = async (req, res) => {
    try {
        const { id } = req.params;

        // Kiểm tra ID hợp lệ
        if (!/^[1-9]\d*$/.test(id)) {
            return res.status(400).json({
                status: "error",
                message: "Invalid test ID"
            });
        }

        const test = await testModel.getPublishedTestById(id);

        if (!test) {
            return res.status(404).json({
                status: "error",
                message: "Test not found"
            });
        }

        res.status(200).json({
            status: "success",
            data: test
        });

    } catch (error) {
        console.error("Get test detail error:", error.message);

        res.status(500).json({
            status: "error",
            message: "Cannot retrieve test details"
        });
    }
};

module.exports = {
    getPublishedTests,
    getPublishedTestById
};
