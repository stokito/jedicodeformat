object ExceptionDialog: TExceptionDialog
  Left = 294
  Top = 195
  BorderStyle = bsDialog
  Caption = 'Exception'
  ClientHeight = 148
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 126
    Top = 112
    Width = 80
    Height = 28
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = btnOkClick
  end
  object mExceptionMessage: TMemo
    Left = 0
    Top = 0
    Width = 332
    Height = 101
    Align = alTop
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
  end
end
