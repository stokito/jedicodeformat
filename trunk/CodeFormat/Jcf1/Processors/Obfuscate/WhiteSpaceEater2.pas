{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is WhiteSpaceEater2.pas, released April 2000.
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

unit WhiteSpaceEater2;

{ AFS 24 Dec 1999
 an obfuscator
  - remove white space entirely where it is not needed

  for instance
    a := 3; b := 2;
  becomes
    a:=3;b:=2;
 }

interface

uses TokenType, Token, TokenSource;

type

  TWhiteSpaceEater2 = class(TBufferedTokenProcessor)
  private
    function NeedSpaceBetween(t1, t2: TToken): boolean;
    function OnlyOneText(t1, t2: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public

  end;

implementation

uses
    { delphi } SysUtils,
    { jcl } JclStrings;

function TextOrNumberString(const str: string): boolean;
var
  liLoop: integer;
  ch:     char;
begin
  Result := True;

  for liLoop := 1 to Length(str) do
  begin
    ch := str[liLoop];
    if not (CharIsAlphaNum(ch) or (ch = '_') or (ch = '.')) then
    begin
      Result := False;
      break;
    end;
  end;
end;


{ TWhiteSpaceEater2 }
function TWhiteSpaceEater2.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and Settings.Obfuscate.RemoveWhiteSpace;
end;

function TWhiteSpaceEater2.OnProcessToken(const pt: TToken): TToken;
var
  t0, t1: TToken;
begin
  t0 := BufferTokens(0);
  t1 := BufferTokens(1);

  while t0.TokenType = ttWhiteSpace do
    begin
      { white space in the middle - does it need to be there }
      if NeedSpaceBetween(pt, t1) then
      break
    else
    begin
      RemoveBufferToken(0);
      t0 := BufferTokens(0);
      t1 := BufferTokens(1);
    end;
  end;

  Result := pt;
end;

const
  MiscUnspacedTokens: TTokenTypeSet =
    [ttLiteralString, ttSemiColon, ttColon, ttComma, ttDot, ttAssign, ttReturn];

function TWhiteSpaceEater2.NeedSpaceBetween(t1, t2: TToken): boolean;
begin
  Result := True;

  { never need a space next to a bracket }
  if (t1.TokenType in BracketTokens) or (t2.TokenType in BracketTokens) then
  begin
    Result := False;
    exit;
  end;

  { or dot or comma etc }
  if (t1.TokenType in MiscUnspacedTokens) or (t2.TokenType in MiscUnspacedTokens) then
  begin
    Result := False;
    exit;
  end;

  { don't need white space next to white space }
  if (t1.TokenType = ttWhiteSpace) or (t2.TokenType = ttWhiteSpace) then
  begin
    Result := False;
    exit;
  end;

  { if one token is text, and the other not, don't need white space
   for this numbers count as text, for e.g.
   "for liLoop := 0to3do" is not valid, neither is "for liLoop := 0 to3 do",
   must be for liLoop := 0 to 3 do
   }

  if (t1.TokenType in TextOrNumberTokens) and not (t2.TokenType in TextOrNumberTokens)
    then
  begin
    Result := False;
    exit;
  end;

  {operators such as '<', '='  are counted as texual tokens
   no space betwen such an operator and a different token

   (unlike operators like 'in', 'is' which need a space between them & other words
  }


  if ((t1.TokenType = ttOperator) or (t2.TokenType = ttOperator)) and
    (t1.TokenType <> t2.TokenType) then
  begin
    if OnlyOneText(t1, t2) then
    begin
      Result := False;
      exit;
    end;
  end;
end;

function TWhiteSpaceEater2.OnlyOneText(t1, t2: TToken): boolean;
var
  b1, b2: boolean;
begin
  b1 := TextOrNumberString(t1.SourceCode);
  b2 := TextOrNumberString(t2.SourceCode);

  { one or the other, not both }
  Result := b1 xor b2;
end;


end.