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

unit PIXELS.Events;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Deps,
  PIXELS.Base,
  PIXELS.Math;

const
  pxMAX_AXES = 3;
  pxMAX_STICKS = 16;
  pxMAX_BUTTONS = 32;
  pxMOUSE_BUTTON_LEFT = 1;
  pxMOUSE_BUTTON_RIGHT = 2;
  pxMOUSE_BUTTON_MIDDLE = 3;

  // sticks
  pxJOY_STICK_LS = 0;
  pxJOY_STICK_RS = 1;
  pxJOY_STICK_LT = 2;
  pxJOY_STICK_RT = 3;

  // axes
  pxJOY_AXES_X = 0;
  pxJOY_AXES_Y = 1;
  pxJOY_AXES_Z = 2;

  // buttons
  pxJOY_BTN_A = 0;
  pxJOY_BTN_B = 1;
  pxJOY_BTN_X = 2;
  pxJOY_BTN_Y = 3;
  pxJOY_BTN_RB = 4;
  pxJOY_BTN_LB = 5;
  pxJOY_BTN_RT = 6;
  pxJOY_BTN_LT = 7;
  pxJOY_BTN_BACK = 8;
  pxJOY_BTN_START = 9;
  pxJOY_BTN_RDPAD = 10;
  pxJOY_BTN_LDPAD = 11;
  pxJOY_BTN_DDPAD = 12;
  pxJOY_BTN_UDPAD = 13;

