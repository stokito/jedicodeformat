{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Capitalisation.pas, released April 2000.
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

unit Capitalisation;

{ AFS 2 Dec 1999
 first and simplest source code processor
  - fix capitalisation on reserved words

 }

interface

uses TokenType, Token, TokenSource;

type

  TCapitalisation = class(TTokenProcessor)
  private

    procedure FixCaps(pct: TToken; caps: TCapitalisationType);
  protected

    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses
    { delphi } SysUtils,
    { jcl } JclStrings,
    { local } FormatFlags;

{ TCapitalisation }


constructor TCapitalisation.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eCapsReservedWord];
end;

procedure TCapitalisation.FixCaps(pct: TToken; caps: TCapitalisationType);
begin
  if pct = nil then
    exit;
  if pct.SourceCode = '' then
    exit;

  case caps of
    ctUpper:
      pct.SourceCode := AnsiUpperCase(pct.SourceCode);
    ctLower:
      pct.SourceCode := AnsiLowerCase(pct.SourceCode);
    ctMixed:
      pct.SourceCode := StrSmartCase(pct.SourceCode, []);
    ctLeaveAlone:;
  end;
end;

function TCapitalisation.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Caps.Enabled;
end;

function TCapitalisation.OnProcessToken(const pt: TToken): TToken;
begin
  case pt.TokenType of
    ttReservedWord:
      FixCaps(pt, Settings.Caps.ReservedWords);
    ttReservedWordDirective:
    begin
      { directives can occur in other contexts - they are valid proc & variable names }
      if pt.IsDirective then
        FixCaps(pt, Settings.Caps.Directives);
    end;
    ttBuiltInConstant:
      FixCaps(pt, Settings.Caps.Constants);
    ttOperator:
      FixCaps(pt, Settings.Caps.Operators);
    ttBuiltInType:
      FixCaps(pt, Settings.Caps.Types);
  end;

  Result := pt;
end;

end.