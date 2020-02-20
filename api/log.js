var express = require("express");
const redis = require("redis");
const moment = require("moment");
const redisConfig = require("./config");

var router = express.Router();
const client = redis.createClient(redisConfig.localConfig);

// define the home page route
router.post("/", function (req, res) {
    console.log(`[POST /mwlog] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        const body = req.body;
        console.log(`[POST /mwlog] ${JSON.stringify(body)}`);
        if (!("user" in body) || !("timestamp" in body) || !("data" in body)) {
            console.error("[POST /mwlog] Missing Required Params in body");
            res.status(400).json({ "msg": "Missing Required Params in body" });
            return;
        }
        const { user, timestamp, data } = body;
        if (Object.keys(data).length === 0) {
            console.error("[POST /mwlog] Data is empty");
            res.status(400).json({ "msg": "Data cannot be empty" });
            return;
        }
        console.log(`user: ${user}, timestamp: ${timestamp}`);
        console.log(`data: ${JSON.stringify(data)}`);
        
        client.SADD("users", `${user}`, (err) => {
            if (err) {
                console.error("[POST /mwlog] Error occured during Redis SADD");
                res.status(400).json({ "msg": "Error occured during Redis SADD" });
                return;
            }
            client.ZADD(`${user}`, timestamp, `${user}:${timestamp}`, (err) => {
                if (err) {
                    console.error("[POST /mwlog] Error occured during Redis ZADD");
                    res.status(400).json({ "msg": "Error occured during Redis ZADD" });
                    return;
                }
                const eventData = [];
                Object.keys(data).forEach(k => {
                    eventData.push(k);
                    if (typeof data[k] === "object") {
                        eventData.push(JSON.stringify(data[k]));
                    } else {
                        eventData.push(`${data[k]}`);
                    }
                });
                client.HMSET(`${user}:${timestamp}`, eventData, (err) => {
                    if (err) {
                        console.error("[POST /mwlog] Error occured during Redis HMSET");
                        res.status(400).json({ "msg": "Error occured during Redis HMSET" });
                        return;
                    }
                    console.info(`[POST /mwlog] Logging successful for key "${user}:${timestamp}"`);
                    res.status(200).json({ "msg": "Logging successful" });
                });
            });
        });
    } catch (e) {
        console.error(e.stack);
        res.status(500).json({ "msg": e.message });
    }
});

module.exports = router;