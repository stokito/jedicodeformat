unit WarnCaseNoElse;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TWarnCaseNoElse.pas, released July 2001.
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

{ AFS 20 June 2K
 warn of case without a default 'else' case

 This is often an error
 your program will be more error-proof if every case has an else
 if you can't think of anything to put there, put

 case
    ...
    else Raise Exception.Create('case had unexpected value');
 end;


}

interface

uses TokenType, Token, Warn;

type
  TWarnCaseNoElse = class(TWarn)
  private
  protected
    function OnProcessToken(const pt: TToken): TToken; override;

  public

  end;

implementation

uses
    { delphi } SysUtils,
    { local } WordMap;

function TWarnCaseNoElse.OnProcessToken(const pt: TToken): TToken;
var
  ltNext: TToken;
  lbEndFound, lbElseFound: boolean;
  liStartNest, liIndex: integer;
begin
  Result := pt;

  {  look for:
    - in procedure body
    - case
  }

  if not (pt.ProcedureSection = psProcedureBody) then
    exit;

  if pt.word = wCase then
  begin
    { look for the end }
    liStartNest := pt.NestingLevel + 1;
    lbEndFound  := False;
    lbElseFound := False;
    ltNext      := nil;
    liIndex     := 0;

    { look until the matching else is found or we run out of case }
    while (not lbEndFound) and (not lbElseFound) do
    begin
      ltNext := BufferTokens(liIndex);

      { abnormal end }
      if (ltNext.TokenType = ttEOF) or (ltNext.ProcedureSection = psNotInProcedure) then
        lbEndFound := True;

      { normal end }
      if (ltNext.word = wEnd) and (ltNext.NestingLevel = liStartNest) then
        lbEndFound := True;

      { else }
      if (ltNext.word = wElse) and (ltNext.NestingLevel = liStartNest) then
        lbElseFound := True;

      inc(liIndex);
    end;

    if not lbElseFound then
      LogWarning(ltNext, 'Case statement has no else case');
  end;
end;

end.
