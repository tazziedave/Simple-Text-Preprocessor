{                                                                           }
{ File:       Console.pas                                                   }
{ Function:   Console unit, similar to the Crt unit in Turbo Pascal.        }
{ Language:   Delphi 5 and above                                            }
{ Author:     Rudolph Velthuis                                              }
{ Copyright:  (c) 2006,2008 Rudy Velthuis                                   }
{ Disclaimer: This code is freeware. All rights are reserved.               }
{             This code is provided as is, expressly without a warranty     }
{             of any kind. You use it at your own risk.                     }
{                                                                           }
{             If you use this code, please credit me.                       }
{                                                                           }

unit Console;

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 17.0}
    {$DEFINE INLINES}
  {$IFEND}
  {$IF RTLVersion >= 14.0}
    {$DEFINE HASERROUTPUT}
  {$IFEND}
{$ENDIF}

interface

uses Windows;

const
  // Background and foreground colors
  Black        = 0;
  Blue         = 1;
  Green        = 2;
  Cyan         = 3;
  Red          = 4;
  Magenta      = 5;
  Brown        = 6;
  LightGray    = 7;

  // Foreground colors
  DarkGray     = 8;          
  LightBlue    = 9;
  LightGreen   = 10;
  LightCyan    = 11;
  LightRed     = 12;
  LightMagenta = 13;
  Yellow       = 14;
  White        = 15;

  // Blink attribute, to be or-ed with background colors.
  Blink        = 128;

  // Text modes:
  BW40         = 0;      // 40x25 B/W on Color Adapter
  CO40         = 1;      // 40x25 Color on Color Adapter
  BW80         = 2;      // 80x25 B/W on Color Adapter
  CO80         = 3;      // 80x25 Color on Color Adapter
  Mono         = 7;      // 80x25 on Monochrome Adapter
  Font8x8      = 256;    // Add-in for ROM font

  // Mode constants for 3.0 compatibility of original CRT unit }
  C40          = CO40;
  C80          = CO80;


// Turbo/Borland Pascal Crt routines:

// Waits for keypress and returns the key pressed. If the key is not an ASCII
// key, #0 is returned, and a successive ReadKey will give the extended key
// code of the key.
function ReadKey: Char;

// Checks whether a key was pressed.
function KeyPressed: Boolean;

procedure InitScreenMode;

var
  TextWindow: TSmallRect;
  TextAttr: Byte;
  DefaultAttr: Byte;
  ScreenMode: Byte;
  BufferSize: TCoord;
  ScreenSize: TCoord;
  StdIn, StdOut: THandle;
  StdErr: THandle;
  LastMode: Word;
  WindMin: Word;
  WindMax: Word;
  CheckBreak: Boolean;

implementation

uses SysUtils;

type
  PKey = ^TKey;
  TKey = record
    KeyCode: Smallint;
    Normal: Smallint;
    Shift: Smallint;
    Ctrl: Smallint;
    Alt: Smallint;
  end;

