unit TestWarnings;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TestWarnings, released May 2003.
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
  TestFrameWork, BaseTestProcess;

type
  TTestWarnings = class(TBaseTestProcess)
  private

  public
    fStoreWarningsOn: Boolean;
    fStoreWarnUnusedParamsOn: Boolean;


    procedure Setup; override;
    procedure TearDown; override;
  published
    // no warnings in basic units
    procedure TestNoWarningsBasic;

    // warnings on empty stuff
    procedure TestEmptyProcedure;
    procedure TestEmptyProcedureOff;

    procedure TestEmptyBlock;
    procedure TestEmptyTryExcept;
    procedure TestEmptyTryFinally;

    // assign to fn name
    procedure TestAssignToFunctionName;

    // real and real84 types
    procedure TestRealType1;
    procedure TestRealType2;
    procedure TestRealType3;
    procedure TestRealType4;

    // calls to destroy
    procedure TestDestroy;
    procedure TestDestroy2;

    // case without else block
    procedure TestCaseNoElse1;
    procedure TestCaseNoElse2;

    procedure TestWarnUnusedParam1;
    procedure TestWarnUnusedParam2;
    procedure TestWarnUnusedParam3;
    procedure TestWarnUnusedParam4;
    procedure TestWarnUnusedParam5;
    procedure TestWarnUnusedParam6;
    procedure TestWarnUnusedParamClass;
    procedure TestWarnUnusedParamConstructor;
    procedure TestWarnUnusedParamClassFn;
    procedure TestWarnUnusedParamOpOverload;
    procedure TestUnusedParamClassConstructor;
    procedure TestUnusedInnerClass;

    procedure TestWarnUnusedParamOff;
  end;


implementation

uses
  // jcf
  JclStrings,
  // local
  JcfSettings;

const
  EMPTY_BEGIN_END = 'Empty begin..end block';
  EMPTY_TRY      = 'Empty try block';
  EMPTY_EXCEPT_END = 'Empty except..end';
  EMPTY_FINALLY_END = 'Empty finally..end';
  REAL_TYPE_USED = 'Real type used';
  REAL48_TYPE_USED = 'Real48 type used';


procedure TTestWarnings.Setup;
begin
  inherited;

  fStoreWarningsOn := FormatSettings.Clarify.Warnings;
  fStoreWarnUnusedParamsOn := FormatSettings.Clarify.WarnUnusedParams;

  FormatSettings.Clarify.Warnings := True;
  FormatSettings.Clarify.WarnUnusedParams := True;
end;

procedure TTestWarnings.TearDown;
begin
  FormatSettings.Clarify.Warnings := fStoreWarningsOn;
  FormatSettings.Clarify.WarnUnusedParams := fStoreWarnUnusedParamsOn;

  inherited;

end;

procedure TTestWarnings.TestNoWarningsBasic;
const
  UNIT_TEXT = UNIT_HEADER + UNIT_FOOTER;
begin
  TestNoWarnings(UNIT_TEXT);
end;


procedure TTestWarnings.TestEmptyProcedure;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, EMPTY_BEGIN_END);
end;

// no warning if the setting is turned off
procedure TTestWarnings.TestEmptyProcedureOff;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin end; ' + UNIT_FOOTER;
begin
  FormatSettings.Clarify.Warnings := False;
  TestNoWarnings(UNIT_TEXT);
end;


procedure TTestWarnings.TestEmptyBlock;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin begin end; end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, EMPTY_BEGIN_END);
end;

procedure TTestWarnings.TestEmptyTryExcept;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin try except end; end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, [EMPTY_TRY, EMPTY_EXCEPT_END]);
end;

procedure TTestWarnings.TestEmptyTryFinally;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin try finally end; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, [EMPTY_TRY, EMPTY_FINALLY_END]);
end;

procedure TTestWarnings.TestAssignToFunctionName;
const
  UNIT_TEXT = UNIT_HEADER + ' function fred: integer; begin fred := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'Assignment to the function name');
end;


procedure TTestWarnings.TestRealType1;
const
  UNIT_TEXT = UNIT_HEADER + ' var foo: real; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, REAL_TYPE_USED);
end;

procedure TTestWarnings.TestRealType2;
const
  UNIT_TEXT = UNIT_HEADER + ' const foo: Real48 = 4.5; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, REAL48_TYPE_USED);
end;

procedure TTestWarnings.TestRealType3;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; var foo: Real48; begin end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, [EMPTY_BEGIN_END, REAL48_TYPE_USED]);
end;

procedure TTestWarnings.TestRealType4;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; var foo: Real48; bar: real; begin end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, [EMPTY_BEGIN_END, REAL_TYPE_USED, REAL48_TYPE_USED]);
end;

procedure TTestWarnings.TestDestroy;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure fred; begin Destroy; end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'Destroy should not normally be called');
end;

