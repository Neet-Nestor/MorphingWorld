var express = require("express");
const redis = require("redis");
const moment = require("moment");
const { promisify } = require("util");
const redisConfig = require("./config");

var router = express.Router();
const client = redis.createClient(redisConfig);

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
        zrangeAsync("Start", 0, -1)
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
        zrangeAsync("EXIT", 0, -1)
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

// Get game stats
router.get("/games", function (req, res) {
    console.log(`[GET /data/games] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        queryAllData().then((data) => {
            const games = [];
            for (const userData of data) {
                var death = 0;
                var reset = 0;
                var startTime = null;
                var game = {};
                for (const entry of userData) {
                    const [key, value] = entry;
                    const [user, timestampStr] = key.split(":");
                    const timestamp = parseFloat(timestampStr);
                    var inRecoding = false;
                    if (!("user" in game)) {
                        game.user = user;
                    }
                    if (value.type === "Start") {
                        startTime = timestamp;
                        game.start = timestamp;
                        if (inRecoding) {
                            games.push(game);
                            game = {};
                            inRecoding = false;
                        }
                    } else {
                        inRecoding = true;
                        if (value.type === "Die") {
                            death++;
                        } else if (value.type === "Reset") {
                            reset++;
                        } else if (value.type === "Pass") {
                            game[`stage${value.stage}`] = { time: timestamp - startTime, death, reset };
                            startTime = timestamp;
                            death = 0;
                            reset = 0;
                        }
                    }
                }
                if (inRecoding) ames.push(game);
            }
            games.sort((g1, g2) => g1.start - g2.start);
            res.status(200).json(games);
        }).catch((err) => {
            console.error(err);
            res.status(500).json({ "msg": "Error occured during Redis querying" });
        });
    } catch (e) {
        console.error(e.stack);
        res.status(500).json({ "msg": e.message });
    }
});

// Direct request all raw data
router.get("/raw/all", function (req, res) {
    console.log(`[GET /data/raw/all] Received Request at ${moment().format("HH:mm:ss.SSS MM/DD/YYYY")}`);
    try {
        queryAllData()
            .then((data) => {
                res.status(200).json(data.map((group) => group.map((el) => {
                    const [key, values] = el;
                    const [user, timestamp] = key.split(":");
                    return { user, timestamp, ...values };
                })));
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

const queryAllData = () => 
    queryAllEntries().then((entryGroups) =>
        Promise.all(entryGroups.map((group) => Promise.all(group.map((entry) => hgetallAsync(entry).then((data) => [entry, data]))))));

const queryAllDataFlatten = () => {
    return queryAllEntries().then((entries) => {
        const flatten = entries.reduce((prev, cur) => prev.concat(cur), []);
        return Promise.all(flatten.map((entry) => hgetallAsync(entry).then((data) => [entry, data])));
    });
};

module.exports = router;