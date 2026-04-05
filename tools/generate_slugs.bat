@echo off
setlocal EnableDelayedExpansion

:: TamrielKR slug generation script
:: Usage: generate_slugs.bat [slugfont.exe path]
::
:: Example:
::   generate_slugs.bat "C:\...\game\client\slugfont.exe"

set "SLUGFONT=%~1"
set "OUTDIR=%~dp0..\fonts"
set "KRFONTDIR=%~dp0..\폰트"
set "DEFAULT_SLUGFONT=C:\Program Files (x86)\Steam\steamapps\common\Zenimax Online\The Elder Scrolls Online\game\client\slugfont.exe"

if "%SLUGFONT%"=="" (
    set "SLUGFONT=!DEFAULT_SLUGFONT!"
)

if not exist "%SLUGFONT%" (
    echo slugfont.exe not found: %SLUGFONT%
    echo Example: generate_slugs.bat "C:\...\game\client\slugfont.exe"
    exit /b 1
)

set "MARUBURI_SEMIBOLD=%KRFONTDIR%\마루 부리\MaruBuriOTF\MaruBuri-Bold.otf"
set "MARUBURI_CNKR=%KRFONTDIR%\MaruBuri-CNKR.otf"
set "JALNAN=%KRFONTDIR%\여기어때 잘난체\JalnanGothic.otf"
set "JALNAN_CNKR=%KRFONTDIR%\JalnanGothic-CNKR.otf"

if not exist "%MARUBURI_SEMIBOLD%" (
    echo Missing font: %MARUBURI_SEMIBOLD%
    exit /b 1
)

if not exist "%JALNAN%" (
    echo Missing font: %JALNAN%
    exit /b 1
)

:: Generate CNKR fonts if not exists (Korean glyphs at CJK codepoints for Bridge compatibility)
if not exist "%MARUBURI_CNKR%" (
    echo [TamrielKR] Generating MaruBuri CNKR font...
    python "%~dp0generate_cnkr_font.py" "%MARUBURI_SEMIBOLD%" "%MARUBURI_CNKR%"
    if errorlevel 1 (
        echo Failed to generate CNKR font. Using original MaruBuri.
        set "MARUBURI_CNKR=%MARUBURI_SEMIBOLD%"
    )
)

if not exist "%JALNAN_CNKR%" (
    echo [TamrielKR] Generating Jalnan CNKR font...
    python "%~dp0generate_cnkr_font.py" "%JALNAN%" "%JALNAN_CNKR%"
    if errorlevel 1 (
        echo Failed to generate CNKR font. Using original Jalnan.
        set "JALNAN_CNKR=%JALNAN%"
    )
)

echo [TamrielKR] Generating slug fonts
echo [TamrielKR] Base font: MaruBuri Bold (CNKR)
echo [TamrielKR] Title font: Jalnan Gothic
echo [TamrielKR] Output directory: %OUTDIR%
echo.

:: MaruBuri CNKR - primary slugs (CJK codepoints에 한글 글리프 포함)
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\ftn47.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\ftn57.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\proseantiquepsmt.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\univers47.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\univers55.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\univers57.slug"

:: MaruBuri CNKR - Korean backup slugs
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\kr_maruburi.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\kr_gothic.slug"
call :generate "%MARUBURI_CNKR%" "%OUTDIR%\kr_gothic_bold.slug"

:: Jalnan Gothic CNKR - title/emphasis (CJK 코드포인트에 한글 글리프 포함)
call :generate "%JALNAN_CNKR%" "%OUTDIR%\ftn87.slug"
call :generate "%JALNAN_CNKR%" "%OUTDIR%\kr_jalnan.slug"

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
