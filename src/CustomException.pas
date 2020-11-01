unit CustomException;

interface

uses
  System.SysUtils, System.Classes;

type
  TCustomException = class(System.SysUtils.Exception)
  private
    procedure SalvarLog(Mensagem: String);
  public
    constructor Create(Mensagem: String);
  end;

implementation

uses
  Vcl.Forms;

{ TCustomException }

constructor TCustomException.Create(Mensagem: String);
begin
  SalvarLog(Mensagem);
  Exception.ThrowOuterException(Exception.Create(Mensagem));
end;

procedure TCustomException.SalvarLog(Mensagem: String);
var
  LArqLog: TextFile;
  LArqName: String;
begin
  LArqName := ExtractFileDir(Application.ExeName)+'log.txt';
  if FileExists(LArqName) then
  begin
    Append(LArqLog);
  end else
    Rewrite(LArqLog, LArqName);

  Write(LArqLog, Self.ToString + Mensagem);
end;

end.
