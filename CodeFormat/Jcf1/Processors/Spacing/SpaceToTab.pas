{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SpaceToTab.pas, released April 2000.
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

unit SpaceToTab;

{ AFS 14 October 2000
  convert spaces to tabs }

interface

uses TokenType, Token, TokenSource;

type

  TSpaceToTab = class(TTokenProcessor)
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

constructor TSpaceToTab.Create;
begin
  inherited;
  fbInitialised := False;
  fsSpaces := '';
  FormatFlags := FormatFlags + [eRemoveSpace];
end;

function TSpaceToTab.GetIsEnabled: Boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.SpacesToTabs;
end;

procedure TSpaceToTab.OnFileStart;
begin
  inherited;
  // reset the local var - setings may have changed
  fsSpaces := '';
  fbInitialised := False;
end;

function TSpaceToTab.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttWhiteSpace);
end;

function TSpaceToTab.OnProcessToken(const pt: TToken): TToken;
var
  ls, lsTab: string;
begin
  { set up spaces }
  if not fbInitialised then
  begin
    fsSpaces := StrRepeat(AnsiSpace, Settings.Spaces.SpacesForTab);
    fbInitialised := True;
  end;

  { can't pass property as var parameter so ls local var is used }
  ls := pt.SourceCode;
  lsTab := AnsiTab;
  StrReplace(ls, fsSpaces, lsTab, [rfReplaceAll]);
  pt.SourceCode := ls;

  Result := pt;
end;

end.
