unit TestDelphi2009Generics;

interface

uses Generics.Collections;

implementation

function TestList: integer;
var
  liList: TList<integer>;
begin
  liList := TList<integer>.Create();

  liList.Add(12);
  liList.Add(24);
  liList.Add(48);

  result := liList.Count;
end;

end.
