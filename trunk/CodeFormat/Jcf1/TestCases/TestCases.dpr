program TestCases;

{ AFS 20 October
  This is not a program worth running
  A way to verify that the test cases are compilable, nothing more

  If you have opened JediCodeFormat.bpg, use View|Project Manager
  Close this project and open JediCodeFormat.dpr }

uses
  Forms,
  TestWarnings in 'TestWarnings.pas',
  TestASM in 'TestASM.pas',
  TestBogusDirectives in 'TestBogusDirectives.pas',
  TestBogusTypes in 'TestBogusTypes.pas',
  TestCast in 'TestCast.pas',
  TestClassLines in 'TestClassLines.pas',
  TestConstRecords in 'TestConstRecords.pas',
  TestDeclarations in 'TestDeclarations.pas',
  TestDeclarations2 in 'TestDeclarations2.pas',
  TestDefaultParams in 'TestDefaultParams.pas',
  TestEmptyClass in 'TestEmptyClass.pas',
  TestEsotericKeywords in 'TestEsotericKeywords.pas',
  TestExclusion in 'TestExclusion.pas',
  TestForward in 'TestForward.pas',
  TestGoto in 'TestGoto.pas',
  TestInitFinal in 'TestInitFinal.pas',
  TestInterfaces in 'TestInterfaces.pas',
  TestLayout in 'TestLayout.pas',
  TestLayoutBare in 'TestLayoutBare.pas',
  TestLayoutBare2 in 'TestLayoutBare2.pas',
  TestLocalTypes in 'TestLocalTypes.pas',
  TestLongStrings in 'TestLongStrings.pas',
  TestMarcoV in 'TestMarcoV.pas',
  TestMixedModeCaps in 'TestMixedModeCaps.pas',
  TestNested in 'TestNested.pas',
  TestOperators in 'TestOperators.pas',
  TestParamSpaces in 'TestParamSpaces.pas',
  TestPointers in 'TestPointers.pas',
  TestProperties in 'TestProperties.pas',
  TestRecords in 'TestRecords.pas',
  TestReg in 'testReg.pas',
  TestReint in 'TestReint.pas',
  TestReturns in 'TestReturns.pas',
  TestRunOnConst in 'TestRunOnConst.pas',
  TestRunOnDef in 'TestRunOnDef.pas',
  TestTry in 'TestTry.pas',
  TestTypeDefs in 'TestTypeDefs.pas',
  TestUses in 'TestUses.pas',
  TestAbsolute in 'TestAbsolute.pas',
  TestTPObjects in 'TestTPObjects.pas',
  TestCaseBlock in 'TestCaseBlock.pas',
  TestPropertyLines in 'TestPropertyLines.pas',
  TestCommentIndent in 'TestCommentIndent.pas',
  TestInterfaceImplements in 'TestInterfaceImplements.pas',
  TestNestedRecords in 'TestNestedRecords.pas',
  TestLineBreaking in 'TestLineBreaking.pas',
  fFormTest in 'fFormTest.pas' {FormTest},
  TestReturnRemoval in 'TestReturnRemoval.pas',
  TestExclusionFlags in 'TestExclusionFlags.pas',
  TestBlankLineRemoval in 'TestBlankLineRemoval.pas',
  TestD6 in 'TestD6.pas',
  TestAlign in 'TestAlign.pas',
  Testgg in 'TestGG.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormTest, FormTest);
  Application.Run;
end.
