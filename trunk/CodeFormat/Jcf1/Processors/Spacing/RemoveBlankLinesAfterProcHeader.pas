unit RemoveBlankLinesAfterProcHeader;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is RemoveBlankLinesAfterProcHeader.pas, released September 2001.
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

uses Token, TokenSource;

type 
  TRemoveBlankLinesAfterProcHeader = class(TBufferedTokenProcessor)
  private
  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses WordMap, TokenType, FormatFlags;

{ TRemoveBlankLinesAfterProcHeader }

constructor TRemoveBlankLinesAfterProcHeader.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

function TRemoveBlankLinesAfterProcHeader.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.RemoveProcHeaderBlankLines;
end;

function TRemoveBlankLinesAfterProcHeader.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.ProcedureSection in [psProcedureDeclarations, psProcedureDirectives]);
end;

function TRemoveBlankLinesAfterProcHeader.OnProcessToken(const pt: TToken): TToken;
var
  liLoop, liMax: integer;
  ptNext:        TToken;
  lbFirstReturn: boolean;
begin
  Result := pt;

  { find the index of the next solid token }
  liMax  := 0;
  ptNext := BufferTokens(liMax);
  while ptNext.TokenType in [ttWhiteSpace, ttReturn] do
  begin
    inc(liMax);
    ptNext := BufferTokens(liMax);
  end;

  { it must be a 'var', 'const', 'type' or 'begin'
   in the procedure defs/body section }

  { don't remove blank lines before a contained fn or proc }
  if not (ptNext.Word in [wVar, wConst, wBegin, wType]) then
    exit;

  if not (ptNext.ProcedureSection in [psProcedureDeclarations, psProcedureBody]) then
    exit;

  lbFirstReturn := True;
  { remove all returns up to that point (except one) }
  for liLoop := liMax - 1 downto 0 do
  begin
    ptNext := BufferTokens(liLoop);
    if (ptNext.TokenType = ttReturn) then
    begin
      if (not lbFirstReturn) then
        RemoveBufferToken(liLoop);
      lbFirstReturn := False;
    end;
  end;
end;

end.
