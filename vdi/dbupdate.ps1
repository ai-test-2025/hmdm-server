$hmdm_language = "en"
$hmdm_protocol="http"
$hmdm_host_ip="localhost"
$hmdm_host_port="8080"
$hmdm_root="hmdm"
$hmdm_mqtt_domain="127.0.0.1"
$hmdm_admin_email = "admin@hmdm.com"

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
$ADMIN_EMAIL = "_ADMIN_EMAIL_"
$HMDM_VERSION = "_HMDM_VERSION_"
$HMDM_APK = "_HMDM_APK_"
$CLIENT_VERSION = "5.19"
$CLIENT_VARIANT = "os"
$CLIENT_APK="hmdm-$CLIENT_VERSION-$CLIENT_VARIANT.apk"
$TIMEOUT = 30

$tomcat_base = "E:\Headwind\tomcat9"

#TO DO: email address validation
$app_admin_email = Read-Host "Enter admin email [default: $hmdm_admin_email]"
if (![string]::IsNullOrEmpty($app_admin_email)){$hmdm_admin_email = $app_admin_email}

$currentDirectory = Get-Location
Set-Location $tomcat_base/bin
$tomcatShutDown = Start-Process -FilePath "shutdown.bat" -PassThru
$tomcatShutDown.WaitForExit($TIMEOUT  * 1000)
if (-not $tomcatShutDown.HasExited) {
    Write-Host "Timeout reached. Process is still running."
} else {
	if($tomcatStartUp.ExitCode -eq 0){
		Start-Sleep -Seconds 30
	} else {
	    Write-Host "Process exited with code $($tomcatStartUp.ExitCode)"
	}
}

$tomcatStartUp = Start-Process -FilePath "startup.bat" -PassThru
$tomcatStartUp.WaitForExit($TIMEOUT  * 1000)
if (-not $tomcatStartUp.HasExited) {
    Write-Host "Timeout reached. Process is still running."
} else {
	if($tomcatStartUp.ExitCode -eq 0){
		Start-Sleep -Seconds 30
	} else {
	    Write-Host "Process exited with code $($tomcatStartUp.ExitCode)"
		Set-Location $currentDirectory
		exit "DB upgrade aborted"
	}
}

Set-Location $currentDirectory

Copy-Item -Path "../install/sql/hmdm_init.$hmdm_language.sql" -Destination "$hmdm_base_directory/hmdm_init.$hmdm_language.sql"

(Get-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql").replace("$ADMIN_EMAIL","$hmdm_admin_email") | Set-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql"

(Get-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql").replace("$HMDM_VERSION","$CLIENT_VERSION") | Set-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql"

(Get-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql").replace("$HMDM_APK","$CLIENT_APK") | Set-Content "$hmdm_base_directory/hmdm_init.$hmdm_language.sql"

$env:PGPASSWORD = $hmdm_login_role_pass

#Update Postgres DB
#TO DO: Implement DB check and DB deletion
$createDatabase = @"
CREATE DATABASE $hmdm_db_name OWNER $hmdm_login_role;
"@
$result = & "$postgres_path\bin\psql.exe" -h $postgres_host -p $postgres_port -U $hmdm_login_role -d $hmdm_db_name -f "$hmdm_base_directory/hmdm_init.$hmdm_language.sql"

if($LASTEXITCODE -eq 0) {
	Write-Host "DB upgraded"
}else {
	Write-Host "DB upgrade failed"
	exit
}

Remove-Item Env:PGPASSWORD

Remove-Item "$hmdm_base_directory/hmdm_init.$hmdm_language.sql" -Force