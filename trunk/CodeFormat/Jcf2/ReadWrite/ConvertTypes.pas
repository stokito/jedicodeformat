{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ConvertTypes.pas, released April 2000.
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

unit ConvertTypes;

interface

{ settings on how to convert
  this unit is simple type defs with no dependencies 
}
type
  TBackupMode = (cmInPlace, cmInPlaceWithBackup, cmSeperateOutput);
  TSourceMode = (fmSingleFile, fmDirectory, fmDirectoryRecursive);

type
  TStatusMessageProc = procedure(const ps: string) of object;


type
  TShowParseTreeOption = (eShowAlways, eShowOnError, eShowNever);

const
  REG_ROOT_KEY = '\Software\Jedi\JediCodeFormat';

const
  SOURCE_FILE_FILTERS =
    'Delphi source (*.pas, *.dpr, *.dpk)|*.pas; *.dpr; *.dpk|' +
    'Text files (*.txt)|*.txt|' +
    'All files (*.*)|*.*';

  CONFIG_FILE_FILTERS =
    'Config files (*.cfg)|*.cfg|' +
    'Text files (*.txt)|*.txt|' +
    'All files (*.*)|*.*';

implementation

end.


