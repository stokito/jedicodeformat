{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TokenProcessPipeline.pas, released April 2000.
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

unit TokenProcessPipeline;

{ AFS 4 Dec 1999
 all the token setup processors set up together
}

interface

uses TokenSource, Pipeline;

type

  TTokenProcessPipeline = class(TPipeline)
  private

  public
    constructor Create; override;

  end;

implementation

uses
    { setup }
  TokenContext, TokenBareIndent, CommentBreaker,
    { obfuscate }
  CommentEater, FixCase, RemoveIndent,
  WhiteSpaceEater, WhiteSpaceEater2,
  LineUnBreaker, LineReBreaker,
    { clarify}
  Position, Capitalisation, SpecificWordCaps, Replace,
  UsesClauseFindReplace, UsesClauseRemove, UsesClauseInsert,
  NoSpaceBefore, SingleSpaceBefore, SingleSpaceAfter, NoSpaceAfter,
  ReturnBefore, ReturnAfter, NoReturnBefore, NoReturnAfter,
  RemoveReturnsAfterBegin, RemoveReturnsBeforeEnd,
  RemoveBlankLinesInVars, RemoveBlankLinesAfterProcHeader,
  PropertyOnOneLine, SpaceBeforeColon,
  TabToSpace, SpaceToTab, ReturnChars,
  BlockStyles, LineBreaker,
  IndentProcedures, IndentGlobals, IndentUsesClause, IndentClassDef,

  AlignAssign, AlignConst, AlignTypeDef, AlignVars, AlignComment,

  { warnings }
  WarnRealType, WarnDestroy, WarnCaseNoElse, WarnEmptyBlock,
  WarnAssignToFunctionName;

    {!! onceoffs - used to fix a specific code problem
    ADOUsesClause, RemoveFromUses;

  MozComment; }

{ TTokenProcessPipeline }

constructor TTokenProcessPipeline.Create;
begin
  inherited;

  // setup
  Add(TTokenContext.Create);
  Add(TTokenBareIndent.Create);

  Add(TCommentBreaker.Create);


  // obfuscate process
  Add(TCommentEater.Create); // do this before the line-unbreaker
  Add(TLineUnbreaker.Create);
  Add(TFixCase.Create);
  Add(TRemoveIndent.Create);
  Add(TWhiteSpaceEater.Create);
  Add(TWhiteSpaceEater2.Create);
  Add(TLineRebreaker.Create);

  // clarify process


  Add(TCapitalisation.Create);
  Add(TSpecificWordCaps.Create);
  Add(TReplace.Create);
  Add(TUsesClauseFindReplace.Create);
  Add(TUsesClauseRemove.Create);
  Add(TUsesClauseInsert.Create);

  Add(TTabToSpace.Create);
  Add(TSpaceToTab.Create);
  Add(TReturnChars.Create);


  Add(TPosition.Create);
  Add(TReturnBefore.Create);
  Add(TPosition.Create);
  Add(TReturnAfter.Create);
  Add(TBlockStyles.Create);
  

  Add(TRemoveReturnsAfterBegin.Create);
  Add(TRemoveReturnsBeforeEnd.Create);
  Add(TRemoveBlankLinesInVars.Create);
  Add(TRemoveBlankLinesAfterProcHeader.Create);


  Add(TNoReturnBefore.Create);
  Add(TNoReturnAfter.Create);


  Add(TSingleSpaceBefore.Create);
  Add(TSingleSpaceAfter.Create);
  Add(TSpaceBeforeColon.Create);
  Add(TNoSpaceBefore.Create);
  Add(TNoSpaceAfter.Create);



  { these processes need fresh position values
    position must be recalculated after each as it could be messed up }
  Add(TPosition.Create);
  Add(TLineBreaker.Create);

  Add(TPosition.Create);
  Add(TIndentProcedures.Create);

  Add(TPosition.Create);
  Add(TIndentGlobals.Create);

  Add(TPosition.Create);
  Add(TIndentUsesClause.Create);

  Add(TPosition.Create);
  Add(TIndentClassDef.Create);

  Add(TPosition.Create);
  Add(TAlignAssign.Create);

  Add(TPosition.Create);
  Add(TAlignConst.Create);

  Add(TPosition.Create);
  Add(TAlignTypeDef.Create);

  Add(TPosition.Create);
  Add(TAlignVars.Create);

  Add(TPosition.Create);
  Add(TAlignComment.Create);

  { warners }
  Add(TPosition.Create);
  Add(TWarnRealType.Create);
  Add(TWarnDestroy.Create);
  Add(TWarnCaseNoElse.Create);
  Add(TWarnEmptyBlock.Create);
  Add(TWarnAssignToFunctionName.Create);

  { once-offs }
  //Add (TADOUsesClause.Create);
  //Add (TRemoveFromUses.Create);
  //Add(TMozComment.Create);


end;

end.