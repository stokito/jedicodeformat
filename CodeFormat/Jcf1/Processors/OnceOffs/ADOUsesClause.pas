{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ADOUsesClause.pas, released April 2000.
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

unit ADOUsesClause;

{ AFS 7 Jan 1999
  convert uses clause from Delphi 4 to Delphi 5 

  The idea is to turn references in uses clause
  from the units ADODB_TLB.pas and ADOR_TLB.pas to refs to adoint.pas
  }


interface

uses TokenType, Token, TokenSource;

type

  TADOUsesClause = class(TTokenProcessor)
  private
    bHasADO: boolean;

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
    { delphi}  SysUtils,
    { local} WordMap;

{ TADOUsesClause }

function IsOldUnit(psText: string): boolean;
begin
  Result := (AnsiCompareText(psText, 'ADODB_TLB') = 0) or
    (AnsiCompareText(psText, 'ADOR_TLB') = 0);
end;

constructor TADOUsesClause.Create;
begin
  inherited;
  bHasADO := False;
end;

function TADOUsesClause.GetIsEnabled: boolean;
begin
  Result := Settings.Clarify.OnceOffs;
end;

function TADOUsesClause.OnProcessToken(const pt: TToken): TToken;
begin
  Result := pt;

  if not bHasADO then
  begin
    { first instance, convert the name }
    bHasADO := True;
    Result.SourceCode := 'AdoInt';
  end
  else
  begin
    { following instances, throw away the word and the trailing comma }
    repeat
      Result.Free;
      Result := RetrieveToken;
    until (Result.TokenType <> ttComma) and (Result.TokenType <> ttWhiteSpace);
  end;
end;

procedure TADOUsesClause.OnFileStart;
begin
  inherited;

  { reset the flag at the top of each unit }
  bHasADO := False;
end;

function TADOUsesClause.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := False;

  { only do this in interface & implementation }
  if not (pt.FileSection in [fsInterface, fsImplementation]) then
    exit;

  { only do this in a uses clause }
  if not pt.InUsesClause then
    exit;

  { only proceed on one of the specifed words }
  if not (pt.TokenType = ttWord) then
    exit;

  if not (IsOldUnit(pt.SourceCode)) then
    exit;

  Result := True;
end;

end.