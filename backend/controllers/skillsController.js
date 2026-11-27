const skillsModel = require("../models/skillsModel");

const getAllSkills = async (req, res) => {
    try {
        const skills = await skillsModel.getAllSkills();

        res.status(200).json({
            status: "success",
            data: skills
        });
    } catch (error) {
        console.error("Get skills error:", error.message);

        res.status(500).json({
            status: "error",
            message: "Cannot retrieve skills"
        });
    }
};

module.exports = {
    getAllSkills
};