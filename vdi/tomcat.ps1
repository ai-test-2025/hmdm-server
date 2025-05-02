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

