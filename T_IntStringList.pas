unit T_IntStringList;

interface

uses System.Classes;

type
  TIntStringList = class(TStringList)
  private
    function GetInt(const Index : integer) : integer;
    procedure SetInt(const Index : integer; const Value : integer);
  public
    function AddItem(const sValue : string; const iValue : integer) : integer;
    property Ints[const Idx : integer] : integer read GetInt write SetInt;
  end;

implementation

{$WARN UNSAFE_CAST OFF}
function TIntStringList.GetInt(const Index : integer) : integer;
begin
  Result := integer(Objects[Index]);
end;

procedure TIntStringList.SetInt(const Index : integer; const Value : integer);
begin
  Objects[Index] := TObject(Value);
end;

function TIntStringList.AddItem(const sValue : string; const iValue : integer) : integer;
begin
  Result := AddObject(sValue, TObject(iValue));
end;
{$WARN UNSAFE_CAST DEFAULT}

end.
