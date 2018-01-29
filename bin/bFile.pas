unit bFile;

interface

uses winapi.windows, system.SysUtils, shellapi, classes, variants, vEnv, inifiles;

type
  TFile = class
  public

    class function Move(pSource, pDestination: string): string;
    class function Copy(pSource, pDestination: string): string;
    class procedure Open(pFile: string);
    class procedure Delete(pFile: string);
    class function Rename(pOldName, pNewName: string): string;
    class function Create(AbsoluteFileName: string): TFile;

    class procedure writeInFile(fileName, data: string);

    class function exists(pathfilename: string): boolean;

  private
    class procedure PathWork(Origem, Destino: string; work: integer); overload;
    class procedure PathWork(Origem: string; work: integer = FO_DELETE); overload;
    class function quotedPath(path: string): string;

  end;

implementation

class function TFile.Move(pSource, pDestination: string): string;
begin
  if not SameFileName(pSource, tenv.system.exepath) then
  begin
    if ExtractFileExt(pDestination) <> '' then
    begin
      if FileExists(pDestination) then
        self.Delete(quotedPath(pDestination));
      winapi.windows.MoveFile(pchar(pSource), pchar(pDestination));
    end
    else
      PathWork(pSource, pDestination, FO_MOVE);
    result := pDestination;
  end;
end;

class procedure TFile.Open(pFile: string);
begin
  if not FileExists(pFile) then
    raise Exception.Create(Format('Arquivo [%s] não encontrado!', [pFile]));

  ShellExecute(0, 'open', pchar(quotedPath(pFile)), nil, nil, SW_SHOWNORMAL);
end;

class procedure TFile.PathWork(Origem: string; work: integer);
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := work;
    fFlags := FOF_NOCONFIRMATION + FOF_NOCONFIRMMKDIR + FOF_NO_UI + FOF_RENAMEONCOLLISION + FOF_SILENT;
    pFrom := pchar(Origem + #0);
  end;
  ShFileOperation(fos);
end;

class function TFile.quotedPath(path: string): string;
begin
  result := '"' + path + '"';
end;

class procedure TFile.PathWork(Origem, Destino: string; work: integer);
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := work;
    fFlags := FOF_NOCONFIRMATION + FOF_NOCONFIRMMKDIR + FOF_NO_UI + FOF_RENAMEONCOLLISION + FOF_SILENT;
    pFrom := pchar(Origem + #0);
    pTo := pchar(Destino)
  end;
  ShFileOperation(fos);
end;

class function TFile.Rename(pOldName, pNewName: string): string;
var
  b: boolean;
begin
  if not SameFileName(pOldName, tenv.system.exepath) then
  begin
    if ExtractFileExt(pOldName) <> '' then
    begin
      if FileExists(pOldName) then
        b := RenameFile(pOldName, pNewName);
    end
    else
      self.PathWork(quotedPath(pOldName), quotedPath(pNewName), FO_RENAME);
    result := pNewName;
  end;
end;

class procedure TFile.writeInFile(fileName, data: string);
var
  log: TStringList;
begin

  try
    log := TStringList.Create;
    if not FileExists(fileName) then
      TFile.Create(fileName);
    log.LoadFromFile(fileName);
    log.Add(data);
    log.SaveToFile(fileName);
  except
    exit
  end;

end;

class procedure TFile.Delete(pFile: string);
begin
  if not SameFileName(pFile, tenv.system.exepath) then
    PathWork(pFile, FO_DELETE);
end;

class function TFile.exists(pathfilename: string): boolean;
begin
  result := FileExists(pathfilename);
end;

class function TFile.Copy(pSource, pDestination: string): string;
begin
  if ExtractFileExt(pDestination) <> '' then
  begin
    if FileExists(pDestination) then
      self.Delete(quotedPath(pDestination));
    winapi.windows.CopyFile(pchar(pSource), pchar(pDestination), true);
  end
  else
    self.PathWork(pSource, pDestination, FO_COPY);
  result := pDestination;
end;

class function TFile.Create(AbsoluteFileName: string): TFile;
begin
  if ExtractFileExt(AbsoluteFileName) <> '' then
    TStringList.Create.SaveToFile(AbsoluteFileName)
  else
  begin
    if not DirectoryExists(AbsoluteFileName) then
      ForceDirectories(StringToOleStr(AbsoluteFileName));
  end;
  result := self.ClassInfo;
end;

end.
