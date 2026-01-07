@echo off
setlocal enableDelayedExpansion

REM ##########################################################################
REM #    BATCH BACKUP SCRIPT (WINRAR AUTOMATION)                             #
REM ##########################################################################

REM --- Define Core Variables (Customize These Paths!) ---
REM Make sure this points to Rar.exe (Console version) or WinRAR.exe
set "WINRAR_PATH=C:\temp\Deleteme\programs\winRAR\Rar.exe"

REM --- FIXED MAIN BACKUP ROOT DESTINATION ---
set "BACKUP_DESTINATION=C:\temp\Deleteme\backups7z"

REM --- LOG FILE LOCATION ---
set "LOG_FILE=%BACKUP_DESTINATION%\_BackupLog.txt"

REM --------------------------------------------------------------------------
REM --- Dynamic Folder Setup (Portable) ---
set "SCRIPT_ROOT=%~dp0"
set "LIST_FOLDER=%SCRIPT_ROOT%Scripts\"
set "EXCLUSION_FOLDER=%SCRIPT_ROOT%Exclusions\"

REM --- CRITICAL VALIDATION CHECKS ---
if not exist "%WINRAR_PATH%" (
    echo.
    echo [CRITICAL ERROR] WinRAR executable not found at:
    echo "%WINRAR_PATH%"
    echo.
    pause
    goto :EOF
)

if not exist "%LIST_FOLDER%" (
    echo.
    echo [CRITICAL ERROR] Profile list folder not found at:
    echo "%LIST_FOLDER%"
    echo.
    pause
    goto :EOF
)

if not exist "%EXCLUSION_FOLDER%" (
    echo [INFO] Exclusion folder missing. Creating: "%EXCLUSION_FOLDER%"
    mkdir "%EXCLUSION_FOLDER%"
)

REM --------------------------------------------------------------------------
REM --- MENU: SELECT PROFILE ---
REM --------------------------------------------------------------------------
:BUILD_PROFILE_MENU
cls
echo =========================================================================
echo   SELECT BACKUP PROFILE
echo =========================================================================

set "count=0"
REM Clear previous arrays
for /L %%i in (1,1,100) do (
    set "file_paths[%%i]="
    set "file_names[%%i]="
)

REM Scan folder for .txt files
for %%f in ("%LIST_FOLDER%*.txt") do (
    set /A count+=1
    set "file_paths[!count!]=%%f"
    set "file_names[!count!]=%%~nf"
    echo   [!count!] %%~nf
)

if "%count%"=="0" (
    echo.
    echo [ERROR] No .txt files found in "%LIST_FOLDER%".
    pause
    goto :EOF
)

echo.
echo   [Q] Quit
echo =========================================================================

:GET_PROFILE_CHOICE
set "PROFILE_CHOICE="
set /p "PROFILE_CHOICE=Enter selection (1-%count%): "

if /i "%PROFILE_CHOICE%"=="Q" goto :EOF

REM Validate Input
if not defined file_paths[%PROFILE_CHOICE%] (
    echo Invalid choice. Try again.
    goto GET_PROFILE_CHOICE
)

set "SELECTED_LIST=!file_paths[%PROFILE_CHOICE%]!"
set "PROFILE_NAME=!file_names[%PROFILE_CHOICE%]!"

REM --- Check Exclusions ---
set "PROFILE_EXCLUSION_FILE=%EXCLUSION_FOLDER%!PROFILE_NAME!_exclusion.txt"
set "EXCLUSION_COMMAND="
set "USE_EXCLUSIONS_TEXT=NO"

if exist "!PROFILE_EXCLUSION_FILE!" (
    set "EXCLUSION_COMMAND=-x@!PROFILE_EXCLUSION_FILE!"
    set "USE_EXCLUSIONS_TEXT=YES"
)