{$REGION 'Keyboard Constants'}
const
  pxKEY_A = 1;
  pxKEY_B = 2;
  pxKEY_C = 3;
  pxKEY_D = 4;
  pxKEY_E = 5;
  pxKEY_F = 6;
  pxKEY_G = 7;
  pxKEY_H = 8;
  pxKEY_I = 9;
  pxKEY_J = 10;
  pxKEY_K = 11;
  pxKEY_L = 12;
  pxKEY_M = 13;
  pxKEY_N = 14;
  pxKEY_O = 15;
  pxKEY_P = 16;
  pxKEY_Q = 17;
  pxKEY_R = 18;
  pxKEY_S = 19;
  pxKEY_T = 20;
  pxKEY_U = 21;
  pxKEY_V = 22;
  pxKEY_W = 23;
  pxKEY_X = 24;
  pxKEY_Y = 25;
  pxKEY_Z = 26;
  pxKEY_0 = 27;
  pxKEY_1 = 28;
  pxKEY_2 = 29;
  pxKEY_3 = 30;
  pxKEY_4 = 31;
  pxKEY_5 = 32;
  pxKEY_6 = 33;
  pxKEY_7 = 34;
  pxKEY_8 = 35;
  pxKEY_9 = 36;
  pxKEY_PAD_0 = 37;
  pxKEY_PAD_1 = 38;
  pxKEY_PAD_2 = 39;
  pxKEY_PAD_3 = 40;
  pxKEY_PAD_4 = 41;
  pxKEY_PAD_5 = 42;
  pxKEY_PAD_6 = 43;
  pxKEY_PAD_7 = 44;
  pxKEY_PAD_8 = 45;
  pxKEY_PAD_9 = 46;
  pxKEY_F1 = 47;
  pxKEY_F2 = 48;
  pxKEY_F3 = 49;
  pxKEY_F4 = 50;
  pxKEY_F5 = 51;
  pxKEY_F6 = 52;
  pxKEY_F7 = 53;
  pxKEY_F8 = 54;
  pxKEY_F9 = 55;
  pxKEY_F10 = 56;
  pxKEY_F11 = 57;
  pxKEY_F12 = 58;
  pxKEY_ESCAPE = 59;
  pxKEY_TILDE = 60;
  pxKEY_MINUS = 61;
  pxKEY_EQUALS = 62;
  pxKEY_BACKSPACE = 63;
  pxKEY_TAB = 64;
  pxKEY_OPENBRACE = 65;
  pxKEY_CLOSEBRACE = 66;
  pxKEY_ENTER = 67;
  pxKEY_SEMICOLON = 68;
  pxKEY_QUOTE = 69;
  pxKEY_BACKSLASH = 70;
  pxKEY_BACKSLASH2 = 71;
  pxKEY_COMMA = 72;
  pxKEY_FULLSTOP = 73;
  pxKEY_SLASH = 74;
  pxKEY_SPACE = 75;
  pxKEY_INSERT = 76;
  pxKEY_DELETE = 77;
  pxKEY_HOME = 78;
  pxKEY_END = 79;
  pxKEY_PGUP = 80;
  pxKEY_PGDN = 81;
  pxKEY_LEFT = 82;
  pxKEY_RIGHT = 83;
  pxKEY_UP = 84;
  pxKEY_DOWN = 85;
  pxKEY_PAD_SLASH = 86;
  pxKEY_PAD_ASTERISK = 87;
  pxKEY_PAD_MINUS = 88;
  pxKEY_PAD_PLUS = 89;
  pxKEY_PAD_DELETE = 90;
  pxKEY_PAD_ENTER = 91;
  pxKEY_PRINTSCREEN = 92;
  pxKEY_PAUSE = 93;
  pxKEY_ABNT_C1 = 94;
  pxKEY_YEN = 95;
  pxKEY_KANA = 96;
  pxKEY_CONVERT = 97;
  pxKEY_NOCONVERT = 98;
  pxKEY_AT = 99;
  pxKEY_CIRCUMFLEX = 100;
  pxKEY_COLON2 = 101;
  pxKEY_KANJI = 102;
  pxKEY_PAD_EQUALS = 103;
  pxKEY_BACKQUOTE = 104;
  pxKEY_SEMICOLON2 = 105;
  pxKEY_COMMAND = 106;
  pxKEY_BACK = 107;
  pxKEY_VOLUME_UP = 108;
  pxKEY_VOLUME_DOWN = 109;
  pxKEY_SEARCH = 110;
  pxKEY_DPAD_CENTER = 111;
  pxKEY_BUTTON_X = 112;
  pxKEY_BUTTON_Y = 113;
  pxKEY_DPAD_UP = 114;
  pxKEY_DPAD_DOWN = 115;
  pxKEY_DPAD_LEFT = 116;
  pxKEY_DPAD_RIGHT = 117;
  pxKEY_SELECT = 118;
  pxKEY_START = 119;
  pxKEY_BUTTON_L1 = 120;
  pxKEY_BUTTON_R1 = 121;
  pxKEY_BUTTON_L2 = 122;
  pxKEY_BUTTON_R2 = 123;
  pxKEY_BUTTON_A = 124;
  pxKEY_BUTTON_B = 125;
  pxKEY_THUMBL = 126;
  pxKEY_THUMBR = 127;
  pxKEY_UNKNOWN = 128;
  pxKEY_MODIFIERS = 215;
  pxKEY_LSHIFT = 215;
  pxKEY_RSHIFT = 216;
  pxKEY_LCTRL = 217;
  pxKEY_RCTRL = 218;
  pxKEY_ALT = 219;
  pxKEY_ALTGR = 220;
  pxKEY_LWIN = 221;
  pxKEY_RWIN = 222;
  pxKEY_MENU = 223;
  pxKEY_SCROLLLOCK = 224;
  pxKEY_NUMLOCK = 225;
  pxKEY_CAPSLOCK = 226;
  pxKEY_MAX = 227;
  pxKEYMOD_SHIFT = $0001;
  pxKEYMOD_CTRL = $0002;
  pxKEYMOD_ALT = $0004;
  pxKEYMOD_LWIN = $0008;
  pxKEYMOD_RWIN = $0010;
  pxKEYMOD_MENU = $0020;
  pxKEYMOD_COMMAND = $0040;
  pxKEYMOD_SCROLOCK = $0100;
  pxKEYMOD_NUMLOCK = $0200;
  pxKEYMOD_CAPSLOCK = $0400;
  pxKEYMOD_INALTSEQ = $0800;
  pxKEYMOD_ACCENT1 = $1000;
  pxKEYMOD_ACCENT2 = $2000;
  pxKEYMOD_ACCENT3 = $4000;
  pxKEYMOD_ACCENT4 = $8000;
{$ENDREGION}

