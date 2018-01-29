unit bSpartan;

interface

uses vEnv, vConst, bFile, system.SysUtils, system.StrUtils, firedac.comp.client, dDB, bFormatter, bHelper, types;

type
  TSpartan = class
  private
    class procedure version(newLine: boolean = true);
    class procedure noteCaseInsensitive;

    class procedure createModel(model_name: string);
    class procedure createController(controller_name: string);
    class procedure createDAO(dao_name: string);

  public

    class procedure raiseArmy;
    class procedure raiseWeapons(dir: string);
    class procedure spartError(msg: string);
  end;

implementation

{ TSpartan }

class procedure TSpartan.raiseWeapons(dir: string);
var
  projectName, confFile, defPort, defUser, defPass: string;

begin
  projectName := THelper.getPathName(dir);

  writeln(format('Starting project %s ...', [projectName]));
  tfile.Create(dir);
  writeln('');

  if not fileexists(dir + tconst.GITIGNORE_FILE) then
  begin
    tfile.Create(dir + tconst.GITIGNORE_FILE);
    tfile.writeInFile(dir + tconst.GITIGNORE_FILE, tconst.GITIGNORE_CONTENT);
  end;

  if (fileexists(dir + tconst.CONTROLLER_FILE) and THelper.readbolinput('Base Controller file already exists. Do you want to recriate it ?')) or
    (not fileexists(dir + tconst.CONTROLLER_FILE)) then
  begin
    writeln(format('Creating Controller Weapons in %s%s ...', [dir, tconst.CONTROLLER_FILE]));
    tfile.Create(dir + tconst.CONTROLLER);
    tfile.Create(dir + tconst.CONTROLLER_FILE);
    writeln('');
  end;

  if (fileexists(dir + tconst.MODEL_FILE) and THelper.readbolinput('Base Model file already exists. Do you want to recriate it ?')) or (not fileexists(dir + tconst.MODEL_FILE))
  then
  begin
    writeln(format('Creating Model Weapons in %s%s ...', [dir, tconst.MODEL_FILE]));
    tfile.Create(dir + tconst.MODEL);
    tfile.Create(dir + tconst.MODEL_FILE);
    writeln('');
  end;

  if (fileexists(dir + tconst.DAO_FILE) and THelper.readbolinput('Base DAO file already exists. Do you want to recriate it ?')) or (not fileexists(dir + tconst.DAO_FILE)) then
  begin
    writeln(format('Creating DAO Weapons in %s%s ...', [dir, tconst.DAO_FILE]));
    tfile.Create(dir + tconst.DAO);
    tfile.Create(dir + tconst.DAO_FILE);
    writeln('');
  end;

  writeln(format('Creating View Weapons in %s%s ...', [dir, tconst.View]));
  writeln('');
  tfile.Create(dir + tconst.View);

  confFile := dir + tconst.CONF_FILE;

  if (fileexists(confFile) and THelper.readbolinput(format('Configuration file "%s" already exists. Do you want to recriate it ?', [tconst.CONF_FILE, slinebreak]))) or
    (not fileexists(confFile)) then
  begin
    tfile.Create(confFile);
    writeln('');
    writeln('Database configurations: ');
    writeln('-------------------------');

    CONF_FULL_PATH := confFile;

    tenv.db.driver := THelper.readinput('Driver [ mysql | postgres | firebird ]', 'mysql');
    defPass := '';

    case ansiindexstr(tenv.db.driver, ['mysql', 'postgres', 'firebird']) of
      0: { mysql }
        begin
          defPort := '3306';
          defUser := 'root';
        end;
      1: { postgres }
        begin
          defPort := '5432';
          defUser := 'postgres';
        end;
      2: { firebird }
        begin
          defPort := '3050';
          defUser := 'sysdba';
          defPass := 'masterkey';
        end
    else
      begin
        spartError(format('Driver "%s" not supported.', [tenv.db.driver]));
        tenv.db.driver := '';
        tenv.db.server := '';
        tenv.db.Port := '';
        tenv.db.database := '';
        tenv.db.user := '';
        tenv.db.password := '';
      end;
    end;

    tenv.db.server := THelper.readinput('Server', 'localhost');
    tenv.db.Port := THelper.readinput('Port', defPort);
    if tenv.db.driver = 'firebird' then
    begin
      tenv.db.database := '"' + THelper.selectfile(dir, '.fdb|.fdb2|.fdb3|.gdb') + '"';
      if tenv.db.database = '' then
        tenv.db.database := 'no_database_selected';
      writeln('Database: ', tenv.db.database);
    end
    else
      tenv.db.database := THelper.readinput('Database');
    tenv.db.user := THelper.readinput('User', defUser);
    tenv.db.password := THelper.readinput('Password', defPass);
    writeln('');
    writeln('-------------------------');
  end;

  writeln('');
  writeln(format('Weapon "%s" created successfully' + slinebreak + 'START YOUR BATTLE NOW !!!', [projectName]));
