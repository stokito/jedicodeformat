{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SetFile.pas, released April 2000.
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

unit SetFile;

{ settings to do with files
  AFS 29 Dec 1999
}

interface

uses
    { delphi  } classes,
    { local } JCFSetBase, TokenType, ConvertTypes, SettingsStream;

type

  TSetFile = class(TSetBase)
  private
  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteToStream(const pcOut: TSettingsOutput); override;
    procedure ReadFromStream(const pcStream: TSettingsInput); override;

  end;

implementation

uses
    { delphi } SysUtils,
    { jcl } JclStrings, JclFileUtils;



  { TSetFile }

constructor TSetFile.Create;
begin
  inherited;


  SetSection('File');
end;

destructor TSetFile.Destroy;
begin
  inherited;
end;

procedure TSetFile.ReadFromStream(const pcStream: TSettingsInput);
begin
  Assert(pcStream <> nil);

end;

procedure TSetFile.WriteToStream(const pcOut: TSettingsOutput);
begin
  Assert(pcOut <> nil);

end;

end.