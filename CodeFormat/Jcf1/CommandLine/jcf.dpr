program jcf;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Converter in '..\ReadWrite\Converter.pas',
  FileConverter in '..\ReadWrite\FileConverter.pas',
  ConvertTypes in '..\Types\ConvertTypes.pas',
  Reader in '..\ReadWrite\Reader.pas',
  JclStrings in '..\..\External\JCL\Source\JclStrings.pas',
  JclFileUtils in '..\..\External\JCL\Source\JclFileUtils.pas',
  JclBase in '..\..\External\JCL\Source\JclBase.pas',
  JclResources in '..\..\External\JCL\Source\JclResources.pas',
  JclSysInfo in '..\..\External\JCL\Source\JclSysInfo.pas',
  JclSysUtils in '..\..\External\JCL\Source\JclSysUtils.pas',
  JclWin32 in '..\..\External\JCL\Source\JclWin32.pas',
  JclRegistry in '..\..\External\JCL\Source\JclRegistry.pas',
  JclSecurity in '..\..\External\JCL\Source\JclSecurity.pas',
  JclShell in '..\..\External\JCL\Source\JclShell.pas',
  Writer in '..\ReadWrite\Writer.pas',
  IntList in '..\Types\IntList.pas',
  Pipeline in '..\Types\Pipeline.pas',
  Token in '..\Types\Token.pas',
  TokenSource in '..\Types\TokenSource.pas',
  TokenType in '..\Types\TokenType.pas',
  WordMap in '..\Types\WordMap.pas',
  JCFLog in '..\Utils\JCFLog.pas',
  JCFSettings in '..\Settings\JCFSettings.pas',
  SetAnyWordCaps in '..\Settings\SetAnyWordCaps.pas',
  JCFSetBase in '..\Settings\JCFSetBase.pas',
  SetCaps in '..\Settings\SetCaps.pas',
  SetClarify in '..\Settings\SetClarify.pas',
  SetFile in '..\Settings\SetFile.pas',
  SetIndent in '..\Settings\SetIndent.pas',
  SetLog in '..\Settings\SetLog.pas',
  SetObfuscate in '..\Settings\SetObfuscate.pas',
  SetReplace in '..\Settings\SetReplace.pas',
  SetAlign in '..\Settings\SetAlign.pas',
  Tokeniser in '..\TokenCreation\Tokeniser.pas',
  TokenBareIndent in '..\TokenCreation\TokenBareIndent.pas',
  TokenContext in '..\TokenCreation\TokenContext.pas',
  CommentBreaker in '..\TokenCreation\CommentBreaker.pas',
  TokenProcessPipeline in '..\Processors\TokenProcessPipeline.pas',
  LineBreaker in '..\Processors\LineBreaker.pas',
  Position in '..\Processors\Position.pas',
  Replace in '..\Processors\Transform\Replace.pas',
  SpecificWordCaps in '..\Processors\SpecificWordCaps.pas',
  Capitalisation in '..\Processors\Capitalisation.pas',
  AlignVars in '..\Processors\Align\AlignVars.pas',
  AlignConst in '..\Processors\Align\AlignConst.pas',
  AlignStatements in '..\Processors\Align\AlignStatements.pas',
  AlignTypedef in '..\Processors\Align\AlignTypedef.pas',
  AlignAssign in '..\Processors\Align\AlignAssign.pas',
  IndentUsesClause in '..\Processors\Indent\IndentUsesClause.pas',
  Indenter in '..\Processors\Indent\Indenter.pas',
  IndentGlobals in '..\Processors\Indent\IndentGlobals.pas',
  IndentProcedures in '..\Processors\Indent\IndentProcedures.pas',
  IndentClassDef in '..\Processors\Indent\IndentClassDef.pas',
  WhiteSpaceEater2 in '..\Processors\Obfuscate\WhiteSpaceEater2.pas',
  FixCase in '..\Processors\Obfuscate\FixCase.pas',
  LineRebreaker in '..\Processors\Obfuscate\LineRebreaker.pas',
  LineUnbreaker in '..\Processors\Obfuscate\LineUnbreaker.pas',
  RemoveIndent in '..\Processors\Obfuscate\RemoveIndent.pas',
  WhiteSpaceEater in '..\Processors\Obfuscate\WhiteSpaceEater.pas',
  CommentEater in '..\Processors\Obfuscate\CommentEater.pas',
  TabToSpace in '..\Processors\Spacing\TabToSpace.pas',
  NoReturnAfter in '..\Processors\Spacing\NoReturnAfter.pas',
  NoReturnBefore in '..\Processors\Spacing\NoReturnBefore.pas',
  NoSpaceAfter in '..\Processors\Spacing\NoSpaceAfter.pas',
  NoSpaceBefore in '..\Processors\Spacing\NoSpaceBefore.pas',
  RemoveReturnsAfterBegin in '..\Processors\Spacing\RemoveReturnsAfterBegin.pas',
  RemoveReturnsBeforeEnd in '..\Processors\Spacing\RemoveReturnsBeforeEnd.pas',
  ReturnAfter in '..\Processors\Spacing\ReturnAfter.pas',
  ReturnBefore in '..\Processors\Spacing\ReturnBefore.pas',
  SingleSpaceAfter in '..\Processors\Spacing\SingleSpaceAfter.pas',
  SingleSpaceBefore in '..\Processors\Spacing\SingleSpaceBefore.pas',
  BlockStyles in '..\Processors\Spacing\BlockStyles.pas',
  WarnRealType in '..\Processors\Warnings\WarnRealType.pas',
  WarnDestroy in '..\Processors\Warnings\WarnDestroy.pas',
  WarnEmptyBlock in '..\Processors\Warnings\WarnEmptyBlock.pas',
  WarnCaseNoElse in '..\Processors\Warnings\WarnCaseNoElse.pas',
  SetUses in '..\Settings\SetUses.pas',
  UsesClauseFindReplace in '..\Processors\Transform\UsesClauseFindReplace.pas',
  UsesClauseRemove in '..\Processors\Transform\UsesClauseRemove.pas',
  UsesClauseInsert in '..\Processors\Transform\UsesClauseInsert.pas',
  SpaceToTab in '..\Processors\Spacing\SpaceToTab.pas',
  MiscFunctions in '..\Utils\MiscFunctions.pas',
  RemoveBlankLinesInVars in '..\Processors\Spacing\RemoveBlankLinesInVars.pas',
  PropertyOnOneLine in '..\Processors\Spacing\PropertyOnOneLine.pas',
  SpaceBeforeColon in '..\Processors\Spacing\SpaceBeforeColon.pas',
  Warn in '..\Processors\Warnings\Warn.pas',
  FileReader in '..\ReadWrite\FileReader.pas',
  FileWriter in '..\ReadWrite\FileWriter.pas',
  FormatFlags in '..\Types\FormatFlags.pas',
  JclDateTime in '..\..\External\JCL\source\JclDateTime.pas',
  SetSpaces in '..\Settings\SetSpaces.pas',
  SetReturns in '..\Settings\SetReturns.pas',
  SetUi in '..\Settings\SetUi.pas',
  RemoveBlankLinesAfterProcHeader in '..\Processors\Spacing\RemoveBlankLinesAfterProcHeader.pas',
  ReturnChars in '..\Processors\Spacing\ReturnChars.pas',
  WarnAssignToFunctionName in '..\Processors\Warnings\WarnAssignToFunctionName.pas',
  SettingsStream in '..\Settings\Streams\SettingsStream.pas',
  RegistrySettings in '..\Settings\Streams\RegistrySettings.pas',
  AlignComment in '..\Processors\Align\AlignComment.pas';

