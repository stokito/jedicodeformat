unit TestDelphiNetRecordForward;

interface

type

  TRecord1 = record;
  TRecord2 = record;
  TRecord3 = record;

  TRecord1 = record
    foo: integer;
    bar: string;
    fish: double;

    rec: TRecord2;
  end;

  TRecord2 = record
    foo: integer;
    bar: string;
    fish: double;

    rec: TRecord3;
  end;

  TRecord3 = record
  end;


implementation

end.

