unit WarnDestroy;

{ AFS 30 December 2002

 warn of calls to obj.destroy;
}


{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is WarnDestroy, released May 2003.
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

uses Warning, VisitParseTree;

type

  TWarnDestroy = class(TWarning)
    public
      procedure EnabledVisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult); override;
  end;

implementation

uses
  { delphi } SysUtils,
  { local } SourceToken, ParseTreeNodeType;

procedure TWarnDestroy.EnabledVisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult);
var
  lcToken: TSourceToken;
begin
  lcToken := TSourceToken(pcToken);

  { look in statements }
  if not lcToken.HasParentNode(nBlock) then
    exit;

  if AnsiSameText(lcToken.SourceCode, 'destroy') then
  begin
    SendWarning(lcToken, 'Destroy should not normally be called. ' +
        'You may want to use FreeAndNil(MyObj), or MyObj.Free, or MyForm.Release');
  end;

end;

end.