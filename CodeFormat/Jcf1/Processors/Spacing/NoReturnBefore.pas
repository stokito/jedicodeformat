{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoRetunrBefore.pas, released April 2000.
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

unit NoReturnBefore;

{ AFS 20 May 2K
  I saw some sample code this week where the programmer put a return before
  the 'then' keyword. Otherwise the code was good so we may employ that person
  better stop the rot before it begins
  - June 2K - we didn't employ him but the process remains
}


interface

uses TokenType, Token, TokenSource;

type

  TNoReturnBefore = class(TBufferedTokenProcessor)
  private
    fbSaveToRemoveReturn: boolean;

    function NoReturnBefore(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

    procedure OnFileStart; override;

  end;

implementation

uses
  { jcl } JclStrings,
  { local } WordMap, FormatFlags;

{ TNoReturnBefore }

constructor TNoReturnBefore.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

procedure TNoReturnBefore.OnFileStart;
begin
  inherited;
  fbSaveToRemoveReturn := True;
end;

function TNoReturnBefore.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.RemoveBadReturns;
end;

function TNoReturnBefore.IsTokenInContext(const pt: TToken): boolean;
begin
  // not safe to remove return at a comment like this
  if (pt.TokenType = ttComment) and (pt.CommentStyle = eDoubleSlash) then
    fbSaveToRemoveReturn := False
  else if (pt.TokenType <> ttReturn) then
    fbSaveToRemoveReturn := True;
  // safe again after the next return

  Result := (pt.TokenType = ttReturn) and fbSaveToRemoveReturn;
end;

function TNoReturnBefore.NoReturnBefore(const pt: TToken): boolean;
const
  NoReturnTokens: TTokenTypeSet = [ttAssign, ttOperator, ttColon, ttSemiColon];
  ProcNoReturnWords: TWordSet   = [wThen, wDo];
begin
  Result := False;

  if (pt.TokenType in NoReturnTokens) then
  begin
    Result := True;
    exit;
  end;

  { no return before then and do  in procedure body }
  if (pt.Word in ProcNoReturnWords) and (pt.ProcedureSection = psProcedureBody) then
  begin
    Result := True;
    exit;
  end;

  { no return in record def before the record keyword, likewise class & interface
    be carefull with the word 'class' as it also denotes (static) class fns. }
  if (pt.DeclarationSection = dsType) and (pt.Word in StructuredTypeWords) and
    (pt.ClassDefinitionSection in [cdNotInClassDefinition, cdHeader]) then
  begin
    Result := True;
    exit;
  end;
end;

function TNoReturnBefore.OnProcessToken(const pt: TToken): TToken;
var
  fcNext: TToken;
begin
  { inspect the next token }
  fcNext := FirstSolidToken;

  if NoReturnBefore(fcNext) then
  begin
    pt.Free;
    Result := RetrieveToken;
  end
  else
    Result := pt;
end;

end.