rem import pas files

del *.pas

copy ..\*.pas .

rem obfuscate in place

..\..\output\jcf -obfuscate -inplace -y -d . 



Rem clarify, make output files for all files in the dir, no confirmations

..\..\output\jcf -clarify -out -y -d . 
pause