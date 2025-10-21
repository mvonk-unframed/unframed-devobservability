#!/bin/bash

# Setup voor navigatie scenario
echo "Setting up navigation exercise environment..."

# Maak test directory structuur
mkdir -p /home/student/{documents,downloads,projects/web,projects/scripts,logs,config}

# Maak test bestanden met verschillende groottes
echo "Dit is een klein tekstbestand voor documentatie." > /home/student/documents/readme.txt
echo "Configuratie bestand voor de webserver." > /home/student/config/nginx.conf
echo "#!/bin/bash\necho 'Hello World'" > /home/student/projects/scripts/hello.sh

# Maak wat grotere bestanden
dd if=/dev/zero of=/home/student/downloads/largefile.dat bs=1M count=50 2>/dev/null
dd if=/dev/zero of=/home/student/logs/access.log bs=1M count=25 2>/dev/null
dd if=/dev/zero of=/home/student/projects/web/backup.tar bs=1M count=100 2>/dev/null

# Maak wat kleinere bestanden
for i in {1..10}; do
    echo "Log entry $i: $(date)" >> /home/student/logs/app.log
done

for i in {1..5}; do
    echo "Document $i content" > /home/student/documents/doc$i.txt
done

# Stel verschillende permissions in
chmod 644 /home/student/documents/*.txt
chmod 755 /home/student/projects/scripts/hello.sh
chmod 600 /home/student/config/nginx.conf

# Maak een symlink
ln -s /home/student/documents /home/student/docs-link

# Zorg dat student eigenaar is
chown -R student:student /home/student 2>/dev/null || true

# Start in home directory
cd /home/student

echo "Environment setup complete!"
echo "Directory structure created with various file sizes for practice."