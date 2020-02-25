zip api.zip app.js config.js ecosystem.config.js log.js package-lock.json package.json query.js
scp api.zip vultr:~/mwlog/
ssh vultr "cd ~/mwlog && unzip -o api.zip"