unit frmJcfNotepad;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is frmJcfNotepad, released May 2003.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele. 

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations 
under the License.
------------------------------------------------------------------------------*)
{*)}

interface

uses
  { delphi }
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ExtActns, StdActns, ActnList,
  Buttons, Menus,
  { Jedi }
  JvMRUList, JvMemo,
  { local } StringsConverter, JcfRegistrySettings, JvPlacemnt;

type
  TfmJCFNotepad = class(TForm)
    sb1: TStatusBar;
    pnlTop: TPanel;
    pcPages: TPageControl;
    tsInput: TTabSheet;
    tsOutput: TTabSheet;
    mInput: TJvMemo;
    mOutput: TJvMemo;
    mMessages: TJvMemo;
    lblMessages: TLabel;
    sbLoad: TSpeedButton;
    sbSave: TSpeedButton;
    sbGo: TSpeedButton;
    ActionList1: TActionList;
    actOpen: TAction;
    actSave: TAction;
    actGo: TAction;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    actClear: TAction;
    sbClear: TSpeedButton;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSaveOut: TMenuItem;
    mnuExit: TMenuItem;
    mnuSettings: TMenuItem;
    actCopy: TAction;
    actPaste: TAction;
    N1: TMenuItem;
    mruFiles: TJvMRUManager;
    mnuEdit: TMenuItem;
    mnuEditPaste: TMenuItem;
    mnuEditCopy: TMenuItem;
    mnuEditGo: TMenuItem;
    mnuEditClear: TMenuItem;
    mnuEditCut: TMenuItem;
    mnuEditCopyOutput: TMenuItem;
    mnuEditSelectAll: TMenuItem;
    mnuEditCopyMessages: TMenuItem;
    mnuFormat: TMenuItem;
    mnuFileSaveIn: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuShowRegSetting: TMenuItem;
    mnuFormatSettings: TMenuItem;
    ActCut: TAction;
    Contents1: TMenuItem;
    JvFormStorage1: TJvFormStorage;
    procedure FormResize(Sender: TObject);
    procedure pcPagesChange(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure mInputKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure mruFilesClick(Sender: TObject; const RecentName,
      Caption: String; UserData: Integer);
    procedure mnuEditCopyOutputClick(Sender: TObject);
    procedure mnuEditSelectAllClick(Sender: TObject);
    procedure mnuEditCopyMessagesClick(Sender: TObject);
    procedure mnuFileSaveInClick(Sender: TObject);
    procedure mnuHelpAboutClick(Sender: TObject);
    procedure mnuShowRegSettingClick(Sender: TObject);
    procedure mnuFormatSettingsClick(Sender: TObject);
    procedure ActCutExecute(Sender: TObject);
    procedure mInputMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Contents1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    fcConvert: TStringsConverter;

    procedure CheckInputState;
    procedure CheckCutPasteState;
    procedure DoFileOpen(const psFileName: string);
    procedure AddCheckMRU(const psFile: string);

  public
  end;

var
  fmJCFNotepad: TfmJCFNotepad;

implementation

uses
  { delphi }
  ClipBrd,
  { jcl }
  JclStrings,
  { local }
  JCFHelp, Converter, ConvertTypes, fAbout, fRegistrySettings, fAllSettings;

{$R *.dfm}



procedure TfmJCFNotepad.CheckInputState;
begin
  actGo.Enabled := (mInput.Text <> '');
  actClear.Enabled := (mInput.Text <> '');
end;

procedure TfmJCFNotepad.CheckCutPasteState;
var
  lbHasOutput: boolean;
begin
  actPaste.Enabled := (pcPages.ActivePage = tsInput) and  Clipboard.HasFormat(CF_TEXT);
  actCut.Enabled := (pcPages.ActivePage = tsInput) and (mInput.SelLength > 0);

  lbHasOutput := (pcPages.ActivePage = tsOutput) and (mOutput.Text <> '');
  actSave.Enabled := lbHasOutput;

  if pcPages.ActivePage = tsOutput then
    actCopy.Enabled := lbHasOutput
  else
    actCopy.Enabled := (mInput.Text <> '');


end;

procedure TfmJCFNotepad.DoFileOpen(const psFileName: string);
begin
  if psFileName = '' then
    exit;
  if not FileExists(psFileName) then
    exit;

  GetRegSettings.InputDir := ExtractFilePath(psFileName);
  mInput.Text := FileToString(psFileName);
  sb1.SimpleText := psFileName;
  AddCheckMRU(psFileName);

  CheckInputState;
end;

procedure TfmJCFNotepad.AddCheckMRU(const psFile: string);
var
  liIndex: integer;
begin
  liIndex := mruFiles.Strings.IndexOf(psFile);

  if (liIndex < 0) then
  begin
    mruFiles.Add(psFile, 0);
    liIndex := mruFiles.Strings.IndexOf(psFile);
  end;

  mruFiles.Strings.Move(liIndex, 0);

  while mruFiles.Strings.Count > mruFiles.Capacity do
    mruFiles.Strings.Delete(mruFiles.Strings.Count - 1);
end;

procedure TfmJCFNotepad.FormResize(Sender: TObject);
const
  OUTPUT_PAD = 4;
begin
  mOutput.Left := OUTPUT_PAD;
  mOutput.Top := OUTPUT_PAD;
  mOutput.Width := tsOutput.ClientWidth - (2 * OUTPUT_PAD);

  // two thirds height
  mOutput.Height := (tsOutput.Height * 2 div 3) - (2 * OUTPUT_PAD);

  lblMessages.Left := 4;
  lblMessages.Top := mOutput.Top + mOutput.Height + OUTPUT_PAD;

  mMessages.Top := lblMessages.Top + lblMessages.Height + OUTPUT_PAD;
  mMessages.Height := tsOutput.ClientHeight - (lblMessages.Top + lblMessages.Height + (OUTPUT_PAD * 2));
  mMessages.Left := OUTPUT_PAD;
  mMessages.Width := tsOutput.ClientWidth - (2 * OUTPUT_PAD);
end;

procedure TfmJCFNotepad.pcPagesChange(Sender: TObject);
begin
  CheckCutPasteState;
end;

procedure TfmJCFNotepad.actGoExecute(Sender: TObject);
begin
  mMessages.Clear;
  fcConvert.InputStrings := mInput.Lines;
  fcConvert.OutputStrings := mOutput.Lines;
  fcConvert.MessageStrings := mMessages.Lines;

  fcConvert.Convert;
  fcConvert.Clear;

  pcPages.ActivePage := tsOutput;
  pcPagesChange(nil);
end;

procedure TfmJCFNotepad.mInputKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CheckInputState;
  CheckCutPasteState;
end;


procedure TfmJCFNotepad.FormShow(Sender: TObject);
begin
  CheckInputState;
  CheckCutPasteState;
end;

procedure TfmJCFNotepad.actOpenExecute(Sender: TObject);
begin
  OpenDialog1.InitialDir := GetRegSettings.InputDir;
  OpenDialog1.Filter := SOURCE_FILE_FILTERS;

  if OpenDialog1.Execute then
  begin
    DoFileOpen(OpenDialog1.FileName);
    pcPages.ActivePage := tsInput;
  end;
end;

procedure TfmJCFNotepad.actClearExecute(Sender: TObject);
begin
  mInput.Text := '';
  mOutput.Text := '';
  mMessages.Text := '';
  pcPages.ActivePage := tsInput;

  CheckInputState;
  CheckCutPasteState;
end;

procedure TfmJCFNotepad.actSaveExecute(Sender: TObject);
begin
  SaveDialog1.InitialDir := GetRegSettings.OutputDir;
  SaveDialog1.Title := 'Save output file';
  SaveDialog1.Filter := SOURCE_FILE_FILTERS;


  if SaveDialog1.Execute then
  begin
    GetRegSettings.OutputDir := ExtractFilePath(SaveDialog1.FileName);
    StringToFile(SaveDialog1.FileName, mOutput.Text);
    sb1.SimpleText := 'Saved output: ' + SaveDialog1.FileName;
    AddCheckMRU(SaveDialog1.FileName);
  end;
end;

procedure TfmJCFNotepad.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmJCFNotepad.FormCreate(Sender: TObject);
begin
  fcConvert := TStringsConverter.Create;

  GetRegSettings.MRUFiles := mruFiles.Strings;
  GetRegSettings.ReadAll;

  mruFiles.RemoveInvalid;
end;

procedure TfmJCFNotepad.FormDestroy(Sender: TObject);
begin
  GetRegSettings.WriteAll;
  GetRegSettings.MRUFiles := nil;

  FreeAndNil(fcConvert);
end;

procedure TfmJCFNotepad.actCopyExecute(Sender: TObject);
begin
  if pcPages.ActivePage = tsOutput then
    mOutput.CopyToClipboard
  else
    mInput.CopyToClipboard;
end;

procedure TfmJCFNotepad.actPasteExecute(Sender: TObject);
begin
  if (pcPages.ActivePage = tsInput) and Clipboard.HasFormat(CF_TEXT) then
  begin
    mInput.PasteFromClipboard;
    CheckInputState;
  end;
end;

procedure TfmJCFNotepad.mruFilesClick(Sender: TObject; const RecentName,
  Caption: String; UserData: Integer);
begin
  DoFileOpen(RecentName);
end;

procedure TfmJCFNotepad.mnuEditCopyOutputClick(Sender: TObject);
begin
  Clipboard.AsText := mOutput.Text;
end;

procedure TfmJCFNotepad.ActCutExecute(Sender: TObject);
begin
  if (pcPages.ActivePage = tsInput) then
  begin
    mInput.CutToClipboard;
    CheckInputState;
  end;
end;

procedure TfmJCFNotepad.mnuEditSelectAllClick(Sender: TObject);
begin
  if (pcPages.ActivePage = tsInput) then
  begin
    mInput.SetFocus;
    mInput.SelectAll;
    CheckCutPasteState;
  end
  else
  begin
    mOutput.SetFocus;
    mOutput.SelectAll;
  end;
end;

procedure TfmJCFNotepad.mnuEditCopyMessagesClick(Sender: TObject);
begin
  Clipboard.AsText := mMessages.Text;
end;

procedure TfmJCFNotepad.mnuFileSaveInClick(Sender: TObject);
begin
  SaveDialog1.InitialDir := GetRegSettings.OutputDir;
  SaveDialog1.Title := 'Save input file';
  SaveDialog1.Filter := SOURCE_FILE_FILTERS;

  if SaveDialog1.Execute then
  begin
    GetRegSettings.OutputDir := ExtractFilePath(SaveDialog1.FileName);
    StringToFile(SaveDialog1.FileName, mInput.Text);
    sb1.SimpleText := 'Saved input as ' + SaveDialog1.FileName;
    AddCheckMRU(SaveDialog1.FileName);
  end;
end;

procedure TfmJCFNotepad.mnuHelpAboutClick(Sender: TObject);
var
  lfAbout: TfrmAboutBox;
begin
  lfAbout := TfrmAboutBox.Create(self);
  try
    lfAbout.ShowModal;
  finally
    lfAbout.Release;
  end;
end;

procedure TfmJCFNotepad.mnuShowRegSettingClick(Sender: TObject);
var
  lfSettings: TfmRegistrySettings;
begin
  lfSettings := TfmRegistrySettings.Create(self);
  try
    lfSettings.Execute;
  finally
    lfSettings.Release;
  end;
end;

procedure TfmJCFNotepad.mnuFormatSettingsClick(Sender: TObject);
var
  lfAllSettings: TFormAllSettings;
begin
  lfAllSettings := TFormAllSettings.Create(self);
  try
    lfAllSettings.Execute;
  finally
    lfAllSettings.Release;
  end;
end;

procedure TfmJCFNotepad.mInputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CheckCutPasteState;
end;

procedure TfmJCFNotepad.Contents1Click(Sender: TObject);
begin
  Application.HelpContext(HELP_MAIN);
end;

procedure TfmJCFNotepad.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_F1 then
  Application.HelpContext(HELP_MAIN);

end;

end.