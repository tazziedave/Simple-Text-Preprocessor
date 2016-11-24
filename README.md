# Simple Text Preprocessor (SPP)
A simple windows command line text file processor that allows for conditional inclusion/exclusion of lines from an input file similar to the way compiled languages create conditional builds. It enables multiple builds of a website, wordpress plugin or theme, etc from a single source base. 

It is totally file extension agnostic and relies on command line parameters to identify the conditions within the input file. This makes it suitable for preprocessing PHP, Javascript, CSS, HTML, XML or just about anything.

It is written using Delphi XE2. The win32\test directory contains text files and batch files used to verify program operation.

## Command Line

	SPP InFile [OutFile]
		[conditional conditional ... -Dconditional -Dconditional ... -Uconditional -Uconditional ...
		-1[tag] -2[tag] -3[tag] -4[tag] -5[tag] -6[tag] -7[tag] -8[tag] -9commentString ...
		-Q -F -H -? -E -L]

The following documentation is taken from using the command:
	
	SPP -h (or SPP -? for a section at a time

    Description:
      Simple text file preprocessor.
      Creates OutFile from InFile by including or excluding text based on defined conditionals
      (from the command line or within the InFile) and conditions specified within the InFile.
      The conditions are prefixed by user determined comment strings.
      If OutFile is not specified, output is listed to the console.
    
    Parameters:
    
      InFile                Fully qualified name of source text file.
    
      OutFile               Fully qualified name of output text file. If -F is not used, output path
                            must exist. If the output file exists then you prompted to overwrite
                            unless the -Q parameter is specified
    
      -Dconditional         "Hard" definition of a conditional that cannot be undefined within
                            the InFile.
    
      -Uconditional         "Hard" undefinition of a conditional that prevents definition of the
                            conditional within the InFile or using a "soft" conditional parameter.
    
      -1[tag] .. -8[tag]    Use one or more of the comment strings specified below to prefix a
                            condition in the InFile. If tag is defined than it means that the
                            comment string has tag and <space> tag appended.
                            eg. -2# gives comment strings of "//#" and "// #" but not "//".
                            If you want all variants then you'd use -2 and -2# as two parameters.
    
      -9commentString       Specify a user defined comment string. Use "comment string" if you want
                            spaces within or at end of comment string. eg -9": " or -9": #"
    
      -Q                    Overwrites output file without warning or prompt.
    
      -F                    Force creation of output path if necessary (and possible).
    
      -H                    Shows this help.
    
      -?                    Shows this help a section at a time.
    
      -E                    Skips straight to the example section.
    
      -L                    Lists the text of example file. Use SPP -L > "infile.txt" to create file.
    
      conditional           All other parameters are considered "soft" conditional definitions.
                            They don't override a "Hard" define or undefine and can be undefined
                            and redefined within the InFile.
    
      Notes:        Parameters can also be lower case. / or -- can be used instead of -.
                    If the same conditional has -D and -U, the last one specified applies.
    
    Comment Strings:
      Conditions are identified within the InFile by being prefixed by one of the following comment
      strings as the first non-space string in the text line. Suggested usages are shown.
    
      -1    #               PHP
    
      -2    //              Javascript, PHP
    
      -3    /*              CSS
    
      -4    <!--            HTML, XML
    
      -5    {#              Phalcon Volt, Jinja
    
      -6    {% comment      Django - trailing space required
    
      -7    rem             Batch files - trailing space required
    
      -8    "               Not sure, but defined because it's hard to define on the command line
    
      -9    <user>          Whatever you want
    
      Notes:        If none of the -1 ... -9 parameters are used, then this is the equivalent of -1 -2.
                    Multiple predefined and user defined comment strings can be used.
    
    Conditions:
      Once a comment string is found. The following conditions are looked for at the next non-space
      position in the line. If a conditional is expected, this is the next word followed by a
      space or end of line.
    
      ifdef         conditional     If text is currently being output, then text up to the paired
                                    Else or Endif will be included in the output if "conditional"
                                    has been defined. Otherwise, text will be excluded from the output.
    
      ifndef        conditional     If text is currently being output, then text up to the paired
                                    Else or Endif will be included in the output if "conditional"
                                    has NOT been defined. Otherwise, text will be excluded from the output.
    
      else                          Toggles including/excluding text for the currently effective If...
                                    condition.
    
      endif                         Terminates the currently effective If.../Else condition. Subsequent
                                    text will be included.
    
      def           conditional     "Soft" define of "conditional". Only processed if text is currently
                                    being output
    
      undef         conditional     "Soft" removal of "conditional" definition. Only processed if text
                                    is currently being output
    
      Notes:        All condition and conditional strings are case insensitive. If a fully formed
                    condition is found then the entire line is removed. All conditional comment lines MUST be
                    single line. A malformed condition is treated as any other line. eg. #ifdef
                    on a line of it's own will get output like any other text.
    
    Examples:
      Given an input file (infile.txt) with the following text in it:
    
    LineNbr Content
    1       #def foo
    2       //def bar
    3       // #undef baz
    4       
    5       #ifdef foo
    6           #ifndef bar
    7               foo is defined, bar isn't
    8           #else
    9               foo and bar defined
    10          #endif
    11      #else
    12          foo is not defined
    13          //#ifdef BAZ
    14              Baz is defined
    15          //#else
    16              baz is not defined
    17          //#endif
    18      #endif
    19      ifdef Unaffected text
    
    
    COMMAND:  SPP infile.txt outfile.txt
    
      Would produce outfile.txt, based on # (-1) and // (-2) being the comment strings
    
    LineNbr Content
    3       // #undef baz  -- [comment string not recognized, so just treated as text]
    4       
    9               foo and bar defined
    19      ifdef Unaffected text
    
    
    COMMAND:  SPP infile.txt -1 -2 -2# BAZ
    
      BAZ is soft defined; #, //, //# and // # are the comment strings. Output goes to the console.
    
    LineNbr Ouput
    4       
    9               foo and bar defined
    19      ifdef Unaffected text
    
    
    COMMAND:  SPP infile.txt outfile.txt BAZ -Ufoo -1 -2 -2#
    
      BAZ is soft defined, FOO is hard undefined; #, //, //# and // # are the comment strings
    
    LineNbr Content
    4       
    12          foo is not defined
    16              baz is not defined  -- [undefined on line 3]
    19      ifdef Unaffected text
    
    
    COMMAND:  SPP infile.txt outfile.txt -dBAZ -Ufoo -1 -2 -9//# -9"// #" 1234
    
      BAZ is hard defined, FOO is hard undefined, 1234 is soft defined;
      #, //, //# and // # are the comment strings
    
    LineNbr Content
    4       
    12          foo is not defined
    14              Baz is defined
    18      ifdef Unaffected text
