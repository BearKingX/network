@echo off
setlocal EnableDelayedExpansion
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:: === SETTINGS ===
:: table inner width (characters between the pipes)
set "WIDTH=66"
:: a long pad string for padding
set "PAD=                                                                                                    "

:: === HELPER: pad text to WIDTH then wrap with pipes ===
:padAndEcho
rem %~1 is the text to display
set "line=%~1"
set "line=!line!!PAD!"
set "line=!line:~0,%WIDTH%!"
echo ^| !line! ^|
exit /b

:: === AUTOMATIC UPDATE STATUS CHECK ===
set "updateURL=https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
set "tempScript=%TEMP%\network-tools-updated.bat"
set "status=Unable to check updates"
curl -s -o "%tempScript%" "%updateURL%" 2>nul
if exist "%tempScript%" (
    fc /b "%~f0" "%tempScript%" >nul
    if errorlevel 1 (set "status=New update available!") else (set "status=Up to date")
    del "%tempScript%" >nul 2>&1
)

:: === MAIN MENU ===
:menu
cls
color 0A
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "NETWORK UTILITY TOOL v1.7"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "Status: !status!"
echo +%PAD:~0,%WIDTH%+
for %%n in (1 2 3 4 5 6 7 8 9 10) do (
    if %%n==1 call :padAndEcho "[1] View Computer Information"
    if %%n==2 call :padAndEcho "[2] Reset Network"
    if %%n==3 call :padAndEcho "[3] Manage Temp Files (Check/Delete)"
    if %%n==4 call :padAndEcho "[4] Ping Test"
    if %%n==5 call :padAndEcho "[5] Active Network Connections"
    if %%n==6 call :padAndEcho "[6] View Environment Variables"
    if %%n==7 call :padAndEcho "[7] View Running Processes"
    if %%n==8 call :padAndEcho "[8] List Wi-Fi Profiles & Passwords"
    if %%n==9 call :padAndEcho "[9] Check for Updates"
    if %%n==10 call :padAndEcho "[10] Exit"
)
echo +%PAD:~0,%WIDTH%+
<nul set /p="Select an option (1-10): "
set /p option=
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
goto menu

:: === COMPUTER INFORMATION ===
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

:: === RESET NETWORK ===
:resetNetwork
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "NETWORK RESET"
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "This will:"
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

:: === MANAGE TEMP FILES ===
:manageTempFiles
cls
set "tempDir=%TEMP%"
set /a count=0, size=0
for /r "%tempDir%" %%F in (*) do (
  set /a count+=1
  set /a size+=%%~zF
)
set /a sizeMB=size/1048576
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "TEMP FILE CLEANER"
echo +%PAD:~0,%WIDTH%+
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

:: === PING TEST ===
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

:: === ACTIVE NETWORK CONNECTIONS ===
:netConnections
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "ACTIVE NETWORK CONNECTIONS"
echo +%PAD:~0,%WIDTH%+
netstat -an
pause
goto menu

:: === VIEW ENVIRONMENT VARIABLES ===
:viewEnv
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "ENVIRONMENT VARIABLES"
echo +%PAD:~0,%WIDTH%+
set
pause
goto menu

:: === VIEW RUNNING PROCESSES ===
:viewProcs
cls
echo +%PAD:~0,%WIDTH%+
call :padAndEcho "RUNNING PROCESSES"
echo +%PAD:~0,%WIDTH%+
tasklist
pause
goto menu

:: === LIST WIFI PROFILES & PASSWORDS ===
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

:: === MANUAL UPDATE ===
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
