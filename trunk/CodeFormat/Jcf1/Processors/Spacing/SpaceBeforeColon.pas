unit SpaceBeforeColon;
{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SpaceAfterColon.pas, released February 2001.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 2001 Anthony Steele.
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

{ to introduce that formatting option of spaces before colons

  todo: configure where this applies (proc vars, global vars, class vars, params, fn return types )
  and how many spaces 
}

uses TokenType, Token, TokenSource;

type

  TSpaceBeforeColon = class(TBufferedTokenProcessor)
  private

    function SpacesBefore(const pt: TToken): integer;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses
  { jcl } JclStrings,
  { local } WordMap, SetSpaces, FormatFlags;


constructor TSpaceBeforeColon.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddSpace, eRemoveSpace];
end;

function TSpaceBeforeColon.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) // and Settings.Spaces.SpaceBeforeColon;
end;

function TSpaceBeforeColon.SpacesBefore(const pt: TToken): integer;
var
  lcSpaces: TSetSpaces;
begin
  Assert(pt.TokenType = ttColon);

  lcSpaces := Settings.Spaces;

  if pt.ProcedureSection = psProcedureDefinition then
  begin
    if (pt.BracketLevel > 0) then
      Result := lcSpaces.SpacesBeforeColonParam
    else
      Result := lcSpaces.SpacesBeforeColonFn;
  end
  else if pt.ProcedureSection = psProcedureDeclarations then
  begin
    Result := lcSpaces.SpacesBeforeColonVar;
  end
  else if pt.ProcedureSection = psProcedureBody then
  begin
    if pt.CaseLabelNestingLevel then
      Result := lcSpaces.SpacesBeforeColonCaseLabel
    else
      Result := lcSpaces.SpacesBeforeColonLabel;
  end
  else if (pt.ClassDefinitionSection <> cdNotInClassDefinition) then
    Result := lcSpaces.SpacesBeforeColonClass
  else if pt.DeclarationSection in [dsVar, dsConst] then
    Result :=  lcSpaces.SpacesBeforeColonVar
  { proc/function type def }
  else if (pt.DeclarationSection = dsType) and (pt.RHSEquals) then
  begin
    if (pt.BracketLevel > 0) then
      Result := lcSpaces.SpacesBeforeColonParam
    else
      Result := lcSpaces.SpacesBeforeColonFn;
  end
  else if (pt.DeclarationSection = dsType) then
    Result := lcSpaces.SpacesBeforeColonVar
  else
  begin
    Result := 0;
    // assertion failure brings the house down Assert(False, 'No context for colon');
    Log.LogError('No context for colon at ' + FilePlace(pt) + ', using zero spaces');
  end;
end;

function TSpaceBeforeColon.OnProcessToken(const pt: TToken): TToken;
var
  fcNext1, fcNext2, fcNew: TToken;
  liSpaces: integer;
  ls: string;
begin
  { inspect the next 2 tokens }
  fcNext1 := BufferTokens(0);
  fcNext2 := BufferTokens(1);

  Result := pt;

  if fcNext2.TokenType <> ttColon then
    exit;

  liSpaces := SpacesBefore(fcNext2);

  if liSpaces > 0 then
  begin
    ls := StrRepeat(AnsiSpace, liSpaces);

    { modify the existing space, or make a new one? }
    if (fcNext1.TokenType = ttWhiteSpace) then
      fcNext1.SourceCode := ls
    else
    begin
      fcNew := TToken.Create;
      fcNew.TokenType := ttWhiteSpace;
      fcNew.SourceCode := ls;
      InsertTokenInBuffer(1, fcNew);
    end;
  end
  else
  begin
    { remove the space }
    if (fcNext1.TokenType = ttWhiteSpace) then
      RemoveBufferToken(0);
  end;
end;

end.
