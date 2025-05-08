@echo off
setlocal EnableDelayedExpansion
title Network Utility Tool
color 0A
mode con: cols=100 lines=9999

:: === AUTOMATIC UPDATE STATUS CHECK ===
set "updateURL=https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
set "tempScript=%TEMP%\network-tools-updated.bat"
set "status=Unable to check updates"

:: download latest script silently
curl -s -o "%tempScript%" "%updateURL%" 2>nul
if exist "%tempScript%" (
    fc /b "%~f0" "%tempScript%" >nul
    if errorlevel 1 (
        set "status=New update available!"
    ) else (
        set "status=Up to date"
    )
    del "%tempScript%" >nul 2>&1
)

:: === MAIN MENU ===
:menu
cls
color 0A
echo +==================================================================================================+
echo ^|                                  NETWORK UTILITY TOOL v1.7                                     ^|
echo +==================================================================================================+
echo ^| Status: !status!                                                                                ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| [1] View Computer Information                                                                   ^|
echo ^| [2] Reset Network                                                                               ^|
echo ^| [3] Manage Temp Files (Check/Delete)                                                            ^|
echo ^| [4] Ping Test                                                                                   ^|
echo ^| [5] Active Network Connections                                                                  ^|
echo ^| [6] View Environment Variables                                                                  ^|
echo ^| [7] View Running Processes                                                                      ^|
echo ^| [8] List Wi-Fi Profiles ^& Passwords                                                            ^|
echo ^| [9] Check for Updates                                                                           ^|
echo ^| [10] Exit                                                                                       ^|
echo +==================================================================================================+
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
echo +==================================================================================================+
echo ^|                                COMPUTER INFORMATION                                            ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| Hostname        : %COMPUTERNAME%                                                                ^|
echo ^| Logged User     : %USERNAME%                                                                    ^|
for /f "skip=1 tokens=*" %%A in ('wmic os get Caption') do if not "%%A"=="" echo ^| OS Name         : %%A                                                              ^| & goto cpu
:cpu
for /f "skip=1 tokens=*" %%A in ('wmic cpu get Name') do if not "%%A"=="" echo ^| CPU             : %%A                                                              ^| & goto ip
:ip
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
echo ^| IP Address      :!ip!                                                                            ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet Mask"') do set subnet=%%I
echo ^| Subnet Mask     :!subnet!                                                                        ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%I
echo ^| DNS Server      :!dns!                                                                           ^|
for /f "skip=1 tokens=*" %%A in ('wmic bios get SerialNumber') do if not "%%A"=="" echo ^| BIOS Serial No.: %%A                                                            ^| & goto mem
:mem
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value') do set ram=%%A
set /a ramMB=ram/1024
echo ^| Total RAM       : !ramMB! MB                                                                     ^|
echo +--------------------------------------------------------------------------------------------------+
pause
goto menu

:: === RESET NETWORK ===
:resetNetwork
cls
echo +==================================================================================================+
echo ^|                                      NETWORK RESET                                              ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| This will:                                                                                      ^|
echo ^|  - Release current IP                                                                           ^|
echo ^|  - Flush DNS cache                                                                              ^|
echo ^|  - Renew IP                                                                                     ^|
echo ^|  - Reconnect to Wi-Fi                                                                           ^|
echo +--------------------------------------------------------------------------------------------------+
<nul set /p="Proceed (Y/N)? "
set /p confirm=
if /i "%confirm%"=="Y" goto performNetworkReset
goto menu

:performNetworkReset
cls
echo Releasing IP...
ipconfig /release || (echo Error releasing IP & pause & goto menu)
echo Flushing DNS...
ipconfig /flushdns || (echo Error flushing DNS & pause & goto menu)
echo Renewing IP...
ipconfig /renew || (echo Error renewing IP & pause & goto menu)
echo Disconnecting Wi-Fi...
netsh wlan disconnect >nul 2>&1
echo Reconnecting Wi-Fi...
netsh wlan connect name="WiFiName" || (echo Error reconnecting & pause & goto menu)
echo Network reset complete!
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
echo +==================================================================================================+
echo ^|                                   TEMP FILE CLEANER                                             ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| Temp Folder     : %tempDir%                                                                     ^|
echo ^| File Count      : %count%                                                                       ^|
echo ^| Used Space      : %sizeMB% MB                                                                   ^|
echo +--------------------------------------------------------------------------------------------------+
<nul set /p="Delete all temp files? (Y/N): "
set /p del=
if /i "%del%"=="Y" (
  del /f /s /q "%tempDir%\*" >nul 2>&1
  for /d %%D in ("%tempDir%\*") do rd /s /q "%%D" >nul 2>&1
  if errorlevel 1 (echo Error deleting some files/folders.) else (echo All temp files deleted.)
) else echo Operation cancelled.
pause
goto menu

:: === PING TEST ===
:pingTest
cls
<nul set /p="Enter host to ping (default 8.8.8.8): "
set /p host= 
if "%host%"=="" set host=8.8.8.8
echo Pinging %host%...
ping %host% -n 4
pause
goto menu

:: === ACTIVE NETWORK CONNECTIONS ===
:netConnections
cls
echo Active TCP/UDP Connections:
netstat -an
pause
goto menu

:: === VIEW ENVIRONMENT VARIABLES ===
:viewEnv
cls
echo Environment Variables:
set
pause
goto menu

:: === VIEW RUNNING PROCESSES ===
:viewProcs
cls
echo Running Processes:
tasklist
pause
goto menu

:: === LIST WIFI PROFILES & PASSWORDS ===
:wifiList
cls
echo +==================================================================================================+
echo ^|                                  WIFI PROFILES                                                  ^|
echo +--------------------------------------------------------------------------------------------------+
set i=0
for /f "tokens=2 delims=:" %%G in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
  set /a i+=1
  set "wf[!i!]=%%~G"
  echo  !i!) %%~G
)
if %i% EQU 0 (
  echo No Wi-Fi profiles found.
  pause
  goto menu
)
echo +--------------------------------------------------------------------------------------------------+
<nul set /p="Select profile number (1-%i%): "
set /p choice=
if not defined wf[%choice%] (
  echo Invalid choice.
  pause
  goto menu
)
set "sel=!wf[%choice%]!"
echo Profile: !sel!
echo Password:
netsh wlan show profile name="!sel!" key=clear ^| findstr "Key Content"
pause
goto menu

:: === MANUAL UPDATE ===
:manualUpdate
color 0E
cls
echo +==================================================================================================+
echo ^|                                 CHECK FOR UPDATES                                               ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| Clearing cache...                                                                               ^|
echo +--------------------------------------------------------------------------------------------------+
ipconfig /flushdns >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
certutil -urlcache * delete >nul 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >nul 2>&1

echo ^| Fetching update from GitHub...                                                                  ^|
echo +--------------------------------------------------------------------------------------------------+
curl -s -o "%tempScript%" "%updateURL%"
if exist "%tempScript%" (
  echo Update downloaded.
  copy /y "%tempScript%" "%~f0" >nul
  echo %DATE% %TIME%>last_update.txt
  del "%tempScript%" >nul 2>&1
  echo Cache cleared.
  echo Restarting...
  timeout /t 2 >nul
  start "" "%~f0"
  exit
) else (
  echo Failed to download update.
  pause
  color 0A
  goto menu
)
