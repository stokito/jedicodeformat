{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignAssign.pas, released April 2000.
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

unit AlignAssign;

{ AFS 3 Feb 2K
 Align the RHS of consecutive assign statements
}

interface

uses TokenType, Token, AlignStatements;

type

  TAlignAssign = class(TAlignStatements)
  private
    fiStartIndent: integer;
  protected
    { TokenProcessor overrides }
    function IsTokenInContext(const pt: TToken): boolean; override;
    function GetIsEnabled: boolean; override;

      { AlignStatements overrides }
    function TokenIsAligned(const pt: TToken): boolean; override;
    function TokenEndsStatement(const pt: TToken): boolean; override;

    procedure ResetState; override;
  public
    constructor Create; override;
  end;

implementation

uses
    { local} WordMap, FormatFlags;

{ TAlignAssign }


constructor TAlignAssign.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignAssign];
end;

procedure TAlignAssign.ResetState;
begin
  inherited;
  fiStartIndent := -1;
end;


{ a token that ends an assign block }
function TAlignAssign.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Align.AlignAssign;
end;

function TAlignAssign.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.ProcedureSection = psProcedureBody);
end;

function TAlignAssign.TokenEndsStatement(const pt: TToken): boolean;
begin
  Result := (pt.TokenType in [ttSemiColon, ttEOF, ttReservedWord]) or
    (pt.ProcedureSection <> psProcedureBody);

  // ended by a blank line
  if (pt.TokenType = ttReturn) and (pt.IndexOnLine <= 1) then
    Result := True;
end;

function TAlignAssign.TokenIsAligned(const pt: TToken): boolean;
begin
  { keep the indent - don't align statement of differing indent levels }
  if (fiStartIndent < 0) and (pt.TokenType = ttAssign) then
    fiStartIndent := pt.NestingLevel;

  Result := (pt.TokenType = ttAssign) and (fiStartIndent = pt.NestingLevel);
end;


end.