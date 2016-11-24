# Simple Text Preprocessor (SPP)
A simple windows command line text file processor that allows for conditional inclusion/exclusion of lines from an input file similar to the way compiled languages create conditional builds. It enables multiple builds of a website, wordpress plugin or theme, etc from a single source base. 

It is totally file extension agnostic and relies on command line parameters to identify the conditions within the input file. This makes it suitable for preprocessing PHP, Javascript, CSS, HTML, XML or just about anything.

Output can go straight to the console or a specifed file. 
Windows command line program that creates OutFile from InFile by including or excluding text based on defined conditionals
(from the command line or within the InFile) and conditions specified within the InFile.
The conditions are prefixed by user determined comment strings.
If OutFile is not specified, output is listed to the console.
  
## Command Line
	SPP InFile [OutFile]
		[conditional conditional ... -Dconditional -Dconditional ... -Uconditional -Uconditional ...
		-1[tag] -2[tag] -3[tag] -4[tag] -5[tag] -6[tag] -7[tag] -8[tag] -9commentString ...
		-Q -F -H -? -E -L]
