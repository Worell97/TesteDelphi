unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TThreads = class(TThread)
    FTempoMaximo: Integer;
    FNumeroThreads: Integer;
    procedure SetTempoMaximo(const Value: integer);
    procedure SetNumeroThreads(const Value: integer);
    procedure IncrementProgressBar;
    { Private declarations }
    protected
      procedure TMemoThreadInicio;
      procedure TMemoThreadFim;
      procedure Execute; override;
    private
      FForm: TForm;
      procedure DecNumeroThreads;
    public
      constructor Create(CreateSuspended: Boolean; AForm: TForm);
      property TempoMaximo: integer read FTempoMaximo write SetTempoMaximo;
      property NumeroThreads: integer read FNumeroThreads write SetNumeroThreads;

  end;
  TfThreads = class(TForm)
    EDNumeroThreads: TEdit;
    EDTempMax: TEdit;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FNumeroDeThreads: Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.Button1Click(Sender: TObject);
var
  I: Integer;
  LThread: TThreads;
begin
  ProgressBar1.Min := 0;
  ProgressBar1.Max := (StrToInt(EDNumeroThreads.Text) * 101) + StrToInt(EDNumeroThreads.Text);
  ProgressBar1.Position := 0;
  for I := 0 to StrToInt(EDNumeroThreads.Text) do
  begin
    LThread := TThreads.Create(True, Self);
    LThread.FreeOnTerminate := True;
    FNumeroDeThreads := FNumeroDeThreads + 1;
    LThread.TempoMaximo := StrToInt(EDTempMax.Text);
    LThread.Start;
  end;
end;

{ TThreads }

procedure TThreads.DecNumeroThreads;
var
  LFormAux : TfThreads;
begin
  inherited;
  LFormAux := FForm as TfThreads;
  LFormAux.FNumeroDeThreads := LFormAux.FNumeroDeThreads - 1;
end;

procedure TThreads.Execute;
var
  I: Integer;
  LTime : Integer;
begin
  inherited;
  Synchronize(TMemoThreadInicio);
  while not(Terminated) do
  begin
    for I := 0 to (100) do
    begin
      LTime := Random(Self.TempoMaximo);
      Sleep(LTime);
      Synchronize(IncrementProgressBar);
    end;
    Synchronize(DecNumeroThreads);
    Synchronize(IncrementProgressBar);
    Synchronize(TMemoThreadFim);
  end;
end;

procedure TThreads.IncrementProgressBar;
var
  LFormAux : TfThreads;
begin
  LFormAux := FForm as TfThreads;
  LFormAux.ProgressBar1.Position := LFormAux.ProgressBar1.Position + 1;
end;

procedure TThreads.SetNumeroThreads(const Value: integer);
begin
  FNumeroThreads := Value;
end;

procedure TThreads.SetTempoMaximo(const Value: integer);
begin
   FTempoMaximo := Value;
end;

procedure TThreads.TMemoThreadFim;
var
  LFormAux : TfThreads;
begin
  LFormAux := FForm as TfThreads;
  LFormAux.Memo1.Lines.Add(Self.ThreadID.ToString+' – Processo finalizado');
end;

procedure TThreads.TMemoThreadInicio;
var
  LFormAux : TfThreads;
begin
  LFormAux := FForm as TfThreads;
  LFormAux.Memo1.Lines.Add(Self.ThreadID.ToString+' – Iniciando processamento');
end;

constructor TThreads.Create(CreateSuspended: Boolean; AForm: TForm);
begin
  inherited Create (CreateSuspended);
  FForm := AForm;
  FreeOnTerminate := True;
end;

procedure TfThreads.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if FNumeroDeThreads > 0 then
  begin
    Application.MessageBox('Existem threads em execução. Aguardo o fim do processo',
            'Atenção',MB_OK);
    CanClose := false;
  end;
end;


procedure TfThreads.FormCreate(Sender: TObject);
begin
  FNumeroDeThreads := 0;
end;

end.