end;

class procedure TSpartan.spartError(msg: string);
begin
  raise Exception.Create(msg);
end;

class procedure TSpartan.version(newLine: boolean = true);
begin
  writeln(tconst.APP_NAME, ': ', tenv.system.version);
  if newLine then
    writeln('');
end;

class procedure TSpartan.createController(controller_name: string);
var
  selected_controller: string;
begin
  writeln('');
  selected_controller := tenv.system.currentPath + tconst.CONTROLLER + tformatter.parseController(controller_name) + tconst.pas;
  if (fileexists(selected_controller) and THelper.readBolInputWithAll('Controller "' + selected_controller + '" already exists!' + slinebreak + 'Do you want to recriate it ?')) or
    (not fileexists(selected_controller)) then
  begin
    tfile.Create(selected_controller);
    writeln('Controller ', tformatter.parseController(controller_name), ' created successfully !');
  end;
end;

class procedure TSpartan.createDAO(dao_name: string);
var
  selected_DAO: string;
begin
  writeln('');
  selected_DAO := tenv.system.currentPath + tconst.DAO + tformatter.parseDAO(dao_name) + tconst.pas;
  if (fileexists(selected_DAO) and THelper.readBolInputWithAll('DAO "' + selected_DAO + '" already exists!' + slinebreak + 'Do you want to recriate it ?')) or
    (not fileexists(selected_DAO)) then
  begin
    tfile.Create(selected_DAO);
    writeln('DAO ', tformatter.parseDAO(dao_name), ' created successfully !');
  end;
end;

class procedure TSpartan.createModel(model_name: string);
var
  selected_model: string;
begin
  writeln('');
  selected_model := tenv.system.currentPath + tconst.MODEL + tformatter.parseModel(model_name) + tconst.pas;
  if (fileexists(selected_model) and THelper.readBolInputWithAll('Model "' + selected_model + '" already exists!' + slinebreak + 'Do you want to recriate it ?')) or
    (not fileexists(selected_model)) then
  begin
    tfile.Create(selected_model);
    writeln('Model ', tformatter.parseModel(model_name), ' created successfully !');
  end;
end;

class procedure TSpartan.noteCaseInsensitive;
begin
  writeln('Note: Types bellow are case sensitive!');
end;

class procedure TSpartan.raiseArmy;
var
  i: integer;
  aName, table: string;
  tables_list: TStringDynArray;
