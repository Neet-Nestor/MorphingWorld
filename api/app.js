const express = require("express");
const winston = require("winston");
const bodyParser  = require("body-parser");
const expressWinston = require("express-winston");
const logRouter = require("./log");
const queryRouter = require("./query");

const app = express();
const port = 4596;

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

// Parsing Error Handling
app.use(function (err, req, res, next) {
    // logic
    if (err) {
        console.error(err.stack);
        res.status(500).json({ "msg": err.message });
    }
});

// logger
app.use(expressWinston.logger({
    transports: [
        new winston.transports.Console()
    ],
    format: winston.format.combine(
        // winston.format.colorize(),
        winston.format.json()
    ),
    meta: true,
    expressFormat: true,
    colorize: true
}));

app.use("/api/mwlog", logRouter);
app.use("/api/data", queryRouter);

app.listen(port, () => console.log(`Example app listening on port ${port}!`));