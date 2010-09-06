unit PageExtControl;
{$R-,T-,H+,X+}
{##############################################################################
 @  TPageExtControl Component                                                 @
 @                                                                            @
 @  Clone of TPageControl with added fetures -:                               @
 @                                                                            @
 @  Close button on Tabs                                                      @
 @  Small or Larg Close Button                                                @
 @  Color/Gradient -- ActiveTabs/InactiveTabs                                 @
 @  Font for ActiveTabs/InactiveTabs                                          @
 @  Indavidual color for TTabExtSheet                                         @
 @  Picture Property for when there are no tabs showing                       @
 @  Flat Property make it flat when one or more tabs are visable              @
 @  OncloseTab Property with CanClose Var                                     @
 @  OnTabClick Property                                                       @
 @  OnTabDelete Property fires when the tab is been nil                       @
 @  TabDragDrop Property when enabled alows user to drag & drop Tabs          @
 @                                                                            @
 @  Version := 1.0                                                            @
 @                                                                            @
 @  Legal Notice!:                                                            @
 @  This component is Free you have to right to use in any program you want   @
 @  You have the right to modify the contants as long as this infomation      @
 @  remains here and not alterd in any way shape or "form"!                   @
 @  This Component must Remain FREE and cannot be sold for any amout of       @
 @  profit!                                                                   @
 @                                                                            @
 @  Any Improvements found made please email me a copy                        @
 @  Any bugs found please emale me.                                           @
 @  Contact details:                                                          @
 @  Aurther: Scott Pettit                                                     @
 @  Copyright Holder: Scott pettitt                                           @
 @  Website: http://confuddledsoul.freepgs.com/                               @
 @  Email: dotdot6@dodo.com.au                                                @
 @                                                                            @
 @  Copyright© Scott Pettit 2005-2006                                         @
 @                                                                            @
 @ In Progress...                                                             @
 @ Picture property for indavidual tabs                                       @
 @ Working out why the Windows fillrect wont fill the close button in         @
 @ Working out why the picture will show after you close a tab when           @
 @ there are tabs still open should on show when no tabs are visable.         @
 ##############################################################################}


interface

uses
  {$IFDEF LINUX}
  WinUtils,
  {$ENDIF}
  Messages, Windows, SysUtils, CommCtrl, Classes, Controls, Forms, Menus,
  Graphics, StdCtrls, RichEdit, ToolWin, ImgList, ExtCtrls, ListActns,
  ShlObj, Dialogs;

const
  TXT_MARG: TPoint = (x: 4; y: 2);
  BTN_WIDTH = 12;

type
  THitTest = (htAbove, htBelow, htNowhere, htOnItem, htOnButton, htOnIcon,
    htOnIndent, htOnLabel, htOnRight, htOnStateIcon, htToLeft, htToRight);
  THitTests = set of THitTest;

  TCustomTabExtControl = class;

  TTabExtChangingEvent = procedure(Sender: TObject;
    var AllowChange: Boolean) of object;

  TTabExtPosition = (tpTop, tpBottom, tpLeft, tpRight);

  TTabExtStyle = (tsTabs, tsButtons, tsFlatButtons);
  TGradientStyle = (gsHorizontal, gsVertical, gsElliptic, gsRectangle,
                                     gsVertCenter, gsHorizCenter);
  TDrawTabExtEvent = procedure(Control: TCustomTabExtControl; TabIndex: Integer;
    const Rect: TRect; Active: Boolean) of object;
  TTabExtGetImageEvent = procedure(Sender: TObject; TabIndex: Integer;
    var ImageIndex: Integer) of object;
  TTabClose = Procedure(Sender: TObject; TabIndex: Integer;
  var CanClose: Boolean) of object;
  TTabDelete = Procedure(Sender: TObject; TabIndex: Integer) of Object;
  TTabClick = Procedure(Sender : TObject; TabIndex : Integer) of Object;

  TCustomTabExtControl = class(TWinControl)
  private
    FCanvas: TCanvas;
    FHotTrack: Boolean;
    FImageChangeLink: TChangeLink;
    FImages: TCustomImageList;
    FMultiLine: Boolean;
    FMultiSelect: Boolean;
    FOwnerDraw: Boolean;
    FRaggedRight: Boolean;
    FSaveTabIndex: Integer;
    FSaveTabs: TStringList;
    FScrollOpposite: Boolean;
    FStyle: TTabExtStyle;
    FTabPosition: TTabExtPosition;
    FTabs: TStrings;
    FTabSize: TSmallPoint;
    FUpdating: Boolean;
    FSavedAdjustRect: TRect;
    FOnChange: TNotifyEvent;
    FOnChanging: TTabExtChangingEvent;
    FOnDrawTabExt: TDrawTabExtEvent;
    FOnGetImageIndex: TTabExtGetImageEvent;
    FCloseButton : Boolean;
    FSmallCloseBtn: Boolean;
    FPicture: TPicture;
    FFlat : Boolean;
    FCanDragDrop: Boolean;
    FGradientFill: Boolean;
    Function GetClose:Boolean;
    procedure SetClose(Value : Boolean);
    procedure SetPicture(Const Value : TPicture);
    function GetDisplayRect: TRect;
    function GetTabIndex: Integer;
    procedure ImageListChange(Sender: TObject);
    function InternalSetMultiLine(Value: Boolean): Boolean;
    procedure SetHotTrack(Value: Boolean);
    procedure SetImages(Value: TCustomImageList);
    procedure SetMultiLine(Value: Boolean);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetOwnerDraw(Value: Boolean);
    procedure SetRaggedRight(Value: Boolean);
    procedure SetScrollOpposite(Value: Boolean);
    procedure SetStyle(Value: TTabExtStyle);
    procedure SetTabHeight(Value: Smallint);
    procedure SetTabPosition(Value: TTabExtPosition);
    procedure SetTabs(Value: TStrings);
    procedure SetTabWidth(Value: Smallint);
    procedure TabsChanged;
    procedure UpdateTabSize;
    procedure CMFontChanged(var Message); message CM_FONTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMTabStopChanged(var Message: TMessage); message CM_TABSTOPCHANGED;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure TCMAdjustRect(var Message: TMessage); message TCM_ADJUSTRECT;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMNotifyFormat(var Message: TMessage); message WM_NOTIFYFORMAT;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure WMPAINT(var Msg: TWMPAINT);message WM_PAINT;
    procedure WndProc(var Message:TMessage); override;
    procedure SetFlat(Value : Boolean);
    procedure SetGradientFill(value : Boolean);
    procedure SetSmallCloseBtn(const Value: boolean);
  protected
    function GetBtnRect(TabIndex: integer; Complete: boolean; TP: TTabExtPosition): TRect;
    procedure AdjustClientRect(var Rect: TRect); override;
    function CanChange: Boolean; dynamic;
    function CanShowTab(TabIndex: Integer): Boolean; virtual;
    procedure Change; dynamic;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    property CloseBtn : boolean read GetClose write SetClose default False;
    property SmallCloseBtn : boolean read FSmallCloseBtn write SetSmallCloseBtn default True;
    procedure DrawTabExt(TabIndex: Integer; const Rect: TRect; Active: Boolean); virtual;
    function GetImageIndex(TabIndex: Integer): Integer; virtual;
    procedure Loaded; override;
    procedure UpdateTabImages;
    property DisplayRect: TRect read GetDisplayRect;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property Images: TCustomImageList read FImages write SetImages;
    property MultiLine: Boolean read FMultiLine write SetMultiLine default False;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetTabIndex(Value: Integer); virtual;
    property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw default False;
    property RaggedRight: Boolean read FRaggedRight write SetRaggedRight default False;
    property ScrollOpposite: Boolean read FScrollOpposite
      write SetScrollOpposite default False;
    property Style: TTabExtStyle read FStyle write SetStyle default tsTabs;
    property TabHeight: Smallint read FTabSize.Y write SetTabHeight default 0;
    property TabIndex: Integer read GetTabIndex write SetTabIndex default -1;
    property TabPosition: TTabExtPosition read FTabPosition write SetTabPosition
      default tpTop;
    property Tabs: TStrings read FTabs write SetTabs;
    property TabWidth: Smallint read FTabSize.X write SetTabWidth default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TTabExtChangingEvent read FOnChanging write FOnChanging;
    property OnDrawTabExt: TDrawTabExtEvent read FOnDrawTabExt write FOnDrawTabExt;
    property OnGetImageIndex: TTabExtGetImageEvent read FOnGetImageIndex write FOnGetImageIndex;
    property Picture : TPicture read FPicture  write SetPicture;
    property Flat : Boolean read FFlat write SetFlat default False;
    Property TabDragDrop: boolean read FCanDragDrop write FCanDragDrop default False;
    property TabFillGradient : Boolean read FGradientFill write setGradientFill default false;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfTabAt(X, Y: Integer): Integer;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function TabRect(Index: Integer): TRect;
    function RowCount: Integer;
    procedure ScrollTabs(Delta: Integer);
    property Canvas: TCanvas read FCanvas;
    property TabStop default True;
  end;
  TTabExtSheet = Class;
  TPageExtControl = class;

  TTabColors = Class(TPersistent)
  private
    FColor       : TColor;
    FAFontColor  : TColor;
    FIAFontColor : TColor;
    FATabColor   : TColor;
    FATabColor2  : TColor;
    FIATabColor  : TColor;
    FIATabColor2 : TColor;
    FOwner       : TTabExtSheet;
    procedure SetColor(Value : TColor);
    procedure SetAFontColor(Value : TColor);
    procedure SetIAFontColor(Value : TColor);
    procedure SetATabColor(Value : TColor);
    procedure SetATabColor2(Value : TColor);
    procedure SetIATabColor(Value : TColor);
    procedure SetIATabColor2(Value : TColor);

  public
    constructor Create(AOwner: TComponent);
  published
    Property Color             : TColor read FColor        write SetColor       default clBtnFace;
    Property ActiveFontColor   : TColor read FAFontColor   write SetAFontColor  default clCaptionText;
    Property InActiveFontColor : TColor read FIAFontColor  write SetIAFontColor default clInActiveCaptionText;
    Property ActiveFill1       : TColor read FATabColor    write SetATabColor   default clActiveCaption;
    property ActiveFill2       : TColor read FATabColor2   write SetATabColor2  default clGradientActiveCaption;
    property InActivefill1     : TColor read FIATabColor   write SetIATabColor  default clInactiveCaption;
    property InActivefill2     : TColor read FIATabColor2  write SetIATabColor2 default clGradientInActiveCaption;
  end;

  TTabExtControl = class(TCustomTabExtControl)
  public
    property DisplayRect;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property CloseBtn;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Flat;
    property HotTrack;
    property Images;
    property MultiLine;
    property MultiSelect;
    property OwnerDraw;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property Picture;
    property PopupMenu;
    property RaggedRight;
    property ScrollOpposite;
    property ShowHint;
    property SmallCloseBtn;
    property Style;
    Property TabDragDrop;
    property TabHeight;
    property TabOrder;
    property TabPosition;
    property Tabs;
    property TabFillGradient;
    property TabIndex;  // must be after Tabs
    property TabStop;
    property TabWidth;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawTabExt;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  TTabExtSheet = class(TWinControl)
  private
    FImageIndex: TImageIndex;
    FPageExtControl: TPageExtControl;
    FTabVisible: Boolean;
    FTabShowing: Boolean;
    FHighlighted: Boolean;
    FOnHide: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FColors : TTabColors;
    //FPicture  : TPicture;
    function GetPageIndex: Integer;
    function GetTabIndex: Integer;
    //function GetPicture: TPicture;
    procedure SetHighlighted(Value: Boolean);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetPageControl(APageControl: TPageExtControl);
    procedure SetPageIndex(Value: Integer);
    //procedure SetPicture(Const Value: TPicture);
    procedure SetTabShowing(Value: Boolean);
    procedure SetTabVisible(Value: Boolean);
    procedure UpdateTabShowing;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoHide; dynamic;
    procedure DoShow; dynamic;
    procedure ReadState(Reader: TReader); override;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure SetTabColors(const Value: TTabColors);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property PageExtControl: TPageExtControl read FPageExtControl write SetPageControl;
    property TabIndex: Integer read GetTabIndex;
  published
    property Colors : TTabColors read FColors write SetTabColors;
    property Caption;
    property DragMode;
    property Enabled;
    property Font;
    property Height stored False;
    property Highlighted: Boolean read FHighlighted write SetHighlighted default False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default 0;
    property Left stored False;
    property Constraints;
    property PageIndex: Integer read GetPageIndex write SetPageIndex stored False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabVisible: Boolean read FTabVisible write SetTabVisible default True;
    property Top stored False;
    property Visible stored False;
    property Width stored False;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnStartDrag;

  end;

  TPageExtControl = class(TCustomTabExtControl)
  private
    FPages: TList;
    FActivePage: TTabExtSheet;
    FNewDockSheet: TTabExtSheet;
    FUndockingPage: TTabExtSheet;
    FInSetActivePage: Boolean;
    FTabClose: TTabClose;
    FTabClick: TTabClick;
    FTabDelete: TTabDelete;
    FCloseHot: Boolean;
    procedure ChangeActivePage(Page: TTabExtSheet);
    procedure DeleteTab(Page: TTabExtSheet; Index: Integer);
    function GetActivePageIndex: Integer;
    function GetDockClientFromMousePos(MousePos: TPoint): TControl;
    function GetPage(Index: Integer): TTabExtSheet;
    function GetPageCount: Integer;
    procedure InsertPage(Page: TTabExtSheet);
    procedure InsertTab(Page: TTabExtSheet);
    procedure MoveTab(CurIndex, NewIndex: Integer);
    procedure RemovePage(Page: TTabExtSheet);
    procedure SetActivePageIndex(const Value: Integer);
    procedure UpdateTab(Page: TTabExtSheet);
    procedure UpdateTabHighlights;
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
    procedure CMDockNotification(var Message: TCMDockNotification); message CM_DOCKNOTIFICATION;
    procedure CMUnDockClient(var Message: TCMUnDockClient); message CM_UNDOCKCLIENT;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;

  protected
    procedure GradientFillRect(Canvas: TCanvas; Rect: TRect;
                           BeginClr, EndClr: TColor; style: TGradientStyle);
    function CanShowTab(TabIndex: Integer): Boolean; override;
    procedure Change; override;
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); override;
    procedure DockOver(Source: TDragDockObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    procedure DoRemoveDockClient(Client: TControl); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetImageIndex(TabIndex: Integer): Integer; override;
    function GetPageFromDockClient(Client: TControl): TTabExtSheet;
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect;
      MousePos: TPoint; var CanDock: Boolean); override;
    procedure Loaded; override;
    procedure SetActivePage(Page: TTabExtSheet);
    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    procedure SetTabIndex(Value: Integer); override;
    procedure ShowControl(AControl: TControl); override;
    procedure UpdateActivePage; virtual;
    Function DoTabClose(TabIndex: integer): boolean;
    procedure DrawTabExt(TabIndex: Integer; const Rect: TRect; Active: Boolean);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    Procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
              State: TDragState; var Accept: Boolean);override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindNextPage(CurPage: TTabExtSheet;
      GoForward, CheckTabVisible: Boolean): TTabExtSheet;
    procedure SelectNextPage(GoForward: Boolean; CheckTabVisible: Boolean = True);
    property ActivePageIndex: Integer read GetActivePageIndex
      write SetActivePageIndex;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TTabExtSheet read GetPage;

  published
    property ActivePage: TTabExtSheet read FActivePage write SetActivePage;
    property Align;
    property Anchors;
    property BiDiMode;
    property CloseBtn;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Flat;
    property HotTrack;
    property Images;
    property MultiLine;
    property OwnerDraw;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property Picture;
    property PopupMenu;
    property RaggedRight;
    property ScrollOpposite;
    property ShowHint;
    property SmallCloseBtn;
    property Style;
    Property TabDragDrop;
    property TabFillGradient;
    property TabHeight;
    property TabIndex stored False;
    property TabOrder;
    property TabPosition;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawTabExt;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnTabClose: TTabClose read FTabClose write FTabClose;
    Property OnTabClick : TTabClick read FTabClick write FTabClick;
    property OnTabDelete: TTabDelete read FTabDelete write FTabDelete;
    property OnUnDock;
  end;


