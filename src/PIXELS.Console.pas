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

unit PIXELS.Console;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Base,
  PIXELS.Graphics;

const
  pxLF   = AnsiChar(#10);
  pxCR   = AnsiChar(#13);
  pxCRLF = pxLF+pxCR;
  pxESC  = AnsiChar(#27);

  VK_ESC = 27;

  // Cursor Movement
  pxCSICursorPos       = pxESC + '[%d;%dH';     // Set cursor to (row, col)
  pxCSICursorUp        = pxESC + '[%dA';        // Move cursor up by n lines
  pxCSICursorDown      = pxESC + '[%dB';        // Move cursor down by n lines
  pxCSICursorForward   = pxESC + '[%dC';        // Move cursor forward (right) by n columns
  pxCSICursorBack      = pxESC + '[%dD';        // Move cursor back (left) by n columns
  pxCSISaveCursorPos   = pxESC + '[s';          // Save current cursor position
  pxCSIRestoreCursorPos= pxESC + '[u';          // Restore previously saved cursor position
  pxCSICursorHomePos   = pxESC + '[H';          // Move cursor to home position (1,1)

  // Cursor Visibility
  pxCSIShowCursor      = pxESC + '[?25h';       // Show cursor
  pxCSIHideCursor      = pxESC + '[?25l';       // Hide cursor
  pxCSIBlinkCursor     = pxESC + '[?12h';       // Enable blinking cursor
  pxCSISteadyCursor    = pxESC + '[?12l';       // Disable blinking cursor (steady)

  // Screen Manipulation
  pxCSIClearScreen     = pxESC + '[2J';         // Clear entire screen and move cursor to home
  pxCSIClearLine       = pxESC + '[2K';         // Clear entire current line
  pxCSIClearToEndOfLine= pxESC + '[K';          // Clear from cursor to end of line
  pxCSIScrollUp        = pxESC + '[%dS';        // Scroll screen up by n lines
  pxCSIScrollDown      = pxESC + '[%dT';        // Scroll screen down by n lines

  // Text Formatting
  pxCSIBold            = pxESC + '[1m';         // Enable bold text
  pxCSIUnderline       = pxESC + '[4m';         // Enable underline
  pxCSIResetFormat     = pxESC + '[0m';         // Reset all text attributes
  pxCSIResetBackground = pxESC + '[49m';           // Reset background color to default
  pxCSIResetForeground = pxESC + '[39m';           // Reset foreground color to default
  pxCSIInvertColors    = pxESC + '[7m';         // Invert foreground and background colors
  pxCSINormalColors    = pxESC + '[27m';        // Disable inverted colors

  pxCSIDim             = pxESC + '[2m';         // Dim (faint) text
  pxCSIItalic          = pxESC + '[3m';         // Italic text
  pxCSIBlink           = pxESC + '[5m';         // Blinking text
  pxCSIFramed          = pxESC + '[51m';        // Framed text
  pxCSIEncircled       = pxESC + '[52m';        // Encircled text

  // Text Modification
  pxCSIInsertChar      = pxESC + '[%d@';        // Insert n blank characters at cursor
  pxCSIDeleteChar      = pxESC + '[%dP';        // Delete n characters at cursor
  pxCSIEraseChar       = pxESC + '[%dX';        // Erase n characters at cursor (replaces with space)

  // Colors (Foreground)
  pxCSIFGBlack         = pxESC + '[30m';        // Set foreground to black
  pxCSIFGRed           = pxESC + '[31m';        // Set foreground to red
  pxCSIFGGreen         = pxESC + '[32m';        // Set foreground to green
  pxCSIFGYellow        = pxESC + '[33m';        // Set foreground to yellow
  pxCSIFGBlue          = pxESC + '[34m';        // Set foreground to blue
  pxCSIFGMagenta       = pxESC + '[35m';        // Set foreground to magenta
  pxCSIFGCyan          = pxESC + '[36m';        // Set foreground to cyan
  pxCSIFGWhite         = pxESC + '[37m';        // Set foreground to white

  // Colors (Background)
  pxCSIBGBlack         = pxESC + '[40m';        // Set background to black
  pxCSIBGRed           = pxESC + '[41m';        // Set background to red
  pxCSIBGGreen         = pxESC + '[42m';        // Set background to green
  pxCSIBGYellow        = pxESC + '[43m';        // Set background to yellow
  pxCSIBGBlue          = pxESC + '[44m';        // Set background to blue
  pxCSIBGMagenta       = pxESC + '[45m';        // Set background to magenta
  pxCSIBGCyan          = pxESC + '[46m';        // Set background to cyan
  pxCSIBGWhite         = pxESC + '[47m';        // Set background to white

  // Bright Foreground Colors
  pxCSIFGBrightBlack   = pxESC + '[90m';        // Set bright foreground to black (gray)
  pxCSIFGBrightRed     = pxESC + '[91m';        // Set bright foreground to red
  pxCSIFGBrightGreen   = pxESC + '[92m';        // Set bright foreground to green
  pxCSIFGBrightYellow  = pxESC + '[93m';        // Set bright foreground to yellow
  pxCSIFGBrightBlue    = pxESC + '[94m';        // Set bright foreground to blue
  pxCSIFGBrightMagenta = pxESC + '[95m';        // Set bright foreground to magenta
  pxCSIFGBrightCyan    = pxESC + '[96m';        // Set bright foreground to cyan
  pxCSIFGBrightWhite   = pxESC + '[97m';        // Set bright foreground to white

  // Bright Background Colors
  pxCSIBGBrightBlack   = pxESC + '[100m';       // Set bright background to black (gray)
  pxCSIBGBrightRed     = pxESC + '[101m';       // Set bright background to red
  pxCSIBGBrightGreen   = pxESC + '[102m';       // Set bright background to green
  pxCSIBGBrightYellow  = pxESC + '[103m';       // Set bright background to yellow
  pxCSIBGBrightBlue    = pxESC + '[104m';       // Set bright background to blue
  pxCSIBGBrightMagenta = pxESC + '[105m';       // Set bright background to magenta
  pxCSIBGBrightCyan    = pxESC + '[106m';       // Set bright background to cyan
  pxCSIBGBrightWhite   = pxESC + '[107m';       // Set bright background to white

  // RGB Colors
  pxCSIFGRGB           = pxESC + '[38;2;%d;%d;%dm'; // Set foreground to RGB color
  pxCSIBGRGB           = pxESC + '[48;2;%d;%d;%dm'; // Set background to RGB color

type

  { TpxCharSet }
  TpxCharSet = set of AnsiChar;

  { TpxConsole }
  TpxConsole = class(TpxStaticObject)
  private class var
    FTeletypeDelay: Integer;
    FKeyState: array [0..1, 0..255] of Boolean;
    FPerformanceFrequency: Int64;
  private
    class constructor Create();
    class destructor Destroy();
  public
    class function  HasConsoleOutput(): Boolean; static;
    class function  StartedFromConsole(): Boolean; static;
    class function  StartedFromDelphiIDE(): Boolean; static;

    class function  CreateForegroundColor(const ARed, AGreen, ABlue: Byte): string; overload; static;
    class function  CreateForegroundColor(const AColor: TpxColor): string; overload; static;
    class function  CreateBackgroundColor(const ARed, AGreen, ABlue: Byte): string; overload; static;
    class function  CreateBackgroundColor(const AColor: TpxColor): string; overload; static;

    class procedure SetForegroundColor(const ARed, AGreen, ABlue: Byte); overload; static;
    class procedure SetForegroundColor(const AColor: TpxColor); overload; static;
    class procedure SetBackgroundColor(const ARed, AGreen, ABlue: Byte); overload; static;
    class procedure SetBackgroundColor(const AColor: TpxColor); overload; static;

    class procedure SetBoldText(); static;
    class procedure ResetTextFormat(); static;

    class procedure Print(const AMsg: string; const AResetFormat: Boolean = True); overload; static;
    class procedure PrintLn(const AMsg: string; const AResetFormat: Boolean = True); overload; static;
    class procedure Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;
    class procedure PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;
    class procedure Print(const AResetFormat: Boolean = True); overload; static;
    class procedure PrintLn(const AResetFormat: Boolean = True); overload; static;

    class function  GetClipboardText(): string; static;
    class procedure SetClipboardText(const AText: string); static;

    class procedure GetCursorPos(X, Y: PInteger); static;
    class procedure SetCursorPos(const X, Y: Integer); static;
    class procedure SetCursorVisible(const AVisible: Boolean); static;
    class procedure HideCursor(); static;
    class procedure ShowCursor(); static;
    class procedure SaveCursorPos(); static;
    class procedure RestoreCursorPos(); static;
    class procedure MoveCursorUp(const ALines: Integer); static;
    class procedure MoveCursorDown(const ALines: Integer); static;
    class procedure MoveCursorForward(const ACols: Integer); static;
    class procedure MoveCursorBack(const ACols: Integer); static;

    class procedure ClearScreen(); static;
    class procedure ClearLine(); static;
    class procedure ClearToEndOfLine(); static;
    class procedure ClearLineFromCursor(const AColor: string); static;

    class procedure GetSize(AWidth: PInteger; AHeight: PInteger); static;

    class function  GetTitle(): string; static;
    class procedure SetTitle(const ATitle: string); static;

    class function  AnyKeyPressed(): Boolean; static;
    class procedure ClearKeyStates(); static;
    class procedure ClearKeyboardBuffer(); static;
    class procedure WaitForAnyConsoleKey(); static;
    class function  IsKeyPressed(AKey: Byte): Boolean;
    class function  WasKeyReleased(AKey: Byte): Boolean;
    class function  WasKeyPressed(AKey: Byte): Boolean;
    class function  ReadKey(): WideChar;
    class function  ReadLnX(const AAllowedChars: TpxCharSet; AMaxLength: Integer; const AColor: string): string;

    class function  WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TpxCharSet = [' ', '-', ',', ':', #9]): string; static;
    class procedure Teletype(const AText: string; const AColor: string = pxCSIFGWhite; const AMargin: Integer = 10; const AMinDelay: Integer = 0; const AMaxDelay: Integer = 3; const ABreakKey: Byte = VK_ESC); static;

    class procedure Wait(const AMilliseconds: Double); static;

    class procedure Pause(const AForcePause: Boolean=False; AColor: string=''; const AMsg: string=''); static;
  end;

implementation

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  PIXELS.Utils,
  PIXELS.Math;

{ TpxConsole }
class constructor TpxConsole.Create();
begin
  inherited;

  FTeletypeDelay := 0;
  QueryPerformanceFrequency(FPerformanceFrequency);
  ClearKeyStates();
end;

class destructor TpxConsole.Destroy();
begin
  inherited;
end;

class function  TpxConsole.HasConsoleOutput(): Boolean;
var
  LStdHandle: THandle;
begin
  LStdHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  Result := (LStdHandle <> INVALID_HANDLE_VALUE) and
            (GetFileType(LStdHandle) = FILE_TYPE_CHAR);
end;

class function  TpxConsole.CreateForegroundColor(const ARed, AGreen, ABlue: Byte): string;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;
  Result := Format(pxCSIFGRGB, [ARed, AGreen, ABlue])
end;

class function  TpxConsole.CreateForegroundColor(const AColor: TpxColor): string;
var
  r,g,b: Byte;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);

  Result := Format(pxCSIFGRGB, [r, g, b]);
end;

class function  TpxConsole.CreateBackgroundColor(const ARed, AGreen, ABlue: Byte): string;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  Result := '';
  if not HasConsoleOutput() then Exit;

  Result := Format(pxCSIBGRGB, [ARed, AGreen, ABlue]);
end;

class function  TpxConsole.CreateBackgroundColor(const AColor: TpxColor): string;
var
  r,g,b: Byte;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);

  Result := Format(pxCSIBGRGB, [r, g, b]);
end;

class procedure TpxConsole.SetForegroundColor(const ARed, AGreen, ABlue: Byte);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSIFGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TpxConsole.SetForegroundColor(const AColor: TpxColor);
var
  r, g, b: Byte;
begin
  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);
  SetForegroundColor(r, g, b);
end;

class procedure TpxConsole.SetBackgroundColor(const ARed, AGreen, ABlue: Byte);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSIBGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TpxConsole.SetBackgroundColor(const AColor: TpxColor);
var
  r, g, b: Byte;
begin
  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);
  SetBackgroundColor(r, g, b);
