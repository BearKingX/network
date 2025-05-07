:checkUpdates
color 0E
cls
echo ============================================================
echo                    Checking for Updates
echo ============================================================
echo Fetching update from GitHub...
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

:: Display the last update time if available
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

    echo Restarting the script...
    timeout /t 2 >nul

    :: ✅ Restart the script properly
    start "" cmd /c "%~f0"
    exit /b
) else (
    echo Failed to download the update.
    echo Check your internet connection or GitHub URL.
    pause
    color 0A
    goto menu
)
