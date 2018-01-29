unit dDB;

interface

uses Firedac.comp.client, Firedac.Phys.MySQL, Firedac.UI.Intf,
  Firedac.comp.dataset, Firedac.comp.UI,
  types, winapi.windows,
  Firedac.stan.Option, Firedac.dapt, Firedac.stan.def,
  Data.DB, vEnv, system.sysutils, Firedac.stan.async;

type
  TDB = class
  private

  class var
    connection: TFDConnection;
    waitCursor: TFDGUIxWaitCursor;

  public
    class function execute(pSql: string): tfdquery; overload;
    class function execute(pSql: string; arr_params: array of variant): tfdquery; overload;

    class function listTables: TStringDynArray;

    class function getConnection: TFDConnection;

  end;

implementation

{ TDB }

class function TDB.execute(pSql: string): tfdquery;
begin
  TDB.execute(pSql, []);
end;

class function TDB.execute(pSql: string; arr_params: array of variant): tfdquery;
var
  i: integer;
begin
  result := tfdquery.Create(nil);
  with result do
  begin
    connection := getConnection;
    active := false;
    close;
    sql.Clear;
    sql.Add(pSql);
    for i := Low(arr_params) to High(arr_params) do
      params[i].value := arr_params[i];
    if lowercase(copy(pSql, 1, 6)) = 'select' then
    begin
      open;
      active := True;
      FetchAll;
      if recordcount = 0 then
        result := nil;
    end
    else
      ExecSQL;
  end;
end;

class function TDB.getConnection: TFDConnection;
begin
  if connection = nil then
  begin

    connection := TFDConnection.Create(nil);

    with connection do
    begin

      Connected := false;
      params.BeginUpdate;
      params.Clear;
      params.endUpdate;

      ResourceOptions.AutoReconnect := false;
      params.BeginUpdate;

      LoginPrompt := false;
      params.Values['Server'] := tenv.DB.Server;
      params.Values['Port'] := tenv.DB.Port;
      params.Values['Database'] := tenv.DB.Database;
      params.Values['User_name'] := tenv.DB.User;
      params.Values['Password'] := tenv.DB.Password;
      params.Values['DriverID'] := tenv.DB.Driver;
      params.Values['LoginTimeout'] := '2000';

      params.endUpdate;

    end;
  end;

  connection.ResourceOptions.AutoReconnect := True;
  connection.ConnectedStoredUsage := [auDesignTime, auRunTime];
  connection.Connected := True;

  result := connection;

end;

class function TDB.listTables: TStringDynArray;
var
  qry: tfdquery;
begin
  result := nil;
  qry := TDB.execute('select table_name from information_schema.tables where table_schema = ?', [tenv.DB.Database]);
  if qry <> nil then
  begin
    with qry do
    begin
      FetchAll;
      setlength(result, recordcount);
      first;
      while not eof do
      begin
        result[qry.RecNo - 1] := Fields[0].AsString;
        next;
      end;
    end;
  end;
end;

end.
