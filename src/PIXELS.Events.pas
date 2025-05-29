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

/// <summary>
/// Maximum number of axes supported per joystick stick (X, Y, Z)
/// </summary>
const
  pxMAX_AXES = 3;

/// <summary>
/// Maximum number of joystick sticks supported per device
/// </summary>
const
  pxMAX_STICKS = 16;

/// <summary>
/// Maximum number of buttons supported per joystick device
/// </summary>
const
  pxMAX_BUTTONS = 32;

/// <summary>
/// Mouse left button identifier for mouse input functions
/// </summary>
const
  pxMOUSE_BUTTON_LEFT = 1;

/// <summary>
/// Mouse right button identifier for mouse input functions
/// </summary>
const
  pxMOUSE_BUTTON_RIGHT = 2;

/// <summary>
/// Mouse middle button identifier for mouse input functions
/// </summary>
const
  pxMOUSE_BUTTON_MIDDLE = 3;

/// <summary>
/// Left analog stick identifier for dual-stick controllers
/// </summary>
const
  pxJOY_STICK_LS = 0;

/// <summary>
/// Right analog stick identifier for dual-stick controllers
/// </summary>
const
  pxJOY_STICK_RS = 1;

/// <summary>
/// Left trigger stick identifier for gamepad controllers
/// </summary>
const
  pxJOY_STICK_LT = 2;

/// <summary>
/// Right trigger stick identifier for gamepad controllers
/// </summary>
const
  pxJOY_STICK_RT = 3;

/// <summary>
/// X-axis identifier for joystick stick position queries
/// </summary>
const
  pxJOY_AXES_X = 0;

/// <summary>
/// Y-axis identifier for joystick stick position queries
/// </summary>
const
  pxJOY_AXES_Y = 1;

/// <summary>
/// Z-axis identifier for joystick stick position queries (typically pressure or twist)
/// </summary>
const
  pxJOY_AXES_Z = 2;

/// <summary>
/// A button identifier for Xbox-style controllers (bottom face button)
/// </summary>
const
  pxJOY_BTN_A = 0;

/// <summary>
/// B button identifier for Xbox-style controllers (right face button)
/// </summary>
const
  pxJOY_BTN_B = 1;

/// <summary>
/// X button identifier for Xbox-style controllers (left face button)
/// </summary>
const
  pxJOY_BTN_X = 2;

/// <summary>
/// Y button identifier for Xbox-style controllers (top face button)
/// </summary>
const
  pxJOY_BTN_Y = 3;

/// <summary>
/// Right bumper button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_RB = 4;

/// <summary>
/// Left bumper button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_LB = 5;

/// <summary>
/// Right trigger button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_RT = 6;

/// <summary>
/// Left trigger button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_LT = 7;

/// <summary>
/// Back/Select button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_BACK = 8;

/// <summary>
/// Start button identifier for gamepad controllers
/// </summary>
const
  pxJOY_BTN_START = 9;

/// <summary>
/// Right directional pad button identifier
/// </summary>
const
  pxJOY_BTN_RDPAD = 10;

/// <summary>
/// Left directional pad button identifier
/// </summary>
const
  pxJOY_BTN_LDPAD = 11;

/// <summary>
/// Down directional pad button identifier
/// </summary>
const
  pxJOY_BTN_DDPAD = 12;

/// <summary>
/// Up directional pad button identifier
/// </summary>
const
  pxJOY_BTN_UDPAD = 13;

{$REGION 'Keyboard Constants'}
/// <summary>
/// Keyboard key code for the 'A' key
/// </summary>
const
  pxKEY_A = 1;

/// <summary>
/// Keyboard key code for the 'B' key
/// </summary>
const
  pxKEY_B = 2;

/// <summary>
/// Keyboard key code for the 'C' key
/// </summary>
const
  pxKEY_C = 3;

/// <summary>
/// Keyboard key code for the 'D' key
/// </summary>
const
  pxKEY_D = 4;

/// <summary>
/// Keyboard key code for the 'E' key
/// </summary>
const
  pxKEY_E = 5;

/// <summary>
/// Keyboard key code for the 'F' key
/// </summary>
const
  pxKEY_F = 6;

/// <summary>
/// Keyboard key code for the 'G' key
/// </summary>
const
  pxKEY_G = 7;

/// <summary>
/// Keyboard key code for the 'H' key
/// </summary>
const
  pxKEY_H = 8;

/// <summary>
/// Keyboard key code for the 'I' key
/// </summary>
const
  pxKEY_I = 9;

/// <summary>
/// Keyboard key code for the 'J' key
/// </summary>
const
  pxKEY_J = 10;

/// <summary>
/// Keyboard key code for the 'K' key
/// </summary>
const
  pxKEY_K = 11;

