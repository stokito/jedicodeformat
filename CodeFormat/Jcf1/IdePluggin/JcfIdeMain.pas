unit JcfIdeMain;

{ AFS 7 Jan 2K
  Jedi Code Format IDE plugin main class

  global object that implements the callbacks from the menu items }


interface

uses
  { delphi } Windows, Messages, SysUtils, Classes,
  { delphi design time } ToolsAPI,
  { local} JCFSettings, EditorConverter, FileCOnverter;

type
  TJcfIdeMain = class(TObject)
  private
    fcSettings: TSettings;
    fcEditorConverter: TEditorConverter;
    fcFileConverter: TFileConverter;

    function GetSettings: TSettings;
    procedure MakeEditorConverter;

    procedure LogIDEMessage(const ps: string); overload;
    procedure FormatFile(const psFileName: string);

    procedure ClearToolMessages;

  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure ShortcutKeyCallback(const Context: IOTAKeyContext;
      KeyCode: TShortcut; var BindingResult: TKeyBindingResult);

    procedure DoFormatCurrentIDEWindow(Sender: TObject);
    procedure DoFormatProject(Sender: TObject);
    procedure DoFormatOpen(Sender: TObject);
    procedure DoFormatSettings(Sender: TObject);
  end;


implementation

uses
  { delphi } Menus, Dialogs, Controls,
  { jcl } JclStrings,
  { local } fAllSettings, EditorReader, EditorWriter;


function FileIsAllowedType(const psFileName: string): boolean;
const
  ALLOWED_FILE_TYPES: array[1..3] of string = ('.pas', '.dpr', '.dpk');
begin
  Result := StrIsOneOf(StrRight(psFileName, 4), ALLOWED_FILE_TYPES);
end;


{ the function GetCurrentProject is from Erik's OpenTools API FAQ and Resources
  http://www.gexperts.org/opentools/
}
// Modified from code posted by Ray Lischner (www.tempest-sw.com)
function GetCurrentProject: IOTAProject;
var
  Services: IOTAModuleServices;
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  MultipleProjects: boolean;
  I: integer;
begin
  Result   := nil;
  MultipleProjects := False;
  Services := BorlandIDEServices as IOTAModuleServices;
  for I := 0 to Services.ModuleCount - 1 do
  begin
    Module := Services.Modules[I];
    if Module.QueryInterface(IOTAProjectGroup, ProjectGroup) = S_OK then
    begin
      Result := ProjectGroup.ActiveProject;
      Exit;
    end
    else if Module.QueryInterface(IOTAProject, Project) = S_OK then
    begin
      if Result = nil then
        // Found the first project, so save it
        Result := Project
      else
        MultipleProjects := True;
      // It doesn't look good, but keep searching for a project group
    end;
  end;
  if MultipleProjects then
    Result := nil;
end;


constructor TJcfIdeMain.Create;
begin
  inherited;
  { both of these are created on demand }
  fcSettings      := nil;
  fcEditorConverter := nil;
  fcFileConverter := nil;
end;

destructor TJcfIdeMain.Destroy;
begin
  FreeAndNil(fcEditorConverter);
  FreeAndNil(fcFileConverter);
  FreeAndNil(fcSettings);
  inherited;
end;

procedure TJcfIdeMain.DoFormatCurrentIDEWindow(Sender: TObject);
var
  hRes:      HResult;
  lciEditManager: IOTAEditorServices;
  lciEditor: IOTASourceEditor;
begin
  // get the current editor window
  hRes := BorlandIDEServices.QueryInterface(IOTAEditorServices, lciEditManager);
  if hRes <> S_OK then
    exit;
  if lciEditManager = nil then
    exit;

  lciEditor := lciEditManager.TopBuffer;
  if lciEditor = nil then
    exit;

  MakeEditorConverter;

  ClearToolMessages;
  fcEditorConverter.OnRunStart;
  fcEditorConverter.ConvertUnit(lciEditor);
  fcEditorConverter.AfterConvert;
end;

procedure TJcfIdeMain.DoFormatProject(Sender: TObject);
var
  lciProject: IOTAProject;
  lciModule:  IOTAModuleInfo;
  liLoop:     integer;
  lsMsg:      string;
