const express = require('express');
const redis = require("redis");
const { redisConfig } = require("./config");

const client = redis.createClient(redisConfig);
const app = express();

const port = 3000;

app.get('/', (req, res) => res.send('Hello World!'));

app.listen(port, () => console.log(`Example app listening on port ${port}!`));