/// <summary>
/// Keyboard key code for the 'L' key
/// </summary>
const
  pxKEY_L = 12;

/// <summary>
/// Keyboard key code for the 'M' key
/// </summary>
const
  pxKEY_M = 13;

/// <summary>
/// Keyboard key code for the 'N' key
/// </summary>
const
  pxKEY_N = 14;

/// <summary>
/// Keyboard key code for the 'O' key
/// </summary>
const
  pxKEY_O = 15;

/// <summary>
/// Keyboard key code for the 'P' key
/// </summary>
const
  pxKEY_P = 16;

/// <summary>
/// Keyboard key code for the 'Q' key
/// </summary>
const
  pxKEY_Q = 17;

/// <summary>
/// Keyboard key code for the 'R' key
/// </summary>
const
  pxKEY_R = 18;

/// <summary>
/// Keyboard key code for the 'S' key
/// </summary>
const
  pxKEY_S = 19;

/// <summary>
/// Keyboard key code for the 'T' key
/// </summary>
const
  pxKEY_T = 20;

/// <summary>
/// Keyboard key code for the 'U' key
/// </summary>
const
  pxKEY_U = 21;

/// <summary>
/// Keyboard key code for the 'V' key
/// </summary>
const
  pxKEY_V = 22;

/// <summary>
/// Keyboard key code for the 'W' key
/// </summary>
const
  pxKEY_W = 23;

/// <summary>
/// Keyboard key code for the 'X' key
/// </summary>
const
  pxKEY_X = 24;

/// <summary>
/// Keyboard key code for the 'Y' key
/// </summary>
const
  pxKEY_Y = 25;

/// <summary>
/// Keyboard key code for the 'Z' key
/// </summary>
const
  pxKEY_Z = 26;

/// <summary>
/// Keyboard key code for the '0' key
/// </summary>
const
  pxKEY_0 = 27;

/// <summary>
/// Keyboard key code for the '1' key
/// </summary>
const
  pxKEY_1 = 28;

/// <summary>
/// Keyboard key code for the '2' key
/// </summary>
const
  pxKEY_2 = 29;

/// <summary>
/// Keyboard key code for the '3' key
/// </summary>
const
  pxKEY_3 = 30;

/// <summary>
/// Keyboard key code for the '4' key
/// </summary>
const
  pxKEY_4 = 31;

/// <summary>
/// Keyboard key code for the '5' key
/// </summary>
const
  pxKEY_5 = 32;

/// <summary>
/// Keyboard key code for the '6' key
/// </summary>
const
  pxKEY_6 = 33;

/// <summary>
/// Keyboard key code for the '7' key
/// </summary>
const
  pxKEY_7 = 34;

/// <summary>
/// Keyboard key code for the '8' key
/// </summary>
const
  pxKEY_8 = 35;

/// <summary>
/// Keyboard key code for the '9' key
/// </summary>
const
  pxKEY_9 = 36;

/// <summary>
/// Keyboard key code for the numeric keypad '0' key
/// </summary>
const
  pxKEY_PAD_0 = 37;

/// <summary>
/// Keyboard key code for the numeric keypad '1' key
/// </summary>
const
  pxKEY_PAD_1 = 38;

/// <summary>
/// Keyboard key code for the numeric keypad '2' key
/// </summary>
const
  pxKEY_PAD_2 = 39;

/// <summary>
/// Keyboard key code for the numeric keypad '3' key
/// </summary>
const
  pxKEY_PAD_3 = 40;

/// <summary>
/// Keyboard key code for the numeric keypad '4' key
/// </summary>
const
  pxKEY_PAD_4 = 41;

/// <summary>
/// Keyboard key code for the numeric keypad '5' key
/// </summary>
const
  pxKEY_PAD_5 = 42;

/// <summary>
/// Keyboard key code for the numeric keypad '6' key
/// </summary>
const
  pxKEY_PAD_6 = 43;

/// <summary>
/// Keyboard key code for the numeric keypad '7' key
/// </summary>
const
  pxKEY_PAD_7 = 44;

/// <summary>
/// Keyboard key code for the numeric keypad '8' key
/// </summary>
const
  pxKEY_PAD_8 = 45;

/// <summary>
/// Keyboard key code for the numeric keypad '9' key
/// </summary>
const
  pxKEY_PAD_9 = 46;

/// <summary>
/// Keyboard key code for the F1 function key
/// </summary>
const
  pxKEY_F1 = 47;

/// <summary>
/// Keyboard key code for the F2 function key
/// </summary>
const
  pxKEY_F2 = 48;

/// <summary>
/// Keyboard key code for the F3 function key
/// </summary>
const
  pxKEY_F3 = 49;

/// <summary>
/// Keyboard key code for the F4 function key
/// </summary>
const
  pxKEY_F4 = 50;

