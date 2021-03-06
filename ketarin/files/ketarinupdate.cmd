@echo off

SET DIR=%~dp0%

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)

echo Updating the github repo first
pushd %DIR%
call git add .
call git commit -m "updates prior to automatic run for %mydate%_%mytime%"
::call git reset --hard HEAD
call git fetch && git rebase origin/master
call git push origin master
popd

::import all the files
FOR /f "tokens=*" %%F IN ('dir %DIR%..\ /b *.ketarin.xml') DO (
	call ketarin.exe /database="%DIR%\jobs.db" /import="%DIR%..\%%F"
	TIMEOUT /T 2
)

Echo Wait for all of those to finish importing...
TIMEOUT /T 15

echo Calling ketarin now the the repo has been updated
call "Ketarin.exe" /silent /notify /database="%DIR%\jobs.db" /log=C:\ProgramData\chocolateypackageupdater\ketarin.%mydate%_%mytime%.log
