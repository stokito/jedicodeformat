inherited fClarifyReturns: TfClarifyReturns
  Width = 334
  Height = 351
  OnResize = FrameResize
  object Label3: TLabel
    Left = 138
    Top = 8
    Width = 71
    Height = 13
    Caption = 'Max line length'
  end
  object bvRebreak: TBevel
    Left = 4
    Top = 32
    Width = 289
    Height = 5
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 2
    Top = 220
    Width = 199
    Height = 13
    Caption = 'Number or returns after the unit'#39's final end.'
  end
  object edtMaxLineLength: TJvIntegerEdit
    Left = 216
    Top = 6
    Width = 49
    Height = 21
    Alignment = taRightJustify
    ReadOnly = False
    TabOrder = 0
    Value = 0
    MaxValue = 255
    MinValue = 0
    HasMaxValue = True
    HasMinValue = True
  end
  object cbRebreakLines: TCheckBox
    Left = 4
    Top = 6
    Width = 118
    Height = 17
    Caption = 'Rebreak long lines'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = cbRebreakLinesClick
  end
  object cbRemoveReturns: TCheckBox
    Left = 4
    Top = 62
    Width = 217
    Height = 17
    Caption = 'Remove returns in misc. bad places'
    TabOrder = 2
  end
  object cbRemoveVarBlankLines: TCheckBox
    Left = 4
    Top = 171
    Width = 237
    Height = 17
    Caption = 'Remove blank lines in procedure var section'
    TabOrder = 3
  end
  object cbRemovePropertyReturns: TCheckBox
    Left = 4
    Top = 80
    Width = 181
    Height = 17
    Caption = 'Remove returns in properties'
    TabOrder = 4
  end
  object cbRemoveExprReturns: TCheckBox
    Left = 4
    Top = 98
    Width = 181
    Height = 17
    Caption = 'Remove returns in expressions'
    TabOrder = 5
  end
  object cbInsertReturns: TCheckBox
    Left = 4
    Top = 44
    Width = 217
    Height = 17
    Caption = 'Insert returns in misc. good places'
    TabOrder = 6
  end
  object cbRemoveProcDefReturns: TCheckBox
    Left = 4
    Top = 117
    Width = 237
    Height = 17
    Caption = 'Remove returns in procedure definitions'
    TabOrder = 7
  end
  object cbRemoveVarReturns: TCheckBox
    Left = 4
    Top = 135
    Width = 237
    Height = 17
    Caption = 'Remove returns in variable declarations'
    TabOrder = 8
  end
  object eNumReturnsAfterFinalEnd: TJvIntegerEdit
    Left = 204
    Top = 214
    Width = 49
    Height = 21
    Alignment = taRightJustify
    ReadOnly = False
    TabOrder = 9
    Value = 0
    MaxValue = 255
    MinValue = 0
    HasMaxValue = True
    HasMinValue = True
  end
  object cbRemoveBlankLinesAfterProcHeader: TCheckBox
    Left = 4
    Top = 153
    Width = 237
    Height = 17
    Caption = 'Remove blank lines after procedure header'
    TabOrder = 10
  end
  object cbRemoveBlockBlankLines: TCheckBox
    Left = 4
    Top = 190
    Width = 253
    Height = 17
    Caption = 'Remove blank lines at start and end of block'
    TabOrder = 11
  end
  object rgReturnChars: TRadioGroup
    Left = 4
    Top = 244
    Width = 301
    Height = 73
    Caption = 'Return chars'
    Items.Strings = (
      'Leave as is'
      'Convert to Carriage return (UNIX)'
      'Convert to Carriage-return + Linefeed (DOS/Windows)')
    TabOrder = 12
  end
end
