{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignVars.pas, released April 2000.
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

unit AlignVars;

{ AFS 12 Feb 2K
 Align the RHS of var types
}

interface

uses TokenType, Token, AlignStatements;

type

  TFoundTokenState = (eBefore, eOn, eAfter, eUnknown);

  TAlignVars = class(TAlignStatements)
  private
    feFoundTokenState: TFoundTokenState;

  protected
    { TokenProcessor overrides }
    function IsTokenInContext(const pt: TToken): boolean; override;
    function GetIsEnabled: boolean; override;

      { AlignStatements overrides }
    function TokenIsAligned(const pt: TToken): boolean; override;
    function TokenEndsStatement(const pt: TToken): boolean; override;

    procedure OnTokenRead(const pt: TToken); override;
    procedure ResetState; override;

  public
    constructor Create; override;

  end;

implementation

uses
  { local} WordMap, FormatFlags;

{ TAlignVars }

constructor TAlignVars.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignVars];
end;

function AlignedToken(ptt: TtokenType): boolean;
const
  NOT_ALIGNED: TTokenTypeSet = [ttWhiteSpace, ttReturn, ttComment, ttSemiColon, ttColon];
begin
  Result := not (ptt in NOT_ALIGNED);
end;

procedure TAlignVars.OnTokenRead(const pt: TToken);
begin
  inherited;

  { when we get the colon, we are now *before* the target token
   on the next on-whitespace token we are *on* it,
   any token after that, we are *after* it
    unknown status is there to match the very first token in the block }

  if pt.TokenType = ttColon then
    feFoundTokenState := eBefore
  else if AlignedToken(pt.TokenType) and
    (feFoundTokenState in [eUnknown, eBefore]) then
    feFoundTokenState := eOn
  else if feFoundTokenState = eOn then
    feFoundTokenState := eAfter
  else if feFoundTokenState = eUnknown then
    feFoundTokenState := eBefore;
end;

procedure TAlignVars.ResetState;
begin
  feFoundTokenState := eUnknown;
end;

function TAlignVars.TokenEndsStatement(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection <> dsVar) or
    (pt.TokenType in [ttSemiColon, ttEOF]);

  // ended by a blank line
  if (pt.TokenType = ttReturn) and (pt.IndexOnLine <= 1) then
    Result := True;
end;

function TAlignVars.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection = dsVar) and (pt.BracketLevel < 1) and
    ((not Settings.Align.InterfaceOnly) or (pt.FileSection = fsInterface));
end;

function TAlignVars.TokenIsAligned(const pt: TToken): boolean;
begin
  { the local var feFoundTokenState is used to recognise the first token after the colon }

  Result := pt.RHSColon and
    (feFoundTokenState in [eOn, eUnknown]) and AlignedToken(pt.TokenType);

  if Result and (pt.RecordCount > 0) then
    Result := False;

  if Result and (pt.BracketLevel > 0) then
    Result := False;

end;

function TAlignVars.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Align.AlignVar;
end;


end.