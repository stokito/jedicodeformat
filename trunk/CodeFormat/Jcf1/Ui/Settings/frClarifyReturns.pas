{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is frClarify.pas, released April 2000.
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

unit frClarifyReturns;

interface

uses
    { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
    { local}
  SettingsFrame, MemoEx, TypedEdit;

type
  TfClarifyReturns = class(TfrSettingsFrame)
    edtMaxLineLength: TJvIntegerEdit;
    Label3: TLabel;
    cbRebreakLines: TCheckBox;
    cbRemoveReturns: TCheckBox;
    cbRemoveVarBlankLines: TCheckBox;
    cbRemovePropertyReturns: TCheckBox;
    cbRemoveExprReturns: TCheckBox;
    cbInsertReturns: TCheckBox;
    bvRebreak: TBevel;
    cbRemoveProcDefReturns: TCheckBox;
    cbRemoveVarReturns: TCheckBox;
    eNumReturnsAfterFinalEnd: TJvIntegerEdit;
    Label1: TLabel;
    cbRemoveBlankLinesAfterProcHeader: TCheckBox;
    cbRemoveBlockBlankLines: TCheckBox;
    rgReturnChars: TRadioGroup;
    procedure cbRebreakLinesClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private

  public
    constructor Create(AOwner: TComponent); override;

    procedure Read; override;
    procedure Write; override;

  end;

implementation

{$R *.DFM}

uses TokenType, SetReturns, JcfHelp;


constructor TfClarifyReturns.Create(AOwner: TComponent);
begin
  inherited;
  fiHelpContext := HELP_RETURNS;
end;

{-------------------------------------------------------------------------------
  worker procs }

procedure TfClarifyReturns.Read;
begin
  with Settings.Returns do
  begin
    { line breaking }
    cbRebreakLines.Checked := RebreakLines;
    edtMaxLineLength.Value := MaxLineLength;

    { returns }
    eNumReturnsAfterFinalEnd.Value := NumReturnsAfterFinalEnd;

    cbInsertReturns.Checked := AddGoodReturns;
    cbRemoveReturns.Checked := RemoveBadReturns;
    cbRemovePropertyReturns.Checked := RemovePropertyReturns;
    cbRemoveExprReturns.Checked := RemoveExpressionReturns;
    cbRemoveVarReturns.Checked := RemoveVarReturns;
    cbRemoveBlankLinesAfterProcHeader.Checked := RemoveProcHeaderBlankLines;

    cbRemoveProcDefReturns.Checked := RemoveProcedureDefReturns;

    cbRemoveVarBlankLines.Checked := RemoveVarBlankLines;
    cbRemoveBlockBlankLines.Checked := RemoveBlockBlankLines;

    rgReturnChars.ItemIndex := Ord(ReturnChars);
  end;
end;

procedure TfClarifyReturns.Write;
begin
  with Settings.Returns do
  begin
    { line breaking }
    RebreakLines  := cbRebreakLines.Checked;
    MaxLineLength := edtMaxLineLength.Value;

    { returns }
    NumReturnsAfterFinalEnd := eNumReturnsAfterFinalEnd.Value;

    AddGoodReturns := cbInsertReturns.Checked;
    RemoveBadReturns := cbRemoveReturns.Checked;
    RemovePropertyReturns := cbRemovePropertyReturns.Checked;
    RemoveExpressionReturns := cbRemoveExprReturns.Checked;
    RemoveVarReturns := cbRemoveVarReturns.Checked;
    RemoveProcHeaderBlankLines := cbRemoveBlankLinesAfterProcHeader.Checked;

    RemoveProcedureDefReturns := cbRemoveProcDefReturns.Checked;

    RemoveVarBlankLines := cbRemoveVarBlankLines.Checked;
    RemoveBlockBlankLines := cbRemoveBlockBlankLines.Checked;

    ReturnChars := TReturnChars(rgReturnChars.ItemIndex);

  end;
end;

{-------------------------------------------------------------------------------
  event handlers }

procedure TfClarifyReturns.cbRebreakLinesClick(Sender: TObject);
begin
  edtMaxLineLength.Enabled := cbRebreakLines.Checked;
end;

procedure TfClarifyReturns.FrameResize(Sender: TObject);
begin
  inherited;
  bvRebreak.Left := 4;
  bvRebreak.Width := ClientWidth - 8;
end;

end.
