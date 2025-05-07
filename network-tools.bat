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
echo [4] Check Active Network Connections
echo [5] View Wi-Fi Profiles & Passwords
echo [6] Network Adapter Status
echo [7] Flush ARP Cache
echo [8] Trace Route
echo [9] Check for Updates
echo [10] Exit
echo ------------------------------------------------------------
set /p option=Select an option (1-10): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto activeConnections
if "%option%"=="5" goto wifiProfiles
if "%option%"=="6" goto networkAdapterStatus
if "%option%"=="7" goto flushArpCache
if "%option%"=="8" goto traceRoute
if "%option%"=="9" goto checkUpdates
if "%option%"=="10" exit
goto menu

:: Display Computer Information (Shortened)
:computerInfo
cls
echo ============================================================
echo              Computer Information Overview
echo ============================================================
echo Hostname         : %COMPUTERNAME%
echo OS Version       : %OS%
echo Processor        : %PROCESSOR_IDENTIFIER%

for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet"') do set subnet=%%I
echo IP Address       :%ip%
echo Subnet Mask      :%subnet%

echo Memory Info:
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value
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

:: Manage Temp Files
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
    echo Temp files deleted.
) else (
    echo Operation cancelled.
)
pause
goto menu

:: Check Active Network Connections
:activeConnections
cls
echo ============================================================
echo             Active Network Connections
echo ============================================================
netstat -an
echo ------------------------------------------------------------
pause
goto menu

:: View Wi-Fi Profiles & Passwords
:wifiProfiles
cls
echo ============================================================
echo          View Wi-Fi Profiles & Passwords
echo ============================================================
netsh wlan show profiles
echo ------------------------------------------------------------
set /p profileName=Enter Profile Name to see the Password: 
netsh wlan show profile name="%profileName%" key=clear
echo ------------------------------------------------------------
pause
goto menu

:: Network Adapter Status
:networkAdapterStatus
cls
echo ============================================================
echo          Network Adapter Status Overview
echo ============================================================
wmic nic get Name, Status
echo ------------------------------------------------------------
pause
goto menu

:: Flush ARP Cache
:flushArpCache
cls
echo ============================================================
echo               Flushing ARP Cache
echo ============================================================
arp -d
echo ------------------------------------------------------------
pause
goto menu

:: Trace Route
:traceRoute
cls
echo ============================================================
echo               Trace Route to Host
echo ============================================================
set /p traceHost=Enter Host or IP to trace: 
tracert %traceHost%
echo ------------------------------------------------------------
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

if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Updating current version...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul
    echo Update applied successfully!
    timeout /t 2 >nul
    goto menu
) else (
    echo Failed to download the update.
    echo Check your internet connection or GitHub URL.
    pause
    goto menu
)
