@echo off
title Server Update Utility - Hashim
color 0A

:: Prompt for update confirmation
cls
echo ============================================================
echo        Server Update Utility - Hashim Tools
echo ============================================================
echo This will update the "network-tools.bat" file on the server.
set /p confirm=Proceed with update? (Y/N): 

if /i "%confirm%"=="Y" goto performUpdate
goto exit

:: Perform update operations
:performUpdate
cls
echo Downloading the latest version of "network-tools.bat" from GitHub...
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

:: Check if the update file was downloaded
if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Replacing the old version on the server...
    copy /y "%TEMP%\network-tools-updated.bat" "network-tools.bat"
    echo Update complete! Returning to the main menu...
    timeout /t 2
    exit
) else (
    echo Failed to download the update. Please check your internet connection or GitHub URL.
    timeout /t 2
    exit
)

:: Exit
:exit
exit
