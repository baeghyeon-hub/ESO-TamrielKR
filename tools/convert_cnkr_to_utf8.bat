@echo off
chcp 65001 >nul 2>&1

echo ============================================
echo   EsoKR CJK → UTF-8 한글 변환기
echo ============================================
echo.

:: kr.lang 찾기
set "INPUT="
if exist "%~dp0kr.lang" set "INPUT=%~dp0kr.lang"
if exist "%~dp0..\kr.lang" set "INPUT=%~dp0..\kr.lang"
if exist "%cd%\kr.lang" set "INPUT=%cd%\kr.lang"

if "%INPUT%"=="" (
    echo [!] kr.lang 파일을 찾을 수 없습니다.
    echo.
    echo     이 bat 파일과 같은 폴더에 kr.lang 을 넣어주세요.
    echo.
    pause
    exit /b 1
)

echo [1/2] 변환 중: %INPUT%
echo.

python "%~dp0convert_cnkr_to_utf8.py" "%INPUT%" "%INPUT%" 2>nul
if %errorlevel% equ 0 (
    echo.
    echo [2/2] 완료! kr.lang 이 UTF-8로 변환되었습니다.
    echo       이 파일을 AddOns\gamedata\lang\ 에 넣어주세요.
) else (
    echo [!] Python이 설치되어 있지 않습니다.
    echo.
    echo     https://www.python.org/downloads/ 에서 Python을 설치하고
    echo     다시 실행해주세요. (설치 시 "Add to PATH" 체크)
)

echo.
pause
