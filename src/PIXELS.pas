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

unit PIXELS;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Base,
  PIXELS.Math,
  PIXELS.Graphics,
  PIXELS.Events,
  PIXELS.Audio,
  PIXELS.Console,
  PIXELS.IO,
  PIXELS.Core,
  PIXELS.Game,
  PIXELS.Utils,
  PIXELS.Sprite;

{$REGION 'Math Constants'}
const
  // Math constants
  pxRAD2DEG = PIXELS.Math.pxRAD2DEG;
  pxDEG2RAD = PIXELS.Math.pxDEG2RAD;
  pxEPSILON = PIXELS.Math.pxEPSILON;
  pxNaN = PIXELS.Math.pxNaN;
{$ENDREGION}

{$REGION 'Graphics Constants'}
const
  // Window defaults
  CpxDefaultWindowWidth = PIXELS.Graphics.CpxDefaultWindowWidth;
  CpxDefaultWindowHeight = PIXELS.Graphics.CpxDefaultWindowHeight;

  // Blend constants
  pxBLEND_ZERO = PIXELS.Graphics.pxBLEND_ZERO;
  pxBLEND_ONE = PIXELS.Graphics.pxBLEND_ONE;
  pxBLEND_ALPHA = PIXELS.Graphics.pxBLEND_ALPHA;
  pxBLEND_INVERSE_ALPHA = PIXELS.Graphics.pxBLEND_INVERSE_ALPHA;
  pxBLEND_SRC_COLOR = PIXELS.Graphics.pxBLEND_SRC_COLOR;
  pxBLEND_DEST_COLOR = PIXELS.Graphics.pxBLEND_DEST_COLOR;
  pxBLEND_INVERSE_SRC_COLOR = PIXELS.Graphics.pxBLEND_INVERSE_SRC_COLOR;
  pxBLEND_INVERSE_DEST_COLOR = PIXELS.Graphics.pxBLEND_INVERSE_DEST_COLOR;
  pxBLEND_CONST_COLOR = PIXELS.Graphics.pxBLEND_CONST_COLOR;
  pxBLEND_INVERSE_CONST_COLOR = PIXELS.Graphics.pxBLEND_INVERSE_CONST_COLOR;
  pxBLEND_ADD = PIXELS.Graphics.pxBLEND_ADD;
  pxBLEND_SRC_MINUS_DEST = PIXELS.Graphics.pxBLEND_SRC_MINUS_DEST;
  pxBLEND_DEST_MINUS_SRC = PIXELS.Graphics.pxBLEND_DEST_MINUS_SRC;

  // Shader constants
  CpxDefaultShaderSource = PIXELS.Graphics.CpxDefaultShaderSource;


{$ENDREGION}

