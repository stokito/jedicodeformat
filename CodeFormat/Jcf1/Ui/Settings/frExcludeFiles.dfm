inherited fExcludeFiles: TfExcludeFiles
  Height = 274
  OnResize = FrameResize
  object lblFilesCaption: TLabel
    Left = 4
    Top = 4
    Width = 225
    Height = 13
    Caption = 'Individual files to exclude from batch processing'
  end
  object lblDirsCaption: TLabel
    Left = 4
    Top = 130
    Width = 209
    Height = 13
    Caption = 'Directories to exclude from batch processing'
  end
  object mFiles: TJvMemoEx
    Left = 0
    Top = 20
    Width = 320
    Height = 100
    MaxLines = 0
    AutoVScrollbar = True
    TabOrder = 0
    OnDragDrop = mFilesDragDrop
    OnDragOver = mFilesDragOver
  end
  object mDirs: TJvMemoEx
    Left = 0
    Top = 146
    Width = 320
    Height = 100
    MaxLines = 0
    AutoVScrollbar = True
    TabOrder = 1
    OnDragDrop = mDirsDragDrop
    OnDragOver = mDirsDragOver
  end
end
