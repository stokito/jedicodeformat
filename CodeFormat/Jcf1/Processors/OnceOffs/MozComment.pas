{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is MozComment.pas, released April 2000.
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

unit MozComment;

{ AFS 24 march 2K
 The Mozilla public licence requires that all files include a header comment
 that specifies the licence.

 Right now, my files don't
 The easiest way to fix that, is this code below:
}

interface

uses TokenType, Token, TokenSource;

type
  TMozComment = class(TBufferedTokenProcessor)
  private
    bHasMoz: boolean;
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
    { local } WordMap;

const
  STR_RETURN = #13 + #10;

  { this comment will be inserted in all files above the unit header }

  MozURL = 'http://www.mozilla.org/NPL/';

  MozCommentString: string =
    NOFORMAT_ON + STR_RETURN + // so this program can't easily obfuscate it out
    '(*------------------------------------------------------------------------------' +
    STR_RETURN +
    ' Delphi Code formatter source code ' + STR_RETURN + STR_RETURN +
    'The Original Code is <FileName>, released <Date>.' + STR_RETURN +
    'The Initial Developer of the Original Code is Anthony Steele. ' + STR_RETURN +
    'Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.' +
    STR_RETURN +
    'All Rights Reserved. ' + STR_RETURN +
    'Contributor(s): Anthony Steele. ' + STR_RETURN + STR_RETURN +
    'The contents of this file are subject to the Mozilla Public License Version 1.1' +
    STR_RETURN +
    '(the "License"). you may not use this file except in compliance with the License.' +
    STR_RETURN +
    'You may obtain a copy of the License at ' + MozURL + STR_RETURN + STR_RETURN +
    'Software distributed under the License is distributed on an "AS IS" basis,' +
    STR_RETURN +
    'WITHOUT WARRANTY OF ANY KIND, either express or implied.' + STR_RETURN +
    'See the License for the specific language governing rights and limitations ' +
    STR_RETURN +
    'under the License.' + STR_RETURN +
    '------------------------------------------------------------------------------*)' +
    STR_RETURN + NOFORMAT_OFF + STR_RETURN + STR_RETURN;


  { TMozComment }

constructor TMozComment.Create;
begin
  inherited;
  bHasMoz := False;
end;

function TMozComment.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Clarify.OnceOffs;
end;

function TMozComment.IsTokenInContext(const pt: TToken): boolean;
const
  UnitStart: TWordSet = [wUnit, wProgram, wLibrary];
begin
  Result := ((pt.Word in UnitStart) or (pt.TokenType = ttComment)) and not bHasMoz;
end;

procedure TMozComment.OnFileStart;
begin
  inherited;
  bHasMoz := False;
end;

function TMozComment.OnProcessToken(const pt: TToken): TToken;
var
  lsFile:    string;
  lsComment: string;
begin
  if (pt.TokenType = ttComment) then
  begin
    { check for existing Moz. comment
     Any comment with the Moz. licence URL is assumed to be it }

    if Pos(MozURL, pt.SourceCode) > 0 then
      bHasMoz := True;

    Result := pt;
  end
  else
  begin
    { get the file name but remove the path
      This will be inserted into the standard comment string
    }

    lsFile := ExtractFileName(OriginalFileName);

    AddTokenToFrontOfBuffer(pt);

    lsComment := MozCommentString;
    lsComment := StringReplace(lsComment, '<FileName>', lsFile, [rfReplaceAll]);
    lsComment := StringReplace(lsComment, '<Date>', FormatDateTime('mmmm yyyy', Date),
      [rfReplaceAll]);

    // put the comment in front of the unit start word
    Result  := NewToken(ttComment);
    Result.SourceCode := lsComment;
    bHasMoz := True;
  end;
end;

end.