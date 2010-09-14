object frmMain: TfrmMain
  Left = 308
  Top = 140
  Width = 243
  Height = 314
  Caption = 'YMsgPas'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 241
    Width = 235
    Height = 19
    Panels = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 235
    Height = 241
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 233
      Height = 239
      ActivePage = TabSheet1
      Align = alClient
      Style = tsFlatButtons
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'TabSheet1'
        DesignSize = (
          225
          208)
        object GroupBox1: TGroupBox
          Left = 7
          Top = 15
          Width = 209
          Height = 169
          Anchors = []
          Caption = 'Yahoo! account'
          TabOrder = 0
          object Label1: TLabel
            Left = 16
            Top = 24
            Width = 48
            Height = 13
            Caption = 'Yahoo! &ID'
            FocusControl = edtYID
          end
          object Label2: TLabel
            Left = 16
            Top = 72
            Width = 46
            Height = 13
            Caption = '&Password'
            FocusControl = edtPWD
          end
          object edtYID: TEdit
            Left = 16
            Top = 40
            Width = 177
            Height = 21
            TabOrder = 0
          end
          object edtPWD: TEdit
            Left = 16
            Top = 88
            Width = 177
            Height = 21
            PasswordChar = '*'
            TabOrder = 1
          end
          object btnLogin: TButton
            Left = 64
            Top = 128
            Width = 75
            Height = 25
            Caption = '&LOGIN'
            TabOrder = 2
            OnClick = btnLoginClick
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'TabSheet2'
        ImageIndex = 1
        object TreeBuddies: TTreeView
          Left = 0
          Top = 0
          Width = 225
          Height = 208
          Align = alClient
          Indent = 19
          TabOrder = 0
          OnDblClick = TreeBuddiesDblClick
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'TabSheet3'
        ImageIndex = 2
        object Memo1: TMemo
          Left = 0
          Top = 0
          Width = 225
          Height = 208
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 80
    Top = 224
    object YMsgPas1: TMenuItem
      Caption = '&YMsgPas'
      object Login1: TMenuItem
        Caption = '&Login'
        OnClick = btnLoginClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ChatRooms1: TMenuItem
        Caption = '&Chat Rooms'
        OnClick = ChatRooms1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
  end
end
