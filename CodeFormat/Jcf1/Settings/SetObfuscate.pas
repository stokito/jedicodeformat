{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SetObfuscate.pas, released April 2000.
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

unit SetObfuscate;

{ settings to do with code obfuscation
  AFS 29 Dec 1999
}

interface

uses
  { local } JCFSetBase, TokenType, SettingsStream;

type

  TSetObfuscate = class(TSetBase)
  private
    fbEnabled: boolean;
    feCaps: TCapitalisationType;
    fbRemoveComments: boolean;
    fbRemoveWhiteSpace: boolean;
    fbRemoveIndent: boolean;
    fbRebreakLines: boolean;
  protected

  public
    constructor Create;

    procedure WriteToStream(const pcOut: TSettingsOutput); override;
    procedure ReadFromStream(const pcStream: TSettingsInput); override;

    property Enabled: boolean read fbEnabled write fbEnabled;

    property Caps: TCapitalisationType read feCaps write feCaps;

    property RemoveComments: boolean read fbRemoveComments write fbRemoveComments;
    property RemoveWhiteSpace: boolean read fbRemoveWhiteSpace write fbRemoveWhiteSpace;
    property RemoveIndent: boolean read fbRemoveIndent write fbRemoveIndent;
    property RebreakLines: boolean read fbRebreakLines write fbRebreakLines;

  end;

implementation

const
  { obfuscation settings }
  REG_ENABLED = 'Enabled';

  REG_CAPS = 'Caps';
  REG_REMOVE_COMMENTS = 'RemoveComments';
  REG_REMOVE_WHITESPACE = 'RemoveWhiteSpace';
  REG_REMOVE_INDENT = 'RemoveIndent';
  REG_REBREAK_LINES = 'RebreakLines';


  { TSetObfuscate }

constructor TSetObfuscate.Create;
begin
  inherited;
  SetSection('Obfuscate');
end;

procedure TSetObfuscate.ReadFromStream(const pcStream: TSettingsInput);
begin
  Assert(pcStream <> nil);

  fbEnabled := pcStream.Read(REG_ENABLED, False);

  feCaps := TCapitalisationType(pcStream.Read(REG_CAPS, Ord(ctLower)));

  fbRemoveComments   := pcStream.Read(REG_REMOVE_COMMENTS, True);
  fbRemoveWhiteSpace := pcStream.Read(REG_REMOVE_WHITESPACE, True);
  fbRemoveIndent     := pcStream.Read(REG_REMOVE_INDENT, True);
  fbRebreakLines     := pcStream.Read(REG_REBREAK_LINES, True);
end;

procedure TSetObfuscate.WriteToStream(const pcOut: TSettingsOutput);
begin
  Assert(pcOut <> nil);

  pcOut.Write(REG_ENABLED, fbEnabled);
  pcOut.Write(REG_CAPS, Ord(feCaps));
  pcOut.Write(REG_REMOVE_COMMENTS, fbRemoveComments);
  pcOut.Write(REG_REMOVE_WHITESPACE, fbRemoveWhiteSpace);
  pcOut.Write(REG_REMOVE_INDENT, fbRemoveIndent);
  pcOut.Write(REG_REBREAK_LINES, fbRebreakLines);

end;

end.