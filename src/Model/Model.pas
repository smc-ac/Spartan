unit Model;

interface

{$M+}

uses FireDAC.Comp.client, bDB, System.Generics.Collections, System.Rtti, SysUtils, data.db, System.TypInfo, System.DateUtils,
  strutils, bHelper;

Type
  TModel = class

  strict private
  const
    ID_FIELD = 'm_id';
    FIELD_PREFIX = 'm_';
    SETTER_METHOD_PREFIX = '_set';
    FOREIGN_KEY_POSTFIX = '_id';

    class function getTableName(className: string): string; static;

  private
  var
    aClassTypeInfo: TRttiType;
    class function getContext: TRttiContext;

  published

    /// <summary>
    /// Retorna todos os elementos da table
    /// </summary>
    class function all: Tarray<TObject>; virtual; final;

    /// <summary>
    /// Retorna todos os elementos que obedecerem
    /// os parametros
    /// </summary>
    /// <param name="Fields">
    /// Nomes dos campos na tabela a serem buscados
    /// </param>
    /// <param name="Values">
    /// Valores dos campos passados no parametro `Fields`
    /// </param>
    /// <returns>
    /// array of TObject ou nil
    /// </returns>
    class function find(fields: array of string; values: array of variant): Tarray<TObject>; virtual; final;

    /// <summary>
    /// Retorna o primeiro elemento que obedece
    /// os parametros
    /// </summary>
    /// <param name="Fields">
    /// Nomes dos campos na tabela a serem buscados
    /// </param>
    /// <param name="Values">
    /// Valores dos campos passados no parametro `Fields`
    /// </param>
    /// <returns>
    /// TObject ou nil
    /// </returns>
    class function get(fields: array of string; values: array of variant): TObject; virtual; final;

    /// <summary>
    /// Verifica se existe algum registro com os parametros
    /// informados, removendo um registro da busca
    /// </summary>
    /// <param name="excludeId">
    /// Id do objeto a ser excluído da busca
    /// </param>
    /// <param name="Fields">
    /// Nomes dos campos na tabela a serem buscados
    /// </param>
    /// <param name="Values">
    /// Valores dos campos passados no parametro `Fields`
    /// </param>
    /// <returns>
    /// Boolean
    /// </returns>
    class function exists(excludeId: integer; fields: array of string; values: array of variant): boolean; virtual; final;

    /// <summary>
    /// Verifica se existe algum registro com os parametros
    /// informados
    /// </summary>
    /// <param name="Fields">
    /// Nomes dos campos na tabela a serem buscados
    /// </param>
    /// <param name="Values">
    /// Valores dos campos passados no parametro `Fields`
    /// </param>
    /// <returns>
    /// Boolean
    /// </returns>
    class function hasAny(fields: array of string; values: array of variant): boolean; virtual; final;

    constructor Create(pk: integer = 0); overload; virtual;

    procedure save; virtual; final;
    procedure delete; virtual; final;

  end;

implementation

{ TModel }

constructor TModel.Create(pk: integer);
var
  qry: tfdquery;
  qryField: TField;
  classField: TRttiField;
  classSetterMethod: trttimethod;
  methodName: string;
begin
  inherited Create;
  Self.aClassTypeInfo := TModel.getContext.GetType(Self.ClassType);
  if pk <> 0 then
  begin
    qry := TDB.execute('select * from ' + TModel.getTableName(Self.className) + ' where id = ? ', [pk]);
    if qry <> nil then
    begin
      for qryField in qry.fields do
      begin
        classField := Self.aClassTypeInfo.GetField(FIELD_PREFIX + qryField.fieldName);
        if classField <> nil then
        begin
          methodName := SETTER_METHOD_PREFIX + Uppercase(qryField.fieldName[1]) + copy(qryField.fieldName, 2, length(qryField.fieldName));
          classSetterMethod := Self.aClassTypeInfo.GetMethod(methodName);
          if classSetterMethod <> nil then
            classSetterMethod.Invoke(Self, [TValue.FromVariant(qryField.AsVariant)])
          else
          begin
            if qryField.DataType in [ftDate, ftDateTime] then
              classField.SetValue(Self, tdatetime(qryField.Value))
            else
              classField.SetValue(Self, TValue.FromVariant(qryField.Value));
          end;
        end;
      end;
    end
    else
      raise Exception.Create(Format('Not found record with id = "%d" for Model "%s"', [pk, Self.className]));
  end;
