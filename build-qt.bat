@ECHO OFF
COLOR
TITLE Configuring Qt
CLS
SETLOCAL EnableDelayedExpansion
REM x86 or x64, default is x64
SET "_TARGET_ARCH=%1"
REM dll or lib, default is dll
SET "_BUILD_TYPE=%2"
REM debug, release or debug-and-release, default is release
SET "_COMP_MODE=%3"
REM Qt source code directory, default is ".\src"
SET "_ROOT=%4"
REM Qt install directory, default is ".\qt"
SET "_INSTALL_DIR=%5"
REM Extra configure parameters, default is empty
SET "_EXTRA_PARAMS=%6"
IF /I "%_ROOT%" == "" SET "_ROOT=%~dp0src"
IF NOT EXIST "%_ROOT%" ECHO Qt source code directory not found. Cannot continue compiling. && GOTO Fin
IF /I "%_TARGET_ARCH%" == "" SET "_TARGET_ARCH=x64"
IF /I "%_COMP_MODE%" == "" SET "_COMP_MODE=release"
IF /I "%_BUILD_TYPE%" == "" SET "_BUILD_TYPE=dll"
IF /I "%_INSTALL_DIR%" == "" SET "_INSTALL_DIR=%~dp0qt-%_BUILD_TYPE%-%_COMP_MODE%-%_TARGET_ARCH%"
IF EXIST "%_INSTALL_DIR%" RD /S /Q "%_INSTALL_DIR%"
MD "%_INSTALL_DIR%"
IF /I "%_COMP_MODE%" == "debug" (
    SET "_COMP_MODE=-%_COMP_MODE%"
) ELSE (
    SET "_COMP_MODE=-%_COMP_MODE% -strip"
)
IF /I "%_BUILD_TYPE%" == "lib" (
    REM According to Qt official wiki, QWebEngine module cannot be compiled statically, so we have to skip it
    SET "_BUILD_TYPE=-static -static-runtime -skip qtwebengine"
) ELSE (
    REM If you want to compile QWebEngine, you have to change your system locale to English(United States)
    REM And don't forget to change it back after compiling Qt
    SET "_BUILD_TYPE=-shared"
)
SET "_VC_CMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_CMD%" SET "_VC_CMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_CMD%" SET "_VC_CMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_CMD%" SET "_VC_CMD=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
IF NOT EXIST "%_VC_CMD%" SET "_VC_CMD=C:\Program Files (x86)\Microsoft Visual Studio\Shared\14.0\VC\vcvarsall.bat"
IF NOT EXIST "%_VC_CMD%" ECHO Cannot find [vcvarsall.bat], if you didn't install vs in it's default location, please change this script. && GOTO Fin
SET _CFG_PARAMS=-opensource -confirm-license %_COMP_MODE% %_BUILD_TYPE% -platform win32-msvc -ltcg -plugin-manifests -mp -silent -nomake examples -nomake tests -opengl dynamic -prefix "%_INSTALL_DIR%" %_EXTRA_PARAMS%
SET "_CFG_BAT=%_ROOT%\configure.bat"
REM If you don't have jom, use nmake instead, which is provided by Visual Studio.
REM nmake is very slow, I recommend you use jom, you can download the latest jom
REM from it's official download link:
REM download.qt.io/official_releases/jom/jom.zip
REM Remember to add it's path to your system path variables
REM or just put it into "src\gnuwin32\bin", this directory will be added to
REM the PATH variable temporarily during the compiling process.
SET "_JOM=nmake"
IF EXIST "jom.exe" SET "_JOM=jom"
TITLE Configure finished
CLS
ECHO The configuring process have finished successfully
ECHO Your configuration is:
ECHO ---------------------------------------
ECHO Target architecture: %_TARGET_ARCH%
ECHO Source code directory: %_ROOT%
ECHO Install directory: %_INSTALL_DIR%
ECHO vcvarsall.bat: %_VC_CMD%
ECHO Build tool: %_JOM%
ECHO Qt configure parameters: %_CFG_PARAMS%
ECHO ---------------------------------------
ECHO If everything is all right, press any key to generate the build script
ECHO If anything is wrong, please close this window and re-run it
ECHO Your build script will be saved to: %~dp0build.bat
PAUSE
SET "_BUILD_BAT=%~dp0build.bat"
IF EXIST "%_BUILD_BAT%" DEL /F /Q "%_BUILD_BAT%"
ECHO @ECHO OFF>"%_BUILD_BAT%"
ECHO COLOR>>"%_BUILD_BAT%"
ECHO TITLE Building Qt from source code>>"%_BUILD_BAT%"
ECHO CLS>>"%_BUILD_BAT%"
ECHO SETLOCAL>>"%_BUILD_BAT%"
ECHO CALL "%_VC_CMD%" %_TARGET_ARCH%>>"%_BUILD_BAT%"
ECHO SET "_ROOT=%_ROOT%">>"%_BUILD_BAT%"
ECHO SET "PATH=%%_ROOT%%\qtbase\bin;%%_ROOT%%\gnuwin32\bin;%%PATH%%">>"%_BUILD_BAT%"
ECHO SET _ROOT=>>"%_BUILD_BAT%"
ECHO CD /D "%_ROOT%">>"%_BUILD_BAT%"
ECHO CALL "%_CFG_BAT%" %_CFG_PARAMS%>>"%_BUILD_BAT%"
ECHO IF %%ERRORLEVEL%% NEQ 0 GOTO ErrHappen>>"%_BUILD_BAT%"
ECHO %_JOM%>>"%_BUILD_BAT%"
ECHO IF %%ERRORLEVEL%% NEQ 0 GOTO ErrHappen>>"%_BUILD_BAT%"
ECHO %_JOM% install>>"%_BUILD_BAT%"
ECHO IF %%ERRORLEVEL%% NEQ 0 GOTO ErrHappen>>"%_BUILD_BAT%"
ECHO TITLE Compiling process finished>>"%_BUILD_BAT%"
ECHO ECHO Compiling process have finished successfully>>"%_BUILD_BAT%"
ECHO ECHO All binaries have been installed to: %_INSTALL_DIR%>>"%_BUILD_BAT%"
ECHO ECHO Press any key to exit this program>>"%_BUILD_BAT%"
ECHO GOTO Fin>>"%_BUILD_BAT%"
ECHO :ErrHappen>>"%_BUILD_BAT%"
ECHO TITLE Compiling process aborted>>"%_BUILD_BAT%"
ECHO ECHO Something wrong happened during the compiling process>>"%_BUILD_BAT%"
ECHO ECHO and the process have aborted because of this>>"%_BUILD_BAT%"
ECHO ECHO Please check the log file for more information>>"%_BUILD_BAT%"
ECHO ECHO Press any key to exit this program>>"%_BUILD_BAT%"
ECHO GOTO Fin>>"%_BUILD_BAT%"
ECHO :Fin>>"%_BUILD_BAT%"
ECHO ENDLOCAL>>"%_BUILD_BAT%"
ECHO PAUSE>>"%_BUILD_BAT%"
ECHO EXIT /B>>"%_BUILD_BAT%"
CLS
ECHO Build script have been saved to: %_BUILD_BAT%
ECHO Press any key to run it, or you can close this window and run it manually
PAUSE
CALL "%_BUILD_BAT%"
GOTO Fin

:Fin
ENDLOCAL
PAUSE
EXIT /B