/// <summary>
/// Keyboard key code for the F5 function key
/// </summary>
const
  pxKEY_F5 = 51;

/// <summary>
/// Keyboard key code for the F6 function key
/// </summary>
const
  pxKEY_F6 = 52;

/// <summary>
/// Keyboard key code for the F7 function key
/// </summary>
const
  pxKEY_F7 = 53;

/// <summary>
/// Keyboard key code for the F8 function key
/// </summary>
const
  pxKEY_F8 = 54;

/// <summary>
/// Keyboard key code for the F9 function key
/// </summary>
const
  pxKEY_F9 = 55;

/// <summary>
/// Keyboard key code for the F10 function key
/// </summary>
const
  pxKEY_F10 = 56;

/// <summary>
/// Keyboard key code for the F11 function key
/// </summary>
const
  pxKEY_F11 = 57;

/// <summary>
/// Keyboard key code for the F12 function key
/// </summary>
const
  pxKEY_F12 = 58;

/// <summary>
/// Keyboard key code for the Escape key
/// </summary>
const
  pxKEY_ESCAPE = 59;

/// <summary>
/// Keyboard key code for the tilde (~) key
/// </summary>
const
  pxKEY_TILDE = 60;

/// <summary>
/// Keyboard key code for the minus (-) key
/// </summary>
const
  pxKEY_MINUS = 61;

/// <summary>
/// Keyboard key code for the equals (=) key
/// </summary>
const
  pxKEY_EQUALS = 62;

/// <summary>
/// Keyboard key code for the Backspace key
/// </summary>
const
  pxKEY_BACKSPACE = 63;

/// <summary>
/// Keyboard key code for the Tab key
/// </summary>
const
  pxKEY_TAB = 64;

/// <summary>
/// Keyboard key code for the open bracket ([) key
/// </summary>
const
  pxKEY_OPENBRACE = 65;

/// <summary>
/// Keyboard key code for the close bracket (]) key
/// </summary>
const
  pxKEY_CLOSEBRACE = 66;

/// <summary>
/// Keyboard key code for the Enter/Return key
/// </summary>
const
  pxKEY_ENTER = 67;

/// <summary>
/// Keyboard key code for the semicolon (;) key
/// </summary>
const
  pxKEY_SEMICOLON = 68;

/// <summary>
/// Keyboard key code for the quote (') key
/// </summary>
const
  pxKEY_QUOTE = 69;

/// <summary>
/// Keyboard key code for the backslash (\) key
/// </summary>
const
  pxKEY_BACKSLASH = 70;

/// <summary>
/// Keyboard key code for the second backslash key (if present)
/// </summary>
const
  pxKEY_BACKSLASH2 = 71;

/// <summary>
/// Keyboard key code for the comma (,) key
/// </summary>
const
  pxKEY_COMMA = 72;

/// <summary>
/// Keyboard key code for the period/full stop (.) key
/// </summary>
const
  pxKEY_FULLSTOP = 73;

/// <summary>
/// Keyboard key code for the forward slash (/) key
/// </summary>
const
  pxKEY_SLASH = 74;

/// <summary>
/// Keyboard key code for the Space bar key
/// </summary>
const
  pxKEY_SPACE = 75;

/// <summary>
/// Keyboard key code for the Insert key
/// </summary>
const
  pxKEY_INSERT = 76;

/// <summary>
/// Keyboard key code for the Delete key
/// </summary>
const
  pxKEY_DELETE = 77;

/// <summary>
/// Keyboard key code for the Home key
/// </summary>
const
  pxKEY_HOME = 78;

/// <summary>
/// Keyboard key code for the End key
/// </summary>
const
  pxKEY_END = 79;

/// <summary>
/// Keyboard key code for the Page Up key
/// </summary>
const
  pxKEY_PGUP = 80;

/// <summary>
/// Keyboard key code for the Page Down key
/// </summary>
const
  pxKEY_PGDN = 81;

/// <summary>
/// Keyboard key code for the Left arrow key
/// </summary>
const
  pxKEY_LEFT = 82;

/// <summary>
/// Keyboard key code for the Right arrow key
/// </summary>
const
  pxKEY_RIGHT = 83;

/// <summary>
/// Keyboard key code for the Up arrow key
/// </summary>
const
  pxKEY_UP = 84;

/// <summary>
/// Keyboard key code for the Down arrow key
/// </summary>
const
  pxKEY_DOWN = 85;

/// <summary>
/// Keyboard key code for the numeric keypad slash (/) key
/// </summary>
const
  pxKEY_PAD_SLASH = 86;

/// <summary>
/// Keyboard key code for the numeric keypad asterisk (*) key
/// </summary>
const
  pxKEY_PAD_ASTERISK = 87;

