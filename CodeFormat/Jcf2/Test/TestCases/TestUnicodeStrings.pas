﻿unit TestUnicodeStrings;
{ AFS Jan 2009

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests unicode strings
}


interface

const
  MixedString: string = 'English للغة العربية 中文 中文简体 ウェブ全体から検索';
  MixedStringNoType = 'English للغة العربية 中文 中文简体 ウェブ全体から検索';

  EnglishString = 'An English string';
  ArabicString: string = 'للغة العربية';
  EasternString: string = '中文 中文简体 ウェブ全体から検索';


implementation

end.
