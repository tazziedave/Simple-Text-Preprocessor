program SPP;
{$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$SETPEFLAGS 1}  // Remove PE Relocation table

{$APPTYPE CONSOLE}

//{$DEFINE timing}
//{$DEFINE lineCount}

uses
  System.SysUtils,
  System.Classes,
  T_Include in 'T_Include.pas',
  Help in 'Help.pas',
  Definitions in 'Definitions.pas',
  T_IntStringList in 'T_IntStringList.pas';

var
  InFileName, OutFileName : string;
  InFile, OutFile : Text;
  i : Integer;
  includes : TInclude;
  Line, TestLine : string;
  Include : array[1..MAX_NESTING] of Boolean;
  CommentMarkers : TIntStringList;
  CommentChars : string;
  CommentCount : Integer;

  IncludeLine : Boolean;
  IfDepth, IgnoreDepth : Integer;
  Condition : TConditionals;
  Parameter : string;
  Command : TSwitchCommand;
  Switches : array[TSwitchCommand] of Boolean;
  StartTrim : string;

function GetRemainingString(const InString : string; const RemoveString : string) : string; overload;
begin
  Result := Trim(Copy(InString, Length(RemoveString) + 1, MaxInt));
end;

function GetRemainingString(const InString : string; const RemoveChars : integer) : string;  overload;
begin
  Result := Trim(Copy(InString, RemoveChars, MaxInt));
end;

function compare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Length(List[Index2]) - Length(List[Index1]);
end;

procedure AddCommentMarker(const Marker : string; const Tag : string = '');
var
  sMarker : string;
  firstchar : Char;

  procedure AddMarker(const sMarker : string);
  begin
    if CommentMarkers.IndexOf(sMarker) = -1 then // dupIgnore doesn't seem to be working
    begin
      CommentMarkers.AddItem(sMarker, Length(sMarker) + 1);
      CommentMarkers.CustomSort(compare);
      CommentCount := CommentCount + 1;
    end;
  end;

begin
  sMarker := LowerCase(Marker);

  if TrimLeft(sMarker) = '' then
    Exit;

  firstchar := sMarker[1];
  if Pos(firstchar, CommentChars) < 1 then
    CommentChars := CommentChars + firstchar;

  if Tag <> '' then
  begin
    AddMarker(sMarker + Tag);
    AddMarker(sMarker + ' ' + Tag);
  end else
    AddMarker(sMarker);


end;

function ParseParameter(InParameter : string; var  Parameter : string) : TSwitchCommand;
var
  i: Integer;
  Switch : Char;
begin
  if Length(InParameter) = 0 then // May happen for filename parameters
    Exit(quickhelp);

  // If no switches, assume define
  Result := baredefine;
  Parameter := LowerCase(InParameter);

  for i := 1 to SWITCH_DELIMITER_COUNT do
  begin
    if pos(SWITCH_DELIMITERS[i], Parameter) = 1 then
    begin
        Parameter := GetRemainingString(Parameter, SWITCH_DELIMITERS[i]);
        if Parameter = '' then
          Exit(quickhelp);

        Switch := Parameter[1];
        Parameter := Copy(Parameter, 2, MaxInt);

        case Switch of
        'd': Result := defining;
        'u': Result := undefining;
        'h': Result := fullhelp;
        '?': Result := pagedhelp;
        'e': Result := examples;
        'q': Result := quietrewrite;
        'f': Result := forceddirectories;
//        'r': Result := report;
//        'v': Result := verbose;
        'l': Result := createinfile;
//        't':
//          begin
//            if Parameter = '' then
//              StartTrim := TAB
//            else
//              StartTrim := Parameter;
//            Result := noaction;
//          end;
        '1'..'8':
          begin
            Result := comment;
            AddCommentMarker(PREDEFINED_COMMENT_MARKERS[TCommentMarkers(StrToInt(Switch))], Parameter);
          end;
        '9':
          begin
            if Parameter = '' then
              Exit(quickhelp);
            Result := comment;
            AddCommentMarker(Parameter)
          end;
         else
          Result := quickhelp;
        end;

        if (Result in [defining, undefining]) and (Parameter = '') then
          Result := quickhelp;
    end;
  end;

