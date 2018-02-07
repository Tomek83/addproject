#!/bin/bash

name=$1; if [[ ! $name =~ ^[abcdefghijklmnopqrstuvwxyz0-9_\-]+$ ]]; then exit 1; fi

user='username'; if [ ! `id -u $user 2>/dev/null` ]; then exit 1; fi

group='groupname'; if [ ! `id -g $group 2>/dev/null` ]; then exit 1; fi

ip_addr='127.0.0.1'

script_dir=`realpath .`;

server_dir=`realpath /etc/apache2`; if [ ! -d "$server_dir" ]; then exit 1; fi

projects_dir=`realpath /home/$user/Projects`; if [ ! -d "$projects_dir" ]; then exit 1; fi

project_dir="$projects_dir/$name.dev"; if [ -d "$project_dir" ]; then exit 1; fi

host_file=`realpath /etc/hosts`; if [ ! -e "$host_file" ]; then exit 1; fi

host_entry=$(awk -v name="^$name(.dev)?$" '$2 ~ name {printf("%d", NR)}' $host_file)

vhost_dir_conf='sites-available'; if [ ! -d "$server_dir/$vhost_dir_conf" ]; then exit 1; fi

vhost_dir_link='sites-enabled'; if [ ! -d "$server_dir/$vhost_dir_link" ]; then exit 1; fi

vhost_entry="<VirtualHost *:80>
\tServerName $name.dev

\tServerAdmin webmaster@$name.dev

\tDocumentRoot $project_dir

\tScriptAlias /cgi-bin/ $project_dir/cgi-bin/

\t<Directory \"$project_dir\">
\t\tRequire all granted
\t</Directory>

\t<Directory \"$project_dir/cgi-bin\">
\t\tAllowOverride None
\t\tOptions +ExecCGI -MultiViews +SymLinksIfOwnerMatch
\t\tRequire all granted
\t</Directory>

\tErrorLog \${APACHE_LOG_DIR}/error.log
\tCustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"

if [ ! $host_entry ]; then
	echo -en "$ip_addr	$name.dev\n" >> $host_file;
	if [ ! -e "./sites-available/$name.conf" ]; then
		printf "$vhost_entry" > "$server_dir/$vhost_dir_conf/$name.conf"
		cd "$server_dir/$vhost_dir_link"; ln -s "../$vhost_dir_conf/$name.conf"
		cd "$script_dir"; mkdir -p "$project_dir/cgi-bin"
		chown -R $user:$group "$project_dir"; chmod -R 775 "$project_dir"
		service apache2 restart
	fi
else
	exit 1
fi
