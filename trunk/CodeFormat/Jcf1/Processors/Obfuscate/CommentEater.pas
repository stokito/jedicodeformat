{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is CommentEater.pas, released April 2000.
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

unit CommentEater;

{ AFS 24 Dec 1999
 an obfuscator
  - remove all comments. I felt I had to write it as it was so very simple.
  But anyway use with care and keep backups or use Source Control


  AFS 8 MAY fixed for changed comment scheme - long comments are split up now
}

interface

uses TokenType, Token, TokenSource;

type

  TCommentEater = class(TBufferedTokenProcessor)
  private
    function MustLeaveComment(pc: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
  end;

implementation

uses
    { delphi } SysUtils,
    { jcl } JclStrings,
    { local } FormatFlags;

{ TCommentEater }
function TCommentEater.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and Settings.Obfuscate.RemoveComments;
end;

function TCommentEater.MustLeaveComment(pc: TToken): boolean;
var
  lsPrefix: string;
begin
  Result := False;

  lsPrefix := StrLeft(pc.SourceCode, 2);
  if (lsPrefix = '{$') or (lsPrefix = '{%') then
    Result := True;

  { all curly backets in the uses clause of a program/library def
   must be respected as they link files to dfms, com classes 'n stuff }
  if (pc.CommentStyle = eCurly) and
    (pc.FileSection in ProgramDefSections) and pc.InUsesClause then
    Result := True;

  { these comments are flags to the code format program, so leave them }
  if (pc.SourceCode = '{(*}') or (pc.SourceCode = '{*)}') then
    Result := True;

  // these are also flags
  if ((pc.CommentStyle = eDoubleSlash) and
    (StrLeft(pc.SourceCode, FORMAT_COMMENT_PREFIX_LEN) = FORMAT_COMMENT_PREFIX)) then
    Result := True;

end;

function TCommentEater.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttComment) and (not MustLeaveComment(pt));
end;

function TCommentEater.OnProcessToken(const pt: TToken): TToken;
var
  ltNext: TToken;
begin
  { lose the comment }
  pt.Free;

  { is it followed by a return and another comment? if so, lose them too }
  while True do
  begin
    ltNext := BufferTokens(0);

    if not (ltNext.TokenType  in [ttReturn, ttComment]) then
      break;

    if (ltNext.TokenType = ttComment) and (MustLeaveComment(ltNext)) then
      break;

    { if we get here, then ltNext is a comment-ending return or a discardable comment
      discard it }
    RemoveBufferToken(0);
  end;

  Result := RetrieveToken;
end;

end.