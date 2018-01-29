unit vEnv;

interface

uses
  System.inifiles,
  System.sysutils,
  vConst,
  System.IOUtils,
  System.Types, bFormatter;

type

  TEnv = class

  public Type
    DB = class
      class function All: string; static;
      class function getDriver: string; static;
      class function getDatabase: string; static;
      class function getServer: string; static;
      class function getPort: string; static;
      class function getUser: string; static;
      class function getPassword: string; static;

      class procedure setDriver(value: string); static;
      class procedure setDatabase(value: string); static;
      class procedure setServer(value: string); static;
      class procedure setPort(value: string); static;
      class procedure setUser(value: string); static;
      class procedure setPassword(value: string); static;

      class property DRIVER: string read getDriver write setDriver;
      class property DATABASE: string read getDatabase write setDatabase;
      class property SERVER: string read getServer write setServer;
      class property USER: string read getUser write setUser;
      class property PORT: string read getPort write setPort;
      class property PASSWORD: string read getPassword write setPassword;
    end;

    System = class
    const
      Version = 'v1.0.5';
      class function exePath: string;
      class function ConfFile: TIniFile;
      class function getConfig: String;
      class function currentPath: string;
      class function Models: TStringDynArray;
      class function Controllers: TStringDynArray;
      class function DAOs: TStringDynArray;

    end;

  end;

var
  CONF_FULL_PATH: string;
  ALL_OPTION_SELECTED: boolean = false;

implementation

{ TEnv.DB }

class function TEnv.DB.All: string;
begin
  result := 'driver=' + TEnv.DB.DRIVER + slinebreak + 'database=' + TEnv.DB.DATABASE + slinebreak + 'server=' + TEnv.DB.SERVER + slinebreak + 'port=' + TEnv.DB.PORT + slinebreak +
    'user=' + TEnv.DB.USER;
end;

class function TEnv.DB.getDatabase: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'database', '');
end;

class function TEnv.DB.getDriver: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'driver', 'mysql');
end;

class function TEnv.DB.getPassword: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'password', '');
end;

class function TEnv.DB.getPort: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'port', '3306');
end;

class function TEnv.DB.getServer: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'server', 'localhost');
end;

class procedure TEnv.DB.setDatabase(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'database', value);
end;

class procedure TEnv.DB.setDriver(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'driver', lowercase(value));
end;

class procedure TEnv.DB.setPassword(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'password', value);
end;

class procedure TEnv.DB.setPort(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'port', value);
end;

class procedure TEnv.DB.setServer(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'server', value);
end;

class procedure TEnv.DB.setUser(value: string);
begin
  TEnv.System.ConfFile.writestring('database', 'user', value);
end;

class function TEnv.DB.getUser: string;
begin
  result := TEnv.System.ConfFile.readString('database', 'user', 'root');
end;

{ TEnv.System }

class function TEnv.System.ConfFile: TIniFile;
begin
  if CONF_FULL_PATH = '' then
    CONF_FULL_PATH := tconst.getConfFile;

  if not fileexists(CONF_FULL_PATH) then
    raise Exception.Create('Configuration file "' + CONF_FULL_PATH + '" not found!' + slinebreak + ' Run "spartan stare ." to recriate file.');

  result := TIniFile.Create(CONF_FULL_PATH);
end;

class function TEnv.System.getConfig: string;
begin
  result := 'Database Configuration:' + slinebreak + TEnv.DB.All;
end;

class function TEnv.System.Models: TStringDynArray;
begin
  result := TDirectory.getfiles(TEnv.System.currentPath + tconst.model);
end;

class function TEnv.System.Controllers: TStringDynArray;
begin
  result := TDirectory.getfiles(TEnv.System.currentPath + tconst.controller);
end;

class function TEnv.System.currentPath: string;
begin
  result := GetCurrentDir + '\';
end;

class function TEnv.System.DAOs: TStringDynArray;
begin
  result := TDirectory.getfiles(TEnv.System.currentPath + tconst.DAO);
end;

class function TEnv.System.exePath: string;
begin
  result := ExtractFilePath(ParamStr(0));
end;

end.
