program Spartan;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  vEnv in 'var\vEnv.pas',
  bSpartan in 'bin\bSpartan.pas',
  vConst in 'var\vConst.pas',
  bFile in 'bin\bFile.pas',
  dDB in 'DAO\dDB.pas',
  bFormatter in 'bin\bFormatter.pas',
  bHelper in 'bin\bHelper.pas';

begin
  try
    TSpartan.raiseArmy;
  except
    on e: exception do
    begin
      Writeln('Error starting ', TCONST.APP_NAME, ' command line:');
      Writeln('');
      Writeln(e.Message);
    end;
  end;

end.
