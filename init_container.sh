#!/bin/bash
cat >/etc/motd <<EOL
  _____
  /  _  \ __________ _________   ____
 /  /_\  \\___   /  |  \_  __ \_/ __ \
/    |    \/    /|  |  /|  | \/\  ___/
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/
A P P   S E R V I C E   O N   L I N U X
Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs
EOL
cat /etc/motd

eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)

service ssh start
/etc/apache2/foreground.sh