implementation
{$R *.res}
uses Printers, Consts, RTLConsts, ComStrs, ActnList, StdActns, ExtActns, Types,
     ActiveX, Themes, UxTheme;

//Returns rectangle where button will be drawn:
function TCustomTabExtControl.GetBtnRect(TabIndex: integer; Complete: boolean; TP: TTabExtPosition): TRect;
  //Caculate and make the ButtonRect
  function MakeBtnRect(TP: TTabExtPosition;
                       ARrect: TRect; Complete: boolean): TRect;
  var
    AHeight: integer;
  begin
     Result := ARrect;
     AHeight := ARrect.bottom - ARrect.top;
     Case TP of
          tpTop, tpBottom:begin
          result.Left := ARrect.Right - BTN_WIDTH - TXT_MARG.x - TXT_MARG.x;
          if Result.left < ARrect.left then
           Result.left := ARrect.left;

          if not Complete then
          begin
            Result.top := ARrect.top + ((AHeight - BTN_WIDTH) div 2);
            Result.left := Result.left + TXT_MARG.x;
            Result.right := Result.left + BTN_WIDTH;
            Result.Bottom := Result.top + BTN_WIDTH;
            end;
          end;

         tpLeft:begin
          Result.Bottom := ARrect.top + BTN_WIDTH + TXT_MARG.x + TXT_MARG.x;
          if Result.top > ARrect.top then
            Result.top := ARrect.top;

          if not Complete then
          begin
            Result.top := ARrect.top + ((AHeight - BTN_WIDTH- TXT_MARG.x) );
            Result.left := Result.left + TXT_MARG.x;
            Result.right := Result.left + BTN_WIDTH;
            Result.Bottom := Result.top + BTN_WIDTH;
            end;
           end;

       tpRight:begin
          Result.top := ARrect.Bottom - BTN_WIDTH - TXT_MARG.x - TXT_MARG.x;
          if Result.Bottom > ARrect.Bottom then
            Result.Bottom := ARrect.Bottom;

          if not Complete then
          begin
            Result.Bottom := ARrect.Bottom + ((AHeight - BTN_WIDTH- TXT_MARG.x) );
            Result.left := Result.left + TXT_MARG.x;
            Result.right := Result.left + BTN_WIDTH;
            Result.top := Result.Bottom + BTN_WIDTH;
          end;
        end;
     end;
  end;
var
  ARrect: TRect;
begin
  result := Rect(0, 0, 0, 0);

  //Get complete Tabrect for the current Tab:
  ARrect := TabRect(TabIndex);

  //Last visible Tab sometimes get truncated so we need to fix that
  if (ARrect.Bottom - ARrect.Top) < Self.TabHeight then
    ARrect.Bottom := ARrect.top + Self.TabHeight;

    Result := MakeBtnRect(TP, ARrect, Complete);
end;

function InitCommonControl(CC: Integer): Boolean;
var
  ICC: TInitCommonControlsEx;
begin
  ICC.dwSize := SizeOf(TInitCommonControlsEx);
  ICC.dwICC := CC;
  Result := InitCommonControlsEx(ICC);
  if not Result then InitCommonControls;
end;

procedure SetComCtlStyle(Ctl: TWinControl; Value: Integer; UseStyle: Boolean);
var
  Style: Integer;
begin
  if Ctl.HandleAllocated then
  begin
    Style := GetWindowLong(Ctl.Handle, GWL_STYLE);
    if not UseStyle then Style := Style and not Value
    else Style := Style or Value;
    SetWindowLong(Ctl.Handle, GWL_STYLE, Style);
  end;
end;

{ TTabExtStrings }

type
  TTabExtStrings = class(TStrings)
  private
    FTabExtControl: TCustomTabExtControl;
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
  end;

procedure TabControlError(const S: string);
begin
  raise EListError.Create(S);
end;

procedure TTabExtStrings.Clear;
begin
  if SendMessage(FTabExtControl.Handle, TCM_DELETEALLITEMS, 0, 0) = 0 then
    TabControlError(sTabFailClear);
  FTabExtControl.TabsChanged;
