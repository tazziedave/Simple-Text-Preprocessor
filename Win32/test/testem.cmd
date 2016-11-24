@echo off
set outdir=R:\testout\
if exist %outdir% goto :RemoveFiles
md %outdir%  

:RemoveFiles
del /Q %outdir%*.*

call dotest %1 1 1 %outdir% %2 
call dotest %1 1 2 %outdir% %2 -ubasic_test
call dotest %1 1 3 %outdir% %2 -dbasic_test -ubasic_test
call dotest %1 1 4 %outdir% %2 /ubasic_test /dbasic_test
call dotest %1 1 5 %outdir% %2 --ubasic_test basic_test

call dotest %1 2 1 %outdir% %2
call dotest %1 2 2 %outdir% %2 -ubasic_test
call dotest %1 2 3 %outdir% %2 -dbasic_test
call dotest %1 2 4 %outdir% %2 basic_test

call dotest %1 3 1 %outdir% %2
call dotest %1 3 2 %outdir% %2 -ubasic_test
call dotest %1 3 3 %outdir% %2 -dbasic_test
call dotest %1 3 4 %outdir% %2 basic_test

call dotest %1 4 1 %outdir% %2
call dotest %1 4 2 %outdir% %2 DEF1
call dotest %1 4 3 %outdir% %2 -DDEF1
call dotest %1 4 4 %outdir% %2 -UDEF1
call dotest %1 4 5 %outdir% %2 DEF2
call dotest %1 4 6 %outdir% %2 -DDEF2
call dotest %1 4 7 %outdir% %2 -UDEF2
call dotest %1 4 8 %outdir% %2 DEF3
call dotest %1 4 9 %outdir% %2 -DDEF3
call dotest %1 4 10 %outdir% %2 -UDEF3
call dotest %1 4 11 %outdir% %2 -ddef1 def3 -udef2
call dotest %1 4 12 %outdir% %2 -udef1 -udef2 -udef3
call dotest %1 4 13 %outdir% %2 def1 def2 def3
call dotest %1 4 14 %outdir% %2 --ddef1 /ddef2 -ddef3

call dotest %1 5 1 %outdir% %2
call dotest %1 5 2 %outdir% %2 DEF1
call dotest %1 5 3 %outdir% %2 -DDEF1
call dotest %1 5 4 %outdir% %2 -UDEF1
call dotest %1 5 5 %outdir% %2 DEF2
call dotest %1 5 6 %outdir% %2 -DDEF2
call dotest %1 5 7 %outdir% %2 -UDEF2
call dotest %1 5 8 %outdir% %2 DEF3
call dotest %1 5 9 %outdir% %2 -DDEF3
call dotest %1 5 10 %outdir% %2 -UDEF3
call dotest %1 5 11 %outdir% %2 -ddef1 def3 -udef2
call dotest %1 5 12 %outdir% %2 -udef1 -udef2 -udef3
call dotest %1 5 13 %outdir% %2 def1 def2 def3
call dotest %1 5 14 %outdir% %2 --ddef1 /ddef2 -ddef3

call dotest %1 6 1 %outdir% %2
call dotest %1 6 2 %outdir% %2 DEF1
call dotest %1 6 3 %outdir% %2 -DDEF1
call dotest %1 6 4 %outdir% %2 -UDEF1
