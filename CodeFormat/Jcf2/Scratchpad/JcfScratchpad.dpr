program JcfScratchpad;

uses
  Forms,
  frmJcfScratchpad in 'frmJcfScratchpad.pas' {frmScratchpad},
  Converter in '..\ReadWrite\Converter.pas',
  CodeReader in '..\ReadWrite\CodeReader.pas',
  CodeWriter in '..\ReadWrite\CodeWriter.pas',
  StringsReader in '..\ReadWrite\StringsReader.pas',
  StringsWriter in '..\ReadWrite\StringsWriter.pas',
  StringsConverter in '..\ReadWrite\StringsConverter.pas',
  ConvertTypes in '..\ReadWrite\ConvertTypes.pas',
  WordMap in '..\Parse\WordMap.pas',
  BuildParseTree in '..\Parse\BuildParseTree.pas',
  BuildTokenList in '..\Parse\BuildTokenList.pas',
  ParseError in '..\Parse\ParseError.pas',
  ParseTreeNode in '..\Parse\ParseTreeNode.pas',
  ParseTreeNodeType in '..\Parse\ParseTreeNodeType.pas',
  SourceToken in '..\Parse\SourceToken.pas',
  SourceTokenList in '..\Parse\SourceTokenList.pas',
  TokenType in '..\Parse\TokenType.pas',
  VisitSetXY in '..\Process\VisitSetXY.pas',
  BaseVisitor in '..\Process\BaseVisitor.pas',
  VisitParseTree in '..\Process\VisitParseTree.pas',
  JcfMiscFunctions in '..\Utils\JcfMiscFunctions.pas',
  FileUtils in '..\Utils\FileUtils.pas',
  JCFLog in '..\Utils\JcfLog.pas',
  fShowParseTree in '..\Parse\UI\fShowParseTree.pas' {frmShowParseTree},
  SetUses in '..\Settings\SetUses.pas',
  JCFSetBase in '..\Settings\JCFSetBase.pas',
  JCFSettings in '..\Settings\JCFSettings.pas',
  SetAlign in '..\Settings\SetAlign.pas',
  SetAnyWordCaps in '..\Settings\SetAnyWordCaps.pas',
  SetCaps in '..\Settings\SetCaps.pas',
  SetClarify in '..\Settings\SetClarify.pas',
  SetFile in '..\Settings\SetFile.pas',
  SetIndent in '..\Settings\SetIndent.pas',
  SetLog in '..\Settings\SetLog.pas',
  SetObfuscate in '..\Settings\SetObfuscate.pas',
  SetReplace in '..\Settings\SetReplace.pas',
  SetReturns in '..\Settings\SetReturns.pas',
  SetSpaces in '..\Settings\SetSpaces.pas',
  SetUi in '..\Settings\SetUi.pas',
  SettingsStream in '..\Settings\Streams\SettingsStream.pas',
  RegistrySettings in '..\Settings\Streams\RegistrySettings.pas',
  RemoveUnneededWhiteSpace in '..\Process\Obfuscate\RemoveUnneededWhiteSpace.pas',
  FixCase in '..\Process\Obfuscate\FixCase.pas',
  ObfuscateControl in '..\Process\Obfuscate\ObfuscateControl.pas',
  RebreakLines in '..\Process\Obfuscate\RebreakLines.pas',
  ReduceWhiteSpace in '..\Process\Obfuscate\ReduceWhiteSpace.pas',
  RemoveComment in '..\Process\Obfuscate\RemoveComment.pas',
  RemoveConsecutiveWhiteSpace in '..\Process\Obfuscate\RemoveConsecutiveWhiteSpace.pas',
  RemoveReturn in '..\Process\Obfuscate\RemoveReturn.pas',
  AllWarnings in '..\Process\Warnings\AllWarnings.pas',
  WarnRealType in '..\Process\Warnings\WarnRealType.pas',
  WarnAssignToFunctionName in '..\Process\Warnings\WarnAssignToFunctionName.pas',
  WarnCaseNoElse in '..\Process\Warnings\WarnCaseNoElse.pas',
  WarnDestroy in '..\Process\Warnings\WarnDestroy.pas',
  WarnEmptyBlock in '..\Process\Warnings\WarnEmptyBlock.pas',
  Warning in '..\Process\Warnings\Warning.pas',
  VersionConsts in '..\VersionConsts.pas',
  ScratchpadSettings in 'ScratchpadSettings.pas',
  TokenUtils in '..\Parse\TokenUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmScratchpad, frmScratchpad);
  Application.Run;
end.
