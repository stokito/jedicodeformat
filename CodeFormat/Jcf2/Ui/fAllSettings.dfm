object FormAllSettings: TFormAllSettings
  Left = 192
  Top = 106
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'JCF Format settings'
  ClientHeight = 386
  ClientWidth = 532
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
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
      03000000240000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0B466F726D61742066696C65220000000000000000000000FFFFFFFFFFFFFFFF
      0000000000000000094F6266757363617465200000000000000000000000FFFF
      FFFFFFFFFFFF000000000800000007436C61726966791F000000000000000000
      0000FFFFFFFFFFFFFFFF00000000000000000653706163657324000000000000
      0000000000FFFFFFFFFFFFFFFF00000000000000000B496E64656E746174696F
      6E230000000000000000000000FFFFFFFFFFFFFFFF00000000000000000A4C6F
      6E67204C696E6573200000000000000000000000FFFFFFFFFFFFFFFF00000000
      000000000752657475726E731F0000000000000000000000FFFFFFFFFFFFFFFF
      000000000000000006426C6F636B731E0000000000000000000000FFFFFFFFFF
      FFFFFF000000000000000005416C69676E270000000000000000000000FFFFFF
      FFFFFFFFFF00000000030000000E4361706974616C69736174696F6E26000000
      0000000000000000FFFFFFFFFFFFFFFF00000000000000000D4F626A65637420
      50617363616C210000000000000000000000FFFFFFFFFFFFFFFF000000000000
      000008416E7920576F7264220000000000000000000000FFFFFFFFFFFFFFFF00
      0000000000000009556E6974204E616D65290000000000000000000000FFFFFF
      FFFFFFFFFF00000000010000001046696E6420616E64205265706C6163651D00
      00000000000000000000FFFFFFFFFFFFFFFF00000000000000000455736573}
  end
  object pnlSet: TPanel
    Left = 172
    Top = 6
    Width = 356
    Height = 340
    BevelOuter = bvNone
    TabOrder = 1
  end
  object bbOK: TBitBtn
    Left = 149
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 2
    OnClick = bbOKClick
    Kind = bkOK
  end
  object bbCancel: TBitBtn
    Left = 229
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 3
    OnClick = bbCancelClick
    Kind = bkCancel
  end
  object BitBtn1: TBitBtn
    Left = 309
    Top = 352
    Width = 75
    Height = 29
    TabOrder = 4
    OnClick = bbHelpClick
    Kind = bkHelp
  end
end
