Author: tomek.antczak@gmail.com
Useful shell script for creating basic environment for new projects. This basic environments consist of adding proper /etc/hosts entry, virtual host and project document root creation, setting proper access rights. For instance typing below command ...

sudo ./project.sh myproject

will...

1. create myproject.dev entry in /etc/hosts (will refuse if entry exists)
2. create virtualhost for apache2 web server
3. create document root with proper rights (in my case /home/tomek/Projects/myproject.dev)
4. gracefully reload apache2
