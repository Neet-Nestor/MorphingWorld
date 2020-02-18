const express = require("express");
const winston = require("winston");
const expressWinston = require("express-winston");
const router = require("./router");

const app = express();
const port = 3000;

app.use(router);
app.listen(port, () => console.log(`Example app listening on port ${port}!`));