end;

procedure TModel.delete;
begin
  Self.aClassTypeInfo := TModel.getContext.GetType(Self.ClassType);
  TDB.execute('delete from ' + TModel.getTableName(Self.className) + ' where id = ? ',
    [Self.aClassTypeInfo.GetField(ID_FIELD).GetValue(Self).asInteger]);
end;

class function TModel.exists(excludeId: integer; fields: array of string; values: array of variant): boolean;
var
  qry: tfdquery;
begin
  result := false;
  qry := TDB.execute('select * from ' + TModel.getTableName(Self.className) + ' ' + TDB.GenWhere(fields) + ' order by id limit 1', values);
  if qry <> nil then
    result := qry.Fieldbyname('id').asInteger <> excludeId;
end;

class function TModel.all: Tarray<TObject>;
begin
  (*
    Prettiest way to do this
    ´select * from tableName where 1 = 1´
  *)
  result := Self.find(['1'], ['1']);
end;

class function TModel.find(fields: array of string; values: array of variant): Tarray<TObject>;
var
  qry: tfdquery;
  arrObjects: Tarray<TObject>;
begin
  result := nil;
  qry := TDB.execute('select * from ' + TModel.getTableName(Self.className) + ' ' + TDB.GenWhere(fields), values);
  if qry <> nil then
  begin
    qry.first;
    SetLength(arrObjects, qry.RecordCount);
    while not qry.eof do
    begin
      arrObjects[qry.RecNo - 1] := Self.Create(qry.fields[0].asInteger);
      qry.next;
    end;
    result := arrObjects;
  end;
end;

class function TModel.get(fields: array of string; values: array of variant): TObject;
var
  arrObjects: Tarray<TObject>;
begin
  result := nil;
  arrObjects := Self.find(fields, values);
  if length(arrObjects) > 0 then
    result := arrObjects[0];
end;

class function TModel.getContext: TRttiContext;
begin
  result := TRttiContext.Create;
end;

class function TModel.getTableName(className: string): string;

  procedure raiseError;
  begin
    raise Exception.Create('Class Name(\' + className + '\) convention doesnt follow the pattern to model inherit \T[ClassName]\');
  end;

var
  I: integer;
begin
  result := '';

  if className[1] <> 'T' then
    raiseError;

  if className[2] <> Uppercase(className[2]) then
    raiseError;

  result := LowerCase(className[2]);

  for I := 3 to length(className) do
  begin
    if className[I] = LowerCase(className[I]) then
      result := result + className[I]
    else
      result := result + '_' + LowerCase(className[I]);
  end;

end;

class function TModel.hasAny(fields: array of string; values: array of variant): boolean;
begin
  result := Self.get(fields, values) <> nil;
end;

procedure TModel.save;

  function hasValidPrefix(const Field: TRttiField): boolean;
  begin
    result := copy(Field.Name, 1, 2) = FIELD_PREFIX;
  end;

  function isForeignKey(const Field: TRttiField): boolean;
  begin
    result := copy(Field.Name, length(Field.Name) - 2, length(Field.Name)) = FOREIGN_KEY_POSTFIX;
  end;

  function isDate(const aValue: TValue): boolean;
  begin
    result := (aValue.TypeInfo = System.TypeInfo(tDate)) or (aValue.TypeInfo = System.TypeInfo(tdatetime));
  end;

  function getFieldName(const Field: TRttiField): string;
  begin
    result := copy(Field.Name, 3, length(Field.Name));
  end;

  function getFieldSetter(const Field: TRttiField): string;
  begin
    result := 'set' + getFieldName(Field);
  end;