end;

procedure TTabExtStrings.Delete(Index: Integer);
begin
  if SendMessage(FTabExtControl.Handle, TCM_DELETEITEM, Index, 0) = 0 then
    TabControlError(Format(sTabFailDelete, [Index]));
  FTabExtControl.TabsChanged;
end;

function TTabExtStrings.Get(Index: Integer): string;
const
  RTL: array[Boolean] of LongInt = (0, TCIF_RTLREADING);
var
  TCItem: TTCItem;
  Buffer: array[0..4095] of Char;
begin
  TCItem.mask := TCIF_TEXT or RTL[FTabExtControl.UseRightToLeftReading];
  TCItem.pszText := Buffer;
  TCItem.cchTextMax := SizeOf(Buffer);
  if SendMessage(FTabExtControl.Handle, TCM_GETITEM, Index,
    Longint(@TCItem)) = 0 then
    TabControlError(Format(sTabFailRetrieve, [Index]));
  Result := Buffer;
end;

function TTabExtStrings.GetCount: Integer;
begin
  Result := SendMessage(FTabExtControl.Handle, TCM_GETITEMCOUNT, 0, 0);
end;

function TTabExtStrings.GetObject(Index: Integer): TObject;
var
  TCItem: TTCItem;
begin
  TCItem.mask := TCIF_PARAM;
  if SendMessage(FTabExtControl.Handle, TCM_GETITEM, Index,
    Longint(@TCItem)) = 0 then
    TabControlError(Format(sTabFailGetObject, [Index]));
  Result := TObject(TCItem.lParam);
end;

procedure TTabExtStrings.Put(Index: Integer; const S: string);
const
  RTL: array[Boolean] of LongInt = (0, TCIF_RTLREADING);
var
  TCItem: TTCItem;
begin
  TCItem.mask := TCIF_TEXT or RTL[FTabExtControl.UseRightToLeftReading] or
    TCIF_IMAGE;
  TCItem.pszText := PChar(S);
  TCItem.iImage := FTabExtControl.GetImageIndex(Index);
  if SendMessage(FTabExtControl.Handle, TCM_SETITEM, Index,
    Longint(@TCItem)) = 0 then
    TabControlError(Format(sTabFailSet, [S, Index]));
  FTabExtControl.TabsChanged;
end;

procedure TTabExtStrings.PutObject(Index: Integer; AObject: TObject);
var
  TCItem: TTCItem;
begin
  TCItem.mask := TCIF_PARAM;
  TCItem.lParam := Longint(AObject);
  if SendMessage(FTabExtControl.Handle, TCM_SETITEM, Index,
    Longint(@TCItem)) = 0 then
    TabControlError(Format(sTabFailSetObject, [Index]));
end;

procedure TTabExtStrings.Insert(Index: Integer; const S: string);
const
  RTL: array[Boolean] of LongInt = (0, TCIF_RTLREADING);
var
  TCItem: TTCItem;
begin
  TCItem.mask := TCIF_TEXT or RTL[FTabExtControl.UseRightToLeftReading] or
    TCIF_IMAGE;
  TCItem.pszText := PChar(S);
  TCItem.iImage := FTabExtControl.GetImageIndex(Index);
  if SendMessage(FTabExtControl.Handle, TCM_INSERTITEM, Index,
    Longint(@TCItem)) < 0 then
    TabControlError(Format(sTabFailSet, [S, Index]));
  FTabExtControl.TabsChanged;
end;

procedure TTabExtStrings.SetUpdateState(Updating: Boolean);
begin
  FTabExtControl.FUpdating := Updating;
  SendMessage(FTabExtControl.Handle, WM_SETREDRAW, Ord(not Updating), 0);
  if not Updating then
  begin
    FTabExtControl.Invalidate;
    FTabExtControl.TabsChanged;
  end;
end;

{ TCustomTabExtControl }

constructor TCustomTabExtControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 289;
  Height := 193;
  TabStop := True;
  ControlStyle := [csAcceptsControls, csDoubleClicks, csOpaque];
  FTabs := TTabExtStrings.Create;
  TTabExtStrings(FTabs).FTabExtControl := Self;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FCloseButton := False;
  FSmallCloseBtn:= True;
  FPicture := TPicture.Create;
  FFlat := False;
  FCanDragDrop := False;
  FGradientFill := False;
end;

destructor TCustomTabExtControl.Destroy;
begin
  FreeAndNil(FPicture);
  FreeAndNil(FCanvas);
  FreeAndNil(FTabs);
  FreeAndNil(FSaveTabs);
  FreeAndNil(FImageChangeLink);
  inherited Destroy;
end;

function TCustomTabExtControl.CanChange: Boolean;
begin
  Result := True;
  if Assigned(FOnChanging) then FOnChanging(Self, Result);
end;

function TCustomTabExtControl.CanShowTab(TabIndex: Integer): Boolean;
begin
  Result := True;
end;

procedure TCustomTabExtControl.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TCustomTabExtControl.CreateParams(var Params: TCreateParams);
const
  AlignStyles: array[Boolean, TTabExtPosition] of DWORD =
    ((0, TCS_BOTTOM, TCS_VERTICAL, TCS_VERTICAL or TCS_RIGHT),
     (0, TCS_BOTTOM, TCS_VERTICAL or TCS_RIGHT, TCS_VERTICAL));
  TabStyles: array[TTabExtStyle] of DWORD = (TCS_TABS, TCS_BUTTONS,
    TCS_BUTTONS or TCS_FLATBUTTONS);
   RRStyles: array[Boolean] of DWORD = (0, TCS_RAGGEDRIGHT);
begin
  InitCommonControl(ICC_TAB_CLASSES);
  inherited CreateParams(Params);
  CreateSubClass(Params, WC_TABCONTROL);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN or
      AlignStyles[UseRightToLeftAlignment, FTabPosition] or
      TabStyles[FStyle] or RRStyles[FRaggedRight];
    if not TabStop then Style := Style or TCS_FOCUSNEVER;
    if FMultiLine then Style := Style or TCS_MULTILINE;
    if FMultiSelect then Style := Style or TCS_MULTISELECT;
    if FOwnerDraw then Style := Style or TCS_OWNERDRAWFIXED;
    if FTabSize.X <> 0 then Style := Style or TCS_FIXEDWIDTH;
    if FHotTrack and (not (csDesigning in ComponentState)) then
      Style := Style or TCS_HOTTRACK;
    if FScrollOpposite then Style := Style or TCS_SCROLLOPPOSITE;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW) or
      CS_DBLCLKS;
  end;
end;

procedure TCustomTabExtControl.CreateWnd;
begin
  inherited CreateWnd;
  if (Images <> nil) and Images.HandleAllocated then
    Perform(TCM_SETIMAGELIST, 0, Images.Handle);
  if Integer(FTabSize) <> 0 then UpdateTabSize;
  if FSaveTabs <> nil then
  begin
    FTabs.Assign(FSaveTabs);
    SetTabIndex(FSaveTabIndex);
    FSaveTabs.Free;
    FSaveTabs := nil;
  end;
end;

