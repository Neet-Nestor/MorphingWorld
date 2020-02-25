echo "Preparing zip...\n"
zip api.zip app.js config.js ecosystem.config.js log.js package-lock.json package.json query.js
echo "\n"
echo "Uploading the zip...\n"
scp api.zip vultr:~/mwlog/
echo "Unziping the zip on target machine...\n"
ssh vultr "cd ~/mwlog && unzip -o api.zip"
echo "Deployed\n"