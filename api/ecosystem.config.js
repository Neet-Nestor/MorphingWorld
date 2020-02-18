module.exports = {
    apps : [
        {
            name: "MW Redis API",
            script: "app.js",

            // Options reference: https://pm2.keymetrics.io/docs/usage/application-declaration/
            // instances: "max",
            instances: 1,
            autorestart: true,
            watch: ["."],
            ignore_watch: ["node_modules", "logs"],
            max_memory_restart: "1G",
            output: "./logs/output.log",
            error: "./logs/error.log",
            env: {
                NODE_ENV: "development"
            },
            env_production: {
                NODE_ENV: "production"
            }
        }
    ],
};
