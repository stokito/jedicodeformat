unit SettingsTypes;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is SettingsTypes.pas, released June 2003.
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

// types and constants used in settings

{ can stop and restart formating using these comments
 from DelForExp - Egbbert Van Nes's program }
const
  NOFORMAT_ON  = '{(*}';
  NOFORMAT_OFF = '{*)}';

  NOFORMAT_ON_2  = '//jcf:format=off';
  NOFORMAT_OFF_2 = '//jcf:format=on';


type
  TCapitalisationType = (ctUpper, ctLower, ctMixed, ctLeaveAlone);

type
 { return after Then and other strategic places? }
  TBlockNewLineStyle = (eAlways, eLeave, eNever);



{ what to do with return characters (Cr or CrLf)
  1) leave them as is
  2) turn to Lf
  3) turn to CrLf
  4) pick 2 or 3 depending on the Host OS, preference, ie CrLf for win, cr for 'nix
}
type
  TReturnChars = (rcLeaveAsIs, rcLinefeed, rcCrLf, rcPlatform);


implementation

end.