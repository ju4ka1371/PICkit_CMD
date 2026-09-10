@echo off
chcp 1251 >nul
setlocal EnableDelayedExpansion

mode con: cols=80 lines=20
title PIC MCU Flash >nul

:: =====================================================================
::  Flash.bat
::  Drag & drop a .hex file onto this script to program it into the
::  microcontroller connected via PICkit2/3/PKOB.
::
::  1. Detects the microcontroller
::  2. Programs the dropped .hex file into the device
::     (the whole device is erased & programmed, as with normal
::     pk2cmd -M behaviour with no memory region specified)
::
::  Uses pk2cmd: https://github.com/jaka-fi/pk2cmd
::  Place pk2cmd.exe and PK2DeviceFile.dat in the same folder as this
::  bat file (or add pk2cmd.exe to PATH).
:: =====================================================================

set "PK2DIR=%~dp0"
set "PK2CMD=%PK2DIR%pk2cmd.exe"

:: --- Check that pk2cmd.exe is available ---
if not exist "%PK2CMD%" (
    where pk2cmd.exe >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] pk2cmd.exe was not found next to the script or in PATH.
		echo.
        echo Download it from https://github.com/jaka-fi/pk2cmd ^(Releases section^)
        echo and place pk2cmd.exe + PK2DeviceFile.dat in the script folder.
		echo.
        pause
        exit /b 1
    ) else (
        set "PK2CMD=pk2cmd.exe"
    )
)

:: --- Check that a file was dropped onto the script ---
if "%~1"=="" (
    echo.
    echo [ERROR] No file was provided.
	echo.
    echo Drag and drop a .hex file onto this script to flash it.
	echo.
    pause
    exit /b 1
)

set "HEXFILE=%~1"

:: --- Check the extension is .hex ---
if /i not "%~x1"==".hex" (
    echo.
    echo [ERROR] The dropped file is not a .hex file: %HEXFILE%
	echo.
    pause
    exit /b 1
)

if not exist "%HEXFILE%" (
    echo.
    echo [ERROR] File not found: %HEXFILE%
	echo.
    pause
    exit /b 1
)

echo.
echo ================================================================================
echo   Step 1: detecting the connected MCU
echo ================================================================================
set "DETECTLOG=%TEMP%\pk2_detect.log"

"%PK2CMD%" /P > "%DETECTLOG%" 2>&1
set "DETECT_ERR=%ERRORLEVEL%"

set "CHIPNAME="
for /f "tokens=4" %%A in ('findstr /C:"Auto-Detect: Found part" "%DETECTLOG%"') do set "CHIPNAME=%%A"
if defined CHIPNAME set "CHIPNAME=!CHIPNAME:.=!"

if not "%DETECT_ERR%"=="0" (
    echo.
    echo [ERROR] Could not detect the microcontroller.
	echo.
    echo pk2cmd said:
    findstr /V /C:"Auto-Detect" "%DETECTLOG%"
	echo.
    echo Check that the PICkit programmer and the target board are connected.
	echo.
    del "%DETECTLOG%" >nul 2>&1
    pause
    exit /b 1
)

del "%DETECTLOG%" >nul 2>&1

if not defined CHIPNAME set "CHIPNAME=unknown"
echo Detected MCU: %CHIPNAME%

echo.
echo File to flash: %HEXFILE%

:: --- Confirmation before an irreversible operation ---
echo.
choice /M "Erase the device and program this file"
if errorlevel 2 (
    echo Operation cancelled by user.
	echo.
    pause
    exit /b 0
)

:: --- Step 2: flash the device ---
echo.
echo ================================================================================
echo   Step 2: programming the device
echo ================================================================================
set "FLASHLOG=%TEMP%\pk2_flash.log"
"%PK2CMD%" /P /F"%HEXFILE%" /M /T /R > "%FLASHLOG%" 2>&1
set "FLASH_ERR=%ERRORLEVEL%"
findstr /V /C:"Auto-Detect" "%FLASHLOG%"
del "%FLASHLOG%" >nul 2>&1

if not "%FLASH_ERR%"=="0" (
    echo.
    echo [ERROR] Programming failed ^(code %FLASH_ERR%^).
	echo.
    pause
    exit /b 1
)

echo.
echo Done! Firmware programmed and verified successfully.
echo File: %HEXFILE%
echo.
pause
exit /b 0