end;

class procedure TpxConsole.Print(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs)+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs) + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.Print(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS :=  sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class function  TpxConsole.GetClipboardText(): string;
var
  Handle: THandle;
  Ptr: PChar;
begin
  Result := '';
  if not OpenClipboard(0) then Exit;
  try
    Handle := GetClipboardData(CF_TEXT);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Result := Ptr;
        GlobalUnlock(Handle);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

class procedure TpxConsole.SetClipboardText(const AText: string);
var
  Handle: THandle;
  Ptr: PChar;
  Size: Integer;
begin
  if not OpenClipboard(0) then Exit;
  try
    EmptyClipboard;
    Size := (Length(AText) + 1) * SizeOf(Char);
    Handle := GlobalAlloc(GMEM_MOVEABLE, Size);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Move(PChar(AText)^, Ptr^, Size);
        GlobalUnlock(Handle);
        SetClipboardData(CF_TEXT, Handle);
      end else
        GlobalFree(Handle);
    end;
  finally
    CloseClipboard;
  end;
end;

class procedure TpxConsole.GetCursorPos(X, Y: PInteger);
var
  hConsole: THandle;
  BufferInfo: TConsoleScreenBufferInfo;
begin
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  if hConsole = INVALID_HANDLE_VALUE then
    Exit;

  if not GetConsoleScreenBufferInfo(hConsole, BufferInfo) then
    Exit;

  if Assigned(X) then
    X^ := BufferInfo.dwCursorPosition.X;
  if Assigned(Y) then
    Y^ := BufferInfo.dwCursorPosition.Y;
end;

class procedure TpxConsole.SetCursorPos(const X, Y: Integer);
begin
  if not HasConsoleOutput() then Exit;
  // CSICursorPos expects Y parameter first, then X
  Write(Format(pxCSICursorPos, [Y + 1, X + 1])); // +1 because ANSI is 1-based
end;

class procedure TpxConsole.SetCursorVisible(const AVisible: Boolean);
var
  ConsoleInfo: TConsoleCursorInfo;
  ConsoleHandle: THandle;
begin
  ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  ConsoleInfo.dwSize := 25; // You can adjust cursor size if needed
  ConsoleInfo.bVisible := AVisible;
  SetConsoleCursorInfo(ConsoleHandle, ConsoleInfo);
end;

class procedure TpxConsole.HideCursor();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIHideCursor);
end;

