unit JcfIdeRegister;

{ AFS 7 Jan 2K
  Jedi Code Format IDE plugin registration }

interface

uses
  { delphi } Windows, Messages, SysUtils, Classes, ToolsAPI;


procedure Register;

implementation

uses
  { delphi } Menus, Dialogs, ExtCtrls,
  { local } JcfIdeMain, Delay;

const
  MENU_TOOLS = '&Tools';
  FORMAT_MENU_NAME = 'Jedi Code &Format';
  FORMAT_CURRENT_NAME = '&Current source file';
  FORMAT_PROJECT_NAME = '&All files in project';
  FORMAT_OPEN_NAME = 'All &open files';
  FORMAT_SETTINGS_MENU_NAME = '&Settings';

{ find the TMenuItem for the IDE main menu tools }
function GetToolsMenu: TMenuItem;
var
  hRes: HResult;
  lciMenuServices: INTAServices40;
  lcMainMenu: TMenu;
begin
  Result := nil;

  { get the menu services }
  hRes := BorlandIDEServices.QueryInterface(INTAServices40, lciMenuServices);
  if hRes <> S_OK then
    exit;
  if lciMenuServices = nil then
    exit;

  { get the main menu }
  lcMainMenu := lciMenuServices.MainMenu;

  { get the tools menu }
  Result := lcMainMenu.Items.Find(MENU_TOOLS);
end;

{ the object that does all the work
  - created the first time that a JCF menu item is selected }
var
  lcJCFIDE: TJcfIdeMain;
  { object to delay registration }
  lcDelayedRegister: TDelay;


procedure AddMenuItems;
var
  fcMainMenu: TMenuItem;

  procedure AddMenuItem(const psName: string; const pcHandler: TNotifyEvent);
  var
    lcItem: TMenuItem;
  begin
    Assert(psName <> '');
    Assert(Assigned(pcHandler));

    lcItem := TMenuItem.Create(fcMainMenu);
    Assert(lcItem <> nil);

    lcItem.Caption := psName;
    lcItem.OnClick := pcHandler;

    Assert(fcMainMenu <> nil);
    fcMainMenu.Add(lcItem);
  end;

var
  fcToolsMenu: TMenuItem;
begin
  { this doesn't work during program startup?!? }
  fcToolsMenu := GetToolsMenu;
  if fcToolsMenu = nil then
    exit;

  { I make these in the Register proc, &
    I'll free them in finalization }
  fcMainMenu := TMenuItem.Create(fcToolsMenu);
  fcMainMenu.Caption := FORMAT_MENU_NAME;
  fcToolsMenu.Insert(fcToolsMenu.Count, fcMainMenu);

  //liShortcut := Shortcut(ord('K'), [ssCtrl]);
  AddMenuItem(FORMAT_CURRENT_NAME, lcJCFIDE.DoFormatCurrentIDEWindow);
  AddMenuItem(FORMAT_PROJECT_NAME, lcJCFIDE.DoFormatProject);
  AddMenuItem(FORMAT_OPEN_NAME, lcJCFIDE.DoFormatOpen);
  AddMenuItem(FORMAT_SETTINGS_MENU_NAME, lcJCFIDE.DoFormatSettings);
end;

{ called from Finalization }
procedure RemoveMenuItems;
var
  fcMainMenu: TMenuItem;

  procedure RemoveMenuItem(const psName: string);
  var
    lcItem: TMenuItem;
  begin
    Assert(psName <> '');
    Assert(fcMainMenu <> nil);

    lcItem := fcMainMenu.Find(psName);
    if lcItem <> nil then
      fcMainMenu.Remove(lcItem);
  end;

var
  fcToolsMenu: TMenuItem;
begin
  { remove any existant menu items -
    this causes crashes of not done right }
  fcToolsMenu := GetToolsMenu;
  if fcToolsMenu = nil then
    exit;

  fcMainMenu := fcToolsMenu.Find(FORMAT_MENU_NAME);

  if fcMainMenu <> nil then
  begin
    RemoveMenuItem(FORMAT_CURRENT_NAME);
    RemoveMenuItem(FORMAT_PROJECT_NAME);
    RemoveMenuItem(FORMAT_OPEN_NAME);
    RemoveMenuItem(FORMAT_SETTINGS_MENU_NAME);

    fcToolsMenu.Remove(fcMainMenu);
  end;

  FreeAndNil(fcMainMenu);
end;

procedure Register;
begin
  { delayed reg. technique from sample code by Mike Remec
  http://www.miharemec.com/doc/ota-nmi.html }
  Assert(lcDelayedRegister <> nil);
  lcDelayedRegister.Proc := AddMenuItems;
  lcDelayedRegister.DoItSoon;
end;


initialization
  lcJCFIDE := TJcfIdeMain.Create;
  lcDelayedRegister := TDelay.Create;

finalization
  FreeAndNil(lcDelayedRegister);

  RemoveMenuItems;
  FreeAndNil(lcJCFIDE);
end.
