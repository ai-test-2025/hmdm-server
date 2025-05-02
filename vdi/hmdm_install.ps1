$postgres_path = "C:\Program Files\PostgreSQL\15"
$postgres_host = "127.0.0.1"
$postgres_port = 5432
$postgres_admin = "postgres"
$postgres_admnin_pass = ""
$hmdm_db_name = "hmdm"
$hmdm_login_role = "hmdmuser"
$hmdm_login_role_pass = "hmdm2025!"


$tomcat_base = "C:\AI\tomcat9"
$hmdm_base_name = "hmdm"
$install_language = "en"

$TOMCAT_HOST_NAME = 'localhost'
$TOMCAT_ENGINE_NAME = 'Catalina'
$LOG4J_TEMPLATE_NAME = "log4j_template.xml"
$WEB_CONFIG_TEMPLATE_NAME = "context_template.xml"
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


#postgres section

$db_path = Read-Host "Enter Postgres 15 installation path(default: $postgres_path) "
if (![string]::IsNullOrEmpty($db_path)){$postgres_path = $db_path}

$db_host = Read-Host "Enter Postgres Server IP (default: $postgres_host) "
if (![string]::IsNullOrEmpty($db_host)){$postgres_host = $db_host}

$db_port = Read-Host "Enter Postgres Server Port (default: $postgres_port) "
if (![string]::IsNullOrEmpty($db_port)){$postgres_port = $db_port}

$postgres_admnin_pass = Read-Host "Enter pasword for '$postgres_admin' user "

$db_name = Read-Host "Enter target database for hmdm server(default: $hmdm_db_name) "
if (![string]::IsNullOrEmpty($db_name)){$hmdm_db_name = $db_port}

$db_login_role = Read-Host "Enter login role for hmdm server(default: $hmdm_login_role) "
if (![string]::IsNullOrEmpty($db_login_role)){$hmdm_login_role = $db_login_role}

#TO DO: implement mandatory not null password check password reconfirmation feature here
$db_login_role_pass = Read-Host "Enter password for $hmdm_login_role "
if (![string]::IsNullOrEmpty($db_login_role_pass)){$hmdm_login_role_pass = $db_login_role_pass}


#verify postgres installation
if(!(Test-Path "$postgres_path\bin\psql.exe")) {
	"Can not find postgres installation path"
	exit
}

$env:PGPASSWORD = $postgres_admnin_pass


#create role
#TO DO: Implement Login role exists check here
$createRoleSql = @"
CREATE ROLE $hmdm_login_role WITH LOGIN PASSWORD '$hmdm_login_role_pass' NOSUPERUSER REPLICATION CREATEDB CREATEROLE;
"@
$result = & "$postgres_path\bin\psql.exe" -h $postgres_host -p $postgres_port -U $postgres_admin -d postgres -c $createRoleSql

if($LASTEXITCODE -eq 0) {
	Write-Host "Role created"
}else {
	Write-Host "Role creation failed"
	exit
}

#create db
#TO DO: Implement DB check and DB deletion
$createDatabase = @"
CREATE DATABASE $hmdm_db_name OWNER $hmdm_login_role;
"@
$result = & "$postgres_path\bin\psql.exe" -h $postgres_host -p $postgres_port -U $postgres_admin -d postgres -c $createDatabase

if($LASTEXITCODE -eq 0) {
	Write-Host "DB created"
}else {
	Write-Host "DB creation failed"
	exit
}

Remove-Item Env:PGPASSWORD

#tomcat section
$server_base = Read-Host "Enter tomcat folder path (default: $tomcat_base) "
if (![string]::IsNullOrEmpty($server_base)){$tomcat_base = $server_base}

$app_base_name = Read-Host "Enter app basename (defaul: $hmdm_base_name)"
if (![string]::IsNullOrEmpty($app_base_name)){$hmdm_base_name = $app_base_name}

#TO DO: Validate tomcat installtion and version

#create hmdm folder in tomcat base
#TO DO: Add validations and remove with custom confirmation
Remove-Item "$tomcat_base\$hmdm_base_name" -Force

New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name"
New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name\files"
New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name\logs"
New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name\plugins"
New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name\scripts"
New-Item -ItemType Directory -Path "$tomcat_base\$hmdm_base_name\emails\$install_language"


#create install flag file
#TO DO: Add validations
New-Item -ItemType File -Path "$tomcat_base\$hmdm_base_name\$INSTALL_FLAG_NAME"


#Emails Copy
#TO-DO check if exists
Copy-Item -Path "../install/emails/$install_language/*" -Destination "$tomcat_base\$hmdm_base_name\emails\$install_language\" -Recurse

#copy and modify log4j
Copy-Item -Path "../install/$LOG4J_TEMPLATE_NAME" -Destination "$tomcat_base\$hmdm_base_name\"
(Get-Content "$tomcat_base\$hmdm_base_name\$LOG4J_TEMPLATE_NAME").replace("$BASE_DIRECTORY","$tomcat_base\$hmdm_base_name") | Set-Content "$tomcat_base\$hmdm_base_name\$LOG4J_TEMPLATE_NAME"

#Create Config folder
#TO DO:Remove with custom confirmation
Remove-Item "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml" -Force
Copy-Item -Path "../install/$WEB_CONFIG_TEMPLATE_NAME" -Destination "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
#-- Replace base directory
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$BASE_DIRECTORY","$tomcat_base\$hmdm_base_name") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
#-- Postgres Config
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$SQL_HOST","$postgres_host") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$SQL_PORT","$postgres_port") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$SQL_BASE","$hmdm_db_name") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$SQL_USER","$hmdm_login_role") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$SQL_PASS","$hmdm_login_role_pass") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
#-- install flag
(Get-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml").replace("$INSTALL_FLAG","$tomcat_base\$hmdm_base_name\$INSTALL_FLAG_NAME") | Set-Content "$tomcat_base\conf\$TOMCAT_ENGINE_NAME\$TOMCAT_HOST_NAME\$hmdm_base_name.xml"
