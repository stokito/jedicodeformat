unit CommentBreaker;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is CommentBreaker.pas, released April 2000.
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

interface

{
  AFS 19 April 2K

  comments as they come put of the tokensiser
 stretch from one curly brace to the other (or / / or ( * * ) )
 this can be several lines long
 This is the only token that spans multiple lines
 This processor breaks it up so everyone can work on the assumtion
 that only a return token breaks lines,
 and that your position on the line is given
 by summing up the length of all the tokens since the last return token

 The resulting tokens are of type ttComment (and ttReturn)
}

uses TokenSource, Token;

type 
  TCommentBreaker = class(TBufferedTokenProcessor)
  private
  protected
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public

  end;

implementation

uses
    { jcl } JclStrings,
    { local } TokenType;

{ TCommentBreaker }

function TCommentBreaker.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := pt.TokenType = ttComment;
end;

function TCommentBreaker.OnProcessToken(const pt: TToken): TToken;
var
  liPos:       integer;
  lsRemainder: string;
  ptNew:       TToken;
begin
  Result := pt;

  { does the comment have a return? }
  liPos := Pos(AnsiCrLf, pt.SourceCode);
  if liPos <= 0 then
    exit;

  { stuff before the return }
  lsRemainder   := StrRestOf(pt.SourceCode, liPos + 2);
  pt.SourceCode := StrLeft(pt.SourceCode, liPos - 1);

  { the return on it's own }
  InsertTokenInBuffer(0, NewReturnToken);

  { the rest. Don't worry about multiple returns
   as the rest will be processed here soon enough }
  if lsRemainder = '' then
    exit;

  ptNew := TToken.Create;
  ptNew.TokenType := ttComment;
  ptNew.SourceCode := lsRemainder;
  ptNew.CopyContextFrom(pt); // same context as before
  InsertTokenInBuffer(1, ptNew);
end;

end.