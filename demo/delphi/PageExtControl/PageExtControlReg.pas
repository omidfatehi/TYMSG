unit PageExtControlReg;

interface
uses
  Windows, Messages, SysUtils, Classes, Dialogs, {ListViewExt,} ImgList,
  DesignWindows,  Menus, ExtCtrls, DesignIntf, ActnList, ToolWin,  ToolWnds,
  DesignEditors, ActnPopup, LibHelp, DsnConst,
  PageExtControl;

type
  TPageExtControleEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    function FindUniqueName(const Name: string): string;
  end;

procedure Register;

implementation
uses ComStrs;

 {Change Strings to your preferred language}
resourcestring
 sTABSHEET_DEFAULT_NAME = 'TTabExtSheet';
 sNEW_PAGE              = 'Ne&w Page';
 sDEL_PAGE              = '&Delete Page';
 sNEXT_PAGE             = 'Ne&xt Page';
 sPREV_PAGE             = '&Previouse Page';

procedure Register;
begin
//  RegisterComponents('sarcon', [TTabSheetes]);
  RegisterComponents('Souls', [TPageExtControl]);
 // RegisterComponents('sarcon', [TPageControlBles]);
  RegisterComponentEditor(TPageExtControl, TPageExtControleEditor);
  RegisterComponentEditor(TTabExtSheet, TPageExtControleEditor);
  RegisterNoIcon([TTabExtSheet]);
  RegisterClasses([TTabExtSheet]);
end;

{ TPageControlesEditor }

function TPageExtControleEditor.FindUniqueName(const Name: string): string;
var
  FFormDesigner: IDesigner;
begin
  FFormDesigner:=GetDesigner;
  Result := FFormDesigner.UniqueName(Name);
end;

procedure TPageExtControleEditor.ExecuteVerb(Index: Integer);
var
  NewPage: TTabExtSheet;
  PControl : TPageExtControl;
begin
  if Component is TPageExtControl then
    PControl := TPageExtControl(Component)
  else PControl := TPageExtControl(TTabExtSheet(Component).PageExtControl);

  case Index of
    0:  begin  //  New Page
          NewPage := TTabExtSheet.Create(Designer.GetRoot);
          with NewPage do
          begin
            Parent := PControl;
            PageExtControl := PControl;
            Name  :=  FindUniqueName(sTABSHEET_DEFAULT_NAME);
            Caption  := Name;
          end;
        end;
    1:  begin  //  Delete Page
          with PControl do
          begin
            NewPage := TTabExtSheet(ActivePage);
            NewPage.PageExtControl := nil;
            NewPage.Free;
          end;
        end;
    2:  begin  //  Next Page
          PControl.FindNextPage(PControl.ActivePage,True,False);
        end;
    3:  begin  //  Previous Page
          PControl.FindNextPage(PControl.ActivePage,False,False);
        end;
  end;
  if Designer <> nil then Designer.Modified;
end;

function TPageExtControleEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0:  result := sNEW_PAGE;
    1:  result := sDEL_PAGE;
    2:  result := sNEXT_PAGE;
    3:  result := sPREV_PAGE;
  end;
end;

function TPageExtControleEditor.GetVerbCount: Integer;
begin
  result := 4;
end;

end.
 