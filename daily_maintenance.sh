#!/bin/bash

# This is the path where all the logs gonna be
LOG_FILE="/var/log/daily_maintenance.log"

# From here we will start the script
echo "Daily Maintenance started at $(date)" >> "$LOG_FILE"

# Clean and remove old and unwanted packs
sudo apt autoclean -y >> "$LOG_FILE" 2>&1
sudo apt autoremove -y >> "$LOG_FILE" 2>&1

# daily updatess
sudo apt update -y >> "$LOG_FILE" 2>&1
sudo apt upgrade -y >> "$LOG_FILE" 2>&1

# Check for suspicious files
echo "Checking for suspicious files..." >> "$LOG_FILE"
sudo find / -type f -perm -4000 >> "$LOG_FILE" 2>&1

# Check for suspicious processes
echo "Checking for suspicious processes..." >> "$LOG_FILE"
ps aux | grep -vE "^root" | awk '{print $1,$11}' | grep "/usr/bin/" >> "$LOG_FILE" 2>&1

# End of the script
echo "Daily Maintenance finished at $(date)" >> "$LOG_FILE"