begin
  lciProject := GetCurrentProject;
  if lciProject = nil then
    exit;

  lsMsg := 'Jedi Code Format of ' + lciProject.FileName + AnsiLineBreak +
    'Are you sure that you want to format all ' + IntToStr(lciProject.GetModuleCount) +
    ' files in the project.';

  if MessageDlg(lsMsg, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    exit;

  ClearToolMessages;
  fcEditorConverter.OnRunStart;

  { loop through all modules in the project }
  for liLoop := 0 to lciProject.GetModuleCount - 1 do
  begin
    lciModule := lciProject.GetModule(liLoop);
    FormatFile(lciModule.FileName);
  end;
  fcEditorConverter.AfterConvert;
end;

procedure TJcfIdeMain.DoFormatOpen(Sender: TObject);
var
  hRes:      HResult;
  lciEditManager: IOTAEditorServices;
  lciIterateBuffers: IOTAEditBufferIterator;
  lciEditor: IOTASourceEditor;
  liLoop:    integer;
begin
  hRes := BorlandIDEServices.QueryInterface(IOTAEditorServices, lciEditManager);
  if hRes <> S_OK then
    exit;
  if lciEditManager = nil then
    exit;

  MakeEditorConverter;

  lciIterateBuffers := nil;
  lciEditManager.GetEditBufferIterator(lciIterateBuffers);
  if lciIterateBuffers = nil then
    exit;

  ClearToolMessages;
  fcEditorConverter.OnRunStart;

  for liLoop := 0 to lciIterateBuffers.Count - 1 do
  begin
    lciEditor := lciIterateBuffers.EditBuffers[liLoop];

    // check that it's a .pas or .dpr
    if not FileIsAllowedType(lciEditor.FileName) then
      exit;

    if lciEditor <> nil then
      fcEditorConverter.ConvertUnit(lciEditor);
  end;

  fcEditorConverter.AfterConvert;
end;


procedure TJcfIdeMain.FormatFile(const psFileName: string);
begin
  if not FileExists(psFileName) then
    exit;

  // check that it's a .pas or .dpr
  if not FileIsAllowedType(psFileName) then
    exit;

  if fcFileConverter = nil then
  begin
    fcFileConverter := TFileConverter.Create;
    fcFileConverter.Settings := GetSettings;
    fcFileConverter.OnStatusMessage := LogIDEMessage;
  end;

  fcFileConverter.ProcessFile(psFileName);
end;

procedure TJcfIdeMain.DoFormatSettings(Sender: TObject);
var
  lfAllSettings: TFormAllSettings;
begin
  lfAllSettings := TFormAllSettings.Create(nil);
  try
    lfAllSettings.Settings := GetSettings;
    lfAllSettings.Execute;
  finally
    lfAllSettings.Release;
  end;
end;

function TJcfIdeMain.GetSettings: TSettings;
begin
  if fcSettings = nil then
    fcSettings := TSettings.Create;

  Result := fcSettings;
end;

procedure TJcfIdeMain.ShortcutKeyCallback(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var
  liShortcut: TShortCut;
begin
  liShortcut := Shortcut(Ord('K'), [ssCtrl]);

  if KeyCode = liShortcut then
    DoFormatCurrentIDEWindow(nil);
end;

procedure TJcfIdeMain.LogIDEMessage(const ps: string);
var
  lciMessages: IOTAMessageServices40;
  hRes: HResult;
begin
  hRes := BorlandIDEServices.QueryInterface(IOTAMessageServices40, lciMessages);
  if hRes <> S_OK then
    exit;
  if lciMessages = nil then
    exit;

  lciMessages.AddTitleMessage('JCF: ' + ps);
end;

procedure TJcfIdeMain.MakeEditorConverter;
begin
  if fcEditorConverter = nil then
  begin
    fcEditorConverter := TEditorConverter.Create;
    fcEditorConverter.Settings := GetSettings;
    fcEditorConverter.OnStatusMessage := LogIDEMessage;
  end;

  Assert(fcEditorConverter <> nil);
end;

procedure TJcfIdeMain.ClearToolMessages;
var
  lciMessages: IOTAMessageServices40;
  hRes: HResult;
begin
  hRes := BorlandIDEServices.QueryInterface(IOTAMessageServices40, lciMessages);
  if hRes <> S_OK then
    exit;
  if lciMessages = nil then
    exit;

  lciMessages.ClearToolMessages;
end;

end.
