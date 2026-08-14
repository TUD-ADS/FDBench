@echo off
setlocal enabledelayedexpansion

echo Running case: %cd%

REM -------------------------------------------------------------------
REM 1. Load Vivado environment
REM -------------------------------------------------------------------
call "C:\Xilinx\Vivado\2022.2\settings64.bat"

REM -------------------------------------------------------------------
REM 2. Run Vivado batch
REM -------------------------------------------------------------------
call vivado -mode batch -source build.tcl

REM -------------------------------------------------------------------
REM 3. AUTO-DETECT build folder inside *_t directory
REM -------------------------------------------------------------------
set build_dir=
set rtl_dir=

for /d %%D in ("%cd%\*_D") do (
    if exist "%%D\build" (
        set build_dir=%%D\build
	set rtl_dir=%%D\rtl
    )
)

if "%build_dir%"=="" (
    echo ERROR: No *_t folder found!
    exit /b 1
)

echo Detected build directory:
echo    %build_dir%

REM -------------------------------------------------------------------
REM 4. Run Python metadata generator
REM -------------------------------------------------------------------
python "C:/Users/narsi/Desktop/projects/Project_BUG/tools/write_meta.py" ^
       "%cd%" ^
       "%build_dir%" ^
       "xc7z020clg484-1" ^
       "Vivado 2022.2" ^
       "%rtl_dir%" ^
       "UART_tx_rseq"

echo DONE.
endlocal
