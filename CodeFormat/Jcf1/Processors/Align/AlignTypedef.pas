{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignTypedef.pas, released April 2000.
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

unit AlignTypedef;

{ AFS 12 Feb 2K
 Align the RHS of consecutive = signs in a typedef section 
}

interface

uses TokenType, Token, AlignStatements;

type

  TAlignTypeDef = class(TAlignStatements)
  private
  protected
    { TokenProcessor overrides }
    function IsTokenInContext(const pt: TToken): boolean; override;
    function GetIsEnabled: boolean; override;

      { AlignStatements overrides }
    function TokenIsAligned(const pt: TToken): boolean; override;
    function TokenEndsStatement(const pt: TToken): boolean; override;
  public
    constructor Create; override;
  end;

implementation

uses
  { local} WordMap, FormatFlags;

{ TAlignTypeDef }

constructor TAlignTypeDef.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignTypedef];
end;

{ a token that ends an type block }
function TAlignTypeDef.TokenEndsStatement(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection <> dsType) or
    (pt.TokenType in [ttSemiColon, ttEOF]);

  // ended by a blank line
  if (pt.TokenType = ttReturn) and (pt.IndexOnLine <= 1) then
    Result := True;
end;

function TAlignTypeDef.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Align.AlignTypeDef;
end;


function TAlignTypeDef.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection = dsType) and
    (pt.ClassDefinitionSection = cdNotInClassDefinition)  and
    ((not Settings.Align.InterfaceOnly) or (pt.FileSection = fsInterface));
end;

function TAlignTypeDef.TokenIsAligned(const pt: TToken): boolean;
begin
  Result := (pt.Word = wEquals);
end;

end.