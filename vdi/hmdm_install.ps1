$postgres_path = "C:\Program Files\PostgreSQL\15"
$postgres_host = "127.0.0.1"
$postgres_port = 5432
$postgres_admin = "postgres"
$postgres_admnin_pass = ""
$hmdm_db_name = "hmdm"
$hmdm_login_role = "hmdmuser"
$hmdm_login_role_pass = "hmdm2025!"
$tomcat_base = "C:\AI\tomcat9"

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

#TO DO: Validate tomcat installtion and version

#create hmdm folder in tomcat base
New-Item ItemType Directory -Path "$tomcat_base\hmdm"
New-Item ItemType Directory -Path "$tomcat_base\hmdm\files"
New-Item ItemType Directory -Path "$tomcat_base\hmdm\logs"
New-Item ItemType Directory -Path "$tomcat_base\hmdm\plugins"
New-Item ItemType Directory -Path "$tomcat_base\hmdm\scripts"


#Write-Host $pgConnString