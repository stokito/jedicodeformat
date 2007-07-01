object FormAllSettings: TFormAllSettings
  Left = 171
  Top = 106
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'JCF Format Settings'
  ClientHeight = 528
  ClientWidth = 872
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  DesignSize = (
    872
    528)
  PixelsPerInch = 120
  TextHeight = 20
  object tvFrames: TTreeView
    Left = 3
    Top = 3
    Width = 240
    Height = 468
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnChange = tvFramesChange
    Items.NodeData = {
      01040000002F0000000000000000000000FFFFFFFFFFFFFFFF00000000000000
      000B46006F0072006D00610074002000460069006C0065002B00000000000000
      00000000FFFFFFFFFFFFFFFF0000000000000000094F00620066007500730063
      00610074006500270000000000000000000000FFFFFFFFFFFFFFFF000000000A
      0000000743006C0061007200690066007900250000000000000000000000FFFF
      FFFFFFFFFFFF0000000000000000065300700061006300650073002F00000000
      00000000000000FFFFFFFFFFFFFFFF00000000000000000B49006E0064006500
      6E0074006100740069006F006E002F0000000000000000000000FFFFFFFFFFFF
      FFFF00000000000000000B42006C0061006E006B0020004C0069006E00650073
      00230000000000000000000000FFFFFFFFFFFFFFFF0000000000000000054100
      6C00690067006E00330000000000000000000000FFFFFFFFFFFFFFFF00000000
      050000000D4C0069006E006500200042007200650061006B0069006E0067002D
      0000000000000000000000FFFFFFFFFFFFFFFF00000000000000000A4C006F00
      6E00670020004C0069006E0065007300270000000000000000000000FFFFFFFF
      FFFFFFFF000000000000000007520065007400750072006E0073002F00000000
      00000000000000FFFFFFFFFFFFFFFF00000000000000000B4300610073006500
      200042006C006F0063006B007300250000000000000000000000FFFFFFFFFFFF
      FFFF00000000000000000642006C006F0063006B0073003F0000000000000000
      000000FFFFFFFFFFFFFFFF00000000000000001343006F006D00700069006C00
      6500720020004400690072006500630074006900760065007300290000000000
      000000000000FFFFFFFFFFFFFFFF00000000000000000843006F006D006D0065
      006E0074007300290000000000000000000000FFFFFFFFFFFFFFFF0000000000
      000000085700610072006E0069006E0067007300350000000000000000000000
      FFFFFFFFFFFFFFFF00000000050000000E4300610070006900740061006C0069
      0073006100740069006F006E00330000000000000000000000FFFFFFFFFFFFFF
      FF00000000000000000D4F0062006A0065006300740020005000610073006300
      61006C00290000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0841006E007900200057006F00720064002F0000000000000000000000FFFFFF
      FFFFFFFFFF00000000000000000B4900640065006E0074006900660069006500
      72007300370000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0F4E006F00740020004900640065006E0074006900660069006500720073002B
      0000000000000000000000FFFFFFFFFFFFFFFF00000000000000000955006E00
      6900740020004E0061006D006500390000000000000000000000FFFFFFFFFFFF
      FFFF000000000100000010460069006E006400200061006E0064002000520065
      0070006C00610063006500210000000000000000000000FFFFFFFFFFFFFFFF00
      000000000000000455007300650073002B0000000000000000000000FFFFFFFF
      FFFFFFFF0000000000000000095400720061006E00730066006F0072006D0031
      0000000000000000000000FFFFFFFFFFFFFFFF00000000000000000C50007200
      6500500072006F0063006500730073006F007200}
  end
  object pnlSet: TPanel
    Left = 240
    Top = 3
    Width = 629
    Height = 468
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    TabOrder = 1
  end
  object bbOK: TBitBtn
    Left = 292
    Top = 480
    Width = 92
    Height = 36
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    OnClick = bbOKClick
    Kind = bkOK
  end
  object bbCancel: TBitBtn
    Left = 389
    Top = 480
    Width = 94
    Height = 36
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    OnClick = bbCancelClick
    Kind = bkCancel
  end
  object BitBtn1: TBitBtn
    Left = 488
    Top = 480
    Width = 92
    Height = 36
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    OnClick = bbHelpClick
    Kind = bkHelp
  end
end
