{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is FixCase.pas, released April 2000.
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

unit FixCase;

{ AFS 24 Dec 1999
 first and simplest obfuscator
  - fix capitalisation on all words

 }

interface

uses TokenType, Token, TokenSource;

type

  TFixCase = class(TTokenProcessor)
  private
    procedure FixCaps(const pt: TToken);
    function PutUpWithCompilerBugs(const pt: TToken): boolean;
  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

  end;

implementation

uses
    { delphi } SysUtils,
    { local} jclStrings;

{ TFixCase }

constructor TFixCase.Create;
begin
  inherited;
end;

procedure TFixCase.FixCaps(const pt: TToken);
begin
  if PutUpWithCompilerBugs(pt) then
    exit;

  case Settings.Obfuscate.Caps of
    ctUpper:
      pt.SourceCode := AnsiUpperCase(pt.SourceCode);
    ctLower:
      pt.SourceCode := AnsiLowerCase(pt.SourceCode);
    ctMixed:
      pt.SourceCode := StrSmartCase(pt.SourceCode, []);
    ctLeaveAlone:;
  end;
end;

function TFixCase.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and (Settings.Obfuscate.Caps <> ctLeaveAlone);
end;

function TFixCase.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType in TextualTokens) and (pt.SourceCode <> '');
end;

function TFixCase.OnProcessToken(const pt: TToken): TToken;
begin
  FixCaps(pt);
  Result := pt;
end;

function TFixCase.PutUpWithCompilerBugs(const pt: TToken): boolean;
begin
  Result := False;

  { special case - 'Register' (with a capital R) as a procedure name must be preserved
    or component registration may not work in some versions of Delphi
    This is a known issue in some versions of Delphi
    note intentional use of case-sensitive compare }
  if (pt.TokenType = ttWord) and
    AnsiSameStr(pt.SourceCode, 'Register') and
    (pt.ProcedureSection = psProcedureDefinition) then
  begin
    Result := True;
    exit;
  end;

  { had problems - IDE could not find the base class frame
    when the frame's ancestor's name was decapitised
    most likely some lazy developer @ borland forgot to match strings without case}
  if (pt.TokenType = ttWord) and
    (pt.ClassDefinitionSection = cdHeritage) and
    (pt.StructuredType = stClass) then
  begin
    Result := True;
    exit;
  end;
end;

end.