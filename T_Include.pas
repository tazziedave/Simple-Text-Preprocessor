unit T_Include;

interface

uses
  System.Generics.Collections;

const ARRAY_DELTA = 20;

type
  TIncludeStatus = (isDefine = 1, isHardDefine, isUndefine, isHardUndefine, isNotDefined);
  TConditional = record
    Conditional : string;
    Status : TIncludeStatus;
  end;

  TInclude = class
  constructor Create;

  private
    FIncludes : array of TConditional;
    FIncludeCount : Integer;
    FDefines : array of string;
    FDefineCount : Integer;

    function GetIncludeItem(const sDefinition : string; var index : Integer) : TIncludeStatus;

    function SetItem(const sDefinition : string; const IncludeStatus : TIncludeStatus)  : boolean;
    procedure RefreshDefines;

    procedure IncreaseIncludes;
    procedure IncreaseDefines;
  public
    function Define(const sDefinition : string)  : boolean;
    function Undefine(const sDefinition : string) : boolean;
    procedure HardDefine(const sDefinition : string);
    procedure HardUndefine(const sDefinition : string);

    function Defined(const sDefinition : string) : boolean;
  end;

implementation

constructor TInclude.Create;
begin
    inherited Create;
    IncreaseIncludes;
    IncreaseDefines;
    FIncludeCount := -1;
    FDefineCount := -1;

end;

procedure TInclude.IncreaseIncludes;
begin
    SetLength(FIncludes, Length(FIncludes) + ARRAY_DELTA);
end;

procedure TInclude.IncreaseDefines;
begin
    SetLength(FDefines, Length(FDefines) + ARRAY_DELTA);
end;

function TInclude.GetIncludeItem(const sDefinition : string; var index : Integer) : TIncludeStatus;
var
  i : Integer;
begin
  Result := isNotDefined;
  index := -1;
  for i := 0 to FIncludeCount do
  begin
    if sDefinition = FIncludes[i].Conditional then
    begin
      index := i;
      Exit(FIncludes[i].Status);
    end;
  end;
end;

function TInclude.SetItem(const sDefinition : string; const IncludeStatus : TIncludeStatus) : boolean;
var
  CurrentIncludeStatus : TIncludeStatus;
  i : Integer;
begin
  Result := True;

  CurrentIncludeStatus := GetIncludeItem(sDefinition, i);
  if CurrentIncludeStatus = isNotDefined then
  begin
      FIncludeCount := FIncludeCount + 1;

      if FIncludeCount = Length(FIncludes) then
        IncreaseIncludes;

      FIncludes[FIncludeCount].Conditional := sDefinition;
      FIncludes[FIncludeCount].Status := IncludeStatus;
  end
  else
  begin
    case IncludeStatus of
    isHardDefine, isHardUndefine:
      FIncludes[i].Status := IncludeStatus;
    isDefine, isUndefine:
      if not (CurrentIncludeStatus in [isHardDefine, isHardUndefine]) then
        FIncludes[i].Status := IncludeStatus
      else
        Result := False;
    end;
  end;
  RefreshDefines;
end;

procedure TInclude.RefreshDefines;
var
  i : Integer;
begin
  FDefineCount := -1;
  for i := 0 to FIncludeCount do
  begin
    if FIncludes[i].Status in [isDefine, isHardDefine] then
    begin
      FDefineCount := FDefineCount + 1;
      if FDefineCount = Length(FDefines) then
        IncreaseDefines;
      FDefines [FDefineCount]:= FIncludes[i].Conditional;
    end;
  end;

end;

function TInclude.Define(const sDefinition : string) : boolean;
begin
   Result := SetItem(sDefinition, isDefine);
end;

procedure TInclude.HardDefine(const sDefinition : string);
begin
   SetItem(sDefinition, isHardDefine);
end;

function TInclude.Undefine(const sDefinition : string) : boolean;
begin
   Result := SetItem(sDefinition, isUndefine);
end;

procedure TInclude.HardUndefine(const sDefinition : string);
begin
   SetItem(sDefinition, isHardUndefine);
end;

function TInclude.Defined(const sDefinition : string) : boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to FDefineCount do
  begin
      if FDefines [i] = sDefinition then
        Exit(True);
  end;
end;

end.
