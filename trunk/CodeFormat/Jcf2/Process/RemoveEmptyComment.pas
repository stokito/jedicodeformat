unit RemoveEmptyComment;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is RemoveEmptyComment, released Nov 2003.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 2003 Anthony Steele.
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

{ AFS 9 Nov 2003
  Remove empty comments
}

uses SwitchableVisitor, VisitParseTree;

type
  TRemoveEmptyComment = class(TSwitchableVisitor)
  private
  protected
    procedure EnabledVisitSourceToken(const pcNode: TObject;
      var prVisitResult: TRVisitResult); override;
  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
  end;


implementation

uses
  SysUtils,
  JclStrings,
  FormatFlags, SourceToken, Tokens, TokenUtils, JcfSettings;


constructor TRemoveEmptyComment.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveComments];
end;

procedure TRemoveEmptyComment.EnabledVisitSourceToken(const pcNode: TObject;
  var prVisitResult: TRVisitResult);
var
  lcSourceToken: TSourceToken;
  lsCommentText: string;
begin
  lcSourceToken := TSourceToken(pcNode);

  case lcSourceToken.CommentStyle of
    eDoubleSlash:
    begin
      if FormatSettings.Comments.RemoveEmptyDoubleSlashComments then
      begin
        lsCommentText := StrAfter('//', lcSourceToken.SourceCode);
        lsCommentText := Trim(lsCommentText);
        if lsCommentText = '' then
          BlankToken(lcSourceToken);
      end;
    end;
    eCurlyBrace:
    begin
      if FormatSettings.Comments.RemoveEmptyCurlyBraceComments then
      begin
        lsCommentText := StrAfter('{', lcSourceToken.SourceCode);
        lsCommentText := StrBefore('}', lsCommentText);
        lsCommentText := Trim(lsCommentText);
        if lsCommentText = '' then
          BlankToken(lcSourceToken);
      end;
    end;
    eBracketStar, eCompilerDirective: ; // always leave these
    eNotAComment: ; // this is not a comment
    else
      // should not be here
      Assert(False);
  end;
end;

function TRemoveEmptyComment.IsIncludedInSettings: boolean;
begin
  Result := FormatSettings.Comments.RemoveEmptyDoubleSlashComments or
    FormatSettings.Comments.RemoveEmptyCurlyBraceComments;
end;

end.