procedure TCustomTabExtControl.DrawTabExt(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
begin
  if Assigned(FOnDrawTabExt) then
    FOnDrawTabExt(Self, TabIndex, Rect, Active)
  else
  FCanvas.FillRect(Rect);

end;

function TCustomTabExtControl.GetDisplayRect: TRect;
begin
  Result := ClientRect;
  SendMessage(Handle, TCM_ADJUSTRECT, 0, Integer(@Result));
  if TabPosition = tpTop then
    Inc(Result.Top, 2);

end;

function TCustomTabExtControl.GetImageIndex(TabIndex: Integer): Integer;
begin
  Result := TabIndex;
  if Assigned(FOnGetImageIndex) then FOnGetImageIndex(Self, TabIndex, Result);
end;

function TCustomTabExtControl.GetTabIndex: Integer;
begin
  Result := SendMessage(Handle, TCM_GETCURSEL, 0, 0);
end;

procedure TCustomTabExtControl.Loaded;
begin
  inherited Loaded;
  if Images <> nil then UpdateTabImages;
end;

procedure TCustomTabExtControl.SetHotTrack(Value: Boolean);
begin
  if FHotTrack <> Value then
  begin
    FHotTrack := Value;
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

procedure TCustomTabExtControl.SetImages(Value: TCustomImageList);
begin
  if Images <> nil then
    Images.UnRegisterChanges(FImageChangeLink);
  FImages := Value;
  if Images <> nil then
  begin
    Images.RegisterChanges(FImageChangeLink);
    Images.FreeNotification(Self);
    Perform(TCM_SETIMAGELIST, 0, Images.Handle);
  end
  else Perform(TCM_SETIMAGELIST, 0, 0);
end;

procedure TCustomTabExtControl.ImageListChange(Sender: TObject);
begin
  Perform(TCM_SETIMAGELIST, 0, TCustomImageList(Sender).Handle);
end;

function TCustomTabExtControl.InternalSetMultiLine(Value: Boolean): Boolean;
begin
  Result := FMultiLine <> Value;
  if Result then
  begin
    if not Value and ((TabPosition = tpLeft) or (TabPosition = tpRight)) then
      TabControlError(sTabMustBeMultiLine);
    FMultiLine := Value;
    if not Value then FScrollOpposite := False;
  end;
end;

procedure TCustomTabExtControl.SetMultiLine(Value: Boolean);
begin
  if InternalSetMultiLine(Value) then RecreateWnd;
end;

procedure TCustomTabExtControl.SetMultiSelect(Value: Boolean);
begin
  if FMultiSelect <> Value then
  begin
    FMultiSelect := Value;
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.SetOwnerDraw(Value: Boolean);
begin
  if FOwnerDraw <> Value then
  begin
    FOwnerDraw := Value;
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.SetRaggedRight(Value: Boolean);
begin
  if FRaggedRight <> Value then
  begin
    FRaggedRight := Value;
    SetComCtlStyle(Self, TCS_RAGGEDRIGHT, Value);
  end;
end;

procedure TCustomTabExtControl.SetScrollOpposite(Value: Boolean);
begin
  if FScrollOpposite <> Value then
  begin
    FScrollOpposite := Value;
    if Value then FMultiLine := Value;
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.SetStyle(Value: TTabExtStyle);
begin
  if FStyle <> Value then
  begin
    if (Value <> tsTabs) and (TabPosition <> tpTop) then
      raise EInvalidOperation.Create(SInvalidTabStyle);
    ParentBackground := Value = tsTabs;
    FStyle := Value;
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.SetTabHeight(Value: Smallint);
begin
  if FTabSize.Y <> Value then
  begin
    if Value < 0 then
      raise EInvalidOperation.CreateFmt(SPropertyOutOfRange, [Self.Classname]);
    FTabSize.Y := Value;
    UpdateTabSize;
  end;
end;

procedure TCustomTabExtControl.SetTabIndex(Value: Integer);
begin
  SendMessage(Handle, TCM_SETCURSEL, Value, 0);
end;

procedure TCustomTabExtControl.SetTabPosition(Value: TTabExtPosition);
begin
  if FTabPosition <> Value then
  begin
    if (Value <> tpTop) and (Style <> tsTabs) then
      raise EInvalidOperation.Create(SInvalidTabPosition);
    FTabPosition := Value;
    if not MultiLine and ((Value = tpLeft) or (Value = tpRight)) then
      InternalSetMultiLine(True);
    RecreateWnd;
  end;
end;

procedure TCustomTabExtControl.SetTabs(Value: TStrings);
begin
  FTabs.Assign(Value);
end;

procedure TCustomTabExtControl.SetTabWidth(Value: Smallint);
var
  OldValue: Smallint;
begin
  if FTabSize.X <> Value then
  begin
    if Value < 0 then
      raise EInvalidOperation.CreateFmt(SPropertyOutOfRange, [Self.Classname]);
    OldValue := FTabSize.X;
    FTabSize.X := Value;
    if (OldValue = 0) or (Value = 0) then RecreateWnd
    else UpdateTabSize;
  end;
end;

procedure TCustomTabExtControl.TabsChanged;
begin
  if not FUpdating then
  begin
    if HandleAllocated then
      SendMessage(Handle, WM_SIZE, SIZE_RESTORED,
        Word(Width) or Word(Height) shl 16);
    Realign;
  end;
end;

procedure TCustomTabExtControl.UpdateTabSize;
begin
  SendMessage(Handle, TCM_SETITEMSIZE, 0, Integer(FTabSize));
  TabsChanged;
end;

procedure TCustomTabExtControl.UpdateTabImages;
var
  I: Integer;
  TCItem: TTCItem;
begin
  TCItem.mask := TCIF_IMAGE;
  for I := 0 to FTabs.Count - 1 do
  begin
    TCItem.iImage := GetImageIndex(I);
    if SendMessage(Handle, TCM_SETITEM, I,
      Longint(@TCItem)) = 0 then
      TabControlError(Format(sTabFailSet, [FTabs[I], I]));
  end;
  TabsChanged;
end;

procedure TCustomTabExtControl.CNDrawItem(var Message: TWMDrawItem);
var
  SaveIndex: Integer;
begin

  with Message.DrawItemStruct^ do
  begin
    SaveIndex := SaveDC(hDC);
    FCanvas.Lock;
    try
      FCanvas.Handle := hDC;
      FCanvas.Font := Font;
      FCanvas.Brush := Brush;
      DrawTabExt(itemID, rcItem, itemState and ODS_SELECTED <> 0);
    finally
      FCanvas.Handle := 0;
      FCanvas.Unlock;
      RestoreDC(hDC, SaveIndex);
    end;
  end;
  Message.Result := 1;
end;

procedure TCustomTabExtControl.WMDestroy(var Message: TWMDestroy);
var
  FocusHandle: HWnd;
begin
  if (FTabs <> nil) and (FTabs.Count > 0) then
  begin
    FSaveTabs := TStringList.Create;
    FSaveTabs.Assign(FTabs);
    FSaveTabIndex := GetTabIndex;
  end;
  FocusHandle := GetFocus;
  if (FocusHandle <> 0) and ((FocusHandle = Handle) or
    IsChild(Handle, FocusHandle)) then
    Windows.SetFocus(0);
  inherited;
  WindowHandle := 0;
end;

procedure TCustomTabExtControl.WMNotifyFormat(var Message: TMessage);
begin
  with Message do
    Result := DefWindowProc(Handle, Msg, WParam, LParam);
end;

procedure TCustomTabExtControl.WMSize(var Message: TMessage);
begin
  inherited;
  RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE);
end;

procedure TCustomTabExtControl.CMFontChanged(var Message);
begin
  inherited;
  if HandleAllocated then Perform(WM_SIZE, 0, 0);
end;

procedure TCustomTabExtControl.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    Message.Msg := WM_SYSCOLORCHANGE;
    DefaultHandler(Message);
  end;
end;

procedure TCustomTabExtControl.CMTabStopChanged(var Message: TMessage);
begin
  if not (csDesigning in ComponentState) then RecreateWnd;
end;

procedure TCustomTabExtControl.CNNotify(var Message: TWMNotify);
begin
  with Message do
    case NMHdr^.code of
      TCN_SELCHANGE:
        Change;
      TCN_SELCHANGING:
        begin
          Result := 1;
          if CanChange then Result := 0;
        end;
    end;
end;

procedure TCustomTabExtControl.CMDialogChar(var Message: TCMDialogChar);
var
  I: Integer;
begin
  for I := 0 to FTabs.Count - 1 do
    if IsAccel(Message.CharCode, FTabs[I]) and CanShowTab(I) and CanFocus then
    begin
      Message.Result := 1;
      if CanChange then
      begin
        TabIndex := I;
        Change;
      end;
      Exit;
    end;
  inherited;
end;

procedure TCustomTabExtControl.AdjustClientRect(var Rect: TRect);
var i: integer;
begin
  Rect := DisplayRect;
  i:= 4;
  if FFlat then
  Rect := Classes.Rect(Rect.Left-i,Rect.Top-i,Rect.Right+i,Rect.Bottom+i) else
  inherited AdjustClientRect(Rect);
end;

function TCustomTabExtControl.IndexOfTabAt(X, Y: Integer): Integer;
var
  HitTest: TTCHitTestInfo;
begin
  Result := -1;
  if PtInRect(ClientRect, Point(X, Y)) then
    with HitTest do
    begin
      pt.X := X;
      pt.Y := Y;
      Result := TabCtrl_HitTest(Handle, @HitTest);
    end;
end;

function TCustomTabExtControl.GetHitTestInfoAt(X, Y: Integer): THitTests;
var
  HitTest: TTCHitTestInfo;
begin
  Result := [];
  if PtInRect(ClientRect, Point(X, Y)) then
    with HitTest do
    begin
      pt.X := X;
      pt.Y := Y;
      if TabCtrl_HitTest(Handle, @HitTest) <> -1 then
      begin
        if (flags and TCHT_NOWHERE) <> 0 then
          Include(Result, htNowhere);
        if (flags and TCHT_ONITEM) = TCHT_ONITEM then
          Include(Result, htOnItem)
        else
        begin
          if (flags and TCHT_ONITEM) <> 0 then
            Include(Result, htOnItem);
          if (flags and TCHT_ONITEMICON) <> 0 then
            Include(Result, htOnIcon);
          if (flags and TCHT_ONITEMLABEL) <> 0 then
            Include(Result, htOnLabel);
        end;
      end
      else
        Result := [htNowhere];
    end;
end;

function TCustomTabExtControl.TabRect(Index: Integer): TRect;
begin
  TabCtrl_GetItemRect(Handle, Index, Result);
end;

function TCustomTabExtControl.RowCount: Integer;
begin
  Result := TabCtrl_GetRowCount(Handle);
end;

procedure TCustomTabExtControl.ScrollTabs(Delta: Integer);
var
  Wnd: HWND;
  P: TPoint;
  Rect: TRect;
  I: Integer;
begin
  Wnd := FindWindowEx(Handle, 0, 'msctls_updown32', nil);
  if Wnd <> 0 then
  begin
    Windows.GetClientRect(Wnd, Rect);
    if Delta < 0 then
      P.X := Rect.Left + 2
    else
      P.X := Rect.Right - 2;
    P.Y := Rect.Top + 2;
    for I := 0 to Abs(Delta) - 1 do
    begin
      SendMessage(Wnd, WM_LBUTTONDOWN, 0, MakeLParam(P.X, P.Y));
      SendMessage(Wnd, WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y));
    end;
  end;
end;

procedure TCustomTabExtControl.TCMAdjustRect(var Message: TMessage);
begin
  { Major hack around a problem in the Windows tab control. Don't try this
    at home. The tab control (4.71) will AV when in a TCM_ADJUSTRECT message
    when the height of the control is the same as the height of the tab (or the
    width of the control for tpBottom). This hack will return the last value
    successfully returned if an exception is encountered. This allows the
    control to function but the AV is still generated and and reported by the
    debugger. }
  try
    inherited;
    if (TabPosition <> tpTop) and (Message.WParam = 0) then
      FSavedAdjustRect := PRect(Message.LParam)^;
  except
    PRect(Message.LParam)^ := FSavedAdjustRect;
  end;
end;

function TCustomTabExtControl.GetClose: Boolean;
begin
  Result := FCloseButton;
end;

procedure TCustomTabExtControl.SetClose(Value: Boolean);
begin
  if Value <> FCloseButton then FCloseButton := Value;
  FOwnerDraw := FCloseButton;
  ReCreateWnd;
end;

procedure TCustomTabExtControl.SetPicture(Const Value: TPicture);
begin
  FPicture.Assign(Value);
  Invalidate;
end;

procedure TCustomTabExtControl.WMPAINT(var Msg: TWMPAINT);
begin
   ControlState := ControlState + [csCustomPaint];
   inherited;
   ControlState := ControlState - [csCustomPaint];
   if (FPicture.Graphic <> Nil) and (TabIndex < 0) and
   (Assigned(FPicture)) then
   begin
   FCanvas.StretchDraw(ClientRect, FPicture.Graphic)
   end;

end;

