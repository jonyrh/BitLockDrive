unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  Windows, Process, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private

  public
    procedure UpdateDrivesToComboBox;
    function GetVolumeName(const DriveLetter: Char): AnsiString;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  aStrOut,
  aDrive  : AnsiString;
begin
  if ComboBox1.ItemIndex=-1 then Exit;

  aDrive:=ComboBox1.Text[1] + ComboBox1.Text[2];
  aStrOut:='';

  if RunCommand('cmd', ['/c', 'manage-bde', '-lock', aDrive, '-ForceDismount'], aStrOut, [], swoHIDE) then
  Application.Terminate
   else MessageBox(handle,'Cannot lock drive', 'Error', MB_OK or MB_ICONERROR);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateDrivesToComboBox;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
  OpenURL('http://www.jonyrh.ru');
end;

function TForm1.GetVolumeName(const DriveLetter: Char): AnsiString;
var
  dummy: DWORD;
  buffer: array[0..MAX_PATH] of Char;
  oldmode: LongInt;
begin
  oldmode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    GetVolumeInformation(PChar(DriveLetter + ':\'),
                         buffer,
                         SizeOf(buffer),
                         nil,
                         dummy,
                         dummy,
                         nil,
                         0);
    Result := StrPas(buffer);
  finally
    SetErrorMode(oldmode);
  end;
end;

procedure TForm1.UpdateDrivesToComboBox;
var
  Drive: Char;
  DriveLetter: string;
  DriveLabel: AnsiString;
  OldMode: Word;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  ComboBox1.Items.Clear;

  try

   for Drive := 'A' to 'Z' do
    begin
    DriveLetter := Drive + ':';

    case GetDriveType(PChar(DriveLetter)) of
     DRIVE_REMOVABLE, DRIVE_FIXED:
       begin
       DriveLabel:=GetVolumeName(Drive);

       ComboBox1.Items.Add(DriveLetter + ' ' + DriveLabel);
       end;
     end;
    end;

  finally
    SetErrorMode(OldMode);
  end;

  if ComboBox1.Items.Count<>0 then ComboBox1.ItemIndex:=ComboBox1.Items.Count-1
                              else ComboBox1.ItemIndex:=-1;
end;


end.