end;

function HasComment(ReadLine : string; var TestLine : string) : Boolean;
var i : integer;
begin
  Result := False;
  TestLine := LowerCase(Trim(ReadLine));
  if (TestLine = '') or (pos(TestLine[1], CommentChars) < 1) then
      exit;

  for i := 0 to CommentCount do
  begin
    if pos(CommentMarkers[i], TestLine) = 1 then
    begin
        TestLine := GetRemainingString(TestLine, CommentMarkers.Ints[i]);
        Exit(True);
    end;
  end;
end;

function HasCondition(TestLine : string; var  Parameter : string; LineIncluded : boolean) : TConditionals;
var condition : TConditionals;
  spacePos: Integer;
begin
  Result := noConditional;
  for condition := FIRST_CONDITIONAL to LAST_CONDITIONAL do
  begin
    if pos(CONDITIONALS[condition], TestLine) = 1 then
    begin
        if LineIncluded then
        begin
          case  EDGE_TEST[condition] of
          MaximumNesting:
            if ifDepth >= MAX_NESTING then
              Exit;
          NoConditionals:
            if IfDepth = 0 then
              Exit;
          end;

          TestLine := Trim(Copy(TestLine, Length(CONDITIONALS[condition]) + 1, MaxInt));
          if PARAMETER_REQUIRED[condition] then
          begin
            if Length(TestLine) > 0 then
            begin
              spacePos := Pos(' ', TestLine);
              if (spacePos > 0) then
                Parameter := Copy(TestLine, 1, spacePos - 1)
              else
                Parameter := TestLine;
              Exit(condition)
            end;
          end
          else
            Exit(condition);
      end
      else
        Exit(condition); // Line not included, no tests needed
    end;
  end;
end;


{$IFDEF timing}
var
  j : Integer;
  StartTime : TDateTime;
{$ENDIF}

{$IFDEF lineCount}
var
  LineNbr : Integer;
{$ENDIF}

function CheckOutFile(var msg : string) : Boolean;
var
  dir : string;
begin
  Result := True;

  if OutFileName = '' then  // Sending to console, bail
    Exit;

  if FileExists(OutFileName) then
  begin
    if not Switches[quietrewrite] then
    begin
      msg := '';
      Result := Confirm(OutFileName + ' already exists. Overwrite y/N?');
    end;
  end
  else
  begin
      dir := ExtractFileDir(ExpandFileName(OutFileName));
      if (dir <> '') and not DirectoryExists(dir) then
      begin
        msg := 'Output directory ' + dir + ' doesn''t exist. ';
        if Switches[forceddirectories] then
        begin
          if not ForceDirectories(dir) then
          begin
            msg := msg + 'Unable to create.';
            Result := false;
          end;
        end
        else
        begin
          msg := msg + 'Use -F parameter to force creation of directories.';
          Result := False;
        end;
      end;
  end;
end;

begin
  try

    CommentMarkers := TIntStringList.Create;
    CommentChars := '';
