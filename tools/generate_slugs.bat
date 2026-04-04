@echo off
setlocal EnableDelayedExpansion

:: TamrielKR slug generation script
:: Usage: generate_slugs.bat [slugfont.exe path]
::
:: Example:
::   generate_slugs.bat "C:\...\game\client\slugfont.exe"

set "SLUGFONT=%~1"
set "OUTDIR=%~dp0..\fonts"
set "KRFONTDIR=%~dp0..\..\폰트"
set "DEFAULT_SLUGFONT=C:\Program Files (x86)\Steam\steamapps\common\Zenimax Online\The Elder Scrolls Online\game\client\slugfont.exe"

if "%SLUGFONT%"=="" (
    set "SLUGFONT=!DEFAULT_SLUGFONT!"
)

if not exist "%SLUGFONT%" (
    echo slugfont.exe not found: %SLUGFONT%
    echo Example: generate_slugs.bat "C:\...\game\client\slugfont.exe"
    exit /b 1
)

set "MARUBURI_SEMIBOLD=%KRFONTDIR%\마루 부리\MaruBuriOTF\MaruBuri-SemiBold.otf"
set "JALNAN=%KRFONTDIR%\여기어때 잘난체\JalnanGothic.otf"

if not exist "%MARUBURI_SEMIBOLD%" (
    echo Missing font: %MARUBURI_SEMIBOLD%
    exit /b 1
)

if not exist "%JALNAN%" (
    echo Missing font: %JALNAN%
    exit /b 1
)

echo [TamrielKR] Generating slug fonts
echo [TamrielKR] Base font: MaruBuri SemiBold
echo [TamrielKR] Title font: Jalnan Gothic
echo [TamrielKR] Output directory: %OUTDIR%
echo.

:: MaruBuri SemiBold - primary slugs
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\ftn47.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\ftn57.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\proseantiquepsmt.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\univers47.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\univers55.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\univers57.slug"

:: MaruBuri SemiBold - Korean backup slugs
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\kr_maruburi.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\kr_gothic.slug"
call :generate "%MARUBURI_SEMIBOLD%" "%OUTDIR%\kr_gothic_bold.slug"

:: Jalnan Gothic - title/emphasis
call :generate "%JALNAN%" "%OUTDIR%\ftn87.slug"
call :generate "%JALNAN%" "%OUTDIR%\kr_jalnan.slug"

echo.
echo [TamrielKR] Done! Generated 11 slug fonts.
exit /b 0

:generate
if not exist "%~1" (
    echo Missing source font: %~1
    exit /b 1
)

"%SLUGFONT%" "%~1" -o "%~2"
if errorlevel 1 (
    echo Failed to generate: %~2
    exit /b 1
)
echo   OK: %~2
exit /b 0
