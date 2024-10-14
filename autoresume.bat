@echo off
setlocal enabledelayedexpansion

:list_folders
echo Available folders in the output directory:
set /a count=0
for /d %%i in (outputs\*) do (
    set /a count+=1
    set "folder[!count!]=%%~nxi"
    echo !count!. %%~nxi
)

if %count% equ 0 (
    echo No folders found in the output directory.
    exit /b
)

:choose_folder
set /p choice="Enter the number of the folder you want to resume training from: "

if !choice! leq 0 goto invalid_choice
if !choice! gtr %count% goto invalid_choice

set "chosen_folder=!folder[%choice%]!"
echo You selected: %chosen_folder%

cd "outputs\%chosen_folder%"
echo Current directory: %CD%

:find_latest_state
set "latest_state="
set "latest_number=0"

for /d %%i in (*) do (
    set "folder_name=%%~nxi"
    if "!folder_name:~-6!"=="-state" (
        for /f "tokens=2 delims=-" %%a in ("!folder_name!") do (
            set "numeric_part=%%a"
            if !numeric_part! gtr !latest_number! (
                set "latest_number=!numeric_part!"
                set "latest_state=!folder_name!"
            )
        )
    )
)

if defined latest_state (
    set "latest_state=%CD%\%latest_state%"
    echo Latest state folder found: %latest_state%
) else (
    echo No state folders found in %chosen_folder%
    goto :eof
)

:create_trainresume
if exist train.bat (
    copy train.bat trainresume.bat
    echo --save_state_on_train_end ^^>> trainresume.bat
    echo --resume "%latest_state%" >> trainresume.bat
    echo Created trainresume.bat with resume command for %latest_state%
) else (
    echo train.bat not found in the current directory.
    goto :eof
)

echo.
echo Ready for the next steps. What would you like to do now?

goto :eof

:invalid_choice
echo Invalid choice. Please enter a number between 1 and %count%.
goto choose_folder
