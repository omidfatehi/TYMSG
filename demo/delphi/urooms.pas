unit urooms;

interface

uses
  SysUtils, Classes, Controls, Forms, ExtCtrls, ComCtrls, StdCtrls, ImgList;

type
  TfrmRooms = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    TreeCat: TTreeView;
    TreeRoom: TTreeView;
    ImageList1: TImageList;
    procedure TreeCatDblClick(Sender: TObject);
    procedure TreeRoomDblClick(Sender: TObject);
  private
  public
  end;

var
  frmRooms: TfrmRooms;

implementation

uses mainunit,dialogs;

{$R *.dfm}

procedure TfrmRooms.TreeCatDblClick(Sender: TObject);
var
  node:TTreeNode;
  EN:TElementNode;
  id:string;
begin
  if not frmMain.fLogin then
    Exit;

  node := TreeCat.Selected;
  if (node=nil) or (node.Data=nil) or (node.HasChildren) then
    Exit;

  EN := TElementNode(node.Data);
  id := EN.Attr.Values['id'];
  if (id='') then Exit;
  frmMain.ym.GetChatRooms(StrToIntDef(id,0));
end;

procedure TfrmRooms.TreeRoomDblClick(Sender: TObject);
var
  node:TTreeNode;
  EN:TElementNode;
  id,rn,lobby:string;
  i:integer;
begin
  if not frmMain.fLogin then
    Exit;

  node := TreeRoom.Selected;
  if (node=nil) or (node.Data=nil) or (node.HasChildren) then
    Exit;

  EN := TElementNode(node.Parent.Data);
  id := EN.Attr.Values['id'];
  rn := EN.Attr.Values['name'];

  lobby := TElementNode(node.Data).Attr.Values['count'];
  
  ShowMessage('RN: '+rn+':'+lobby+#13#10+'ID: '+id);

  i := StrToIntDef(id,0);
  
  if (id='') or (i=0) or (rn='') or (lobby='') then Exit;
  frmMain.ym.JoinChatRoom(rn+':'+lobby,i);
  Close;
end;

end.