procedure TCustomTabExtControl.WndProc(var Message: TMessage);
begin
  {if(Message.Msg=TCM_ADJUSTRECT) and (FFlat) then
   begin
    Inherited WndProc(Message);
    Case TAbPosition of
    tpTop : begin
    PRect(Message.LParam)^.Left:=0;
    PRect(Message.LParam)^.Right:=ClientWidth;
    PRect(Message.LParam)^.Top:=PRect(Message.LParam)^.Top-4;
    PRect(Message.LParam)^.Bottom:=ClientHeight;
  end;
    tpLeft : begin
    PRect(Message.LParam)^.Top:=0;
    PRect(Message.LParam)^.Right:=ClientWidth;
    PRect(Message.LParam)^.Left:=PRect(Message.LParam)^.Left-4;
    PRect(Message.LParam)^.Bottom:=ClientHeight;
  end;
    tpBottom : begin
    PRect(Message.LParam)^.Left:=0;
    PRect(Message.LParam)^.Right:=ClientWidth;
    PRect(Message.LParam)^.Bottom:=PRect(Message.LParam)^.Bottom-4;
    PRect(Message.LParam)^.Top:=0;
  end;
    tpRight : begin
    PRect(Message.LParam)^.Top:=0;
    PRect(Message.LParam)^.Left:=0;
    PRect(Message.LParam)^.Right:=PRect(Message.LParam)^.Right-4;
    PRect(Message.LParam)^.Bottom:=ClientHeight;
    end;
  end;
 end else} Inherited WndProc(Message);

end;

procedure TCustomTabExtControl.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then FFlat := Value;
  RecreateWnd;
end;

procedure TCustomTabExtControl.SetGradientFill(value: Boolean);
begin
  if FGradientFill <> Value then begin
   FGradientFill := Value;
   invalidate;
 end;
end;

procedure TCustomTabExtControl.SetSmallCloseBtn(const Value: boolean);
begin
  if Value <> FSmallCloseBtn then
  begin
  FSmallCloseBtn := Value;
  Invalidate;
  end;
end;

{ TTabExtSheet }

constructor TTabExtSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  ControlStyle := ControlStyle + [csAcceptsControls, csNoDesignVisible,
    csParentBackground];
  Visible := False;
  FTabVisible := True;
  FHighlighted := False;
  FColors := TTabColors.Create(Self);
  //FPicture  := TPicture.Create;
end;

destructor TTabExtSheet.Destroy;
begin
  if FPageExtControl <> nil then
  begin
    if FPageExtControl.FUndockingPage = Self then FPageExtControl.FUndockingPage := nil;
    FPageExtControl.RemovePage(Self);
  end;
  //FPicture.Free;
  inherited Destroy;
end;

procedure TTabExtSheet.DoHide;
begin
  if Assigned(FOnHide) then FOnHide(Self);
end;

procedure TTabExtSheet.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;

function TTabExtSheet.GetPageIndex: Integer;
begin
  if FPageExtControl <> nil then
    Result := FPageExtControl.FPages.IndexOf(Self) else
    Result := -1;
end;

function TTabExtSheet.GetTabIndex: Integer;
var
  I: Integer;
begin
  Result := 0;
  if not FTabShowing then Dec(Result) else
    for I := 0 to PageIndex - 1 do
      if TTabExtSheet(FPageExtControl.FPages[I]).FTabShowing then
        Inc(Result);
end;

procedure TTabExtSheet.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not ThemeServices.ThemesAvailable then
    with Params.WindowClass do
      style := style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TTabExtSheet.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if Reader.Parent is TPageExtControl then
    PageExtControl := TPageExtControl(Reader.Parent);
end;

