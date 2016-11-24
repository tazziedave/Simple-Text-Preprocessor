unit Help;

interface

uses
  Definitions;

procedure ShowHelp(Command : TSwitchCommand; msg : string = '');
procedure ExtraHelp(Command : TSwitchCommand);
procedure show(msg : string; linebefore : Boolean = false);
procedure CreateExampleFile;
function Confirm(msg : string) : Boolean;

implementation

uses System.SysUtils, Console;

var
  indent : Integer;
  lineNbr : Integer;
  tabindent : integer;

procedure show(msg : string; linebefore : Boolean = false);
var
  spaces : string;
begin
  if linebefore then
    Writeln('');

  spaces := StringOfChar(' ', indent);
  Writeln(spaces + msg);
end;

procedure exampleshow(msg : string; tabdelta : Integer = 0; LineNbrs : Boolean = true);
var
  tabs : string;
begin
  tabindent := tabindent + tabdelta;

  tabs := StringOfChar(' ', 4 * tabindent);
  if LineNbrs  then
    Writeln(IntToStr(lineNbr) + TAB + tabs + msg)
  else
    Writeln(tabs + msg);
  lineNbr := lineNbr + 1;
end;

procedure section(Command : TSwitchCommand);
begin
  if Command in [pagedhelp, examples] then
  begin
    show('Press Any key to continue. CTRL+C or ESC to escape.', True);
    if ReadKey in [chr(3), chr($1B)] then
      Halt;
  end;
end;

procedure ShowHelp(Command : TSwitchCommand; msg : string = '');
begin
  indent := 0;

  if msg <> '' then
  begin
    show(msg, true);
  end;

  show('SPP InFile [OutFile]', true);
  indent := 4;
  show('[conditional conditional ... -Dconditional -Dconditional ... -Uconditional -Uconditional ...');
  show('-1[tag] -2[tag] -3[tag] -4[tag] -5[tag] -6[tag] -7[tag] -8[tag] -9commentString ...');
  show('-Q -F -H -? -E -L]');

  indent := 0;
  show('Description:', true);
  indent := 2;
  show('Simple text file preprocessor.');
  show('Creates OutFile from InFile by including or excluding text based on defined conditionals');
  show('(from the command line or within the InFile) and conditions specified within the InFile.');
  show('The conditions are prefixed by user determined comment strings.');
  show('If OutFile is not specified, output is listed to the console.');

  if Command <> quickhelp then
    ExtraHelp(Command)
  else
  begin
    indent := 0;
    show('Use SPP -H or -? -E -L', True);
    indent := 2;
    show('for additional instructions. -? Shows the instructions a section at a time. -E Skips straight');
    show('to the examples. -L lists the text of example file.');
    indent := 0;
    show('Use SPP -L > "infile.txt"', true);
    indent := 2;
    show('to create the example file.');
  end;

  indent := 0;
  show('Version 1.0 Beta', True);
  indent := 2;
  show('Source and further documentation can be found at https://github.com/tazziedave/Simple-Text-Preprocessor');

  Halt;
end;

procedure ExampleMessage(LineNbrs : Boolean = true);
begin
  exampleshow('#def foo', 0, LineNbrs);
  exampleshow('//def bar', 0, LineNbrs);
  exampleshow('// #undef baz', 0, LineNbrs);
  exampleshow('', 0, LineNbrs);
  exampleshow('#ifdef foo', 0, LineNbrs);
  exampleshow('#ifndef bar', 1, LineNbrs);
  exampleshow('foo is defined, bar isn''t', 1, LineNbrs);
  exampleshow('#else', -1, LineNbrs);
  exampleshow('foo and bar defined', 1, LineNbrs);
  exampleshow('#endif', -1, LineNbrs);
  exampleshow('#else', -1, LineNbrs);
  exampleshow('foo is not defined', 1, LineNbrs);
  exampleshow('//#ifdef BAZ', 0, LineNbrs);
  exampleshow('Baz is defined', 1, LineNbrs);
  exampleshow('//#else', -1, LineNbrs);
  exampleshow('baz is not defined', 1, LineNbrs);
  exampleshow('//#endif', -1, LineNbrs);
  exampleshow('#endif', -1, LineNbrs);
  exampleshow('ifdef Unaffected text', 0, LineNbrs);

