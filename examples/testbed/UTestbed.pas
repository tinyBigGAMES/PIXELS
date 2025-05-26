{==============================================================================
    ___ _____  _____ _    ___ ™
   | _ \_ _\ \/ / __| |  / __|
   |  _/| | >  <| _|| |__\__ \
   |_| |___/_/\_\___|____|___/
 Advanced Delphi 2D Game Library

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/PIXELS

 BSD 3-Clause License

 Copyright (c) 2025-present, tinyBigGAMES LLC

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
==============================================================================}

unit UTestbed;

interface

uses
  WinApi.Windows,
  System.Types,
  System.SysUtils,
  System.StrUtils,
  System.IOUtils,
  System.Classes,
  System.Math,
  PIXELS.Deps,
  PIXELS.Console,
  PIXELS.Graphics,
  PIXELS.IO,
  PIXELS.Audio,
  PIXELS.Game,
  PIXELS,
  UMisc,
  UParticleUniverse,
  UPlasmaFire,
  UStarfield,
  UDefender,
  UAsteroids;

procedure RunTests();

implementation

procedure Pause();
begin
  writeln;
  write('Press ENTER to continue...');
  readln;
  writeln;
end;

procedure Test01();
begin
  if TpxFile.BuildZip('Data.zip', 'res',
    procedure (const AFilename: string; const AProgress: Integer; const ANewFile: Boolean; const AUserData: Pointer)
    begin
      if aNewFile then TpxConsole.PrintLn();
      TpxConsole.SetForegroundColor(pxGREEN);
      TpxConsole.Print(pxCR+'Adding %s(%d%%)...', [TPath.GetFileName(AFilename), aProgress]);
    end) then
    TpxConsole.PrintLn(pxCSIFGCyan+pxCRLF+'Success!')
  else
    TpxConsole.PrintLn(pxCSIFGRed+pxCRLF+'Failed!');
end;

procedure RunTests();
var
  LNum: Integer;
begin
  TpxConsole.ClearScreen();
  TpxConsole.SetForegroundColor(pxDARKKHAKI);
  TPixels.PrintAsciiLogo();
  TpxConsole.SetForegroundColor(pxWHITE);
  TpxConsole.PrintLn('        Version %s', [TPixels.GetVersion()], False);

  LNum := 01;

  case LNum of
    01: Test01();
    02: pxRunGame(TParticleUniverse);
    03: pxRunGame(TPlasmaFire);
    04: pxrunGame(TStarfield);
    05: pxRunGame(TDefender);
    06: pxRunGame(TAsteroids);
    07: pxRunGame(TTest01);
  end;

  TpxConsole.Pause();
end;

end.