class procedure TpxConsole.ShowCursor();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIShowCursor);
end;

class procedure TpxConsole.SaveCursorPos();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSISaveCursorPos);
end;

class procedure TpxConsole.RestoreCursorPos();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIRestoreCursorPos);
end;

class procedure TpxConsole.MoveCursorUp(const ALines: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorUp, [ALines]));
end;

class procedure TpxConsole.MoveCursorDown(const ALines: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorDown, [ALines]));
end;

class procedure TpxConsole.MoveCursorForward(const ACols: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorForward, [ACols]));
end;

class procedure TpxConsole.MoveCursorBack(const ACols: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorBack, [ACols]));
end;

class procedure TpxConsole.ClearScreen();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIClearScreen);
  Write(pxESC + '[3J');
  Write(pxCSICursorHomePos);
end;

class procedure TpxConsole.ClearLine();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCR);
  Write(pxCSIClearLine);
end;

class procedure TpxConsole.ClearToEndOfLine();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIClearToEndOfLine);
end;

class procedure TpxConsole.ClearLineFromCursor(const AColor: string);
var
  LConsoleOutput: THandle;
  LConsoleInfo: TConsoleScreenBufferInfo;
  LNumCharsWritten: DWORD;
  LCoord: TCoord;
begin
  LConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(LConsoleOutput, LConsoleInfo) then
  begin
    LCoord.X := 0;
    LCoord.Y := LConsoleInfo.dwCursorPosition.Y;

    Print(AColor);
    FillConsoleOutputCharacter(LConsoleOutput, ' ', LConsoleInfo.dwSize.X
      - LConsoleInfo.dwCursorPosition.X, LCoord, LNumCharsWritten);
    SetConsoleCursorPosition(LConsoleOutput, LCoord);
  end;
