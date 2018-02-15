unit bFormatter;

interface

uses system.sysutils, strutils;

type
  TFormatter = class
  private
    class function formatType(v: string): string;
    class function unformatType(v: string): string;
    class function parseType(inputedType: string): string;

  public

    class function parseModel(v: string): string;
    class function parseController(v: string): string;
    class function parseDAO(v: string): string;

    class function modelFromTable(tableName: string): string;
    class function controllerFromTable(tableName: string): string;
    class function daoFromTable(tableName: string): string;

    class function tableFromModel(model: string): string;
    class function tableFromController(controller: string): string;
    class function tableFromDAO(dao: string): string;

    class function replace(value, value_to_find: string; value_to_replace: string = ''): string;
  end;

implementation

{ TFormatter }

class function TFormatter.replace(value, value_to_find: string; value_to_replace: string = ''): string;
begin
  Result := StringReplace(value, value_to_find, value_to_replace, [rfReplaceAll, rfIgnoreCase]);
end;

class function TFormatter.tableFromController(controller: string): string;
begin
  Result := '';
  if controller = '' then
    raise Exception.Create('Controller name must be filled.');
  Result := unformatType(copy(controller, 1, length(controller) - length('Controller')));
end;

class function TFormatter.tableFromDAO(dao: string): string;
begin
  Result := '';
  if dao = '' then
    raise Exception.Create('DAO name must be filled.');
  Result := unformatType(copy(dao, 1, length(dao) - length('DAO')));
end;

class function TFormatter.tableFromModel(model: string): string;
begin
  Result := '';
  if model = '' then
    raise Exception.Create('Model name must be filled.');
  Result := unformatType(model);
end;

class function TFormatter.unformatType(v: string): string;
var
  I: integer;
begin
  Result := '';
  Result := LowerCase(v[2]);
  for I := 3 to length(v) do
    Result := Result + ifthen(v[I] = LowerCase(v[I]), v[I], '_' + LowerCase(v[I]));
end;

class function TFormatter.controllerFromTable(tableName: string): string;
begin
  Result := '';
  if tableName = '' then
    raise Exception.Create('Table name must be filled.');
  Result := 'T' + formatType(copy(tableName, 1, length(tableName))) + 'Controller';
end;

class function TFormatter.daoFromTable(tableName: string): string;
begin
  Result := '';
  if tableName = '' then
    raise Exception.Create('Table name must be filled.');
  Result := 'T' + formatType(copy(tableName, 1, length(tableName))) + 'DAO';
end;

class function TFormatter.formatType(v: string): string;
var
  I: integer;
begin
  Result := uppercase(v[1]);
  for I := 2 to length(v) do
  begin
    if v[I] = '_' then
    begin
      Result := Result + formatType(copy(v, I + 1, length(v)));
      exit;
    end
    else
      Result := Result + LowerCase(v[I]);
  end;
end;

class function TFormatter.modelFromTable(tableName: string): string;
begin
  Result := '';
  if tableName = '' then
    raise Exception.Create('Table name must be filled.');
  Result := 'T' + formatType(copy(tableName, 1, length(tableName)));
end;

class function TFormatter.parseController(v: string): string;
begin
  Result := TFormatter.formatType(TFormatter.unformatType(copy(v, 1, length(v) - length('controller')))) + 'Controller';
end;

class function TFormatter.parseDAO(v: string): string;
begin
  Result := TFormatter.formatType(TFormatter.unformatType(copy(v, 1, length(v) - length('dao')))) + 'DAO';
end;

class function TFormatter.parseModel(v: string): string;
begin
  Result := TFormatter.formatType(TFormatter.unformatType(v));
end;

class function TFormatter.parseType(inputedType: string): string;
begin
  Result := TFormatter.formatType(TFormatter.unformatType(inputedType));
end;

end.