/// <summary>
/// Keyboard key code for the numeric keypad minus (-) key
/// </summary>
const
  pxKEY_PAD_MINUS = 88;

/// <summary>
/// Keyboard key code for the numeric keypad plus (+) key
/// </summary>
const
  pxKEY_PAD_PLUS = 89;

/// <summary>
/// Keyboard key code for the numeric keypad Delete key
/// </summary>
const
  pxKEY_PAD_DELETE = 90;

/// <summary>
/// Keyboard key code for the numeric keypad Enter key
/// </summary>
const
  pxKEY_PAD_ENTER = 91;

/// <summary>
/// Keyboard key code for the Print Screen key
/// </summary>
const
  pxKEY_PRINTSCREEN = 92;

/// <summary>
/// Keyboard key code for the Pause key
/// </summary>
const
  pxKEY_PAUSE = 93;

/// <summary>
/// Keyboard key code for the ABNT C1 key (Brazilian keyboard layout)
/// </summary>
const
  pxKEY_ABNT_C1 = 94;

/// <summary>
/// Keyboard key code for the Yen (¥) key (Japanese keyboard layout)
/// </summary>
const
  pxKEY_YEN = 95;

/// <summary>
/// Keyboard key code for the Kana key (Japanese keyboard layout)
/// </summary>
const
  pxKEY_KANA = 96;

/// <summary>
/// Keyboard key code for the Convert key (Japanese keyboard layout)
/// </summary>
const
  pxKEY_CONVERT = 97;

/// <summary>
/// Keyboard key code for the No Convert key (Japanese keyboard layout)
/// </summary>
const
  pxKEY_NOCONVERT = 98;

/// <summary>
/// Keyboard key code for the At (@) key
/// </summary>
const
  pxKEY_AT = 99;

/// <summary>
/// Keyboard key code for the circumflex (^) key
/// </summary>
const
  pxKEY_CIRCUMFLEX = 100;

/// <summary>
/// Keyboard key code for the second colon key (if present)
/// </summary>
const
  pxKEY_COLON2 = 101;

/// <summary>
/// Keyboard key code for the Kanji key (Japanese keyboard layout)
/// </summary>
const
  pxKEY_KANJI = 102;

/// <summary>
/// Keyboard key code for the numeric keypad equals (=) key
/// </summary>
const
  pxKEY_PAD_EQUALS = 103;

/// <summary>
/// Keyboard key code for the backquote (`) key
/// </summary>
const
  pxKEY_BACKQUOTE = 104;

/// <summary>
/// Keyboard key code for the second semicolon key (if present)
/// </summary>
const
  pxKEY_SEMICOLON2 = 105;

/// <summary>
/// Keyboard key code for the Command key (Mac keyboards)
/// </summary>
const
  pxKEY_COMMAND = 106;

/// <summary>
/// Keyboard key code for the Back key (mobile/tablet devices)
/// </summary>
const
  pxKEY_BACK = 107;

/// <summary>
/// Keyboard key code for the Volume Up key (mobile/tablet devices)
/// </summary>
const
  pxKEY_VOLUME_UP = 108;

/// <summary>
/// Keyboard key code for the Volume Down key (mobile/tablet devices)
/// </summary>
const
  pxKEY_VOLUME_DOWN = 109;

/// <summary>
/// Keyboard key code for the Search key (mobile/tablet devices)
/// </summary>
const
  pxKEY_SEARCH = 110;

/// <summary>
/// Keyboard key code for the D-pad Center key (mobile/tablet devices)
/// </summary>
const
  pxKEY_DPAD_CENTER = 111;

/// <summary>
/// Keyboard key code for the Button X key (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_X = 112;

/// <summary>
/// Keyboard key code for the Button Y key (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_Y = 113;

/// <summary>
/// Keyboard key code for the D-pad Up key (mobile/tablet devices)
/// </summary>
const
  pxKEY_DPAD_UP = 114;

/// <summary>
/// Keyboard key code for the D-pad Down key (mobile/tablet devices)
/// </summary>
const
  pxKEY_DPAD_DOWN = 115;

/// <summary>
/// Keyboard key code for the D-pad Left key (mobile/tablet devices)
/// </summary>
const
  pxKEY_DPAD_LEFT = 116;

/// <summary>
/// Keyboard key code for the D-pad Right key (mobile/tablet devices)
/// </summary>
const
  pxKEY_DPAD_RIGHT = 117;

/// <summary>
/// Keyboard key code for the Select key (mobile/tablet devices)
/// </summary>
const
  pxKEY_SELECT = 118;

/// <summary>
/// Keyboard key code for the Start key (mobile/tablet devices)
/// </summary>
const
  pxKEY_START = 119;

/// <summary>
/// Keyboard key code for the L1 button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_L1 = 120;

