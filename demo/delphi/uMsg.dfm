object frmMessage: TfrmMessage
  Left = 299
  Top = 193
  Width = 372
  Height = 274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 181
    Width = 364
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object Panel1: TPanel
    Left = 0
    Top = 184
    Width = 364
    Height = 56
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      364
      56)
    object MemoSend: TMemo
      Left = 1
      Top = 1
      Width = 272
      Height = 54
      Align = alLeft
      Anchors = [akLeft, akTop, akRight, akBottom]
      MaxLength = 254
      TabOrder = 0
      OnKeyUp = MemoSendKeyUp
    end
    object btnSend: TButton
      Left = 280
      Top = 8
      Width = 75
      Height = 41
      Anchors = [akTop, akRight]
      Caption = '&S E N D'
      TabOrder = 1
      OnClick = btnSendClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 364
    Height = 181
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object MemoChat: TMemo
      Left = 1
      Top = 1
      Width = 362
      Height = 179
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end
