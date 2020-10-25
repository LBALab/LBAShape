//******************************************************************************
// LBA Shape Editor - editing lsh (shape) files from Little Big Adventure 1 & 2
//
// This is the main program file.
//
// Copyright (C) Zink
// e-mail: zink@poczta.onet.pl
//
// This source code is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This source code is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License (License.txt) for more details.
//******************************************************************************

program LBAShape;

uses
  Forms, SysUtils,
  LBAShape1 in 'LBAShape1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);

  If ParamCount>0 then
   If FileExists(ParamStr(1)) then
    Open(ParamStr(1));

  Application.Run;
end.