/// <summary>
/// Keyboard key code for the R1 button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_R1 = 121;

/// <summary>
/// Keyboard key code for the L2 button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_L2 = 122;

/// <summary>
/// Keyboard key code for the R2 button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_R2 = 123;

/// <summary>
/// Keyboard key code for the A button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_A = 124;

/// <summary>
/// Keyboard key code for the B button (mobile/tablet devices)
/// </summary>
const
  pxKEY_BUTTON_B = 125;

/// <summary>
/// Keyboard key code for the left thumbstick button (mobile/tablet devices)
/// </summary>
const
  pxKEY_THUMBL = 126;

/// <summary>
/// Keyboard key code for the right thumbstick button (mobile/tablet devices)
/// </summary>
const
  pxKEY_THUMBR = 127;

/// <summary>
/// Keyboard key code for unknown/unmapped keys
/// </summary>
const
  pxKEY_UNKNOWN = 128;

/// <summary>
/// Base value for keyboard modifier keys
/// </summary>
const
  pxKEY_MODIFIERS = 215;

/// <summary>
/// Keyboard key code for the left Shift key
/// </summary>
const
  pxKEY_LSHIFT = 215;

/// <summary>
/// Keyboard key code for the right Shift key
/// </summary>
const
  pxKEY_RSHIFT = 216;

/// <summary>
/// Keyboard key code for the left Control key
/// </summary>
const
  pxKEY_LCTRL = 217;

/// <summary>
/// Keyboard key code for the right Control key
/// </summary>
const
  pxKEY_RCTRL = 218;

/// <summary>
/// Keyboard key code for the Alt key
/// </summary>
const
  pxKEY_ALT = 219;

/// <summary>
/// Keyboard key code for the AltGr key (right Alt on international keyboards)
/// </summary>
const
  pxKEY_ALTGR = 220;

/// <summary>
/// Keyboard key code for the left Windows key
/// </summary>
const
  pxKEY_LWIN = 221;

/// <summary>
/// Keyboard key code for the right Windows key
/// </summary>
const
  pxKEY_RWIN = 222;

/// <summary>
/// Keyboard key code for the Menu key (context menu key)
/// </summary>
const
  pxKEY_MENU = 223;

/// <summary>
/// Keyboard key code for the Scroll Lock key
/// </summary>
const
  pxKEY_SCROLLLOCK = 224;

/// <summary>
/// Keyboard key code for the Num Lock key
/// </summary>
const
  pxKEY_NUMLOCK = 225;

/// <summary>
/// Keyboard key code for the Caps Lock key
/// </summary>
const
  pxKEY_CAPSLOCK = 226;

/// <summary>
/// Maximum keyboard key code value
/// </summary>
const
  pxKEY_MAX = 227;

/// <summary>
/// Keyboard modifier flag for Shift key pressed
/// </summary>
const
  pxKEYMOD_SHIFT = $0001;

/// <summary>
/// Keyboard modifier flag for Control key pressed
/// </summary>
const
  pxKEYMOD_CTRL = $0002;

/// <summary>
/// Keyboard modifier flag for Alt key pressed
/// </summary>
const
  pxKEYMOD_ALT = $0004;

/// <summary>
/// Keyboard modifier flag for left Windows key pressed
/// </summary>
const
  pxKEYMOD_LWIN = $0008;

/// <summary>
/// Keyboard modifier flag for right Windows key pressed
/// </summary>
const
  pxKEYMOD_RWIN = $0010;

/// <summary>
/// Keyboard modifier flag for Menu key pressed
/// </summary>
const
  pxKEYMOD_MENU = $0020;

/// <summary>
/// Keyboard modifier flag for Command key pressed (Mac keyboards)
/// </summary>
const
  pxKEYMOD_COMMAND = $0040;

/// <summary>
/// Keyboard modifier flag for Scroll Lock active
/// </summary>
const
  pxKEYMOD_SCROLOCK = $0100;

/// <summary>
/// Keyboard modifier flag for Num Lock active
/// </summary>
const
  pxKEYMOD_NUMLOCK = $0200;

/// <summary>
/// Keyboard modifier flag for Caps Lock active
/// </summary>
const
  pxKEYMOD_CAPSLOCK = $0400;

/// <summary>
/// Keyboard modifier flag for in Alt sequence mode
/// </summary>
const
  pxKEYMOD_INALTSEQ = $0800;

/// <summary>
/// Keyboard modifier flag for accent 1 active
/// </summary>
const
  pxKEYMOD_ACCENT1 = $1000;

/// <summary>
/// Keyboard modifier flag for accent 2 active
/// </summary>
const
  pxKEYMOD_ACCENT2 = $2000;

/// <summary>
/// Keyboard modifier flag for accent 3 active
/// </summary>
const
  pxKEYMOD_ACCENT3 = $4000;