end;

class procedure TpxConsole.SetBoldText();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIBold);
end;

class procedure TpxConsole.ResetTextFormat();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIResetFormat);
end;

class procedure TpxConsole.GetSize(AWidth: PInteger; AHeight: PInteger);
var
  LConsoleInfo: TConsoleScreenBufferInfo;
begin
  if not HasConsoleOutput() then Exit;

  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), LConsoleInfo);
  if Assigned(AWidth) then
    AWidth^ := LConsoleInfo.dwSize.X;

  if Assigned(AHeight) then
  AHeight^ := LConsoleInfo.dwSize.Y;
end;

class function  TpxConsole.GetTitle(): string;
const
  MAX_TITLE_LENGTH = 1024;
var
  LTitle: array[0..MAX_TITLE_LENGTH] of WideChar;
  LTitleLength: DWORD;
begin
  // Get the console title and store it in LTitle
  LTitleLength := GetConsoleTitleW(LTitle, MAX_TITLE_LENGTH);

  // If the title is retrieved, assign it to the result
  if LTitleLength > 0 then
    Result := string(LTitle)
  else
    Result := '';
end;

class procedure TpxConsole.SetTitle(const ATitle: string);
begin
  WinApi.Windows.SetConsoleTitle(PChar(ATitle));
end;

