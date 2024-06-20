unit Unit1;

{$mode objfpc}{$H+}

{$DEFINE ALLOW_DARK}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  Windows, Process, LCLIntf, ComboEx, LazUTF8
   {$IFDEF ALLOW_DARK}
  ,uDarkStyleParams, uWin32WidgetSetDark, uDarkStyleSchemes, uMetaDarkStyle
  {$ENDIF}
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    ComboBoxEx1: TComboBoxEx;
    ImageList1: TImageList;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  private

  public
    procedure UpdateDrivesToComboBox;
    function GetVolumeName(const DriveLetter: Char): AnsiString;
  end;

const
  SC_MyMenuItem = WM_USER + 1;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{$IFDEF ALLOW_DARK}
procedure SetDarkStyle;
begin
 try
  if not IsDarkModeEnabled then
   begin
   uDarkStyleParams.PreferredAppMode:=pamAllowDark;
   uMetaDarkStyle.ApplyMetaDarkStyle(DefaultDark);
   end;
  except
  end;
end;
{$ENDIF}

procedure TForm1.WMSysCommand(var Msg: TWMSysCommand);
begin
  if Msg.CmdType = SC_MyMenuItem then OpenURL('http://www.jonyrh.ru')
  else
    inherited;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  aStrOut,
  aDrive: String;
begin
  if ComboBoxEx1.ItemIndex=-1 then Exit;

  aDrive:= ComboBoxEx1.ItemsEx.Items[ComboBoxEx1.ItemIndex].Caption[1] + ':';
  aStrOut:='';

  if RunCommand('cmd', ['/c', 'manage-bde', '-lock', aDrive, '-ForceDismount'], aStrOut, [], swoHIDE) then
  Application.Terminate
   else MessageBox(handle,'Cannot lock drive', 'Error', MB_OK or MB_ICONERROR);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AppendMenu(GetSystemMenu(Handle, FALSE), MF_SEPARATOR, 0, '');
  AppendMenu(GetSystemMenu(Handle, FALSE), MF_STRING, SC_MyMenuItem, '(c) Jony Rh, 2024');
  AppendMenu(GetSystemMenu(Handle, FALSE), MF_STRING, SC_MyMenuItem, 'http://www.jonyrh.ru');

  UpdateDrivesToComboBox;
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
  ComboBoxEx1.Items.Clear;

  try

   for Drive := 'A' to 'Z' do
    begin
    DriveLetter := Drive + ':';

    case GetDriveType(PChar(DriveLetter)) of
     DRIVE_REMOVABLE:
       begin
        DriveLabel:=GetVolumeName(Drive);
        ComboBoxEx1.ItemsEx.AddItem(DriveLetter + ' ' + DriveLabel, 0);
       end;

     DRIVE_FIXED:
       begin
        DriveLabel:=GetVolumeName(Drive);
        ComboBoxEx1.ItemsEx.AddItem(DriveLetter + ' ' + DriveLabel, 1);
       end;
     end;
    end;

  finally
    SetErrorMode(OldMode);
  end;

  if ComboBoxEx1.Items.Count<>0 then ComboBoxEx1.ItemIndex:= ComboBoxEx1.Items.Count-1
                                else ComboBoxEx1.ItemIndex:=-1;
end;

{$IFDEF ALLOW_DARK}
initialization

SetDarkStyle;
{$ENDIF}

end.

