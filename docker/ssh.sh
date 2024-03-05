#!/bin/sh

host_ssh_path="/.ssh"

cp -a $host_ssh_path/. /root/.ssh/

# Change the permissions of all files in the directory to 0600
# Assuming all files inside are keys that require these permissions
if [ -d $host_ssh_path ]; then
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/*
  chmod 644 /root/.ssh/*.pub
fi

echo "Permissions have been set successfully."

# Execute the command passed as arguments to the script
exec "$@"
