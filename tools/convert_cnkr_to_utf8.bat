@echo off
setlocal

echo ============================================
echo   EsoKR CJK to UTF-8 Korean Converter
echo ============================================
echo.

:: Find kr.lang
set "INPUT="
if exist "%~dp0kr.lang" set "INPUT=%~dp0kr.lang"
if exist "%~dp0..\kr.lang" set "INPUT=%~dp0..\kr.lang"
if exist "%cd%\kr.lang" set "INPUT=%cd%\kr.lang"

if "%INPUT%"=="" (
    echo [!] kr.lang not found.
    echo.
    echo     Put kr.lang in the same folder as this bat file.
    echo.
    pause
    exit /b 1
)

echo [1/2] Converting: %INPUT%
echo.

:: Try python, then py launcher
python "%~dp0convert_cnkr_to_utf8.py" "%INPUT%" "%INPUT%" 2>nul
if %errorlevel% equ 0 goto done

py "%~dp0convert_cnkr_to_utf8.py" "%INPUT%" "%INPUT%" 2>nul
if %errorlevel% equ 0 goto done

py -3 "%~dp0convert_cnkr_to_utf8.py" "%INPUT%" "%INPUT%" 2>nul
if %errorlevel% equ 0 goto done

echo [!] Python is not installed.
echo.
echo     Install Python from https://www.python.org/downloads/
echo     Make sure to check "Add to PATH" during installation.
echo.
pause
exit /b 1

:done
echo.
echo [2/2] Done! kr.lang has been converted to UTF-8.
echo       Copy this file to: AddOns\gamedata\lang\
echo.
pause