procedure TTestWarnings.TestDestroy2;
const
  UNIT_TEXT = UNIT_HEADER + ' procedure TFoo.fred; begin Destroy; end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'TFoo.fred');
end;

procedure TTestWarnings.TestCaseNoElse1;
const
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred; var li: integer; begin case li of 1: end; end; ' + UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'Case statement has no else case');
end;

procedure TTestWarnings.TestCaseNoElse2;
const
  // this one has an else, should have no warning
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred; var li: integer; begin case li of 1: ; else; end; end; ' +
    UNIT_FOOTER;
begin
  TestNoWarnings(UNIT_TEXT);
end;



procedure TTestWarnings.TestWarnUnusedParam1;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred(foo: integer); var li: integer; begin li := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;

procedure TTestWarnings.TestWarnUnusedParam2;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred(const foo: integer); var li: integer; begin li := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;

procedure TTestWarnings.TestWarnUnusedParam3;
const
  // this one should have 2 param warning
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred(var foo, bar: integer); var li: integer; begin li := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, ['is not used', 'is not used']);
end;

procedure TTestWarnings.TestWarnUnusedParam4;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    'function fred(const foo: integer): integer; begin Result := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;


procedure TTestWarnings.TestWarnUnusedParam5;
const
  // this one should have 2 param warnings out of 4 params
  UNIT_TEXT = UNIT_HEADER +
    'function fred(var foo1, foo2, foo3, foo4: integer): integer; begin foo3 := foo1; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, ['foo2', 'foo4']);
end;


procedure TTestWarnings.TestWarnUnusedParam6;
const
  // this one should have only paramC unused
  UNIT_TEXT = UNIT_HEADER +
    ' function fred(var paramA, paramB, paramC: integer): integer; ' +  AnsiLineBreak +
    ' begin if b > 10 then Result := foo(paramA, paramB, paramB - 1) else Result := paramA + paramB; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'paramC');
end;


procedure TTestWarnings.TestWarnUnusedParamClass;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TMyClass = class ' + AnsiLineBreak +
    ' public  function fred(const foo: integer): integer; end; ' + AnsiLineBreak +
    ' function TMyClass.fred(const foo: integer): integer; begin Result := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;


procedure TTestWarnings.TestWarnUnusedParamConstructor;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TMyClass = class ' + AnsiLineBreak +
    ' public constructor Create(const foo: integer); end; ' + AnsiLineBreak +
    'constructor TMyClass.Create(const foo: integer); begin  inherited; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;

procedure TTestWarnings.TestWarnUnusedParamClassFn;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TMyClass = class ' + AnsiLineBreak +
    ' public class function fred(const foo: integer): integer; end; ' + AnsiLineBreak +
    'class function TMyClass.fred(const foo: integer): integer; ' + AnsiLineBreak +
    'begin Result := 3; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'is not used');
end;

procedure TTestWarnings.TestWarnUnusedParamOpOverload;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TMyClass = class ' + AnsiLineBreak +
    ' class operator Add(A,B: TMyClass): TMyClass; end; ' + AnsiLineBreak +
    ' class operator TMyClass.Add(paramA, paramB: TMyClass): TMyClass; ' +  AnsiLineBreak +
    ' begin Result := paramA; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'paramB');
end;

procedure TTestWarnings.TestUnusedParamClassConstructor;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TMyClass = class ' + AnsiLineBreak +
    ' class constructor Create(const ParamA: integer); end; ' + AnsiLineBreak +
    ' class constructor TMyClass.Create(const ParamA: integer); ' + AnsiLineBreak +
    ' begin inherited Create(); end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'paramA');
end;

procedure TTestWarnings.TestUnusedInnerClass;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    ' type TOuterClass = class ' + AnsiLineBreak +
    ' type TInnerClass = class  ' + AnsiLineBreak +
    ' procedure innerProc(const paramA, paramB: integer); '  + AnsiLineBreak +
    ' end; end; ' +  AnsiLineBreak +
    ' procedure TOuterClass.TInnerClass.innerProc(var paramA, paramB: integer); ' + AnsiLineBreak +
    ' begin paramB := paramB; end; ' +
    UNIT_FOOTER;
begin
  TestWarnings(UNIT_TEXT, 'paramA');
end;



// test the switch to turn it off
procedure TTestWarnings.TestWarnUnusedParamOff;
const
  // this one should have 1 param warning
  UNIT_TEXT = UNIT_HEADER +
    'procedure fred(foo: integer); var li: integer; begin li := 3; end; ' +
    UNIT_FOOTER;
begin
  FormatSettings.Clarify.WarnUnusedParams := False;

  TestNoWarnings(UNIT_TEXT);
end;

initialization
  TestFramework.RegisterTest('Processes', TTestWarnings.Suite);
end.