/// <summary>
/// Keyboard modifier flag for accent 4 active
/// </summary>
const
  pxKEYMOD_ACCENT4 = $8000;
{$ENDREGION}

type

  /// <summary>
  /// Provides comprehensive input handling for keyboard, mouse, and joystick devices in the PIXELS game engine.
  /// This static class manages all input states and provides frame-based input detection for game development.
  /// </summary>
  /// <remarks>
  /// The TpxInput class operates on a frame-based input system that tracks both current and previous input states
  /// to provide pressed/released detection. All input methods are thread-safe and automatically updated each frame
  /// through the PIXELS engine's 60fps game loop. Mouse coordinates are automatically translated to logical screen
  /// coordinates regardless of window scaling or fullscreen mode.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Check for keyboard input
  /// if TpxInput.KeyPressed(pxKEY_SPACE) then
  ///   FireWeapon();
  ///
  /// // Check for mouse input
  /// if TpxInput.MouseDown(pxMOUSE_BUTTON_LEFT) then
  ///   HandleMouseClick();
  ///
  /// // Get joystick input
  /// LJoyX := TpxInput.JoystickPosition(pxJOY_STICK_LS, pxJOY_AXES_X);
  /// LJoyY := TpxInput.JoystickPosition(pxJOY_STICK_LS, pxJOY_AXES_Y);
  /// </code>
  /// </example>
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
    /// <summary>
    /// Returns the Unicode character code of the last key pressed that generates text input.
    /// </summary>
    /// <returns>
    /// The Unicode character code as an integer, or 0 if no character-generating key was pressed this frame
    /// </returns>
    /// <remarks>
    /// This method is primarily used for text input in user interfaces rather than game controls.
    /// It respects keyboard layout, modifier keys, and international character input methods.
    /// For game controls, use KeyPressed, KeyDown, or KeyReleased instead.
    /// </remarks>
    /// <example>
    /// <code>
    /// LChar := TpxInput.KeyCode();
    /// if LChar > 0 then
    ///   LTextInput := LTextInput + Chr(LChar);
    /// </code>
    /// </example>
    class function KeyCode(): Integer; static;

    /// <summary>
    /// Indicates whether the last character input was a key repeat event.
    /// </summary>
    /// <returns>
    /// True if the last KeyCode() result was from a key repeat (holding key down), False for initial key press
    /// </returns>
    /// <remarks>
    /// Key repeat occurs when a key is held down and the operating system generates multiple character events.
    /// This is useful for text input fields where you might want to handle initial presses differently from repeats.
    /// </remarks>
    /// <seealso cref="KeyCode"/>
    class function KeyCodeRepeat: Boolean; static;

    /// <summary>
    /// Clears all input states and resets internal input tracking to default values.
    /// </summary>
    /// <remarks>
    /// This method resets all keyboard, mouse, and joystick states to unpressed/released.
    /// It also clears the internal input buffers and resets position tracking.
    /// Useful when transitioning between game states or when you need to ignore accumulated input.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Clear input when entering a menu
    /// TpxInput.Clear();
    /// </code>
    /// </example>
    class procedure Clear; static;

    /// <summary>
    /// Updates all input states for the current frame. This method is called automatically by the PIXELS game loop.
    /// </summary>
    /// <remarks>
    /// This method processes all pending input events and updates internal state tracking for keyboards,
    /// mouse, and joysticks. It maintains previous frame states for pressed/released detection.
    /// You should not call this method manually unless implementing a custom game loop.
    /// </remarks>
    class procedure Update; static;

    /// <summary>
    /// Checks if a specific keyboard key is currently being held down.
    /// </summary>
    /// <param name="AKey">The keyboard key code to check (use pxKEY_* constants)</param>
    /// <returns>True if the key is currently pressed down, False otherwise</returns>
    /// <remarks>
    /// This method returns True for every frame that the key remains pressed.
    /// For detecting the moment a key is first pressed, use KeyPressed instead.
    /// For detecting when a key is released, use KeyReleased.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Continuous movement while key is held
    /// if TpxInput.KeyDown(pxKEY_W) then
    ///   MovePlayerForward();
    /// </code>
    /// </example>
    /// <seealso cref="KeyPressed"/>
    /// <seealso cref="KeyReleased"/>
    class function  KeyDown(const AKey: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific keyboard key was pressed down this frame (transition from up to down).
    /// </summary>
    /// <param name="AKey">The keyboard key code to check (use pxKEY_* constants)</param>
    /// <returns>True only on the frame when the key transitions from released to pressed</returns>
    /// <remarks>
    /// This method returns True only once per key press, on the exact frame the key goes from released
    /// to pressed. It will not return True again until the key is released and pressed again.
    /// Perfect for discrete actions like jumping, shooting, or menu navigation.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Jump only when spacebar is first pressed
    /// if TpxInput.KeyPressed(pxKEY_SPACE) then
    ///   PlayerJump();
    /// </code>
    /// </example>
    /// <seealso cref="KeyDown"/>
    /// <seealso cref="KeyReleased"/>
    class function  KeyPressed(const AKey: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific keyboard key was released this frame (transition from down to up).
    /// </summary>
    /// <param name="AKey">The keyboard key code to check (use pxKEY_* constants)</param>
    /// <returns>True only on the frame when the key transitions from pressed to released</returns>
    /// <remarks>
    /// This method returns True only once per key release, on the exact frame the key goes from pressed
    /// to released. Useful for detecting the end of player actions or implementing charge-up mechanics.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Fire charged weapon when key is released
    /// if TpxInput.KeyReleased(pxKEY_SPACE) then
    ///   FireChargedWeapon();
    /// </code>
    /// </example>
    /// <seealso cref="KeyDown"/>
    /// <seealso cref="KeyPressed"/>
    class function  KeyReleased(const AKey: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific mouse button is currently being held down.
    /// </summary>
    /// <param name="AButton">The mouse button to check (use pxMOUSE_BUTTON_* constants)</param>
    /// <returns>True if the mouse button is currently pressed down, False otherwise</returns>
    /// <remarks>
    /// This method returns True for every frame that the mouse button remains pressed.
    /// Mouse coordinates are automatically translated to logical screen coordinates.
    /// Use MousePressed for detecting the initial button press moment.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Continuous action while mouse button held
    /// if TpxInput.MouseDown(pxMOUSE_BUTTON_LEFT) then
    ///   ContinuousAction();
    /// </code>
    /// </example>
    /// <seealso cref="MousePressed"/>
    /// <seealso cref="MouseReleased"/>
    class function  MouseDown(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific mouse button was pressed down this frame (transition from up to down).
    /// </summary>
    /// <param name="AButton">The mouse button to check (use pxMOUSE_BUTTON_* constants)</param>
    /// <returns>True only on the frame when the button transitions from released to pressed</returns>
    /// <remarks>
    /// This method returns True only once per mouse button press, on the exact frame the button goes
    /// from released to pressed. Perfect for discrete actions like clicking buttons or firing weapons.
    /// Mouse coordinates are available through GetMouseInfo for determining click location.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Handle single click events
    /// if TpxInput.MousePressed(pxMOUSE_BUTTON_LEFT) then
    ///   HandleMouseClick();
    /// </code>
    /// </example>
    /// <seealso cref="MouseDown"/>
    /// <seealso cref="GetMouseInfo"/>
    class function  MousePressed(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific mouse button was released this frame (transition from down to up).
    /// </summary>
    /// <param name="AButton">The mouse button to check (use pxMOUSE_BUTTON_* constants)</param>
    /// <returns>True only on the frame when the button transitions from pressed to released</returns>
    /// <remarks>
    /// This method returns True only once per mouse button release, on the exact frame the button goes
    /// from pressed to released. Useful for implementing drag operations or charge-up mechanics.
    /// </remarks>
    /// <example>
    /// <code>
    /// // End drag operation when mouse released
    /// if TpxInput.MouseReleased(pxMOUSE_BUTTON_LEFT) then
    ///   EndDragOperation();
    /// </code>
    /// </example>
    /// <seealso cref="MouseDown"/>
    /// <seealso cref="MousePressed"/>
    class function  MouseReleased(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Sets the mouse cursor position in logical screen coordinates.
    /// </summary>
    /// <param name="AX">The X coordinate in logical screen space</param>
    /// <param name="AY">The Y coordinate in logical screen space</param>
    /// <remarks>
    /// The coordinates are automatically converted from logical to physical screen coordinates,
    /// accounting for window scaling and letterboxing. The coordinate system origin (0,0) is
    /// at the top-left corner of the logical screen area.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Center mouse cursor on screen
    /// LCenter := TpxWindow.GetLogicalSize();
    /// TpxInput.MouseSetPos(Round(LCenter.w / 2), Round(LCenter.h / 2));
    /// </code>
    /// </example>
    class procedure MouseSetPos(const AX, AY: Integer); static;

    /// <summary>
    /// Retrieves comprehensive mouse state information including position, movement delta, and pressure.
    /// </summary>
    /// <param name="APosition">Pointer to TpxVector to receive current mouse position, or nil to ignore</param>
    /// <param name="ADelta">Pointer to TpxVector to receive mouse movement delta since last frame, or nil to ignore</param>
    /// <param name="APressure">Pointer to Single to receive pressure information (for pressure-sensitive devices), or nil to ignore</param>
    /// <remarks>
    /// Position coordinates are in logical screen space with origin at top-left (0,0).
    /// Delta values represent pixel movement since the previous frame.
    /// Pressure is typically 0.0 for standard mice, and 0.0-1.0 for pressure-sensitive devices.
    /// Pass nil for any parameter you don't need to avoid unnecessary memory operations.
    /// </remarks>
    /// <example>
    /// <code>
    /// var
    ///   LPos: TpxVector;
    ///   LDelta: TpxVector;
    /// begin
    ///   TpxInput.GetMouseInfo(@LPos, @LDelta, nil);
    ///   // Use LPos.x, LPos.y for cursor position
    ///   // Use LDelta.x, LDelta.y for mouse movement
    /// end;
    /// </code>
    /// </example>
    class procedure GetMouseInfo(const APosition: PpxVector; const ADelta: PpxVector; const APressure: System.PSingle); static;

    /// <summary>
    /// Checks if a specific joystick button is currently being held down.
    /// </summary>
    /// <param name="AButton">The joystick button to check (use pxJOY_BTN_* constants)</param>
    /// <returns>True if the joystick button is currently pressed down, False otherwise</returns>
    /// <remarks>
    /// This method returns True for every frame that the joystick button remains pressed.
    /// Only the first connected joystick is supported. If no joystick is connected, always returns False.
    /// For detecting the initial button press moment, use JoystickPressed instead.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Continuous firing while button held
    /// if TpxInput.JoystickDown(pxJOY_BTN_A) then
    ///   ContinuousFire();
    /// </code>
    /// </example>
    /// <seealso cref="JoystickPressed"/>
    /// <seealso cref="JoystickReleased"/>
    class function  JoystickDown(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific joystick button was pressed down this frame (transition from up to down).
    /// </summary>
    /// <param name="AButton">The joystick button to check (use pxJOY_BTN_* constants)</param>
    /// <returns>True only on the frame when the button transitions from released to pressed</returns>
    /// <remarks>
    /// This method returns True only once per joystick button press, on the exact frame the button goes
    /// from released to pressed. Perfect for discrete actions like jumping, menu selection, or weapon firing.
    /// Only the first connected joystick is supported.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Jump when A button is first pressed
    /// if TpxInput.JoystickPressed(pxJOY_BTN_A) then
    ///   PlayerJump();
    /// </code>
    /// </example>
    /// <seealso cref="JoystickDown"/>
    /// <seealso cref="JoystickReleased"/>
    class function  JoystickPressed(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Checks if a specific joystick button was released this frame (transition from down to up).
    /// </summary>
    /// <param name="AButton">The joystick button to check (use pxJOY_BTN_* constants)</param>
    /// <returns>True only on the frame when the button transitions from pressed to released</returns>
    /// <remarks>
    /// This method returns True only once per joystick button release, on the exact frame the button goes
    /// from pressed to released. Useful for detecting the end of player actions or implementing charge-up mechanics.
    /// Only the first connected joystick is supported.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Release charged attack when button released
    /// if TpxInput.JoystickReleased(pxJOY_BTN_A) then
    ///   ReleaseChargedAttack();
    /// </code>
    /// </example>
    /// <seealso cref="JoystickDown"/>
    /// <seealso cref="JoystickPressed"/>
    class function  JoystickReleased(const AButton: Cardinal): Boolean; static;

    /// <summary>
    /// Returns the current position value for a specific joystick stick axis.
    /// </summary>
    /// <param name="AStick">The joystick stick identifier (use pxJOY_STICK_* constants)</param>
    /// <param name="AAxes">The axis identifier (use pxJOY_AXES_* constants)</param>
    /// <returns>Axis position as a floating-point value typically in the range -1.0 to 1.0</returns>
    /// <remarks>
    /// Returns analog stick position where -1.0 represents fully left/up, 0.0 is center position,
    /// and 1.0 represents fully right/down. The exact range may vary by device but is typically normalized.
    /// Only the first connected joystick is supported. Returns 0.0 if no joystick is connected or
    /// if the specified stick/axis combination is invalid.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Get left stick position for player movement
    /// LMoveX := TpxInput.JoystickPosition(pxJOY_STICK_LS, pxJOY_AXES_X);
    /// LMoveY := TpxInput.JoystickPosition(pxJOY_STICK_LS, pxJOY_AXES_Y);
    ///
    /// // Move player based on stick input
    /// PlayerVelocity.x := LMoveX * MaxSpeed;
    /// PlayerVelocity.y := LMoveY * MaxSpeed;
    /// </code>
    /// </example>
    class function  JoystickPosition(const AStick, AAxes: Integer): Single; static;
  end;

implementation

uses
  System.Math,
  PIXELS.Graphics,
  PIXELS.Core;

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
