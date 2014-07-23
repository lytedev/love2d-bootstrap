@echo off

:: Go to project root
cd %2

:: Remove and recreate bin directory
echo Removing existing bin directory...
rmdir /S /Q "bin"
echo Creating bin directory...
mkdir "bin"

:: Zip up the project
echo Building .love file...
7z a -tzip "bin\%1.love"

:: Copy LOVE2D DLLs to the bin directory
echo Copying DLLs...
copy "lib\love\*.dll" "bin\"

:: Binary copy zip with the LOVE2D executable
echo Building Windows executable...
copy /b "lib\love\love.exe"+"bin\%1.love" "bin\%1.exe"

:: Run
echo Running...
echo.
bin\%1.exe
