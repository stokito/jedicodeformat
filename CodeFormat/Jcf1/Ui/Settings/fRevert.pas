unit fRevert;

interface

uses
  { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  { local } JCFSettings;

type
  TFormRevert = class(TForm)
    mInfo: TMemo;
    bbOk: TBitBtn;
    bbCancel: TBitBtn;
    cbAlign: TCheckBox;
    cbCaps: TCheckBox;
    cbClarify: TCheckBox;
    cbFile: TCheckBox;
    cbIndent: TCheckBox;
    cbLog: TCheckBox;
    cbObfuscate: TCheckBox;
    cbReplace: TCheckBox;
    cbSpaces: TCheckBox;
    cbReturns: TCheckBox;
    cbSpecificWordCaps: TCheckBox;
    cbUses: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    fSettings: TSettings;

    procedure RegRemove;
  public
    procedure Execute;

    property Settings: TSettings read fSettings write fSettings;
  end;


implementation

uses
  { jcl } JCLStrings;

{$R *.DFM}

procedure TFormRevert.Execute;
begin
  Assert(fSettings <> nil);
  ModalResult := mrNone;
  ShowModal;

  if ModalResult = mrOk then
    RegRemove;
end;

procedure TFormRevert.RegRemove;
begin
  { removing sections will repopulate them with default values,
    just like the first time }

  if cbAlign.Checked then
    Settings.Align.Revert;

  if cbCaps.Checked then
    Settings.Caps.Revert;

  if cbClarify.Checked then
    Settings.Clarify.Revert;

  if cbFile.Checked then
    Settings.FileSettings.Revert;

  if cbIndent.Checked then
    Settings.Indent.Revert;

  if cbLog.Checked then
    Settings.Log.Revert;

  if cbObfuscate.Checked then
    Settings.Obfuscate.Revert;

  if cbReplace.Checked then
    Settings.Replace.Revert;

  if cbSpaces.Checked then
    Settings.Spaces.Revert;

  if cbReturns.Checked then
    Settings.Returns.Revert;

  if cbSpecificWordCaps.Checked then
    Settings.SpecificWordCaps.Revert;

  if cbUses.Checked then
    Settings.UsesClause.Revert;
end;

procedure TFormRevert.FormCreate(Sender: TObject);
var
  lsInfo: string;
begin
  lsInfo := mInfo.Text;
  StrReplace(lsInfo, '%ROOTKEY%', ROOT_KEY);
  mInfo.Text := lsInfo;
end;

end.