var
  sql, updateFields: string;
  Field: TRttiField;
  setterMethod: trttimethod;
  classFields: Tarray<TRttiField>;
  classMethods: Tarray<trttimethod>;
  fieldValues: TList<variant>;
  fieldNames: TList<string>;
  idValue: integer;
  aValue: TValue;
begin

  fieldValues := TList<variant>.Create;
  fieldNames := TList<string>.Create;

  fieldValues.Clear;
  fieldNames.Clear;

  Self.aClassTypeInfo := TModel.getContext.GetType(Self.ClassType);
  classFields := Self.aClassTypeInfo.GetFields();
  classMethods := Self.aClassTypeInfo.GetMethods();
  idValue := Self.aClassTypeInfo.GetField(ID_FIELD).GetValue(Self).asInteger;

  // SAVE
  if idValue = 0 then
  begin
    for Field in classFields do
    begin
      if Field.Name <> ID_FIELD then
        if hasValidPrefix(Field) then
        begin
          if isForeignKey(Field) then
          begin
            if Field.GetValue(Self).AsVariant <> 0 then
            begin
              fieldValues.Add(Field.GetValue(Self).asInteger);
              fieldNames.Add(getFieldName(Field));
            end;
          end
          else
          begin
            aValue := Field.GetValue(Self);

            for setterMethod in classMethods do
              if LowerCase(setterMethod.Name) = LowerCase(getFieldSetter(Field)) then
              begin
                setterMethod.Invoke(Self, [aValue]);
                Break;
              end;

            if isDate(aValue) then
              fieldValues.Add(aValue.AsType<tdatetime>)
            else
              fieldValues.Add(aValue.AsVariant);

            fieldNames.Add(getFieldName(Field));
          end;
        end;
    end;

    sql := 'insert into ' + TModel.getTableName(Self.className) + '(id,' + Thelper.arrToStr(fieldNames.ToArray) + ') values(default ' +
      Thelper.genData(',?', length(fieldValues.ToArray)) + ')';

    TDB.execute(sql, fieldValues.ToArray);

    Self.aClassTypeInfo.GetField(ID_FIELD)
      .SetValue(Self, TDB.execute('select id from ' + TModel.getTableName(Self.className) + ' order by id desc limit 1')
      .fields[0].asInteger);

  end
  // UPDATE
  else
  begin
    updateFields := '';
    for Field in classFields do
      if Field.Name <> ID_FIELD then
        if hasValidPrefix(Field) then
          if isForeignKey(Field) then
          begin
            if Field.GetValue(Self).AsVariant <> 0 then
            begin
              updateFields := updateFields + (getFieldName(Field) + ' = ?,');
              fieldValues.Add(Field.GetValue(Self).asInteger);
            end
            else
              updateFields := updateFields + (getFieldName(Field) + ' = null,');
          end
          else
          begin
            updateFields := updateFields + (getFieldName(Field) + ' = ?,');
            aValue := Field.GetValue(Self);

            for setterMethod in classMethods do
              if setterMethod.Name = getFieldSetter(Field) then
              begin
                setterMethod.Invoke(Self, [aValue]);
                Break;
              end;

            if isDate(aValue) then
              fieldValues.Add(aValue.AsType<tdatetime>)
            else
              fieldValues.Add(aValue.AsVariant);
          end;

    fieldValues.Add(idValue);

    updateFields := copy(updateFields, 0, length(updateFields) - 1);

    sql := 'update ' + TModel.getTableName(Self.className) + ' set ' + updateFields + ' where id = ?';

    TDB.execute(sql, fieldValues.ToArray);

  end;
end;

end.
