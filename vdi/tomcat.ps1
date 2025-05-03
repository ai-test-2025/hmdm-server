$hmdm_language = "en"
$hmdm_protocol="http"
$hmdm_host_ip="localhost"
$hmdm_host_port="8080"
$hmdm_root="hmdm"
$hmdm_mqtt_domain="127.0.0.1"

$postgres_path = "C:\Program Files\PostgreSQL\15"
$postgres_host = "127.0.0.1"
$postgres_port = 5432
$postgres_admin = "postgres"
$postgres_admnin_pass = ""
$hmdm_db_name = "hmdm"
$hmdm_login_role = "hmdmuser"
$hmdm_login_role_pass = "hmdm2025!"


$tomcat_base = "C:\AI\tomcat9"
$hmdm_base_directory = "$tomcat_base\base"



$TOMCAT_HOST_NAME = 'localhost'
$TOMCAT_ENGINE_NAME = 'Catalina'
$LOG4J_TEMPLATE_NAME = "log4j_template.xml"
$WEB_CONFIG_TEMPLATE_NAME = "context_template_windows.xml"
$BASE_DIRECTORY = '_BASE_DIRECTORY_'
$INSTALL_FLAG_NAME = "hmdm_install_flag"
$SQL_HOST = "_SQL_HOST_"
$SQL_PORT = "_SQL_PORT_"
$SQL_BASE = "_SQL_BASE_"
$SQL_USER = "_SQL_USER_"
$SQL_PASS = "_SQL_PASS_"
$PROTOCOL = "_PROTOCOL_"
$BASE_HOST = "_BASE_HOST_"
$BASE_PATH = "_BASE_PATH_"
$INSTALL_FLAG = "_INSTALL_FLAG_"
$BASE_DOMAIN = "_BASE_DOMAIN_"
$SMTP_HOST = "_SMTP_HOST_"
$SMTP_PORT = "_SMTP_PORT_"
$SMTP_SSL = "_SMTP_SSL_"
$SMTP_STARTTLS = "_SMTP_STARTTLS_"
$SMTP_USERNAME = "_SMTP_USERNAME_"
$SMTP_PASSWORD = "_SMTP_PASSWORD_"
$SMTP_FROM = "_SMTP_FROM_"
$LANGUAGE = "_LANGUAGE_"
$APP_WAR = "launcher.war"

#common section
#TO DO: Validations
$app_language = Read-Host "Enter install language (en/ru) [default: $hmdm_language] "
if (![string]::IsNullOrEmpty($app_language)){$hmdm_language = $app_language}

$app_protocol = Read-Host "Enter installation Protocol (http/https) [default: $hmdm_protocol] "
if (![string]::IsNullOrEmpty($app_protocol)){$hmdm_protocol = $app_protocol}

$app_host_ip = Read-Host "Enter host address (valid IP/domain name) [default: $hmdm_host_ip] "
if (![string]::IsNullOrEmpty($app_host_ip)){$hmdm_host_ip = $app_host_ip}

$app_host_port = Read-Host "Enter host port (80/443/8080) [default: $hmdm_host_port] "
if (![string]::IsNullOrEmpty($app_host_port)){$hmdm_host_port = $app_host_port}

#TO DO: Some how highlight the app root path
$app_root = Read-Host "Enter app root (URL:  ${hmdm_protocol}://${hmdm_host_ip}:${hmdm_host_port}/app_root) [default: $hmdm_root]"
if (![string]::IsNullOrEmpty($app_root)){$hmdm_root = $app_root}


#TO DO: Some how highlight the app root path
$app_mqtt_domain = Read-Host "Enter app mqtt domain (should be IP or domain)[default: $hmdm_mqtt_domain]"
if (![string]::IsNullOrEmpty($app_mqtt_domain)){$hmdm_mqtt_domain = $app_mqtt_domain}


#tomcat section
$server_base = Read-Host "Enter tomcat folder path [default: $tomcat_base] "
if (![string]::IsNullOrEmpty($server_base)){$tomcat_base = $server_base}

$app_base_directory = Read-Host "Enter storage folder location [default: $tomcat_base\base]"
if (![string]::IsNullOrEmpty($app_base_directory)){$hmdm_base_directory = "$tomcat_base\$app_base_directory"}
else {$hmdm_base_directory = "$tomcat_base\base"}

#TO DO: Validate tomcat installtion and version

#create hmdm folder in tomcat base
#TO DO: Add validations and remove with custom confirmation
Remove-Item "$hmdm_base_directory" -Force

New-Item -ItemType Directory -Path "$hmdm_base_directory"
New-Item -ItemType Directory -Path "$hmdm_base_directory\files"
New-Item -ItemType Directory -Path "$hmdm_base_directory\logs"
New-Item -ItemType Directory -Path "$hmdm_base_directory\plugins"
New-Item -ItemType Directory -Path "$hmdm_base_directory\scripts"
New-Item -ItemType Directory -Path "$hmdm_base_directory\emails\$hmdm_language"



#create install flag file
#TO DO: Add validations
New-Item -ItemType File -Path "$hmdm_base_directory\$INSTALL_FLAG_NAME"


#Emails Copy
#TO-DO check if exists
Copy-Item -Path "../install/emails/$hmdm_language/*" -Destination "$hmdm_base_directory\emails\$hmdm_language\" -Recurse

#copy and modify log4j
Copy-Item -Path "../install/$LOG4J_TEMPLATE_NAME" -Destination "$hmdm_base_directory\log4j-hmdm.xml"
(Get-Content "$hmdm_base_directory\log4j-hmdm.xml").replace("$BASE_DIRECTORY","$hmdm_base_directory".replace("\","/")) | Set-Content "$hmdm_base_directory\log4j-hmdm.xml"



#Create Config folder
#TO DO:Remove with custom confirmation
#TO DO: Add validations for if folder file not exists
Remove-Item "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml" -Force
Copy-Item -Path "../install/$WEB_CONFIG_TEMPLATE_NAME" -Destination "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"


#-- Replace base directory
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$BASE_DIRECTORY","$hmdm_base_directory".replace("\","/")) | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#-- install flag
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$INSTALL_FLAG","$hmdm_base_directory\$INSTALL_FLAG_NAME".replace("\","/")) | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#-- Postgres Config
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SQL_HOST","$postgres_host") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SQL_PORT","$postgres_port") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SQL_BASE","$hmdm_db_name") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SQL_USER","$hmdm_login_role") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SQL_PASS","$hmdm_login_role_pass") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#-- base url config
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$PROTOCOL","$hmdm_protocol") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
#TO DO: hostname forming for domain
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$BASE_HOST","${hmdm_host_ip}:${hmdm_host_port}") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$BASE_PATH","/$hmdm_root") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#-- mqtt config
#TO DO: Should have public IP/domain
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$BASE_DOMAIN","$hmdm_mqtt_domain") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#-- language config
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$LANGUAGE","$hmdm_language") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"

#TO DO: Implement SMTP configuration through AI
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_HOST","127.0.0.1") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_PORT","25") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_SSL","0") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_STARTTLS","0") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_USERNAME","") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml").replace("$SMTP_PASSWORD","") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_root.xml"


#Copy Launcher jar
#TO DO: Implement service Stop
Remove-Item "$tomcat_base\webapps\$hmdm_root\*" -Force
#TO DO: Implement file not found and other error handling
Copy-Item -Path "../Server/target/$APP_WAR" -Destination "$tomcat_base\webapps\$hmdm_root.war"


