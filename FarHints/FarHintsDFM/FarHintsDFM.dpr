{$I Defines.inc} { ��. ����� \AppFar\FarHintsDFM\DefApp.Pas }

{$ifdef bDelphi}
 {$E hll}
{$endif bDelphi}

{$ImageBase $403C0000}

library FarHintsDFM;

{$I Defines1.inc}

uses
  SystemLight,
 {$ifdef bTrace}
  MSCheck,
 {$endif bTrace}
  FarHintsDFMMain;

exports
  GetPluginInterface;

{$R *.RES}

end.
