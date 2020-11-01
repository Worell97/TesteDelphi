unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB, System.Threading;

type
  ESalvarArquivosError = class(System.SysUtils.Exception);
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do par�metro n�o pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;
    procedure RollBackOperation();
    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  try
    cds := InitDataset;
    ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      cds.FieldByName('Arquivo').AsString := FPath;
      cds.Post;
      ProgressBar.Position := i;

      {$REGION Simula��o de erro, n�o alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL);
      {$ENDREGION}
    end;

    FServidor.SalvarArquivos(cds.Data);
  except
    on E:Exception do
    begin
      RollBackOperation;
      raise Exception.Create('Erro ao enviar os arquivos!'+#13#10+E.Message);
    end;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
  LArrayOfTaks: array [0..QTD_ARQUIVOS_ENVIAR] of ITask;
begin
  cds := InitDataset;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    LArrayOfTaks[i] := TTask.Create(
    procedure
    begin
      TThread.Synchronize(nil,
      procedure
      begin
        cds.Append;
        cds.FieldByName('Arquivo').AsString := FPath;
        cds.Post;
      end);
    end
    );
    LArrayOfTaks[i].Start;
    ProgressBar.Position := ProgressBar.Position + 1;
  end;
  TTask.WaitForAll(LArrayOfTaks);
  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    cds.Append;
    cds.FieldByName('Arquivo').AsString := FPath;
    cds.Post;
    ProgressBar.Position := ProgressBar.Position + 1;
  end;

  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  ProgressBar.Position := 0;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

procedure TfClienteServidor.RollBackOperation;
var
  i: integer;
  Arq: TSearchRec;
begin
  I := FindFirst(FPath+'*.*', faAnyFile, Arq);
  while I = 0 do
  begin
    DeleteFile(FPath + Arq.Name);
    I := FindNext(Arq);
  end;
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
  LMemoryStream: TMemoryStream;
begin
  Result := False;
  LMemoryStream := TMemoryStream.Create;
  try
    cds := TClientDataset.Create(nil);
    try
      cds.Data := AData;

      {$REGION Simula��o de erro, n�o alterar}
      if cds.RecordCount = 0 then
        Exit;
      {$ENDREGION}

      cds.First;

      while not cds.Eof do
      begin
        LMemoryStream.LoadFromFile(cds.FieldByName('Arquivo').AsString);
        FileName := FPath + cds.RecNo.ToString + '.pdf';
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        LMemoryStream.SaveToFile(FileName);
        cds.Next;
      end;
      Result := True;
    finally
      cds.Free;
      LMemoryStream.Free;
    end;
  except
    on E:Exception do
    begin
      E.ThrowOuterException(ESalvarArquivosError.Create('Erro ao salvar os arquivos!'+#13#10+E.Message));
    end;
  end;
end;

end.