procedure TTabExtSheet.SetImageIndex(Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    if FTabShowing then FPageExtControl.UpdateTab(Self);
  end;
end;

procedure TTabExtSheet.SetPageControl(APageControl: TPageExtControl);
begin
  if FPageExtControl <> APageControl then
  begin
    if FPageExtControl <> nil then FPageExtControl.RemovePage(Self);
    Parent := APageControl;
    if APageControl <> nil then APageControl.InsertPage(Self);
  end;
end;

procedure TTabExtSheet.SetPageIndex(Value: Integer);
var
  I, MaxPageIndex: Integer;
begin
  if FPageExtControl <> nil then
  begin
    MaxPageIndex := FPageExtControl.FPages.Count - 1;
    if Value > MaxPageIndex then
      raise EListError.CreateResFmt(@SPageIndexError, [Value, MaxPageIndex]);
    I := TabIndex;
    FPageExtControl.FPages.Move(PageIndex, Value);
    if I >= 0 then FPageExtControl.MoveTab(I, TabIndex);
  end;
end;

procedure TTabExtSheet.SetTabShowing(Value: Boolean);
var
  Index: Integer;
begin
  if FTabShowing <> Value then
    if Value then
    begin
      FTabShowing := True;
      FPageExtControl.InsertTab(Self);
    end else
    begin
      Index := TabIndex;
      FTabShowing := False;
      FPageExtControl.DeleteTab(Self, Index);
    end;
end;

procedure TTabExtSheet.SetTabVisible(Value: Boolean);
begin
  if FTabVisible <> Value then
  begin
    FTabVisible := Value;
    UpdateTabShowing;
  end;
end;

procedure TTabExtSheet.UpdateTabShowing;
begin
  SetTabShowing((FPageExtControl <> nil) and FTabVisible);
end;

procedure TTabExtSheet.CMTextChanged(var Message: TMessage);
begin
  if FTabShowing then FPageExtControl.UpdateTab(Self);
end;

procedure TTabExtSheet.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
  begin
    try
      DoShow
    except
      Application.HandleException(Self);
    end;
  end else if not Showing then
  begin
    try
      DoHide;
    except
      Application.HandleException(Self);
    end;
  end;
end;

procedure TTabExtSheet.SetHighlighted(Value: Boolean);
begin
  if not (csReading in ComponentState) then
    SendMessage(PageExtControl.Handle, TCM_HIGHLIGHTITEM, TabIndex,
      MakeLong(Word(Value), 0));
  FHighlighted := Value;
end;

procedure TTabExtSheet.WMNCPaint(var Message: TWMNCPaint);
var
  DC: HDC;
  DrawRect: TRect;
  Details: TThemedElementDetails;
begin
  with ThemeServices do
  begin
    if ThemesEnabled and (BorderWidth > 0) then
    begin
      DC := GetWindowDC(Handle);
      try
        DrawRect := ClientRect;
        OffsetRect(DrawRect, BorderWidth, BorderWidth);
        with DrawRect do
          ExcludeClipRect(DC, Left, Top, Right, Bottom);
        SetWindowOrgEx(DC, -BorderWidth, -BorderWidth, nil);
        Details := GetElementDetails(ttBody);
        DrawParentBackground(Handle, DC, @Details, False);
      finally
        ReleaseDC(Handle, DC);
      end;
      Message.Result := 0;
    end
    else
    inherited;
  end;
end;

procedure TTabExtSheet.WMPrintClient(var Message: TWMPrintClient);
begin
  with ThemeServices do
    if ThemesEnabled then
    begin
      DrawParentBackground(Handle, Message.DC, nil, False);
      Message.Result := 1;
    end
    else
      inherited;
end;

procedure TTabExtSheet.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  {if FTabColor = clBtnFace then
  inherited
  else
  begin }
    Brush.Color := FColors.Color;
    Windows.FillRect(Msg.dc, ClientRect, Brush.Handle);
    Msg.Result := 1;
 // end;
end;

{function TTabExtSheet.GetPicture: TPicture;
begin
  Result := FPicture;
end;

{procedure TTabExtSheet.SetPicture(Const Value: TPicture);
begin
 FPicture.Assign(Value);
 Invalidate;
end;

procedure TTabExtSheet.WMPAINT(var Msg: TWMPAINT);
begin
   if (FPicture.Graphic <> Nil)  and
   (Assigned(FPicture)) then
   PageExtControl.Canvas.StretchDraw(Self.BoundsRect, FPicture.Graphic);
end; }

procedure TTabExtSheet.SetTabColors(const Value: TTabColors);
begin
  if (Value <> FColors) then
  begin
  FColors := Value;
  Invalidate;
  end;
end;

{ TPageExtControl }

constructor TPageExtControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csDoubleClicks, csOpaque];
  FPages := TList.Create;
end;

destructor TPageExtControl.Destroy;
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do TTabExtSheet(FPages[I]).FPageExtControl := nil;
  FPages.Free;
  inherited Destroy;
end;

procedure TPageExtControl.UpdateTabHighlights;
var
  I: Integer;
begin
  for I := 0 to PageCount - 1 do
    Pages[I].SetHighlighted(Pages[I].FHighlighted);
end;

procedure TPageExtControl.Loaded;
begin
  inherited Loaded;
  UpdateTabHighlights;
end;


function TPageExtControl.CanShowTab(TabIndex: Integer): Boolean;
begin
  Result := TTabExtSheet(FPages[TabIndex]).Enabled;
end;

procedure TPageExtControl.Change;
var
  Form: TCustomForm;
begin
  if TabIndex >= 0 then
    UpdateActivePage;
  if csDesigning in ComponentState then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  end;
  inherited Change;
end;

procedure TPageExtControl.ChangeActivePage(Page: TTabExtSheet);
var
  ParentForm: TCustomForm;
begin
  if FActivePage <> Page then
  begin
    ParentForm := GetParentForm(Self);
    if (ParentForm <> nil) and (FActivePage <> nil) and
      FActivePage.ContainsControl(ParentForm.ActiveControl) then
    begin
      ParentForm.ActiveControl := FActivePage;
      if ParentForm.ActiveControl <> FActivePage then
      begin
        TabIndex := FActivePage.TabIndex;
        Exit;
      end;
    end;
    if Page <> nil then
    begin
      Page.BringToFront;
      Page.Visible := True;
      if (ParentForm <> nil) and (FActivePage <> nil) and
        (ParentForm.ActiveControl = FActivePage) then
        if Page.CanFocus then
          ParentForm.ActiveControl := Page else
          ParentForm.ActiveControl := Self;
    end;
    if FActivePage <> nil then FActivePage.Visible := False;
    FActivePage := Page;
    if (ParentForm <> nil) and (FActivePage <> nil) and
      (ParentForm.ActiveControl = FActivePage) then
      FActivePage.SelectFirst;
  end;
end;

procedure TPageExtControl.DeleteTab(Page: TTabExtSheet; Index: Integer);
var
  UpdateIndex: Boolean;
begin
  UpdateIndex := Page = ActivePage;
  If Assigned(FTabDelete) then
  FTabDelete(Self, TabIndex);
  Tabs.Delete(Index);
  if UpdateIndex then
  begin
    if Index >= Tabs.Count then
      Index := Tabs.Count - 1;
    TabIndex := Index;
  end;

  UpdateActivePage;
end;

procedure TPageExtControl.DoAddDockClient(Client: TControl; const ARect: TRect);
begin
  if FNewDockSheet <> nil then Client.Parent := FNewDockSheet;
end;

procedure TPageExtControl.DockOver(Source: TDragDockObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  R: TRect;
begin
  GetWindowRect(Handle, R);
  Source.DockRect := R;
  DoDockOver(Source, X, Y, State, Accept);
end;

procedure TPageExtControl.DoRemoveDockClient(Client: TControl);
begin
  if (FUndockingPage <> nil) and not (csDestroying in ComponentState) then
  begin
    SelectNextPage(True);
    FUndockingPage.Free;
    FUndockingPage := nil;
  end;
end;

function TPageExtControl.FindNextPage(CurPage: TTabExtSheet;
  GoForward, CheckTabVisible: Boolean): TTabExtSheet;
var
  I, StartIndex: Integer;
begin
  if FPages.Count <> 0 then
  begin
    StartIndex := FPages.IndexOf(CurPage);
    if StartIndex = -1 then
      if GoForward then StartIndex := FPages.Count - 1 else StartIndex := 0;
    I := StartIndex;
    repeat
      if GoForward then
      begin
        Inc(I);
        if I = FPages.Count then I := 0;
      end else
      begin
        if I = 0 then I := FPages.Count;
        Dec(I);
      end;
      Result := FPages[I];
      if not CheckTabVisible or Result.TabVisible then Exit;
    until I = StartIndex;
  end;
  Result := nil;
end;

procedure TPageExtControl.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do Proc(TComponent(FPages[I]));
end;

function TPageExtControl.GetImageIndex(TabIndex: Integer): Integer;
var
  I,
  Visible,
  NotVisible: Integer;
begin
  if Assigned(FOnGetImageIndex) then
    Result := inherited GetImageIndex(TabIndex) else
    begin
     { For a PageExtControl, TabIndex refers to visible tabs only. The control
     doesn't store }
      Visible := 0;
      NotVisible := 0;
      for I := 0 to FPages.Count - 1 do
      begin
        if not GetPage(I).TabVisible then Inc(NotVisible)
        else Inc(Visible);
        if Visible = TabIndex + 1 then Break;
      end;
      Result := GetPage(TabIndex + NotVisible).ImageIndex;
    end;
end;

function TPageExtControl.GetPageFromDockClient(Client: TControl): TTabExtSheet;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to PageCount - 1 do
  begin
    if (Client.Parent = Pages[I]) and (Client.HostDockSite = Self) then
    begin
      Result := Pages[I];
      Exit;
    end;
  end;
end;

function TPageExtControl.GetPage(Index: Integer): TTabExtSheet;
begin
  Result := FPages[Index];
end;

function TPageExtControl.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

procedure TPageExtControl.GetSiteInfo(Client: TControl; var InfluenceRect: TRect;
  MousePos: TPoint; var CanDock: Boolean);
begin
  CanDock := GetPageFromDockClient(Client) = nil;
  inherited GetSiteInfo(Client, InfluenceRect, MousePos, CanDock);
end;

procedure TPageExtControl.InsertPage(Page: TTabExtSheet);
begin
  FPages.Add(Page);
  Page.FPageExtControl := Self;
  Page.UpdateTabShowing;
end;

procedure TPageExtControl.InsertTab(Page: TTabExtSheet);
begin
  Tabs.InsertObject(Page.TabIndex, Page.Caption, Page);
  UpdateActivePage;
end;

procedure TPageExtControl.MoveTab(CurIndex, NewIndex: Integer);
begin
  Tabs.Move(CurIndex, NewIndex);
end;

procedure TPageExtControl.RemovePage(Page: TTabExtSheet);
var
  NextSheet: TTabExtSheet;
begin
  NextSheet := FindNextPage(Page, True, not (csDesigning in ComponentState));
  if NextSheet = Page then NextSheet := nil;
  Page.SetTabShowing(False);
  Page.FPageExtControl := nil;
  FPages.Remove(Page);
  SetActivePage(NextSheet);
end;

procedure TPageExtControl.SelectNextPage(GoForward: Boolean; CheckTabVisible: Boolean = True);
var
  Page: TTabExtSheet;
begin
  Page := FindNextPage(ActivePage, GoForward, CheckTabVisible);
  if (Page <> nil) and (Page <> ActivePage) and CanChange then
  begin
    SetActivePage(Page);
    Change;
  end;
end;

procedure TPageExtControl.SetActivePage(Page: TTabExtSheet);
begin
  if (Page <> nil) and (Page.PageExtControl <> Self) then Exit;
  FInSetActivePage := True;
  try
    ChangeActivePage(Page);
    if Page = nil then
      TabIndex := -1
    else if Page = FActivePage then
      TabIndex := Page.TabIndex;
  finally
    FInSetActivePage := False;
  end;
end;

procedure TPageExtControl.SetChildOrder(Child: TComponent; Order: Integer);
begin
  TTabExtSheet(Child).PageIndex := Order;
end;

procedure TPageExtControl.ShowControl(AControl: TControl);
begin
  if (AControl is TTabExtSheet) and (TTabExtSheet(AControl).PageExtControl = Self) then
    SetActivePage(TTabExtSheet(AControl));
  inherited ShowControl(AControl);
end;

procedure TPageExtControl.UpdateTab(Page: TTabExtSheet);
begin
  Tabs[Page.TabIndex] := Page.Caption;
end;

procedure TPageExtControl.UpdateActivePage;
begin
  if TabIndex >= 0 then
    SetActivePage(TTabExtSheet(Tabs.Objects[TabIndex]))
  else
    SetActivePage(nil);
end;

procedure TPageExtControl.CMDesignHitTest(var Message: TCMDesignHitTest);
var
  HitIndex: Integer;
  HitTestInfo: TTCHitTestInfo;
begin
  HitTestInfo.pt := SmallPointToPoint(Message.Pos);
  HitIndex := SendMessage(Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));
  if (HitIndex >= 0) and (HitIndex <> TabIndex) then Message.Result := 1;
end;

procedure TPageExtControl.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Focused or Windows.IsChild(Handle, Windows.GetFocus)) and
    (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    SelectNextPage(GetKeyState(VK_SHIFT) >= 0);
    Message.Result := 1;
  end else
    inherited;
end;

procedure TPageExtControl.CMDockClient(var Message: TCMDockClient);
var
  IsVisible: Boolean;
  DockCtl: TControl;
begin
  Message.Result := 0;
  FNewDockSheet := TTabExtSheet.Create(Self);
  try
    try
      DockCtl := Message.DockSource.Control;
      if DockCtl is TCustomForm then
        FNewDockSheet.Caption := TCustomForm(DockCtl).Caption;
      FNewDockSheet.PageExtControl := Self;
      DockCtl.Dock(Self, Message.DockSource.DockRect);
    except
      FNewDockSheet.Free;
      raise;
    end;
    IsVisible := DockCtl.Visible;
    FNewDockSheet.TabVisible := IsVisible;
    if IsVisible then ActivePage := FNewDockSheet;
    DockCtl.Align := alClient;
  finally
    FNewDockSheet := nil;
  end;
end;

procedure TPageExtControl.CMDockNotification(var Message: TCMDockNotification);
var
  I: Integer;
  S: string;
  Page: TTabExtSheet;
begin
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
    case Message.NotifyRec.ClientMsg of
      WM_SETTEXT:
        begin
          S := PChar(Message.NotifyRec.MsgLParam);
          { Search for first CR/LF and end string there }
          for I := 1 to Length(S) do
            if S[I] in [#13, #10] then
            begin
              SetLength(S, I - 1);
              Break;
            end;
          Page.Caption := S;
        end;
      CM_VISIBLECHANGED:
        Page.TabVisible := Boolean(Message.NotifyRec.MsgWParam);
    end;
  inherited;
end;

procedure TPageExtControl.CMUnDockClient(var Message: TCMUnDockClient);
var
  Page: TTabExtSheet;
begin
  Message.Result := 0;
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
  begin
    FUndockingPage := Page;
    Message.Client.Align := alNone;
  end;
end;

function TPageExtControl.GetDockClientFromMousePos(MousePos: TPoint): TControl;
var
  i, HitIndex: Integer;
  HitTestInfo: TTCHitTestInfo;
  Page: TTabExtSheet;
begin
  Result := nil;
  if DockSite then
  begin
    HitTestInfo.pt := MousePos;
    HitIndex := SendMessage(Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));
    if HitIndex >= 0 then
    begin
      Page := nil;
      for i := 0 to HitIndex do
        Page := FindNextPage(Page, True, True);
      if (Page <> nil) and (Page.ControlCount > 0) then
      begin
        Result := Page.Controls[0];
        if Result.HostDockSite <> Self then Result := nil;
      end;
    end;
  end;
end;

procedure TPageExtControl.WMLButtonDown(var Message: TWMLButtonDown);
var
  DockCtl: TControl;
begin
  inherited;
  DockCtl := GetDockClientFromMousePos(SmallPointToPoint(Message.Pos));
  if (DockCtl <> nil) and (Style = tsTabs) then DockCtl.BeginDrag(False);
end;

procedure TPageExtControl.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  DockCtl: TControl;
begin
  inherited;
  DockCtl := GetDockClientFromMousePos(SmallPointToPoint(Message.Pos));
  if DockCtl <> nil then DockCtl.ManualDock(nil, nil, alNone);
end;

function TPageExtControl.GetActivePageIndex: Integer;
begin
  if ActivePage <> nil then
    Result := ActivePage.GetPageIndex
  else
    Result := -1;
end;

procedure TPageExtControl.SetActivePageIndex(const Value: Integer);
begin
  if (Value > -1) and (Value < PageCount) then
    ActivePage := Pages[Value]
  else
    ActivePage := nil;
end;

procedure TPageExtControl.SetTabIndex(Value: Integer);
begin
  inherited;
  if not FInSetActivePage and (Value >= 0) and (Value < FPages.Count) and
    Pages[Value].TabVisible then
  begin
    SetActivePage(Pages[Value]);
  end;
end;

procedure TPageExtControl.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  if (not ThemeServices.ThemesEnabled) or (not ParentBackground) then
    inherited
  else
    Message.Result := 1;
end;

Function TPageExtControl.DoTabClose(TabIndex: integer): boolean;
begin
   Result := True;
   if Assigned(FTabClose) then
   FTabClose(Self, TabIndex, Result);
end;

procedure TPageExtControl.DrawTabExt(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
procedure TextRotate(const S: string; x,y, deg : integer);
  var
    LogFont : tLogFont;
    oldFont : TFont;
  begin
    oldFont := self.Canvas.Font;
    GetObject(oldFont.handle, sizeof(tLogFont),@Logfont);
    Logfont.lfEscapement := deg * 10;
    Logfont.lfOrientation := Logfont.lfEscapement;
    Logfont.lfOutPrecision := OUT_TT_ONLY_PRECIS;   // We need TrueType Fonts
    self.Canvas.Font.handle := CreateFontIndirect(logfont);
    Self.Canvas.textout(x,y,S);
    DeleteObject(self.Canvas.Font.handle);
    self.Canvas.Font := oldFont;
  end;

const imggap = 5;
var R, BtnRect : TRect;
    x, y, hr,
    wr, angle  : Integer;
    fs         : TSize;
    cap        : String;
    gs         : TGradientStyle;
    imgindx,
    BtnState, imgx, imgy : Integer;
    A,INA,AF,IAF,AG,INAG : TColor;
begin
  //inherited DrawTab(TabIndex, Rect, Active);
  x := 0; y:=0; angle:=0;
  A:= TTabExtSheet(Pages[TabIndex]).Colors.ActiveFill1;
  AG := TTabExtSheet(Pages[TabIndex]).Colors.ActiveFill2;
  AF := TTabExtSheet(Pages[TabIndex]).Colors.ActiveFontColor;
  INA:= TTabExtSheet(Pages[TabIndex]).Colors.InActiveFill1;
  INAG := TTabExtSheet(Pages[TabIndex]).Colors.InActiveFill2;
  IAF := TTabExtSheet(Pages[TabIndex]).Colors.InActiveFontColor;

  with Canvas do begin
  if Active then
    Brush.Color := A else
    Brush.Color := INA;
    Canvas.Font := TTabExtSheet(Pages[TabIndex]).Font;
    SetBkMode(Canvas.Handle, Opaque);
    if TabFillGradient and (Not HotTrack) then begin
      R := Rect;
      if Active then begin
        gs := gsVertical;
        case TabPosition of
          tpLeft, tpRight   : gs := gsVertical;
          tpTop, tpBottom   : gs := gsHorizontal;
        end;
        InflateRect(R, -1, 0);
        GradientFillRect(Canvas, R, ColorToRGB(AG){TColor($00FFFFFF)}, ColorToRGB(Brush.Color), gs);
      end else begin
        case TabPosition of
          tpLeft  : begin
             InflateRect(R, 1, 0);
             OffsetRect(R, 1, 0);
             gs := gsVertical;
            end;
          tpTop   : begin
             InflateRect(R, -1, 1);
             OffsetRect(R, 0, 1);
             gs := gsHorizontal;
            end;
          tpRight  : begin
             InflateRect(R, 1, 0);
             OffsetRect(R, -1, 0);
             gs := gsVertical;
            end;
          tpBottom : begin
             InflateRect(R, -1, 1);
             OffsetRect(R, 0, -1);
             gs := gsHorizontal;
            end;
        end;

        GradientFillRect(Canvas, R, ColorToRGB(Brush.Color), ColorToRGB(INAG){TColor($00888888)}, gs);
      end;

    end else
      FillRect(Rect);
    if Active then
    Font.Color := AF else
    Font.Color := IAF;
    Brush.Style := bsClear;

    SetBkMode(Canvas.Handle, Transparent);
    R := Rect;
    if Assigned(Images) then begin
      case TabPosition of
        tpTop,
        tpBottom : Inc(R.Left, Images.Width  + imggap);
        tpLeft   : Dec(R.Bottom, Images.Height + imggap);
        tpRight  : Inc(R.Top, Images.Height + imggap);
      end;
    end;

    cap := Pages[TabIndex].Caption;
    if CloseBtn then
    cap := Trim(cap)+StringOfChar(#32,10) else
    Cap := Trim(cap);
    Pages[TabIndex].Caption := cap;

    fs  := TextExtent(cap);
    hr  := R.Bottom - R.Top;
    wr  := R.Right  - R.Left;
    case TabPosition of
      tpTop, tpBottom : begin
          Inc(R.Left, (wr - fs.cx) shr 1);
          Inc(R.Top, (hr - fs.cy) shr 1);
          if Not Active then begin
            case TabPosition of
              tpTop    : Inc(R.Top, 2);
              tpBottom : Dec(R.Top, 2);
            end;
          end;
          TextRect(R,R.Left, R.Top, cap);
        end;
      tpLeft, tpRight : begin
          Inc(R.Left, (wr - fs.cy) shr 1);
          Inc(R.Top, (hr - fs.cx) shr 1);
          case TabPosition of
             tpLeft : begin
                 y := R.Top + fs.cx;
                 x := R.Left;
                 angle := 90;
               end;
             tpRight : begin
                 y := R.Top;
                 x := R.Left + fs.cy;
                 angle := 270;
               end;
          end;
          TextRotate(cap, x, y, angle);
        end;
    end;

    if Assigned(Images) then begin
      imgindx := Pages[TabIndex].ImageIndex;
      imgx :=0; imgy :=0;
      case TabPosition of
        tpTop,
        tpBottom : begin
              imgx := R.Left-(Images.Width+imggap);
              imgy := R.Top-2;
           end;
        tpLeft   : begin
              imgx := R.Left;
              imgy := R.Top+fs.cx+imggap;
              if Not Active then
                  Inc(imgx, 2);
           end;
        tpRight  : begin
              imgx := R.Left;
              imgy := R.Top-(Images.Height+imggap);
              if Not Active then
                  Dec(imgx, 2);
           end;
      end;
      Images.Draw(Canvas, imgx, imgy, imgindx);
    end;
   if CloseBtn then
   begin
   //Get buttonposition and draw Closebox:
   BtnRect := GetBtnRect(TabIndex, Not(SmallCloseBtn), TabPosition);
   if Active then
   Brush.Color := A else
   Brush.Color := INA;
   Windows.FillRect(Handle,BtnRect,Brush.Handle); //<<not working for some reason
  // BtnRect := GetBtnRect(TabIndex, Not(SmallCloseBtn), TabPosition);
   if FCloseHot then
   BtnState := DFCS_CAPTIONCLOSE or DFCS_FLAT or DFCS_HOT else
   BtnState := DFCS_CAPTIONCLOSE or DFCS_FLAT;
   DrawFrameControl(handle, BtnRect,DFC_CAPTION, btnState);
   end;
    //DrawFocusRect(Rect);
  end;
end;

procedure TPageExtControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  B: TRect;
  CanClose: boolean;
begin
   if Assigned(OnMouseDown) then
   OnMouseDown(Self ,Button, Shift, X, Y) else
   begin
   inherited;
   if (csDesigning in ComponentState) then exit;
   i:= TabIndex;
   B := GetBtnRect(i, Not(SmallCloseBtn), TabPosition);
   if (PtInRect(B, Point(X, Y))) and (CloseBtn) then
   begin
   CanClose := DoTabClose(i);
   if CanClose then
   begin
   Self.Pages[i].PageExtControl := nil;
   exit;
   end;
  end;
  if Assigned(FTabClick) then
  FTabClick(Self,i);
  if TabDragDrop then
  BeginDrag(False);
 end;
end;

procedure TPageExtControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  B: TRect;
begin
  inherited;
   i:= TabIndex;
   B := GetBtnRect(i, Not(SmallCloseBtn), TabPosition);
   if (PtInRect(B, Point(X, Y))) and (CloseBtn)
   then
   FCloseHot := True else
   FCloseHot := False;
end;

procedure TPageExtControl.DragDrop(Source: TObject; X, Y: Integer);
var
  i: Integer;
  r: TRect;
begin
  if Assigned(OnDragDrop) then
  OnDragDrop(Self, Source, X, Y) else
  begin
  inherited;
   for i := 0 to PageCount - 1 do
    begin
      Perform(TCM_GETITEMRECT, i, lParam(@r));
      if PtInRect(r, Point(X, Y)) then
      begin
        if i <> ActivePage.PageIndex then
          ActivePage.PageIndex := i;
        Exit;
      end;
    end;
  end;
end;

procedure TPageExtControl.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Assigned(OnDragOver) then
  OnDragOver(Self, Source, X, Y, State, Accept) else
  begin
  inherited;
  Accept := True;
  end;
end;

{----------------[Gradient Fill Methods]---------}
function Muldv(a,b,c : integer) : longint;
ASM
  MOV EAX, a
  IMUL b
  IDIV c
end;

procedure TPageExtControl.GradientFillRect(Canvas: TCanvas; Rect: TRect;
               BeginClr, EndClr: TColor; style : TGradientStyle);

var Height, Width : Integer;

    {I'll explain a little about the Horizontal gradient, the other styles are all
     consistent with their logic.  The six R, G, and B values are passed to us.
     We define some local variables we'll need: a rectangle, a FOR loop counter,
     and our own RGB numbers.  For a horizontal gradient, we'll draw a series of
     rectangles, each one a little closer in color to the EndClr value.  A horizontal
     gradient rectangle will always be from the top to the bottom of the canvas,
     so we set top to 0 and bottom to however tall our control is.  Then, we draw
     a series of 255 rectangles.  The starting point and width of each will depend
     on the actual width of our control.  It starts out on the left, draws the
     first rectangle in a color that's a percentage of the difference plus the
     starting color.  As I increments through the loop, the rectangles move to the
     right and the color gets closer and closer to the EndClr.}
    procedure DoHorizontal(fr, fg, fb, dr, dg, db : Integer);
    var
      ColorRect     : TRect;
      I             : Integer;
      R, G, B : Byte;
    begin
      ColorRect.Top:= Rect.Top;          //Set rectangle top
      ColorRect.Bottom := Rect.Bottom;
      for I := 0 to 255 do begin         //Make lines (rectangles) of color
        ColorRect.Left := Rect.Left + Muldv (I, Width, 256);        //Find left for this color
        ColorRect.Right:= Rect.Left + Muldv (I + 1, Width, 256);   //Find Right
        R := fr + Muldv(I, dr, 255);    //Find the RGB values
        G := fg + Muldv(I, dg, 255);
        B := fb + Muldv(I, db, 255);
        Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
        Canvas.FillRect(ColorRect);           //Draw on Bitmap
      end;
    end;

    procedure DoVertical(fr, fg, fb, dr, dg, db : Integer);
    var
      ColorRect: TRect;
      I: Integer;
      R, G, B : Byte;
    begin
      ColorRect.Left:= Rect.Left;        //Set rectangle left&right
      ColorRect.Right:= Rect.Right;
      for I := 0 to 255 do begin         //Make lines (rectangles) of color
        ColorRect.Top:= Rect.Top + Muldv (I, Height, 256);    //Find top for this color
        ColorRect.Bottom:= Rect.Top + Muldv (I + 1, Height, 256);   //Find Bottom
        R := fr + Muldv(I, dr, 255);    //Find the RGB values
        G := fg + Muldv(I, dg, 255);
        B := fb + Muldv(I, db, 255);
        Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
        Canvas.FillRect(ColorRect);           //Draw on Bitmap
      end;
    end;

    procedure DoElliptic(fr, fg, fb, dr, dg, db : Integer);

      procedure ClippingRect(r : TRect);
      var Rgn : THandle;
      begin
           LPToDP(Canvas.Handle, r, 2);
           Rgn := CreateRectRgnIndirect(r);
           SelectClipRgn(Canvas.Handle, Rgn);
           DeleteObject(Rgn);
      end;

    var
      I: Integer;
      R, G, B : Byte;
      Pw, Ph, Dw, Dh : integer;
      x1,y1,x2,y2 : integer;
      oldClipRect : TRect;
    {The elliptic is a bit different, since I had to use real numbers. I cut down
     on the number (to 155 instead of 255) of iterations in an attempt to speed
     things up, to no avail.  I think it just takes longer for windows to draw an
     ellipse as opposed to a rectangle.}
    begin
      oldClipRect := Canvas.ClipRect;
      ClippingRect(Rect);
      Canvas.Pen.Style := psClear;
      Canvas.Pen.Mode := pmCopy;
      x1 := Width div-3;
      x2 := Width + (Width div 3);
      y1 := Height div-3;
      y2 := Height + (Height div 3);
      Pw := x2 - x1;
      Ph := y2 - y1;
      for I := 0 to 50 do begin         //Make ellipses of color
        R := fr + Muldv(I, dr, 50);    //Find the RGB values
        G := fg + Muldv(I, dg, 50);
        B := fb + Muldv(I, db, 50);
        Canvas.Brush.Color := R or (G shl 8) or (b shl 16);   //Plug colors into brush
        Dw := Pw * i div 100;
        Dh := Ph * i div 100;
        Canvas.Ellipse(x1 + Dw,y1 + Dh,x2 - Dw,y2 - Dh);
      end;
      Canvas.Pen.Style := psSolid;
      ClippingRect(oldClipRect);
    end;

    procedure DoRectangle(fr, fg, fb, dr, dg, db : Integer);
    var
      I: Integer;
      R, G, B : Byte;
      Pw, Ph : Real;
      x1,y1,x2,y2 : Real;
      r1, r2, r3, r4 : Integer;
    begin
      Canvas.Pen.Style := psClear;
      Canvas.Pen.Mode := pmCopy;
      x1 := 0;
      x2 := Width+2;
      y1 := 0;
      y2 := Height+2;
      Pw := (Width / 2) / 255;
      Ph := (Height / 2) / 255;
      for I := 0 to 255 do begin         //Make rectangles of color
        x1 := x1 + Pw;
        x2 := X2 - Pw;
        y1 := y1 + Ph;
        y2 := y2 - Ph;
        R := fr + Muldv(I, dr, 255);    //Find the RGB values
        G := fg + Muldv(I, dg, 255);
        B := fb + Muldv(I, db, 255);
        Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
        r1 := Rect.Left + Trunc(x1);
        r2 := Rect.Top+Trunc(y1);
        r3 := Rect.Left+Trunc(x2);
        r4 := Rect.Top+Trunc(y2);
        if r3 > Rect.Right then r3 := Rect.Right;
        if r4 > Rect.Bottom then r4 := Rect.Bottom;
        Canvas.FillRect(Classes.Rect(r1, r2,r3,r4));
      end;
      Canvas.Pen.Style := psSolid;
    end;

    procedure DoVertCenter(fr, fg, fb, dr, dg, db : Integer);
    var
      ColorRect: TRect;
      I: Integer;
      R, G, B : Byte;
      Haf : Integer;
    begin
      Haf := Height Div 2;
      ColorRect.Left := Rect.Left;
      ColorRect.Right := Rect.Right;
      for I := 0 to Haf do begin
        ColorRect.Top := Rect.Top + Muldv (I, Haf, Haf);
        ColorRect.Bottom := Rect.Top + Muldv (I + 1, Haf, Haf);
        R := fr + Muldv(I, dr, Haf);
        G := fg + Muldv(I, dg, Haf);
        B := fb + Muldv(I, db, Haf);
        Canvas.Brush.Color := RGB(R, G, B);
        Canvas.FillRect(ColorRect);
        ColorRect.Top := Rect.Top + Height - (Muldv (I, Haf, Haf));
        ColorRect.Bottom := Rect.Top +  Height - (Muldv (I + 1, Haf, Haf));
        Canvas.FillRect(ColorRect);
      end;
    end;

    procedure DoHorizCenter(fr, fg, fb, dr, dg, db : Integer);
    var
      ColorRect: TRect;
      I: Integer;
      R, G, B : Byte;
      Haf : Integer;
    begin
      Haf := Width Div 2;
      ColorRect.Top := Rect.Top;
      ColorRect.Bottom := Rect.Bottom;
      for I := 0 to Haf do begin
        ColorRect.Left := Rect.Left + Muldv (I, Haf, Haf);
        ColorRect.Right := Rect.Left + Muldv (I + 1, Haf, Haf);
        R := fr + Muldv(I, dr, Haf);
        G := fg + Muldv(I, dg, Haf);
        B := fb + Muldv(I, db, Haf);
        Canvas.Brush.Color := RGB(R, G, B);
        Canvas.FillRect(ColorRect);
        ColorRect.Left := Rect.Left + Width - (Muldv (I, Haf, Haf));
        ColorRect.Right := Rect.Left + Width - (Muldv (I + 1, Haf, Haf));
        Canvas.FillRect(ColorRect);
      end;
    end;


var
  FromR, FromG, FromB : Integer; //These are the separate color values for RGB
  DiffR, DiffG, DiffB : Integer; // of color values.
begin
  FromR := BeginClr and $000000ff;  //Strip out separate RGB values
  FromG := (BeginClr shr 8) and $000000ff;
  FromB := (BeginClr shr 16) and $000000ff;
  DiffR := (EndClr  and $000000ff) - FromR;   //Find the difference
  DiffG := ((EndClr shr 8) and $000000ff) - FromG;
  DiffB := ((EndClr shr 16) and $000000ff) - FromB;

  Height := Rect.Bottom-Rect.Top;
  Width  := Rect.Right-Rect.Left;

    //Depending on gradient style selected, go draw it on the Bitmap canvas.
  case style of
    gsHorizontal  : DoHorizontal(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsVertical    : DoVertical(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsElliptic    : DoElliptic(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsRectangle   : DoRectangle(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsVertCenter  : DoVertCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsHorizCenter : DoHorizCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
  end;

end;

{*
{ Gradient fill procedure - displays a gradient beginning with a chosen    }
{ color and ending with another chosen color. Based on TGradientFill       }
{ component source code written by Curtis White, cwhite@teleport.com.      }

{ TTabColors }

constructor TTabColors.Create(AOwner: TComponent);
begin
  inherited Create;
    if Aowner is TTabExtSheet then
    FOwner := AOwner As TTabExtSheet;
    FColor       := clBtnFace;
    FAFontColor  := clCaptionText;
    FIAFontColor := clInActiveCaptionText;
    FATabColor   := clActiveCaption;
    FATabColor2  := clGradientActiveCaption;
    FIATabColor  := clInActiveCaption;
    FIATabColor2 := clGradientInActiveCaption;
end;

procedure TTabColors.SetAFontColor(Value: TColor);
begin
  if Value <> FAFontColor then
  begin
  FAFontColor := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.PageExtControl.Invalidate;
  end;
end;

procedure TTabColors.SetATabColor(Value: TColor);
begin
   if Value <> FATabColor then
   begin
   FATabColor := Value;
   if Not(csLoading in FOwner.ComponentState) then
   FOwner.PageExtControl.Invalidate;
  end;
end;

procedure TTabColors.SetATabColor2(Value: TColor);
begin
  if Value <> FATabColor2 then
  begin
  FATabColor2 := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.PageExtControl.Invalidate;
  end;
end;

procedure TTabColors.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
  FColor := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.Invalidate;
  end;
end;

procedure TTabColors.SetIAFontColor(Value: TColor);
begin
  if Value <> FIAFontColor then
  begin
  FIAFontColor := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.PageExtControl.Invalidate;
  end;
end;

procedure TTabColors.SetIATabColor(Value: TColor);
begin
  if Value <> FIATabColor then
  begin
  FIATabColor := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.PageExtControl.Invalidate;
  end;
end;

procedure TTabColors.SetIATabColor2(Value: TColor);
begin
  if Value <> FIATabColor2 then
  begin
  FIATabColor2 := Value;
  if Not(csLoading in FOwner.ComponentState) then
  FOwner.PageExtControl.Invalidate;
  end;
end;

end.

