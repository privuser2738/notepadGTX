@echo off
REM Build script for notepadGTX Windows GUI Release
REM Run this script on a Windows machine

echo ==============================================
echo   notepadGTX Windows GUI Release Builder
echo ==============================================
echo.

REM Clean previous builds
echo [1/4] Cleaning previous Windows GUI builds...
if exist dist\win-unpacked rmdir /s /q dist\win-unpacked
if exist dist\*.exe del /q dist\*.exe
if exist dist\notepadGTX-windows-release rmdir /s /q dist\notepadGTX-windows-release
mkdir dist\notepadGTX-windows-release

REM Install dependencies if needed
if not exist node_modules (
    echo [2/4] Installing dependencies...
    call npm install
) else (
    echo [2/4] Dependencies already installed
)

REM Build Windows GUI
echo [3/4] Building Windows GUI application...
echo   This may take several minutes on first build...
echo.

call npm run build:gui:windows

REM Organize the release files
echo [4/4] Organizing release files...

REM Copy installer files
if exist dist\notepadGTX*.exe (
    copy dist\notepadGTX*.exe dist\notepadGTX-windows-release\ >nul 2>&1
    echo   - Copied Windows installers/portable exe
)

REM Copy unpacked directory
if exist dist\win-unpacked (
    xcopy /E /I /Y dist\win-unpacked dist\notepadGTX-windows-release\notepadGTX-unpacked >nul 2>&1
    echo   - Copied unpacked application
)

REM Copy documentation
echo   - Copying documentation...
copy README.md dist\notepadGTX-windows-release\ >nul 2>&1
copy SHORTCUTS.md dist\notepadGTX-windows-release\ >nul 2>&1
copy QUICKSTART.md dist\notepadGTX-windows-release\ >nul 2>&1

REM Create README
echo notepadGTX for Windows - GUI Release > dist\notepadGTX-windows-release\README-WINDOWS-RELEASE.txt
echo ===================================== >> dist\notepadGTX-windows-release\README-WINDOWS-RELEASE.txt
echo. >> dist\notepadGTX-windows-release\README-WINDOWS-RELEASE.txt
echo Installation: Run the notepadGTX installer or portable exe >> dist\notepadGTX-windows-release\README-WINDOWS-RELEASE.txt
echo See README.md for full documentation >> dist\notepadGTX-windows-release\README-WINDOWS-RELEASE.txt

echo.
echo ==============================================
echo   Windows GUI Build Complete!
echo ==============================================
echo.
echo Output directory: dist\notepadGTX-windows-release\
echo.
dir /B dist\notepadGTX-windows-release\*.exe
echo.
echo To distribute: Zip the notepadGTX-windows-release folder
echo.
pause
