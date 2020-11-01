unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
  private
  public
    procedure ExceptionManager(Sender: TObject; E:Exception);
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Threads;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin  
  fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads.Show;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
   Application.OnException := ExceptionManager;
end;

procedure TfMain.ExceptionManager(Sender: TObject; E:Exception);
var
  LArqLog: TextFile;
  LArqName: String;
begin
  LArqName := ExtractFileDir(Application.ExeName)+'\log.txt';
  AssignFile(LArqLog, LArqName);
  if FileExists(LArqName) then
  begin
    Append(LArqLog);
  end
  else
  begin
    Rewrite(LArqLog)
  end;
  WriteLn(LArqLog, E.ClassName + E.Message);

  CloseFile(LArqLog);
  if Application.MessageBox(PWideChar('Erro inesperado!'+#13#10+E.Message), 'Error', MB_OK) = ID_OK then
    Self.Close;
end;

end.
