@echo off
title Network Utility Tool
color 0A
mode con: cols=100 lines=30

:: Main menu
:menu
cls
echo ============================================================
echo                  Network Utility Tools
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

:: Function to display computer information
:computerInfo
cls
echo ============================================================
echo                 Computer Information Overview
echo ============================================================
echo Hostname           : %COMPUTERNAME%
echo Logged User        : %USERNAME%
echo OS Version         : %OS%
echo Architecture       : %PROCESSOR_ARCHITECTURE%

echo.
echo OS Name:
for /f "delims=" %%a in ('wmic os get Caption ^| findstr /i /v "Caption"') do echo     %%a

echo Processor:
for /f "delims=" %%a in ('wmic cpu get Name ^| findstr /i /v "Name"') do echo     %%a

echo Cores / Threads:
wmic cpu get NumberOfCores,NumberOfLogicalProcessors /value

echo Baseboard:
wmic baseboard get Manufacturer, Product, SerialNumber /value

echo BIOS Version:
wmic bios get SMBIOSBIOSVersion /value

echo.
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet"') do set subnet=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS"') do set dns=%%I
echo IP Address         :%ip%
echo Subnet Mask        :%subnet%
echo DNS Servers        :%dns%

echo.
echo Memory:
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value

echo Virtual Memory:
wmic pagefile get AllocatedBaseSize,CurrentUsage /value

echo Disk (C:):
wmic logicaldisk where "DeviceID='C:'" get Size,FreeSpace /value

echo ------------------------------------------------------------
pause
goto menu

:: Function to reset the network
:resetNetwork
cls
echo ============================================================
echo                 Network Reset Confirmation
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
echo Network reset completed successfully!
pause
goto menu

:: Function to manage temporary files
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
echo                 Temp File Cleaner
echo ============================================================
echo Temp folder path : %tempDir%
echo Total temp files : %tempFilesCount%
echo Total size used  : %tempSizeMB% MB
echo ------------------------------------------------------------
set /p deleteTemp=Do you want to delete all temp files? (Y/N): 

if /i "%deleteTemp%"=="Y" (
    echo Deleting all temp files...
    del /f /q "%tempDir%\*" >nul 2>&1
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
echo                 Checking for Updates
echo ============================================================
echo Checking GitHub for the latest version...
echo ------------------------------------------------------------

:: Download updated script
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"

if exist "%TEMP%\network-tools-updated.bat" (
    echo Update downloaded successfully.
    echo Replacing current version...
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul
    echo Update applied. Returning to main menu...
    timeout /t 2 >nul
    goto menu
) else (
    echo Failed to download update.
    echo Please check internet connection or GitHub URL.
    pause
    goto menu
)
