@echo off
setlocal EnableDelayedExpansion
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:: === LOADING ANIMATION ===
:loading
rem 8-frame spinner
set "spinner=|/-\"
for /l %%i in (0,1,7) do (
    set /a idx=%%i %% 4
    set "ch=!spinner:~!idx!,1!"
    cls
    echo Loading !ch!
    timeout /t 1 >nul
)
exit /b

:: === MAIN MENU ===
:menu
call :loading
cls
color 0A
echo +================================================================+
echo ^|                 NETWORK UTILITY TOOL v1.4                  ^|
echo +================================================================+
if exist last_update.txt (
  for /f "delims=" %%A in (last_update.txt) do echo Last Update: %%A
) else echo Last Update: N/A
echo +----------------------------------------------------------------+
echo ^| [1] View Computer Information                                ^|
echo ^| [2] Reset Network                                            ^|
echo ^| [3] Manage Temp Files (Check/Delete)                         ^|
echo ^| [4] Check for Updates                                        ^|
echo ^| [5] Exit                                                     ^|
echo +================================================================+
set /p option=Select (1-5): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit
goto menu

:: === COMPUTER INFORMATION ===
:computerInfo
cls
echo +----------------------- COMPUTER INFORMATION -----------------------+
echo ^| Hostname       : %COMPUTERNAME%                                 ^|
echo ^| Logged User    : %USERNAME%                                      ^|
for /f "skip=1 tokens=*" %%A in ('wmic os get Caption') do if not "%%A"=="" echo ^| OS Name        : %%A & goto cpu
:cpu
for /f "skip=1 tokens=*" %%A in ('wmic cpu get Name') do if not "%%A"=="" echo ^| CPU            : %%A & goto ip
:ip
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
echo ^| IP Address     :!ip!                                           ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet Mask"') do set subnet=%%I
echo ^| Subnet Mask    :!subnet!                                       ^|
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%I
echo ^| DNS Server     :!dns!                                          ^|
for /f "skip=1 tokens=*" %%A in ('wmic bios get SerialNumber') do if not "%%A"=="" echo ^| BIOS Serial No.: %%A & goto mem
:mem
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value') do set ram=%%A
set /a ramMB=ram/1024
echo ^| Total RAM      : !ramMB! MB                                   ^|
echo +------------------------------------------------------------------+
pause
goto menu

:: === NETWORK RESET ===
:resetNetwork
cls
echo +----------------------- NETWORK RESET ------------------------+
echo ^| This will:                                               ^|
echo ^|  - Release current IP                                     ^|
echo ^|  - Flush DNS cache                                        ^|
echo ^|  - Renew IP                                               ^|
echo ^|  - Reconnect to Wi‑Fi                                     ^|
echo +------------------------------------------------------------+
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

:: === TEMP FILE CLEANER ===
:manageTempFiles
cls
set "tempDir=%TEMP%"
set /a count=0, size=0
for /r "%tempDir%" %%F in (*) do (
  set /a count+=1
  set /a size+=%%~zF
)
set /a sizeMB=size/1048576
echo +----------------------- TEMP FILE CLEANER -----------------------+
echo ^| Temp Folder : %tempDir%                                      ^|
echo ^| File Count  : %count%                                         ^|
echo ^| Used Space  : %sizeMB% MB                                     ^|
echo +----------------------------------------------------------------+
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

:: === CHECK FOR UPDATES (Yellow) ===
:checkUpdates
color 0E
cls
echo +----------------------- CHECK FOR UPDATES -----------------------+
echo ^| Fetching update from GitHub...                              ^|
echo +----------------------------------------------------------------+
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
