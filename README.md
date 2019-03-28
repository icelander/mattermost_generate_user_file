# Mattermost User Export

When converting a users to SAML auth you need to generate a user file. [There are instructions for this](https://docs.mattermost.com/administration/command-line-tools.html#mattermost-ldap-idmigrate) but this requires a `users.json` file to determine the username and email matching. If you have a server a with only a few `email` or `ldap` users this is a good way to generate a `users.json` file that will update them to use SAML authentication.

## Setup

0. Make sure you have Ruby installed
1. `cd` to this directory
2. Run `bundle` to install the required Gems
3. `cp sample.conf.yaml conf.yaml` and update `conf.yaml` with your Mattermost URL and an admin [Auth Token](https://docs.mattermost.com/developer/personal-access-tokens.html)

## Run

1. run `./main.rb <auth_method> > users.json`, where `auth_method` is either `email` or `ldap`
2. Move the new `users.json` file to your workstation
3. Edit to remove any accounts you don't want migrated to SAML, or don't exist in SAML
4. Copy the new `users.json` to the server. *Tip: Overwrite the existing one for safety*
5. Go to your Mattermost directory: `cd /opt/mattermost`
6. Now run `sudo bin/mattermost user migrate_auth email saml <path to users.json> --dryRun` to test. Make sure to change `email` to `ldap` if you're updating LDAP users.

**Note:** *To make the changes permanent remove `--dryRun`*