{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TabToSpace.pas, released April 2000.
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

unit TabToSpace;

{ AFS 7 Dec 1999
  convert tabs to spaces }

interface

uses TokenType, Token, TokenSource;

type

  TTabToSpace = class(TTokenProcessor)
  private
    fsSpaces: string;
    fbInitialised: boolean;

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
  { delphi } SysUtils,
  { jcl } JclStrings,
  { local } FormatFlags;


constructor TTabToSpace.Create;
begin
  inherited;
  fbInitialised := False;
  fsSpaces := '';
  FormatFlags := FormatFlags + [eAddSpace];
end;

function TTabToSpace.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.TabsToSpaces;
end;

function TTabToSpace.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttWhiteSpace);
end;

procedure TTabToSpace.OnFileStart;
begin
  inherited;
  // reset the local var - setings may have changed
  fsSpaces := '';
  fbInitialised := False;
end;

function TTabToSpace.OnProcessToken(const pt: TToken): TToken;
var
  ls: string;
begin
  { set up spaces }
  if not fbInitialised then
  begin
    fsSpaces := StrRepeat(AnsiSpace, Settings.Spaces.SpacesPerTab);
    fbInitialised := True;
  end;

  { can't pass property as var parameter so ls local var is used }
  ls := pt.SourceCode;
  StrReplace(ls, AnsiTab, fsSpaces, [rfReplaceAll]);
  pt.SourceCode := ls;

  Result := pt;
end;

end.