object FormRevert: TFormRevert
  Left = 192
  Top = 107
  BorderStyle = bsSingle
  Caption = 'Revert to default settings'
  ClientHeight = 303
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 84
    Width = 217
    Height = 13
    Caption = 'Revert the following settings to default values:'
  end
  object mInfo: TMemo
    Left = 0
    Top = 0
    Width = 388
    Height = 69
    Align = alTop
    Lines.Strings = (
      'You can backup your registry settings using regedit. '
      'All settings are stored under the key'
      'HKEY_CURRENT_USER%ROOTKEY%'
      
        'Export this key to a file to back up settings, and reimport it t' +
        'o load those settings.'
      '')
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object bbOk: TBitBtn
    Left = 96
    Top = 268
    Width = 80
    Height = 30
    TabOrder = 1
    Kind = bkOK
  end
  object bbCancel: TBitBtn
    Left = 212
    Top = 268
    Width = 80
    Height = 30
    TabOrder = 2
    Kind = bkCancel
  end
  object cbAlign: TCheckBox
    Left = 4
    Top = 211
    Width = 97
    Height = 17
    Caption = 'Align'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object cbCaps: TCheckBox
    Left = 4
    Top = 108
    Width = 97
    Height = 17
    Caption = 'Capitalisation'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object cbClarify: TCheckBox
    Left = 4
    Top = 134
    Width = 97
    Height = 17
    Caption = 'Clarify'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object cbFile: TCheckBox
    Left = 180
    Top = 134
    Width = 97
    Height = 17
    Caption = 'File'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object cbIndent: TCheckBox
    Left = 4
    Top = 185
    Width = 97
    Height = 17
    Caption = 'Indent'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object cbLog: TCheckBox
    Left = 180
    Top = 160
    Width = 97
    Height = 17
    Caption = 'Log'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object cbObfuscate: TCheckBox
    Left = 180
    Top = 108
    Width = 97
    Height = 17
    Caption = 'Obfuscate'
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object cbReplace: TCheckBox
    Left = 180
    Top = 185
    Width = 97
    Height = 17
    Caption = 'Replace'
    Checked = True
    State = cbChecked
    TabOrder = 10
  end
  object cbSpaces: TCheckBox
    Left = 4
    Top = 160
    Width = 97
    Height = 17
    Caption = 'Spaces'
    Checked = True
    State = cbChecked
    TabOrder = 11
  end
  object cbReturns: TCheckBox
    Left = 4
    Top = 236
    Width = 97
    Height = 17
    Caption = 'Returns'
    Checked = True
    State = cbChecked
    TabOrder = 12
  end
  object cbSpecificWordCaps: TCheckBox
    Left = 180
    Top = 211
    Width = 141
    Height = 17
    Caption = 'Specific word caps'
    Checked = True
    State = cbChecked
    TabOrder = 13
  end
  object cbUses: TCheckBox
    Left = 180
    Top = 236
    Width = 97
    Height = 17
    Caption = 'Uses'
    Checked = True
    State = cbChecked
    TabOrder = 14
  end
end
