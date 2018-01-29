unit bHelper;

interface

uses types, System.sysutils, strutils, windows, vcl.dialogs, vEnv;

type
  THelper = class
  public
    class function existsInArray(value: variant; arrayValues: array of variant): boolean; overload;
    class function existsInArray(value: string; arrayValues: TStringDynArray): boolean; overload;
    class function getPathName(path: string): string;
    class function readInput(msg: string; defaultValue: string = ''): string;
    class function readBolInput(msg: string; defaultValue: string = ''): boolean;
    class function readBolInputWithAll(msg: string; defaultValue: string = ''): boolean;
    class function SelectFile(CurrentDir: string = 'C:\'; Filters: string = ''): string;

  end;

implementation

{ THelper }

class function THelper.existsInArray(value: variant; arrayValues: array of variant): boolean;
var
  _value: variant;
begin
  result := false;

  for _value in arrayValues do
    if _value = value then
    begin
      result := true;
      break;
    end;
end;

class function THelper.existsInArray(value: string; arrayValues: TStringDynArray): boolean;
var
  _value: string;
begin
  result := false;

  for _value in arrayValues do
    if lowercase(_value) = lowercase(value) then
    begin
      result := true;
      break;
    end;
end;

class function THelper.getPathName(path: string): string;
begin
  result := ExtractFileName(ExcludeTrailingPathDelimiter(path));
end;

class function THelper.readBolInput(msg, defaultValue: string): boolean;
begin
  result := lowercase(readInput(msg + ' (y/N)', defaultValue)) = 'y';
end;

class function THelper.readBolInputWithAll(msg, defaultValue: string): boolean;
var
  selected: string;
begin
  result := false;
  if ALL_OPTION_SELECTED then
  begin
    result := true;
    exit;
  end;
  selected := lowercase(readInput(msg + ' (y/N/a)', defaultValue));
  ALL_OPTION_SELECTED := (selected = 'a');
  result := (selected <> 'n');
end;

class function THelper.readInput(msg: string; defaultValue: string = ''): string;
var
  OldMode: Cardinal;
  c: char;
begin
  Write(msg, ' ', ifthen(defaultValue <> '', '(' + defaultValue + ')', ''), ': ');
  Readln(input, result);
  result := ifthen((defaultValue <> '') and (result = ''), defaultValue, result);
  if result = '^C' then
  begin
    writeln('');
    halt(0);
  end;
end;

class function THelper.SelectFile(CurrentDir: string = 'C:\'; Filters: string = ''): string;

var
  openDialog: topendialog;
begin
  try
    openDialog := topendialog.create(nil);
    openDialog.InitialDir := CurrentDir;
    openDialog.Options := [ofFileMustExist];
    openDialog.Filter := Filters + '|All|*.*';
    openDialog.FilterIndex := 1;
    if openDialog.Execute then
      result := openDialog.FileName
    else
      result := emptystr;
  finally
    openDialog.Free;
  end;

end;

end.