const
  ABOUT_COMMANDLINE =
  'Jedi Code Format V' + PROGRAM_VERSION + AnsiLineBreak +
  ' A Delphi Object-Pascal Source code formatter' + AnsiLineBreak  +
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
  ' -? Display this help' + AnsiLineBreak + AnsiLineBreak +
  ' A GUI version of this program is also available' + AnsiLineBreak +
  ' Latest version at http://users.iafrica/com/a/as/asteele/delphi/codeformat';

var
  fcSettings: TSettings;

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
      fcSettings.ReadFromFile(fsConfigFileName);
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
    fcSettings.FileSettings.SourceMode := feCmdLineSourceMode;
  if fbHasBackupMode then
    fcSettings.FileSettings.BackupMode := feCmdLineBackupMode;

  if not fbCmdLineShowHelp then
  begin
    if fcSettings.FileSettings.SourceMode = fmSingleFile then
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

  fcSettings.FileSettings.Input := lsPath;
  fcSettings.Obfuscate.Enabled := fbCmdLineObfuscate;
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

begin
  fcSettings := TSettings.Create;
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
      lcConvert.Settings := fcSettings;
      lcConvert.OnStatusMessage := lcStatus.OnReceiveStatusMessage;
      // use command line settings
      lcConvert.YesAll := fbYesAll;
      lcConvert.GuiMessages := False;


      // do it!
      lcConvert.Convert;
    finally
      lcConvert.Free;
    end;
  end;

  FreeAndNil(fcSettings);
  FreeANdNil(lcStatus);
end.