type

  { TpxInput }
  TpxInput = class(TpxStaticObject)
  private type
    TMouse = record
      Postion: TpxVector;
      Delta: TpxVector;
      Pressure: Single;
    end;

    TJoystick = record
      Name: string;
      Sticks: Integer;
      Buttons: Integer;
      StickName: array[0..pxMAX_STICKS-1] of string;
      Axes: array[0..pxMAX_STICKS-1] of Integer;
      AxesName: array[0..pxMAX_STICKS-1, 0..pxMAX_AXES-1] of string;
      Pos: array[0..pxMAX_STICKS-1, 0..pxMAX_AXES-1] of Single;
      Button: array[0..1, 0..pxMAX_BUTTONS-1] of Boolean;
      ButtonName: array[0..pxMAX_BUTTONS- 1] of string;
      procedure Setup(aNum: Integer);
      function GetPos(aStick: Integer; aAxes: Integer): Single;
      function GetButton(aButton: Integer): Boolean;
      procedure Clear();
    end;

  private class var
    FKeyCode: Integer;
    FKeyCodeRepeat: Boolean;
    FMouseButtons: array [0..1, 0..256] of Boolean;
    FKeyButtons: array [0..1, 0..256] of Boolean;
    FJoyStick: TJoystick;
    FMouse: TMouse;
  private
    class constructor Create;
    class destructor Destroy;
  public
    class function KeyCode(): Integer; static;
    class function KeyCodeRepeat: Boolean; static;
    class procedure Clear; static;
    class procedure Update; static;
    class function  KeyDown(const AKey: Cardinal): Boolean; static;
    class function  KeyPressed(const AKey: Cardinal): Boolean; static;
    class function  KeyReleased(const AKey: Cardinal): Boolean; static;
    class function  MouseDown(const AButton: Cardinal): Boolean; static;
    class function  MousePressed(const AButton: Cardinal): Boolean; static;
    class function  MouseReleased(const AButton: Cardinal): Boolean; static;
    class procedure MouseSetPos(const AX, AY: Integer); static;
    class procedure GetMouseInfo(const APosition: PpxVector; const ADelta: PpxVector; const APressure: System.PSingle); static;
    class function  JoystickDown(const AButton: Cardinal): Boolean; static;
    class function  JoystickPressed(const AButton: Cardinal): Boolean; static;
    class function  JoystickReleased(const AButton: Cardinal): Boolean; static;
    class function  JoystickPosition(const AStick, AAxes: Integer): Single; static;
  end;

implementation

uses
  System.Math,
  PIXELS.Graphics,
  PIXELS;

{ TpxInput.TJoystick }
procedure TpxInput.TJoystick.Setup(aNum: Integer);
var
  LJoyCount: Integer;
  LJoy: PALLEGRO_JOYSTICK;
  LJoyState: ALLEGRO_JOYSTICK_STATE;
  LI, LJ: Integer;
begin
  LJoyCount := al_get_num_joysticks;
  if (aNum < 0) or (aNum > LJoyCount - 1) then
    Exit;

  LJoy := al_get_joystick(aNum);
  if not Assigned(LJoy) then
  begin
    Sticks := 0;
    Buttons := 0;
    Exit;
  end;

  Name := string(al_get_joystick_name(LJoy));

  al_get_joystick_state(LJoy, @LJoyState);

  Sticks := al_get_joystick_num_sticks(LJoy);
  if (Sticks > pxMAX_STICKS) then
    Sticks := pxMAX_STICKS;

  for LI := 0 to Sticks - 1 do
  begin
    StickName[LI] := string(al_get_joystick_stick_name(LJoy, LI));
    Axes[LI] := al_get_joystick_num_axes(LJoy, LI);
    for LJ := 0 to Axes[LI] - 1 do
    begin
      Pos[LI, LJ] := LJoyState.stick[LI].axis[LJ];
      AxesName[LI, LJ] := string(al_get_joystick_axis_name(LJoy, LI, LJ));
    end;
  end;

  Buttons := al_get_joystick_num_buttons(LJoy);
  if (Buttons > pxMAX_BUTTONS) then
    Buttons := pxMAX_BUTTONS;

  for LI := 0 to Buttons - 1 do
  begin
    ButtonName[LI] := string(al_get_joystick_button_name(LJoy, LI));
    Button[0, LI] := Boolean(LJoyState.Button[LI] >= 16384);
  end
end;

function TpxInput.TJoystick.GetPos(aStick: Integer; aAxes: Integer): Single;
begin
  Result := Pos[aStick, aAxes];
end;

function TpxInput.TJoystick.GetButton(aButton: Integer): Boolean;
begin
  Result := Button[0, aButton];
end;

procedure TpxInput.TJoystick.Clear;
begin
  FillChar(Button, SizeOf(Button), False);
  FillChar(Pos, SizeOf(Pos), 0);
end;

{ TpxInput }
class constructor TpxInput.Create();
begin
  inherited;
  Clear;
  FJoyStick.Setup(0);
end;

class destructor TpxInput.Destroy();
begin
  inherited;
end;

class function TpxInput.KeyCode(): Integer;
begin
  Result := FKeyCode;
end;

class function TpxInput.KeyCodeRepeat: Boolean;
begin
  Result := FKeyCodeRepeat;
end;

class procedure TpxInput.Clear();
begin
  FKeyCode := 0;
  FKeyCodeRepeat := False;
  FillChar(FMouseButtons, SizeOf(FMouseButtons), False);
  FillChar(FKeyButtons, SizeOf(FKeyButtons), False);
  FJoystick.Clear;

  if TpxWindow.IsInit() then
  begin
    al_clear_keyboard_state(TpxWindow.Handle());
  end;
