@echo off
chcp 1251 >nul
setlocal EnableDelayedExpansion

mode con: cols=80 lines=20
title PIC MCU Backup (+erase EEPROM) >nul

:: =========================================================================================================
::  pk2_backup_and_clear_eeprom.bat
::  1. Detects the microcontroller connected via PICkit2/3/PKOB
::  2. Saves a full memory dump (backup) to a .hex file next to the
::     script (the file name is requested from the user; if left
::     empty, it defaults to <chip>_<timestamp>.hex)
::  3. Clears ONLY the EEPROM (Program Memory and Config bits are
::     left untouched)
::
::  Uses pk2cmd: https://github.com/jaka-fi/pk2cmd
::  Place pk2cmd.exe and PK2DeviceFile.dat in the same folder as this
::  bat file (or add pk2cmd.exe to PATH).
:: =========================================================================================================

set "PK2DIR=%~dp0"
set "PK2CMD=%PK2DIR%pk2cmd.exe"
set "BLANKHEX=%PK2DIR%_blank.hex"

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

:: --- "Blank" hex file: EOF record only, no data.                    ---
:: --- It's required because pk2cmd needs -F for any program command, ---
:: --- and any address not present in the file is programmed blank.  ---
> "%BLANKHEX%" echo :00000001FF

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

del "%DETECTLOG%" >nul 2>&1

if not "%DETECT_ERR%"=="0" (
    echo.
    echo [ERROR] Could not detect the microcontroller.
	echo.
    echo Check that the PICkit programmer and the target board are connected.
	echo.
    del "%BLANKHEX%" >nul 2>&1
    pause
    exit /b 1
)

if not defined CHIPNAME set "CHIPNAME=unknown"
echo Detected MCU: %CHIPNAME%

:: --- Ask the user for the backup file name ---
echo.
set "BACKUPNAME="
set /p "BACKUPNAME=Enter the backup file name (leave empty for auto name): "

if "%BACKUPNAME%"=="" (
    :: --- No name entered - build one from chip name + timestamp ---
    for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "TS=%%T"
    if not defined TS set "TS=nodate"
    set "BACKUPNAME=!CHIPNAME!_!TS!"
    echo No name entered, using: !BACKUPNAME!.hex
)

:: --- Append .hex if the name doesn't already end with it ---
if /i not "%BACKUPNAME:~-4%"==".hex" set "BACKUPNAME=%BACKUPNAME%.hex"

set "BACKUPFILE=%PK2DIR%%BACKUPNAME%"

:: --- Step 2: firmware backup (full memory: Program + Config + EEPROM) ---
echo.
echo ================================================================================
echo   Step 2: saving the backup
echo ================================================================================
echo File: %BACKUPFILE%

set "BACKUPLOG=%TEMP%\pk2_backup.log"
"%PK2CMD%" /P /GF"%BACKUPFILE%" > "%BACKUPLOG%" 2>&1
set "BACKUP_ERR=%ERRORLEVEL%"
findstr /V /C:"Auto-Detect" "%BACKUPLOG%"
del "%BACKUPLOG%" >nul 2>&1

if not "%BACKUP_ERR%"=="0" (
    echo.
    echo [ERROR] Backup failed. EEPROM clearing CANCELLED.
	echo.
    del "%BLANKHEX%" >nul 2>&1
    pause
    exit /b 1
)

if not exist "%BACKUPFILE%" (
    echo.
    echo [ERROR] Backup file was not created. EEPROM clearing CANCELLED.
	echo.
    del "%BLANKHEX%" >nul 2>&1
    pause
    exit /b 1
)

for %%F in ("%BACKUPFILE%") do set "BSIZE=%%~zF"
if "%BSIZE%"=="0" (
    echo.
    echo [ERROR] Backup file is empty. EEPROM clearing CANCELLED.
	echo.
    del "%BLANKHEX%" >nul 2>&1
    pause
    exit /b 1
)

echo.
echo Backup saved successfully (%BSIZE% bytes^): %BACKUPFILE%

:: --- Confirmation before an irreversible operation ---
echo.
choice /M "Clear the EEPROM (Program Memory and Config bits will stay untouched)"
if errorlevel 2 (
    echo Operation cancelled by user. Backup has been saved.
	echo.
    del "%BLANKHEX%" >nul 2>&1
    pause
    exit /b 0
)

:: --- Step 3: clear ONLY the EEPROM ---
echo.
echo ================================================================================
echo   Step 3: clearing EEPROM (/ME)
echo ================================================================================
set "ERASELOG=%TEMP%\pk2_erase.log"
"%PK2CMD%" /P /F"%BLANKHEX%" /ME > "%ERASELOG%" 2>&1
set "ERASE_ERR=%ERRORLEVEL%"
findstr /V /C:"Auto-Detect" "%ERASELOG%"
del "%ERASELOG%" >nul 2>&1
del "%BLANKHEX%" >nul 2>&1

if not "%ERASE_ERR%"=="0" (
    echo.
    echo [ERROR] EEPROM clearing failed ^(code %ERASE_ERR%^).
    echo This MCU may not have an EEPROM data area accessible via -ME.
    echo Backup is available at: %BACKUPFILE%
	echo.
    pause
    exit /b 1
)

echo.
echo Done! EEPROM has been cleared, Program Memory and Config bits are untouched.
echo Backup: %BACKUPFILE%
echo.
pause
exit /b 0