#!/bin/bash
cat >/etc/motd <<EOL

              _ _  __                              _       _                 _
             | | |/ _|                            | |     | |               | |
__      _____| | | |_ ___  _ __ _ __ ___   ___  __| |  ___| | ___  _   _  __| |
\ \ /\ / / _ \ | |  _/ _ \| '__| '_ ` _ \ / _ \/ _` | / __| |/ _ \| | | |/ _` |
 \ V  V /  __/ | | || (_) | |  | | | | | |  __/ (_| || (__| | (_) | |_| | (_| |
  \_/\_/ \___|_|_|_| \___/|_|  |_| |_| |_|\___|\__,_(_)___|_|\___/ \__,_|\__,_|



EOL
cat /etc/motd

# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)

service ssh start
/etc/apache2/foreground.sh
