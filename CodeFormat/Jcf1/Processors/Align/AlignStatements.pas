{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignStatements.pas, released April 2000.
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

unit AlignStatements;

{ AFS 6 Feb 2K
  base class Generalisation of AlignAssign and co.
  This is the base class for all aligners
}

interface

uses TokenType, Token, TokenSource;

type

  TAlignStatements = class(TBufferedTokenProcessor)
  private

    procedure AlignTheBlock;
    procedure IndentAll(piTokens, piIndent: integer);

  protected
    fbKeepComments: Boolean;

    function OnProcessToken(const pt: TToken): TToken; override;

      { API for descendant classes }
    function TokenIsAligned(const pt: TToken): boolean; virtual; abstract;
    function TokenEndsStatement(const pt: TToken): boolean; virtual; abstract;

      { override this to let the child class see the tokens as they come
      this is used by the align vars to detect the first non-white space token after the : }

    procedure OnTokenRead(const pt: TToken); virtual;
    procedure ResetState; virtual;

  public
    constructor Create; override;

    procedure OnFileStart; override;

  end;

implementation

uses
    { delphi } SysUtils, Math,
    { jcl } JclStrings;

{ TAlignStatements }

constructor TAlignStatements.Create;
begin
  inherited;
  ResetState;
  fbKeepComments := False;
end;


function TAlignStatements.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);

  if TokenIsAligned(lcNext) then
    AlignTheBlock;
end;


procedure TAlignStatements.AlignTheBlock;
var
  liCurrent, liLastKnownAlignedStatement: integer;
  lcCurrent: TToken;
  bDone, bThisStatementIsAligned: boolean;
  liMaxIndent, liMinIndent: integer;
  liThisIndent: integer;
  liSettingsMin, liSettingsMax, liSettingsMaxVariance: integer;

  liUnalignedCount, liMaxUnaligned: integer;
begin
  ResetState;

  lcCurrent := BufferTokens(0);
  Assert(TokenIsAligned(lcCurrent));
  OnTokenRead(lcCurrent);

  liLastKnownAlignedStatement := 0;
  liMaxIndent                 := lcCurrent.XPosition;
  liMinIndent                 := liMaxIndent;

  { locate statement end
   BufferTokens(0) is the first :=
   there must be a semicolon soon after }

  liCurrent := 0;
  repeat
    inc(liCurrent);
    lcCurrent := BufferTokens(liCurrent);
    OnTokenRead(lcCurrent);
  until TokenEndsStatement(lcCurrent);
  inc(liCurrent); { liCurrent is the index of a statement ender so move past it }

  { end the first statement on EOF?! - abort! }
  if lcCurrent.TokenType = ttEOF then
    exit;

  with Settings do
  begin
    liSettingsMin := Align.MinColumn;
    liSettingsMax := Align.MaxColumn;
    liSettingsMaxVariance := Align.MaxVariance;
    liMaxUnaligned := Align.MaxUnalignedStatements;
  end;

  { locate block end - include all consecutive aligned statements }
  bDone := False;
  liUnalignedCount := 0;
  
  bThisStatementIsAligned := False;
  while not bDone do
  begin
    lcCurrent := BufferTokens(liCurrent);
    OnTokenRead(lcCurrent);
    { EOF?! - abort! }
    if lcCurrent.TokenType = ttEOF then
      bDone := True
    else
    begin
      { an aligned statement has the aligned token in it -
        e.g. an assign statement has a ':=' in it :) }
      if TokenIsAligned(lcCurrent) then
      begin
        bThisStatementIsAligned := True;

        liThisIndent := lcCurrent.XPosition;

        if liThisIndent >= liSettingsMin then
          liMinIndent := Min(liThisIndent, liMinIndent);

        { store the higest indent in liMaxIndent
          unless it is out of bounds, ie < liSettingsMin or > liSettingsMax }
        liThisIndent := Max(liThisIndent, liSettingsMin);
        if (liThisIndent > liMaxIndent) and (liThisIndent < liSettingsMax) and
          (liThisIndent <= liMinIndent + liSettingsMaxVariance) then
          liMaxIndent := liThisIndent;

        { may need to knock down the min if the first one is an outlier }
        if (liThisIndent + liSettingsMaxVariance) < liMaxIndent then
          liMaxIndent := liThisIndent;

      end;
      { carry on through comments - not valid anymore ??
        Why didn't I explain why this was in?
        May be of use on some of the aligners so it has been make a setting

        Use only where the comment is first solid token on line ?
         (ie not of enline comments)
      }
      if fbKeepComments and (lcCurrent.TokenType = ttComment) then
        bThisStatementIsAligned := True;

      if TokenEndsStatement(lcCurrent) then
      begin
        { ending a statement - was it an aligned one?
          If not, maybe we should have stopped with the last statement }

        if bThisStatementIsAligned then
        begin
          liLastKnownAlignedStatement := liCurrent;
          liUnalignedCount := 0;
          bThisStatementIsAligned     := False;
        end
        else
        begin
          { look for consecutive unaligned statements to end the aligned block
            depending on the config, this could be just 1 unalaigned statement
            or it could be more
          }
          inc(liUnalignedCount);
          if liUnalignedCount > liMaxUnaligned then
            bDone := True;
        end;
      end;

      inc(liCurrent);
    end; { not EOF }
  end; { while loop }

  { set iResume equal to the block end token }
  fiResume := BufferTokens(liLastKnownAlignedStatement).TokenIndex;

  { now we know how far to go and how far to indent, do it }
  if liLastKnownAlignedStatement > 0 then
    IndentAll(liLastKnownAlignedStatement, liMaxIndent);

  ResetState;
end;

procedure TAlignStatements.IndentAll(piTokens, piIndent: integer);
var
  liLoop: integer;
  lcCurrent, lcNew: TToken;
begin
  ResetState;

  liLoop := 0;
  while liLoop <= piTokens do
  begin
    lcCurrent := BufferTokens(liLoop);
    OnTokenRead(lcCurrent);

    if TokenIsAligned(lcCurrent) and (lcCurrent.XPosition < piIndent) then
    begin
      { indent to the specified level  - make a new space token }
      lcNew := NewToken(ttWhiteSpace);
      lcNew.SourceCode := StrRepeat(' ', (piIndent - lcCurrent.XPosition));
      InsertTokenInBuffer(liLoop, lcNew);
      { list just got longer - move the end marker }
      inc(piTokens);
      inc(liLoop);
    end;

    inc(liLoop);
  end;
end;

procedure TAlignStatements.OnFileStart;
begin
  inherited;
  ResetState;
end;



procedure TAlignStatements.OnTokenRead(const pt: TToken);
begin
  // do nothing - here to be overridden
end;

procedure TAlignStatements.ResetState;
begin
  // do nothing - here to be overridden
end;

end.