{$REGION 'Events Constants'}
const
  // Input constants
  pxMAX_AXES = PIXELS.Events.pxMAX_AXES;
  pxMAX_STICKS = PIXELS.Events.pxMAX_STICKS;
  pxMAX_BUTTONS = PIXELS.Events.pxMAX_BUTTONS;
  pxMOUSE_BUTTON_LEFT = PIXELS.Events.pxMOUSE_BUTTON_LEFT;
  pxMOUSE_BUTTON_RIGHT = PIXELS.Events.pxMOUSE_BUTTON_RIGHT;
  pxMOUSE_BUTTON_MIDDLE = PIXELS.Events.pxMOUSE_BUTTON_MIDDLE;

  // Joystick sticks
  pxJOY_STICK_LS = PIXELS.Events.pxJOY_STICK_LS;
  pxJOY_STICK_RS = PIXELS.Events.pxJOY_STICK_RS;
  pxJOY_STICK_LT = PIXELS.Events.pxJOY_STICK_LT;
  pxJOY_STICK_RT = PIXELS.Events.pxJOY_STICK_RT;

  // Joystick axes
  pxJOY_AXES_X = PIXELS.Events.pxJOY_AXES_X;
  pxJOY_AXES_Y = PIXELS.Events.pxJOY_AXES_Y;
  pxJOY_AXES_Z = PIXELS.Events.pxJOY_AXES_Z;

  // Joystick buttons
  pxJOY_BTN_A = PIXELS.Events.pxJOY_BTN_A;
  pxJOY_BTN_B = PIXELS.Events.pxJOY_BTN_B;
  pxJOY_BTN_X = PIXELS.Events.pxJOY_BTN_X;
  pxJOY_BTN_Y = PIXELS.Events.pxJOY_BTN_Y;
  pxJOY_BTN_RB = PIXELS.Events.pxJOY_BTN_RB;
  pxJOY_BTN_LB = PIXELS.Events.pxJOY_BTN_LB;
  pxJOY_BTN_RT = PIXELS.Events.pxJOY_BTN_RT;
  pxJOY_BTN_LT = PIXELS.Events.pxJOY_BTN_LT;
  pxJOY_BTN_BACK = PIXELS.Events.pxJOY_BTN_BACK;
  pxJOY_BTN_START = PIXELS.Events.pxJOY_BTN_START;
  pxJOY_BTN_RDPAD = PIXELS.Events.pxJOY_BTN_RDPAD;
  pxJOY_BTN_LDPAD = PIXELS.Events.pxJOY_BTN_LDPAD;
  pxJOY_BTN_DDPAD = PIXELS.Events.pxJOY_BTN_DDPAD;
  pxJOY_BTN_UDPAD = PIXELS.Events.pxJOY_BTN_UDPAD;

  // Keyboard keys
  pxKEY_A = PIXELS.Events.pxKEY_A;
  pxKEY_B = PIXELS.Events.pxKEY_B;
  pxKEY_C = PIXELS.Events.pxKEY_C;
  pxKEY_D = PIXELS.Events.pxKEY_D;
  pxKEY_E = PIXELS.Events.pxKEY_E;
  pxKEY_F = PIXELS.Events.pxKEY_F;
  pxKEY_G = PIXELS.Events.pxKEY_G;
  pxKEY_H = PIXELS.Events.pxKEY_H;
  pxKEY_I = PIXELS.Events.pxKEY_I;
  pxKEY_J = PIXELS.Events.pxKEY_J;
  pxKEY_K = PIXELS.Events.pxKEY_K;
  pxKEY_L = PIXELS.Events.pxKEY_L;
  pxKEY_M = PIXELS.Events.pxKEY_M;
  pxKEY_N = PIXELS.Events.pxKEY_N;
  pxKEY_O = PIXELS.Events.pxKEY_O;
  pxKEY_P = PIXELS.Events.pxKEY_P;
  pxKEY_Q = PIXELS.Events.pxKEY_Q;
  pxKEY_R = PIXELS.Events.pxKEY_R;
  pxKEY_S = PIXELS.Events.pxKEY_S;
  pxKEY_T = PIXELS.Events.pxKEY_T;
  pxKEY_U = PIXELS.Events.pxKEY_U;
  pxKEY_V = PIXELS.Events.pxKEY_V;
  pxKEY_W = PIXELS.Events.pxKEY_W;
  pxKEY_X = PIXELS.Events.pxKEY_X;
  pxKEY_Y = PIXELS.Events.pxKEY_Y;
  pxKEY_Z = PIXELS.Events.pxKEY_Z;
  pxKEY_0 = PIXELS.Events.pxKEY_0;
  pxKEY_1 = PIXELS.Events.pxKEY_1;
  pxKEY_2 = PIXELS.Events.pxKEY_2;
  pxKEY_3 = PIXELS.Events.pxKEY_3;
  pxKEY_4 = PIXELS.Events.pxKEY_4;
  pxKEY_5 = PIXELS.Events.pxKEY_5;
  pxKEY_6 = PIXELS.Events.pxKEY_6;
  pxKEY_7 = PIXELS.Events.pxKEY_7;
  pxKEY_8 = PIXELS.Events.pxKEY_8;
  pxKEY_9 = PIXELS.Events.pxKEY_9;
  pxKEY_ESCAPE = PIXELS.Events.pxKEY_ESCAPE;
  pxKEY_ENTER = PIXELS.Events.pxKEY_ENTER;
  pxKEY_SPACE = PIXELS.Events.pxKEY_SPACE;
  pxKEY_BACKSPACE = PIXELS.Events.pxKEY_BACKSPACE;
  pxKEY_TAB = PIXELS.Events.pxKEY_TAB;
  pxKEY_LEFT = PIXELS.Events.pxKEY_LEFT;
  pxKEY_RIGHT = PIXELS.Events.pxKEY_RIGHT;
  pxKEY_UP = PIXELS.Events.pxKEY_UP;
  pxKEY_DOWN = PIXELS.Events.pxKEY_DOWN;
  pxKEY_F1 = PIXELS.Events.pxKEY_F1;
  pxKEY_F2 = PIXELS.Events.pxKEY_F2;
  pxKEY_F3 = PIXELS.Events.pxKEY_F3;
  pxKEY_F4 = PIXELS.Events.pxKEY_F4;
  pxKEY_F5 = PIXELS.Events.pxKEY_F5;
  pxKEY_F6 = PIXELS.Events.pxKEY_F6;
  pxKEY_F7 = PIXELS.Events.pxKEY_F7;
  pxKEY_F8 = PIXELS.Events.pxKEY_F8;
  pxKEY_F9 = PIXELS.Events.pxKEY_F9;
  pxKEY_F10 = PIXELS.Events.pxKEY_F10;
  pxKEY_F11 = PIXELS.Events.pxKEY_F11;
  pxKEY_F12 = PIXELS.Events.pxKEY_F12;
  pxKEY_LSHIFT = PIXELS.Events.pxKEY_LSHIFT;
  pxKEY_RSHIFT = PIXELS.Events.pxKEY_RSHIFT;
  pxKEY_LCTRL = PIXELS.Events.pxKEY_LCTRL;
  pxKEY_RCTRL = PIXELS.Events.pxKEY_RCTRL;
  pxKEY_ALT = PIXELS.Events.pxKEY_ALT;
{$ENDREGION}

{$REGION 'Audio Constants'}
const
  // Audio constants
  CpxAUDIO_CHANNEL_COUNT = PIXELS.Audio.CpxAUDIO_CHANNEL_COUNT;
  CpxAUDIO_PAN_NONE = PIXELS.Audio.CpxAUDIO_PAN_NONE;
{$ENDREGION}