end;

class procedure TpxInput.Update();

  procedure GetMousePos(const X, Y: Integer; var APos: TpxVector);
  var
    LScale: Single;
    LPhysicalSize: TpxSize;
    LLogicalSize: TpxSize;

  begin
    if not TPixels.IsInit() then Exit;
    if not TpxWindow.IsInit() then Exit;

    // Calculate the effective scale (must match the set routine)
    LPhysicalSize := TpxWindow.GetPhysicalSize();
    LLogicalSize := TpxWindow.GetLogicalSize();
    LScale := Min(
      LPhysicalSize.w / LLogicalSize.w,
      LPhysicalSize.h / LLogicalSize.h
    );

    // Convert from physical to logical (taking into account letterboxing offset)
    APos.X := EnsureRange(
      Round((X - ((LPhysicalSize.w - LLogicalSize.w * LScale) * 0.5)) / LScale),
      0,
      Round(LLogicalSize.w-1)
    );

    APos.Y := EnsureRange(
      Round((Y - ((LPhysicalSize.h - LLogicalSize.h * LScale) * 0.5)) / LScale),
      0,
      Round(LLogicalSize.h-1)
    );
  end;

begin
  FKeyCode := 0;

  case TPixels.Event.&type of
    ALLEGRO_EVENT_KEY_CHAR:
    begin
      FKeyCode := TPixels.Event.keyboard.unichar;
      FKeyCodeRepeat := TPixels.Event.keyboard.&repeat;
    end;

    ALLEGRO_EVENT_JOYSTICK_AXIS:
    begin
      if (TPixels.Event.Joystick.stick < pxMAX_STICKS) and
        (TPixels.Event.Joystick.axis < pxMAX_AXES) then
      begin
        FJoystick.Pos[TPixels.Event.Joystick.stick][TPixels.Event.Joystick.axis] :=
          TPixels.Event.Joystick.Pos;
      end;
    end;

    ALLEGRO_EVENT_KEY_DOWN:
    begin
      FKeyButtons[0, TPixels.Event.keyboard.keycode] := True;
    end;

    ALLEGRO_EVENT_KEY_UP:
    begin
      FKeyButtons[0, TPixels.Event.keyboard.keycode] := False;
    end;

    ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
    begin
      FMouseButtons[0, TPixels.Event.mouse.button] := True;
    end;

    ALLEGRO_EVENT_MOUSE_BUTTON_UP:
    begin
      FMouseButtons[0, TPixels.Event.mouse.button] := False;
    end;

    ALLEGRO_EVENT_MOUSE_AXES:
    begin
      (*
      FMouse.Postion.X := Round(TPixels.Event.mouse.x / TpxWindow.DpiScale());
      FMouse.Postion.Y := Round(TPixels.Event.mouse.y / TpxWindow.DpiScale());
      *)
      GetMousePos(TPixels.Event.mouse.x, TPixels.Event.mouse.y, FMouse.Postion);

      FMouse.Postion.Z := TPixels.Event.mouse.z;
      FMouse.Postion.W := TPixels.Event.mouse.w;

      FMouse.Delta.X := TPixels.Event.mouse.dx;
      FMouse.Delta.Y := TPixels.Event.mouse.dy;
      FMouse.Delta.Z := TPixels.Event.mouse.dz;
      FMouse.Delta.W := TPixels.Event.mouse.dw;

      FMouse.Pressure := TPixels.Event.mouse.pressure;
    end;

    ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN:
    begin
      FJoystick.Button[0, TPixels.Event.Joystick.Button] := True;
    end;

    ALLEGRO_EVENT_JOYSTICK_BUTTON_UP:
    begin
      FJoystick.Button[0, TPixels.Event.Joystick.Button] := False;
    end;

    ALLEGRO_EVENT_JOYSTICK_CONFIGURATION:
    begin
      al_reconfigure_joysticks;
      FJoystick.Setup(0);
    end;
  end;
end;

class function  TpxInput.KeyDown(const AKey: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AKey, 0, 255) then  Exit;
  Result := FKeyButtons[0, AKey];
end;

class function  TpxInput.KeyPressed(const AKey: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AKey, 0, 255) then  Exit;
  if KeyDown(AKey) and (not FKeyButtons[1, AKey]) then
  begin
    FKeyButtons[1, AKey] := True;
    Result := True;
  end
  else if (not KeyDown(AKey)) and (FKeyButtons[1, AKey]) then
  begin
    FKeyButtons[1, AKey] := False;
    Result := False;
  end;
