unit frDrop;

{ AFS 16 May - code After DropForm.pas code sample from www.undu.com Oct 98
  Original code by Thorsten Engler - Thorsten.Engler@gmx.net

  This frame will accept shell drag/drops as normal delphi drag/drops
  ie DragOver and DragDrop events

  This frame is suitable as a base class as nothing is allocated until
  the client or child turns on the IsDropActive property
}

interface

uses
  { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, ComObj, ShellAPI,
  { Drop } JCFDropTarget;

type
  TFrameDrop = class(TFrame)
  private
    fcDropInterface: TTeDropInterface;
    fbIsDropActive: boolean;

    procedure ProcessFileMedium(const lrMedium: TStgMedium);
    procedure ProcessTextMedium(const lrMedium: TStgMedium);
  protected

    // override this to recieve the  dropped item text/file name
    procedure DragItemDropped(const piFormat: integer; const psItem: string); virtual;

    // call this when the item is dropped
    procedure HandleShellDragDrop(const pcSource: TObject); overload;
    procedure HandleShellDragDrop(const pcData: TTeComDragObject); overload;
    procedure HandleShellDragDrop(const pciData: IDataObject); overload;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateWnd; override;
    procedure DestroyWnd; override;

    property IsDropActive: boolean read fbIsDropActive write fbIsDropActive;
  end;

  { helper fns }
function GetFileFormat(const pciData: IDataObject; var prFormatEtc: TFormatEtc): boolean;
function GetTextFormat(const pciData: IDataObject; var prFormatEtc: TFormatEtc): boolean;

implementation

{$R *.DFM}

{ find a formatEtc in the IDataObject with the specified type }
function GetFormat(const pciData: IDataObject; const piFormatId: integer;
  var prFormatEtc: TFormatEtc): boolean;
var
  hRes:       integer;
  lciEnum:    IEnumFormatEtc;
  lrFormatEtc: TFormatEtc;
  liReturned: integer;
begin
  Assert(pciData <> nil);
  Result := False;

  hRes := pciData.EnumFormatEtc(DATADIR_GET, lciEnum);
  OleCheck(hRes);
  Assert(lciEnum <> nil);

  lciEnum.Reset;
  { loop through all the records }
  while True do
  begin
    { EOF? }
    if lciEnum.Next(1, lrFormatEtc, @liReturned) <> S_OK then
      break;

    { use this one? }
    if lrFormatEtc.cfFormat = piFormatId then
    begin
      prFormatEtc := lrFormatEtc;
      Result      := True;
      break;
    end;
  end;
end;

function GetFileFormat(const pciData: IDataObject; var prFormatEtc: TFormatEtc): boolean;
begin
  Result := GetFormat(pciData, CF_HDROP, prFormatEtc);
end;

function GetTextFormat(const pciData: IDataObject; var prFormatEtc: TFormatEtc): boolean;
begin
  Result := GetFormat(pciData, CF_TEXT, prFormatEtc);
end;

{-------------------------------------------------------------------------------
  frame }

constructor TFrameDrop.Create(AOwner: TComponent);
begin
  inherited;
  fcDropInterface := nil; // start off without
  fbIsDropActive  := False;
end;

destructor TFrameDrop.Destroy;
begin
  FreeAndNil(fcDropInterface);
  inherited;
end;

procedure TFrameDrop.CreateWnd;
begin
  inherited;

  if IsDropActive then
  begin
    if fcDropInterface = nil then
      fcDropInterface := TTeDropInterface.Create(Self);
    fcDropInterface.DropTarget_Create;
  end;
end;

procedure TFrameDrop.DestroyWnd;
begin
  if IsDropActive then
  begin
    if fcDropInterface <> nil then
      fcDropInterface.DropTarget_Destroy;
  end;
  inherited;
end;


procedure TFrameDrop.DragItemDropped(const piFormat: integer; const psItem: string);
begin
  // no nothing, here for override
end;

procedure TFrameDrop.HandleShellDragDrop(const pcSource: TObject);
begin
  if pcSource is TTeComDragObject then
    HandleShellDragDrop(pcSource as TTeComDragObject);
end;

procedure TFrameDrop.HandleShellDragDrop(const pcData: TTeComDragObject);
begin
  if pcData = nil then
    exit;
  if pcData.DataObject = nil then
    exit;

  { get the interface }
  HandleShellDragDrop(pcData.DataObject);
end;


procedure TFrameDrop.HandleShellDragDrop(const pciData: IDataObject);
var
  lrFormatEtc: TFormatEtc;
  lrMedium:    TStgMedium;
begin
  Assert(pciData <> nil);

  { OK, if you want to understand this, pay attention

    Windows gives you an interface (IDataObject)
    from which you can get an interface (IEnumFormatEtc)
    which can give you the format records (TFormatEtc)
    one of which will may be the file format
    and one of which may be a text format

    For files:
      pass the format to IDataObject.GetData
      to get a structure (TStgMedium)
      which contains a global handle that you can pass
      to a function (DragQueryFile) to find out how many and what file names you got
    For text:
      pass the format to IDataObject.GetData
      to get the text

    Windows API...making it easy
  }

  if GetFileFormat(pciData, lrFormatEtc) then
  begin
    if Succeeded(pciData.GetData(lrFormatEtc, lrMedium)) then
      ProcessFileMedium(lrMedium);
  end
  else if GetTextFormat(pciData, lrFormatEtc) then
  begin
    if Succeeded(pciData.GetData(lrFormatEtc, lrMedium)) then
      ProcessTextMedium(lrMedium);
  end;
  // else there is no format dropped that we can use
end;

procedure TFrameDrop.ProcessFileMedium(const lrMedium: TStgMedium);
const
  cnMaxFileNameLen = 255;
  cnMINUSONE       = $FFFFFFFF;
var
  lgHandle:   THandle;
  nCount, i:  integer;
  acFileName: array [0..cnMaxFileNameLen] of char;
begin
  lgHandle := lrMedium.hGlobal;

  if lgHandle = 0 then
    exit;

  GlobalLock(lgHandle);
  try
    nCount := DragQueryFile(lgHandle, cnMINUSONE, acFileName, cnMaxFileNameLen);

    // query Windows one at a time for the file name
    for i := 0 to nCount - 1 do
    begin
      DragQueryFile(lgHandle, i, acFileName, cnMaxFileNameLen);

      // call the virtual fn now that we have the file name
      DragItemDropped(CF_HDROP, acFileName);
    end;

    // let Windows know that you're done
    DragFinish(lgHandle);
  finally
    GlobalUnLock(lgHandle);
  end;
end;

procedure TFrameDrop.ProcessTextMedium(const lrMedium: TStgMedium);
const
  cnMaxFileNameLen = 255;
  cnMINUSONE       = $FFFFFFFF;
var
  lgHandle: THandle;
  lpChar:   PChar;
  ls:       string;
begin
  lgHandle := lrMedium.hGlobal;

  if lgHandle = 0 then
    exit;

  lpChar := GlobalLock(lgHandle);
  try
    ls := lpChar;
  finally
    GlobalUnLock(lgHandle);
  end;

  // call the virtual fn now that we have the text
  DragItemDropped(CF_TEXT, ls);
end;

end.