REM --------------------------------------------------------------------------
REM --- MENU: SELECT BACKUP TYPE ---
REM --------------------------------------------------------------------------
:BUILD_TYPE_MENU
cls
echo =========================================================================
echo   PROFILE: %PROFILE_NAME%
echo   EXCLUSIONS: %USE_EXCLUSIONS_TEXT%
echo =========================================================================
echo   [1] INCREMENTAL (New/Changed files only)
echo   [2] FULL        (Archive all files)
echo   [Q] Back to Profile Menu
echo =========================================================================

:GET_TYPE_CHOICE
set "TYPE_CHOICE="
set /p "TYPE_CHOICE=Select Type: "

if /i "%TYPE_CHOICE%"=="Q" goto BUILD_PROFILE_MENU

if "%TYPE_CHOICE%"=="1" (
    set "BACKUP_TYPE=INCREMENTAL"
    REM -ao: Add files with Archive attribute set
    REM -ac: Clear Archive attribute after backup (resets the flag for next time)
    set "WINRAR_FLAGS=-m5 -ep1 -ao -ac -rr5p -agYYYYMMDD-HHMMSS %EXCLUSION_COMMAND%"
    set "FILE_PREFIX=Incremental"
) else if "%TYPE_CHOICE%"=="2" (
    set "BACKUP_TYPE=FULL"
    set "WINRAR_FLAGS=-m5 -ep1 -rr5p -agYYYYMMDD-HHMMSS %EXCLUSION_COMMAND%"
    set "FILE_PREFIX=Full"
) else (
    goto GET_TYPE_CHOICE
)

set "FILENAME=%FILE_PREFIX%Backup_%PROFILE_NAME%_.rar"
set "FINAL_DESTINATION=%BACKUP_DESTINATION%\%PROFILE_NAME%"

REM Create Destination
if not exist "%FINAL_DESTINATION%" mkdir "%FINAL_DESTINATION%"

REM --------------------------------------------------------------------------
REM --- EXECUTE BACKUP ---
REM --------------------------------------------------------------------------
cls
echo.
echo =========================================================================
echo   STARTING WINRAR...
echo   Profile: %PROFILE_NAME%
echo   Type:    %BACKUP_TYPE%
echo =========================================================================
echo.

REM Execute WinRAR
"%WINRAR_PATH%" a %WINRAR_FLAGS% "%FINAL_DESTINATION%\%FILENAME%" @"%SELECTED_LIST%"

set "RAR_EXIT_CODE=%ERRORLEVEL%"

REM --------------------------------------------------------------------------
REM --- POST-BACKUP ANALYSIS ---
REM --------------------------------------------------------------------------
echo.
echo =========================================================================

if "%RAR_EXIT_CODE%"=="0" (
    echo   [SUCCESS] Archive created successfully.
    
    REM Log Success
    echo %DATE% %TIME% | Success | %PROFILE_NAME% | %BACKUP_TYPE% >> "%LOG_FILE%"

    REM Find the file just created
    set "ACTUAL_FILENAME="
    for /f "delims=" %%i in ('dir /b /a-d /od "%FINAL_DESTINATION%\*.rar" 2^>nul') do (
        set "ACTUAL_FILENAME=%%i"
    )

    if defined ACTUAL_FILENAME (
        echo   File: !ACTUAL_FILENAME!
        echo   Opening folder...
        explorer.exe "%FINAL_DESTINATION%"
    )
) else (
    echo   [FAILURE] WinRAR returned Error Code: %RAR_EXIT_CODE%
    
    REM Log Failure
    echo %DATE% %TIME% | FAILURE | %PROFILE_NAME% | Error Code %RAR_EXIT_CODE% >> "%LOG_FILE%"
    
    if "%RAR_EXIT_CODE%"=="1" echo   (Warning: Non-fatal error(s) occurred)
    if "%RAR_EXIT_CODE%"=="2" echo   (Fatal error: Write error or disk full)
)

echo =========================================================================
echo.
pause
goto :EOF