unit NoReturnBefore;

{ AFS 11 Jan 2003
  Some tokens should not have a return before them for fomatting
}

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoReturnBefore, released May 2003.
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

uses SwitchableVisitor;

type
  TNoReturnBefore = class(TSwitchableVisitor)
  private
    fbSafeToRemoveReturn: boolean;

  protected
    function EnabledVisitSourceToken(const pcNode: TObject): Boolean; override;

  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses SourceToken, TokenUtils, Tokens, ParseTreeNodeType,
  JcfSettings, FormatFlags;

function HasNoReturnBefore(const pt: TSourceToken): boolean;
const
  NoReturnTokens: TTokenTypeSet    = [ttAssign, ttColon, ttSemiColon];
  ProcNoReturnWords: TTokenTypeSet = [ttThen, ttDo];
begin
  Result := False;

  if pt = nil then
    exit;

  if pt.HasParentNode(nAsm) then
    exit;

  if (pt.TokenType in NoReturnTokens + Operators) then
  begin
    Result := True;
    exit;
  end;

  { no return before then and do  in procedure body }
  if (pt.TokenType in ProcNoReturnWords) and InStatements(pt) then
  begin
    Result := True;
    exit;
  end;

  { no return in record def before the record keyword, likewise class & interface
    be carefull with the word 'class' as it also denotes (static) class fns. }
  if pt.HasParentNode(nTypeDecl) and (pt.TokenType in StructuredTypeWords) and
    ( not pt.HasParentNode(nClassVisibility)) then
  begin
    Result := True;
    exit;
  end;

  // guid in interface
  if (pt.TokenType = ttCloseSquareBracket) and
    pt.HasParentNode(nInterfaceTypeGuid, 1) then
  begin
    Result := True;
    exit;
  end;


  // "foo in  Foo.pas, " has return only after the comma
  if InFilesUses(pt) then
  begin
    if (pt.TokenType in [ttComma, ttWord, ttQuotedLiteralString]) or
      ((pt.TokenType = ttComment) and (pt.CommentStyle in CURLY_COMMENTS)) then
    begin
      Result := True;
      exit;
    end;
  end;
end;

constructor TNoReturnBefore.Create;
begin
  inherited;
  fbSafeToRemoveReturn := True;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

function TNoReturnBefore.EnabledVisitSourceToken(const pcNode: TObject): Boolean;
var
  lcSourceToken: TSourceToken;
  lcNext, lcNextComment: TSourceToken;
begin
  Result := False;
  lcSourceToken := TSourceToken(pcNode);

  // not safe to remove return at a comment like this
  if (lcSourceToken.TokenType = ttComment) and
    (lcSourceToken.CommentStyle = eDoubleSlash) then
    fbSafeToRemoveReturn := False
  else if (lcSourceToken.TokenType <> ttReturn) then
    fbSafeToRemoveReturn := True;
  // safe again after the next return

  if (lcSourceToken.TokenType = ttReturn) and fbSafeToRemoveReturn then
  begin
    lcNext := lcSourceToken.NextSolidToken;

    if HasNoReturnBefore(lcNext) then
    begin
      { must still check for the case of
          try
            Statement;
          except
            // a comment
            ;
          end;

      -- the return before the comment should not be removed

      This does not hold in a program files uses clause
      }
      lcNextComment := lcSourceToken.NextTokenWithExclusions([ttWhiteSpace, ttReturn]);
      if (lcNextComment <> nil) and
        ((lcNextComment.TokenType <> ttComment) or (InFilesUses(lcNextComment))) then
        BlankToken(lcSourceToken);
    end;
  end;
end;

function TNoReturnBefore.IsIncludedInSettings: boolean;
begin
  Result := FormatSettings.Returns.RemoveBadReturns;
end;

end.
