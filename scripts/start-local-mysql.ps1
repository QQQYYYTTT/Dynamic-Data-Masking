param(
    [string]$Port = "3306"
)

$ErrorActionPreference = "Stop"

$mysqlSource = Join-Path $PSScriptRoot "..\tools\mysql-8.4.6-winx64"
$runtimeRoot = Join-Path $env:TEMP "DDM-MySQL"
$mysqlRuntime = Join-Path $runtimeRoot "mysql-8.4.6-winx64"
$dataDir = Join-Path $runtimeRoot "data"
$iniFile = Join-Path $runtimeRoot "mysql-ddm.ini"
$mysqlExe = Join-Path $mysqlRuntime "bin\mysql.exe"
$mysqldExe = Join-Path $mysqlRuntime "bin\mysqld.exe"

if (-not (Test-Path $mysqlRuntime)) {
    if (-not (Test-Path $mysqlSource)) {
        throw "MySQL runtime not found: $mysqlSource"
    }
    New-Item -ItemType Directory -Force $runtimeRoot | Out-Null
    Copy-Item -Path $mysqlSource -Destination $runtimeRoot -Recurse -Force
}

New-Item -ItemType Directory -Force $dataDir | Out-Null

@"
[mysqld]
basedir=$($mysqlRuntime -replace '\\','/')
datadir=$($dataDir -replace '\\','/')
port=$Port
character-set-server=utf8mb4
collation-server=utf8mb4_0900_ai_ci
log-error=$((Join-Path $dataDir 'mysql-error.log') -replace '\\','/')

[client]
default-character-set=utf8mb4
port=$Port
"@ | Set-Content -Encoding ASCII $iniFile

if (-not (Test-Path (Join-Path $dataDir "mysql"))) {
    & $mysqldExe --defaults-file=$iniFile --initialize-insecure
    if ($LASTEXITCODE -ne 0) {
        throw "MySQL initialization failed."
    }
}

$listening = netstat -ano | Select-String ":$Port\s"
if (-not $listening) {
    Start-Process -FilePath $mysqldExe -ArgumentList "--defaults-file=$iniFile" -WorkingDirectory $runtimeRoot -WindowStyle Hidden
    Start-Sleep -Seconds 5
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $mysqlExe -uroot -proot --protocol=tcp --host=localhost --port=$Port -e "SELECT VERSION();" 2>$null | Out-Null
$rootPasswordOk = $LASTEXITCODE -eq 0
if (-not $rootPasswordOk) {
    & $mysqlExe -uroot --protocol=tcp --host=localhost --port=$Port -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;" 2>$null
    $rootPasswordOk = $LASTEXITCODE -eq 0
}
$ErrorActionPreference = $previousErrorActionPreference

if (-not $rootPasswordOk) {
    throw "MySQL is running, but root/root verification failed."
}

Write-Output "MySQL ready: localhost:$Port, user=root, password=root."