begin
  case ParamCount of
    0:
      begin
        writeln('');
        writeln(tconst.APP_NAME, ' Framework | A Delphi MVC micro-framework to fast build applications and dinner in HELL.');
        writeln('==================================================================================================');
        writeln('Authors: Paulo Barros <paulo.alfredo.barros@gmail.com>, Junior de Paula <juniiordepaula@gmail.com>');
        TSpartan.version(false);
        writeln('==================================================================================================');
        writeln('');
        writeln('Usage: ', lowercase(tconst.APP_NAME), ' [option] <param|params>');
        writeln('');
        writeln('');
        writeln('Avaliable soldiers:');
        for i := 0 to High(tconst.SOLDIERS) do
          writeln('  ', tconst.SOLDIERS[i], StringOfChar(' ', 20 - length(tconst.SOLDIERS[i])), tconst.soldiers_help[i]);
      end;
    1:
      begin
        TSpartan.version;
        case ansiindexstr(ParamStr(1), tconst.SOLDIERS) of
          0: { version already been promt }
            ;
          1: { -c }
            begin
              writeln(tenv.system.getConfig);
              writeln('--------------------------------------------------------');
              writeln(format('Configuration file must be located in "%s"', [tconst.getConfFile]));
            end;

          2: { stare }
            begin
              spartError('A NAME to your new weapon must be informed.' + slinebreak + 'If you want to create new weapon in current folder, type "spartan stare ."');
            end;

          3: { push }
            begin
              spartError('You must choose one of the weapons bellow:' + slinebreak + '    model' + slinebreak + '    controller' + slinebreak + '    dao');
            end
        else
          spartError(format('Soldier "%s" is not part of our army.', [ParamStr(1)]));
        end;
      end;
    2:
      begin
        TSpartan.version;
        case ansiindexstr(ParamStr(1), tconst.SOLDIERS) of
          2: { stare }
            begin
              if ParamStr(2) = '.' then
                TSpartan.raiseWeapons(tenv.system.currentPath)
              else
              begin
                if tfile.exists(tenv.system.currentPath + ParamStr(2)) then
                  spartError(format('A project "%s" already exists.', [ParamStr(2)]))
                else
                  TSpartan.raiseWeapons(tenv.system.currentPath + ParamStr(2) + '\');
              end;
            end;
          3: { push }
            begin
              case ansiindexstr(ParamStr(2), tconst.push_options) of
                0: { model }
                  begin
                    tables_list := TDB.listTables;
                    if length(tables_list) > 0 then
                    begin
                      writeln('Avaliable tables to became Model weapons: ');
                      TSpartan.noteCaseInsensitive;
                      writeln('');
                      for table in tables_list do
                      begin
                        aName := tformatter.modelFromTable(table);
                        if THelper.existsInArray(tenv.system.currentPath + tconst.MODEL + copy(aName, 2, length(aName)) + tconst.pas, tenv.system.Models) then
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Created )')

                        else
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Not created )');
                      end;
                    end;
                  end;
                1: { controller }
                  begin
                    tables_list := TDB.listTables;
                    if length(tables_list) > 0 then
                    begin
                      writeln('Avaliable tables to became Controller weapons: ');
                      TSpartan.noteCaseInsensitive;
                      writeln('');
                      for table in tables_list do
                      begin
                        aName := tformatter.controllerFromTable(table);
                        if THelper.existsInArray(tenv.system.currentPath + tconst.CONTROLLER + copy(aName, 2, length(aName)) + tconst.pas, tenv.system.Controllers) then
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Created )')

                        else
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Not created )');
                      end;
                    end;
                  end;
                2: { DAO }
                  begin
                    tables_list := TDB.listTables;
                    if length(tables_list) > 0 then
                    begin
                      writeln('Avaliable tables to became DAO weapons: ');
                      TSpartan.noteCaseInsensitive;
                      writeln('');
                      for table in tables_list do
                      begin
                        aName := tformatter.daoFromTable(table);
                        if THelper.existsInArray(tenv.system.currentPath + tconst.DAO + copy(aName, 2, length(aName)) + tconst.pas, tenv.system.DAOs) then
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Created )')

                        else
                          writeln('       - ', aName, StringOfChar(' ', 40 - length(aName)), '( Not created )');
                      end;
                    end;
                  end
              else
                spartError(format('Weapon "%s" is not part of our arsenal.', [ParamStr(2)]));
              end;
            end;
        else
          spartError(format('Soldier "%s" is not part of our army.', [ParamStr(1)]));
        end;

      end;
    3:
      begin
        TSpartan.version;
        case ansiindexstr(ParamStr(2), tconst.push_options) of
          0: { model }
            begin
              if ParamStr(3) = '*' then
              begin
                tables_list := TDB.listTables;
                if length(tables_list) > 0 then
                begin
                  for table in tables_list do
                    TSpartan.createModel(tformatter.modelFromTable(table));
                end;
              end
              else if ansimatchstr(tformatter.tableFromModel(ParamStr(3)), TDB.listTables) then
                TSpartan.createModel(ParamStr(3))
              else
                writeln('Model ', ParamStr(3), ' not found !');
            end;
          1: { controller }
            begin
              if ParamStr(3) = '*' then
              begin
                tables_list := TDB.listTables;
                if length(tables_list) > 0 then
                begin
                  for table in tables_list do
                    TSpartan.createController(tformatter.controllerFromTable(table));
                end;
              end
              else if ansimatchstr(tformatter.tableFromController(ParamStr(3)), TDB.listTables) then
                TSpartan.createController(ParamStr(3))
              else
                writeln('Controller ', ParamStr(3), ' not found !');
            end;
          2: { dao }
            begin
              if ParamStr(3) = '*' then
              begin
                tables_list := TDB.listTables;
                if length(tables_list) > 0 then
                begin
                  for table in tables_list do
                    TSpartan.createDAO(tformatter.daoFromTable(table));

                end;
              end
              else if ansimatchstr(tformatter.tablefromdao(ParamStr(3)), TDB.listTables) then
                TSpartan.createDAO(ParamStr(3))
              else
                writeln('DAO ', ParamStr(3), ' not found !');
            end;
        else
          spartError(format('Weapon "%s" is not part of our arsenal.', [ParamStr(2)]));
        end
      end;
  end;
end;

end.
