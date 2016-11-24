@echo off
rem %1 is debug or release
rem %2 is number of infile
rem %3 is test number for that infile
rem %4 is the output directory
rem %5 is the output directory is the teston setting
rem all further parameters are passed to phpp

set infile=infile"%2".txt
set outfile=outfile"%2"-"%3".txt
set testOn=%5

echo test %2 - %3 
..\%1\spp %infile% "%4"%outfile% %6 %7 %8 %9 -1 -2# -3# -4#
echo =========================================================== >>"%4"%outfile%
echo test %2 - %3 %6 %7 %8 %9 %9 >>"%4"%outfile%
 
if not exist results\%outfile% goto :notchecked

if %testOn%==yes fc results\%outfile% "%4"%outfile% >nul

if ERRORLEVEL 1 goto :failed
goto :end

:notchecked
echo Not Checked
goto :end

:failed
echo Failed
fc results\%outfile% "%4"%outfile%
pause

:end
