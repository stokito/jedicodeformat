program jcf;
{$APPTYPE CONSOLE}
{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is jcf, released May 2003.
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

uses
  SysUtils,
  FileCtrl,
  JclStrings,
  Converter in '..\ReadWrite\Converter.pas',
  CodeReader in '..\ReadWrite\CodeReader.pas',
  CodeWriter in '..\ReadWrite\CodeWriter.pas',
  StringsReader in '..\ReadWrite\StringsReader.pas',
  StringsWriter in '..\ReadWrite\StringsWriter.pas',
  FileConverter in '..\ReadWrite\FileConverter.pas',
  ConvertTypes in '..\ReadWrite\ConvertTypes.pas',
  BuildParseTree in '..\Parse\BuildParseTree.pas',
  BuildTokenList in '..\Parse\BuildTokenList.pas',
  ParseError in '..\Parse\ParseError.pas',
  ParseTreeNode in '..\Parse\ParseTreeNode.pas',
  ParseTreeNodeType in '..\Parse\ParseTreeNodeType.pas',
  SourceToken in '..\Parse\SourceToken.pas',
  SourceTokenList in '..\Parse\SourceTokenList.pas',
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
  SetCaps in '..\Settings\SetCaps.pas',
  SetClarify in '..\Settings\SetClarify.pas',
  SetFile in '..\Settings\SetFile.pas',
  SetIndent in '..\Settings\SetIndent.pas',
  SetObfuscate in '..\Settings\SetObfuscate.pas',
  SetReplace in '..\Settings\SetReplace.pas',
  SetReturns in '..\Settings\SetReturns.pas',
  SetSpaces in '..\Settings\SetSpaces.pas',
  SettingsStream in '..\Settings\Streams\SettingsStream.pas',
  RegistrySettings in '..\Settings\Streams\RegistrySettings.pas',
  RemoveUnneededWhiteSpace in '..\Process\Obfuscate\RemoveUnneededWhiteSpace.pas',
  FixCase in '..\Process\Obfuscate\FixCase.pas',
  RebreakLines in '..\Process\Obfuscate\RebreakLines.pas',
  ReduceWhiteSpace in '..\Process\Obfuscate\ReduceWhiteSpace.pas',
  RemoveComment in '..\Process\Obfuscate\RemoveComment.pas',
  RemoveConsecutiveWhiteSpace in '..\Process\Obfuscate\RemoveConsecutiveWhiteSpace.pas',
  RemoveReturn in '..\Process\Obfuscate\RemoveReturn.pas',
  WarnRealType in '..\Process\Warnings\WarnRealType.pas',
  WarnAssignToFunctionName in '..\Process\Warnings\WarnAssignToFunctionName.pas',
  WarnCaseNoElse in '..\Process\Warnings\WarnCaseNoElse.pas',
  WarnDestroy in '..\Process\Warnings\WarnDestroy.pas',
  WarnEmptyBlock in '..\Process\Warnings\WarnEmptyBlock.pas',
  Warning in '..\Process\Warnings\Warning.pas',
  VersionConsts in '..\VersionConsts.pas',
  JcfRegistrySettings in '..\Settings\JcfRegistrySettings.pas',
  TokenUtils in '..\Parse\TokenUtils.pas',
  NoSpaceBefore in '..\Process\Spacing\NoSpaceBefore.pas',
  NoSpaceAfter in '..\Process\Spacing\NoSpaceAfter.pas',
  SingleSpaceAfter in '..\Process\Spacing\SingleSpaceAfter.pas',
  SingleSpaceBefore in '..\Process\Spacing\SingleSpaceBefore.pas',
  ReturnAfter in '..\Process\Returns\ReturnAfter.pas',
  Nesting in '..\Process\Nesting.pas',
  VisitSetNesting in '..\Process\VisitSetNesting.pas',
  ReturnBefore in '..\Process\Returns\ReturnBefore.pas',
  NoReturnAfter in '..\Process\Returns\NoReturnAfter.pas',
  NoReturnBefore in '..\Process\Returns\NoReturnBefore.pas',
  AllProcesses in '..\Process\AllProcesses.pas',
  RemoveBlankLine in '..\Process\Obfuscate\RemoveBlankLine.pas',
  BlockStyles in '..\Process\Returns\BlockStyles.pas',
  SwitchableVisitor in '..\Process\SwitchableVisitor.pas',
  FormatFlags in '..\Process\FormatFlags.pas',
  TabToSpace in '..\Process\Spacing\TabToSpace.pas',
  SpaceToTab in '..\Process\Spacing\SpaceToTab.pas',
  SpecificWordCaps in '..\Process\Capitalisation\SpecificWordCaps.pas',
  Capitalisation in '..\Process\Capitalisation\Capitalisation.pas',
  Indenter in '..\Process\Indent\Indenter.pas',
  PropertyOnOneLine in '..\Process\Returns\PropertyOnOneLine.pas',
  SpaceBeforeColon in '..\Process\Spacing\SpaceBeforeColon.pas',
  VisitStripEmptySpace in '..\Process\VisitStripEmptySpace.pas',
  RemoveBlankLinesAfterProcHeader in '..\Process\Returns\RemoveBlankLinesAfterProcHeader.pas',
  RemoveBlankLinesInVars in '..\Process\Returns\RemoveBlankLinesInVars.pas',
  ReturnChars in '..\Process\Returns\ReturnChars.pas',
  RemoveReturnsBeforeEnd in '..\Process\Returns\RemoveReturnsBeforeEnd.pas',
  RemoveReturnsAfterBegin in '..\Process\Returns\RemoveReturnsAfterBegin.pas',
  LongLineBreaker in '..\Process\Returns\LongLineBreaker.pas',
  IntList in '..\Utils\IntList.pas',
  BasicStats in '..\Process\Info\BasicStats.pas',
  AlignConst in '..\Process\Align\AlignConst.pas',
  AlignBase in '..\Process\Align\AlignBase.pas',
  AlignAssign in '..\Process\Align\AlignAssign.pas',
  AlignVars in '..\Process\Align\AlignVars.pas',
  AlignTypedef in '..\Process\Align\AlignTypedef.pas',
  AlignComment in '..\Process\Align\AlignComment.pas',
  FileWriter in '..\ReadWrite\FileWriter.pas',
  FileReader in '..\ReadWrite\FileReader.pas',
  Tokens in '..\Parse\Tokens.pas',
  SetWordList in '..\Settings\SetWordList.pas';

const
  ABOUT_COMMANDLINE =
  'Jedi Code Format V' + PROGRAM_VERSION + AnsiLineBreak +
  ' ' + PROGRAM_DATE + AnsiLineBreak +
  ' A Delphi Object-Pascal Source code formatter' + AnsiLineBreak  +
  ' A GUI version of this program is also available' + AnsiLineBreak +
  ' Latest version at ' + PROGRAM_HOME_PAGE + AnsiLineBreak + AnsiLineBreak +
  'Syntax: jcf [options] path/filename ' +  AnsiLineBreak +
  ' Parameters to the command-line program: ' + AnsiLineBreak + AnsiLineBreak +

  ' Mode of operation: ' + AnsiLineBreak +
  ' -obfuscate Obfuscate mode or ' + AnsiLineBreak +
  ' -clarify Clarify mode' + AnsiLineBreak +
  '   When neither is specified, registry setting will be used.' +  AnsiLineBreak +
  '   This normally means clarify.' +  AnsiLineBreak  + AnsiLineBreak +

  ' Mode of source: ' + AnsiLineBreak +
  ' -F Format a file. The file name must be specified.' + AnsiLineBreak +
  ' -D Format a directory. The directory name must be specified.' + AnsiLineBreak +
  ' -R Format a directory tree. The root directory name must be specified.' + AnsiLineBreak +
  '  When no file mode is specified, registry setting will be used.' +  AnsiLineBreak + AnsiLineBreak +

  ' Mode of output: ' + AnsiLineBreak +
  ' -inplace change the source file without backup' + AnsiLineBreak +
  ' -out output to a new file' + AnsiLineBreak +
  ' -backup change the file and leave the original file as a backup' + AnsiLineBreak +
  '  If no output mode is specified, registry setting will be used.' +  AnsiLineBreak + AnsiLineBreak +

  ' Other options: ' + AnsiLineBreak +
  ' -config=filename  To specify a named configuration file' + AnsiLineBreak +
  ' -y No prompts to overwrite files etc. Yes is assumed ' + AnsiLineBreak +
  ' -? Display this help' + AnsiLineBreak;

var
  fbCmdLineShowHelp: Boolean;
  fbQuietFail: Boolean;

  fbCmdLineObfuscate: Boolean;
  fbCmdLineClarify: Boolean;

  fbHasSourceMode: Boolean;
  feCmdLineSourceMode: TSourceMode;

  fbHasBackupMode: Boolean;
  feCmdLineBackupMode: TBackupMode;

  fbYesAll: Boolean;

  fbHasNamedConfigFile: Boolean;
  fsConfigFileName: string;

function StripParamPrefix(const ps: string): string;
begin
  Result := ps;

  if StrLeft(Result, 1) = '/' then
    Result := StrRestOf(Result, 2);
  if StrLeft(ps, 1) = '\' then
    Result := StrRestOf(Result, 2);
  if StrLeft(Result, 1) = '-' then
    Result := StrRestOf(Result, 2);
end;

procedure ParseCommandLine;
var
  liLoop: integer;
  lsOpt: string;
  lsPath: string;
begin
  fbCmdLineShowHelp := (ParamCount = 0);
  fbQuietFail := False;
  fbCmdLineObfuscate := False;
  fbCmdLineClarify := False;
  fbHasSourceMode := False;
  fbHasBackupMode := False;
  fbYesAll := False;
  fbHasNamedConfigFile := False;
  fsConfigFileName := '';

  for liLoop := 1 to ParamCount do
  begin
    { look for something that is not a -/\ param }
    lsOpt := ParamStr(liLoop);

    if (StrLeft(lsOpt, 1) <> '-') and (StrLeft(lsOpt, 1) <> '/') and
      (StrLeft(lsOpt, 1) <> '\') and (StrLeft(lsOpt, 1) <> '?') then
    begin
      // must be a path
      lsPath := StrTrimQuotes(lsOpt);
      continue;
    end;

    lsOpt := StripParamPrefix(lsOpt);

    if lsOpt = '?' then
    begin
      fbCmdLineShowHelp := True;
      break;
    end
    else if AnsiSameText(lsOpt, 'obfuscate') then
    begin
      fbCmdLineObfuscate := True;
      fbCmdLineClarify := False;
    end
    else if AnsiSameText(lsOpt, 'clarify') then
    begin
      fbCmdLineObfuscate := False;
      fbCmdLineClarify := True;
    end

    else if AnsiSameText(lsOpt, 'inplace') then
    begin
      fbHasBackupMode := True;
      feCmdLineBackupMode := cmInPlace;
    end
    else if AnsiSameText(lsOpt, 'out') then
    begin
      fbHasBackupMode := True;
      feCmdLineBackupMode := cmSeperateOutput;
    end
    else if AnsiSameText(lsOpt, 'backup') then
    begin
      fbHasBackupMode := True;
      feCmdLineBackupMode := cmInPlaceWithBackup;
    end

    else if AnsiSameText(lsOpt, 'f') then
    begin
      fbHasSourceMode := True;
      feCmdLineSourceMode := fmSingleFile;
    end
    else if AnsiSameText(lsOpt, 'd') then
    begin
      fbHasSourceMode := True;
      feCmdLineSourceMode := fmDirectory;
    end
    else if AnsiSameText(lsOpt, 'r') then
    begin
      fbHasSourceMode := True;
      feCmdLineSourceMode := fmDirectoryRecursive;
    end
    else if AnsiSameText(lsOpt, 'y') then
    begin
      fbYesAll := True;
    end
    else if StrFind('config', lsOpt) = 1 then
    begin
     fbHasNamedConfigFile := True;
     fsConfigFileName := StrAfter('=', lsOpt);
    end
    else
    begin
      WriteLn('Unknown option ' +  StrDoubleQuote(lsOpt));
      WriteLn;
      fbCmdLineShowHelp := True;
      break;
    end;
  end; // for loop

  if lsPath = '' then
  begin
    WriteLn('No path found');
    WriteLn;
    fbCmdLineShowHelp := True;
  end;

  { read settings from file? }
  if fbHasNamedConfigFile and (fsConfigFileName <> '') then
  begin
    if FileExists(fsConfigFileName) then
    begin
      FormatSettings.ReadFromFile(fsConfigFileName);
    end
    else
    begin
      WriteLn('Named config file ' + fsConfigFileName + ' was not found');
      WriteLn;
      fbQuietFail := True;
    end
  end;

  { write to settings }
  if fbHasSourceMode then
    GetRegSettings.SourceMode := feCmdLineSourceMode;
  if fbHasBackupMode then
    GetRegSettings.BackupMode := feCmdLineBackupMode;

  if not fbCmdLineShowHelp then
  begin
    if GetRegSettings.SourceMode = fmSingleFile then
    begin
      if not FileExists(lsPath) then
      begin
        WriteLn('File ' +  StrDoubleQuote(lsPath) + ' not found');
        fbQuietFail := True;
      end;
    end
    else
    begin
      if not DirectoryExists(lsPath) then
      begin
        WriteLn('Directory ' +  StrDoubleQuote(lsPath) + ' not found');
        fbQuietFail := True;
      end;
    end;
  end;

  GetRegSettings.Input := lsPath;
  FormatSettings.Obfuscate.Enabled := fbCmdLineObfuscate;
end;

type TStatusMsgReceiver = Class(Tobject)
  public
    procedure OnReceiveStatusMessage(const ps: string);
end;

var
  lcConvert: TFileConverter;
  lcStatus: TStatusMsgReceiver;
{ TStatusMsgReceiver }

procedure TStatusMsgReceiver.OnReceiveStatusMessage(const ps: string);
begin
  WriteLn(ps);
end;

{ main program starts here }
begin
  { read registry }
  GetRegSettings.ReadAll;

  { format setttings will be altered by the command line.
    Do not persist these changes }
  FormatSettings.WriteOnExit := False;

  lcStatus := TStatusMsgReceiver.Create;

  ParseCommandLine;

  if fbQuietFail then
  begin
    // do nothing
  end
  else if fbCmdLineShowHelp then
  begin
    WriteLn(ABOUT_COMMANDLINE);
  end
  else
  begin
    lcConvert := TFileConverter.Create;
    try
      lcConvert.OnStatusMessage := lcStatus.OnReceiveStatusMessage;
      // use command line settings
      lcConvert.YesAll := fbYesAll;
      lcConvert.GuiMessages := False;
      lcConvert.SourceMode :=  GetRegSettings.SourceMode;
      lcConvert.BackupMode := GetRegSettings.BackupMode;
      lcConvert.Input := GetRegSettings.Input;

      // do it!
      lcConvert.Convert;
    finally
      lcConvert.Free;
    end;
  end;

  FreeAndNil(lcStatus);
end.