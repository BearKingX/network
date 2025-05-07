@echo off
setlocal EnableDelayedExpansion

:: ======== SETTINGS ========
title Network Utility Tool
mode con: cols=100 lines=30
:: number of blank lines before menu to vertically center (approx)
set vblank=8
:: number of spaces to prefix each line to approximate horizontal center
set spaces=                  

:: ======== STARTUP LOADING ANIMATION ========
call :startup
goto menu

:: ======== SUBROUTINES ========

:startup
cls
:: Starting System...
call :vblank
echo %spaces%Starting System...
ping -n 1 -w 750 127.0.0.1 >nul

:: Gathering Information...
cls
call :vblank
echo %spaces%Gathering Information...
ping -n 1 -w 750 127.0.0.1 >nul

:: Clearing Temp Files...
cls
call :vblank
echo %spaces%Clearing Temp Files...
ping -n 1 -w 750 127.0.0.1 >nul

:: Almost done...
cls
call :vblank
echo %spaces%Almost done...
ping -n 1 -w 750 127.0.0.1 >nul

exit /b

:vblank
for /L %%i in (1,1,%vblank%) do echo.
exit /b

:: ======== MAIN MENU ========
:menu
cls
color 0A
call :vblank
echo %spaces%+================================================================+
echo %spaces%^|                 NETWORK UTILITY TOOL v1.5                  ^|
echo %spaces%+================================================================+
if exist last_update.txt (
  for /f "delims=" %%A in (last_update.txt) do echo %spaces%^| Last Update: %%A
) else echo %spaces%^| Last Update: N/A
echo %spaces%+----------------------------------------------------------------+
echo %spaces%^| [1] View Computer Information                                ^|
echo %spaces%^| [2] Reset Network                                            ^|
echo %spaces%^| [3] Manage Temp Files (Check/Delete)                         ^|
echo %spaces%^| [4] Check for Updates                                        ^|
echo %spaces%^| [5] Exit                                                     ^|
echo %spaces%+================================================================+
set /p option=Select an option (1-5): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit
goto menu

:: ======== COMPUTER INFORMATION ========
:computerInfo
cls
call :vblank
echo %spaces%+----------------------- COMPUTER INFORMATION -----------------------+
echo %spaces%^| Hostname       : %COMPUTERNAME%                                 ^|
echo %spaces%^| Logged User    : %USERNAME%                                      ^|
for /f "skip=1 tokens=*" %%A in ('wmic os get Caption') do if not "%%A"=="" echo %spaces%^| OS Name        : %%A & goto cpu
:cpu
for /f "skip=1 tokens=*" %%A in ('wmic cpu get Name') do if not "%%A"=="" echo %spaces%^| CPU            : %%A & goto ip
:ip
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
echo %spaces%^| IP Address     :!ip!                                           ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet Mask"') do set subnet=%%I
echo %spaces%^| Subnet Mask    :!subnet!                                       ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%I
echo %spaces%^| DNS Server     :!dns!                                          ^|
for /f "skip=1 tokens=*" %%A in ('wmic bios get SerialNumber') do if not "%%A"=="" echo %spaces%^| BIOS Serial No.: %%A & goto mem
:mem
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value') do set ram=%%A
set /a ramMB=ram/1024
echo %spaces%^| Total RAM      : !ramMB! MB                                   ^|
echo %spaces%+------------------------------------------------------------------+
pause
goto menu

:: ======== NETWORK RESET ========
:resetNetwork
cls
call :vblank
echo %spaces%+----------------------- NETWORK RESET ------------------------+
echo %spaces%^| This will:                                               ^|
echo %spaces%^|  - Release current IP                                     ^|
echo %spaces%^|  - Flush DNS cache                                        ^|
echo %spaces%^|  - Renew IP                                               ^|
echo %spaces%^|  - Reconnect to Wi‑Fi                                     ^|
echo %spaces%+------------------------------------------------------------+
set /p confirm=Proceed (Y/N)? 
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
echo Disconnecting Wi‑Fi...
netsh wlan disconnect >nul 2>&1
echo Reconnecting Wi‑Fi...
netsh wlan connect name="WiFiName" || (echo Error reconnecting & pause & goto menu)
echo Network reset complete!
pause
goto menu

:: ======== TEMP FILE CLEANER ========
:manageTempFiles
cls
call :vblank
set "tempDir=%TEMP%"
set /a count=0, size=0
for /r "%tempDir%" %%F in (*) do (
  set /a count+=1
  set /a size+=%%~zF
)
set /a sizeMB=size/1048576
echo %spaces%+----------------------- TEMP FILE CLEANER -----------------------+
echo %spaces%^| Temp Folder : %tempDir%                                      ^|
echo %spaces%^| File Count  : %count%                                         ^|
echo %spaces%^| Used Space  : %sizeMB% MB                                     ^|
echo %spaces%+----------------------------------------------------------------+
set /p del=Delete all temp files? (Y/N): 
if /i "%del%"=="Y" (
  echo Deleting files...
  del /f /s /q "%tempDir%\*" >nul 2>&1
  for /d %%D in ("%tempDir%\*") do rd /s /q "%%D" >nul 2>&1
  if errorlevel 1 (
    echo Error deleting some files/folders.
  ) else (
    echo All temp files and folders deleted.
  )
) else (
  echo Operation cancelled.
)
pause
goto menu

:: ======== CHECK FOR UPDATES (Yellow) ========
:checkUpdates
color 0E
cls
call :vblank
echo %spaces%+----------------------- CHECK FOR UPDATES -----------------------+
echo %spaces%^| Fetching update from GitHub...                              ^|
echo %spaces%+----------------------------------------------------------------+
set "updateURL=https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
set "tempScript=%TEMP%\network-tools-updated.bat"
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