//    CommentMarkers.Duplicates := dupIgnore; Not working??

    includes := TInclude.Create;
    for i := 1 to ParamCount do
    begin
      Command := ParseParameter(ParamStr(i), Parameter);
      case Command of
      baredefine:
        case i of
        1:
          InFileName := Parameter;
        2:
          OutFileName := Parameter;
        else
          includes.Define(Parameter);
        end;
      defining:   includes.HardDefine(Parameter);
      undefining: includes.HardUndefine(Parameter);
      comment: ;
      createinfile: CreateExampleFile;
      quickhelp, fullhelp, pagedhelp, examples: ShowHelp(Command);
      else
        Switches[Command] := True;
      end;
    end;

    if CommentMarkers.Count = 0 then
    begin
        AddCommentMarker(PREDEFINED_COMMENT_MARKERS[hash]);
{$IFDEF mybuild}
        AddCommentMarker(PREDEFINED_COMMENT_MARKERS[cSingleLine], '#');
{$ELSE}
        AddCommentMarker(PREDEFINED_COMMENT_MARKERS[cSingleLine]);
{$ENDIF}
    end;

    CommentCount := CommentCount - 1; // Always used to access 0 indexed list

    if InFileName = '' then
      ShowHelp(quickhelp);

    if not FileExists(InFileName) then
      ShowHelp(quickhelp, 'Input file - ' + InFileName + ' not found');

    if not CheckOutFile(Parameter) then // Parameter doing double duty as the message
      ShowHelp(quickhelp, Parameter);

    IfDepth := 0;
    IgnoreDepth := 0;
    IncludeLine := True;
    for i := 1 to MAX_NESTING do
      Include[i] := True;

    AssignFile(InFile, InFileName);
    Reset(InFile);

    AssignFile(OutFile, OutFileName);
    Rewrite(OutFile);

{$IFDEF lineCount}
  LineNbr := 0;
{$ENDIF}

{$IFDEF timing}
  StartTime := time;
  for j := 1 to 1000 do begin
{$ENDIF}

    while not Eof(InFile) do
    begin
      Readln(InFile, Line);
{$IFDEF lineCount}
  LineNbr := LineNbr + 1;
{$ENDIF}

      Condition := noConditional;
      if HasComment(Line, TestLine) then
      begin
        Condition := HasCondition(TestLine, Parameter, IncludeLine)
      end;

      if IncludeLine then
      begin
        if Condition <> noConditional then
        begin
          case Condition of
          define:
            includes.Define(Parameter);

          undefine:
            includes.Undefine(Parameter);

          ifdef:
          begin
            IfDepth := IfDepth + 1;
            Include[IfDepth] := includes.Defined(Parameter);
          end;

          ifndef:
          begin
            IfDepth := IfDepth + 1;
            Include[IfDepth] := not includes.Defined(Parameter);
          end;

          els:
          begin
            Include[IfDepth] := not Include[IfDepth];
          end;

          endif:
          begin
            Include[IfDepth] := True;
            IfDepth := IfDepth - 1;
          end;
          end;

          if Condition < define then
          begin
            IncludeLine := True;
            for i := 1 to IfDepth do
              IncludeLine := IncludeLine and Include[i];
          end;
        end
        else
    {$IFDEF lineCount}
    Writeln(OutFile, inttostr(LineNbr) + TAB + Line);
    {$ELSE}
            Writeln(OutFile, Line);
    {$ENDIF}
        end
        else if Condition <> noConditional then // Currently excluding - have we found a line for us?
        begin
          // Ignore defines/undefines
          case Condition of
          ifdef, ifndef:
            IgnoreDepth := IgnoreDepth + 1;

          els:
          begin
            if IgnoreDepth = 0 then
              Include[IfDepth] := not Include[IfDepth]; // Standard Toggle
          end;

          endif:
          begin
            if IgnoreDepth > 0 then
            begin
              IgnoreDepth := IgnoreDepth - 1;
            end
            else
            begin
              Include[IfDepth] := True;
              IfDepth := IfDepth - 1;
            end;
          end;
          end;

          if Condition in [els, endif] then
          begin
            IncludeLine := True;
            for i := 1 to IfDepth do
              IncludeLine := IncludeLine and Include[i];
          end;

        end;
    end;
{$IFDEF timing}
Reset(InFile);
end;
Writeln('Elapsed time: ' + IntToStr(MilliSecondOf(Time - starttime)));
{$ENDIF}

    CloseFile(InFile);
    CloseFile(OutFile);

  except
    on E: Exception do ShowHelp(quickhelp, E.Message);
  end;
end.
