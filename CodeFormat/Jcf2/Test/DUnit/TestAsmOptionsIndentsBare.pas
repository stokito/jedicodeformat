unit TestAsmOptionsIndentsBare;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is TestAsmOptionsIndentsBare, released October 2007.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 2007 Anthony Steele.
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

{ test asm options for indents
  "Bare" in the sense that the asm block is not inside a proc,
   it is the top-level block of the proc
  This is JCF's prefered style
}

uses
  TestFrameWork,
  BaseTestProcess, SettingsTypes, SetTransform, IntList;

type

  TTestAsmOptionsIndentsBare = class(TBaseTestProcess)
  private
    feCapitalisation: TCapitalisationType;

    fbBreaksAfterLabelEnabled: boolean;
    fiBreaksAfterLabel: integer;

    fbStatementIndentEnabled: boolean;
    fiStatementIndent: integer;
    fbParamsIndentEnabled: boolean;
    fiParamsIndent: integer;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  public

  published
    procedure TestParamsIndentOn;
    procedure TestStatementIndentOn;
    procedure TestStatementIndentOff;
  end;

implementation

uses
  SysUtils,
  JclStrings,
  JCFSettings, SetAsm;

const
  UNIT_HEADER = 'unit CaseTest;' + AnsiLineBreak + AnsiLineBreak +
    'interface' + AnsiLineBreak + AnsiLineBreak +
    'implementation' + AnsiLineBreak + AnsiLineBreak +
    'uses Dialogs;' + AnsiLineBreak + AnsiLineBreak +
    'procedure foo(i: integer);' + AnsiLineBreak;

  UNIT_FOOTER = AnsiLineBreak + AnsiLineBreak +
    'end.';

  ASM_STATEMENTS_NOT_INDENTED =
    UNIT_HEADER +
    'asm' + AnsiLineBreak +
    '  MOV ECX, [EDX]' + AnsiLineBreak +
    '  XCHG ECX, [EAX]' + AnsiLineBreak +
    '  CALL PROCASM2' + AnsiLineBreak +
    'end;' + AnsiLineBreak +
    UNIT_FOOTER;

    ASM_STATEMENTS_INDENTED =
    UNIT_HEADER +
    'asm' + AnsiLineBreak +
    '         MOV ECX, [EDX]' + AnsiLineBreak +
    '         XCHG ECX, [EAX]' + AnsiLineBreak +
    '         CALL PROCASM2' + AnsiLineBreak +
    'end;' + AnsiLineBreak +
    UNIT_FOOTER;

    ASM_STATEMENTS_PARAMS_INDENTED =
    UNIT_HEADER +
    'asm' + AnsiLineBreak +
    '         MOV     ECX, [EDX]' + AnsiLineBreak +
    '         XCHG    ECX, [EAX]' + AnsiLineBreak +
    '         CALL    PROCASM2' + AnsiLineBreak +
    'end;' + AnsiLineBreak +
    UNIT_FOOTER;


procedure TTestAsmOptionsIndentsBare.SetUp;
begin
  inherited;

  // store old settings
  with FormatSettings do
  begin
    feCapitalisation := SetAsm.Capitalisation;

    fbBreaksAfterLabelEnabled := SetAsm.BreaksAfterLabelEnabled;
    fiBreaksAfterLabel := SetAsm.BreaksAfterLabel;

    fbStatementIndentEnabled := SetAsm.StatementIndentEnabled;
    fiStatementIndent := SetAsm.StatementIndent;

    fbParamsIndentEnabled := SetAsm.ParamsIndentEnabled;
    fiParamsIndent := SetAsm.ParamsIndent;
  end;
end;

procedure TTestAsmOptionsIndentsBare.TearDown;
begin
  inherited;

  with FormatSettings do
  begin
    SetAsm.Capitalisation := feCapitalisation;

    SetAsm.BreaksAfterLabelEnabled := fbBreaksAfterLabelEnabled;
    SetAsm.BreaksAfterLabel := fiBreaksAfterLabel;

    SetAsm.StatementIndentEnabled := fbStatementIndentEnabled;
    SetAsm.StatementIndent := fiStatementIndent;

    SetAsm.ParamsIndentEnabled := fbParamsIndentEnabled;
    SetAsm.ParamsIndent := fiParamsIndent;
  end;

end;

procedure TTestAsmOptionsIndentsBare.TestStatementIndentOn;
begin
  FormatSettings.SetAsm.StatementIndentEnabled := True;
  FormatSettings.SetAsm.ParamsIndentEnabled := False;
  TestFormatResult(ASM_STATEMENTS_NOT_INDENTED, ASM_STATEMENTS_INDENTED);
end;


procedure TTestAsmOptionsIndentsBare.TestParamsIndentOn;
begin
  FormatSettings.SetAsm.StatementIndentEnabled := True;
  FormatSettings.SetAsm.ParamsIndentEnabled := True;
  TestFormatResult(ASM_STATEMENTS_NOT_INDENTED, ASM_STATEMENTS_PARAMS_INDENTED);
end;

procedure TTestAsmOptionsIndentsBare.TestStatementIndentOff;
begin
  FormatSettings.SetAsm.StatementIndentEnabled := False;
  FormatSettings.SetAsm.ParamsIndentEnabled := False;
  FormatSettings.SetAsm.StatementIndent := 7;
  TestFormatResult(ASM_STATEMENTS_NOT_INDENTED, ASM_STATEMENTS_NOT_INDENTED);
end;


initialization
  TestFramework.RegisterTest('Processes', TTestAsmOptionsIndentsBare.Suite);

end.