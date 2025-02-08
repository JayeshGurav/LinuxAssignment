#!/bin/bash

# Check if a directory path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Assign directory path to a variable
dir_to_backup="$1"

# Check if the provided path is a valid directory
if [ ! -d "$dir_to_backup" ]; then
    echo "Error: '$dir_to_backup' is not a valid directory."
    exit 1
fi

# Create a timestamped backup folder inside the specified directory
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="$dir_to_backup/backup_$timestamp"
mkdir "$backup_dir"

# Copy files to the backup directory
cp -r "$dir_to_backup"/* "$backup_dir"

echo "Backup completed: $backup_dir"

# Implement backup rotation - keep only the last 3 backups
backup_count=$(ls -dt $dir_to_backup/backup_* | wc -l)

if [ "$backup_count" -gt 3 ]; then
    ls -dt $dir_to_backup/backup_* | tail -n +4 | xargs rm -rf
    echo "Old backups removed, keeping only the last 3."
fi

# Automate backup using cron
cron_job="0 * * * * /path/to/this/script.sh $dir_to_backup"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
echo "Cron job added to run the backup script every hour."

