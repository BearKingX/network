@echo off
setlocal EnableDelayedExpansion
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:: === Main Menu ===
:menu
cls
color 0A
echo ============================================================
echo                     Network Utility Tools
echo ============================================================
echo [1] View Computer Information
echo [2] Reset Network
echo [3] Manage Temp Files (Check/Delete)
echo [4] Check for Updates
echo [5] Exit
echo ------------------------------------------------------------
if exist "last_update.txt" (
    for /f "delims=" %%A in (last_update.txt) do set lastUpdate=%%A
    echo Last Update: !lastUpdate!
)
echo ------------------------------------------------------------
set /p option=Select an option (1-5): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit
goto menu

:: === Computer Info (Short) ===
:computerInfo
cls
echo ============================================================
echo                  Computer Information Summary
echo ============================================================
echo Hostname     : %COMPUTERNAME%
echo Username     : %USERNAME%
for /f "tokens=*" %%a in ('wmic os get Caption ^| findstr /v "Caption"') do (
    set "osname=%%a"
    goto showOS
)
:showOS
echo OS Name      : !osname!
for /f "tokens=*" %%a in ('wmic cpu get Name ^| findstr /v "Name"') do (
    set "cpu=%%a"
    goto showCPU
)
:showCPU
echo CPU          : !cpu!
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
echo IP Address   :!ip!
echo ------------------------------------------------------------
pause
goto menu

:: === Reset Network ===
:resetNetwork
cls
echo ============================================================
echo                Network Reset Confirmation
echo ============================================================
echo This will:
echo - Release current IP
echo - Flush DNS cache
echo - Renew IP
echo - Reconnect to Wi-Fi
echo ------------------------------------------------------------
set /p confirm=Proceed with reset? (Y/N): 
if /i "%confirm%"=="Y" goto performNetworkReset
goto menu

:performNetworkReset
cls
echo Releasing IP Address...
ipconfig /release
timeout /t 2 >nul
echo Flushing DNS Cache...
ipconfig /flushdns
timeout /t 2 >nul
echo Renewing IP Address...
ipconfig /renew
timeout /t 2 >nul
echo Disconnecting Wi-Fi...
netsh wlan disconnect
timeout /t 2 >nul
echo Reconnecting to Wi-Fi...
netsh wlan connect name="WiFiName"
timeout /t 2 >nul
echo ------------------------------------------------------------
echo Network reset complete!
pause
goto menu

:: === Temp File Cleaner ===
:manageTempFiles
cls
set tempDir=%TEMP%
set /a tempFilesCount=0
set /a tempSize=0

for /f "delims=" %%F in ('dir /a /s /b "%tempDir%" 2^>nul') do (
    set /a tempFilesCount+=1
    for %%A in ("%%F") do set /a tempSize+=%%~zA
)
set /a tempSizeMB=%tempSize% / 1048576

echo ============================================================
echo                     Temp File Cleaner
echo ============================================================
echo Temp Folder  : %tempDir%
echo Total Files  : %tempFilesCount%
echo Used Space   : %tempSizeMB% MB
echo ------------------------------------------------------------
set /p deleteTemp=Delete all temp files? (Y/N): 
if /i "%deleteTemp%"=="Y" (
    echo Deleting files...
    del /f /s /q "%tempDir%\*" >nul 2>&1
    echo Temp files deleted.
) else (
    echo Operation cancelled.
)
pause
goto menu

:: === Check for Updates (Yellow) ===
:checkUpdates
color 0E
cls
echo ============================================================
echo                    Checking for Updates
echo ============================================================
echo Fetching update from GitHub...
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

if exist "last_update.txt" (
    for /f "delims=" %%A in (last_update.txt) do set lastUpdate=%%A
    echo Last Update: !lastUpdate!
) else (
    echo Last Update: Not available
)
echo ------------------------------------------------------------
if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Updating current version...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul

    if errorlevel 1 (
        echo Error updating the script.
        pause
        color 0A
        goto menu
    )

    echo Update applied successfully!
    echo %DATE% %TIME% > last_update.txt
    timeout /t 2 >nul

    echo Restarting script...
    start "" "%~f0"
    exit
) else (
    echo Failed to download the update.
    echo Please check your internet connection or GitHub URL.
    pause
    color 0A
    goto menu
)
