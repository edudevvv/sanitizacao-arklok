@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM "Method selected: 0 = One Pass Zeros"
SET "METHOD=0"

REM "Dir for save certifieds"
SET "OUTDIR=%~d0\CERTIFICADOS"

REM "Executable killdisk"
SET "KILLDISK=killdisk.exe"

REM "Select disks and if empty, select all disks"
SET "TARGET_DISK="

SET "PROCESS_COUNT=1"
SET "MAX_PROCESS=5"

echo.
echo ****************************************************
echo * Procedimento de Sanitizacao Automatica           *
echo *                                                  *
echo * Desenvolvido por: Eduardo Silva Moraes           *
echo * Contato: github.com/edudevvv                     *
echo *                                                  *
echo * Desenvolvido em 2026-06-11                       *
echo * Versao: 1.0-beta                                 *
echo ****************************************************

if not exist "%OUTDIR%" (
    echo [LOGS] Criando pasta de certificados em "%OUTDIR%"...
    mkdir "%OUTDIR%" 2>nul

    echo [OK] Pasta criada com sucesso.
) else (
    echo [LOGS] Pasta de certificados ja existe.
    echo [INFO] Caminho: "%OUTDIR%"
)

echo.

echo [1/4] Verificando processos do KILLDISK.exe 

REM "Checking if tasklist exists"
where tasklist >nul 2>&1

REM "If tasklist is not available, show a warning. Otherwise, check for running instances of KILLDISK.exe"
if errorlevel 1 (
    echo [WARNING] tasklist nao disponivel neste ambiente.
) else (
    tasklist /fi "imagename eq %KILLDISK%" 2>nul | find /i "%KILLDISK%" >nul
    if not errorlevel 1 (
        echo [WARNING] KILLDISK.exe encontrado em execucao.
    ) else (
        echo [LOGS] Nenhuma instancia encontrada.
    )
)

echo.

REM "Initializing disks and setting SAN policy to OnlineAll"
echo [2/4] Inicializando discos 
(
    echo san policy=OnlineAll
    echo list disk
) | diskpart >"%OUTDIR%\diskpart.log" 2>&1

REM "Check if diskpart executed successfully"
if errorlevel 1 (
    echo [ERRO] Falha ao executar o DiskPart.
) else (
    echo [OK] Politica SAN configurada para OnlineAll.
)

echo.
REM "List detected disks using PowerShell for better formatting"
echo [INFO] Discos detectados:

powershell -NoProfile -Command "Get-Disk | Sort-Object Number | Format-Table Number,FriendlyName,@{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},BusType,PartitionStyle -AutoSize"

for /f %%A in ('powershell -NoProfile -Command "(Get-Disk).Count"') do set "DISKCOUNT=%%A"

echo.
echo [INFO] Total de discos detectados: %DISKCOUNT%
echo [LOGS] Log salvo em: "%OUTDIR%\diskpart.log"
echo.

REM "Coleting serial number for certificate naming"
echo [3/4] Coletando numero de serie (SerialNumber)

set "SERIAL="
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command ^
  "try{((Get-CimInstance Win32_BIOS).SerialNumber).Trim()}catch{''}"`) do set "SERIAL=%%S"

if not defined SERIAL (
  for /f "skip=1 delims=" %%S in ('wmic bios get serialnumber 2^>nul') do (
    if not defined SERIAL set "SERIAL=%%S"
  )
)

if defined SERIAL set "SERIAL=%SERIAL: =%"
if defined SERIAL set "SERIAL=%SERIAL:/=-%"
if defined SERIAL set "SERIAL=%SERIAL:\=-%"
if defined SERIAL set "SERIAL=%SERIAL::=-%"

if not defined SERIAL (
  for /f "tokens=2 delims==" %%T in ('wmic os get localdatetime /value 2^>nul') do set "TS=%%T"
  set "SERIAL=UNKNOWN-!TS:~0,14!"
)

echo [INFO] Serial detectado: %SERIAL%

if defined TARGET_DISK (
  set "DISKSEL=-eh=%TARGET_DISK%"
) else (
  REM -ea = todos os discos | -xr = exclui removiveis (pendrive de boot)
  set "DISKSEL=-ea -xr"
)

echo.
REM "Initializing process of sanitization disks with KillDisk"
echo [4/4] Iniciando sanitizacao (One Pass Zeros)  
echo [LOGS] Certificado: "%OUTDIR%\%SERIAL%.pdf"
echo.

"%KILLDISK%" %DISKSEL% -em=%METHOD% -bm -nc -ns -ie ^
  -ip="%INI%" -cp="%OUTDIR%" -lp="%OUTDIR%"

set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    for %%F in ("%OUTDIR%\*Certificate-*.pdf") do (
        set "CERTFILE=%%~fF"
    )

    if defined CERTFILE (
        ren "!CERTFILE!" "%SERIAL%.pdf"
        echo [OK] Certificado renomeado para %SERIAL%.pdf
    )
) else if "%RC%"=="2" (
  echo [AVISO] Concluido com avisos menores. Verifique o log.
) else (
  echo [ERRO] Ocorreram erros ^(codigo %RC%^). Verifique o log em "%OUTDIR%".
)

echo [LOGS] Certificado e log salvos em: "%OUTDIR%"
echo.
pause