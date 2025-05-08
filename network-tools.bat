@echo off
setlocal enabledelayedexpansion
mode con: cols=100 lines=3000

:: Predefined string of spaces for padding output (100 spaces)
set "sp=                                                                                                "

:strlen
set "s=%~1"
set "len=0"
:strlen_loop
if defined s (
    set "s=!s:~1!"
    set /a len+=1
    goto strlen_loop
)
set %2=%len%
exit /b

:mainMenu
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                   Network Utility Tool (v1.0)                                    ^|
echo +--------------------------------------------------------------------------------------------------+
echo ^| 1. View System Info                                                                              ^|
echo ^| 2. Reset Network                                                                                 ^|
echo ^| 3. Manage Temp Files                                                                             ^|
echo ^| 4. Ping Host                                                                                     ^|
echo ^| 5. View Active Connections                                                                       ^|
echo ^| 6. Wi-Fi Profiles & Passwords                                                                    ^|
echo ^| 7. Check for Updates                                                                             ^|
echo ^| 8. Other Tools                                                                                   ^|
echo ^| 9. Exit                                                                                          ^|
echo +--------------------------------------------------------------------------------------------------+
set /p choice="Enter your choice: "

if "%choice%"=="1" goto sysinfo
if "%choice%"=="2" goto resetnet
if "%choice%"=="3" goto managetemp
if "%choice%"=="4" goto pinghost
if "%choice%"=="5" goto conn
if "%choice%"=="6" goto wifilist
if "%choice%"=="7" goto checkupdates
if "%choice%"=="8" goto othertools
if "%choice%"=="9" goto exit
echo Invalid choice. Press any key to try again...
pause >nul
goto mainMenu

:sysinfo
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                  System Information                                           ^|
echo +--------------------------------------------------------------------------------------------------+
for /f "tokens=2,* delims=:" %%A in ('systeminfo ^| findstr /B /C:"OS Name:"') do set "OSName=%%B"
for /f "tokens=2,* delims=:" %%A in ('systeminfo ^| findstr /B /C:"OS Version:"') do set "OSVer=%%B"
for /f "tokens=2,* delims=:" %%A in ('systeminfo ^| findstr /B /C:"System Type:"') do set "SysType=%%B"
for /f "tokens=2,* delims=:" %%A in ('systeminfo ^| findstr /B /C:"Total Physical Memory:"') do set "PhysMem=%%B"
for %%V in (" OS Name: !OSName!" " OS Version: !OSVer!" " System Type: !SysType!" " Total Physical Memory: !PhysMem!") do (
    set "line=%%~V"
    call :strlen "!line!" len
    set /a pad=98-len
    if !pad! lss 0 set pad=0
    set "spaces=!sp:~0,%pad%!"
    echo ^|!line!!spaces!^|
)
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:resetnet
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                        Network Reset                                          ^|
echo +--------------------------------------------------------------------------------------------------+
echo Releasing IP addresses...
ipconfig /release >nul 2>&1
if errorlevel 1 (
  echo Error releasing IP addresses. Please check your network adapters.
  pause
  goto mainMenu
) else (
  echo IP addresses released successfully.
)
echo Renewing IP addresses...
ipconfig /renew >nul 2>&1
if errorlevel 1 (
  echo Error renewing IP addresses. Please ensure network connectivity.
  pause
  goto mainMenu
) else (
  echo IP addresses renewed successfully.
)
echo Resetting Winsock Catalog...
netsh winsock reset >nul 2>&1
if errorlevel 1 (
  echo Winsock reset failed.
) else (
  echo Winsock reset succeeded.
)
echo Resetting TCP/IP Stack...
netsh int ip reset >nul 2>&1
if errorlevel 1 (
  echo TCP/IP reset failed.
) else (
  echo TCP/IP stack reset succeeded.
)
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:managetemp
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                 Manage Temporary Files                                       ^|
echo +--------------------------------------------------------------------------------------------------+
echo Cleaning User Temp folder...
del /f /s /q "%temp%\*" >nul 2>&1
if errorlevel 1 (
  echo Error occurred while cleaning user temp files.
) else (
  echo User temp files deleted successfully.
)
echo Cleaning Windows Temp folder...
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
if errorlevel 1 (
  echo Error occurred while cleaning system temp files.
) else (
  echo System temp files deleted successfully.
)
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:pinghost
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                         Ping Host                                             ^|
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Enter host name or IP address to ping:
set /p host=Host/IP: 
echo Pinging %host% (4 packets)...
ping -n 4 %host%
if errorlevel 1 (
  echo Ping failed or host unreachable.
) else (
  echo Ping successful.
)
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:conn
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                         Active Connections (ESTABLISHED)                                    ^|
echo +--------------------------------------------------------------------------------------------------+
echo Listing active TCP connections...
netstat -an | findstr "ESTABLISHED"
if errorlevel 1 echo No established connections found or command failed.
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:wifilist
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                         Wi-Fi Profiles and Passwords                                        ^|
echo +--------------------------------------------------------------------------------------------------+
for /f "tokens=2,* delims=:" %%A in ('netsh wlan show interfaces ^| findstr /C:" SSID" ^| findstr /V "BSSID"') do set "currSSID=%%B"
if defined currSSID (
  set "line= Current Wi-Fi SSID: !currSSID!"
  call :strlen "!line!" len
  set /a pad=98-len
  if !pad! lss 0 set pad=0
  set "spaces=!sp:~0,%pad%!"
  echo ^|!line!!spaces!^|
)
echo +--------------------------------------------------------------------------------------------------+
for /f "tokens=2,* delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
  set "profile=%%B"
  set "line= Profile Name: !profile!"
  call :strlen "!line!" len
  set /a pad=98-len
  if !pad! lss 0 set pad=0
  set "spaces=!sp:~0,%pad%!"
  echo ^|!line!!spaces!^|
  for /f "tokens=2,* delims=:" %%C in ('netsh wlan show profile name^="%%B" key=clear ^| findstr "Key Content"') do (
    set "pass=%%D"
    set "line= Password: !pass!"
    call :strlen "!line!" plen
    set /a pad=98-plen
    if !pad! lss 0 set pad=0
    set "spaces=!sp:~0,%pad%!"
    echo ^|!line!!spaces!^|
  )
)
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:checkupdates
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                   Check for Updates                                          ^|
echo +--------------------------------------------------------------------------------------------------+
echo Checking internet connectivity...
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
  echo No internet connection. Cannot check updates.
) else (
  echo Internet is available.
)
echo.
echo Please use Windows Update from Settings or Control Panel to check for system updates.
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:othertools
cls
echo +--------------------------------------------------------------------------------------------------+
echo ^|                                  Other Network Tools                                        ^|
echo +--------------------------------------------------------------------------------------------------+
echo Flushing DNS resolver cache...
ipconfig /flushdns >nul 2>&1
if errorlevel 1 (
  echo Failed to flush DNS cache.
) else (
  echo DNS cache flushed successfully.
)
echo.
echo Displaying IP configuration...
ipconfig
echo.
echo Displaying ARP Table...
arp -a
echo +--------------------------------------------------------------------------------------------------+
echo.
echo Press any key to return to Main Menu...
pause >nul
goto mainMenu

:exit
echo Exiting Network Utility Tool. Goodbye!
exit
