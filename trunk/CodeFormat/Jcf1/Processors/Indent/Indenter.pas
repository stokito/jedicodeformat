{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Indenter.pas, released April 2000.
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

unit Indenter;

{ AFS 18 Feb 2000
  Base class for indentation processors }

interface

uses TokenSource, Token;

type
  TIndenter = class(TBufferedTokenProcessor)

  protected
    procedure IncreaseIndent(const pc: TToken; piHowMuch: integer);
    procedure DecreaseIndent(const pc: TToken; piHowMuch: integer);
    procedure IndentToken(const pcCurrent, pcNext: TToken);

    function GetDesiredIndent(const pc: TToken): integer; virtual; abstract;

  public
    constructor Create; override;

  end;

implementation

uses
    { delphi } SysUtils,
    { jcl }  JclStrings,
    { local } TokenType, FormatFlags;


constructor TIndenter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eIndent];
end;

procedure TIndenter.IncreaseIndent(const pc: TToken; piHowMuch: integer);
var
  lsNewText:  string;
  lcNewToken: TToken;
begin
  lsNewText := StrRepeat(' ', piHowMuch);

  if pc.TokenType = ttWhiteSpace then
  begin
    pc.SourceCode := pc.SourceCode + lsNewText;
  end
  else
  begin
    // make white space
    lcNewToken := TToken.Create;
    lcNewToken.TokenType := ttWhiteSpace;
    lcNewToken.SourceCode := lsNewText;
    AddTokenToFrontOfBuffer(lcNewToken);
  end;
end;

procedure TIndenter.DecreaseIndent(const pc: TToken; piHowMuch: integer);
var
  lsNewText:  string;
  lcNewToken: TToken;
  liSpaces:   integer;
begin
  if pc.TokenType = ttWhiteSpace then
  begin
    lsNewText     := StrRepeat(' ', Length(pc.SourceCode) - piHowMuch);
    pc.SourceCode := lsNewText;
  end
  else
  begin
    // make return + white space
    AddTokenToFrontOfBuffer(NewReturnToken);

    liSpaces := pc.XPosition - piHowMuch;
    if liSpaces > 0 then
    begin
      lcNewToken := TToken.Create;
      lcNewToken.TokenType := ttWhiteSpace;
      lsNewText  := StrRepeat(' ', liSpaces);
      lcNewToken.SourceCode := lsNewText;
      AddTokenToFrontOfBuffer(lcNewToken);
    end;
  end;
end;


{ indent the token pcNext, if need be by inserting tokens before it
  (between pcCurrent and pcNext)
}

procedure TIndenter.IndentToken(const pcCurrent, pcNext: TToken);
var
  liDesiredIndent: integer;
begin
  liDesiredIndent := GetDesiredIndent(pcNext);

  { to get nesting errors }
  if (liDesiredIndent < 0) then
  begin
    Log.LogError('Bad indent level of ' + IntToStr(liDesiredIndent) +
      ' on Token ' + pcNext.Describe);
    liDesiredIndent := 0;
  end;

  { pass on pcCurrent - if pcNext is the first token on the line,
    then pcCurrent may be white space (if any). Best case is to just adjust the # of chars in it  }

  if pcNext.XPosition > liDesiredIndent then
    DecreaseIndent(pcCurrent, (pcNext.XPosition - liDesiredIndent))
  else if pcNext.XPosition < liDesiredIndent then
    IncreaseIndent(pcCurrent, (liDesiredIndent - pcNext.XPosition));

  fiResume := pcNext.TokenIndex + 1;
end;


end.