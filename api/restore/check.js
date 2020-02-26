const fs = require("fs");

fs.readFile("games.json", "utf8", (err, data) => {
    const oldGames = JSON.parse(data);
    fs.readFile("newgames.json", "utf8", (err, data) => {
        const newGames = JSON.parse(data);
        const newEntries = {};
        for (const entry of newGames) {
            newEntries[`${entry.user}:${entry.start}`] = entry;
        }
        for (const entry of oldGames) {
            const key = `${entry.user}:${entry.start}`;
            if (!(key in newEntries)) {
                console.error(`${key} not in new games!`);
            }
            if (Object.keys(entry).length != Object.keys(newEntries[key]).length) {
                console.error(`${key} entries number not the same`);
            }
        }
    });
});