{
  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YChatList;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Sysutils, Classes, YMsgConst;

type
  TYChat = class(TPersistent)
  private
    FYID: string;
    FAge: integer;
    FAttribs: integer;
    FAlias: string;
    FLocation: string;
  public
    property YID: String read FYID write FYID;
    property Age: Integer read FAge write FAge;
    property Attribs: integer read FAttribs write FAttribs;
    property Alias: string read FAlias write FAlias;
    property Location: string read FLocation write FLocation;
  end;

  TYChatList = class(TPersistent)
  private
    FList: TList;
    function GetItem(Idx: Integer): TYChat;
    procedure SetItem(Idx: Integer; Value: TYChat);
    function GetCount:integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TYChat; overload;
    procedure Add(cYID, cAlias, cLocation : string; cAge, cAttribs: integer); overload;
    function IndexOf(cYID: string): Integer;
    procedure Clear;
    procedure Delete(Idx: integer);
    property Chatter[Index: Integer]: TYChat read GetItem write SetItem;
    property ChatterCount: Integer read GetCount;
  end;

implementation

{ TYChatList }

function TYChatList.Add: TYChat;
var
  idx: Integer;
begin
  idx := FList.Add( Pointer( TYChat.Create ));
  Result := TYChat( FList[ idx ]);
end;

procedure TYChatList.Add(cYID, cAlias, cLocation : string; cAge, cAttribs: integer);
begin
  with Add do begin
    YID := cYID;
    Age := cAge;
    Attribs := cAttribs;
    Alias := cAlias;
    Location := cLocation;
  end;
end;

procedure TYChatList.Clear;
begin
  FList.Clear;
end;

constructor TYChatList.Create;
begin
  inherited;
  FList := TList.Create;
end;

procedure TYChatList.Delete(Idx: integer);
begin
  FList.Delete(Idx);
end;

destructor TYChatList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TYChatList.GetCount: integer;
begin
  Result := FList.Count;
end;

function TYChatList.GetItem(Idx: Integer): TYChat;
begin
  Result := TYChat(FList.Items[Idx]);
end;

function TYChatList.IndexOf(cYID: string): Integer;
begin
  for Result := 0 to ChatterCount -1 do
    if Chatter[ Result ].YID = cYID then Exit;
  Result := -1;
end;

procedure TYChatList.SetItem(Idx: Integer; Value: TYChat);
begin
  FList[Idx] := Pointer(Value);
end;

end.
