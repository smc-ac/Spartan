unit vConst;

interface

type
  TConst = class
  public const

    APP_NAME = 'Spartan';

    CONF_FILE = 'lambda.ini';

    CONTROLLER = 'Controller\';
    MODEL = 'Model\';
    DAO = 'DAO\';
    VIEW = 'View\';

    PAS = '.pas';

    GITIGNORE_FILE = '.gitignore';
    GITIGNORE_CONTENT = '# Delphi local files'+
                        '__history/'    + slinebreak +
                        '*.dproj.local' + slinebreak +
                        '*.res'         + slinebreak +
                        '*.skincfg'     + slinebreak +
                        'Win32/'        + slinebreak +
                        '*.identcache'  + slinebreak +
                        '*.tvsconfig'   + slinebreak;

    CONTROLLER_FILE = CONTROLLER + 'Controller' + PAS;
    MODEL_FILE = MODEL + 'Model' + PAS;
    DAO_FILE = DAO + 'DAO' + PAS;

    SOLDIERS: array [0 .. 3] of string = (
      '-v',
      '-c',
      'stare',
      'push'
    );

    SOLDIERS_HELP: array [0 .. 3] of string = (
      'Show framework version.',
      'Read framework configurations stored in ' + TConst.CONF_FILE + ' file.',
      'Start a new Spartan application. [ name ]',
      'Construct the base files using your configuration set. [ model | controller | dao ] '
    );

    PUSH_OPTIONS: array [0 .. 2] of string = (
      'model',
      'controller',
      'dao'
    );

    class function getConfFile: string;

  Type
    Project = class
      class function MainController: string;
      class function MainModel: string;
      class function MainDao: string;
    end;

    System = class
      class function MainController: string;
      class function MainModel: string;
      class function MainDao: string;
    end;
  end;

implementation

{ TConst }
uses vEnv;

class function TConst.getConfFile: string;
begin
  result := Tenv.System.currentPath + CONF_FILE;
end;

{ TConst.Project }

class function TConst.Project.MainController: string;
begin
  result := Tenv.System.currentPath + CONTROLLER_FILE;
end;

class function TConst.Project.MainDao: string;
begin
  result := Tenv.System.currentPath + DAO_FILE;
end;

class function TConst.Project.MainModel: string;
begin
  result := Tenv.System.currentPath + MODEL_FILE;
end;

{ TConst.System }

class function TConst.System.MainController: string;
begin
     result := Tenv.System.exePath + CONTROLLER_FILE;
end;

class function TConst.System.MainDao: string;
begin
     result := Tenv.System.exePath + DAO_FILE;
end;

class function TConst.System.MainModel: string;
begin
     result := Tenv.System.exePath + MODEL_FILE;
end;

end.
