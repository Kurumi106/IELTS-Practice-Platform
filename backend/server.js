
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const healthRoutes = require("./routes/healthRoutes");
const skillsRoutes = require("./routes/skillsRoutes");
const testRoutes = require("./routes/testRoutes");

const app = express();

// Middleware
app.use(cors({
    origin: "http://localhost:5173"
}));

app.use(express.json());

// API kiểm tra Server
app.get("/", (req, res) => {
    res.json({
        message: "IELTS Practice Platform API is running!"
    });
});

// Đăng ký Health Routes
app.use("/api/health", healthRoutes);
app.use("/api/skills", skillsRoutes);
app.use("/api/tests", testRoutes);

// Khởi động Server
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});