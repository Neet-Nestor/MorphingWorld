var express = require("express");
const redis = require("redis");
const moment = require("moment");
const { promisify } = require("util");
const redisConfig = require("./config");

var router = express.Router();
const client = redis.createClient(redisConfig.localConfig);

// Promises
const smembersAsync = promisify(client.SMEMBERS).bind(client);
const zrangeAsync = promisify(client.ZRANGE).bind(client);
const hgetallAsync = promisify(client.HGETALL).bind(client);
const hmgetAsync = promisify(client.HMGET).bind(client);

// Get users number
router.get("/users", function (req, res) {
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

// Get start time for every users
router.get("/time/start", function (req, res) {
    console.log(`[GET /data/time/start] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        smembersAsync("Start")
            .then((data) => Promise.all(data.map((entry) => hgetallAsync(entry).then((data) => [entry, data]))))
            .then((data) => {
                res.status(200).json(data.map((el) => {
                    const [key, values] = el;
                    const [user, timestamp] = key.split(":");
                    return { user, timestamp, ...values };
                }));
            }).catch((err) => {
                console.error(err);
                res.status(500).json({ "msg": "Error occured during Redis querying" });
            });
    } catch (e) {
        console.error(e.stack);
        res.status(500).json({ "msg": e.message });
    }
});


// Get exit time for every users
router.get("/time/exit", function (req, res) {
    console.log(`[GET /data/time/end] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        smembersAsync("EXIT")
            .then((data) => Promise.all(data.map((entry) => hgetallAsync(entry).then((data) => [entry, data]))))
            .then((data) => {
                res.status(200).json(data.map((el) => {
                    const [key, values] = el;
                    const [user, timestamp] = key.split(":");
                    return { user, timestamp, ...values };
                }));
            }).catch((err) => {
                console.error(err);
                res.status(500).json({ "msg": "Error occured during Redis querying" });
            });
    } catch (e) {
        console.error(e.stack);
        res.status(500).json({ "msg": e.message });
    }
});

const queryAllEntries = () => {
    return smembersAsync("users").then((users) => Promise.all(users.map((user) => zrangeAsync(user, 0, -1))));
};

const queryAllData = () => {
    return queryAllEntries().then((entries) => {
        const flatten = entries.reduce((prev, cur) => prev.concat(cur), []);
        return Promise.all(flatten.map((entry) => hgetallAsync(entry).then((data) => [entry, data])));
    });
};

module.exports = router;