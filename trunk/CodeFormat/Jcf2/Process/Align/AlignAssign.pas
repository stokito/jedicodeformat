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

uses SourceToken, AlignBase;

type

  TAlignAssign = class(TAlignBase)
  private
    // don't align across block nexting levels
    fiStartBlockLevel: integer;
    fiStartCaseLevel: integer;
  protected
    { TokenProcessor overrides }
    function IsTokenInContext(const pt: TSourceToken): boolean; override;

      { AlignStatements overrides }
    function TokenIsAligned(const pt: TSourceToken): boolean; override;
    function TokenEndsStatement(const pt: TSourceToken): boolean; override;
    function TokenEndsAlignment(const pt: TSourceToken): boolean; override;

    procedure ResetState; override;
  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses
  { local}
  WordMap, FormatFlags, JcfSettings, TokenUtils,
  ParseTreeNodeType, TokenType;

{ TAlignAssign }


constructor TAlignAssign.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignAssign];
  fiStartBlockLevel := -1;
  fiStartCaseLevel := -1;
end;

procedure TAlignAssign.ResetState;
begin
  inherited;
  fiStartBlockLevel := -1;
  fiStartCaseLevel := -1;
end;


{ a token that ends an assign block }
function TAlignAssign.IsIncludedInSettings: boolean;
begin
  Result := (not FormatSettings.Obfuscate.Enabled) and FormatSettings.Align.AlignAssign;
end;

function TAlignAssign.IsTokenInContext(const pt: TSourceToken): boolean;
begin
  Result := InStatements(pt) and pt.HasParentNode(nAssignment);
end;

function TAlignAssign.TokenEndsStatement(const pt: TSourceToken): boolean;
begin
  { only look at solid tokens }
  if (pt.TokenType in [ttReturn, ttWhiteSpace]) then
  begin
    Result := False;
  end
  else
  begin
    Result := (pt.TokenType in [ttSemiColon, ttEOF, ttReservedWord]) or
    (not InStatements(pt));
  end;
end;

function TAlignAssign.TokenEndsAlignment(const pt: TSourceToken): boolean;
begin
  // ended by a blank line
  Result := IsBlankLineEnd(pt);
end;

function TAlignAssign.TokenIsAligned(const pt: TSourceToken): boolean;
begin
  { keep the indent - don't align statement of differing indent levels }
  if (fiStartBlockLevel < 0) and (pt.TokenType = ttAssign) then
    fiStartBlockLevel := BlockLevel(pt);

  if (fiStartCaseLevel < 0) and (pt.TokenType = ttAssign) then
    fiStartCaseLevel := CaseLevel(pt);

  Result := (pt.TokenType = ttAssign) and
    (fiStartBlockLevel = BlockLevel(pt)) and (fiStartCaseLevel = CaseLevel(pt));
end;

end.