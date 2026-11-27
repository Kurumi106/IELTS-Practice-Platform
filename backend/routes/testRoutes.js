
const express = require("express");
const router = express.Router();

const {
    getPublishedTests,
    getPublishedTestById
} = require("../controllers/testController");

// Lấy danh sách đề thi đã xuất bản
router.get("/", getPublishedTests);

// Lấy chi tiết một đề thi
router.get("/:id", getPublishedTestById);

module.exports = router;
