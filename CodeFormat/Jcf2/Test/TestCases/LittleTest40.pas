unit LittleTest40;

interface

implementation

procedure Foo;
begin
  asm
@foo_@bar_:

    MOV     ECX,(type TInitContext)/4

    LEA     EDI,[EBP- (type foo) - (type foo)]

    MOV     FS:[EAX],ECX

    LEA     ESI,[EAX] + offset foo

    FMUL    qword ptr [EBX] + offset foo

    INC     EDX
    AND     [EAX],CH
  end

end;

end.
