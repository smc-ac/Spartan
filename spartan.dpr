program Spartan;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  vEnv in 'src\var\vEnv.pas',
  bSpartan in 'src\bin\bSpartan.pas',
  vConst in 'src\var\vConst.pas',
  bFile in 'src\bin\bFile.pas',
  bDB in 'src\bin\bDB.pas',
  bFormatter in 'src\bin\bFormatter.pas',
  bHelper in 'src\bin\bHelper.pas',
  Model in 'src\Model\Model.pas';

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
