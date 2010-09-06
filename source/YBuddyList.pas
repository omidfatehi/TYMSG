{
  Original code: TYMsgCore - http://sourceforge.net/projects/tymsgcore
  Author: Hamid_PaK [PRAISER] - praiser_man@yahoo.com

  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YBuddyList;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Sysutils, Classes, YMsgConst;

type
  TYBuddyGroup = class;
  TYBuddy = class(TCollectionItem)
  private
    FYID: String;
    FState: TYStatus;
    FStatus: String;
    FBusy: Boolean;
    function GetGroup: String;
  public
    property YID: String read FYID write FYID;
    property State: TYStatus read FState write FState;
    property Status: String read FStatus write FStatus;
    property Busy: Boolean read FBusy write FBusy;
    property GroupName: String read GetGroup;

    procedure AfterConstruction; override;
  end;

  TYBuddyList = class(TCollection)
  private
    FGName: String;
    function GetItem(Idx: Integer): TYBuddy;
    procedure SetItem(Idx: Integer; Value: TYBuddy);
  public
    property Items[Index: Integer]: TYBuddy read GetItem write SetItem;

    function Add: TYBuddy; overload;
    function Add(AYID: String): TYBuddy; overload;
    function Insert(Idx: Integer): TYBuddy;
  end;

  TYBuddyGroup = class(TCollectionItem)
  private
    FGroupName: String;
    FBuddyList: TYBuddyList;
  public
    property Buddies: TYBuddyList read FBuddyList write FBuddyList;
    property GroupName: String read FGroupName;
  end;

  TYBuddyGroupList = class(TCollection)
  private
    function GetItem(Idx: Integer): TYBuddyGroup;
    //procedure SetStrList(Value: String);
    procedure SetItem(Idx: Integer; Value: TYBuddyGroup);
  public
    property Groups[Index: Integer]: TYBuddyGroup read GetItem write SetItem;

    function Add(AGroupName: String): TYBuddyGroup;
    function Insert(Idx: Integer): TYBuddyGroup;
    function FindGroup(AGroupName: String): Integer;
    function FindYID(YahooID: String; var Rslt: TYBuddy): Boolean;
    //procedure Write(Value: String);
  end;

implementation

procedure TYBuddy.AfterConstruction;
begin
  inherited;
  FState := ysOffline;
  FBusy := False;
end;

function TYBuddy.GetGroup: String;
begin
  Result := TYBuddyList(Collection).FGName;
end;

function TYBuddyList.Add: TYBuddy;
begin
  Result := TYBuddy(inherited Add);
end;

function TYBuddyList.Add(AYID: String): TYBuddy;
begin
  Result := Add;
  with Result do begin
    FYID := AYID;
  end;
end;

function TYBuddyList.GetItem;
begin
  Result := TYBuddy(inherited Items[Idx]);
end;

function TYBuddyList.Insert;
begin
  Result := TYBuddy(inherited Insert(Idx));
end;

procedure TYBuddyList.SetItem;
begin
  inherited Items[Idx] := Value;
end;

function TYBuddyGroupList.Add(AGroupName: String): TYBuddyGroup;
begin
  Result := TYBuddyGroup(inherited Add);
  with Result do begin
    FBuddyList := TYBuddyList.Create(TYBuddy);
    FBuddyList.FGName := AGroupName; 
    FGroupName := AGroupName;
  end;
end;

function TYBuddyGroupList.FindGroup(AGroupName: String): Integer;
begin
  for Result := 0 to Count -1 do
    if (Groups[Result].FGroupName = AGroupName) then Exit;
  Result := -1;
end;

function TYBuddyGroupList.FindYID;
var
  i,x: Integer;
begin
  Result := False;
  for i := 0 to Count -1 do begin
    for x := 0 to Groups[i].Buddies.Count -1 do begin
      if (LowerCase(Groups[i].Buddies.Items[x].FYID) = LowerCase(YahooID)) then begin
        Rslt := Groups[i].Buddies.Items[x];
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TYBuddyGroupList.GetItem;
begin
  Result := TYBuddyGroup(inherited Items[idx]);
end;

function TYBuddyGroupList.Insert;
begin
  Result := TYBuddyGroup(inherited Insert(Idx));
end;

procedure TYBuddyGroupList.SetItem;
begin
  inherited Items[Idx] := Value;
end;

{
procedure TYBuddyGroupList.SetStrList;
var
  idx: Integer;
  p, start: PChar;
  s,
  grp: String;
  dum: TYBuddy;
begin
  BeginUpdate;
  try
    //Clear;
    p := Pointer(Value);
    if (p <> nil) then
      grp := 'None';
      while (p^ <> #0) do begin
        start := p;
        while not (p^ in [#13, #10, ':', ',']) do Inc(p);
        case p^ of
          ':':
          begin
            SetString(grp, start, p -start);
            Inc(p);
          end;

          #13, #10, ',':
          begin
            SetString(s, start, p -start);
            Inc(p);
            idx := FindGroup(grp);
            if (idx < 0) then begin
              with Add(grp) do idx := Index;
            end;
            if (not FindYID(s, dum)) then
            with Groups[idx].Buddies.Add(s) do FState := ysOffline;
          end;
          else Inc(p);
        end;
      end;
  finally
    EndUpdate;
  end;
end;

procedure TYBuddyGroupList.Write;
begin
  SetStrList(Value);
end;
}
end.
