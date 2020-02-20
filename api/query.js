var express = require("express");
const redis = require("redis");
const moment = require("moment");
const { redisConfig } = require("./config");

var router = express.Router();
const client = redis.createClient(redisConfig);

// define the home page route
router.post("/users", function (req, res) {
    console.log(`[GET /data/users] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        client.SCARD("users", (err, value) => {
            if (err) {
                console.error("[GET /data/users] Error occured during Redis SMEMBERS");
                res.status(400).json({ "msg": "Error occured during Redis reading users" });
                return;
            }
            return res.status(200).json(value);
        });
    } catch (e) {
        console.error(e.stack);
        res.status(500).json({ "msg": e.message });
    }
});

module.exports = router;