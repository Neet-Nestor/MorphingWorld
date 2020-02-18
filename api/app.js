const express = require("express");
const winston = require("winston");
const bodyParser  = require("body-parser");
const expressWinston = require("express-winston");
const router = require("./router");

const app = express();
const port = 3000;

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

// logger
app.use(expressWinston.logger({
    transports: [
        new winston.transports.Console()
    ],
    format: winston.format.combine(
        winston.format.colorize(),
        winston.format.json()
    ),
    meta: false,
    expressFormat: true,
    colorize: true
}));

app.use("/api", router);

app.listen(port, () => console.log(`Example app listening on port ${port}!`));