class function  TpxConsole.AnyKeyPressed(): Boolean;
var
  LNumberOfEvents     : DWORD;
  LBuffer             : TInputRecord;
  LNumberOfEventsRead : DWORD;
  LStdHandle           : THandle;
begin
  Result:=false;
  //get the console handle
  LStdHandle := GetStdHandle(STD_INPUT_HANDLE);
  LNumberOfEvents:=0;
  //get the number of events
  GetNumberOfConsoleInputEvents(LStdHandle,LNumberOfEvents);
  if LNumberOfEvents<> 0 then
  begin
    //retrieve the event
    PeekConsoleInput(LStdHandle,LBuffer,1,LNumberOfEventsRead);
    if LNumberOfEventsRead <> 0 then
    begin
      if LBuffer.EventType = KEY_EVENT then //is a Keyboard event?
      begin
        if LBuffer.Event.KeyEvent.bKeyDown then //the key was pressed?
          Result:=true
        else
          FlushConsoleInputBuffer(LStdHandle); //flush the buffer
      end
      else
      FlushConsoleInputBuffer(LStdHandle);//flush the buffer
    end;
  end;
end;

class procedure TpxConsole.ClearKeyStates();
begin
  FillChar(FKeyState, SizeOf(FKeyState), 0);
  ClearKeyboardBuffer();
end;

class procedure TpxConsole.ClearKeyboardBuffer();
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
  LMsg: TMsg;
begin
  while PeekConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead) and (LEventsRead > 0) do
  begin
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  end;

  while PeekMessage(LMsg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE) do
  begin
    // No operation; just removing messages from the queue
  end;
end;

class procedure TpxConsole.WaitForAnyConsoleKey();
var
  LInputRec: TInputRecord;
  LNumRead: Cardinal;
  LOldMode: DWORD;
  LStdIn: THandle;
begin
  LStdIn := GetStdHandle(STD_INPUT_HANDLE);
  GetConsoleMode(LStdIn, LOldMode);
  SetConsoleMode(LStdIn, 0);
  repeat
    ReadConsoleInput(LStdIn, LInputRec, 1, LNumRead);
  until (LInputRec.EventType and KEY_EVENT <> 0) and
    LInputRec.Event.KeyEvent.bKeyDown;
  SetConsoleMode(LStdIn, LOldMode);
end;

class function  TpxConsole.IsKeyPressed(AKey: Byte): Boolean;
begin
  Result := (GetAsyncKeyState(AKey) and $8000) <> 0;
end;

