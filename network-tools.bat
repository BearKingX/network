@echo off
title Network Utility Tool - Hashim
color 0A
mode con: cols=100 lines=30

:: Main menu
:menu
cls
echo ============================================================
echo            Network Utility - Hashim Tools
echo ============================================================
echo [1] View Computer Information
echo [2] Reset Network
echo [3] Manage Temp Files (Check/Delete)
echo [4] Check for Updates
echo [5] Exit
echo -----------------------------------------------------------
set /p option=Select an option (1-5): 

if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit

goto menu

:: Function to display computer information
:computerInfo
cls
echo ============================================================
echo            Computer Information Overview
echo ============================================================
echo Hostname     : %COMPUTERNAME%
echo Logged User  : %USERNAME%
echo OS Version   : %OS%
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
echo IP Address   : %ip%
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet"') do set subnet=%%I
echo Subnet Mask  : %subnet%
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS"') do set dns=%%I
echo DNS Servers  : %dns%
echo -----------------------------------------------------------
pause
goto menu

:: Function to reset the network
:resetNetwork
cls
echo ============================================================
echo            Network Reset Confirmation
echo ============================================================
echo This tool will:
echo - Release current IP
echo - Flush DNS cache
echo - Renew IP
echo - Reconnect to Wi-Fi
set /p confirm=Proceed with reset? (Y/N): 

if /i "%confirm%"=="Y" goto performNetworkReset
goto menu

:: Perform network reset operations
:performNetworkReset
cls
echo Releasing IP Address...
ipconfig /release
timeout /t 2

echo Flushing DNS Cache...
ipconfig /flushdns
timeout /t 2

echo Renewing IP Address...
ipconfig /renew
timeout /t 2

echo Disconnecting Wi-Fi...
netsh wlan disconnect
timeout /t 2

echo Reconnecting to Wi-Fi...
netsh wlan connect name="WiFiName"
timeout /t 2

echo -----------------------------------------------------------
echo Network reset completed successfully!
pause
goto menu

:: Function to manage temporary files
:manageTempFiles
cls
set tempDir=%TEMP%
set tempFilesCount=0
set tempSize=0

for /r "%tempDir%" %%A in (*) do (
    set /a tempFilesCount+=1
    set /a tempSize+=%%~zA
)

set /a tempSizeMB=%tempSize%/1048576
echo ============================================================
echo            Temp File Cleaner
echo ============================================================
echo Temp folder path: %tempDir%
echo Total temp files: %tempFilesCount%
echo Total size used : %tempSizeMB% MB
echo -----------------------------------------------------------
set /p deleteTemp=Do you want to delete all temp files? (Y/N): 

if /i "%deleteTemp%"=="Y" (
    echo Deleting all temp files...
    del /f /q "%tempDir%\*"
    echo Temp files deleted.
) else (
    echo Temp files not deleted.
)

pause
goto menu

:: Function to check for updates
:checkUpdates
cls
echo ============================================================
echo Checking for updates from GitHub...
echo ============================================================
echo This may take a few seconds.
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

:: Check if the update file was downloaded
if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Replacing the current script with the new version...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0"
    echo Update complete! Returning to the main menu...
    timeout /t 2
    goto menu
) else (
    echo Failed to download the update. Please check your internet connection or GitHub URL.
    pause
    goto menu
)
