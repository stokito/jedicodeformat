object FormAllSettings: TFormAllSettings
  Left = 192
  Top = 106
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Jedi Code Format settings'
  ClientHeight = 386
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tvFrames: TTreeView
    Left = 4
    Top = 6
    Width = 165
    Height = 340
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnChange = tvFramesChange
    Items.Data = {
      04000000200000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      074C6F6767696E67230000000000000000000000FFFFFFFFFFFFFFFF00000000
      000000000A4578636C7573696F6E73220000000000000000000000FFFFFFFFFF
      FFFFFF0000000000000000094F62667573636174652000000000000000000000
      00FFFFFFFFFFFFFFFF000000000700000007436C61726966791F000000000000
      0000000000FFFFFFFFFFFFFFFF00000000000000000653706163657324000000
      0000000000000000FFFFFFFFFFFFFFFF00000000000000000B496E64656E7461
      74696F6E200000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0752657475726E731F0000000000000000000000FFFFFFFFFFFFFFFF00000000
      0000000006426C6F636B731E0000000000000000000000FFFFFFFFFFFFFFFF00
      0000000000000005416C69676E270000000000000000000000FFFFFFFFFFFFFF
      FF00000000020000000E4361706974616C69736174696F6E2600000000000000
      00000000FFFFFFFFFFFFFFFF00000000000000000D4F626A6563742050617363
      616C210000000000000000000000FFFFFFFFFFFFFFFF00000000000000000841
      6E7920576F7264290000000000000000000000FFFFFFFFFFFFFFFF0000000001
      0000001046696E6420616E64205265706C6163651D0000000000000000000000
      FFFFFFFFFFFFFFFF00000000000000000455736573}
  end
  object pnlSet: TPanel
    Left = 172
    Top = 6
    Width = 345
    Height = 340
    BevelOuter = bvNone
    TabOrder = 1
  end
  object bbOK: TBitBtn
    Left = 144
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 2
    OnClick = bbOKClick
    Kind = bkOK
  end
  object bbCancel: TBitBtn
    Left = 224
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 3
    OnClick = bbCancelClick
    Kind = bkCancel
  end
  object BitBtn1: TBitBtn
    Left = 304
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 4
    OnClick = bbHelpClick
    Kind = bkHelp
  end
end