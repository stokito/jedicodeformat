{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is CodeFormat.dpr, released April 2000.
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

program JediCodeFormat;

uses
  Forms,
  SysUtils,
  JclStrings in '..\External\JCL\Source\JclStrings.pas',
  JclBase in '..\External\JCL\Source\JclBase.pas',
  JclFileUtils in '..\External\JCL\Source\JclFileUtils.pas',
  JclWin32 in '..\External\JCL\Source\JclWin32.pas',
  JclDateTime in '..\External\JCL\Source\JclDateTime.pas',
  JclResources in '..\External\JCL\Source\JclResources.pas',
  JclSysUtils in '..\External\JCL\Source\JclSysUtils.pas',
  JclSysInfo in '..\External\JCL\Source\JclSysInfo.pas',
  JclRegistry in '..\External\JCL\Source\JclRegistry.pas',
  JclSecurity in '..\External\JCL\Source\JclSecurity.pas',
  JclShell in '..\External\JCL\Source\JclShell.pas',
  frDrop in 'Utils\frDrop.pas' {FrameDrop: TFrame},
  DropTarget in 'Utils\DropTarget.pas',
  fMain in 'UI\fMain.pas' {frmMain},
  fAbout in 'UI\fAbout.pas' {frmAboutBox},
  frFiles in 'UI\Settings\frFiles.pas' {fFiles: TFrame},
  frObfuscateSettings in 'UI\Settings\frObfuscateSettings.pas' {fObfuscateSettings: TFrame},
  SettingsFrame in 'UI\Settings\SettingsFrame.pas' {frSettingsFrame: TFrame},
  frReplace in 'UI\Settings\frReplace.pas' {fReplace: TFrame},
  frExcludeFiles in 'UI\Settings\frExcludeFiles.pas' {fExcludeFiles: TFrame},
  Converter in 'ReadWrite\Converter.pas',
  ConvertTypes in 'Types\ConvertTypes.pas',
  Reader in 'ReadWrite\Reader.pas',
  Writer in 'ReadWrite\Writer.pas',
  TokenType in 'Types\TokenType.pas',
  Token in 'Types\Token.pas',
  WordMap in 'Types\WordMap.pas',
  TokenSource in 'Types\TokenSource.pas',
  Tokeniser in 'TokenCreation\Tokeniser.pas',
  JCFLog in 'Utils\JCFLog.pas',
  Pipeline in 'Types\Pipeline.pas',
  TokenProcessPipeline in 'Processors\TokenProcessPipeline.pas',
  Capitalisation in 'Processors\Capitalisation.pas',
  NoSpaceBefore in 'Processors\Spacing\NoSpaceBefore.pas',
  ReturnAfter in 'Processors\Spacing\ReturnAfter.pas',
  ReturnBefore in 'Processors\Spacing\ReturnBefore.pas',
  SingleSpaceAfter in 'Processors\Spacing\SingleSpaceAfter.pas',
  SingleSpaceBefore in 'Processors\Spacing\SingleSpaceBefore.pas',
  SpecificWordCaps in 'Processors\SpecificWordCaps.pas',
  TabToSpace in 'Processors\Spacing\TabToSpace.pas',
  TokenContext in 'TokenCreation\TokenContext.pas',
  IndentProcedures in 'Processors\Indent\IndentProcedures.pas',
  FixCase in 'Processors\Obfuscate\FixCase.pas',
  WhiteSpaceEater in 'Processors\Obfuscate\WhiteSpaceEater.pas',
  WhiteSpaceEater2 in 'Processors\Obfuscate\WhiteSpaceEater2.pas',
  CommentEater in 'Processors\Obfuscate\CommentEater.pas',
  LineUnbreaker in 'Processors\Obfuscate\LineUnbreaker.pas',
  LineRebreaker in 'Processors\Obfuscate\LineRebreaker.pas',
  RemoveFromUses in 'Processors\OnceOffs\RemoveFromUses.pas',
  ADOUsesClause in 'Processors\OnceOffs\ADOUsesClause.pas',
  Replace in 'Processors\Transform\Replace.pas',
  AlignAssign in 'Processors\Align\AlignAssign.pas',
  Position in 'Processors\Position.pas',
  AlignStatements in 'Processors\Align\AlignStatements.pas',
  AlignConst in 'Processors\Align\AlignConst.pas',
  AlignTypedef in 'Processors\Align\AlignTypedef.pas',
  AlignVars in 'Processors\Align\AlignVars.pas',
  JCFSetBase in 'Settings\JCFSetBase.pas',
  SetObfuscate in 'Settings\SetObfuscate.pas',
  SetFile in 'Settings\SetFile.pas',
  SetCaps in 'Settings\SetCaps.pas',
  SetAnyWordCaps in 'Settings\SetAnyWordCaps.pas',
  SetClarify in 'Settings\SetClarify.pas',
  SetReplace in 'Settings\SetReplace.pas',
  SetLog in 'Settings\SetLog.pas',
  SetAlign in 'Settings\SetAlign.pas',
  SetIndent in 'Settings\SetIndent.pas',
  Indenter in 'Processors\Indent\Indenter.pas',
  IndentGlobals in 'Processors\Indent\IndentGlobals.pas',
  IndentClassDef in 'Processors\Indent\IndentClassDef.pas',
  TokenBareIndent in 'TokenCreation\TokenBareIndent.pas',
  NoSpaceAfter in 'Processors\Spacing\NoSpaceAfter.pas',
  IndentUsesClause in 'Processors\Indent\IndentUsesClause.pas',
  MozComment in 'Processors\OnceOffs\MozComment.pas',
  LineBreaker in 'Processors\LineBreaker.pas',
  IntList in 'Types\IntList.pas',
  CommentBreaker in 'TokenCreation\CommentBreaker.pas',
  BlockStyles in 'Processors\Spacing\BlockStyles.pas',
  frClarify in 'UI\Settings\frClarify.pas' {fClarify: TFrame},
  frBasicSettings in 'UI\Settings\frBasicSettings.pas' {frBasic: TFrame},
  RemoveReturnsAfterBegin in 'Processors\Spacing\RemoveReturnsAfterBegin.pas',
  RemoveReturnsBeforeEnd in 'Processors\Spacing\RemoveReturnsBeforeEnd.pas',
  RemoveIndent in 'Processors\Obfuscate\RemoveIndent.pas',
  WarnRealType in 'Processors\Warnings\WarnRealType.pas',
  WarnDestroy in 'Processors\Warnings\WarnDestroy.pas',
  NoReturnBefore in 'Processors\Spacing\NoReturnBefore.pas',
  WarnCaseNoElse in 'Processors\Warnings\WarnCaseNoElse.pas',
  NoReturnAfter in 'Processors\Spacing\NoReturnAfter.pas',
  WarnEmptyBlock in 'Processors\Warnings\WarnEmptyBlock.pas',
  fAllSettings in 'UI\fAllSettings.pas' {FormAllSettings},
  frAnyCapsSettings in 'UI\Settings\frAnyCapsSettings.pas' {frAnyCapsSettings: TFrame},
  frReservedCapsSettings in 'UI\Settings\frReservedCapsSettings.pas' {frReservedCapsSettings: TFrame},
  frClarifyBlocks in 'Ui\Settings\frClarifyBlocks.pas' {fClarifyBlocks: TFrame},
  frClarifySpaces in 'Ui\Settings\frClarifySpaces.pas' {fClarifySpaces: TFrame},
  frClarifyAlign in 'UI\Settings\frClarifyAlign.pas' {fClarifyAlign: TFrame},
  SpaceToTab in 'Processors\Spacing\SpaceToTab.pas',
  SetUses in 'Settings\SetUses.pas',
  frUses in 'UI\Settings\frUses.pas' {fUses: TFrame},
  UsesClauseFindReplace in 'Processors\Transform\UsesClauseFindReplace.pas',
  UsesClauseRemove in 'Processors\Transform\UsesClauseRemove.pas',
  UsesClauseInsert in 'Processors\Transform\UsesClauseInsert.pas',
  FileReader in 'ReadWrite\FileReader.pas',
  FileWriter in 'ReadWrite\FileWriter.pas',
  FileConverter in 'ReadWrite\FileConverter.pas',
  MiscFunctions in 'Utils\MiscFunctions.pas',
  TypedEdit in '..\JediVCL\Edit\TypedEdit.pas',
  MemoEx in '..\JediVCL\Edit\MemoEx.pas',
  JCFSettings in 'Settings\JCFSettings.pas',
  SpaceBeforeColon in 'Processors\Spacing\SpaceBeforeColon.pas',
  RemoveBlankLinesInVars in 'Processors\Spacing\RemoveBlankLinesInVars.pas',
  frClarifyIndent in 'Ui\Settings\frClarifyIndent.pas' {fClarifyIndent: TFrame},
  SetSpaces in 'Settings\SetSpaces.pas',
  frAbout in 'Ui\Settings\frAbout.pas' {FrameAbout: TFrame},
  PropertyOnOneLine in 'Processors\Spacing\PropertyOnOneLine.pas',
  SetReturns in 'Settings\SetReturns.pas',
  frClarifyReturns in 'Ui\Settings\frClarifyReturns.pas' {fClarifyReturns: TFrame},
  SetUi in 'Settings\SetUi.pas',
  FormatFlags in 'Types\FormatFlags.pas',
  Warn in 'Processors\Warnings\Warn.pas',
  ComponentFunctions in '..\JediVCL\ComponentFunctions.pas',
  RemoveBlankLinesAfterProcHeader in 'Processors\Spacing\RemoveBlankLinesAfterProcHeader.pas',
  ReturnChars in 'Processors\Spacing\ReturnChars.pas',
  WarnAssignToFunctionName in 'Processors\Warnings\WarnAssignToFunctionName.pas',
  SettingsStream in 'Settings\Streams\SettingsStream.pas',
  RegistrySettings in 'Settings\Streams\RegistrySettings.pas',
  JCFHelp in 'Utils\JCFHelp.pas',
  FileUtils in 'Utils\FileUtils.pas',
  AlignComment in 'Processors\Align\AlignComment.pas';

{$R *.RES}


begin
  Application.Initialize;
  Application.Title := 'Jedi Code Format';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.