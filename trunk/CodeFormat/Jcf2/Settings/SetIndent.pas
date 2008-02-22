{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SetIndent.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2008 Anthony Steele.
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

unit SetIndent;

interface

uses JCFSetBase, SettingsStream;

type

  TSetIndent = class(TSetBase)
  private
    fiIndentSpaces: integer;
    fiFirstLevelIndent: integer;
    fbHasFirstLevelIndent: boolean;

    fbIndentGlobals: boolean;
    fbIndentClasses: boolean;
    fbIndentProcedures: boolean;
    fbIndentBeginEnd: boolean;

    fiIndentBeginEndSpaces: integer;

    fbKeepCommentsWithCodeInProcs: boolean;
    fbKeepCommentsWithCodeInGlobals: boolean;
    fbKeepCommentsWithCodeInClassDef: boolean;
    fbKeepCommentsWithCodeElsewhere: boolean;
    fbIndentElse: Boolean;
    fbIndentCaseElse: Boolean;

  protected
  public
    constructor Create;

    procedure WriteToStream(const pcOut: TSettingsOutput); override;
    procedure ReadFromStream(const pcStream: TSettingsInput); override;

    function SpacesForIndentLevel(const piLevel: integer): integer;

    property IndentSpaces: integer Read fiIndentSpaces Write fiIndentSpaces;
    { first level can be indented differently }
    property FirstLevelIndent: integer Read fiFirstLevelIndent Write fiFirstLevelIndent;
    property HasFirstLevelIndent: boolean Read fbHasFirstLevelIndent
      Write fbHasFirstLevelIndent;

    property IndentGlobals: boolean Read fbIndentGlobals Write fbIndentGlobals;
    property IndentClasses: boolean Read fbIndentClasses Write fbIndentClasses;
    property IndentProcedures: boolean Read fbIndentProcedures Write fbIndentProcedures;

    property IndentBeginEnd: boolean Read fbIndentBeginEnd Write fbIndentBeginEnd;
    property IndentBeginEndSpaces: integer Read fiIndentBeginEndSpaces
      Write fiIndentBeginEndSpaces;

    property KeepCommentsWithCodeInProcs: boolean
      Read fbKeepCommentsWithCodeInProcs Write fbKeepCommentsWithCodeInProcs;
    property KeepCommentsWithCodeInGlobals: boolean
      Read fbKeepCommentsWithCodeInGlobals Write fbKeepCommentsWithCodeInGlobals;
    property KeepCommentsWithCodeInClassDef: boolean
      Read fbKeepCommentsWithCodeInClassDef Write fbKeepCommentsWithCodeInClassDef;
    property KeepCommentsWithCodeElsewhere: boolean
      Read fbKeepCommentsWithCodeElsewhere Write fbKeepCommentsWithCodeElsewhere;

    property IndentElse: boolean read fbIndentElse write fbIndentElse;
    property IndentCaseElse: boolean read fbIndentCaseElse write fbIndentCaseElse;

  end;

implementation

const
  REG_INDENTATION_SPACES = 'IndentationSpaces';

  REG_FIRST_LEVEL_INDENT     = 'FirstLevelIndent';
  REG_HAS_FIRST_LEVEL_INDENT = 'HasFirstLevelIndent';

  REG_INDENT_GLOBALS    = 'IndentGlobals';
  REG_INDENT_CLASSES    = 'IndentClasses';
  REG_INDENT_PROCEDURES = 'IndentProcedures';

  REG_INDENT_BEGIN_END = 'IndentBeginEnd';
  REG_INDENT_BEGIN_END_SPACES = 'IndentbeginEndSpaces';

  REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF  = 'KeepCommentsWithCodeInClassDef';
  REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS   = 'KeepCommentsWithCodeInProcs';
  REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS = 'KeepCommentsWithCodeInGlobals';
  REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE = 'KeepCommentsWithCodeElsewhere';

  REG_INDENT_ELSE = 'IndentElse';
  REG_INDENT_CASE_ELSE = 'IndentCaseElse';

constructor TSetIndent.Create;
begin
  inherited;
  SetSection('Indent');
end;

procedure TSetIndent.ReadFromStream(const pcStream: TSettingsInput);
begin
  Assert(pcStream <> nil);

  fiIndentSpaces := pcStream.Read(REG_INDENTATION_SPACES, 2);

  fiFirstLevelIndent    := pcStream.Read(REG_FIRST_LEVEL_INDENT, 2);
  fbHasFirstLevelIndent := pcStream.Read(REG_HAS_FIRST_LEVEL_INDENT, False);

  fbIndentGlobals    := pcStream.Read(REG_INDENT_GLOBALS, True);
  fbIndentClasses    := pcStream.Read(REG_INDENT_CLASSES, True);
  fbIndentProcedures := pcStream.Read(REG_INDENT_PROCEDURES, True);

  fbIndentBeginEnd := pcStream.Read(REG_INDENT_BEGIN_END, False);
  fiIndentBeginEndSpaces := pcStream.Read(REG_INDENT_BEGIN_END_SPACES, 1);

  fbKeepCommentsWithCodeInGlobals  :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS, True);
  fbKeepCommentsWithCodeInProcs    :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS, True);
  fbKeepCommentsWithCodeInClassDef :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF, True);
  fbKeepCommentsWithCodeElsewhere :=
    pcStream.Read(REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE, True);

  fbIndentElse := pcStream.Read(REG_INDENT_ELSE, False);
  fbIndentCaseElse := pcStream.Read(REG_INDENT_CASE_ELSE, True);

end;

procedure TSetIndent.WriteToStream(const pcOut: TSettingsOutput);
begin
  Assert(pcOut <> nil);

  pcOut.Write(REG_INDENTATION_SPACES, fiIndentSpaces);

  pcOut.Write(REG_FIRST_LEVEL_INDENT, fiFirstLevelIndent);
  pcOut.Write(REG_HAS_FIRST_LEVEL_INDENT, fbHasFirstLevelIndent);

  pcOut.Write(REG_INDENT_GLOBALS, fbIndentGlobals);
  pcOut.Write(REG_INDENT_CLASSES, fbIndentClasses);
  pcOut.Write(REG_INDENT_PROCEDURES, fbIndentProcedures);

  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_IN_GLOBALS, fbKeepCommentsWithCodeInGlobals);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_IN_PROCS, fbKeepCommentsWithCodeInProcs);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_CLASS_DEF, fbKeepCommentsWithCodeInClassDef);
  pcOut.Write(REG_KEEP_COMMENTS_WITH_CODE_ELSEWHERE, fbKeepCommentsWithCodeElsewhere);


  pcOut.Write(REG_INDENT_BEGIN_END, fbIndentBeginEnd);
  pcOut.Write(REG_INDENT_BEGIN_END_SPACES, fiIndentBeginEndSpaces);
  pcOut.Write(REG_INDENT_ELSE, fbIndentElse);
  pcOut.Write(REG_INDENT_CASE_ELSE, fbIndentCaseElse);
end;

function TSetIndent.SpacesForIndentLevel(const piLevel: integer): integer;
begin
  if piLevel <= 0 then
    Result := 0
  else if HasFirstLevelIndent then
    Result := FirstLevelIndent + ((piLevel - 1) * IndentSpaces)
  else
    Result := IndentSpaces * piLevel;
end;


end.