const
  CKeys: array[0..88] of TKey = (
    (KeyCode: VK_BACK;     Normal: $8;        Shift: $8;       Ctrl: $7F;  Alt: $10E; ),
    (KeyCode: VK_TAB;      Normal: $9;        Shift: $10F;     Ctrl: $194; Alt: $1A5; ),
    (KeyCode: VK_RETURN;   Normal: $D;        Shift: $D;       Ctrl: $A;   Alt: $1A6),
    (KeyCode: VK_ESCAPE;   Normal: $1B;       Shift: $1B;      Ctrl: $1B;  Alt: $101),
    (KeyCode: VK_SPACE;    Normal: $20;       Shift: $20;      Ctrl: $103; Alt: $20),
    (KeyCode: Ord('0');    Normal: Ord('0');  Shift: Ord(')'); Ctrl: - 1;  Alt: $181),
    (KeyCode: Ord('1');    Normal: Ord('1');  Shift: Ord('!'); Ctrl: - 1;  Alt: $178),
    (KeyCode: Ord('2');    Normal: Ord('2');  Shift: Ord('@'); Ctrl: $103; Alt: $179),
    (KeyCode: Ord('3');    Normal: Ord('3');  Shift: Ord('#'); Ctrl: - 1;  Alt: $17A),
    (KeyCode: Ord('4');    Normal: Ord('4');  Shift: Ord('$'); Ctrl: - 1;  Alt: $17B),
    (KeyCode: Ord('5');    Normal: Ord('5');  Shift: Ord('%'); Ctrl: - 1;  Alt: $17C),
    (KeyCode: Ord('6');    Normal: Ord('6');  Shift: Ord('^'); Ctrl: $1E;  Alt: $17D),
    (KeyCode: Ord('7');    Normal: Ord('7');  Shift: Ord('&'); Ctrl: - 1;  Alt: $17E),
    (KeyCode: Ord('8');    Normal: Ord('8');  Shift: Ord('*'); Ctrl: - 1;  Alt: $17F),
    (KeyCode: Ord('9');    Normal: Ord('9');  Shift: Ord('('); Ctrl: - 1;  Alt: $180),
    (KeyCode: Ord('A');    Normal: Ord('a');  Shift: Ord('A'); Ctrl: $1;   Alt: $11E),
    (KeyCode: Ord('B');    Normal: Ord('b');  Shift: Ord('B'); Ctrl: $2;   Alt: $130),
    (KeyCode: Ord('C');    Normal: Ord('c');  Shift: Ord('C'); Ctrl: $3;   Alt: $12E),
    (KeyCode: Ord('D');    Normal: Ord('d');  Shift: Ord('D'); Ctrl: $4;   Alt: $120),
    (KeyCode: Ord('E');    Normal: Ord('e');  Shift: Ord('E'); Ctrl: $5;   Alt: $112),
    (KeyCode: Ord('F');    Normal: Ord('f');  Shift: Ord('F'); Ctrl: $6;   Alt: $121),
    (KeyCode: Ord('G');    Normal: Ord('g');  Shift: Ord('G'); Ctrl: $7;   Alt: $122),
    (KeyCode: Ord('H');    Normal: Ord('h');  Shift: Ord('H'); Ctrl: $8;   Alt: $123),
    (KeyCode: Ord('I');    Normal: Ord('i');  Shift: Ord('I'); Ctrl: $9;   Alt: $117),
    (KeyCode: Ord('J');    Normal: Ord('j');  Shift: Ord('J'); Ctrl: $A;   Alt: $124),
    (KeyCode: Ord('K');    Normal: Ord('k');  Shift: Ord('K'); Ctrl: $B;   Alt: $125),
    (KeyCode: Ord('L');    Normal: Ord('l');  Shift: Ord('L'); Ctrl: $C;   Alt: $126),
    (KeyCode: Ord('M');    Normal: Ord('m');  Shift: Ord('M'); Ctrl: $D;   Alt: $132),
    (KeyCode: Ord('N');    Normal: Ord('n');  Shift: Ord('N'); Ctrl: $E;   Alt: $131),
    (KeyCode: Ord('O');    Normal: Ord('o');  Shift: Ord('O'); Ctrl: $F;   Alt: $118),
    (KeyCode: Ord('P');    Normal: Ord('p');  Shift: Ord('P'); Ctrl: $10;  Alt: $119),
    (KeyCode: Ord('Q');    Normal: Ord('q');  Shift: Ord('Q'); Ctrl: $11;  Alt: $110),
    (KeyCode: Ord('R');    Normal: Ord('r');  Shift: Ord('R'); Ctrl: $12;  Alt: $113),
    (KeyCode: Ord('S');    Normal: Ord('s');  Shift: Ord('S'); Ctrl: $13;  Alt: $11F),
    (KeyCode: Ord('T');    Normal: Ord('t');  Shift: Ord('T'); Ctrl: $14;  Alt: $114),
    (KeyCode: Ord('U');    Normal: Ord('u');  Shift: Ord('U'); Ctrl: $15;  Alt: $116),
    (KeyCode: Ord('V');    Normal: Ord('v');  Shift: Ord('V'); Ctrl: $16;  Alt: $12F),
    (KeyCode: Ord('W');    Normal: Ord('w');  Shift: Ord('W'); Ctrl: $17;  Alt: $111),
    (KeyCode: Ord('X');    Normal: Ord('x');  Shift: Ord('X'); Ctrl: $18;  Alt: $12D),
    (KeyCode: Ord('Y');    Normal: Ord('y');  Shift: Ord('Y'); Ctrl: $19;  Alt: $115),
    (KeyCode: Ord('Z');    Normal: Ord('z');  Shift: Ord('Z'); Ctrl: $1A;  Alt: $12C),
    (KeyCode: VK_PRIOR;    Normal: $149;      Shift: $149;     Ctrl: $184; Alt: $199),
    (KeyCode: VK_NEXT;     Normal: $151;      Shift: $151;     Ctrl: $176; Alt: $1A1),
    (KeyCode: VK_END;      Normal: $14F;      Shift: $14F;     Ctrl: $175; Alt: $19F),
    (KeyCode: VK_HOME;     Normal: $147;      Shift: $147;     Ctrl: $177; Alt: $197),
    (KeyCode: VK_LEFT;     Normal: $14B;      Shift: $14B;     Ctrl: $173; Alt: $19B),
    (KeyCode: VK_UP;       Normal: $148;      Shift: $148;     Ctrl: $18D; Alt: $198),
    (KeyCode: VK_RIGHT;    Normal: $14D;      Shift: $14D;     Ctrl: $174; Alt: $19D),
    (KeyCode: VK_DOWN;     Normal: $150;      Shift: $150;     Ctrl: $191; Alt: $1A0),
    (KeyCode: VK_INSERT;   Normal: $152;      Shift: $152;     Ctrl: $192; Alt: $1A2),
    (KeyCode: VK_DELETE;   Normal: $153;      Shift: $153;     Ctrl: $193; Alt: $1A3),
    (KeyCode: VK_NUMPAD0;  Normal: Ord('0');  Shift: $152;     Ctrl: $192; Alt: - 1),
    (KeyCode: VK_NUMPAD1;  Normal: Ord('1');  Shift: $14F;     Ctrl: $175; Alt: - 1),
    (KeyCode: VK_NUMPAD2;  Normal: Ord('2');  Shift: $150;     Ctrl: $191; Alt: - 1),
    (KeyCode: VK_NUMPAD3;  Normal: Ord('3');  Shift: $151;     Ctrl: $176; Alt: - 1),
    (KeyCode: VK_NUMPAD4;  Normal: Ord('4');  Shift: $14B;     Ctrl: $173; Alt: - 1),
    (KeyCode: VK_NUMPAD5;  Normal: Ord('5');  Shift: $14C;     Ctrl: $18F; Alt: - 1),
    (KeyCode: VK_NUMPAD6;  Normal: Ord('6');  Shift: $14D;     Ctrl: $174; Alt: - 1),
    (KeyCode: VK_NUMPAD7;  Normal: Ord('7');  Shift: $147;     Ctrl: $177; Alt: - 1),
    (KeyCode: VK_NUMPAD8;  Normal: Ord('8');  Shift: $148;     Ctrl: $18D; Alt: - 1),
    (KeyCode: VK_NUMPAD9;  Normal: Ord('9');  Shift: $149;     Ctrl: $184; Alt: - 1),
    (KeyCode: VK_MULTIPLY; Normal: Ord('*');  Shift: Ord('*'); Ctrl: $196; Alt: $137),
    (KeyCode: VK_ADD;      Normal: Ord('+');  Shift: Ord('+'); Ctrl: $190; Alt: $14E),
    (KeyCode: VK_SUBTRACT; Normal: Ord('-');  Shift: Ord('-'); Ctrl: $18E; Alt: $14A),
    (KeyCode: VK_DECIMAL;  Normal: Ord('.');  Shift: Ord('.'); Ctrl: $153; Alt: $193),
    (KeyCode: VK_DIVIDE;   Normal: Ord('/');  Shift: Ord('/'); Ctrl: $195; Alt: $1A4),
    (KeyCode: VK_F1;       Normal: $13B;      Shift: $154;     Ctrl: $15E; Alt: $168),
    (KeyCode: VK_F2;       Normal: $13C;      Shift: $155;     Ctrl: $15F; Alt: $169),
    (KeyCode: VK_F3;       Normal: $13D;      Shift: $156;     Ctrl: $160; Alt: $16A),
    (KeyCode: VK_F4;       Normal: $13E;      Shift: $157;     Ctrl: $161; Alt: $16B),
    (KeyCode: VK_F5;       Normal: $13F;      Shift: $158;     Ctrl: $162; Alt: $16C),
    (KeyCode: VK_F6;       Normal: $140;      Shift: $159;     Ctrl: $163; Alt: $16D),
    (KeyCode: VK_F7;       Normal: $141;      Shift: $15A;     Ctrl: $164; Alt: $16E),
    (KeyCode: VK_F8;       Normal: $142;      Shift: $15B;     Ctrl: $165; Alt: $16F),
    (KeyCode: VK_F9;       Normal: $143;      Shift: $15C;     Ctrl: $166; Alt: $170),
    (KeyCode: VK_F10;      Normal: $144;      Shift: $15D;     Ctrl: $167; Alt: $171),
    (KeyCode: VK_F11;      Normal: $185;      Shift: $187;     Ctrl: $189; Alt: $18B),
    (KeyCode: VK_F12;      Normal: $186;      Shift: $188;     Ctrl: $18A; Alt: $18C),
    (KeyCode: $DC;         Normal: Ord('\');  Shift: Ord('|'); Ctrl: $1C;  Alt: $12B),
    (KeyCode: $BF;         Normal: Ord('/');  Shift: Ord('?'); Ctrl: - 1;  Alt: $135),
    (KeyCode: $BD;         Normal: Ord('-');  Shift: Ord('_'); Ctrl: $1F;  Alt: $182),
    (KeyCode: $BB;         Normal: Ord('=');  Shift: Ord('+'); Ctrl: - 1;  Alt: $183),
    (KeyCode: $DB;         Normal: Ord('[');  Shift: Ord('{'); Ctrl: $1B;  Alt: $11A),
    (KeyCode: $DD;         Normal: Ord(']');  Shift: Ord('}'); Ctrl: $1D;  Alt: $11B),
    (KeyCode: $BA;         Normal: Ord(';');  Shift: Ord(':'); Ctrl: - 1;  Alt: $127),
    (KeyCode: $DE;         Normal: Ord(''''); Shift: Ord('"'); Ctrl: - 1;  Alt: $128),
    (KeyCode: $BC;         Normal: Ord(',');  Shift: Ord('<'); Ctrl: - 1;  Alt: $133),
    (KeyCode: $BE;         Normal: Ord('.');  Shift: Ord('>'); Ctrl: - 1;  Alt: $134),
    (KeyCode: $C0;         Normal: Ord('`');  Shift: Ord('~'); Ctrl: - 1;  Alt: $129)
  );

var
  ExtendedChar: Char = #0;

function FindKeyCode(KeyCode: Smallint): PKey; {$IFDEF INLINES}inline;{$ENDIF}
var
  I: Integer;
begin
  for I := 0 to High(CKeys) do
    if CKeys[I].KeyCode = KeyCode then
    begin
      Result := @CKeys[I];
      Exit;
    end;
  Result := nil;
end;

// This has a complexity of 11, because of the if else ladder.
// That bugs me a bit. Looking for something more elegant.
function TranslateKey(const Rec: TInputRecord; State: Integer; Key: PKey; KeyCode: Integer): Smallint;
begin
  if State and (RIGHT_ALT_PRESSED or LEFT_ALT_PRESSED) <> 0 then
    Result := Key^.Alt
  else if State and (RIGHT_CTRL_PRESSED or LEFT_CTRL_PRESSED) <> 0 then
    Result := Key^.Ctrl
  else if State and SHIFT_PRESSED <> 0 then
    Result := Key^.Shift
  else if KeyCode in [Ord('A')..Ord('Z')] then
    Result := Ord(Rec.Event.KeyEvent.AsciiChar)
  else
    Result := Key^.Normal;
end;

function ConvertKey(const Rec: TInputRecord; Key: PKey): Smallint;
  {$IFDEF INLINES}inline;{$ENDIF}
begin
  if Assigned(Key) then
    Result := TranslateKey(Rec, Rec.Event.KeyEvent.dwControlKeyState,
      Key, Rec.Event.KeyEvent.wVirtualKeyCode)
  else
    Result := -1
end;

function ReadKey: Char;
var
  InputRec: TInputRecord;
  NumRead: Cardinal;
  KeyMode: DWORD;
  KeyCode: Smallint;
begin
  if ExtendedChar <> #0 then
  begin
    Result := ExtendedChar;
    ExtendedChar := #0;
    Exit;
  end
  else
  begin
    Result := #$FF;
    GetConsoleMode(StdIn, KeyMode);
    SetConsoleMode(StdIn, 0);
    repeat
      ReadConsoleInput(StdIn, InputRec, 1, NumRead);
      if (InputRec.EventType and KEY_EVENT <> 0) and
         InputRec.Event.KeyEvent.bKeyDown then
      begin
        if InputRec.Event.KeyEvent.AsciiChar <> #0 then
        begin
          // From Delphi 2009 on, Result is WideChar
          Result := Chr(Ord(InputRec.Event.KeyEvent.AsciiChar));
          Break;
        end;
        KeyCode := ConvertKey(InputRec,
          FindKeyCode(InputRec.Event.KeyEvent.wVirtualKeyCode));
        if KeyCode > $FF then
        begin
          ExtendedChar := Chr(KeyCode and $FF);
          Result := #0;
          Break;
        end;
      end;
    until False;
    SetConsoleMode(StdIn, KeyMode);
  end;
end;

function KeyPressed: Boolean;
var
  InputRecArray: array of TInputRecord;
  NumRead: DWORD;
  NumEvents: DWORD;
  I: Integer;
  KeyCode: Word;
begin
  Result := False;
  GetNumberOfConsoleInputEvents(StdIn, NumEvents);
  if NumEvents = 0 then
    Exit;
  SetLength(InputRecArray, NumEvents);
  PeekConsoleInput(StdIn, InputRecArray[0], NumEvents, NumRead);
  for I := 0 to High(InputRecArray) do
  begin
    if (InputRecArray[I].EventType and Key_Event <> 0) and
       InputRecArray[I].Event.KeyEvent.bKeyDown then
    begin
      KeyCode := InputRecArray[I].Event.KeyEvent.wVirtualKeyCode;
      if not (KeyCode in [VK_SHIFT, VK_MENU, VK_CONTROL]) then
      begin
        if ConvertKey(InputRecArray[I], FindKeyCode(KeyCode)) <> -1 then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure InitScreenMode;
var
  BufferInfo: TConsoleScreenBufferInfo;
begin
  Reset(Input);
  Rewrite(Output);
  StdIn := TTextRec(Input).Handle;
  StdOut := TTextRec(Output).Handle;
{$IFDEF HASERROUTPUT}
  Rewrite(ErrOutput);
  StdErr := TTextRec(ErrOutput).Handle;
{$ELSE}
  StdErr := GetStdHandle(STD_ERROR_HANDLE);
{$ENDIF}
end;


end.

