unit TestConstRecords;

{ AFS 27 August 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit contains test cases for layout of const record declarations
}

interface


type
  TMap = record
    s1: string;
    i1: integer;
    i2: integer;
  end;

const
  THE_MAP: array [0..5] of TMap =
    ({ reserved words }
    (s1: 'Foo'; i1: 1; i2: 4),
    (s1: 'bar'; i1: 2; i2: 5),
    (s1: 'baz'; i1: 3; i2: 6),
    (s1: 'wibble'; i1: 4; i2: 7),
    (s1: 'fish'; i1: 5; i2: 8),
    (s1: 'spon'; i1: 6; i2: 9)
    );


  THE_POORLY_FORMATTED_MAP: array [0..5] of TMap =
    ({ reserved words }
    (s1: 'Foo';
    i1: 1; i2: 4),
    (s1: 'bar'; i1: 2;
    i2: 5), (s1: 'baz'; i1: 3; i2: 6), (s1: 'wibble'; i1:
  4; i2: 7), (s1:
  'fish'; i1: 5; i2: 8), (s1: 'spon';
  i1: 6; i2: 9));


  THE_LONG_STRING_MAP: array [0..3] of TMap =
    ({ reserved words }
    (s1: 'Foo was here. Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo'; i1: 1; i2: 4),
    (s1: 'bar moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo'; i1: 2;
    i2: 5),
    (s1: 'baz moo moo moo moo moo moo'; i1: 3; i2: 6), (s1: 'wibble moo moo moo moo'; i1: 4; i2: 7)
    );


implementation

end.
