inherited fClarifySpaces: TfClarifySpaces
  Width = 295
  Height = 394
  object cbFixSpacing: TCheckBox
    Left = 8
    Top = 6
    Width = 89
    Height = 17
    Caption = 'Fix spacing'
    TabOrder = 0
  end
  object cbSpaceClassHeritage: TCheckBox
    Left = 8
    Top = 24
    Width = 161
    Height = 17
    Caption = 'Space before class heritage'
    TabOrder = 1
  end
  object gbColon: TGroupBox
    Left = 2
    Top = 42
    Width = 213
    Height = 189
    Caption = 'Spaces before colon in'
    TabOrder = 2
    object Label2: TLabel
      Left = 6
      Top = 24
      Width = 126
      Height = 13
      Caption = 'Var and const declarations'
    end
    object Label4: TLabel
      Left = 6
      Top = 108
      Width = 70
      Height = 13
      Caption = 'Class variables'
    end
    object Label7: TLabel
      Left = 6
      Top = 80
      Width = 99
      Height = 13
      Caption = 'Function return types'
    end
    object Label8: TLabel
      Left = 6
      Top = 52
      Width = 104
      Height = 13
      Caption = 'Procedure parameters'
    end
    object Label5: TLabel
      Left = 6
      Top = 136
      Width = 49
      Height = 13
      Caption = 'Case label'
    end
    object Label6: TLabel
      Left = 6
      Top = 164
      Width = 26
      Height = 13
      Caption = 'Label'
    end
    object eSpaceBeforeColonVar: TJvIntegerEdit
      Left = 142
      Top = 24
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 0
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
    object eSpaceBeforeColonParam: TJvIntegerEdit
      Left = 142
      Top = 52
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 1
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
    object eSpaceBeforeColonFn: TJvIntegerEdit
      Left = 142
      Top = 76
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 2
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
    object eSpacesBeforeColonClassVar: TJvIntegerEdit
      Left = 142
      Top = 104
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 3
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
    object eSpacesBeforeCaseLabel: TJvIntegerEdit
      Left = 142
      Top = 132
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 4
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
    object eSpacesBeforeLabel: TJvIntegerEdit
      Left = 142
      Top = 160
      Width = 50
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 5
      Value = 0
      MaxValue = 0
      MinValue = 0
      HasMaxValue = False
      HasMinValue = False
    end
  end
  object gbTabs: TGroupBox
    Left = 2
    Top = 232
    Width = 277
    Height = 72
    Caption = 'Tab characters'
    TabOrder = 3
    object Label1: TLabel
      Left = 136
      Top = 20
      Width = 72
      Height = 13
      Caption = 'Spaces per tab'
    end
    object Label3: TLabel
      Left = 136
      Top = 44
      Width = 69
      Height = 13
      Caption = 'Spaces for tab'
    end
    object cbTabsToSpaces: TCheckBox
      Left = 6
      Top = 20
      Width = 117
      Height = 17
      Caption = 'Turn tabs to spaces'
      TabOrder = 0
      OnClick = cbTabsToSpacesClick
    end
    object cbSpacesToTabs: TCheckBox
      Left = 6
      Top = 44
      Width = 117
      Height = 17
      Caption = 'Turn spaces to tabs'
      TabOrder = 1
      OnClick = cbSpacesToTabsClick
    end
    object edtSpacesPerTab: TJvIntegerEdit
      Left = 212
      Top = 18
      Width = 49
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 2
      Value = 0
      MaxValue = 12
      MinValue = 0
      HasMaxValue = True
      HasMinValue = True
    end
    object edtSpacesForTab: TJvIntegerEdit
      Left = 212
      Top = 42
      Width = 49
      Height = 21
      Alignment = taRightJustify
      MaxLength = 2
      ReadOnly = False
      TabOrder = 3
      Value = 0
      MaxValue = 12
      MinValue = 0
      HasMaxValue = True
      HasMinValue = True
    end
  end
  object cbMaxSpaces: TCheckBox
    Left = 4
    Top = 308
    Width = 129
    Height = 17
    Caption = 'Max spaces in code'
    TabOrder = 4
    OnClick = cbMaxSpacesClick
  end
  object edtMaxSpacesInCode: TJvIntegerEdit
    Left = 216
    Top = 310
    Width = 49
    Height = 21
    Alignment = taRightJustify
    MaxLength = 2
    ReadOnly = False
    TabOrder = 5
    Value = 0
    MaxValue = 99
    MinValue = 0
    HasMaxValue = True
    HasMinValue = True
  end
end