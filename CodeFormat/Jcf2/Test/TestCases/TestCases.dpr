program TestCases;

uses
  Forms,
  EmptyTest1 in 'EmptyTest1.pas',
  fFormTest in 'fFormTest.pas' {FormTest},
  LittleTest1 in 'LittleTest1.pas',
  LittleTest2 in 'LittleTest2.pas',
  LittleTest3 in 'LittleTest3.pas',
  LittleTest4 in 'LittleTest4.pas',
  LittleTest5 in 'LittleTest5.pas',
  TestAbsolute in 'TestAbsolute.pas',
  TestAlign in 'TestAlign.pas',
  TestASM in 'TestAsm.pas',
  TestBlankLineRemoval in 'TestBlankLineRemoval.pas',
  TestBogusDirectives in 'TestBogusDirectives.pas',
  TestBogusTypes in 'TestBogusTypes.pas',
  TestCaseBlock in 'TestCaseBlock.pas',
  TestCast in 'TestCast.pas',
  TestCastSimple in 'TestCastSimple.pas',
  TestCharLiterals in 'TestCharLiterals.pas',
  TestClassLines in 'TestClassLines.pas',
  TestCommentIndent in 'TestCommentIndent.pas',
  TestConstRecords in 'TestConstRecords.pas',
  TestD6 in 'TestD6.pas',
  TestDeclarations2 in 'TestDeclarations2.pas',
  TestDeclarations in 'TestDeclarations.pas',
  TestDefaultParams in 'TestDefaultParams.pas',
  TestEmptyClass in 'TestEmptyClass.pas',
  TestEsotericKeywords in 'TestEsotericKeywords.pas',
  TestExclusion in 'TestExclusion.pas',
  TestExclusionFlags in 'TestExclusionFlags.pas',
  TestForward in 'TestForward.pas',
  TestGoto in 'TestGoto.pas',
  TestInitFinal in 'TestInitFinal.pas',
  TestInterfaceImplements in 'TestInterfaceImplements.pas',
  TestInterfaces in 'TestInterfaces.pas',
  TestLayout in 'TestLayout.pas',
  TestLayoutBare2 in 'TestLayoutBare2.pas',
  TestLayoutBare3 in 'TestLayoutBare3.pas',
  TestLayoutBare in 'TestLayoutBare.pas',
  TestLineBreaking in 'TestLineBreaking.pas',
  TestLocalTypes in 'TestLocalTypes.pas',
  TestLongStrings in 'TestLongStrings.pas',
  TestMarcoV in 'TestMarcoV.pas',
  TestMh in 'TestMH.pas',
  TestMixedModeCaps in 'TestMixedModeCaps.pas',
  TestNested in 'TestNested.pas',
  TestNestedRecords in 'TestNestedRecords.pas',
  TestOperators in 'TestOperators.pas',
  TestParams in 'TestParams.pas',
  TestParamSpaces in 'TestParamSpaces.pas',
  TestPointers in 'TestPointers.pas',
  TestProperties in 'TestProperties.pas',
  TestPropertyLines in 'TestPropertyLines.pas',
  TestRecords in 'TestRecords.pas',
  TestReg in 'TestReg.pas',
  TestReint in 'TestReint.pas',
  TestReturnRemoval in 'TestReturnRemoval.pas',
  TestReturns in 'TestReturns.pas',
  TestRunOnConst in 'TestRunOnConst.pas',
  TestRunOnDef in 'TestRunOnDef.pas',
  TestTPObjects in 'TestTPObjects.pas',
  TestTry in 'TestTry.pas',
  TestTypeDefs in 'TestTypeDefs.pas',
  TestUses in 'TestUses.pas',
  TestWarnings in 'TestWarnings.pas',
  TestWith in 'TestWith.pas',
  LittleTest6 in 'LittleTest6.pas',
  TestArray in 'TestArray.pas',
  TestVarParam in 'TestVarParam.pas',
  LittleTest7 in 'LittleTest7.pas',
  LittleTest8 in 'LittleTest8.pas',
  TestDeref in 'TestDeref.pas',
  LittleTest9 in 'LittleTest9.pas',
  TestPropertyInherited in 'TestPropertyInherited.pas',
  TestMessages in 'TestMessages.pas',
  LittleTest10 in 'LittleTest10.pas',
  TestInheritedExpr in 'TestInheritedExpr.pas',
  LittleTest11 in 'LittleTest11.pas',
  LittleTest12 in 'LittleTest12.pas',
  LittleTest13 in 'LittleTest13.pas',
  TestOleParams in 'TestOleParams.pas',
  LittleTest14 in 'LittleTest14.pas',
  LittleTest15 in 'LittleTest15.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormTest, FormTest);
  Application.Run;
end.
