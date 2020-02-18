module.exports = {
    apps : [
        {
            name: "MW Redis API",
            script: "app.js",

            // Options reference: https://pm2.keymetrics.io/docs/usage/application-declaration/
            instances: "max",
            autorestart: true,
            watch: true,
            max_memory_restart: "1G",
            env: {
                NODE_ENV: "development"
            },
            env_production: {
                NODE_ENV: "production"
            }
        }
    ],
};