class function  TpxConsole.WasKeyReleased(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := True;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := False;
  end;
end;

class function  TpxConsole.WasKeyPressed(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := False;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := True;
  end;
end;

class function  TpxConsole.ReadKey(): WideChar;
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
begin
  repeat
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  until (LInputRecord.EventType = KEY_EVENT) and LInputRecord.Event.KeyEvent.bKeyDown;
  Result := LInputRecord.Event.KeyEvent.UnicodeChar;
end;

class function  TpxConsole.ReadLnX(const AAllowedChars: TpxCharSet; AMaxLength: Integer; const AColor: string): string;
var
  LInputChar: Char;
begin
  Result := '';

  repeat
    LInputChar := ReadKey;

    if CharInSet(LInputChar, AAllowedChars) then
    begin
      if Length(Result) < AMaxLength then
      begin
        if not CharInSet(LInputChar, [#10, #0, #13, #8])  then
        begin
          //Print(LInputChar, AColor);
          Print('%s%s', [AColor, LInputChar]);
          Result := Result + LInputChar;
        end;
      end;
    end;
    if LInputChar = #8 then
    begin
      if Length(Result) > 0 then
      begin
        //Print(#8 + ' ' + #8);
        Print(#8 + ' ' + #8, []);
        Delete(Result, Length(Result), 1);
      end;
    end;
  until (LInputChar = #13);

  PrintLn();
end;

class function  TpxConsole.WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TpxCharSet): string;
var
  LText: string;
  LPos: integer;
  LChar: Char;
  LLen: Integer;
  I: Integer;
begin
  LText := ALine.Trim;

  LPos := 0;
  LLen := 0;

  while LPos < LText.Length do
  begin
    Inc(LPos);

    LChar := LText[LPos];

    if LChar = #10 then
    begin
      LLen := 0;
      continue;
    end;

    Inc(LLen);

    if LLen >= AMaxCol then
    begin
      for I := LPos downto 1 do
      begin
        LChar := LText[I];

        if CharInSet(LChar, ABreakChars) then
        begin
          LText.Insert(I, #10);
          Break;
        end;
      end;

      LLen := 0;
    end;
  end;

  Result := LText;
end;

class procedure TpxConsole.Teletype(const AText: string; const AColor: string; const AMargin: Integer; const AMinDelay: Integer; const AMaxDelay: Integer; const ABreakKey: Byte);
var
  LText: string;
  LMaxCol: Integer;
  LChar: Char;
  LWidth: Integer;
begin
  GetSize(@LWidth, nil);
  LMaxCol := LWidth - AMargin;

  LText := WrapTextEx(AText, LMaxCol);

  for LChar in LText do
  begin
    TpxUtils.ProcessMessages();
    Print('%s%s', [AColor, LChar]);
    if not TpxMath.RandomBool() then
      FTeletypeDelay := TpxMath.RandomRangeInt(AMinDelay, AMaxDelay);
    Wait(FTeletypeDelay);
    if IsKeyPressed(ABreakKey) then
    begin
      ClearKeyboardBuffer;
      Break;
    end;
  end;
end;

class procedure TpxConsole.Wait(const AMilliseconds: Double);
var
  LStartCount, LCurrentCount: Int64;
  LElapsedTime: Double;

begin
  // Get the starting value of the performance counter
  QueryPerformanceCounter(LStartCount);

  // Convert milliseconds to seconds for precision timing
  repeat
    QueryPerformanceCounter(LCurrentCount);
    LElapsedTime := (LCurrentCount - LStartCount) / FPerformanceFrequency * 1000.0; // Convert to milliseconds
  until LElapsedTime >= AMilliseconds;
end;

class function  TpxConsole.StartedFromConsole(): Boolean;
var
  LStartupInfo: TStartupInfo;
begin
  LStartupInfo.cb := SizeOf(TStartupInfo);
  GetStartupInfo(LStartupInfo);
  Result := ((LStartupInfo.dwFlags and STARTF_USESHOWWINDOW) = 0);
end;

class function TpxConsole.StartedFromDelphiIDE(): Boolean;
begin
  // Check if the IDE environment variable is present
  Result := (GetEnvironmentVariable('BDS') <> '');
end;

class procedure TpxConsole.Pause(const AForcePause: Boolean; AColor: string; const AMsg: string);
var
  LDoPause: Boolean;
begin
  if not HasConsoleOutput then Exit;

  ClearKeyboardBuffer();

  if not AForcePause then
  begin
    LDoPause := True;
    if StartedFromConsole() then LDoPause := False;
    if StartedFromDelphiIDE() then LDoPause := True;
    if not LDoPause then Exit;
  end;

  //ShowCursor();

  PrintLn();
  if AMsg = '' then
    Print('%sPress any key to continue... ', [aColor])
  else
    Print('%s%s', [aColor, AMsg]);

  WaitForAnyConsoleKey();
  PrintLn();
end;

function EnableVirtualTerminalProcessing(): Boolean;
var
  HOut: THandle;
  LMode: DWORD;
begin
  Result := False;

  HOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if HOut = INVALID_HANDLE_VALUE then Exit;
  if not GetConsoleMode(HOut, LMode) then Exit;

  LMode := LMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
  if not SetConsoleMode(HOut, LMode) then Exit;

  Result := True;
end;

initialization
  if not EnableVirtualTerminalProcessing() then
    TpxUtils.FatalError('ERROR: Virtual Terminal Processing not supported. Console features unavailable.', []);

  SetConsoleCP(CP_UTF8);
  SetConsoleOutputCP(CP_UTF8);

finalization

end.
