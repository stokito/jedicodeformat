inherited fReplace: TfReplace
  Width = 262
  Height = 259
  OnResize = FrameResize
  object lblWordList: TLabel
    Left = 4
    Top = 32
    Width = 41
    Height = 13
    Caption = 'Word list'
  end
  object cbEnable: TCheckBox
    Left = 6
    Top = 6
    Width = 141
    Height = 17
    Caption = 'Enable find and replace'
    TabOrder = 0
    OnClick = cbEnableClick
  end
  object mWords: TJvMemoEx
    Left = 0
    Top = 48
    Width = 262
    Height = 211
    MaxLines = 0
    AutoVScrollbar = True
    Align = alBottom
    TabOrder = 1
  end
end
