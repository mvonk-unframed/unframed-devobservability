#!/bin/bash

# Setup voor bestandsrechten scenario
echo "Setting up file permissions exercise environment..."

# Maak test directory structuur
mkdir -p /home/student/{scripts,config,documents,shared,backup}

# Maak verschillende test bestanden
echo "#!/bin/bash
echo 'This is a backup script'
echo 'Backing up important files...'
sleep 2
echo 'Backup completed!'" > /home/student/scripts/backup.sh

echo "#!/bin/bash
echo 'System monitoring script'
ps aux | head -10" > /home/student/scripts/monitor.sh

echo "#!/usr/bin/python3
print('Hello from Python!')
print('This is a data processing script')" > /home/student/scripts/process_data.py

# Configuratie bestanden
echo "# Database configuration
host=localhost
port=5432
database=myapp
user=appuser" > /home/student/config/database.conf

echo "# Web server configuration
listen_port=8080
document_root=/var/www/html
max_connections=100" > /home/student/config/webserver.conf

echo "# Secret configuration - should be protected
api_key=secret123456
admin_password=supersecret" > /home/student/config/secrets.conf

# Documenten
echo "This is a public readme file.
Everyone should be able to read this." > /home/student/documents/readme.txt

echo "Internal company documentation.
Only authorized personnel should access this." > /home/student/documents/internal.txt

echo "Shared project documentation.
Team members should be able to read and write." > /home/student/shared/project_notes.txt

# Backup bestanden
echo "Important data backup" > /home/student/backup/data.bak
echo "Configuration backup" > /home/student/backup/config.bak

# Stel verschillende (verkeerde) permissions in die gecorrigeerd moeten worden
chmod 777 /home/student/config/secrets.conf  # Te open voor geheime config
chmod 644 /home/student/scripts/backup.sh    # Script niet uitvoerbaar
chmod 644 /home/student/scripts/monitor.sh   # Script niet uitvoerbaar
chmod 644 /home/student/scripts/process_data.py  # Script niet uitvoerbaar
chmod 600 /home/student/documents/readme.txt # Te restrictief voor publiek bestand
chmod 777 /home/student/shared/project_notes.txt # Te open
chmod 444 /home/student/backup/data.bak      # Backup niet schrijfbaar voor eigenaar

# Maak een test gebruiker (als deze niet bestaat)
useradd -m testuser 2>/dev/null || true

# Zorg dat student eigenaar is van de meeste bestanden
chown -R student:student /home/student 2>/dev/null || true

# Maar maak sommige bestanden eigendom van root (om chown te oefenen)
chown root:root /home/student/config/secrets.conf 2>/dev/null || true
chown root:root /home/student/backup/config.bak 2>/dev/null || true

# Start in de student directory
cd /home/student

echo "Environment setup complete!"
echo "Created files with various permission issues to fix:"
echo "- Scripts that need to be executable"
echo "- Config files that need proper security"
echo "- Files with wrong ownership"
echo "- Documents with incorrect access levels"