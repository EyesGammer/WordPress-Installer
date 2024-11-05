#!/bin/bash

text=$(cat user_settings.json | grep -E "wordpress_url(.*)" | sed 's/,//g' | sed 's/"//g')
IFS=' '
read -a strarr <<< "$text"
url=${strarr[1]}

curl -o wordpress.zip "$url"
unzip wordpress.zip
echo "<?php function createDefine(\$var_name,\$content){return\"define('\$var_name', \t'\$content');\";}\$curl=curl_init();curl_setopt_array(\$curl,array(CURLOPT_URL=>'https://api.wordpress.org/secret-key/1.1/salt',CURLOPT_RETURNTRANSFER=>true,CURLOPT_ENCODING=>'',CURLOPT_MAXREDIRS=>10,CURLOPT_TIMEOUT=>0,CURLOPT_FOLLOWLOCATION=>true,CURLOPT_HTTP_VERSION=>CURL_HTTP_VERSION_1_1,CURLOPT_CUSTOMREQUEST=>'GET'));\$response_salt=curl_exec(\$curl);curl_close(\$curl);\$salts=array();foreach(explode(\"\n\",\$response_salt)as \$salt){preg_match('/\'.*?\'/',\$salt,\$wordpress_var);if(empty(\$wordpress_var)===false)\$salts[\$wordpress_var[0]]=\$salt;}\$settings=json_decode(file_get_contents('user_settings.json'),1);\$user_settings=\$settings['wp-config'];if(file_exists('wp-config-sample.php')){\$content=file_get_contents('wp-config-sample.php');preg_match_all('/define\(.*\);/',\$content,\$matches,PREG_OFFSET_CAPTURE);foreach(\$matches[0]as \$match){list(\$matched,\$index)=\$match;preg_match('/\'.*?\'/',\$matched,\$wordpress_var);if(array_key_exists(str_replace('\'','',\$wordpress_var[0]),\$user_settings))\$content=str_replace(\$matched,createDefine(str_replace('\'','',\$wordpress_var[0]),\$user_settings[str_replace('\'','',\$wordpress_var[0])]),\$content);else if(array_key_exists(\$wordpress_var[0],\$salts))\$content=str_replace(\$matched,\$salts[\$wordpress_var[0]],\$content);}file_put_contents('wp-config.php',\$content);}\$install=\$settings['install'];\$curl=curl_init();curl_setopt_array(\$curl,array(CURLOPT_URL=>\$settings['base_url'].'wp-admin/install.php?step=2',CURLOPT_RETURNTRANSFER=>true,CURLOPT_ENCODING=>'',CURLOPT_MAXREDIRS=>10,CURLOPT_TIMEOUT=>0,CURLOPT_FOLLOWLOCATION=>true,CURLOPT_HTTP_VERSION=>CURL_HTTP_VERSION_1_1,CURLOPT_CUSTOMREQUEST=>'POST',CURLOPT_POSTFIELDS=>array('weblog_title'=>\$install['weblog_title'],'user_name'=>\$install['user_name'],'admin_password'=>\$install['admin_password'],'admin_password2'=>\$install['admin_password'],'admin_email'=>\$install['admin_email'],'public'=>(int) \$install['public'])));curl_exec(\$curl);curl_close(\$curl); ?>" > kumo_script.php
rm wordpress.zip && mv wordpress/* . && rmdir wordpress && php kumo_script.php && rm kumo_script.php

cd wp-content/plugins/
cat ../../user_settings.json | grep -Pzo "\[([\s\S]+)\]" | sed 's/'"$(printf '\t')"'//g' | sed 's/,//g' | sed 's/"//g' | \
while read plugin; do
	if [ "${plugin:0:1}" != "[" ] && [ "${plugin:0:1}" != "]" ]; then
		name=$(echo "$plugin" | rev | cut -d'/' -f1 | rev)
		curl -o "$name" "$plugin" 2>&1 >/dev/null && unzip "$name" 2>&1 >/dev/null && rm "$name" 2>&1 >/dev/null
	fi
done
cd ../../

rm user_settings.json && rm install_wordpress.sh
