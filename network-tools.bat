@echo off
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:menu
cls
echo ===================== Network Utility Services ( Version 1.0 ) =====================
echo [1] View Computer Info
echo [2] Reset Network
echo [3] Manage Temp Files
echo [4] Check for Updates
echo [5] Exit
echo ----------------------------------------------------------------
set /p option=Select an option (1-5): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" exit
goto menu

:computerInfo
cls
echo ================== Basic Computer Information ==================
echo Hostname       : %COMPUTERNAME%
echo Username       : %USERNAME%
for /f "skip=1 delims=" %%a in ('wmic os get Caption') do if not "%%a"=="" echo OS             : %%a& goto next
:next
echo Architecture   : %PROCESSOR_ARCHITECTURE%
for /f "skip=1 delims=" %%a in ('wmic cpu get Name') do if not "%%a"=="" echo CPU            : %%a& goto ip
:ip
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do set ip=%%i
echo IP Address     :%ip%
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%i
echo DNS Server     :%dns%
echo ----------------------------------------------------------------
echo RAM (MB):
for /f "tokens=2 delims==" %%a in ('wmic OS get TotalVisibleMemorySize /value') do set ram=%%a
set /a ramMB=%ram% / 1024
echo Total RAM      : %ramMB% MB
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value') do set freeram=%%a
set /a freeramMB=%freeram% / 1024
echo Free RAM       : %freeramMB% MB
echo ----------------------------------------------------------------
echo Disk (C:) Usage:
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size /value') do set size=%%a
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value') do set free=%%a
set /a sizeGB=%size% / 1073741824
set /a freeGB=%free% / 1073741824
echo Total Disk     : %sizeGB% GB
echo Free Disk      : %freeGB% GB
echo ----------------------------------------------------------------
pause
goto menu

:resetNetwork
cls
echo ================== Network Reset Confirmation ==================
echo This will:
echo - Release IP
echo - Flush DNS
echo - Renew IP
echo - Reconnect Wi-Fi
echo ----------------------------------------------------------------
set /p confirm=Proceed with reset? (Y/N): 
if /i "%confirm%"=="Y" goto performNetworkReset
goto menu

:performNetworkReset
cls
echo Releasing IP...
ipconfig /release
timeout /t 1 >nul
echo Flushing DNS...
ipconfig /flushdns
timeout /t 1 >nul
echo Renewing IP...
ipconfig /renew
timeout /t 1 >nul
echo Reconnecting Wi-Fi...
netsh wlan disconnect
netsh wlan connect name="WiFiName"
echo ----------------------------------------------------------------
echo Network reset complete!
pause
goto menu

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

echo ===================== Temp File Cleaner ========================
echo Temp Folder   : %tempDir%
echo Total Files   : %tempFilesCount%
echo Used Space    : %tempSizeMB% MB
echo ----------------------------------------------------------------
set /p deleteTemp=Delete all temp files? (Y/N): 
if /i "%deleteTemp%"=="Y" (
    echo Deleting files...
    del /f /q "%tempDir%\*" >nul 2>&1
    echo Temp files deleted.
) else (
    echo Cancelled.
)
pause
goto menu

:checkUpdates
cls
echo ===================== Check for Updates ========================
echo Downloading update from GitHub...
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
if exist "%TEMP%\network-tools-updated.bat" (
    echo Update found. Replacing script...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul
    echo Update complete!
    timeout /t 2 >nul
    goto menu
) else (
    echo Failed to download update. Check connection or URL.
    pause
    goto menu
)
