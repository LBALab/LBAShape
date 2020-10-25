//******************************************************************************
// LBA Shape Editor - editing lsh (shape) files from Little Big Adventure 1 & 2
//
// LBAShape1 unit.
// Main program unit. Contains main form's events.
//
// Copyright (C) Zink
// e-mail: zink@poczta.onet.pl
// See the GNU General Public License (License.txt) for details.
//******************************************************************************

unit LBAShape1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ComCtrls, Buttons, ShellApi;

type
  TForm1 = class(TForm)
    Label7: TLabel;
    btOpen: TButton;
    pbView: TPaintBox;
    dlgOpen: TOpenDialog;
    Label2: TLabel;
    Pages: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    PointAdd: TButton;
    PointNr: TSpinEdit;
    PointDel: TButton;
    PointX: TSpinEdit;
    PointY: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    LineNr: TSpinEdit;
    LineAdd: TButton;
    LineDel: TButton;
    LineStart: TSpinEdit;
    LineEnd: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    PointTot: TLabel;
    Label8: TLabel;
    LineTot: TLabel;
    Label10: TLabel;
    Bevel1: TBevel;
    ShapeCol: TSpinEdit;
    dspPoint: TCheckBox;
    dspLine: TCheckBox;
    dspCenter: TCheckBox;
    rgZoom: TRadioGroup;
    btUp: TBitBtn;
    btLeft: TBitBtn;
    btDown: TBitBtn;
    btRight: TBitBtn;
    btCenter: TBitBtn;
    Bevel2: TBevel;
    pbColour: TPaintBox;
    btPrev: TBitBtn;
    btNext: TBitBtn;
    Label1: TLabel;
    btSave: TButton;
    dlgSave: TSaveDialog;
    Panel1: TPanel;
    Shape1: TShape;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure ShapeNrChange(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure pbViewPaint(Sender: TObject);
    procedure PointNrChange(Sender: TObject);
    procedure PagesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LineStartChange(Sender: TObject);
    procedure OptionsClick(Sender: TObject);
    procedure rgZoomClick(Sender: TObject);
    procedure btUpClick(Sender: TObject);
    procedure PointAddClick(Sender: TObject);
    procedure PointDelClick(Sender: TObject);
    procedure LineAddClick(Sender: TObject);
    procedure LineDelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure AppException(Sender: TObject; E: Exception);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure WMDropFiles(hDrop : THandle; hWindow : HWnd);
  public
    { Public declarations }
  end;

  TConnection = Record
   AStart, AEnd: Byte;
  end;

  TPoints = array of TSmallPoint;
  TLines = array of TConnection;

var
  Form1: TForm1;

  Entries: array of Record
   Offset: DWORD;
   Colour: Byte;
   Points: TPoints;
   Lines: TLines;
  end;

  CurrentShape: Integer = 0;
  CurrentPoint: Integer = 0;
  CurrentLine: Integer = 0;
  Zoom: Integer = 1;
  OffX: Integer = 0;
  OffY: Integer = 0;

  Palette: array[0..255] of TColor;

procedure Open(path: String);
procedure ResetView(IncludingShape: Boolean);

implementation

{$R *.dfm}
{$R palette.res}

procedure TForm1.AppException(Sender: TObject; E: Exception);
begin
 If e.ClassName<>'EConvertError' then
  raise e; 
end;

Function TryToConvert(Spin: TSpinEdit): Integer;
var Temp: Integer;
begin
 Temp:=StrToIntDef(Spin.Text,0);
 If Temp<Spin.MinValue then Temp:=Spin.MinValue;
 If Temp>Spin.MaxValue then Temp:=Spin.MaxValue;
 Result:=Temp;
end;

procedure PaintShape;
var a: Integer;
    c: TPoints;
    d: TLines;
    Center: TPoint;
begin
 If Length(Entries)<1 then Exit;
 With Form1, Form1.pbView.Canvas do begin
  c:=Entries[CurrentShape].Points;
  d:=Entries[CurrentShape].Lines;
  Brush.Color:=clWhite;
  FillRect(Rect(0,0,pbView.Width,pbView.Height));
  Brush.Style:=bsClear;
  Font.Color:=clBlue;
  Center:=Point((pbView.Width div 2)+OffX,(pbView.Height div 2)+OffY);
  If dspCenter.Checked then begin
   Pen.Color:=clBlue;
   MoveTo(Center.X-9,Center.Y); LineTo(Center.X+10,Center.Y);
   Polygon([Point(Center.X+10,Center.Y),Point(Center.X+6,Center.Y-2),Point(Center.X+6,Center.Y+2)]);
   MoveTo(Center.X,Center.Y-9); LineTo(Center.X,Center.Y+10);
   Polygon([Point(Center.X,Center.Y+10),Point(Center.X-2,Center.Y+6),Point(Center.X+2,Center.Y+6)]);
   //TextOut(Center.X+3,Center.Y+1,'(0,0)');
  end;
  Pen.Color:=clBlack;
  for a:=0 to Length(d)-1 do begin
   MoveTo(c[d[a].AStart].x*Zoom+Center.x,c[d[a].AStart].y*Zoom+Center.y);
   LineTo(c[d[a].AEnd].x*Zoom+Center.x,c[d[a].AEnd].y*Zoom+Center.y);
  end;
  If Pages.TabIndex=1 then begin
   Pen.Color:=clRed;
   MoveTo(c[d[CurrentLine].AStart].x*Zoom+Center.x,
          c[d[CurrentLine].AStart].y*Zoom+Center.y);
   LineTo(c[d[CurrentLine].AEnd].x*Zoom+Center.x,
          c[d[CurrentLine].AEnd].y*Zoom+Center.y);
  end;
  if dspPoint.Checked then begin
   Font.Color:=clBlue;
   for a:=0 to Length(c)-1 do
    TextOut(Center.X+c[a].x*Zoom+2,Center.Y+c[a].y*Zoom+2,Format('%d',[a]));
  end;
  If dspLine.Checked then begin
   Font.Color:=clFuchsia;
   Brush.Style:=bsSolid;
   for a:=0 to Length(d)-1 do
    TextOut(Center.X+((c[d[a].AStart].x+c[d[a].AEnd].x) div 2)*Zoom+1,
    Center.Y+((c[d[a].AStart].y+c[d[a].AEnd].y) div 2)*Zoom+1,Format('%d',[a]));
  end;
  If Pages.TabIndex=0 then begin
   Pen.Color:=clRed;
   Brush.Style:=bsClear;
   Ellipse(c[CurrentPoint].x*Zoom-5+Center.x,
           c[CurrentPoint].y*Zoom-5+Center.y,
           c[CurrentPoint].x*Zoom+6+Center.x,
           c[CurrentPoint].y*Zoom+6+Center.y);
  end;
  pbColour.Canvas.Brush.Color:=Palette[Entries[CurrentShape].Colour];
  pbColour.Canvas.FillRect(Rect(0,0,pbColour.Width,pbColour.Height));
 end;
end;

procedure SetValBounds;
var MaxPoints, MaxLines: Integer;
begin
 With Form1 do begin
  MaxPoints:=Length(Entries[CurrentShape].Points);
  MaxLines:=Length(Entries[CurrentShape].Lines);
  PointTot.Caption:=Format('Total %d points.',[MaxPoints]);
  LineTot.Caption:=Format('Total %d lines.',[MaxLines]);
  PointNr.MaxValue:=MaxPoints-1;
  LineNr.MaxValue:=MaxLines-1;
  LineStart.MaxValue:=MaxPoints-1;
  LineEnd.MaxValue:=MaxPoints-1;
  ResetView(False);
 end;
end;

procedure RefreshControls;
begin
 With Form1 do begin
  ShapeCol.Value:=Entries[CurrentShape].Colour;
  PointX.Value:=Entries[CurrentShape].Points[CurrentPoint].x;
  PointY.Value:=Entries[CurrentShape].Points[CurrentPoint].y;
  LineStart.Value:=Entries[CurrentShape].Lines[CurrentLine].AStart;
  LineEnd.Value:=Entries[CurrentShape].Lines[CurrentLine].AEnd;
 end;
end;

procedure Open(path: String);
var f: File;
    a, b: Integer;
    c: Byte;
begin
 AssignFile(f,path);
 Reset(f,1);
 SetLength(Entries,0);
 a:=-1;
 repeat
  Inc(a);
  SetLength(Entries,a+1);
  BlockRead(f,Entries[a].Offset,4);
 until Entries[a].Offset>=FileSize(f);
 If Entries[a].Offset<>FileSize(f) then begin
  MessageBox(Form1.handle,'Bad last offset','Simple LBA Shape Editor',MB_ICONERROR+MB_OK);
  SetLength(Entries,0);
  CloseFile(f);
  Abort;
 end;
 Form1.Label1.Caption:=Format('File contains %d shapes.',[Length(Entries)-1]);

 For a:=0 to Length(Entries)-2 do begin
  BlockRead(f,Entries[a].Colour,1);
  BlockRead(f,c,1);
  SetLength(Entries[a].Points,c);
  For b:=0 to Length(Entries[a].Points)-1 do begin
   BlockRead(f,Entries[a].Points[b].x,2);
   BlockRead(f,Entries[a].Points[b].y,2);
  end;
  BlockRead(f,c,1);
  SetLength(Entries[a].Lines,c);
  For b:=0 to Length(Entries[a].Lines)-1 do begin
   BlockRead(f,Entries[a].Lines[b].AStart,1);
   BlockRead(f,Entries[a].Lines[b].AEnd,1);
  end;
 end;
 CloseFile(f);
 Form1.Caption:='Simple LBA Shape Editor - '+ExtractFileName(path);
 Form1.Panel1.Visible:=False;
 SetValBounds;
 ResetView(True);
 RefreshControls;
 PaintShape;
 Beep;
end;

procedure CalcOffsets;
var a: Integer;
    b: DWORD;
begin
 b:=Length(Entries)*4;
 For a:=0 to Length(Entries)-1 do begin
  Entries[a].Offset:=b;
  Inc(b,3+Length(Entries[a].Points)*4+Length(Entries[a].Lines)*2);
 end;
end;

procedure Save(path: String);
var f: File;
    a, b: Integer;
    c: Byte;
begin
 CalcOffsets;
 AssignFile(f,path);
 Rewrite(f,1);
 for a:=0 to Length(Entries)-1 do
  BlockWrite(f,Entries[a].Offset,4);

 For a:=0 to Length(Entries)-2 do begin
  BlockWrite(f,Entries[a].Colour,1);
  c:=Length(Entries[a].Points);
  BlockWrite(f,c,1);
  For b:=0 to c-1 do begin
   BlockWrite(f,Entries[a].Points[b].x,2);
   BlockWrite(f,Entries[a].Points[b].y,2);
  end;
  c:=Length(Entries[a].Lines);
  BlockWrite(f,c,1);
  For b:=0 to c-1 do begin
   BlockWrite(f,Entries[a].Lines[b].AStart,1);
   BlockWrite(f,Entries[a].Lines[b].AEnd,1);
  end;
 end;
 CloseFile(f);
 Form1.Caption:='Simple LBA Shape Editor - '+ExtractFileName(path);
 Beep;
end;

procedure ResetView(IncludingShape: Boolean);
begin
 If IncludingShape then CurrentShape:=0;
 Form1.Label7.Caption:=IntToStr(CurrentShape);
 Form1.PointNr.Value:=0;
 CurrentPoint:=0;
 Form1.LineNr.Value:=0;
 CurrentLine:=0;
 OffX:=0;
 OffY:=0;
end;

procedure TForm1.ShapeNrChange(Sender: TObject);
begin
 If Length(Entries)<2 then Exit;
 If (Sender as TButton).Name='btPrev' then Dec(CurrentShape)
 else If (Sender as TButton).Name='btNext' then Inc(CurrentShape);
 If CurrentShape<0 then CurrentShape:=0;
 If CurrentShape>Length(Entries)-2 then CurrentShape:=Length(Entries)-2;
 SetValBounds;
 PaintShape;
 RefreshControls;
end;

procedure TForm1.btOpenClick(Sender: TObject);
begin
 If dlgOpen.Execute then
  Open(dlgOpen.FileName);
end;

procedure TForm1.pbViewPaint(Sender: TObject);
begin
 PaintShape;
end;

procedure TForm1.PointNrChange(Sender: TObject);
begin
 If (Sender as TSpinEdit).Name='PointNr' then
  CurrentPoint:=TryToConvert(PointNr)
 else
  CurrentLine:=TryToConvert(LineNr);
 RefreshControls;
 PaintShape;
end;

procedure TForm1.PagesChange(Sender: TObject);
begin
 PaintShape;
end;

procedure TForm1.FormCreate(Sender: TObject);
var FRes: TResourceStream;
    a: Integer;
    b: Byte;
begin
 Application.OnException:=AppException;
 Application.OnMessage:=AppMessage;
 Form1.DoubleBuffered:=True;
 DragAcceptFiles(Form1.Handle,True);

 FRes:=TResourceStream.Create(0,'LBA_2_MAIN','LBA_PALETTE');
 For a:=0 to 255 do begin
  FRes.Read(b,1);
  Palette[a]:=b;   //R
  FRes.Read(b,1);
  Palette[a]:=Palette[a]+b*256;  //G
  FRes.Read(b,1);
  Palette[a]:=Palette[a]+b*256*256;  //B
 end;
 Fres.Free;
end;

procedure TForm1.LineStartChange(Sender: TObject);
begin
 If Length(Entries)<2 then Exit;
 If (Sender as TSpinEdit).Name='LineStart' then
  Entries[CurrentShape].Lines[CurrentLine].AStart:=TryToConvert(LineStart)
 else if (Sender as TSpinEdit).Name='LineEnd' then
  Entries[CurrentShape].Lines[CurrentLine].AEnd:=TryToConvert(LineEnd)
 else if (Sender as TSpinEdit).Name='PointX' then
  Entries[CurrentShape].Points[CurrentPoint].X:=TryToConvert(PointX)
 else if (Sender as TSpinEdit).Name='PointY' then
  Entries[CurrentShape].Points[CurrentPoint].Y:=TryToConvert(PointY)
 else if (Sender as TSpinEdit).Name='ShapeCol' then
  Entries[CurrentShape].Colour:=TryToConvert(ShapeCol);
 PaintShape;
end;

procedure TForm1.OptionsClick(Sender: TObject);
begin
 PaintShape;
end;

procedure TForm1.rgZoomClick(Sender: TObject);
begin
 Case rgZoom.ItemIndex of
  0: Zoom:=1;
  1: Zoom:=2;
  2: Zoom:=4;
 end;
 PaintShape;
end;

procedure TForm1.btUpClick(Sender: TObject);
begin
 If (Sender as TButton).Name='btUp' then Inc(OffY,20)
 else If (Sender as TButton).Name='btDown' then Dec(OffY,20)
 else If (Sender as TButton).Name='btLeft' then Inc(OffX,20)
 else If (Sender as TButton).Name='btRight' then Dec(OffX,20)
 else If (Sender as TButton).Name='btCenter' then begin
  OffX:=0;
  OffY:=0;
 end;
 PaintShape;
end;

procedure TForm1.PointAddClick(Sender: TObject);
begin
 SetLength(Entries[CurrentShape].Points,Length(Entries[CurrentShape].Points)+1);
 SetValBounds;
 PointNr.Value:=PointNr.MaxValue;
 PaintShape;
end;

procedure TForm1.PointDelClick(Sender: TObject);
var a: Integer;
begin
 If Length(Entries[CurrentShape].Points)>2 then begin
  for a:=CurrentPoint to Length(Entries[CurrentShape].Points)-2 do
   Entries[CurrentShape].Points[a]:=Entries[CurrentShape].Points[a+1];
  SetLength(Entries[CurrentShape].Points,Length(Entries[CurrentShape].Points)-1);
  for a:=0 to Length(Entries[CurrentShape].Lines)-1 do begin
   If Entries[CurrentShape].Lines[a].AStart=CurrentPoint then
    Entries[CurrentShape].Lines[a].AStart:=Entries[CurrentShape].Lines[a].AEnd;
   If Entries[CurrentShape].Lines[a].AEnd=CurrentPoint then
    Entries[CurrentShape].Lines[a].AEnd:=Entries[CurrentShape].Lines[a].AStart;
   If Entries[CurrentShape].Lines[a].AStart>CurrentPoint then
    Dec(Entries[CurrentShape].Lines[a].AStart);
   If Entries[CurrentShape].Lines[a].AEnd>CurrentPoint then
    Dec(Entries[CurrentShape].Lines[a].AEnd);
  end;
  a:=CurrentPoint;
  SetValBounds;
  If a<Length(Entries[CurrentShape].Points) then PointNr.Value:=a
  else PointNr.Value:=a-1;
  PaintShape;
 end
 else
  MessageBox(Handle,'Shape must have at least two points to be visible.','LBA Shape Editor',MB_ICONWARNING+MB_OK);
end;

procedure TForm1.LineAddClick(Sender: TObject);
begin
 SetLength(Entries[CurrentShape].Lines,Length(Entries[CurrentShape].Lines)+1);
 SetValBounds;
 LineNr.Value:=LineNr.MaxValue;
 PaintShape;
end;

procedure TForm1.LineDelClick(Sender: TObject);
var a: Integer;
begin
 If Length(Entries[CurrentShape].Lines)>1 then begin
  for a:=CurrentLine to Length(Entries[CurrentShape].Lines)-2 do
   Entries[CurrentShape].Lines[a]:=Entries[CurrentShape].Lines[a+1];
  SetLength(Entries[CurrentShape].Lines,Length(Entries[CurrentShape].Lines)-1);
  a:=CurrentLine;
  SetValBounds;
  If a<Length(Entries[CurrentShape].Lines) then LineNr.Value:=a
  else LineNr.Value:=a-1;
  PaintShape;
 end
 else
  MessageBox(Handle,'Shape must have at lest one line to be visible.','LBA Shape Editor',MB_ICONWARNING+MB_OK);
end;

procedure TForm1.btSaveClick(Sender: TObject);
begin
 If dlgSave.Execute then
  Save(dlgSave.FileName);
end;

procedure TForm1.WMDropFiles(hDrop : THandle; hWindow : HWnd);
var
  TotalNumberOfFiles, nFileLength: Integer;
  pszFileName: PChar;
  DropPoint: TPoint;
begin
  //liczba zrzuconych plików
  TotalNumberOfFiles:=DragQueryFile(hDrop,$FFFFFFFF,nil,0);
  If TotalNumberOfFiles=1 then begin
   nFileLength:=DragQueryFile(hDrop,0,Nil,0)+1;
   GetMem(pszFileName,nFileLength);
   DragQueryFile(hDrop,0,pszFileName,nFileLength);
   DragQueryPoint(hDrop,DropPoint);
   //pszFileName - nazwa upuszczonego pliku
   //tutaj robimy coœ z nazw¹ pliku
   try    //¿eby wykona³o siê FreeMem je¿eli bêdzie b³¹d
    If FileExists(pszFileName) then
     Open(pszFileName)
    else
     Beep;
   except
   end;

   FreeMem(pszFileName,nFileLength);
  end
  else
   MessageBox(handle,'You can''t open more then one file at the same time','LBA Shape Editor',MB_ICONERROR+MB_OK);

  DragFinish(hDrop);
end; //sprawdzamy co zosta³o przeci¹gniête i obs³ugujemy to

procedure TForm1.AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  case Msg.Message of
   WM_DROPFILES: WMDropFiles(Msg.wParam, Msg.hWnd);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 DragAcceptFiles(Form1.Handle,False);
end;

end.
