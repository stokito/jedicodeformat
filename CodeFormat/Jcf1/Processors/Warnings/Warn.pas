unit Warn;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Warn.pas, released July 2001.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 2001 Anthony Steele.
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

{ AFS 23 July 2001
  base class for all warnings }

interface

uses TokenSource;

type
  TWarn = class(TBufferedTokenProcessor)
  private
  protected
    function GetIsEnabled: boolean; override;

  public
    constructor Create; override;
  end;


implementation

uses FormatFlags;

constructor TWarn.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eWarning];
end;

function TWarn.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Clarify.Warnings;
end;

end.
