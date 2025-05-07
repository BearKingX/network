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

echo OS Name:
for /f "delims=" %%a in ('wmic os get Caption ^| findstr /v "Caption"') do echo   %%a

echo Processor:
for /f "delims=" %%a in ('wmic cpu get Name ^| findstr /v "Name"') do echo   %%a

echo Cores / Threads:
wmic cpu get NumberOfCores,NumberOfLogicalProcessors /value

echo Baseboard Info:
wmic baseboard get Manufacturer,Product,SerialNumber /value

echo BIOS Version:
wmic bios get SMBIOSBIOSVersion /value

for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet"') do set subnet=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS"') do set dns=%%I
echo IP Address       :%ip%
echo Subnet Mask      :%subnet%
echo DNS Servers      :%dns%

echo Memory Info:
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value

echo Virtual Memory:
wmic pagefile get AllocatedBaseSize,CurrentUsage /value

echo Disk (C:) Usage:
wmic logicaldisk where "DeviceID='C:'" get Size,FreeSpace /value

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

:: Check for Updates
:checkUpdates
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
