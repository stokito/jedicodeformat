{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is fMain.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved. 
Contributor(s): Michael Beck.
                        
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations
under the License.
------------------------------------------------------------------------------*)
{*)}

unit fMain;

{ Created AFS 27 November 1999
  Main form for code formatting utility program
}


interface

uses
    { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Menus,
  ActnList, ImgList, ToolWin,
    { local } FileConverter, JCFSettings, frFiles,
  SettingsFrame, frBasicSettings,  frDrop, StdActns;

type
  TfrmMain = class(TForm)
    sb: TStatusBar;
    mnuMain: TMainMenu;
    mnuActions: TMenuItem;
    mnuGo: TMenuItem;
    mnuClose: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    tlbTop: TToolBar;
    tbtnOpenFiles: TToolButton;
    btnGo: TToolButton;
    btnAbout: TToolButton;
    tbtnToolButton6: TToolButton;
    btnSettings: TToolButton;
    ilStandardImages: TImageList;
    tbtnToolButton8: TToolButton;
    tbtnToolButton2: TToolButton;
    ActionList: TActionList;
    aOpenFiles: TAction;
    aOptions: TAction;
    aGo: TAction;
    aAbout: TAction;
    aExit: TAction;
    tbtnToolButton4: TToolButton;
    btnClose: TToolButton;
    frBasic: TfrBasic;
    OpenFile1: TMenuItem;
    Settings1: TMenuItem;
    mnuViewLog: TMenuItem;
    mnuSettingsToFile: TMenuItem;
    mnuSettingsFromFile: TMenuItem;
    dlgSaveConfig: TSaveDialog;
    actHelpContents: THelpContents;
    mnuContents: TMenuItem;
    tbHelp: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuGoClick(Sender: TObject);
    procedure mnuCloseClick(Sender: TObject);
    procedure aFormatExecute(Sender: TObject);
    procedure aAboutExecue(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure aOpenFilesExecute(Sender: TObject);
    procedure aOptionsExecute(Sender: TObject);
    procedure mnuViewLogClick(Sender: TObject);
    procedure mnuSettingsToFileClick(Sender: TObject);
    procedure mnuSettingsFromFileClick(Sender: TObject);
    procedure actHelpContentsExecute(Sender: TObject);
  private
    fcConverter: TFileConverter;
    fcSettings: TSettings;

    procedure ShowStatusMesssage(const ps: string);

    procedure DoFormat;
    procedure ShowAbout;
    procedure SettingsChange(Sender: TObject);

  public
    property Settings: TSettings read fcSettings;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

uses
  { jcl } JclFileUtils, JclStrings,
  { local } fAbout, ConvertTypes, fAllSettings,
  SettingsStream, MiscFunctions, JCFHelp;


function OkDialog(const psMsg: string): boolean;
begin
  Result := MessageDlg(psMsg, mtWarning, [mbYes, mbCancel], 0) = mrYes;
end;

procedure ErrorDialog(const psMsg: string);
begin
  MessageDlg(psMsg, mtError, [mbOK], 0);
end;

{------------------------------------------------------------------------------
  worker procs }


procedure TfrmMain.DoFormat;
var
  lsSource, lsFileDesc, lsMessage: string;
begin
  frBasic.Write;

  lsSource := Settings.FileSettings.Input;

  if (Settings.FileSettings.SourceMode = fmSingleFile) and
    (ExtractFileName(lsSource) = '') then
  begin
    ErrorDialog('No file specified in direcory');
    Exit;
  end;

  if (lsSource = '') then
  begin
    ErrorDialog('No files to format');
    exit;
  end;

  if Settings.FileSettings.SourceMode = fmSingleFile then
    lsFileDesc := 'the file ' + ExtractFileName(lsSource)
  else
    lsFileDesc := 'the files in ' + lsSource;

  { confirm before obfuscate }
  if Settings.Obfuscate.Enabled then
  begin
    lsMessage := 'Are you sure that you want to obfuscate ' + lsFileDesc;

    if Settings.FileSettings.BackupMode = cmInPlace then
      lsMessage := lsMessage + ' without backup';

    lsMessage := lsMessage + '?';
    if not OkDialog(lsMessage) then
      exit;
  end
  else if (Settings.FileSettings.BackupMode = cmInPlace) then
  begin
    lsMessage := 'Are you sure you want to convert ' + lsFileDesc + ' without backup?';
    if not OkDialog(lsMessage) then
      exit;
  end;
  fcConverter.Convert;
end;

procedure TfrmMain.ShowAbout;
var
  fAbout: TfrmAboutBox;
begin
  fAbout := TfrmAboutBox.Create(self);
  try
    fAbout.ShowModal;
  finally
    fAbout.Release;
  end;
end;

{------------------------------------------------------------------------------
  event handlers}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  lsHelpFile: string;
begin
  lsHelpFile := PathAddSeparator(ExtractFilePath(Application.ExeName)) +
    'CodeFormat.hlp';

  if FileExists(lsHelpFile) then
    Application.HelpFile := lsHelpFile;

  Randomize;

  fcSettings  := TSettings.Create;
  fcConverter := TFileConverter.Create;

  fcConverter.Settings := Settings;
  fcConverter.OnStatusMessage := ShowStatusMesssage;

  frBasic.Settings := fcSettings;
  frBasic.Read;
  frBasic.OnChange := SettingsChange;
  SettingsChange(nil);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  frBasic.Write;
  FreeAndNil(fcConverter);
  FreeAndNil(fcSettings);
end;


procedure TfrmMain.ShowStatusMesssage(const ps: string);
begin
  sb.SimpleText := ps;
  Application.ProcessMessages;
end;

procedure TfrmMain.mnuGoClick(Sender: TObject);
begin
  DoFormat;
end;

procedure TfrmMain.mnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.aFormatExecute(Sender: TObject);
begin
  DoFormat;
end;

procedure TfrmMain.aAboutExecue(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmMain.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmMain.aOpenFilesExecute(Sender: TObject);
begin
  frBasic.sbOpenClick(Self);
end;

procedure TfrmMain.aOptionsExecute(Sender: TObject);
var
  lfSet: TFormAllSettings;
begin
  lfSet := TFormAllSettings.Create(Self);
  try
    lfSet.Settings := Settings;
    lfSet.Execute;
  finally
    lfSet.Release;
  end;
end;

procedure TfrmMain.SettingsChange(Sender: TObject);
begin
  btnGo.Hint := frBasic.GetGoHint;
  if frBasic.GetCurrentSourceMode = fmSingleFile then
    tbtnOpenFiles.Hint := 'Select a source file'
  else
    tbtnOpenFiles.Hint := 'Select a source directory';

end;

procedure TfrmMain.mnuViewLogClick(Sender: TObject);
begin
  Settings.Log.ViewLog;
end;


const
  CONFIG_FILTER = 'Config files (*.cfg)|*.cfg|Text files (*.txt)|' +
    '*.txt|XML files (*.xml)|*.xml|All files (*.*)|*.*';

procedure TfrmMain.mnuSettingsToFileClick(Sender: TObject);
var
  lsName: string;
  dlgSaveConfig: TSaveDialog;
  lcFile: TSettingsStreamOutput;
begin
  lsName := '';

  dlgSaveConfig := TSaveDialog.Create(self);
  try
    dlgSaveConfig.FileName := 'Saved.cfg';
    dlgSaveConfig.InitialDir := ExtractFilePath(Application.ExeName);
    dlgSaveConfig.DefaultExt := '.cfg';
    dlgSaveCOnfig.Filter := CONFIG_FILTER;

    if dlgSaveConfig.Execute then
    begin
      lsName := dlgSaveCOnfig.FileName;
    end;

    if lsName = '' then
      exit;

  finally
    dlgSaveConfig.Free;
  end;

  lcFile := TSettingsStreamOutput.Create(lsName);
  try
    Settings.ToStream(lcFile);
  finally
    lcFile.free;
  end;

end;

procedure TfrmMain.mnuSettingsFromFileClick(Sender: TObject);
var
  lcOpen: TOpenDialog;
  lsName: string;
begin
  lsName := '';

  lcOpen := TOpenDialog.Create(self);
  try
    lcOpen.InitialDir := GetWinDir;
    lcOpen.Filter := CONFIG_FILTER;

    if lcOpen.Execute then
      lsName := lcOpen.FileName;
  finally
    lcOpen.Free;
  end;

  if lsName = '' then
    exit;

  if not FileExists(lsName) then
  begin
    ShowMessage('File ' + lsName + ' not found');
    exit;
  end;

  // now we know the file exists - try get settings from it
  Settings.ReadFromFile(lsName);

end;

procedure TfrmMain.actHelpContentsExecute(Sender: TObject);
begin
  Application.HelpContext(HELP_MAIN);
end;

end.
