{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is frCapsSettings.pas, released April 2000.
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

unit frReservedCapsSettings;

interface

uses
    { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
    { local }
  SettingsFrame, ComCtrls;

type
  TfrReservedCapsSettings = class(TfrSettingsFrame)
    cbEnable: TCheckBox;
    rgReservedWords: TRadioGroup;
    rgOperators: TRadioGroup;
    rgTypes: TRadioGroup;
    rgConstants: TRadioGroup;
    rgDirectives: TRadioGroup;
    procedure cbEnableClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;

    procedure Read; override;
    procedure Write; override;

  end;

implementation

{$R *.DFM}

uses TokenType, JcfHelp;

constructor TfrReservedCapsSettings.Create(AOwner: TComponent);
begin
  inherited;
  fiHelpContext := HELP_CAPITALISATION;
end;

procedure TfrReservedCapsSettings.cbEnableClick(Sender: TObject);
begin
  rgReservedWords.Enabled := cbEnable.Checked;
  rgConstants.Enabled     := cbEnable.Checked;
  rgDirectives.Enabled    := cbEnable.Checked;
  rgOperators.Enabled     := cbEnable.Checked;
  rgTypes.Enabled         := cbEnable.Checked;
end;

procedure TfrReservedCapsSettings.Read;
begin
  cbEnable.Checked := Settings.Caps.Enabled;

  with Settings.Caps do
  begin
    rgReservedWords.ItemIndex := Ord(ReservedWords);
    rgConstants.ItemIndex     := Ord(Constants);
    rgDirectives.ItemIndex    := Ord(Directives);
    rgOperators.ItemIndex     := Ord(Operators);
    rgTypes.ItemIndex         := Ord(Types);
  end;
end;

procedure TfrReservedCapsSettings.Write;
begin
  Settings.Caps.Enabled := cbEnable.Checked;

  with Settings.Caps do
  begin
    ReservedWords := TCapitalisationType(rgReservedWords.ItemIndex);
    Constants     := TCapitalisationType(rgConstants.ItemIndex);
    Directives    := TCapitalisationType(rgDirectives.ItemIndex);
    Operators     := TCapitalisationType(rgOperators.ItemIndex);
    Types         := TCapitalisationType(rgTypes.ItemIndex);
  end;
end;


end.
