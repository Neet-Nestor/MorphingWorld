var express = require("express");
const redis = require("redis");
const { redisConfig } = require("./config");

var router = express.Router();
const client = redis.createClient(redisConfig);

// define the home page route
router.post("/mwlog", function (req, res) {
    try {
        const body = req.body;
        if (!("user" in body) || !("timestamp" in body) || !("data" in body)) {
            res.status(400).json({ "msg": "Missing Required Params in body" });
            return;
        }
        const { user, timestamp, data } = body;
        if (Object.keys(data).length === 0) {
            res.status(400).json({ "msg": "Data cannot be empty" });
            return;
        }
        console.log(`user: ${user}, timestamp: ${timestamp}`);
        console.log(`data: ${JSON.stringify(data)}`);
        
        client.SADD("users", `${user}`, (err) => {
            if (err) {
                res.status(400).json({ "msg": "Error occured during Redis SADD" });
                return;
            }
            client.ZADD(`${user}`, timestamp, `${user}:${timestamp}`, (err) => {
                if (err) {
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
                        res.status(400).json({ "msg": "Error occured during Redis HMSET" });
                        return;
                    }
                    res.status(200).json({ "msg": "Logging successful" });
                });
            });
        });
    } catch (e) {
        res.status(500).json({ "msg": e.message });
    }
});

module.exports = router;