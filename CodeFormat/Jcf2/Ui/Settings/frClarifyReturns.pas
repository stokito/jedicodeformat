{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is frClarify.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 1999-2008 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele.

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations
under the License.

Alternatively, the contents of this file may be used under the terms of
the GNU General Public License Version 2 or later (the "GPL") 
See http://www.gnu.org/licenses/gpl.html
------------------------------------------------------------------------------*)
{*)}

unit frClarifyReturns;

{$I JcfGlobal.inc}

interface

uses
  { delphi }
  Classes, Controls, Forms,
  StdCtrls, ExtCtrls,
  { local}
  JvEdit, frmBaseSettingsFrame, JvExStdCtrls, JvValidateEdit;

type
  TfClarifyReturns = class(TfrSettingsFrame)
    rgReturnChars: TRadioGroup;
    gbRemoveReturns: TGroupBox;
    cbRemoveProcDefReturns: TCheckBox;
    cbRemoveVarReturns: TCheckBox;
    cbRemoveExprReturns: TCheckBox;
    cbRemovePropertyReturns: TCheckBox;
    cbRemoveReturns: TCheckBox;
    gbInsert: TGroupBox;
    cbUsesClauseOnePerLine: TCheckBox;
    cbInsertReturns: TCheckBox;
    cbBreakAfterUses: TCheckBox;
  private

  public
    constructor Create(AOwner: TComponent); override;

    procedure Read; override;
    procedure Write; override;

  end;

implementation

{$ifdef FPC}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}

uses
  SettingsTypes, JcfSettings, SetReturns, JcfHelp;


constructor TfClarifyReturns.Create(AOwner: TComponent);
begin
  inherited;
  fiHelpContext := HELP_CLARIFY_RETURNS;
end;

{-------------------------------------------------------------------------------
  worker procs }

procedure TfClarifyReturns.Read;
begin
  with JcfFormatSettings.Returns do
  begin
    cbRemoveReturns.Checked     := RemoveBadReturns;
    cbRemovePropertyReturns.Checked := RemovePropertyReturns;
    cbRemoveProcDefReturns.Checked := RemoveProcedureDefReturns;
    cbRemoveVarReturns.Checked  := RemoveVarReturns;
    cbRemoveExprReturns.Checked := RemoveExpressionReturns;

    cbInsertReturns.Checked := AddGoodReturns;
    cbUsesClauseOnePerLine.Checked := UsesClauseOnePerLine;
    cbBreakAfterUses.Checked := BreakAfterUses;

    rgReturnChars.ItemIndex := Ord(ReturnChars);
  end;
end;

procedure TfClarifyReturns.Write;
begin
  with JcfFormatSettings.Returns do
  begin
    RemoveBadReturns      := cbRemoveReturns.Checked;
    RemovePropertyReturns := cbRemovePropertyReturns.Checked;
    RemoveProcedureDefReturns := cbRemoveProcDefReturns.Checked;
    RemoveVarReturns      := cbRemoveVarReturns.Checked;
    RemoveExpressionReturns := cbRemoveExprReturns.Checked;

    AddGoodReturns := cbInsertReturns.Checked;
    UsesClauseOnePerLine := cbUsesClauseOnePerLine.Checked;
    BreakAfterUses := cbBreakAfterUses.Checked;

    ReturnChars := TReturnChars(rgReturnChars.ItemIndex);
  end;
end;

end.