{$REGION 'Console Constants'}
const
  // Console constants
  pxLF = PIXELS.Console.pxLF;
  pxCR = PIXELS.Console.pxCR;
  pxCRLF = PIXELS.Console.pxCRLF;
  pxESC = PIXELS.Console.pxESC;
  VK_ESC = PIXELS.Console.VK_ESC;

  // Console sequences
  pxCSICursorPos = PIXELS.Console.pxCSICursorPos;
  pxCSICursorUp = PIXELS.Console.pxCSICursorUp;
  pxCSICursorDown = PIXELS.Console.pxCSICursorDown;
  pxCSICursorForward = PIXELS.Console.pxCSICursorForward;
  pxCSICursorBack = PIXELS.Console.pxCSICursorBack;
  pxCSISaveCursorPos = PIXELS.Console.pxCSISaveCursorPos;
  pxCSIRestoreCursorPos = PIXELS.Console.pxCSIRestoreCursorPos;
  pxCSICursorHomePos = PIXELS.Console.pxCSICursorHomePos;
  pxCSIShowCursor = PIXELS.Console.pxCSIShowCursor;
  pxCSIHideCursor = PIXELS.Console.pxCSIHideCursor;
  pxCSIBlinkCursor = PIXELS.Console.pxCSIBlinkCursor;
  pxCSISteadyCursor = PIXELS.Console.pxCSISteadyCursor;
  pxCSIClearScreen = PIXELS.Console.pxCSIClearScreen;
  pxCSIClearLine = PIXELS.Console.pxCSIClearLine;
  pxCSIClearToEndOfLine = PIXELS.Console.pxCSIClearToEndOfLine;
  pxCSIScrollUp = PIXELS.Console.pxCSIScrollUp;
  pxCSIScrollDown = PIXELS.Console.pxCSIScrollDown;
  pxCSIBold = PIXELS.Console.pxCSIBold;
  pxCSIUnderline = PIXELS.Console.pxCSIUnderline;
  pxCSIResetFormat = PIXELS.Console.pxCSIResetFormat;
  pxCSIResetBackground = PIXELS.Console.pxCSIResetBackground;
  pxCSIResetForeground = PIXELS.Console.pxCSIResetForeground;
  pxCSIInvertColors = PIXELS.Console.pxCSIInvertColors;
  pxCSINormalColors = PIXELS.Console.pxCSINormalColors;
  pxCSIDim = PIXELS.Console.pxCSIDim;
  pxCSIItalic = PIXELS.Console.pxCSIItalic;
  pxCSIBlink = PIXELS.Console.pxCSIBlink;
  pxCSIFramed = PIXELS.Console.pxCSIFramed;
  pxCSIEncircled = PIXELS.Console.pxCSIEncircled;
  pxCSIInsertChar = PIXELS.Console.pxCSIInsertChar;
  pxCSIDeleteChar = PIXELS.Console.pxCSIDeleteChar;
  pxCSIEraseChar = PIXELS.Console.pxCSIEraseChar;
  pxCSIFGBlack = PIXELS.Console.pxCSIFGBlack;
  pxCSIFGRed = PIXELS.Console.pxCSIFGRed;
  pxCSIFGGreen = PIXELS.Console.pxCSIFGGreen;
  pxCSIFGYellow = PIXELS.Console.pxCSIFGYellow;
  pxCSIFGBlue = PIXELS.Console.pxCSIFGBlue;
  pxCSIFGMagenta = PIXELS.Console.pxCSIFGMagenta;
  pxCSIFGCyan = PIXELS.Console.pxCSIFGCyan;
  pxCSIFGWhite = PIXELS.Console.pxCSIFGWhite;
  pxCSIBGBlack = PIXELS.Console.pxCSIBGBlack;
  pxCSIBGRed = PIXELS.Console.pxCSIBGRed;
  pxCSIBGGreen = PIXELS.Console.pxCSIBGGreen;
  pxCSIBGYellow = PIXELS.Console.pxCSIBGYellow;
  pxCSIBGBlue = PIXELS.Console.pxCSIBGBlue;
  pxCSIBGMagenta = PIXELS.Console.pxCSIBGMagenta;
  pxCSIBGCyan = PIXELS.Console.pxCSIBGCyan;
  pxCSIBGWhite = PIXELS.Console.pxCSIBGWhite;
  pxCSIFGBrightBlack = PIXELS.Console.pxCSIFGBrightBlack;
  pxCSIFGBrightRed = PIXELS.Console.pxCSIFGBrightRed;
  pxCSIFGBrightGreen = PIXELS.Console.pxCSIFGBrightGreen;
  pxCSIFGBrightYellow = PIXELS.Console.pxCSIFGBrightYellow;
  pxCSIFGBrightBlue = PIXELS.Console.pxCSIFGBrightBlue;
  pxCSIFGBrightMagenta = PIXELS.Console.pxCSIFGBrightMagenta;
  pxCSIFGBrightCyan = PIXELS.Console.pxCSIFGBrightCyan;
  pxCSIFGBrightWhite = PIXELS.Console.pxCSIFGBrightWhite;
  pxCSIBGBrightBlack = PIXELS.Console.pxCSIBGBrightBlack;
  pxCSIBGBrightRed = PIXELS.Console.pxCSIBGBrightRed;
  pxCSIBGBrightGreen = PIXELS.Console.pxCSIBGBrightGreen;
  pxCSIBGBrightYellow = PIXELS.Console.pxCSIBGBrightYellow;
  pxCSIBGBrightBlue = PIXELS.Console.pxCSIBGBrightBlue;
  pxCSIBGBrightMagenta = PIXELS.Console.pxCSIBGBrightMagenta;
  pxCSIBGBrightCyan = PIXELS.Console.pxCSIBGBrightCyan;
  pxCSIBGBrightWhite = PIXELS.Console.pxCSIBGBrightWhite;
  pxCSIFGRGB = PIXELS.Console.pxCSIFGRGB;
  pxCSIBGRGB = PIXELS.Console.pxCSIBGRGB;
{$ENDREGION}

{$REGION 'IO Constants'}
const
  // IO constants
  CpxDefaultZipPassword = PIXELS.IO.CpxDefaultZipPassword;
{$ENDREGION}

