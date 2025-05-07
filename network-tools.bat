@echo off
title Server Update Utility - Hashim
color 0A
mode con: cols=100 lines=30

:: Set up variables for update
set "updateURL=https://raw.githubusercontent.com/YourGitHubUsername/YourRepoName/main/network-tools.bat"
set "localScript=network-tools.bat"
set "tempScript=%TEMP%\network-tools-updated.bat"

:: Function to download and update the client batch file
:downloadUpdate
cls
echo ============================================================
echo Downloading the latest version of network-tools.bat from GitHub...
echo ============================================================
echo Please wait, this may take a few seconds.
curl -s -o "%tempScript%" "%updateURL%"

:: Check if the update file was downloaded
if exist "%tempScript%" (
    echo Update downloaded successfully.
    echo Replacing the current script with the new version...
    copy /y "%tempScript%" "%localScript%"
    echo Update complete!
) else (
    echo Failed to download the update. Please check your internet connection or GitHub URL.
    pause
)

pause
exit
