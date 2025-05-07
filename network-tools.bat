@echo off
setlocal EnableDelayedExpansion
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

::─────────────────────────────────────────────────────────────────────────────
::  Subroutine: padAndEcho  — pads text to fixed width and wraps in “| … |”
::  Uses WIDTH and PAD defined in :init
::─────────────────────────────────────────────────────────────────────────────
:padAndEcho
set "line=%~1"
set "line=%line%%PAD%"
set "line=%line:~0,%WIDTH%%"
echo ^| %line% ^|
exit /b

::─────────────────────────────────────────────────────────────────────────────
::  Initialize & Automatic Update‑Status Check
::─────────────────────────────────────────────────────────────────────────────
:init
:: table inner width
set "WIDTH=66"
:: long pad string
set "PAD=                                                                  "

:: auto‑check update status
set "updateURL=https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
set "tempScript=%TEMP%\network-tools-updated.bat"
set "status=Unable to check updates"
2>nul curl -s -o "%tempScript%" "%updateURL%"
if exist "%tempScript%" (
  2>nul fc /b "%~f0" "%tempScript%" >nul
  if errorlevel 1 (set "status=New update available!") else (set "status=Up to date")
  del "%tempScript%" >nul 2>&1
)

goto menu

::─────────────────────────────────────────────────────────────────────────────
::  MAIN MENU
::─────────────────────────────────────────────────────────────────────────────
:menu
cls
color 0A
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "NETWORK UTILITY TOOL v1.7"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "Status: !status!"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "[1] View Computer Information"
call :padAndEcho "[2] Reset Network"
call :padAndEcho "[3] Manage Temp Files (Check/Delete)"
call :padAndEcho "[4] Ping Test"
call :padAndEcho "[5] Active Network Connections"
call :padAndEcho "[6] View Environment Variables"
call :padAndEcho "[7] View Running Processes"
call :padAndEcho "[8] List Wi-Fi Profiles & Passwords"
call :padAndEcho "[9] Check for Updates"
call :padAndEcho "[10] Exit"
echo +%PAD:~0,%WIDTH%+
echo(
<nul set /p="Select an option (1-10): "
set /p option=
if not "%option%"=="%option:~0,2%" set option=0
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto pingTest
if "%option%"=="5" goto netConnections
if "%option%"=="6" goto viewEnv
if "%option%"=="7" goto viewProcs
if "%option%"=="8" goto wifiList
if "%option%"=="9" goto manualUpdate
if "%option%"=="10" exit
call :padAndEcho "Invalid choice, please select 1–10."
timeout /t 1 >nul
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  1) COMPUTER INFORMATION
::─────────────────────────────────────────────────────────────────────────────
:computerInfo
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "COMPUTER INFORMATION"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "Hostname       : %COMPUTERNAME%"
call :padAndEcho "Logged User    : %USERNAME%"
for /f "skip=1 tokens=*" %%A in ('wmic os get Caption') do if not "%%A"=="" (set "os=%%A" & goto showOS)
:showOS
call :padAndEcho "OS Name        : !os!"
for /f "skip=1 tokens=*" %%A in ('wmic cpu get Name') do if not "%%A"=="" (set "cpu=%%A" & goto showCPU)
:showCPU
call :padAndEcho "CPU            : !cpu!"
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
call :padAndEcho "IP Address     :!ip!"
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet Mask"') do set subnet=%%I
call :padAndEcho "Subnet Mask    :!subnet!"
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%I
call :padAndEcho "DNS Server     :!dns!"
for /f "skip=1 tokens=*" %%A in ('wmic bios get SerialNumber') do if not "%%A"=="" (set "sn=%%A" & goto showSN)
:showSN
call :padAndEcho "BIOS Serial No.: !sn!"
for /f "tokens=2 delims==" %%A in ('wmic path SoftwareLicensingService get OA3xOriginalProductKey /value') do set pk=%%A
call :padAndEcho "Product Key    : !pk!"
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value') do set ram=%%A
set /a ramMB=ram/1024
call :padAndEcho "Total RAM      : !ramMB! MB"
echo +%PAD:~0,%WIDTH%+
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  2) RESET NETWORK
::─────────────────────────────────────────────────────────────────────────────
:resetNetwork
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "NETWORK RESET"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "- Release current IP"
call :padAndEcho "- Flush DNS cache"
call :padAndEcho "- Renew IP"
call :padAndEcho "- Reconnect to Wi-Fi"
echo +%PAD:~0,%WIDTH%+
<nul set /p="Proceed (Y/N)? "
set /p confirm=
if /i "%confirm%"=="Y" (
  ipconfig /release >nul 2>&1
  ipconfig /flushdns >nul 2>&1
  ipconfig /renew >nul 2>&1
  netsh wlan disconnect >nul 2>&1
  netsh wlan connect name="WiFiName" >nul 2>&1
  call :padAndEcho "Network reset complete!"
) else (
  call :padAndEcho "Operation cancelled."
)
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  3) MANAGE TEMP FILES
::─────────────────────────────────────────────────────────────────────────────
:manageTempFiles
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "TEMP FILE CLEANER"
echo +%PAD:~0,%WIDTH%+
set "tempDir=%TEMP%" & set /a count=0, size=0
for /r "%tempDir%" %%F in (*) do (
  set /a count+=1
  set /a size+=%%~zF
)
set /a sizeMB=size/1048576
call :padAndEcho "Temp Folder : %tempDir%"
call :padAndEcho "File Count  : %count%"
call :padAndEcho "Used Space  : %sizeMB% MB"
echo +%PAD:~0,%WIDTH%+
<nul set /p="Delete all temp files? (Y/N): "
set /p del=
if /i "%del%"=="Y" (
  del /f /s /q "%tempDir%\*" >nul 2>&1
  for /d %%D in ("%tempDir%\*") do rd /s /q "%%D" >nul 2>&1
  call :padAndEcho "All temp files deleted."
) else (
  call :padAndEcho "Operation cancelled."
)
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  4) PING TEST
::─────────────────────────────────────────────────────────────────────────────
:pingTest
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "PING TEST"
echo +%PAD:~0,%WIDTH%+
<nul set /p="Enter host (default 8.8.8.8): "
set /p host=
if "%host%"=="" set host=8.8.8.8
ping %host% -n 4
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  5) ACTIVE NETWORK CONNECTIONS
::─────────────────────────────────────────────────────────────────────────────
:netConnections
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "ACTIVE NETWORK CONNECTIONS"
echo +%PAD:~0,%WIDTH%+
netstat -an
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  6) VIEW ENVIRONMENT VARIABLES
::─────────────────────────────────────────────────────────────────────────────
:viewEnv
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "ENVIRONMENT VARIABLES"
echo +%PAD:~0,%WIDTH%+
set
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  7) VIEW RUNNING PROCESSES
::─────────────────────────────────────────────────────────────────────────────
:viewProcs
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "RUNNING PROCESSES"
echo +%PAD:~0,%WIDTH%+
tasklist
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  8) LIST WIFI PROFILES & PASSWORDS
::─────────────────────────────────────────────────────────────────────────────
:wifiList
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "WIFI PROFILES & PASSWORDS"
echo +%PAD:~0,%WIDTH%+
set i=0
for /f "tokens=2 delims=:" %%G in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
  set /a i+=1
  set "wf[!i!]=%%~G"
  call :padAndEcho "!i!) %%~G"
)
if %i% EQU 0 (
  call :padAndEcho "No Wi-Fi profiles found."
  pause
  goto menu
)
echo +%PAD:~0,%WIDTH%+
<nul set /p="Select profile number (1-%i%): "
set /p choice=
if not defined wf[%choice%] (
  call :padAndEcho "Invalid choice."
  pause
  goto menu
)
set "sel=!wf[%choice%]!"
call :padAndEcho "Profile: !sel!"
for /f "tokens=2 delims=:" %%H in ('netsh wlan show profile name^="!sel!" key^=clear ^| findstr "Key Content"') do call :padAndEcho "Password:%%H"
echo +%PAD:~0,%WIDTH%+
pause
goto menu

::─────────────────────────────────────────────────────────────────────────────
::  9) MANUAL UPDATE (CLEAR CACHE & RESTART)
::─────────────────────────────────────────────────────────────────────────────
:manualUpdate
color 0E
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "CHECK FOR UPDATES"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "Clearing cache..."
ipconfig /flushdns >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
certutil -urlcache * delete >nul 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >nul 2>&1
call :padAndEcho "Fetching update..."
curl -s -o "%tempScript%" "%updateURL%"
if exist "%tempScript%" (
  copy /y "%tempScript%" "%~f0" >nul
  echo %DATE% %TIME%>last_update.txt
  del "%tempScript%" >nul 2>&1
  call :padAndEcho "Update applied."
  timeout /t 2 >nul
  start "" "%~f0"
  exit
) else (
  call :padAndEcho "Update failed."
  pause
  color 0A
  goto menu
)