end;

class function  TpxInput.KeyReleased(const AKey: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AKey, 0, 255) then Exit;
  if KeyDown(AKey) and (not FKeyButtons[1, AKey]) then
  begin
    FKeyButtons[1, AKey] := True;
    Result := False;
  end
  else if (not KeyDown(AKey)) and (FKeyButtons[1, AKey]) then
  begin
    FKeyButtons[1, AKey] := False;
    Result := True;
  end;
end;

class function  TpxInput.MouseDown(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, pxMOUSE_BUTTON_LEFT, pxMOUSE_BUTTON_MIDDLE) then Exit;
  Result := FMouseButtons[0, AButton];
end;

class function  TpxInput.MousePressed(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, pxMOUSE_BUTTON_LEFT, pxMOUSE_BUTTON_MIDDLE) then Exit;

  if MouseDown(AButton) and (not FMouseButtons[1, AButton]) then
  begin
    FMouseButtons[1, AButton] := True;
    Result := True;
  end
  else if (not MouseDown(AButton)) and (FMouseButtons[1, AButton]) then
  begin
    FMouseButtons[1, AButton] := False;
    Result := False;
  end;
end;

class function  TpxInput.MouseReleased(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, pxMOUSE_BUTTON_LEFT, pxMOUSE_BUTTON_MIDDLE) then Exit;

  if MouseDown(AButton) and (not FMouseButtons[1, AButton]) then
  begin
    FMouseButtons[1, AButton] := True;
    Result := False;
  end
  else if (not MouseDown(AButton)) and (FMouseButtons[1, AButton]) then
  begin
    FMouseButtons[1, AButton] := False;
    Result := True;
  end;
end;

class procedure TpxInput.MouseSetPos(const AX, AY: Integer);
var
  PhysX, PhysY: Integer;
  Scale: Single;
  LPhysicalSize: TpxSize;
  LLogicalSize: TpxSize;
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  // Calculate the effective scale (should match how you calculate for rendering)
  LPhysicalSize := TpxWindow.GetPhysicalSize();
  LLogicalSize := TpxWindow.GetLogicalSize();

  Scale := Min(
    LPhysicalSize.w / LLogicalSize.w,
    LPhysicalSize.h / LLogicalSize.h
  );

  // Calculate offset for letterboxing (centering)
  PhysX := Round((AX * Scale) + ((LPhysicalSize.w - LLogicalSize.w * Scale) * 0.5));
  PhysY := Round((AY * Scale) + ((LPhysicalSize.h - LLogicalSize.h * Scale) * 0.5));

  al_set_mouse_xy(TpxWindow.Handle(), PhysX, PhysY);
end;

class procedure TpxInput.GetMouseInfo(const APosition: PpxVector; const ADelta: PpxVector; const APressure: System.PSingle);
begin
  if Assigned(APosition) then
    APosition^ := FMouse.Postion;
  if Assigned(ADelta) then
    ADelta^ := FMouse.Delta;
  if Assigned(APressure) then
    APressure^ := FMouse.Pressure;
end;

class function  TpxInput.JoystickDown(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, 0, pxMAX_BUTTONS-1) then Exit;
  Result := FJoystick.Button[0, AButton];
end;

class function  TpxInput.JoystickPressed(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, 0, pxMAX_BUTTONS-1) then Exit;

  if JoystickDown(AButton) and (not FJoystick.Button[1, AButton]) then
  begin
    FJoystick.Button[1, AButton] := True;
    Result := True;
  end
  else if (not JoystickDown(AButton)) and (FJoystick.Button[1, AButton]) then
  begin
    FJoystick.Button[1, AButton] := False;
    Result := False;
  end;
end;

class function  TpxInput.JoystickReleased(const AButton: Cardinal): Boolean;
begin
  Result := False;
  if not InRange(AButton, 0, pxMAX_BUTTONS-1) then Exit;

  if JoystickDown(AButton) and (not FJoystick.Button[1, AButton]) then
  begin
    FJoystick.Button[1, AButton] := True;
    Result := False;
  end
  else if (not JoystickDown(AButton)) and (FJoystick.Button[1, AButton]) then
  begin
    FJoystick.Button[1, AButton] := False;
    Result := True;
  end;
end;

class function  TpxInput.JoystickPosition(const AStick, AAxes: Integer): Single;
begin
  Result := 0;
  if not InRange(AStick, 0, pxMAX_STICKS-1) then Exit;
  if not InRange(AAxes, 0, pxMAX_AXES-1) then Exit;
  Result := FJoystick.Pos[AStick, AAxes];
end;

end.
