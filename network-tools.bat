# Let's generate the full batch script with all the new menu items integrated.
# The code will be structured and readable, with clear comments and consistent formatting.

menu_script = r"""@echo off
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
echo [5] View Public IP Address
echo [6] Speed Test
echo [7] Ping Test / Latency
echo [8] Active Network Connections
echo [9] Wi-Fi Profiles & Passwords
echo [10] Network Adapter Status
echo [11] Flush ARP Cache
echo [12] Trace Route
echo [13] Exit
echo ------------------------------------------------------------
set /p option=Select an option (1-13): 
if "%option%"=="1" goto computerInfo
if "%option%"=="2" goto resetNetwork
if "%option%"=="3" goto manageTempFiles
if "%option%"=="4" goto checkUpdates
if "%option%"=="5" goto publicIP
if "%option%"=="6" goto speedTest
if "%option%"=="7" goto pingTest
if "%option%"=="8" goto netConnections
if "%option%"=="9" goto wifiProfiles
if "%option%"=="10" goto adapterStatus
if "%option%"=="11" goto flushARP
if "%option%"=="12" goto traceRoute
if "%option%"=="13" exit
goto menu

:computerInfo
cls
echo ============================================================
echo              Computer Information Overview
echo ============================================================
echo Hostname         : %COMPUTERNAME%
echo Logged User      : %USERNAME%
echo OS Version       : %OS%
echo Architecture     : %PROCESSOR_ARCHITECTURE%
for /f "delims=" %%a in ('wmic os get Caption ^| findstr /v "Caption"') do echo OS Name: %%a
for /f "delims=" %%a in ('wmic cpu get Name ^| findstr /v "Name"') do echo CPU: %%a
wmic cpu get NumberOfCores,NumberOfLogicalProcessors /value
wmic baseboard get Manufacturer,Product /value
wmic bios get SMBIOSBIOSVersion /value
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "IPv4"') do set ip=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "Subnet"') do set subnet=%%I
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr "DNS Servers"') do set dns=%%I
echo IP Address       :%ip%
echo Subnet Mask      :%subnet%
echo DNS Servers      :%dns%
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value
wmic pagefile get AllocatedBaseSize,CurrentUsage /value
wmic logicaldisk where "DeviceID='C:'" get Size,FreeSpace /value
echo ------------------------------------------------------------
pause
goto menu

:resetNetwork
cls
echo ============================================================
echo                Network Reset Confirmation
echo ============================================================
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
ipconfig /release
ipconfig /flushdns
ipconfig /renew
netsh wlan disconnect
netsh wlan connect name="WiFiName"
echo ------------------------------------------------------------
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
echo ============================================================
echo                   Temp File Cleaner
echo ============================================================
echo Temp Folder     : %tempDir%
echo Total Files     : %tempFilesCount%
echo Used Space      : %tempSizeMB% MB
echo ------------------------------------------------------------
set /p deleteTemp=Delete all temp files? (Y/N): 
if /i "%deleteTemp%"=="Y" (
    del /f /q "%tempDir%\*" >nul 2>&1
    echo Temp files deleted.
) else (
    echo Operation cancelled.
)
pause
goto menu

:checkUpdates
cls
curl -s -o "%TEMP%\network-tools-updated.bat" "https://raw.githubusercontent.com/BearKingX/network/main/network-tools.bat"
if exist "%TEMP%\network-tools-updated.bat" (
    copy /y "%TEMP%\network-tools-updated.bat" "%~f0" >nul
    echo Update applied successfully!
) else (
    echo Failed to download update.
)
pause
goto menu

:publicIP
cls
echo Public IP Address:
powershell -Command "(Invoke-WebRequest -uri 'https://api.ipify.org').Content"
pause
goto menu

:speedTest
cls
echo Running Speed Test (requires PowerShell + internet)...
powershell -Command "Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py')"
pause
goto menu

:pingTest
cls
ping 8.8.8.8 -n 4
pause
goto menu

:netConnections
cls
netstat -an | findstr /R "^ *TCP ^ *UDP"
pause
goto menu

:wifiProfiles
cls
netsh wlan show profiles
echo ------------------------------------------------------------
set /p profile=Enter profile name to view password: 
netsh wlan show profile name="%profile%" key=clear | findstr "SSID Key"
pause
goto menu

:adapterStatus
cls
netsh interface show interface
pause
goto menu

:flushARP
cls
arp -d *
echo ARP cache flushed.
pause
goto menu

:traceRoute
cls
tracert google.com
pause
goto menu
"""

menu_script[:1000]  # show only first part since it's long

