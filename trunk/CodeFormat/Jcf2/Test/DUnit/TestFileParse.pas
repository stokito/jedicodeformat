unit TestFileParse;

interface

uses
 TestFrameWork;

type
 TTestParse = class(TTestCase)
 private
    procedure TestParseFile(const psInFileName, psRefOutput: string; const piTokenCount: integer); overload;
    procedure TestParseFile(const psName: string; const piTokenCount: integer); overload;
 published
   procedure TestDirs;
   procedure TestCreate;


    { one proc for each file,
      as it's nice to have a tick for each test file }
    procedure TestParse_Empty1;
    procedure TestParse_fFormTest;
    procedure TestParse_LittleTest1;
    procedure TestParse_LittleTest2;
    procedure TestParse_LittleTest3;
    procedure TestParse_LittleTest4;
    procedure TestParse_LittleTest5;
    procedure TestParse_TestAbsolute;
    procedure TestParse_TestAlign;
    procedure TestParse_TestAsm;
    procedure TestParse_TestBlankLineRemoval;
    procedure TestParse_TestBogusDirectives;
    procedure TestParse_TestBogusTypes;
    procedure TestParse_TestCaseBlock;
    procedure TestParse_TestSimpleCast;
    procedure TestParse_TestCast;
    procedure TestParse_TestCharLiterals;
    procedure TestParse_TestClassLines;
    procedure TestParse_TestCommentIndent;
    procedure TestParse_TestConstRecords;
    procedure TestParse_TestD6;
    procedure TestParse_TestDeclarations;
    procedure TestParse_TestDeclarations2;
    procedure TestParse_TestDefaultParams;
    procedure TestParse_TestEmptyClass;
    procedure TestParse_TestEsotericKeywords;
    procedure TestParse_TestExclusion;
    procedure TestParse_TestExclusionFlags;
    procedure TestParse_TestExternal;
    procedure TestParse_TestForward;
    procedure TestParse_TestGoto;
    procedure TestParse_TestInitFinal;
    procedure TestParse_TestInterfaceImplements;
    procedure TestParse_TestInterfaceMap;
    procedure TestParse_TestInterfaces;
    procedure TestParse_TestLayout;
    procedure TestParse_TestLayoutBare;
    procedure TestParse_TestLayoutBare2;
    procedure TestParse_TestLayoutBare3;
    procedure TestParse_TestLibExports;
    procedure TestParse_TestLineBreaking;
    procedure TestParse_TestLocalTypes;
    procedure TestParse_TestLongStrings;
    procedure TestParse_TestMarkoV;
    procedure TestParse_TestMixedModeCaps;
    procedure TestParse_TestMVB;
    procedure TestParse_TestNested;
    procedure TestParse_TestNestedRecords;
    procedure TestParse_TestOperators;
    procedure TestParse_TestParams;
    procedure TestParse_TestParamSpaces;
    procedure TestParse_TestPointers;
    procedure TestParse_TestProgram;
    procedure TestParse_TestProperties;
    procedure TestParse_TestPropertyLines;
    procedure TestParse_TestRecords;
    procedure TestParse_TestReg;
    procedure TestParse_TestReint;
    procedure TestParse_TestReturnRemoval;
    procedure TestParse_TestReturns;
    procedure TestParse_TestRunOnConst;
    procedure TestParse_TestRunOnDef;
    procedure TestParse_TestRunOnLine;
    procedure TestParse_TestTestMH;
    procedure TestParse_TestTPObjects;
    procedure TestParse_TestTry;
    procedure TestParse_TestTypeDefs;
    procedure TestParse_TestUses;
    procedure TestParse_TestUsesChanges;
    procedure TestParse_TestWarnings;
 end;

implementation

uses
  { delphi } SysUtils,
  JclStrings,
  FileConverter, ConvertTypes;

const
  TEST_FILES_DIR = 'C:\Code\Delphi\JcfCheckout\CodeFormat\Jcf2\Test\TestCases\';
  REF_OUT_FILES_DIR = 'C:\Code\Delphi\jcf2\TestCases\Out\';

procedure TTestParse.TestParseFile(const psInFileName, psRefOutput: string;
  const piTokenCount: integer);
var
  lcConverter: TFileConverter;
  lsOutFileName: string;
begin
    Check(FileExists(psInFileName), 'input file ' + psInFileName + ' not found');

  // Check(FileExists(psRefOutput), 'reference output file ' + psRefOutput + ' not found');

  lcConverter := TFileConverter.Create;
  try
    lcConverter.YesAll := True;
    lcConverter.GuiMessages := False;

    lcConverter.SourceMode := fmSingleFile;
    lcConverter.BackupMode := cmSeperateOutput;

    lcConverter.Input := psInFileName;

    lcConverter.Convert;

    Check(not lcConverter.ConvertError, 'Convert failed for ' +
      ExtractFileName(psInFileName) +
      ' : ' + lcConverter.ConvertErrorMessage);

    lsOutFileName := lcConverter.OutFileName;
    Check(lsOutFileName <> '', 'No output file');
    Check(FileExists(lsOutFileName), 'output file ' + lsOutFileName + ' not found');

    CheckEquals(piTokenCount, lcConverter.TokenCount, 'wrong number of tokens');

  finally
    lcConverter.Free;
  end;

  //TestFileContentsSame(lsOutFileName, psRefOutput);
end;


procedure TTestParse.TestCreate;
var
  lcConverter: TFileConverter;
begin
  lcConverter := TFileConverter.Create;
  lcConverter.Free;
end;

procedure TTestParse.TestDirs;
begin
  Check(DirectoryExists(TEST_FILES_DIR), 'Test files dir ' + TEST_FILES_DIR + ' not found');
  Check(DirectoryExists(REF_OUT_FILES_DIR), 'Test files ref out dir ' + TEST_FILES_DIR + ' not found');
end;


procedure TTestParse.TestParseFile(const psName: string; const piTokenCount: integer);
begin
  TestParseFile(TEST_FILES_DIR + psName + '.pas',
    REF_OUT_FILES_DIR + psName + '.out', piTokenCount)
end;

procedure TTestParse.TestParse_Empty1;
begin
  TestParseFile('EmptyTest1', 15);
end;

procedure TTestParse.TestParse_fFormTest;
begin
  TestParseFile('fFormTest', 151);
end;

procedure TTestParse.TestParse_LittleTest1;
begin
  TestParseFile('LittleTest1', 25);
end;

procedure TTestParse.TestParse_LittleTest2;
begin
  TestParseFile('LittleTest2', 26);
end;

procedure TTestParse.TestParse_LittleTest3;
begin
  TestParseFile('LittleTest3', 39);
end;

procedure TTestParse.TestParse_LittleTest4;
begin
  TestParseFile('LittleTest4', 41);
end;

procedure TTestParse.TestParse_LittleTest5;
begin
  TestParseFile('LittleTest5', 54);
end;

procedure TTestParse.TestParse_TestAbsolute;
begin
  TestParseFile('TestAbsolute', 86);
end;

procedure TTestParse.TestParse_TestAlign;
begin
  TestParseFile('TestAlign', 662);
end;

procedure TTestParse.TestParse_TestAsm;
begin
  TestParseFile('TestAsm', 521);
end;

procedure TTestParse.TestParse_TestBlankLineRemoval;
begin
  TestParseFile('TestBlankLineRemoval', 369);
end;

procedure TTestParse.TestParse_TestBogusDirectives;
begin
  TestParseFile('TestBogusDirectives', 300);
end;

procedure TTestParse.TestParse_TestBogusTypes;
begin
  TestParseFile('TestBogusTypes', 230);
end;

procedure TTestParse.TestParse_TestCaseBlock;
begin
  TestParseFile('TestCaseBlock', 2751);
end;

procedure TTestParse.TestParse_TestCast;
begin
  TestParseFile('TestCast', 600);
end;

procedure TTestParse.TestParse_TestSimpleCast;
begin
  TestParseFile('TestCastSimple', 843);
end;

procedure TTestParse.TestParse_TestCharLiterals;
begin
  TestParseFile('TestCharLiterals', 177);
end;

procedure TTestParse.TestParse_TestClassLines;
begin
  TestParseFile('TestClassLines', 71);
end;

procedure TTestParse.TestParse_TestCommentIndent;
begin
  TestParseFile('TestCommentIndent', 549);
end;

procedure TTestParse.TestParse_TestConstRecords;
begin
  TestParseFile('TestConstRecords', 760);
end;

procedure TTestParse.TestParse_TestD6;
begin
  TestParseFile('TestD6', 845);
end;

procedure TTestParse.TestParse_TestDeclarations;
begin
  TestParseFile('TestDeclarations', 985);
end;


procedure TTestParse.TestParse_TestDeclarations2;
begin
  TestParseFile('TestDeclarations2', 362);
end;

procedure TTestParse.TestParse_TestDefaultParams;
begin
  TestParseFile('TestDefaultParams', 698);
end;

procedure TTestParse.TestParse_TestEmptyClass;
begin
  TestParseFile('TestEmptyClass', 244);
end;

procedure TTestParse.TestParse_TestEsotericKeywords;
begin
  TestParseFile('TestEsotericKeywords', 258);
end;

procedure TTestParse.TestParse_TestExclusion;
begin
  TestParseFile('TestExclusion', 431);
end;

procedure TTestParse.TestParse_TestExclusionFlags;
begin
  TestParseFile('TestExclusionFlags', 723);
end;

procedure TTestParse.TestParse_TestExternal;
begin
  TestParseFile('TestExternal', 259);
end;

procedure TTestParse.TestParse_TestForward;
begin
  TestParseFile('TestForward', 332);
end;

procedure TTestParse.TestParse_TestGoto;
begin
  TestParseFile('TestGoto', 443);
end;

procedure TTestParse.TestParse_TestInitFinal;
begin
  TestParseFile('TestInitFinal', 170);
end;

procedure TTestParse.TestParse_TestInterfaceImplements;
begin
  TestParseFile('TestInterfaceImplements', 225);
end;

procedure TTestParse.TestParse_TestInterfaceMap;
begin
  TestParseFile('TestInterfaceMap', 397);
end;

procedure TTestParse.TestParse_TestInterfaces;
begin
  TestParseFile('TestInterfaces', 352);
end;

procedure TTestParse.TestParse_TestLayout;
begin
  TestParseFile('TestLayout', 1051);
end;

procedure TTestParse.TestParse_TestLayoutBare;
begin
  TestParseFile('TestLayoutBare', 1459);
end;

procedure TTestParse.TestParse_TestLayoutBare2;
begin
  TestParseFile('TestLayoutBare2', 1008);
end;

procedure TTestParse.TestParse_TestLayoutBare3;
begin
  TestParseFile('TestLayoutBare3', 1177);
end;

procedure TTestParse.TestParse_TestLibExports;
begin
  TestParseFile('TestLibExports', 119);
end;

procedure TTestParse.TestParse_TestLineBreaking;
begin
  TestParseFile('TestLineBreaking', 4445);
end;

procedure TTestParse.TestParse_TestLocalTypes;
begin
  TestParseFile('TestLocalTypes', 297);
end;

procedure TTestParse.TestParse_TestLongStrings;
begin
  TestParseFile('TestLongStrings', 163);
end;

procedure TTestParse.TestParse_TestMarkoV;
begin
  TestParseFile('TestMarkoV', 241);
end;

procedure TTestParse.TestParse_TestTestMH;
begin
  TestParseFile('TestMH', 2956);
end;

procedure TTestParse.TestParse_TestMixedModeCaps;
begin
  TestParseFile('TestMixedModeCaps', 123);
end;

procedure TTestParse.TestParse_TestMVB;
begin
  TestParseFile('TestMVB', 833);
end;

procedure TTestParse.TestParse_TestNested;
begin
  TestParseFile('TestNested', 658);
end;

procedure TTestParse.TestParse_TestNestedRecords;
begin
  TestParseFile('TestNestedRecords', 984);
end;

procedure TTestParse.TestParse_TestOperators;
begin
  TestParseFile('TestOperators', 1128);
end;

procedure TTestParse.TestParse_TestParams;
begin
  TestParseFile('TestParams', 218);
end;

procedure TTestParse.TestParse_TestParamSpaces;
begin
  TestParseFile('TestParamSpaces', 159);
end;

procedure TTestParse.TestParse_TestPointers;
begin
  TestParseFile('TestPointers', 193);
end;

procedure TTestParse.TestParse_TestProgram;
begin
  TestParseFile('TestProgram', 1246);
end;

procedure TTestParse.TestParse_TestProperties;
begin
  TestParseFile('TestProperties', 677);
end;

procedure TTestParse.TestParse_TestPropertyLines;
begin
  TestParseFile('TestPropertyLines', 1186);
end;

procedure TTestParse.TestParse_TestRecords;
begin
  TestParseFile('TestRecords', 1244);
end;

procedure TTestParse.TestParse_TestReg;
begin
  TestParseFile('TestReg', 85);
end;

procedure TTestParse.TestParse_TestReint;
begin
  TestParseFile('TestReint', 159);
end;

procedure TTestParse.TestParse_TestReturnRemoval;
begin
  TestParseFile('TestReturnRemoval', 256);
end;

procedure TTestParse.TestParse_TestReturns;
begin
  TestParseFile('TestReturns', 141);
end;

procedure TTestParse.TestParse_TestRunOnConst;
begin
  TestParseFile('TestRunOnConst', 465);
end;

procedure TTestParse.TestParse_TestRunOnDef;
begin
  TestParseFile('TestRunOnDef', 363);
end;

procedure TTestParse.TestParse_TestRunOnLine;
begin
  TestParseFile('TestRunOnLine', 3668);
end;

procedure TTestParse.TestParse_TestTPObjects;
begin
  TestParseFile('TestTPObjects', 126);
end;

procedure TTestParse.TestParse_TestTry;
begin
  TestParseFile('TestTry', 391);
end;

procedure TTestParse.TestParse_TestTypeDefs;
begin
  TestParseFile('TestTypeDefs', 793);
end;

procedure TTestParse.TestParse_TestUses;
begin
  TestParseFile('TestUses', 64);
end;

procedure TTestParse.TestParse_TestUsesChanges;
begin
  TestParseFile('TestUsesChanges', 56);
end;

procedure TTestParse.TestParse_TestWarnings;
begin
  TestParseFile('TestWarnings', 558);
end;

initialization
 TestFramework.RegisterTest(TTestParse.Suite);
end.