end;


procedure ExtraHelp(Command : TSwitchCommand);
var
  i : TCommentMarkers;
begin
  if Command <> fullhelp then
    InitScreenMode;

  if Command <> examples then
  begin
    indent := 0;
    show('Parameters:', true);
    indent := 2;
    show('InFile' + TAB2 + 'Fully qualified name of source text file.', true);

    show('OutFile' + TAB2 + 'Fully qualified name of output text file. If -F is not used, output path', true);
    show(TAB3 + 'must exist. If the output file exists then you prompted to overwrite');
    show(TAB3 + 'unless the -Q parameter is specified');

    show('-Dconditional' + TAB2 + '"Hard" definition of a conditional that cannot be undefined within', true);
    show(TAB3 + 'the InFile.');

    show('-Uconditional' + TAB2 +  '"Hard" undefinition of a conditional that prevents definition of the', true);
    show(TAB3 + 'conditional within the InFile or using a "soft" conditional parameter.');

    show('-1[tag] .. -8[tag]' + TAB + 'Use one or more of the comment strings specified below to prefix a', true);
    show(TAB3 + 'condition in the InFile. If tag is defined than it means that the');
    show(TAB3 + 'comment string has tag and <space> tag appended.');
    show(TAB3 + 'eg. -2# gives comment strings of "//#" and "// #" but not "//".');
    show(TAB3 + 'If you want all variants then you''d use -2 and -2# as two parameters.');

    show('-9commentString' + TAB + 'Specify a user defined comment string. Use "comment string" if you want', true);
    show(TAB3 + 'spaces within or at end of comment string. eg -9": " or -9": #"');


    show('-Q' + TAB3 + 'Overwrites output file without warning or prompt.', true);
    show('-F' + TAB3 + 'Force creation of output path if necessary (and possible).', true);
    show('-H' + TAB3 + 'Shows this help.', true);
    show('-?' + TAB3 + 'Shows this help a section at a time.', true);
    show('-E' + TAB3 + 'Skips straight to the example section.', true);
    show('-L' + TAB3 + 'Lists the text of example file. Use SPP -L > "infile.txt" to create file.', true);

    show('conditional' + TAB2 + 'All other parameters are considered "soft" conditional definitions.', true);
    show(TAB3 + 'They don''t override a "Hard" define or undefine and can be undefined');
    show(TAB3 + 'and redefined within the InFile.');

    show('Notes:' + TAB +  'Parameters can also be lower case. / or -- can be used instead of -.', true);
    show(TAB2 +  'If the same conditional has -D and -U, the last one specified applies.');

    section(Command);

    indent := 0;
    show('Comment Strings:', true);
    indent := 2;
    show('Conditions are identified within the InFile by being prefixed by one of the following comment');
    show('strings as the first non-space string in the text line. Suggested usages are shown.');

    for i := Low(TCommentMarkers) to UserDefined do
        show('-' + IntToStr(Ord(i))+ TAB + PREDEFINED_COMMENT_MARKERS[i] + TAB + COMMENT_MARKER_DESCRIPTION[i], true);

    show('Notes:' + TAB +  'If none of the -1 ... -9 parameters are used, then this is the equivalent of -1 -2.', true);
    show(TAB2 +  'Multiple predefined and user defined comment strings can be used.');

    section(Command);

    indent := 0;
    show('Conditions:', true);
    indent := 2;
    show('Once a comment string is found. The following conditions are looked for at the next non-space');
    show('position in the line. If a conditional is expected, this is the next word followed by a');
    show('space or end of line.');

    show('ifdef' + TAB2 + 'conditional' + TAB + 'If text is currently being output, then text up to the paired', true);
    show(TAB4 + 'Else or Endif will be included in the output if "conditional"');
    show(TAB4 + 'has been defined. Otherwise, text will be excluded from the output.');

    show('ifndef' + TAB + 'conditional' + TAB + 'If text is currently being output, then text up to the paired', true);
    show(TAB4 + 'Else or Endif will be included in the output if "conditional"');
    show(TAB4 + 'has NOT been defined. Otherwise, text will be excluded from the output.');

    show('else' + TAB4 + 'Toggles including/excluding text for the currently effective If...', true);
    show(TAB4 + 'condition.');

    show('endif' + TAB4 + 'Terminates the currently effective If.../Else condition. Subsequent', true);
    show(TAB4 + 'text will be included.');

    show('def' + TAB2 + 'conditional' + TAB + '"Soft" define of "conditional". Only processed if text is currently', true);
    show(TAB4 + 'being output');

    show('undef' + TAB2 + 'conditional' + TAB + '"Soft" removal of "conditional" definition. Only processed if text', true);
    show(TAB4 + 'is currently being output');

    show('Notes:' + TAB +  'All condition and conditional strings are case insensitive. If a fully formed', true);
    show(TAB2 +  'condition is found then the entire line is removed. All conditional comment lines MUST be');
    show(TAB2 +  'single line. A malformed condition is treated as any other line. eg. #ifdef');
    show(TAB2 +  'on a line of it''s own will get output like any other text.');

    section(Command);
  end;

  indent := 0;
  show('Examples:', true);
  indent := 2;
  show('Given an input file (infile.txt) with the following text in it:');

  indent := 0;
  tabindent := 0;
  lineNbr := 1;
  show('LineNbr' + TAB + 'Content', true);
  ExampleMessage(True);

  indent := 0;
  show('');
  show('COMMAND:  SPP infile.txt outfile.txt', true);
  indent := 2;
  show('Would produce outfile.txt, based on # (-1) and // (-2) being the comment strings', true);

  indent := 0;
  tabindent := 0;
  show('LineNbr' + TAB + 'Content', true);
  lineNbr := 3;
  exampleshow('// #undef baz  -- [comment string not recognized, so just treated as text]');
  exampleshow('');
  lineNbr := 9;
  exampleshow('foo and bar defined', 2);
  lineNbr := 19;
  exampleshow('ifdef Unaffected text', -2);

  section(Command);

  indent := 0;
  show('');
  show('COMMAND:  SPP infile.txt -1 -2 -2# BAZ', true);
  indent := 2;
  show('BAZ is soft defined; #, //, //# and // # are the comment strings. Output goes to the console.', true);

  indent := 0;
  tabindent := 0;
  show('LineNbr' + TAB + 'Ouput', true);
  lineNbr := 4;
  exampleshow('');
  lineNbr := 9;
  exampleshow('foo and bar defined', 2);
  lineNbr := 19;
  exampleshow('ifdef Unaffected text', -2);

  indent := 0;
  show('');
  show('COMMAND:  SPP infile.txt outfile.txt BAZ -Ufoo -1 -2 -2#', true);
  indent := 2;
  show('BAZ is soft defined, FOO is hard undefined; #, //, //# and // # are the comment strings', true);

  indent := 0;
  tabindent := 0;
  show('LineNbr' + TAB + 'Content', true);
  lineNbr := 4;
  exampleshow('');
  lineNbr := 12;
  exampleshow('foo is not defined', 1);
  lineNbr := 16;
  exampleshow('baz is not defined  -- [undefined on line 3]', 1);
  lineNbr := 19;
  exampleshow('ifdef Unaffected text', -2);

  indent := 0;
  show('');
  show('COMMAND:  SPP infile.txt outfile.txt -dBAZ -Ufoo -1 -2 -9//# -9"// #" 1234', true);
  indent := 2;
  show('BAZ is hard defined, FOO is hard undefined, 1234 is soft defined;', true);
  show('#, //, //# and // # are the comment strings');

  indent := 0;
  tabindent := 0;
  show('LineNbr' + TAB + 'Content', true);
  lineNbr := 4;
  exampleshow('');
  lineNbr := 12;
  exampleshow('foo is not defined', 1);
  lineNbr := 14;
  exampleshow('Baz is defined', 1);
  lineNbr := 18;
  exampleshow('ifdef Unaffected text', -2);
end;

procedure CreateExampleFile;
begin
    ExampleMessage(false);
    Halt;
end;


function Confirm(msg : string) : Boolean;
var
  Key : Char;
begin
  show(msg, True);
  Key := chr(0);
  while not (Key in ['n', 'N', 'Y', 'y', Chr(13), Chr(3)]) do
  begin
    Key := ReadKey;
  end;

  If Key = chr(3) then
    Halt;

  Result := (Key = 'y') or (Key = 'Y');
end;

end.
