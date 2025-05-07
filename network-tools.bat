@echo off
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:: Main Menu
:menu
cls
echo ============================================================
echo                   Network Utility Tools
echo ============================================================
echo [1] View Computer Information
echo [2] Reset Network
echo [3] Manage Temp Files (Check/Delete)
echo [4] Check for Updates
echo [5] Exit
echo ------------------------------------------------------------
set /p option=Select an option (1-5): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit
goto menu

:: Display Computer Information
:computerInfo
cls
echo ============================================================
echo              Computer Information Overview
echo ============================================================
echo Hostname         : %COMPUTERNAME%
echo Logged User      : %USERNAME%
echo OS Version       : %OS%
echo Architecture     : %PROCESSOR_ARCHITECTURE%
echo IP Address       : %IP%
echo Subnet Mask      : %SUBNET%
echo DNS Servers      : %DNS%
echo ------------------------------------------------------------
pause
goto menu

:: Network Reset
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
if errorlevel 1 (
    echo Error releasing IP address.
    pause
    goto menu
)
timeout /t 2 >nul
echo Flushing DNS Cache...
ipconfig /flushdns
if errorlevel 1 (
    echo Error flushing DNS cache.
    pause
    goto menu
)
timeout /t 2 >nul
echo Renewing IP Address...
ipconfig /renew
if errorlevel 1 (
    echo Error renewing IP address.
    pause
    goto menu
)
timeout /t 2 >nul
echo Disconnecting Wi-Fi...
netsh wlan disconnect
if errorlevel 1 (
    echo Error disconnecting Wi-Fi.
    pause
    goto menu
)
timeout /t 2 >nul
echo Reconnecting to Wi-Fi...
netsh wlan connect name="WiFiName"
if errorlevel 1 (
    echo Error reconnecting to Wi-Fi.
    pause
    goto menu
)
timeout /t 2 >nul
echo ------------------------------------------------------------
echo Network reset complete!
pause
goto menu

:: Manage Temp Files
:manageTempFiles
cls
set tempDir=%TEMP%
set /a tempFilesCount=0
set /a tempSize=0

:: Counting the temp files and calculating the total size
for /f "delims=" %%F in ('dir /a /s /b "%tempDir%" 2^>nul') do (
    set /a tempFilesCount+=1
    for %%A in ("%%F") do set /a tempSize+=%%~zA
)

set /a tempSizeMB=%tempSize% / 1048576

echo ============================================================
echo                   Temp File Cleaner
echo ============================================================
echo Temp Folder     : %tempDir%
echo Total Files     : %tempFilesCount%
echo Used Space      : %tempSizeMB% MB
echo ------------------------------------------------------------
set /p deleteTemp=Delete all temp files? (Y/N): 
if /i "%deleteTemp%"=="Y" (
    echo Deleting files...
    del /f /q "%tempDir%\*" >nul 2>&1
    if errorlevel 1 (
        echo Error deleting temp files.
        pause
        goto menu
    )
    echo Temp files deleted.
) else (
    echo Operation cancelled.
)
pause
goto menu

:: Check for Updates (Yellow Text)
:checkUpdates
color 0E
cls
echo ============================================================
echo                    Checking for Updates
echo ============================================================
echo Fetching update from GitHub...
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

:: Display the last update time if the file exists
if exist "last_update.txt" (
    for /f "delims=" %%A in (last_update.txt) do set lastUpdate=%%A
    echo Last Update: %lastUpdate%
) else (
    echo Last Update: Not available
)

echo -----------------------------------------------------------
echo Update Process:
if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Updating current version...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul
    if errorlevel 1 (
        echo Error updating the script.
        pause
        goto menu
    )
    echo Update applied successfully!
    
    :: Store the current date and time as the last update
    echo %DATE% %TIME% > last_update.txt
    timeout /t 2 >nul
    echo Restarting the script...
    exit
) else (
    echo Failed to download the update.
    echo Check your internet connection or GitHub URL.
    pause
    goto menu
)

:: After exiting, this will launch the script again
start cmd /c "%~f0"
