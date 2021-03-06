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

{ settings on how to convert }
type
  TBackupMode = (cmInPlace, cmInPlaceWithBackup, cmSeperateOutput);
  TSourceMode = (fmSingleFile, fmDirectory, fmDirectoryRecursive);

type
  TStatusMessageProc = procedure(const ps: string) of object;

const
  PROGRAM_VERSION = '0.65';
  PROGRAM_DATE = 'January 2003';
  PROGRAM_HOME_PAGE = 'http://jedicodeformat.sourceforge.net';

implementation

end.