{$REGION 'Enum Value Constants'}
const
  // TpxTextureKind enum values
  pxPixelArtTexture = PIXELS.Graphics.pxPixelArtTexture;
  pxHDTexture = PIXELS.Graphics.pxHDTexture;

  // TpxBlendMode enum values
  pxPreMultipliedAlphaBlendMode = PIXELS.Graphics.pxPreMultipliedAlphaBlendMode;
  pxNonPreMultipliedAlphaBlendMode = PIXELS.Graphics.pxNonPreMultipliedAlphaBlendMode;
  pxAdditiveAlphaBlendMode = PIXELS.Graphics.pxAdditiveAlphaBlendMode;
  pxCopySrcToDestBlendMode = PIXELS.Graphics.pxCopySrcToDestBlendMode;
  MultiplySrcAndDestBlendMode = PIXELS.Graphics.MultiplySrcAndDestBlendMode;

  // TpxBlendModeColor enum values
  pxColorNormalBlendModeColor = PIXELS.Graphics.pxColorNormalBlendModeColor;
  ColorAvgSrcDestBlendModeColor = PIXELS.Graphics.ColorAvgSrcDestBlendModeColor;

  // TpxAlign enum values
  pxAlignLeft = PIXELS.Graphics.pxAlignLeft;
  pxAlignCenter = PIXELS.Graphics.pxAlignCenter;
  pxAlignRight = PIXELS.Graphics.pxAlignRight;
  pxAlignInteger = PIXELS.Graphics.pxAlignInteger;

  // TpxShaderKind enum values
  pxVertexShader = PIXELS.Graphics.pxVertexShader;
  pxPixelShader = PIXELS.Graphics.pxPixelShader;

  // TVideoState enum values
  vsLoad = PIXELS.Graphics.vsLoad;
  vsUnload = PIXELS.Graphics.vsUnload;
  vsPlaying = PIXELS.Graphics.vsPlaying;
  vsPaused = PIXELS.Graphics.vsPaused;
  vsFinished = PIXELS.Graphics.vsFinished;

  // TpxEase enum values
  pxEaseLinearTween = PIXELS.Math.pxEaseLinearTween;
  pxEaseInQuad = PIXELS.Math.pxEaseInQuad;
  pxEaseOutQuad = PIXELS.Math.pxEaseOutQuad;
  pxEaseInOutQuad = PIXELS.Math.pxEaseInOutQuad;
  pxEaseInCubic = PIXELS.Math.pxEaseInCubic;
  pxEaseOutCubic = PIXELS.Math.pxEaseOutCubic;
  pxEaseInOutCubic = PIXELS.Math.pxEaseInOutCubic;
  pxEaseInQuart = PIXELS.Math.pxEaseInQuart;
  pxEaseOutQuart = PIXELS.Math.pxEaseOutQuart;
  pxEaseInOutQuart = PIXELS.Math.pxEaseInOutQuart;
  pxEaseInQuint = PIXELS.Math.pxEaseInQuint;
  pxEaseOutQuint = PIXELS.Math.pxEaseOutQuint;
  pxEaseInOutQuint = PIXELS.Math.pxEaseInOutQuint;
  pxEaseInSine = PIXELS.Math.pxEaseInSine;
  pxEaseOutSine = PIXELS.Math.pxEaseOutSine;
  pxEaseInOutSine = PIXELS.Math.pxEaseInOutSine;
  pxEaseInExpo = PIXELS.Math.pxEaseInExpo;
  pxEaseOutExpo = PIXELS.Math.pxEaseOutExpo;
  pxEaseInOutExpo = PIXELS.Math.pxEaseInOutExpo;
  pxEaseInCircle = PIXELS.Math.pxEaseInCircle;
  pxEaseOutCircle = PIXELS.Math.pxEaseOutCircle;
  pxEaseInOutCircle = PIXELS.Math.pxEaseInOutCircle;
  pxEaseInElastic = PIXELS.Math.pxEaseInElastic;
  pxEaseOutElastic = PIXELS.Math.pxEaseOutElastic;
  pxEaseInOutElastic = PIXELS.Math.pxEaseInOutElastic;
  pxEaseInBack = PIXELS.Math.pxEaseInBack;
  pxEaseOutBack = PIXELS.Math.pxEaseOutBack;
  pxEaseInOutBack = PIXELS.Math.pxEaseInOutBack;
  pxEaseInBounce = PIXELS.Math.pxEaseInBounce;
  pxEaseOutBounce = PIXELS.Math.pxEaseOutBounce;
  pxEaseInOutBounce = PIXELS.Math.pxEaseInOutBounce;

  // TpxLoopMode enum values
  pxLoopNone = PIXELS.Math.pxLoopNone;
  pxLoopRepeat = PIXELS.Math.pxLoopRepeat;
  pxLoopPingPong = PIXELS.Math.pxLoopPingPong;
  pxLoopReverse = PIXELS.Math.pxLoopReverse;

  // TpxLineIntersection enum values
  liNone = PIXELS.Math.liNone;
  liTrue = PIXELS.Math.liTrue;
  liParallel = PIXELS.Math.liParallel;

  // TpxPlayMode enum values
  pmOnce = PIXELS.Audio.pmOnce;
  pmLoop = PIXELS.Audio.pmLoop;
  pmBiDir = PIXELS.Audio.pmBiDir;
  pmLoopOnce = PIXELS.Audio.pmLoopOnce;

  // TpxSeekMode enum values
  smStart = PIXELS.IO.smStart;
  smCurrent = PIXELS.IO.smCurrent;
  smEnd = PIXELS.IO.smEnd;

  // TpxCollisionMethod enum values
  cmAuto = PIXELS.Sprite.cmAuto;
  cmCircle = PIXELS.Sprite.cmCircle;
  cmAABB = PIXELS.Sprite.cmAABB;
  cmOBB = PIXELS.Sprite.cmOBB;
  cmPixelPerfect = PIXELS.Sprite.cmPixelPerfect;

  // TpxAnimationMode enum values
  amOnce = PIXELS.Sprite.amOnce;
  amLoop = PIXELS.Sprite.amLoop;
  amPingPong = PIXELS.Sprite.amPingPong;
  amReverse = PIXELS.Sprite.amReverse;

  // Color constants (as typed constants)
  pxALICEBLUE: TpxColor = (r:$F0/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  pxANTIQUEWHITE: TpxColor = (r:$FA/$FF; g:$EB/$FF; b:$D7/$FF; a:$FF/$FF);
  pxAQUA: TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxAQUAMARINE: TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$D4/$FF; a:$FF/$FF);
  pxAZURE: TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxBEIGE: TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$DC/$FF; a:$FF/$FF);
  pxBISQUE: TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$C4/$FF; a:$FF/$FF);
  pxBLACK: TpxColor = (r:$00/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxBLANCHEDALMOND: TpxColor = (r:$FF/$FF; g:$EB/$FF; b:$CD/$FF; a:$FF/$FF);
  pxBLUE: TpxColor = (r:$00/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxBLUEVIOLET: TpxColor = (r:$8A/$FF; g:$2B/$FF; b:$E2/$FF; a:$FF/$FF);
  pxBROWN: TpxColor = (r:$A5/$FF; g:$2A/$FF; b:$2A/$FF; a:$FF/$FF);
  pxBURLYWOOD: TpxColor = (r:$DE/$FF; g:$B8/$FF; b:$87/$FF; a:$FF/$FF);
  pxCADETBLUE: TpxColor = (r:$5F/$FF; g:$9E/$FF; b:$A0/$FF; a:$FF/$FF);
  pxCHARTREUSE: TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxCHOCOLATE: TpxColor = (r:$D2/$FF; g:$69/$FF; b:$1E/$FF; a:$FF/$FF);
  pxCORAL: TpxColor = (r:$FF/$FF; g:$7F/$FF; b:$50/$FF; a:$FF/$FF);
  pxCORNFLOWERBLUE: TpxColor = (r:$64/$FF; g:$95/$FF; b:$ED/$FF; a:$FF/$FF);
  pxCORNSILK: TpxColor = (r:$FF/$FF; g:$F8/$FF; b:$DC/$FF; a:$FF/$FF);
  pxCRIMSON: TpxColor = (r:$DC/$FF; g:$14/$FF; b:$3C/$FF; a:$FF/$FF);
  pxCYAN: TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxDARKBLUE: TpxColor = (r:$00/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKCYAN: TpxColor = (r:$00/$FF; g:$8B/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKGOLDENROD: TpxColor = (r:$B8/$FF; g:$86/$FF; b:$0B/$FF; a:$FF/$FF);
  pxDARKGRAY: TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  pxDARKGREEN: TpxColor = (r:$00/$FF; g:$64/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKGREY: TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  pxDARKKHAKI: TpxColor = (r:$BD/$FF; g:$B7/$FF; b:$6B/$FF; a:$FF/$FF);
  pxDARKMAGENTA: TpxColor = (r:$8B/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKOLIVEGREEN: TpxColor = (r:$55/$FF; g:$6B/$FF; b:$2F/$FF; a:$FF/$FF);
  pxDARKORANGE: TpxColor = (r:$FF/$FF; g:$8C/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKORCHID: TpxColor = (r:$99/$FF; g:$32/$FF; b:$CC/$FF; a:$FF/$FF);
  pxDARKRED: TpxColor = (r:$8B/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKSALMON: TpxColor = (r:$E9/$FF; g:$96/$FF; b:$7A/$FF; a:$FF/$FF);
  pxDARKSEAGREEN: TpxColor = (r:$8F/$FF; g:$BC/$FF; b:$8F/$FF; a:$FF/$FF);
  pxDARKSLATEBLUE: TpxColor = (r:$48/$FF; g:$3D/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKSLATEGRAY: TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  pxDARKSLATEGREY: TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  pxDARKTURQUOISE: TpxColor = (r:$00/$FF; g:$CE/$FF; b:$D1/$FF; a:$FF/$FF);
  pxDARKVIOLET: TpxColor = (r:$94/$FF; g:$00/$FF; b:$D3/$FF; a:$FF/$FF);
  pxDEEPPINK: TpxColor = (r:$FF/$FF; g:$14/$FF; b:$93/$FF; a:$FF/$FF);
  pxDEEPSKYBLUE: TpxColor = (r:$00/$FF; g:$BF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxDIMGRAY: TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  pxDIMGREY: TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  pxDODGERBLUE: TpxColor = (r:$1E/$FF; g:$90/$FF; b:$FF/$FF; a:$FF/$FF);
  pxFIREBRICK: TpxColor = (r:$B2/$FF; g:$22/$FF; b:$22/$FF; a:$FF/$FF);
  pxFLORALWHITE: TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$F0/$FF; a:$FF/$FF);
  pxFORESTGREEN: TpxColor = (r:$22/$FF; g:$8B/$FF; b:$22/$FF; a:$FF/$FF);
  pxFUCHSIA: TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxGAINSBORO: TpxColor = (r:$DC/$FF; g:$DC/$FF; b:$DC/$FF; a:$FF/$FF);
  pxGHOSTWHITE: TpxColor = (r:$F8/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  pxGOLD: TpxColor = (r:$FF/$FF; g:$D7/$FF; b:$00/$FF; a:$FF/$FF);
  pxGOLDENROD: TpxColor = (r:$DA/$FF; g:$A5/$FF; b:$20/$FF; a:$FF/$FF);
  pxGRAY: TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxGREEN: TpxColor = (r:$00/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  pxGREENYELLOW: TpxColor = (r:$AD/$FF; g:$FF/$FF; b:$2F/$FF; a:$FF/$FF);
  pxGREY: TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxHONEYDEW: TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  pxHOTPINK: TpxColor = (r:$FF/$FF; g:$69/$FF; b:$B4/$FF; a:$FF/$FF);
  pxINDIANRED: TpxColor = (r:$CD/$FF; g:$5C/$FF; b:$5C/$FF; a:$FF/$FF);
  pxINDIGO: TpxColor = (r:$4B/$FF; g:$00/$FF; b:$82/$FF; a:$FF/$FF);
  pxIVORY: TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  pxKHAKI: TpxColor = (r:$F0/$FF; g:$E6/$FF; b:$8C/$FF; a:$FF/$FF);
  pxLAVENDER: TpxColor = (r:$E6/$FF; g:$E6/$FF; b:$FA/$FF; a:$FF/$FF);
  pxLAVENDERBLUSH: TpxColor = (r:$FF/$FF; g:$F0/$FF; b:$F5/$FF; a:$FF/$FF);
  pxLAWNGREEN: TpxColor = (r:$7C/$FF; g:$FC/$FF; b:$00/$FF; a:$FF/$FF);
  pxLEMONCHIFFON: TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$CD/$FF; a:$FF/$FF);
  pxLIGHTBLUE: TpxColor = (r:$AD/$FF; g:$D8/$FF; b:$E6/$FF; a:$FF/$FF);
  pxLIGHTCORAL: TpxColor = (r:$F0/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxLIGHTCYAN: TpxColor = (r:$E0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxLIGHTGOLDENRODYELLOW: TpxColor = (r:$FA/$FF; g:$FA/$FF; b:$D2/$FF; a:$FF/$FF);
  pxLIGHTGRAY: TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  pxLIGHTGREEN: TpxColor = (r:$90/$FF; g:$EE/$FF; b:$90/$FF; a:$FF/$FF);
  pxLIGHTGREY: TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  pxLIGHTPINK: TpxColor = (r:$FF/$FF; g:$B6/$FF; b:$C1/$FF; a:$FF/$FF);
  pxLIGHTSALMON: TpxColor = (r:$FF/$FF; g:$A0/$FF; b:$7A/$FF; a:$FF/$FF);
  pxLIGHTSEAGREEN: TpxColor = (r:$20/$FF; g:$B2/$FF; b:$AA/$FF; a:$FF/$FF);
  pxLIGHTSKYBLUE: TpxColor = (r:$87/$FF; g:$CE/$FF; b:$FA/$FF; a:$FF/$FF);
  pxLIGHTSLATEGRAY: TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  pxLIGHTSLATEGREY: TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  pxLIGHTSTEELBLUE: TpxColor = (r:$B0/$FF; g:$C4/$FF; b:$DE/$FF; a:$FF/$FF);
  pxLIGHTYELLOW: TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$E0/$FF; a:$FF/$FF);
  pxLIME: TpxColor = (r:$00/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxLIMEGREEN: TpxColor = (r:$32/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  pxLINEN: TpxColor = (r:$FA/$FF; g:$F0/$FF; b:$E6/$FF; a:$FF/$FF);
  pxMAGENTA: TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxMAROON: TpxColor = (r:$80/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxMEDIUMAQUAMARINE: TpxColor = (r:$66/$FF; g:$CD/$FF; b:$AA/$FF; a:$FF/$FF);
  pxMEDIUMBLUE: TpxColor = (r:$00/$FF; g:$00/$FF; b:$CD/$FF; a:$FF/$FF);
  pxMEDIUMORCHID: TpxColor = (r:$BA/$FF; g:$55/$FF; b:$D3/$FF; a:$FF/$FF);
  pxMEDIUMPURPLE: TpxColor = (r:$93/$FF; g:$70/$FF; b:$DB/$FF; a:$FF/$FF);
  pxMEDIUMSEAGREEN: TpxColor = (r:$3C/$FF; g:$B3/$FF; b:$71/$FF; a:$FF/$FF);
  pxMEDIUMSLATEBLUE: TpxColor = (r:$7B/$FF; g:$68/$FF; b:$EE/$FF; a:$FF/$FF);
  pxMEDIUMSPRINGGREEN: TpxColor = (r:$00/$FF; g:$FA/$FF; b:$9A/$FF; a:$FF/$FF);
  pxMEDIUMTURQUOISE: TpxColor = (r:$48/$FF; g:$D1/$FF; b:$CC/$FF; a:$FF/$FF);
  pxMEDIUMVIOLETRED: TpxColor = (r:$C7/$FF; g:$15/$FF; b:$85/$FF; a:$FF/$FF);
  pxMIDNIGHTBLUE: TpxColor = (r:$19/$FF; g:$19/$FF; b:$70/$FF; a:$FF/$FF);
  pxMINTCREAM: TpxColor = (r:$F5/$FF; g:$FF/$FF; b:$FA/$FF; a:$FF/$FF);
  pxMISTYROSE: TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$E1/$FF; a:$FF/$FF);
  pxMOCCASIN: TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$B5/$FF; a:$FF/$FF);
  pxNAVAJOWHITE: TpxColor = (r:$FF/$FF; g:$DE/$FF; b:$AD/$FF; a:$FF/$FF);
  pxNAVY: TpxColor = (r:$00/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  pxOLDLACE: TpxColor = (r:$FD/$FF; g:$F5/$FF; b:$E6/$FF; a:$FF/$FF);
  pxOLIVE: TpxColor = (r:$80/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  pxOLIVEDRAB: TpxColor = (r:$6B/$FF; g:$8E/$FF; b:$23/$FF; a:$FF/$FF);
  pxORANGE: TpxColor = (r:$FF/$FF; g:$A5/$FF; b:$00/$FF; a:$FF/$FF);
  pxORANGERED: TpxColor = (r:$FF/$FF; g:$45/$FF; b:$00/$FF; a:$FF/$FF);
  pxORCHID: TpxColor = (r:$DA/$FF; g:$70/$FF; b:$D6/$FF; a:$FF/$FF);
  pxPALEGOLDENROD: TpxColor = (r:$EE/$FF; g:$E8/$FF; b:$AA/$FF; a:$FF/$FF);
  pxPALEGREEN: TpxColor = (r:$98/$FF; g:$FB/$FF; b:$98/$FF; a:$FF/$FF);
  pxPALETURQUOISE: TpxColor = (r:$AF/$FF; g:$EE/$FF; b:$EE/$FF; a:$FF/$FF);
  pxPALEVIOLETRED: TpxColor = (r:$DB/$FF; g:$70/$FF; b:$93/$FF; a:$FF/$FF);
  pxPAPAYAWHIP: TpxColor = (r:$FF/$FF; g:$EF/$FF; b:$D5/$FF; a:$FF/$FF);
  pxPEACHPUFF: TpxColor = (r:$FF/$FF; g:$DA/$FF; b:$B9/$FF; a:$FF/$FF);
  pxPERU: TpxColor = (r:$CD/$FF; g:$85/$FF; b:$3F/$FF; a:$FF/$FF);
  pxPINK: TpxColor = (r:$FF/$FF; g:$C0/$FF; b:$CB/$FF; a:$FF/$FF);
  pxPLUM: TpxColor = (r:$DD/$FF; g:$A0/$FF; b:$DD/$FF; a:$FF/$FF);
  pxPOWDERBLUE: TpxColor = (r:$B0/$FF; g:$E0/$FF; b:$E6/$FF; a:$FF/$FF);
  pxPURPLE: TpxColor = (r:$80/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  pxREBECCAPURPLE: TpxColor = (r:$66/$FF; g:$33/$FF; b:$99/$FF; a:$FF/$FF);
  pxRED: TpxColor = (r:$FF/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxROSYBROWN: TpxColor = (r:$BC/$FF; g:$8F/$FF; b:$8F/$FF; a:$FF/$FF);
  pxROYALBLUE: TpxColor = (r:$41/$FF; g:$69/$FF; b:$E1/$FF; a:$FF/$FF);
  pxSADDLEBROWN: TpxColor = (r:$8B/$FF; g:$45/$FF; b:$13/$FF; a:$FF/$FF);
  pxSALMON: TpxColor = (r:$FA/$FF; g:$80/$FF; b:$72/$FF; a:$FF/$FF);
  pxSANDYBROWN: TpxColor = (r:$F4/$FF; g:$A4/$FF; b:$60/$FF; a:$FF/$FF);
  pxSEAGREEN: TpxColor = (r:$2E/$FF; g:$8B/$FF; b:$57/$FF; a:$FF/$FF);
  pxSEASHELL: TpxColor = (r:$FF/$FF; g:$F5/$FF; b:$EE/$FF; a:$FF/$FF);
  pxSIENNA: TpxColor = (r:$A0/$FF; g:$52/$FF; b:$2D/$FF; a:$FF/$FF);
  pxSILVER: TpxColor = (r:$C0/$FF; g:$C0/$FF; b:$C0/$FF; a:$FF/$FF);
  pxSKYBLUE: TpxColor = (r:$87/$FF; g:$CE/$FF; b:$EB/$FF; a:$FF/$FF);
  pxSLATEBLUE: TpxColor = (r:$6A/$FF; g:$5A/$FF; b:$CD/$FF; a:$FF/$FF);
  pxSLATEGRAY: TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  pxSLATEGREY: TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  pxSNOW: TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$FA/$FF; a:$FF/$FF);
  pxSPRINGGREEN: TpxColor = (r:$00/$FF; g:$FF/$FF; b:$7F/$FF; a:$FF/$FF);
  pxSTEELBLUE: TpxColor = (r:$46/$FF; g:$82/$FF; b:$B4/$FF; a:$FF/$FF);
  pxTAN: TpxColor = (r:$D2/$FF; g:$B4/$FF; b:$8C/$FF; a:$FF/$FF);
  pxTEAL: TpxColor = (r:$00/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxTHISTLE: TpxColor = (r:$D8/$FF; g:$BF/$FF; b:$D8/$FF; a:$FF/$FF);
  pxTOMATO: TpxColor = (r:$FF/$FF; g:$63/$FF; b:$47/$FF; a:$FF/$FF);
  pxTURQUOISE: TpxColor = (r:$40/$FF; g:$E0/$FF; b:$D0/$FF; a:$FF/$FF);
  pxVIOLET: TpxColor = (r:$EE/$FF; g:$82/$FF; b:$EE/$FF; a:$FF/$FF);
  pxWHEAT: TpxColor = (r:$F5/$FF; g:$DE/$FF; b:$B3/$FF; a:$FF/$FF);
  pxWHITE: TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxWHITESMOKE: TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  pxYELLOW: TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxYELLOWGREEN: TpxColor = (r:$9A/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  pxBLANK: TpxColor = (r:$00; g:$00; b:$00; a:$00);
  pxWHITE2: TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  pxRED2: TpxColor = (r:$7E/$FF; g:$32/$FF; b:$3F/$FF; a:255/$FF);
  pxCOLORKEY: TpxColor = (r:$FF/$FF; g:$00; b:$FF/$FF; a:$FF/$FF);
  pxOVERLAY1: TpxColor = (r:$00/$FF; g:$20/$FF; b:$29/$FF; a:$B4/$FF);
  pxOVERLAY2: TpxColor = (r:$01/$FF; g:$1B/$FF; b:$01/$FF; a:255/$FF);
  pxDIMWHITE: TpxColor = (r:$10/$FF; g:$10/$FF; b:$10/$FF; a:$10/$FF);
  pxDARKSLATEBROWN: TpxColor = (r:30/255; g:31/255; b:30/255; a:1/255);
{$ENDREGION}

type
{$REGION 'Base Types'}
  // Base types
  TpxStaticObject = PIXELS.Base.TpxStaticObject;
  TpxObject = PIXELS.Base.TpxObject;
  TpxResourceTracker = PIXELS.Base.TpxResourceTracker;
{$ENDREGION}

{$REGION 'Math Types'}
  // Math types
  TpxEase = PIXELS.Math.TpxEase;
  TpxLoopMode = PIXELS.Math.TpxLoopMode;
  TpxEaseParams = PIXELS.Math.TpxEaseParams;
  TpxVector = PIXELS.Math.TpxVector;
  PpxVector = PIXELS.Math.PpxVector;
  TpxRect = PIXELS.Math.TpxRect;
  PpxRect = PIXELS.Math.PpxRect;
  TpxSize = PIXELS.Math.TpxSize;
  PpxSize = PIXELS.Math.PpxSize;
  TpxRange = PIXELS.Math.TpxRange;
  PpxRange = PIXELS.Math.PpxRange;
  TpxLineIntersection = PIXELS.Math.TpxLineIntersection;
  TpxRay = PIXELS.Math.TpxRay;
  TpxOBB = PIXELS.Math.TpxOBB;
  TpxMath = PIXELS.Math.TpxMath;
{$ENDREGION}

{$REGION 'Graphics Types'}
  // Graphics types
  TpxColor = PIXELS.Graphics.TpxColor;
  PpxColor = PIXELS.Graphics.PpxColor;
  TpxBlendMode = PIXELS.Graphics.TpxBlendMode;
  TpxBlendModeColor = PIXELS.Graphics.TpxBlendModeColor;
  TpxWindow = PIXELS.Graphics.TpxWindow;
  TpxAlign = PIXELS.Graphics.TpxAlign;
  TpxFont = PIXELS.Graphics.TpxFont;
  TpxTextureKind = PIXELS.Graphics.TpxTextureKind;
  TpxTextureData = PIXELS.Graphics.TpxTextureData;
  PpxTextureData = PIXELS.Graphics.PpxTextureData;
  TpxTexture = PIXELS.Graphics.TpxTexture;
  TpxShaderKind = PIXELS.Graphics.TpxShaderKind;
  TpxShader = PIXELS.Graphics.TpxShader;
  TpxCamera = PIXELS.Graphics.TpxCamera;
  TVideoState = PIXELS.Graphics.TpxVideoState;
  TpxVideo = PIXELS.Graphics.TpxVideo;
{$ENDREGION}

{$REGION 'Events Types'}
  // Events types
  TpxInput = PIXELS.Events.TpxInput;
{$ENDREGION}

{$REGION 'Audio Types'}
  // Audio types
  TpxPlayMode = PIXELS.Audio.TpxPlayMode;
  PpxSample = PIXELS.Audio.PpxSample;
  TpxSampleID = PIXELS.Audio.TpxSampleID;
  PpxSampleID = PIXELS.Audio.PpxSampleID;
  TpxAudio = PIXELS.Audio.TpxAudio;
{$ENDREGION}

{$REGION 'Console Types'}
  // Console types
  TpxCharSet = PIXELS.Console.TpxCharSet;
  TpxConsole = PIXELS.Console.TpxConsole;
{$ENDREGION}

{$REGION 'IO Types'}
  // IO types
  TpxSeekMode = PIXELS.IO.TpxSeekMode;
  PpxFile = PIXELS.IO.PpxFile;
  TpxFile = PIXELS.IO.TpxFile;
{$ENDREGION}

{$REGION 'Core Types'}
  // Core types
  TPixels = PIXELS.Core.TPixels;
{$ENDREGION}

{$REGION 'Game Types'}
  // Game types
  TpxGameClass = PIXELS.Game.TpxGameClass;
  TpxGame = PIXELS.Game.TpxGame;
{$ENDREGION}

{$REGION 'Utils Types'}
  // Utils types
  //TpxCallback<T> = PIXELS.Utils.TpxCallback<T>;
  TpxUtils = PIXELS.Utils.TpxUtils;
{$ENDREGION}

{$REGION 'Sprite Types'}
  // Sprite types
  TpxCollisionMethod = PIXELS.Sprite.TpxCollisionMethod;
  TpxAnimationMode = PIXELS.Sprite.TpxAnimationMode;
  TpxAnimationCompleteEvent = PIXELS.Sprite.TpxAnimationCompleteEvent;
  TpxAnimationFrameEvent = PIXELS.Sprite.TpxAnimationFrameEvent;
  TpxAnimationSequence = PIXELS.Sprite.TpxAnimationSequence;
  TpxTextureRegion = PIXELS.Sprite.TpxTextureRegion;
  TpxTextureAtlas = PIXELS.Sprite.TpxTextureAtlas;
  TpxSprite = PIXELS.Sprite.TpxSprite;
{$ENDREGION}

{$REGION 'Game Routines'}
  // Game routines
  procedure pxRunGame(const AGame: TpxGameClass);
{$ENDREGION}

implementation

{$REGION 'Game Routines Implementation'}
procedure pxRunGame(const AGame: TpxGameClass);
begin
  PIXELS.Game.pxRunGame(AGame);
end;
{$ENDREGION}

end.
