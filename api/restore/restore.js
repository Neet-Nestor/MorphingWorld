const fs = require("fs");
const axios = require("axios");

const restore = () => {
    fs.readFile("log-to-restore.log", "utf8", (err, data) => {
        if (err) {
            console.error(err.stack);
            throw err;
        }
        const lines = data.split("\n");
        var promise = null;
        for (var i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.startsWith("[POST /mwlog] Received Request at") && (i + 3 < lines.length)) {
                i += 2;
                var [user, timestamp] = lines[i].split(",");
                user = user.split(":")[1].trim();
                timestamp = parseFloat(timestamp.split(":")[1].trim());

                i++;
                const data = JSON.parse(lines[i].substr(6));

                if (promise === null) {
                    promise = axios.post("http://45.32.231.66:4596/api/mwlog", {
                        user, timestamp, data
                    }, {
                        headers: { "Content-Type": "application/json" }
                    })
                        .then((response) => console.log(response.data))
                        .catch((error) => {
                            console.log(error);
                        });
                } else {
                    promise = promise.then(axios.post("http://45.32.231.66:4596/api/mwlog", {
                        user, timestamp, data
                    }, {
                        headers: { "Content-Type": "application/json" }
                    })
                        .then((response) => console.log(response.data))
                        .catch((error) => {
                            console.log(error);
                        }));
                }
            }
        }
    });
};

restore();