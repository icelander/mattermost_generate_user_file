#!/bin/bash

wget https://releases.mattermost.com/4.10.1/mattermost-4.10.1-linux-amd64.tar.gz

tar -x --transform='s,^[^/]\+,\0-upgrade,' -f mattermost-4.10.1-linux-amd64.tar.gz

cd /opt/

cp -ra mattermost/ ~/mattermost-back-$(date +'%F-%H-%M')/

cp -ra mattermost/ ~/mattermost-back-$(date +'%F-%H-%M')/
service mattermost stop
find mattermost/ -mindepth 1 -maxdepth 1 \! \( -type d \( -path mattermost/config -o -path mattermost/logs -o -path mattermost/plugins -o -path mattermost/data \) -prune \) | sudo xargs rm -r
mv mattermost/plugins/ mattermost/plugins~
chown -hR mattermost:mattermost ~/mattermost-upgrade/
cp -rn ~//mattermost-upgrade/. mattermost/
service mattermost start