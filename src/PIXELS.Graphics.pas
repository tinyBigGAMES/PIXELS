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

unit PIXELS.Graphics;

{$I PIXELS.Defines.inc}

interface

uses
  WinApi.Windows,
  PIXELS.Deps,
  PIXELS.Base,
  PIXELS.Math,
  PIXELS.IO;

type
  /// <summary>
  /// Represents an RGBA color with floating-point components ranging from 0.0 to 1.0
  /// </summary>
  /// <remarks>
  /// TpxColor is a record structure used throughout PIXELS for color representation.
  /// Each component (r, g, b, a) uses Single precision floating-point values where
  /// 0.0 represents no intensity and 1.0 represents full intensity.
  /// </remarks>
  { TpxColor }
  PpxColor = ^TpxColor;
  TpxColor = record
    r,g,b,a: Single;
    /// <summary>
    /// Creates a color from byte values (0-255) and converts them to floating-point
    /// </summary>
    /// <param name="AR">Red component (0-255)</param>
    /// <param name="AG">Green component (0-255)</param>
    /// <param name="AB">Blue component (0-255)</param>
    /// <param name="AA">Alpha component (0-255)</param>
    /// <returns>The TpxColor record with converted floating-point values</returns>
    /// <example>
    /// <code>
    /// LColor := LColor.FromByte(255, 128, 64, 255); // Orange color
    /// </code>
    /// </example>
    function FromByte(const AR, AG, AB,  AA: Byte): TpxColor;
    /// <summary>
    /// Creates a color from floating-point values (0.0-1.0)
    /// </summary>
    /// <param name="AR">Red component (0.0-1.0)</param>
    /// <param name="AG">Green component (0.0-1.0)</param>
    /// <param name="AB">Blue component (0.0-1.0)</param>
    /// <param name="AA">Alpha component (0.0-1.0)</param>
    /// <returns>The TpxColor record with the specified values</returns>
    /// <example>
    /// <code>
    /// LColor := LColor.FromFloat(1.0, 0.5, 0.25, 1.0); // Orange color
    /// </code>
    /// </example>
    function FromFloat(const AR, AG, AB, AA: Single): TpxColor;
    /// <summary>
    /// Creates a color from a predefined color name string
    /// </summary>
    /// <param name="AName">The color name (e.g., "red", "blue", "green")</param>
    /// <returns>The TpxColor record for the named color</returns>
    /// <remarks>
    /// Supports standard CSS/HTML color names. Returns black if the name is not recognized.
    /// </remarks>
    /// <example>
    /// <code>
    /// LColor := LColor.FromName('crimson');
    /// LColor := LColor.FromName('palegreen');
    /// </code>
    /// </example>
    function FromName(const AName: string): TpxColor; overload;
    /// <summary>
    /// Interpolates between this color and another color
    /// </summary>
    /// <param name="ATo">The target color to fade towards</param>
    /// <param name="APos">Interpolation factor (0.0 = this color, 1.0 = target color)</param>
    /// <returns>The interpolated color</returns>
    /// <remarks>
    /// APos is automatically clamped to the range 0.0-1.0. Useful for color transitions and animations.
    /// </remarks>
    /// <example>
    /// <code>
    /// LFadedColor := pxRED.Fade(pxBLUE, 0.5); // 50% between red and blue
    /// </code>
    /// </example>
    function Fade(const ATo: TpxColor; APos: Single): TpxColor;
    /// <summary>
    /// Compares this color with another color for exact equality
    /// </summary>
    /// <param name="AColor">The color to compare against</param>
    /// <returns>True if all RGBA components are exactly equal</returns>
    /// <remarks>
    /// Uses exact floating-point comparison. For fuzzy comparison, use manual epsilon checking.
    /// </remarks>
    function Equal(const AColor: TpxColor): Boolean;
    /// <summary>
    /// Interpolates between this color and another using an easing function
    /// </summary>
    /// <param name="ATo">The target color</param>
    /// <param name="AProgress">Animation progress (0.0-1.0)</param>
    /// <param name="AEase">The easing function to apply</param>
    /// <returns>The interpolated color with easing applied</returns>
    /// <seealso cref="TpxEase"/>
    /// <example>
    /// <code>
    /// LColor := pxRED.Ease(pxBLUE, 0.3, pxEaseInOut);
    /// </code>
    /// </example>
    function Ease(const ATo: TpxColor; const AProgress: Double; const AEase: TpxEase): TpxColor;
  end;

{$REGION ' COMMON COLORS '}
/// <summary>Alice blue color constant (240, 248, 255)</summary>
const
  pxALICEBLUE           : TpxColor = (r:$F0/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Antique white color constant (250, 235, 215)</summary>
  pxANTIQUEWHITE        : TpxColor = (r:$FA/$FF; g:$EB/$FF; b:$D7/$FF; a:$FF/$FF);
  /// <summary>Aqua color constant (0, 255, 255)</summary>
  pxAQUA                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Aquamarine color constant (127, 255, 212)</summary>
  pxAQUAMARINE          : TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$D4/$FF; a:$FF/$FF);
  /// <summary>Azure color constant (240, 255, 255)</summary>
  pxAZURE               : TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Beige color constant (245, 245, 220)</summary>
  pxBEIGE               : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$DC/$FF; a:$FF/$FF);
  /// <summary>Bisque color constant (255, 228, 196)</summary>
  pxBISQUE              : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$C4/$FF; a:$FF/$FF);
  /// <summary>Pure black color constant (0, 0, 0)</summary>
  pxBLACK               : TpxColor = (r:$00/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Blanched almond color constant (255, 235, 205)</summary>
  pxBLANCHEDALMOND      : TpxColor = (r:$FF/$FF; g:$EB/$FF; b:$CD/$FF; a:$FF/$FF);
  /// <summary>Pure blue color constant (0, 0, 255)</summary>
  pxBLUE                : TpxColor = (r:$00/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Blue violet color constant (138, 43, 226)</summary>
  pxBLUEVIOLET          : TpxColor = (r:$8A/$FF; g:$2B/$FF; b:$E2/$FF; a:$FF/$FF);
  /// <summary>Brown color constant (165, 42, 42)</summary>
  pxBROWN               : TpxColor = (r:$A5/$FF; g:$2A/$FF; b:$2A/$FF; a:$FF/$FF);
  /// <summary>Burlywood color constant (222, 184, 135)</summary>
  pxBURLYWOOD           : TpxColor = (r:$DE/$FF; g:$B8/$FF; b:$87/$FF; a:$FF/$FF);
  /// <summary>Cadet blue color constant (95, 158, 160)</summary>
  pxCADETBLUE           : TpxColor = (r:$5F/$FF; g:$9E/$FF; b:$A0/$FF; a:$FF/$FF);
  /// <summary>Chartreuse color constant (127, 255, 0)</summary>
  pxCHARTREUSE          : TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Chocolate color constant (210, 105, 30)</summary>
  pxCHOCOLATE           : TpxColor = (r:$D2/$FF; g:$69/$FF; b:$1E/$FF; a:$FF/$FF);
  /// <summary>Coral color constant (255, 127, 80)</summary>
  pxCORAL               : TpxColor = (r:$FF/$FF; g:$7F/$FF; b:$50/$FF; a:$FF/$FF);
  /// <summary>Cornflower blue color constant (100, 149, 237)</summary>
  pxCORNFLOWERBLUE      : TpxColor = (r:$64/$FF; g:$95/$FF; b:$ED/$FF; a:$FF/$FF);
  /// <summary>Cornsilk color constant (255, 248, 220)</summary>
  pxCORNSILK            : TpxColor = (r:$FF/$FF; g:$F8/$FF; b:$DC/$FF; a:$FF/$FF);
  /// <summary>Crimson color constant (220, 20, 60)</summary>
  pxCRIMSON             : TpxColor = (r:$DC/$FF; g:$14/$FF; b:$3C/$FF; a:$FF/$FF);
  /// <summary>Cyan color constant (0, 255, 255)</summary>
  pxCYAN                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Dark blue color constant (0, 0, 139)</summary>
  pxDARKBLUE            : TpxColor = (r:$00/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  /// <summary>Dark cyan color constant (0, 139, 139)</summary>
  pxDARKCYAN            : TpxColor = (r:$00/$FF; g:$8B/$FF; b:$8B/$FF; a:$FF/$FF);
  /// <summary>Dark goldenrod color constant (184, 134, 11)</summary>
  pxDARKGOLDENROD       : TpxColor = (r:$B8/$FF; g:$86/$FF; b:$0B/$FF; a:$FF/$FF);
  /// <summary>Dark gray color constant (169, 169, 169)</summary>
  pxDARKGRAY            : TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  /// <summary>Dark green color constant (0, 100, 0)</summary>
  pxDARKGREEN           : TpxColor = (r:$00/$FF; g:$64/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Dark grey color constant (169, 169, 169)</summary>
  pxDARKGREY            : TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  /// <summary>Dark khaki color constant (189, 183, 107)</summary>
  pxDARKKHAKI           : TpxColor = (r:$BD/$FF; g:$B7/$FF; b:$6B/$FF; a:$FF/$FF);
  /// <summary>Dark magenta color constant (139, 0, 139)</summary>
  pxDARKMAGENTA         : TpxColor = (r:$8B/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  /// <summary>Dark olive green color constant (85, 107, 47)</summary>
  pxDARKOLIVEGREEN      : TpxColor = (r:$55/$FF; g:$6B/$FF; b:$2F/$FF; a:$FF/$FF);
  /// <summary>Dark orange color constant (255, 140, 0)</summary>
  pxDARKORANGE          : TpxColor = (r:$FF/$FF; g:$8C/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Dark orchid color constant (153, 50, 204)</summary>
  pxDARKORCHID          : TpxColor = (r:$99/$FF; g:$32/$FF; b:$CC/$FF; a:$FF/$FF);
  /// <summary>Dark red color constant (139, 0, 0)</summary>
  pxDARKRED             : TpxColor = (r:$8B/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Dark salmon color constant (233, 150, 122)</summary>
  pxDARKSALMON          : TpxColor = (r:$E9/$FF; g:$96/$FF; b:$7A/$FF; a:$FF/$FF);
  /// <summary>Dark sea green color constant (143, 188, 143)</summary>
  pxDARKSEAGREEN        : TpxColor = (r:$8F/$FF; g:$BC/$FF; b:$8F/$FF; a:$FF/$FF);
  /// <summary>Dark slate blue color constant (72, 61, 139)</summary>
  pxDARKSLATEBLUE       : TpxColor = (r:$48/$FF; g:$3D/$FF; b:$8B/$FF; a:$FF/$FF);
  /// <summary>Dark slate gray color constant (47, 79, 79)</summary>
  pxDARKSLATEGRAY       : TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  /// <summary>Dark slate grey color constant (47, 79, 79)</summary>
  pxDARKSLATEGREY       : TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  /// <summary>Dark turquoise color constant (0, 206, 209)</summary>
  pxDARKTURQUOISE       : TpxColor = (r:$00/$FF; g:$CE/$FF; b:$D1/$FF; a:$FF/$FF);
  /// <summary>Dark violet color constant (148, 0, 211)</summary>
  pxDARKVIOLET          : TpxColor = (r:$94/$FF; g:$00/$FF; b:$D3/$FF; a:$FF/$FF);
  /// <summary>Deep pink color constant (255, 20, 147)</summary>
  pxDEEPPINK            : TpxColor = (r:$FF/$FF; g:$14/$FF; b:$93/$FF; a:$FF/$FF);
  /// <summary>Deep sky blue color constant (0, 191, 255)</summary>
  pxDEEPSKYBLUE         : TpxColor = (r:$00/$FF; g:$BF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Dim gray color constant (105, 105, 105)</summary>
  pxDIMGRAY             : TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  /// <summary>Dim grey color constant (105, 105, 105)</summary>
  pxDIMGREY             : TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  /// <summary>Dodger blue color constant (30, 144, 255)</summary>
  pxDODGERBLUE          : TpxColor = (r:$1E/$FF; g:$90/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Fire brick color constant (178, 34, 34)</summary>
  pxFIREBRICK           : TpxColor = (r:$B2/$FF; g:$22/$FF; b:$22/$FF; a:$FF/$FF);
  /// <summary>Floral white color constant (255, 250, 240)</summary>
  pxFLORALWHITE         : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$F0/$FF; a:$FF/$FF);
  /// <summary>Forest green color constant (34, 139, 34)</summary>
  pxFORESTGREEN         : TpxColor = (r:$22/$FF; g:$8B/$FF; b:$22/$FF; a:$FF/$FF);
  /// <summary>Fuchsia color constant (255, 0, 255)</summary>
  pxFUCHSIA             : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Gainsboro color constant (220, 220, 220)</summary>
  pxGAINSBORO           : TpxColor = (r:$DC/$FF; g:$DC/$FF; b:$DC/$FF; a:$FF/$FF);
  /// <summary>Ghost white color constant (248, 248, 255)</summary>
  pxGHOSTWHITE          : TpxColor = (r:$F8/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Gold color constant (255, 215, 0)</summary>
  pxGOLD                : TpxColor = (r:$FF/$FF; g:$D7/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Goldenrod color constant (218, 165, 32)</summary>
  pxGOLDENROD           : TpxColor = (r:$DA/$FF; g:$A5/$FF; b:$20/$FF; a:$FF/$FF);
  /// <summary>Gray color constant (128, 128, 128)</summary>
  pxGRAY                : TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Pure green color constant (0, 128, 0)</summary>
  pxGREEN               : TpxColor = (r:$00/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Green yellow color constant (173, 255, 47)</summary>
  pxGREENYELLOW         : TpxColor = (r:$AD/$FF; g:$FF/$FF; b:$2F/$FF; a:$FF/$FF);
  /// <summary>Grey color constant (128, 128, 128)</summary>
  pxGREY                : TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Honeydew color constant (240, 255, 240)</summary>
  pxHONEYDEW            : TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  /// <summary>Hot pink color constant (255, 105, 180)</summary>
  pxHOTPINK             : TpxColor = (r:$FF/$FF; g:$69/$FF; b:$B4/$FF; a:$FF/$FF);
  /// <summary>Indian red color constant (205, 92, 92)</summary>
  pxINDIANRED           : TpxColor = (r:$CD/$FF; g:$5C/$FF; b:$5C/$FF; a:$FF/$FF);
  /// <summary>Indigo color constant (75, 0, 130)</summary>
  pxINDIGO              : TpxColor = (r:$4B/$FF; g:$00/$FF; b:$82/$FF; a:$FF/$FF);
  /// <summary>Ivory color constant (255, 255, 240)</summary>
  pxIVORY               : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  /// <summary>Khaki color constant (240, 230, 140)</summary>
  pxKHAKI               : TpxColor = (r:$F0/$FF; g:$E6/$FF; b:$8C/$FF; a:$FF/$FF);
  /// <summary>Lavender color constant (230, 230, 250)</summary>
  pxLAVENDER            : TpxColor = (r:$E6/$FF; g:$E6/$FF; b:$FA/$FF; a:$FF/$FF);
  /// <summary>Lavender blush color constant (255, 240, 245)</summary>
  pxLAVENDERBLUSH       : TpxColor = (r:$FF/$FF; g:$F0/$FF; b:$F5/$FF; a:$FF/$FF);
  /// <summary>Lawn green color constant (124, 252, 0)</summary>
  pxLAWNGREEN           : TpxColor = (r:$7C/$FF; g:$FC/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Lemon chiffon color constant (255, 250, 205)</summary>
  pxLEMONCHIFFON        : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$CD/$FF; a:$FF/$FF);
  /// <summary>Light blue color constant (173, 216, 230)</summary>
  pxLIGHTBLUE           : TpxColor = (r:$AD/$FF; g:$D8/$FF; b:$E6/$FF; a:$FF/$FF);
  /// <summary>Light coral color constant (240, 128, 128)</summary>
  pxLIGHTCORAL          : TpxColor = (r:$F0/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Light cyan color constant (224, 255, 255)</summary>
  pxLIGHTCYAN           : TpxColor = (r:$E0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Light goldenrod yellow color constant (250, 250, 210)</summary>
  pxLIGHTGOLDENRODYELLOW: TpxColor = (r:$FA/$FF; g:$FA/$FF; b:$D2/$FF; a:$FF/$FF);
  /// <summary>Light gray color constant (211, 211, 211)</summary>
  pxLIGHTGRAY           : TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  /// <summary>Light green color constant (144, 238, 144)</summary>
  pxLIGHTGREEN          : TpxColor = (r:$90/$FF; g:$EE/$FF; b:$90/$FF; a:$FF/$FF);
  /// <summary>Light grey color constant (211, 211, 211)</summary>
  pxLIGHTGREY           : TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  /// <summary>Light pink color constant (255, 182, 193)</summary>
  pxLIGHTPINK           : TpxColor = (r:$FF/$FF; g:$B6/$FF; b:$C1/$FF; a:$FF/$FF);
  /// <summary>Light salmon color constant (255, 160, 122)</summary>
  pxLIGHTSALMON         : TpxColor = (r:$FF/$FF; g:$A0/$FF; b:$7A/$FF; a:$FF/$FF);
  /// <summary>Light sea green color constant (32, 178, 170)</summary>
  pxLIGHTSEAGREEN       : TpxColor = (r:$20/$FF; g:$B2/$FF; b:$AA/$FF; a:$FF/$FF);
  /// <summary>Light sky blue color constant (135, 206, 250)</summary>
  pxLIGHTSKYBLUE        : TpxColor = (r:$87/$FF; g:$CE/$FF; b:$FA/$FF; a:$FF/$FF);
  /// <summary>Light slate gray color constant (119, 136, 153)</summary>
  pxLIGHTSLATEGRAY      : TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  /// <summary>Light slate grey color constant (119, 136, 153)</summary>
  pxLIGHTSLATEGREY      : TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  /// <summary>Light steel blue color constant (176, 196, 222)</summary>
  pxLIGHTSTEELBLUE      : TpxColor = (r:$B0/$FF; g:$C4/$FF; b:$DE/$FF; a:$FF/$FF);
  /// <summary>Light yellow color constant (255, 255, 224)</summary>
  pxLIGHTYELLOW         : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$E0/$FF; a:$FF/$FF);
  /// <summary>Lime color constant (0, 255, 0)</summary>
  pxLIME                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Lime green color constant (50, 205, 50)</summary>
  pxLIMEGREEN           : TpxColor = (r:$32/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  /// <summary>Linen color constant (250, 240, 230)</summary>
  pxLINEN               : TpxColor = (r:$FA/$FF; g:$F0/$FF; b:$E6/$FF; a:$FF/$FF);
  /// <summary>Magenta color constant (255, 0, 255)</summary>
  pxMAGENTA             : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>Maroon color constant (128, 0, 0)</summary>
  pxMAROON              : TpxColor = (r:$80/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Medium aquamarine color constant (102, 205, 170)</summary>
  pxMEDIUMAQUAMARINE    : TpxColor = (r:$66/$FF; g:$CD/$FF; b:$AA/$FF; a:$FF/$FF);
  /// <summary>Medium blue color constant (0, 0, 205)</summary>
  pxMEDIUMBLUE          : TpxColor = (r:$00/$FF; g:$00/$FF; b:$CD/$FF; a:$FF/$FF);
  /// <summary>Medium orchid color constant (186, 85, 211)</summary>
  pxMEDIUMORCHID        : TpxColor = (r:$BA/$FF; g:$55/$FF; b:$D3/$FF; a:$FF/$FF);
  /// <summary>Medium purple color constant (147, 112, 219)</summary>
  pxMEDIUMPURPLE        : TpxColor = (r:$93/$FF; g:$70/$FF; b:$DB/$FF; a:$FF/$FF);
  /// <summary>Medium sea green color constant (60, 179, 113)</summary>
  pxMEDIUMSEAGREEN      : TpxColor = (r:$3C/$FF; g:$B3/$FF; b:$71/$FF; a:$FF/$FF);
  /// <summary>Medium slate blue color constant (123, 104, 238)</summary>
  pxMEDIUMSLATEBLUE     : TpxColor = (r:$7B/$FF; g:$68/$FF; b:$EE/$FF; a:$FF/$FF);
  /// <summary>Medium spring green color constant (0, 250, 154)</summary>
  pxMEDIUMSPRINGGREEN   : TpxColor = (r:$00/$FF; g:$FA/$FF; b:$9A/$FF; a:$FF/$FF);
  /// <summary>Medium turquoise color constant (72, 209, 204)</summary>
  pxMEDIUMTURQUOISE     : TpxColor = (r:$48/$FF; g:$D1/$FF; b:$CC/$FF; a:$FF/$FF);
  /// <summary>Medium violet red color constant (199, 21, 133)</summary>
  pxMEDIUMVIOLETRED     : TpxColor = (r:$C7/$FF; g:$15/$FF; b:$85/$FF; a:$FF/$FF);
  /// <summary>Midnight blue color constant (25, 25, 112)</summary>
  pxMIDNIGHTBLUE        : TpxColor = (r:$19/$FF; g:$19/$FF; b:$70/$FF; a:$FF/$FF);
  /// <summary>Mint cream color constant (245, 255, 250)</summary>
  pxMINTCREAM           : TpxColor = (r:$F5/$FF; g:$FF/$FF; b:$FA/$FF; a:$FF/$FF);
  /// <summary>Misty rose color constant (255, 228, 225)</summary>
  pxMISTYROSE           : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$E1/$FF; a:$FF/$FF);
  /// <summary>Moccasin color constant (255, 228, 181)</summary>
  pxMOCCASIN            : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$B5/$FF; a:$FF/$FF);
  /// <summary>Navajo white color constant (255, 222, 173)</summary>
  pxNAVAJOWHITE         : TpxColor = (r:$FF/$FF; g:$DE/$FF; b:$AD/$FF; a:$FF/$FF);
  /// <summary>Navy color constant (0, 0, 128)</summary>
  pxNAVY                : TpxColor = (r:$00/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Old lace color constant (253, 245, 230)</summary>
  pxOLDLACE             : TpxColor = (r:$FD/$FF; g:$F5/$FF; b:$E6/$FF; a:$FF/$FF);
  /// <summary>Olive color constant (128, 128, 0)</summary>
  pxOLIVE               : TpxColor = (r:$80/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Olive drab color constant (107, 142, 35)</summary>
  pxOLIVEDRAB           : TpxColor = (r:$6B/$FF; g:$8E/$FF; b:$23/$FF; a:$FF/$FF);
  /// <summary>Orange color constant (255, 165, 0)</summary>
  pxORANGE              : TpxColor = (r:$FF/$FF; g:$A5/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Orange red color constant (255, 69, 0)</summary>
  pxORANGERED           : TpxColor = (r:$FF/$FF; g:$45/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Orchid color constant (218, 112, 214)</summary>
  pxORCHID              : TpxColor = (r:$DA/$FF; g:$70/$FF; b:$D6/$FF; a:$FF/$FF);
  /// <summary>Pale goldenrod color constant (238, 232, 170)</summary>
  pxPALEGOLDENROD       : TpxColor = (r:$EE/$FF; g:$E8/$FF; b:$AA/$FF; a:$FF/$FF);
  /// <summary>Pale green color constant (152, 251, 152)</summary>
  pxPALEGREEN           : TpxColor = (r:$98/$FF; g:$FB/$FF; b:$98/$FF; a:$FF/$FF);
  /// <summary>Pale turquoise color constant (175, 238, 238)</summary>
  pxPALETURQUOISE       : TpxColor = (r:$AF/$FF; g:$EE/$FF; b:$EE/$FF; a:$FF/$FF);
  /// <summary>Pale violet red color constant (219, 112, 147)</summary>
  pxPALEVIOLETRED       : TpxColor = (r:$DB/$FF; g:$70/$FF; b:$93/$FF; a:$FF/$FF);
  /// <summary>Papaya whip color constant (255, 239, 213)</summary>
  pxPAPAYAWHIP          : TpxColor = (r:$FF/$FF; g:$EF/$FF; b:$D5/$FF; a:$FF/$FF);
  /// <summary>Peach puff color constant (255, 218, 185)</summary>
  pxPEACHPUFF           : TpxColor = (r:$FF/$FF; g:$DA/$FF; b:$B9/$FF; a:$FF/$FF);
  /// <summary>Peru color constant (205, 133, 63)</summary>
  pxPERU                : TpxColor = (r:$CD/$FF; g:$85/$FF; b:$3F/$FF; a:$FF/$FF);
  /// <summary>Pink color constant (255, 192, 203)</summary>
  pxPINK                : TpxColor = (r:$FF/$FF; g:$C0/$FF; b:$CB/$FF; a:$FF/$FF);
  /// <summary>Plum color constant (221, 160, 221)</summary>
  pxPLUM                : TpxColor = (r:$DD/$FF; g:$A0/$FF; b:$DD/$FF; a:$FF/$FF);
  /// <summary>Powder blue color constant (176, 224, 230)</summary>
  pxPOWDERBLUE          : TpxColor = (r:$B0/$FF; g:$E0/$FF; b:$E6/$FF; a:$FF/$FF);
  /// <summary>Purple color constant (128, 0, 128)</summary>
  pxPURPLE              : TpxColor = (r:$80/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Rebecca purple color constant (102, 51, 153)</summary>
  pxREBECCAPURPLE       : TpxColor = (r:$66/$FF; g:$33/$FF; b:$99/$FF; a:$FF/$FF);
  /// <summary>Pure red color constant (255, 0, 0)</summary>
  pxRED                 : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Rosy brown color constant (188, 143, 143)</summary>
  pxROSYBROWN           : TpxColor = (r:$BC/$FF; g:$8F/$FF; b:$8F/$FF; a:$FF/$FF);
  /// <summary>Royal blue color constant (65, 105, 225)</summary>
  pxROYALBLUE           : TpxColor = (r:$41/$FF; g:$69/$FF; b:$E1/$FF; a:$FF/$FF);
  /// <summary>Saddle brown color constant (139, 69, 19)</summary>
  pxSADDLEBROWN         : TpxColor = (r:$8B/$FF; g:$45/$FF; b:$13/$FF; a:$FF/$FF);
  /// <summary>Salmon color constant (250, 128, 114)</summary>
  pxSALMON              : TpxColor = (r:$FA/$FF; g:$80/$FF; b:$72/$FF; a:$FF/$FF);
  /// <summary>Sandy brown color constant (244, 164, 96)</summary>
  pxSANDYBROWN          : TpxColor = (r:$F4/$FF; g:$A4/$FF; b:$60/$FF; a:$FF/$FF);
  /// <summary>Sea green color constant (46, 139, 87)</summary>
  pxSEAGREEN            : TpxColor = (r:$2E/$FF; g:$8B/$FF; b:$57/$FF; a:$FF/$FF);
  /// <summary>Seashell color constant (255, 245, 238)</summary>
  pxSEASHELL            : TpxColor = (r:$FF/$FF; g:$F5/$FF; b:$EE/$FF; a:$FF/$FF);
  /// <summary>Sienna color constant (160, 82, 45)</summary>
  pxSIENNA              : TpxColor = (r:$A0/$FF; g:$52/$FF; b:$2D/$FF; a:$FF/$FF);
  /// <summary>Silver color constant (192, 192, 192)</summary>
  pxSILVER              : TpxColor = (r:$C0/$FF; g:$C0/$FF; b:$C0/$FF; a:$FF/$FF);
  /// <summary>Sky blue color constant (135, 206, 235)</summary>
  pxSKYBLUE             : TpxColor = (r:$87/$FF; g:$CE/$FF; b:$EB/$FF; a:$FF/$FF);
  /// <summary>Slate blue color constant (106, 90, 205)</summary>
  pxSLATEBLUE           : TpxColor = (r:$6A/$FF; g:$5A/$FF; b:$CD/$FF; a:$FF/$FF);
  /// <summary>Slate gray color constant (112, 128, 144)</summary>
  pxSLATEGRAY           : TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  /// <summary>Slate grey color constant (112, 128, 144)</summary>
  pxSLATEGREY           : TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  /// <summary>Snow color constant (255, 250, 250)</summary>
  pxSNOW                : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$FA/$FF; a:$FF/$FF);
  /// <summary>Spring green color constant (0, 255, 127)</summary>
  pxSPRINGGREEN         : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$7F/$FF; a:$FF/$FF);
  /// <summary>Steel blue color constant (70, 130, 180)</summary>
  pxSTEELBLUE           : TpxColor = (r:$46/$FF; g:$82/$FF; b:$B4/$FF; a:$FF/$FF);
  /// <summary>Tan color constant (210, 180, 140)</summary>
  pxTAN                 : TpxColor = (r:$D2/$FF; g:$B4/$FF; b:$8C/$FF; a:$FF/$FF);
  /// <summary>Teal color constant (0, 128, 128)</summary>
  pxTEAL                : TpxColor = (r:$00/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  /// <summary>Thistle color constant (216, 191, 216)</summary>
  pxTHISTLE             : TpxColor = (r:$D8/$FF; g:$BF/$FF; b:$D8/$FF; a:$FF/$FF);
  /// <summary>Tomato color constant (255, 99, 71)</summary>
  pxTOMATO              : TpxColor = (r:$FF/$FF; g:$63/$FF; b:$47/$FF; a:$FF/$FF);
  /// <summary>Turquoise color constant (64, 224, 208)</summary>
  pxTURQUOISE           : TpxColor = (r:$40/$FF; g:$E0/$FF; b:$D0/$FF; a:$FF/$FF);
  /// <summary>Violet color constant (238, 130, 238)</summary>
  pxVIOLET              : TpxColor = (r:$EE/$FF; g:$82/$FF; b:$EE/$FF; a:$FF/$FF);
  /// <summary>Wheat color constant (245, 222, 179)</summary>
  pxWHEAT               : TpxColor = (r:$F5/$FF; g:$DE/$FF; b:$B3/$FF; a:$FF/$FF);
  /// <summary>Pure white color constant (255, 255, 255)</summary>
  pxWHITE               : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  /// <summary>White smoke color constant (245, 245, 245)</summary>
  pxWHITESMOKE          : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  /// <summary>Pure yellow color constant (255, 255, 0)</summary>
  pxYELLOW              : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  /// <summary>Yellow green color constant (154, 205, 50)</summary>
  pxYELLOWGREEN         : TpxColor = (r:$9A/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  /// <summary>Transparent/blank color constant (0, 0, 0, 0)</summary>
  pxBLANK               : TpxColor = (r:$00;     g:$00;     b:$00;     a:$00);
  /// <summary>Alternative white color constant (245, 245, 245)</summary>
  pxWHITE2              : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  /// <summary>Alternative red color constant (126, 50, 63)</summary>
  pxRED2                : TpxColor = (r:$7E/$FF; g:$32/$FF; b:$3F/$FF; a:255/$FF);
  /// <summary>Color key for transparency (255, 0, 255)</summary>
  pxCOLORKEY            : TpxColor = (r:$FF/$FF; g:$00;     b:$FF/$FF; a:$FF/$FF);
  /// <summary>Dark overlay color constant (0, 32, 41) with transparency</summary>
  pxOVERLAY1            : TpxColor = (r:$00/$FF; g:$20/$FF; b:$29/$FF; a:$B4/$FF);
  /// <summary>Dark green overlay color constant (1, 27, 1)</summary>
  pxOVERLAY2            : TpxColor = (r:$01/$FF; g:$1B/$FF; b:$01/$FF; a:255/$FF);
  /// <summary>Dim white color constant (16, 16, 16) with low alpha</summary>
  pxDIMWHITE            : TpxColor = (r:$10/$FF; g:$10/$FF; b:$10/$FF; a:$10/$FF);
  /// <summary>Dark slate brown color constant (30, 31, 30) with minimal alpha</summary>
  pxDARKSLATEBROWN      : TpxColor = (r:30/255; g:31/255; b:30/255; a:1/255);
{$ENDREGION}

/// <summary>Blend operation constant: Zero blend factor</summary>
const
  pxBLEND_ZERO = 0;
  /// <summary>Blend operation constant: One blend factor</summary>
  pxBLEND_ONE = 1;
  /// <summary>Blend operation constant: Alpha blend factor</summary>
  pxBLEND_ALPHA = 2;
  /// <summary>Blend operation constant: Inverse alpha blend factor</summary>
  pxBLEND_INVERSE_ALPHA = 3;
  /// <summary>Blend operation constant: Source color blend factor</summary>
  pxBLEND_SRC_COLOR = 4;
  /// <summary>Blend operation constant: Destination color blend factor</summary>
  pxBLEND_DEST_COLOR = 5;
  /// <summary>Blend operation constant: Inverse source color blend factor</summary>
  pxBLEND_INVERSE_SRC_COLOR = 6;
  /// <summary>Blend operation constant: Inverse destination color blend factor</summary>
  pxBLEND_INVERSE_DEST_COLOR = 7;
  /// <summary>Blend operation constant: Constant color blend factor</summary>
  pxBLEND_CONST_COLOR = 8;
  /// <summary>Blend operation constant: Inverse constant color blend factor</summary>
  pxBLEND_INVERSE_CONST_COLOR = 9;
  /// <summary>Blend operation constant: Addition blend operation</summary>
  pxBLEND_ADD = 0;
  /// <summary>Blend operation constant: Source minus destination blend operation</summary>
  pxBLEND_SRC_MINUS_DEST = 1;
  /// <summary>Blend operation constant: Destination minus source blend operation</summary>
  pxBLEND_DEST_MINUS_SRC = 2;

  /// <summary>Default window width (960 pixels)</summary>
  CpxDefaultWindowWidth  = 1920 div 2;
  /// <summary>Default window height (540 pixels)</summary>
  CpxDefaultWindowHeight = 1080 div 2;

type
  /// <summary>
  /// Defines predefined blend modes for rendering operations
  /// </summary>
  /// <remarks>
  /// Blend modes control how newly rendered pixels combine with existing pixels in the framebuffer.
  /// Different modes produce different visual effects for transparency and overlapping graphics.
  /// </remarks>
  { TpxBlendMode }
  TpxBlendMode = (
    /// <summary>Premultiplied alpha blending - fastest for sprites with premultiplied alpha</summary>
    pxPreMultipliedAlphaBlendMode,
    /// <summary>Non-premultiplied alpha blending - standard alpha transparency</summary>
    pxNonPreMultipliedAlphaBlendMode,
    /// <summary>Additive blending - colors are added together for bright effects</summary>
    pxAdditiveAlphaBlendMode,
    /// <summary>Copy source to destination - no blending, source replaces destination</summary>
    pxCopySrcToDestBlendMode,
    /// <summary>Multiply source and destination - creates darkening effect</summary>
    MultiplySrcAndDestBlendMode
  );

  /// <summary>
  /// Defines color-based blend modes for special rendering effects
  /// </summary>
  { TpxBlendModeColor }
  TpxBlendModeColor = (
    /// <summary>Normal color blending mode</summary>
    pxColorNormalBlendModeColor,
    /// <summary>Average of source and destination colors</summary>
    ColorAvgSrcDestBlendModeColor
  );

  /// <summary>
  /// Main window management class providing display, rendering, and drawing functionality
  /// </summary>
  /// <remarks>
  /// TpxWindow manages the game window, handles DPI scaling, provides primitive drawing routines,
  /// and controls the rendering pipeline. It uses a virtual coordinate system that automatically
  /// scales to maintain consistent appearance across different screen resolutions and DPI settings.
  /// The window operates at a locked 60 FPS by default with v-sync enabled.
  /// </remarks>
  { TpxWindow }
  TpxWindow = class(TpxStaticObject)
  private class var
    FDisplay: PALLEGRO_DISPLAY;
    FTransform: ALLEGRO_TRANSFORM;
    FTitle: string;
    FLogicalSize: TpxSize;
    FPhysicalSize: TpxSize;
    FVSync: Boolean;
    FResizable: Boolean;
    FDpi: Cardinal;
    FDpiScale: Single;
    FTargetFPS: Cardinal;
    FActualFPS: Cardinal;
    FFrameTime: Single;
    FIsFullscreen: Boolean;
    FCurrentTime: Double;
    FLastTime: Double;
    FDeltaTime: Double;
    FFrameCount: Integer;
    FSecondCounter: Double;
    FNeedRender: Boolean;
    FNextFrameTime: Double;
    FOffset: TpxVector;
    //FOldWndProc: Pointer;
    FDPIEventSource: ALLEGRO_EVENT_SOURCE;
    FHWNDHandle: HWND;
    FReady: Boolean;
    class function GetCurrentDeviceDPI(): UINT; static;
  private
    class constructor Create();
    class destructor Destroy();
  public
    /// <summary>
    /// Initializes the game window with specified parameters
    /// </summary>
    /// <param name="ATitle">Window title text displayed in the title bar</param>
    /// <param name="AWidth">Logical width in pixels (default: 960)</param>
    /// <param name="AHeight">Logical height in pixels (default: 540)</param>
    /// <param name="AVsync">Enable vertical synchronization (default: True)</param>
    /// <param name="AResizable">Allow window resizing (default: True)</param>
    /// <returns>True if initialization succeeded, False otherwise</returns>
    /// <remarks>
    /// The logical dimensions define the virtual coordinate system used for drawing.
    /// The window automatically scales and letterboxes to maintain aspect ratio on different displays.
    /// V-sync locks the frame rate to the display refresh rate (typically 60 Hz).
    /// </remarks>
    /// <example>
    /// <code>
    /// if not TpxWindow.Init('My Game', 1280, 720, True, True) then
    ///   Exit;
    /// </code>
    /// </example>
    class function  Init(const ATitle: string; const AWidth: Cardinal=CpxDefaultWindowWidth; const AHeight: Cardinal=CpxDefaultWindowHeight; const AVsync: Boolean=True; AResizable: Boolean=True): Boolean; static;
    /// <summary>
    /// Checks if the window has been successfully initialized
    /// </summary>
    /// <returns>True if the window is initialized and ready for use</returns>
    class function  IsInit(): Boolean; static;
    /// <summary>
    /// Gets the underlying Allegro display handle
    /// </summary>
    /// <returns>Pointer to the Allegro display structure, or nil if not initialized</returns>
    /// <remarks>
    /// Advanced users only. Used for low-level Allegro operations not covered by PIXELS.
    /// </remarks>
    class function  Handle(): PALLEGRO_DISPLAY; static;
    /// <summary>
    /// Checks if the window is ready for rendering operations
    /// </summary>
    /// <returns>True if the window is ready and has focus</returns>
    /// <remarks>
    /// The window may not be ready during startup, minimization, or when losing focus.
    /// Rendering should be skipped when the window is not ready.
    /// </remarks>
    class function  IsReady(): Boolean; static;
    /// <summary>
    /// Sets the window ready state manually
    /// </summary>
    /// <param name="AReady">The new ready state</param>
    /// <remarks>
    /// Typically managed automatically by the window system. Manual control may be needed
    /// for special cases like custom focus handling.
    /// </remarks>
    class procedure SetReady(const AReady: Boolean); static;
    /// <summary>
    /// Gets the current system DPI setting
    /// </summary>
    /// <returns>DPI value (typically 96 for standard displays, 144+ for high-DPI)</returns>
    /// <remarks>
    /// Used internally for DPI scaling calculations. Higher DPI values indicate
    /// high-resolution displays that require scaling adjustments.
    /// </remarks>
    class function  Dpi(): Cardinal; static;
    /// <summary>
    /// Gets the current DPI scaling factor
    /// </summary>
    /// <returns>Scale factor (1.0 for standard DPI, >1.0 for high-DPI displays)</returns>
    /// <remarks>
    /// Calculated as current DPI divided by 96 (standard DPI). Used internally
    /// for automatic window and content scaling.
    /// </remarks>
    class function  DpiScale(): Single; static;
    /// <summary>
    /// Updates DPI scaling and window transformations
    /// </summary>
    /// <remarks>
    /// Called automatically during the game loop to handle DPI changes and window resizing.
    /// Maintains proper aspect ratio and applies letterboxing when necessary.
    /// </remarks>
    class procedure UpdateDpiScaling(); static;
    /// <summary>
    /// Closes and destroys the window
    /// </summary>
    /// <remarks>
    /// Releases all window resources and event handlers. The window cannot be used
    /// after calling Close() without calling Init() again.
    /// </remarks>
    class procedure Close(); static;

    /// <summary>
    /// Brings the window to the foreground and gives it input focus
    /// </summary>
    /// <remarks>
    /// Useful for ensuring the game window is visible and active, especially when
    /// starting from a launcher or after minimization.
    /// </remarks>
    class procedure Focus(); static;
    /// <summary>
    /// Checks if the window currently has input focus
    /// </summary>
    /// <returns>True if the window is the active foreground window</returns>
    /// <remarks>
    /// Games may want to pause or reduce activity when not in focus to save resources
    /// and respect user attention.
    /// </remarks>
    class function  HasFocus(): Boolean; static;

    /// <summary>
    /// Gets the current window title
    /// </summary>
    /// <returns>The title text displayed in the window's title bar</returns>
    class function  GeTTitle(): string; static;
    /// <summary>
    /// Sets the window title text
    /// </summary>
    /// <param name="ATitle">New title text to display</param>
    /// <remarks>
    /// Can be changed at any time to reflect game state, level names, or other information.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.SetTitle('My Game - Level 3');
    /// </code>
    /// </example>
    class procedure SetTitle(const ATitle: string); static;

    /// <summary>
    /// Gets the logical (virtual) screen dimensions
    /// </summary>
    /// <returns>Size structure with width and height in logical pixels</returns>
    /// <remarks>
    /// The logical size defines the coordinate system used for all drawing operations.
    /// This remains constant regardless of the actual window size or DPI scaling.
    /// </remarks>
    class function  GetLogicalSize(): TpxSize; static;
    /// <summary>
    /// Gets the physical window dimensions in screen pixels
    /// </summary>
    /// <returns>Size structure with actual window width and height</returns>
    /// <remarks>
    /// The physical size reflects the actual window size on screen, including DPI scaling.
    /// This may differ from logical size on high-DPI displays.
    /// </remarks>
    class function  GetPhysicalSize(): TpxSize; static;

    /// <summary>
    /// Checks if vertical synchronization is enabled
    /// </summary>
    /// <returns>True if v-sync is active</returns>
    /// <remarks>
    /// V-sync synchronizes the frame rate with the display refresh rate to prevent
    /// screen tearing but may introduce input lag.
    /// </remarks>
    class function  IsVsyncEnabled(): Boolean; static;
    /// <summary>
    /// Checks if the window can be resized by the user
    /// </summary>
    /// <returns>True if the window has resizable borders</returns>
    class function  IsResiable(): Boolean; static;

    /// <summary>
    /// Gets the target frame rate in frames per second
    /// </summary>
    /// <returns>Target FPS value (default: 60)</returns>
    /// <remarks>
    /// The actual frame rate may be limited by v-sync or hardware capabilities.
    /// Used by the timing system to maintain consistent game speed.
    /// </remarks>
    class function  GetTargetFPS(): Cardinal; static;
    /// <summary>
    /// Sets the target frame rate for the game loop
    /// </summary>
    /// <param name="AFrameRate">Desired frames per second</param>
    /// <remarks>
    /// Changes the game loop timing to target the specified frame rate.
    /// Higher values provide smoother motion but require more processing power.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.SetTargetFPS(30); // Half speed for better performance
    /// </code>
    /// </example>
    class procedure SetTargetFPS(const AFrameRate: Cardinal); static;
    /// <summary>
    /// Gets the time in seconds for one frame at the target frame rate
    /// </summary>
    /// <returns>Frame time in seconds (e.g., 0.0167 for 60 FPS)</returns>
    /// <remarks>
    /// Useful for frame-rate independent calculations and animations.
    /// </remarks>
    class function  GetFrameTime(): Single; static;
    /// <summary>
    /// Gets the actual measured frame rate
    /// </summary>
    /// <returns>Current FPS based on recent frame timing</returns>
    /// <remarks>
    /// Updated once per second based on actual frame render times.
    /// May differ from target FPS due to performance limitations or v-sync.
    /// </remarks>
    class function  GetFPS(): Cardinal; static;
    /// <summary>
    /// Resets the frame timing system
    /// </summary>
    /// <remarks>
    /// Called automatically when needed, such as after losing focus or changing settings.
    /// Prevents frame rate calculations from being skewed by pauses.
    /// </remarks>
    class procedure ResetTiming(); static;
    /// <summary>
    /// Updates frame timing calculations
    /// </summary>
    /// <remarks>
    /// Called automatically once per frame to maintain accurate timing and FPS measurements.
    /// </remarks>
    class procedure UpdateTiming(); static;

    /// <summary>
    /// Clears the entire window to a solid color
    /// </summary>
    /// <param name="AColor">Color to fill the window with</param>
    /// <remarks>
    /// Typically called at the beginning of each frame to clear the previous frame's contents.
    /// Essential for preventing visual artifacts from overlapping frames.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.Clear(pxBLACK); // Clear to black
    /// </code>
    /// </example>
    class procedure Clear(const AColor: TpxColor); static;


    /// <summary>
    /// Checks if the window is currently in fullscreen mode
    /// </summary>
    /// <returns>True if the window occupies the entire screen</returns>
    class function  IsFullscreen(): Boolean; static;
    /// <summary>
    /// Sets the window fullscreen state
    /// </summary>
    /// <param name="AFullscreen">True for fullscreen, False for windowed mode</param>
    /// <remarks>
    /// Fullscreen mode can improve performance and immersion but may affect alt-tab behavior
    /// and multi-monitor setups.
    /// </remarks>
    class procedure SetWindowFullscreen(const AFullscreen: Boolean); static;
    /// <summary>
    /// Toggles between fullscreen and windowed modes
    /// </summary>
    /// <remarks>
    /// Convenient for implementing fullscreen toggle functionality, often bound to F11 or Alt+Enter.
    /// </remarks>
    /// <example>
    /// <code>
    /// if TpxInput.KeyPressed(pxKEY_F11) then
    ///   TpxWindow.ToggleFullscreen();
    /// </code>
    /// </example>
    class procedure ToggleFullscreen(); static;

    /// <summary>
    /// Presents the completed frame to the screen
    /// </summary>
    /// <remarks>
    /// Must be called after all drawing operations to make them visible.
    /// Handles buffer swapping, frame rate limiting, and v-sync timing.
    /// Called automatically by the game loop framework.
    /// </remarks>
    class procedure ShowFrame(); static;

    /// <summary>
    /// Sets low-level blending parameters for advanced rendering effects
    /// </summary>
    /// <param name="AOperation">Blend operation (add, subtract, etc.)</param>
    /// <param name="ASource">Source blend factor</param>
    /// <param name="ADestination">Destination blend factor</param>
    /// <remarks>
    /// Advanced feature for custom blend modes. Most users should use SetBlendMode() instead.
    /// Requires knowledge of OpenGL/DirectX blending operations.
    /// </remarks>
    /// <seealso cref="SetBlendMode"/>
    class procedure SetBlender(const AOperation, ASource, ADestination: Integer); static;
    /// <summary>
    /// Gets the current low-level blending parameters
    /// </summary>
    /// <param name="AOperation">Returns the current blend operation</param>
    /// <param name="ASource">Returns the current source blend factor</param>
    /// <param name="ADestination">Returns the current destination blend factor</param>
    class procedure GetBlender(AOperation: PInteger; ASource: PInteger; ADestination: PInteger); static;
    /// <summary>
    /// Sets the constant color used in certain blend modes
    /// </summary>
    /// <param name="AColor">Color to use as the blend constant</param>
    /// <remarks>
    /// Only affects blend modes that use constant color factors.
    /// </remarks>
    class procedure SetBlendColor(const AColor: TpxColor); static;
    /// <summary>
    /// Gets the current blend constant color
    /// </summary>
    /// <returns>The color currently set as the blend constant</returns>
    class function  GetBlendColor(): TpxColor; static;
    /// <summary>
    /// Sets the blend mode for subsequent drawing operations
    /// </summary>
    /// <param name="AMode">The blend mode to apply</param>
    /// <remarks>
    /// Affects how new pixels combine with existing pixels. Different modes create
    /// different visual effects for transparency, glow, and special effects.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.SetBlendMode(pxAdditiveAlphaBlendMode); // For glow effects
    /// // Draw glowing objects here
    /// TpxWindow.RestoreDefaultBlendMode();
    /// </code>
    /// </example>
    class procedure SetBlendMode(const AMode: TpxBlendMode); static;
    /// <summary>
    /// Sets a color-based blend mode with a specific color
    /// </summary>
    /// <param name="AMode">The color blend mode type</param>
    /// <param name="AColor">Color to use with the blend mode</param>
    class procedure SetBlendModeColor(const AMode: TpxBlendModeColor; const AColor: TpxColor); static;
    /// <summary>
    /// Restores the default alpha blending mode
    /// </summary>
    /// <remarks>
    /// Should be called after using special blend modes to return to normal transparency rendering.
    /// </remarks>
    class procedure RestoreDefaultBlendMode(); static;

    /// <summary>
    /// Saves the current window contents to an image file
    /// </summary>
    /// <param name="AFilename">Path and filename for the screenshot</param>
    /// <returns>True if the screenshot was saved successfully</returns>
    /// <remarks>
    /// Captures the current framebuffer contents. File format is determined by the extension
    /// (.png, .jpg, .bmp, etc.). Useful for screenshots or debug captures.
    /// </remarks>
    /// <example>
    /// <code>
    /// if TpxInput.KeyPressed(pxKEY_F12) then
    ///   TpxWindow.Save('screenshot.png');
    /// </code>
    /// </example>
    class function  Save(const AFilename: string): Boolean; static;

    /// <summary>
    /// Draws a single pixel at the specified coordinates
    /// </summary>
    /// <param name="AX">X coordinate in logical pixels</param>
    /// <param name="AY">Y coordinate in logical pixels</param>
    /// <param name="AColor">Color of the pixel</param>
    /// <remarks>
    /// Useful for pixel-perfect graphics, debug visualization, or particle effects.
    /// Not optimized for drawing large numbers of pixels.
    /// </remarks>
    class procedure DrawPixel(const AX, AY: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws a line between two points
    /// </summary>
    /// <param name="X1">Starting X coordinate</param>
    /// <param name="Y1">Starting Y coordinate</param>
    /// <param name="X2">Ending X coordinate</param>
    /// <param name="Y2">Ending Y coordinate</param>
    /// <param name="AColor">Line color</param>
    /// <param name="AThickness">Line thickness in pixels</param>
    /// <remarks>
    /// Useful for debugging, UI elements, wireframes, and simple graphics.
    /// Thickness affects performance, so use sparingly for very thick lines.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.DrawLine(0, 0, 100, 100, pxRED, 2.0); // Red diagonal line
    /// </code>
    /// </example>
    class procedure DrawLine(const X1, Y1, X2, Y2: Single; const AColor: TpxColor; const AThickness: Single); static;

    /// <summary>
    /// Draws the outline of a triangle
    /// </summary>
    /// <param name="X1">First vertex X coordinate</param>
    /// <param name="Y1">First vertex Y coordinate</param>
    /// <param name="X2">Second vertex X coordinate</param>
    /// <param name="Y2">Second vertex Y coordinate</param>
    /// <param name="X3">Third vertex X coordinate</param>
    /// <param name="Y3">Third vertex Y coordinate</param>
    /// <param name="AColor">Triangle outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    class procedure DrawTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled triangle
    /// </summary>
    /// <param name="X1">First vertex X coordinate</param>
    /// <param name="Y1">First vertex Y coordinate</param>
    /// <param name="X2">Second vertex X coordinate</param>
    /// <param name="Y2">Second vertex Y coordinate</param>
    /// <param name="X3">Third vertex X coordinate</param>
    /// <param name="Y3">Third vertex Y coordinate</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Useful for simple polygon graphics, arrows, or geometric shapes.
    /// </remarks>
    class procedure DrawFillTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws the outline of a rectangle
    /// </summary>
    /// <param name="AX">Left edge X coordinate</param>
    /// <param name="AY">Top edge Y coordinate</param>
    /// <param name="AWidth">Rectangle width</param>
    /// <param name="AHeight">Rectangle height</param>
    /// <param name="AColor">Outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    class procedure DrawRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled rectangle
    /// </summary>
    /// <param name="AX">Left edge X coordinate</param>
    /// <param name="AY">Top edge Y coordinate</param>
    /// <param name="AWidth">Rectangle width</param>
    /// <param name="AHeight">Rectangle height</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Very common for UI elements, backgrounds, bars, and simple graphics.
    /// Coordinates specify the top-left corner in the standard coordinate system.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.DrawFillRectangle(10, 10, 100, 50, pxBLUE); // Blue rectangle
    /// </code>
    /// </example>
    class procedure DrawFillRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor); static;
    /// <summary>
    /// Draws the outline of a rounded rectangle
    /// </summary>
    /// <param name="AX">Left edge X coordinate</param>
    /// <param name="AY">Top edge Y coordinate</param>
    /// <param name="AWidth">Rectangle width</param>
    /// <param name="AHeight">Rectangle height</param>
    /// <param name="RX">Horizontal corner radius</param>
    /// <param name="RY">Vertical corner radius</param>
    /// <param name="AColor">Outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    class procedure DrawRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled rounded rectangle
    /// </summary>
    /// <param name="AX">Left edge X coordinate</param>
    /// <param name="AY">Top edge Y coordinate</param>
    /// <param name="AWidth">Rectangle width</param>
    /// <param name="AHeight">Rectangle height</param>
    /// <param name="RX">Horizontal corner radius</param>
    /// <param name="RY">Vertical corner radius</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Perfect for modern UI elements like buttons, panels, and cards with rounded corners.
    /// </remarks>
    class procedure DrawFillRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws the outline of a circle
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="AColor">Outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    class procedure DrawCircle(const CX, CY, ARadius: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled circle
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Excellent for simple sprites, particles, collision visualization, and UI elements.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxWindow.DrawFillCircle(100, 100, 25, pxYELLOW); // Yellow circle
    /// </code>
    /// </example>
    class procedure DrawFillCircle(const CX, CY, ARadius: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws the outline of an ellipse
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="RX">Horizontal radius</param>
    /// <param name="RY">Vertical radius</param>
    /// <param name="AColor">Outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    class procedure DrawEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled ellipse
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="RX">Horizontal radius</param>
    /// <param name="RY">Vertical radius</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Useful for stretched circles, oval shapes, and non-uniform collision areas.
    /// </remarks>
    class procedure DrawFillEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws the outline of a pie slice (partial circle)
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="AStartTheta">Starting angle in radians</param>
    /// <param name="ADeltaTheta">Angular span in radians</param>
    /// <param name="AColor">Outline color</param>
    /// <param name="AThickness">Line thickness for the outline</param>
    /// <remarks>
    /// Angles are in radians, not degrees. Use degree conversion if needed.
    /// </remarks>
    class procedure DrawPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws a filled pie slice (partial circle)
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="AStartTheta">Starting angle in radians</param>
    /// <param name="ADeltaTheta">Angular span in radians</param>
    /// <param name="AColor">Fill color</param>
    /// <remarks>
    /// Perfect for pie charts, gauges, radar displays, and game UI elements.
    /// Angles are in radians, not degrees.
    /// </remarks>
    class procedure DrawFillPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor); static;

    /// <summary>
    /// Draws an arc (portion of a circle outline)
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="AStartTheta">Starting angle in radians</param>
    /// <param name="ADeltaTheta">Angular span in radians</param>
    /// <param name="AColor">Arc color</param>
    /// <param name="AThickness">Line thickness</param>
    /// <remarks>
    /// Unlike pie slices, arcs don't draw lines to the center. Useful for partial rings and curves.
    /// </remarks>
    class procedure DrawArc(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
    /// <summary>
    /// Draws an elliptical arc (portion of an ellipse outline)
    /// </summary>
    /// <param name="CX">Center X coordinate</param>
    /// <param name="CY">Center Y coordinate</param>
    /// <param name="RX">Horizontal radius</param>
    /// <param name="RY">Vertical radius</param>
    /// <param name="AStartTheta">Starting angle in radians</param>
    /// <param name="ADeltaTheta">Angular span in radians</param>
    /// <param name="AColor">Arc color</param>
    /// <param name="AThickness">Line thickness</param>
    class procedure DrawEllipticalArc(const CX, CY, RX, RY, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
  end;

type
  /// <summary>
  /// Text alignment options for font rendering
  /// </summary>
  { TpxAlign }
  TpxAlign = (
    /// <summary>Align text to the left edge</summary>
    pxAlignLeft   =ALLEGRO_ALIGN_LEFT,
    /// <summary>Center text horizontally</summary>
    pxAlignCenter =ALLEGRO_ALIGN_CENTER,
    /// <summary>Align text to the right edge</summary>
    pxAlignRight  =ALLEGRO_ALIGN_RIGHT,
    /// <summary>Use integer positioning for crisp pixel alignment</summary>
    pxAlignInteger=ALLEGRO_ALIGN_INTEGER
  );

  /// <summary>
  /// Font class for loading and rendering text in various sizes and styles
  /// </summary>
  /// <remarks>
  /// TpxFont manages TrueType font loading and text rendering with support for different sizes,
  /// colors, and alignment options. Fonts are rendered with automatic DPI scaling and can be
  /// loaded from files or ZIP archives. The class supports Unicode text rendering.
  /// </remarks>
  { TpxFont }
  TpxFont = class(TpxObject)
  protected
    FHandle: PALLEGRO_FONT;
  public
    constructor Create(); override;
    destructor Destroy(); override;

    /// <summary>
    /// Loads the default built-in font at the specified size
    /// </summary>
    /// <param name="ASize">Font size in pixels</param>
    /// <returns>True if the font was loaded successfully</returns>
    /// <remarks>
    /// The default font is embedded in the PIXELS library and always available.
    /// Size is automatically scaled for high-DPI displays.
    /// </remarks>
    /// <example>
    /// <code>
    /// LFont := TpxFont.Create();
    /// if LFont.LoadDefault(16) then
    ///   // Font ready for use
    /// </code>
    /// </example>
    function  LoadDefault(const ASize: Cardinal): Boolean;
    /// <summary>
    /// Loads a TrueType font from a file handle
    /// </summary>
    /// <param name="AFile">File handle (will be consumed and set to nil)</param>
    /// <param name="ASize">Font size in pixels</param>
    /// <returns>True if the font was loaded successfully</returns>
    /// <remarks>
    /// Supports TTF and OTF font formats. The file handle is consumed by this operation.
    /// Size is automatically scaled for high-DPI displays.
    /// </remarks>
    function  Load(var AFile: PpxFile; const ASize: Cardinal): Boolean;
    /// <summary>
    /// Checks if a font has been successfully loaded
    /// </summary>
    /// <returns>True if the font is ready for text rendering</returns>
    function  Loaded(): Boolean;
    /// <summary>
    /// Unloads the current font and frees its resources
    /// </summary>
    /// <remarks>
    /// Called automatically by the destructor. Manual calling allows reusing the font object.
    /// </remarks>
    procedure Unload();

    /// <summary>
    /// Draws formatted text at the specified position with alignment
    /// </summary>
    /// <param name="AColor">Text color</param>
    /// <param name="AX">X coordinate for text positioning</param>
    /// <param name="AY">Y coordinate for text positioning</param>
    /// <param name="AAlign">Text alignment relative to the position</param>
    /// <param name="AText">Text string with optional format specifiers</param>
    /// <param name="AArgs">Arguments for format specifiers (use [] if none)</param>
    /// <remarks>
    /// Position interpretation depends on alignment: left-aligned text starts at (X,Y),
    /// center-aligned text centers on (X,Y), right-aligned text ends at (X,Y).
    /// Supports standard Pascal format strings with % specifiers.
    /// </remarks>
    /// <example>
    /// <code>
    /// LFont.DrawText(pxWHITE, 100, 50, pxAlignCenter, 'Score: %d', [LScore]);
    /// LFont.DrawText(pxRED, 10, 10, pxAlignLeft, 'Hello World', []);
    /// </code>
    /// </example>
    procedure DrawText(const AColor: TpxColor; const AX, AY: Single; AAlign: TpxAlign; const AText: string; const AArgs: array of const); overload;
    /// <summary>
    /// Draws text and automatically advances the Y position for multi-line text
    /// </summary>
    /// <param name="AColor">Text color</param>
    /// <param name="AX">X coordinate (constant for all lines)</param>
    /// <param name="AY">Y coordinate (modified to point to next line position)</param>
    /// <param name="ALineSpace">Additional spacing between lines</param>
    /// <param name="AAlign">Text alignment</param>
    /// <param name="AText">Text string to draw</param>
    /// <param name="AArgs">Format arguments</param>
    /// <remarks>
    /// Convenient for drawing multiple lines of text. AY is modified to point to where
    /// the next line should be drawn, making it easy to draw sequential text lines.
    /// </remarks>
    procedure DrawText(const AColor: TpxColor; const AX: Single; var AY: Single; const ALineSpace: Single; const AAlign: TpxAlign; const AText: string; const AArgs: array of const); overload;
    /// <summary>
    /// Draws rotated text centered on the specified point
    /// </summary>
    /// <param name="AColor">Text color</param>
    /// <param name="AX">Center X coordinate for rotation</param>
    /// <param name="AY">Center Y coordinate for rotation</param>
    /// <param name="AAngle">Rotation angle in degrees</param>
    /// <param name="AText">Text string to draw</param>
    /// <param name="AArgs">Format arguments</param>
    /// <remarks>
    /// Text rotates around its center point. Useful for special effects, labels, and UI elements.
    /// Angle is in degrees with 0 being horizontal text.
    /// </remarks>
    procedure DrawText(const AColor: TpxColor; const AX, AY, AAngle: Single; const AText: string; const AArgs: array of const); overload;

    /// <summary>
    /// Calculates the width of text when rendered with this font
    /// </summary>
    /// <param name="AText">Text string to measure</param>
    /// <param name="AArgs">Format arguments</param>
    /// <returns>Text width in pixels</returns>
    /// <remarks>
    /// Useful for centering text, creating text boxes, and UI layout calculations.
    /// Takes into account the actual font metrics and character spacing.
    /// </remarks>
    /// <example>
    /// <code>
    /// LWidth := LFont.GetTextWidth('Player Score: %d', [LScore]);
    /// LCenterX := (ScreenWidth - LWidth) / 2;
    /// </code>
    /// </example>
    function  GetTextWidth(const AText: string; const AArgs: array of const): Single;
    /// <summary>
    /// Gets the height of a single line of text for this font
    /// </summary>
    /// <returns>Line height in pixels</returns>
    /// <remarks>
    /// Consistent for all text rendered with this font, regardless of content.
    /// Used for multi-line text spacing and UI layout calculations.
    /// </remarks>
    function  GetLineHeight(): Single;
  end;

type
  /// <summary>
  /// Texture filtering and scaling modes
  /// </summary>
  { TpxTextureKind }
  TpxTextureKind = (
    /// <summary>Pixel art mode - nearest neighbor filtering for crisp pixel graphics</summary>
    pxPixelArtTexture,
    /// <summary>HD mode - linear filtering for smooth scaling of photographic content</summary>
    pxHDTexture
  );

  /// <summary>
  /// Low-level texture data structure for direct pixel access
  /// </summary>
  PpxTextureData = ^TpxTextureData;
  TpxTextureData = record
    /// <summary>Pointer to raw pixel data</summary>
    Memory: Pointer;
    /// <summary>Pixel format identifier</summary>
    Format: Integer;
    /// <summary>Bytes per row of pixels</summary>
    Pitch: Integer;
    /// <summary>Bytes per individual pixel</summary>
    PixelSize: Integer;
  end;

  /// <summary>
  /// 2D texture class for loading, manipulating, and rendering images
  /// </summary>
  /// <remarks>
  /// TpxTexture represents a 2D image that can be loaded from files or created procedurally.
  /// Textures support various formats (PNG, JPG, BMP), color key transparency, pixel-level
  /// access, render-to-texture functionality, and efficient drawing with transformations.
  /// The class handles both pixel art (nearest neighbor) and HD (linear filtered) rendering modes.
  /// </remarks>
  { TpxTexture }
  TpxTexture = class(TpxObject)
  protected
    FHandle: PALLEGRO_BITMAP;
    FSize: TpxSize;
    FLocked: Boolean;
    FLockedRegion: TpxRect;
    FLockedData: PALLEGRO_LOCKED_REGION;
    FKind: TpxTextureKind;
    FOldTarget: PALLEGRO_BITMAP;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    /// <summary>
    /// Creates a blank texture with the specified dimensions and fill color
    /// </summary>
    /// <param name="AWidth">Texture width in pixels</param>
    /// <param name="AHeight">Texture height in pixels</param>
    /// <param name="AColor">Color to fill the texture with</param>
    /// <param name="AKind">Filtering mode (pixel art or HD)</param>
    /// <returns>True if allocation succeeded</returns>
    /// <remarks>
    /// Creates a texture that can be used as a drawing canvas or for procedural generation.
    /// The entire texture is initially filled with the specified color.
    /// </remarks>
    /// <example>
    /// <code>
    /// LTexture := TpxTexture.Create();
    /// if LTexture.Alloc(256, 256, pxBLACK, pxPixelArtTexture) then
    ///   // 256x256 black pixel art texture ready
    /// </code>
    /// </example>
    function  Alloc(const AWidth, AHeight: Cardinal; const AColor: TpxColor; const AKind: TpxTextureKind): Boolean;
    /// <summary>
    /// Loads a texture from a file handle
    /// </summary>
    /// <param name="AFile">File handle (will be consumed)</param>
    /// <param name="AExtension">File extension to determine format (e.g., '.png', '.jpg')</param>
    /// <param name="AKind">Filtering mode for the texture</param>
    /// <param name="AColorKey">Optional color to treat as transparent (nil for no color key)</param>
    /// <returns>True if loading succeeded</returns>
    /// <remarks>
    /// Supports common image formats: PNG, JPG, BMP, TGA, etc. Color key creates transparency
    /// by making all pixels of the specified color fully transparent.
    /// </remarks>
    function  Load(const AFile: PpxFile; const AExtension: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil): Boolean;
    /// <summary>
    /// Checks if the texture has been successfully loaded or allocated
    /// </summary>
    /// <returns>True if the texture is ready for use</returns>
    function  IsLoaded(): Boolean;
    /// <summary>
    /// Releases texture resources and memory
    /// </summary>
    /// <remarks>
    /// Called automatically by the destructor. Manual calling allows reusing the texture object.
    /// </remarks>
    procedure Unload();
    /// <summary>
    /// Gets the underlying graphics handle for advanced operations
    /// </summary>
    /// <returns>Low-level bitmap handle or nil if not loaded</returns>
    /// <remarks>
    /// Advanced users only. Provides access to the underlying Allegro bitmap for operations
    /// not directly supported by PIXELS.
    /// </remarks>
    function  Handle(): PALLEGRO_BITMAP;
    /// <summary>
    /// Gets the filtering mode of this texture
    /// </summary>
    /// <returns>The texture kind (pixel art or HD)</returns>
    function  Kind(): TpxTextureKind;
    /// <summary>
    /// Gets the dimensions of the texture
    /// </summary>
    /// <returns>Size structure containing width and height</returns>
    function  GetSize(): TpxSize;
    /// <summary>
    /// Draws the texture with full transformation support
    /// </summary>
    /// <param name="AX">X position for drawing</param>
    /// <param name="AY">Y position for drawing</param>
    /// <param name="AColor">Color tint (use pxWHITE for no tinting)</param>
    /// <param name="ARegion">Source region to draw (nil for entire texture)</param>
    /// <param name="AOrigin">Origin point for rotation/scaling (nil for top-left)</param>
    /// <param name="AScale">Scale factors (nil for no scaling)</param>
    /// <param name="AAngle">Rotation angle in degrees</param>
    /// <param name="AHFlip">Flip horizontally</param>
    /// <param name="AVFlip">Flip vertically</param>
    /// <remarks>
    /// This is the most versatile drawing method supporting all transformation options.
    /// Origin values are normalized (0.5, 0.5 = center). Color tinting multiplies
    /// the texture colors. Use pxWHITE for normal appearance.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Draw centered and rotated
    /// LOrigin.x := 0.5; LOrigin.y := 0.5;
    /// LTexture.Draw(100, 100, pxWHITE, nil, @LOrigin, nil, 45.0);
    /// </code>
    /// </example>
    procedure Draw(const AX, AY: Single; const AColor: TpxColor; const ARegion: PpxRect = nil; const AOrigin: PpxVector = nil; const AScale: PpxVector = nil; const AAngle: Single = 0; const AHFlip: Boolean = False; const AVFlip: Boolean = False);
    /// <summary>
    /// Draws the texture tiled across the screen with scrolling offset
    /// </summary>
    /// <param name="ADeltaX">Horizontal scrolling offset</param>
    /// <param name="ADeltaY">Vertical scrolling offset</param>
    /// <remarks>
    /// Perfect for scrolling backgrounds, repeating patterns, and parallax effects.
    /// The texture repeats seamlessly across the entire screen area.
    /// </remarks>
    /// <example>
    /// <code>
    /// LScrollX := LScrollX + 1.0; // Scroll horizontally
    /// LTexture.DrawTiled(LScrollX, 0);
    /// </code>
    /// </example>
    procedure DrawTiled(const ADeltaX, ADeltaY: Single);
    /// <summary>
    /// Draws the texture with simplified transformation parameters
    /// </summary>
    /// <param name="AX">X position</param>
    /// <param name="AY">Y position</param>
    /// <param name="AColor">Color tint</param>
    /// <param name="AScaleX">Horizontal scale factor</param>
    /// <param name="AScaleY">Vertical scale factor</param>
    /// <param name="AAngle">Rotation angle in degrees</param>
    /// <param name="AOriginX">Horizontal origin (0.0-1.0)</param>
    /// <param name="AOriginY">Vertical origin (0.0-1.0)</param>
    /// <remarks>
    /// Convenient alternative to the full Draw method when you need simple transformations.
    /// </remarks>
    procedure DrawEx(const AX, AY: Single; const AColor: TpxColor; const AScaleX: Single = 1.0; const AScaleY: Single = 1.0; const AAngle: Single = 0; const AOriginX: Single = 0; const AOriginY: Single = 0);
    /// <summary>
    /// Locks a region of the texture for direct pixel access
    /// </summary>
    /// <param name="ARegion">Region to lock (nil for entire texture)</param>
    /// <param name="AData">Returns pixel data information</param>
    /// <returns>True if locking succeeded</returns>
    /// <remarks>
    /// Enables direct pixel manipulation for procedural generation, image processing,
    /// or real-time effects. Must be matched with Unlock() when finished.
    /// Performance-sensitive operation - minimize lock time.
    /// </remarks>
    /// <example>
    /// <code>
    /// if LTexture.Lock() then
    /// try
    ///   // Modify pixels directly
    ///   LTexture.SetPixel(10, 10, pxRED);
    /// finally
    ///   LTexture.Unlock();
    /// end;
    /// </code>
    /// </example>
    function  Lock(const ARegion: PpxRect = nil; const AData: PpxTextureData = nil): Boolean;
    /// <summary>
    /// Checks if the texture is currently locked for pixel access
    /// </summary>
    /// <returns>True if the texture is locked</returns>
    function  IsLocked(): Boolean;
    /// <summary>
    /// Unlocks the texture and commits any pixel changes
    /// </summary>
    /// <returns>True if unlocking succeeded</returns>
    /// <remarks>
    /// Must be called after Lock() to commit changes and restore normal texture usage.
    /// </remarks>
    function  Unlock(): Boolean;
    /// <summary>
    /// Reads the color of a specific pixel
    /// </summary>
    /// <param name="AX">X coordinate of the pixel</param>
    /// <param name="AY">Y coordinate of the pixel</param>
    /// <returns>Color of the pixel at the specified location</returns>
    /// <remarks>
    /// Useful for collision detection, color sampling, and image analysis.
    /// Coordinates must be within texture bounds.
    /// </remarks>
    function  GetPixel(const AX, AY: Integer): TpxColor;
    /// <summary>
    /// Sets the color of a specific pixel
    /// </summary>
    /// <param name="AX">X coordinate of the pixel</param>
    /// <param name="AY">Y coordinate of the pixel</param>
    /// <param name="AColor">New color for the pixel</param>
    /// <remarks>
    /// Direct pixel modification for procedural generation, drawing, or effects.
    /// For bulk pixel operations, consider using Lock/Unlock for better performance.
    /// </remarks>
    procedure SetPixel(const AX, AY: Integer; const AColor: TpxColor);
    /// <summary>
    /// Checks if this texture is currently set as the render target
    /// </summary>
    /// <returns>True if drawing operations target this texture</returns>
    function  IsRenderTarget(): Boolean;
    /// <summary>
    /// Sets this texture as the render target for subsequent drawing operations
    /// </summary>
    /// <remarks>
    /// All drawing commands (primitives, other textures, text) will render to this texture
    /// instead of the screen. Enables render-to-texture effects, dynamic content generation,
    /// and post-processing. Must be matched with UnsetAsRenderTarget().
    /// </remarks>
    /// <example>
    /// <code>
    /// LTexture.SetAsRenderTarget();
    /// try
    ///   TpxWindow.Clear(pxBLACK);
    ///   // Draw whatever you want to the texture
    /// finally
    ///   LTexture.UnsetAsRenderTarget();
    /// end;
    /// </code>
    /// </example>
    procedure SetAsRenderTarget();
    /// <summary>
    /// Restores the previous render target (typically the screen)
    /// </summary>
    /// <remarks>
    /// Must be called after SetAsRenderTarget() to restore normal rendering.
    /// </remarks>
    procedure UnsetAsRenderTarget();
    /// <summary>
    /// Copies a region of this texture to another texture
    /// </summary>
    /// <param name="ADestTexture">Destination texture to copy to</param>
    /// <param name="ASourceRegion">Source region to copy (nil for entire texture)</param>
    /// <param name="ADestX">Destination X coordinate</param>
    /// <param name="ADestY">Destination Y coordinate</param>
    /// <returns>True if copying succeeded</returns>
    /// <remarks>
    /// Useful for texture atlasing, compositing, and creating derived textures.
    /// Both textures must be loaded/allocated before copying.
    /// </remarks>
    function  CopyTo(const ADestTexture: TpxTexture; const ASourceRegion: PpxRect = nil; const ADestX: Integer = 0; const ADestY: Integer = 0): Boolean;
    /// <summary>
    /// Creates an exact copy of this texture
    /// </summary>
    /// <returns>New texture object containing a copy of this texture's data</returns>
    /// <remarks>
    /// Creates a completely independent texture with identical pixel data.
    /// Useful for creating variations or backup copies of textures.
    /// Returns nil if cloning fails.
    /// </remarks>
    function  Clone(): TpxTexture;
    /// <summary>
    /// Fills the entire texture with a solid color
    /// </summary>
    /// <param name="AColor">Color to fill the texture with</param>
    /// <remarks>
    /// Overwrites all existing pixel data. Useful for resetting textures or
    /// creating solid color backgrounds.
    /// </remarks>
    procedure Clear(const AColor: TpxColor);
    /// <summary>
    /// Saves the texture to an image file
    /// </summary>
    /// <param name="AFilename">Path and filename for the saved image</param>
    /// <returns>True if saving succeeded</returns>
    /// <remarks>
    /// File format is determined by the extension. Supports PNG, JPG, BMP, and other formats.
    /// Useful for exporting procedurally generated content or debugging.
    /// </remarks>
    function  Save(const AFilename: string): Boolean;
    /// <summary>
    /// Loads a texture from a disk file
    /// </summary>
    /// <param name="AFilename">Path to the image file</param>
    /// <param name="AKind">Filtering mode for the texture</param>
    /// <param name="AColorKey">Optional color to treat as transparent</param>
    /// <returns>New texture object, or nil if loading failed</returns>
    /// <remarks>
    /// Convenience class method for loading textures in a single call.
    /// The returned texture is ready for immediate use.
    /// </remarks>
    /// <example>
    /// <code>
    /// LTexture := TpxTexture.LoadFromFile('player.png', pxPixelArtTexture);
    /// if Assigned(LTexture) then
    ///   // Texture ready for use
    /// </code>
    /// </example>
    class function LoadFromFile(const AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil): TpxTexture;
    /// <summary>
    /// Loads a texture from a file within a ZIP archive
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP file</param>
    /// <param name="AFilename">Filename within the ZIP archive</param>
    /// <param name="AKind">Filtering mode for the texture</param>
    /// <param name="AColorKey">Optional color to treat as transparent</param>
    /// <param name="APassword">ZIP archive password if required</param>
    /// <returns>New texture object, or nil if loading failed</returns>
    /// <remarks>
    /// Enables loading assets from compressed archives for distribution or organization.
    /// Supports password-protected archives.
    /// </remarks>
    class function LoadFromZip(const AZipFilename, AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil; const APassword: string=CpxDefaultZipPassword): TpxTexture;
  end;


/// <summary>Default shader source constant for built-in shaders</summary>
const
  CpxDefaultShaderSource = 'CpxDefaultShaderSource';

type
  /// <summary>
  /// Shader types supported by the graphics pipeline
  /// </summary>
  { TpxShaderKind }
  TpxShaderKind = (
    /// <summary>Vertex shader - processes vertex data and positions</summary>
    pxVertexShader=ALLEGRO_VERTEX_SHADER,
    /// <summary>Pixel/Fragment shader - processes individual pixels and colors</summary>
    pxPixelShader=ALLEGRO_PIXEL_SHADER
  );

  /// <summary>
  /// Shader class for custom graphics effects and post-processing
  /// </summary>
  /// <remarks>
  /// TpxShader enables custom graphics programming using GLSL shaders for advanced visual effects,
  /// post-processing, lighting, and material systems. Supports both vertex and pixel shaders
  /// with uniform parameter passing for dynamic effects. Requires knowledge of GLSL programming.
  /// </remarks>
  { TpxShader }
  TpxShader = class(TpxObject)
  protected
    FHandle: PALLEGRO_SHADER;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    /// <summary>
    /// Resets the shader to default state
    /// </summary>
    /// <remarks>
    /// Clears any loaded shader code and restores default vertex and pixel shaders.
    /// Useful for starting fresh or resetting after errors.
    /// </remarks>
    procedure Clear();
    /// <summary>
    /// Loads shader source code from a string
    /// </summary>
    /// <param name="AKind">Type of shader (vertex or pixel)</param>
    /// <param name="ASource">GLSL source code or CpxDefaultShaderSource for built-in</param>
    /// <returns>True if the shader source was loaded successfully</returns>
    /// <remarks>
    /// Loads GLSL source code for compilation. Use CpxDefaultShaderSource to load
    /// the built-in default shader for that type. Must call Build() after loading
    /// both vertex and pixel shaders.
    /// </remarks>
    /// <example>
    /// <code>
    /// LShader.Load(pxVertexShader, CpxDefaultShaderSource);
    /// LShader.Load(pxPixelShader, LCustomPixelShaderCode);
    /// if LShader.Build() then // Ready to use
    /// </code>
    /// </example>
    function  Load(const AKind: TpxShaderKind; const ASource: string): Boolean; overload;
    /// <summary>
    /// Loads shader source code from a file
    /// </summary>
    /// <param name="AFile">File handle containing GLSL source code</param>
    /// <param name="AKind">Type of shader (vertex or pixel)</param>
    /// <returns>True if loading succeeded</returns>
    /// <remarks>
    /// Convenient for loading shader source from external files. The file should
    /// contain valid GLSL source code for the specified shader type.
    /// </remarks>
    function  Load(const AFile: PpxFile; const AKind: TpxShaderKind): Boolean; overload;
    /// <summary>
    /// Compiles and links the loaded shader source code
    /// </summary>
    /// <returns>True if compilation and linking succeeded</returns>
    /// <remarks>
    /// Must be called after loading both vertex and pixel shader source.
    /// Check Log() for compilation errors if this returns False.
    /// </remarks>
    function  Build(): Boolean;
    /// <summary>
    /// Enables or disables this shader for rendering
    /// </summary>
    /// <param name="AEnable">True to use this shader, False to restore default</param>
    /// <returns>True if the operation succeeded</returns>
    /// <remarks>
    /// When enabled, all subsequent drawing operations use this shader.
    /// Remember to disable custom shaders when returning to normal rendering.
    /// </remarks>
    /// <example>
    /// <code>
    /// LShader.Enable(True);
    /// try
    ///   // Draw with custom shader
    ///   LTexture.Draw(100, 100, pxWHITE);
    /// finally
    ///   LShader.Enable(False);
    /// end;
    /// </code>
    /// </example>
    function  Enable(const AEnable: Boolean): Boolean;
    /// <summary>
    /// Gets compilation and linking error messages
    /// </summary>
    /// <returns>String containing error messages, or empty if no errors</returns>
    /// <remarks>
    /// Essential for debugging shader compilation issues. Contains detailed
    /// error information from the GLSL compiler.
    /// </remarks>
    function  Log(): string;
    /// <summary>
    /// Sets an integer uniform variable in the shader
    /// </summary>
    /// <param name="AName">Name of the uniform variable in the shader</param>
    /// <param name="AValue">Integer value to set</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Uniform variables are parameters passed to shaders. The variable name
    /// must exactly match the declaration in the GLSL source code.
    /// </remarks>
    function  SetIntUniform(const AName: string; const AValue: Integer): Boolean; overload;
    /// <summary>
    /// Sets an array of integer uniform values
    /// </summary>
    /// <param name="AName">Name of the uniform variable</param>
    /// <param name="ANumComponents">Components per element (1-4)</param>
    /// <param name="AValue">Pointer to integer array</param>
    /// <param name="ANumElements">Number of array elements</param>
    /// <returns>True if the uniform was set successfully</returns>
    function  SetIntUniform(const AName: string; const ANumComponents: Integer; const AValue: PInteger; const ANumElements: Integer): Boolean; overload;
    /// <summary>
    /// Sets a floating-point uniform variable in the shader
    /// </summary>
    /// <param name="AName">Name of the uniform variable in the shader</param>
    /// <param name="AValue">Float value to set</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Most common uniform type for shader parameters like time, brightness, colors, etc.
    /// </remarks>
    /// <example>
    /// <code>
    /// LShader.SetFloatUniform('time', LElapsedTime);
    /// LShader.SetFloatUniform('brightness', 0.8);
    /// </code>
    /// </example>
    function  SetFloatUniform(const AName: string; const AValue: Single): Boolean; overload;
    /// <summary>
    /// Sets an array of floating-point uniform values
    /// </summary>
    /// <param name="AName">Name of the uniform variable</param>
    /// <param name="ANumComponents">Components per element (1-4)</param>
    /// <param name="AValue">Pointer to float array</param>
    /// <param name="ANumElements">Number of array elements</param>
    /// <returns>True if the uniform was set successfully</returns>
    function  SetFloatUniform(const AName: string; const ANumComponents: Integer; const AValue: PSingle; const ANumElements: Integer): Boolean; overload;
    /// <summary>
    /// Sets a boolean uniform variable in the shader
    /// </summary>
    /// <param name="AName">Name of the uniform variable in the shader</param>
    /// <param name="AValue">Boolean value to set</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Useful for shader feature toggles and conditional effects.
    /// </remarks>
    function  SetBoolUniform(const AName: string; const AValue: Boolean): Boolean;
    /// <summary>
    /// Sets a texture uniform variable in the shader
    /// </summary>
    /// <param name="AName">Name of the sampler uniform in the shader</param>
    /// <param name="ATexture">Texture to bind to the sampler</param>
    /// <param name="AUnit">Texture unit number (typically 0)</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Allows shaders to sample from textures. The shader must declare a sampler2D
    /// uniform with the specified name. AUnit should typically be 0 for the first texture.
    /// </remarks>
    /// <example>
    /// <code>
    /// LShader.SetTextureUniform('mainTexture', LMyTexture, 0);
    /// </code>
    /// </example>
    function  SetTextureUniform(const AName: string; const ATexture: TpxTexture; const AUnit: Integer): Boolean;
    /// <summary>
    /// Sets a 2D vector uniform variable from a TpxVector
    /// </summary>
    /// <param name="AName">Name of the vec2 uniform in the shader</param>
    /// <param name="AValue">Vector containing X and Y components</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Convenient for passing 2D positions, sizes, or direction vectors to shaders.
    /// </remarks>
    function  SetVec2Uniform(const AName: string; const AValue: TpxVector): Boolean; overload;
    /// <summary>
    /// Sets a 2D vector uniform variable from individual components
    /// </summary>
    /// <param name="AName">Name of the vec2 uniform in the shader</param>
    /// <param name="X">X component</param>
    /// <param name="Y">Y component</param>
    /// <returns>True if the uniform was set successfully</returns>
    function  SetVec2Uniform(const AName: string; const X: Single; const Y: Single): Boolean; overload;
    /// <summary>
    /// Sets a 3D vector uniform variable from a TpxVector
    /// </summary>
    /// <param name="AName">Name of the vec3 uniform in the shader</param>
    /// <param name="AValue">Vector containing X, Y, and Z components</param>
    /// <returns>True if the uniform was set successfully</returns>
    /// <remarks>
    /// Useful for 3D positions, RGB colors, or direction vectors in shaders.
    /// </remarks>
    function  SetVec3Uniform(const AName: string; const AValue: TpxVector): Boolean; overload;
    /// <summary>
    /// Sets a 3D vector uniform variable from individual components
    /// </summary>
    /// <param name="AName">Name of the vec3 uniform in the shader</param>
    /// <param name="X">X component</param>
    /// <param name="Y">Y component</param>
    /// <param name="Z">Z component</param>
    /// <returns>True if the uniform was set successfully</returns>
    function  SetVec3Uniform(const AName: string; const X, Y, Z: Single): Boolean; overload;
  end;

type
  /// <summary>
  /// Provides a comprehensive 2D camera system with smooth following, screen shake effects,
  /// coordinate transformations, and viewport management for PIXELS games.
  /// </summary>
  /// <remarks>
  /// TpxCamera manages view transformations, zoom levels, rotation, and special effects like screen shake.
  /// The camera uses a logical coordinate system that is independent of actual screen resolution.
  /// All position coordinates are in world space unless otherwise specified.
  /// Camera transformations are applied during BeginTransform/EndTransform pairs.
  /// </remarks>
  /// <example>
  /// <code>
  /// var
  ///   LCamera: TpxCamera;
  /// begin
  ///   LCamera := TpxCamera.Create();
  ///   LCamera.SetLogicalSize(1920, 1080);
  ///   LCamera.SetPosition(100, 100);
  ///   LCamera.SetZoom(1.5);
  ///
  ///   // In game loop
  ///   LCamera.Update(DeltaTime);
  ///   LCamera.BeginTransform();
  ///   // Draw game objects here
  ///   LCamera.EndTransform();
  /// end;
  /// </code>
  /// </example>
  TpxCamera = class(TpxObject)
  protected
    FPosition: TpxVector;
    FTarget: TpxVector;
    FZoom: Single;
    FAngle: Single;
    FOrigin: TpxVector;
    FBounds: TpxRange;
    FShakeTime: Single;
    FShakeStrength: Single;
    FShakeOffset: TpxVector;
    FFollowLerp: Single;
    FIsShaking: Boolean;
    FSavedTransform: ALLEGRO_TRANSFORM;
    FLogicalSize: TpxSize;
    procedure ClampToBounds();
    procedure UpdateShake(const ADelta: Single);
  public
    /// <summary>
    /// Creates a new camera instance with default settings: position at origin, zoom of 1.0,
    /// no rotation, and logical size of 1280x720.
    /// </summary>
    constructor Create(); override;

    /// <summary>
    /// Destroys the camera instance and cleans up any associated resources.
    /// </summary>
    destructor Destroy(); override;

    /// <summary>
    /// Gets the current world position of the camera center.
    /// </summary>
    /// <returns>A TpxVector containing the camera's X and Y world coordinates</returns>
    function  GetPosition(): TpxVector;

    /// <summary>
    /// Sets the camera position to the specified world coordinates.
    /// The camera will immediately jump to this position without interpolation.
    /// </summary>
    /// <param name="AX">The X coordinate in world space</param>
    /// <param name="AY">The Y coordinate in world space</param>
    /// <remarks>
    /// If camera bounds are set, the position will be clamped to stay within those bounds.
    /// Use LookAt() for smooth camera movement with interpolation.
    /// </remarks>
    /// <seealso cref="LookAt"/>
    procedure SetPosition(const AX, AY: Single);

    /// <summary>
    /// Gets the current camera origin point used for rotation and scaling transformations.
    /// </summary>
    /// <returns>A TpxVector representing the origin point in normalized coordinates (0.0 to 1.0)</returns>
    /// <remarks>
    /// Default origin is (0, 0) representing the top-left of the camera view.
    /// Origin (0.5, 0.5) represents the center of the camera view.
    /// </remarks>
    function  GetOrigin(): TpxVector;

    /// <summary>
    /// Sets the camera's origin point for rotation and scaling operations.
    /// </summary>
    /// <param name="AX">The X origin coordinate (0.0 = left edge, 0.5 = center, 1.0 = right edge)</param>
    /// <param name="AY">The Y origin coordinate (0.0 = top edge, 0.5 = center, 1.0 = bottom edge)</param>
    /// <remarks>
    /// The origin affects where rotation and scaling transformations are applied from.
    /// Typically set to (0.5, 0.5) for center-based transformations.
    /// </remarks>
    procedure SetOrigin(const AX, AY: Single);

    /// <summary>
    /// Gets the current camera movement boundaries in world coordinates.
    /// </summary>
    /// <returns>A TpxRange defining the minimum and maximum X/Y coordinates the camera can reach</returns>
    /// <remarks>
    /// If no bounds are set, returns effectively infinite bounds (-MaxSingle to MaxSingle).
    /// </remarks>
    function  GetBounds(): TpxRange;

    /// <summary>
    /// Sets the world coordinate boundaries that constrain camera movement.
    /// </summary>
    /// <param name="AMinX">The minimum X coordinate the camera center can reach</param>
    /// <param name="AMinY">The minimum Y coordinate the camera center can reach</param>
    /// <param name="AMaxX">The maximum X coordinate the camera center can reach</param>
    /// <param name="AMaxY">The maximum Y coordinate the camera center can reach</param>
    /// <remarks>
    /// Camera bounds prevent the camera from moving outside a defined world area.
    /// Bounds account for the camera's zoom level and viewport size to prevent showing empty space.
    /// Set to very large values to effectively disable bounds checking.
    /// </remarks>
    procedure SetBounds(const AMinX, AMinY, AMaxX, AMaxY: Single);

    /// <summary>
    /// Gets the current logical screen size used for camera calculations.
    /// </summary>
    /// <returns>A TpxSize containing the logical width and height in pixels</returns>
    /// <remarks>
    /// Logical size is independent of actual window size and used for consistent coordinate mapping.
    /// </remarks>
    function  GetLogicalSize(): TpxSize;

    /// <summary>
    /// Sets the logical screen size for camera viewport calculations.
    /// </summary>
    /// <param name="AWidth">The logical screen width in pixels</param>
    /// <param name="AHeight">The logical screen height in pixels</param>
    /// <remarks>
    /// This should typically match your game's target resolution (e.g., 1920x1080).
    /// The logical size affects how world coordinates map to screen coordinates.
    /// </remarks>
    procedure SetLogicalSize(const AWidth, AHeight: Single);

    /// <summary>
    /// Gets the current camera zoom level.
    /// </summary>
    /// <returns>The zoom factor where 1.0 is normal size, 2.0 is 2x zoom, 0.5 is 50% size</returns>
    function  GetZoom(): Single;

    /// <summary>
    /// Sets the camera zoom level for magnification or minification.
    /// </summary>
    /// <param name="AZoom">The zoom factor (0.05 to 100.0). Values > 1.0 zoom in, < 1.0 zoom out</param>
    /// <remarks>
    /// Zoom is clamped to the range 0.05 to 100.0 for stability.
    /// Higher zoom values show less of the world but with more detail.
    /// Lower zoom values show more of the world but with less detail.
    /// </remarks>
    procedure SetZoom(const AZoom: Single);

    /// <summary>
    /// Gets the current camera rotation angle in degrees.
    /// </summary>
    /// <returns>The rotation angle in degrees (0-360)</returns>
    function  GetAngle(): Single;

    /// <summary>
    /// Sets the camera rotation angle.
    /// </summary>
    /// <param name="AAngle">The rotation angle in degrees (automatically clamped to 0-360 range)</param>
    /// <remarks>
    /// Rotation is applied around the camera's origin point.
    /// Positive angles rotate clockwise, following standard PIXELS coordinate conventions.
    /// </remarks>
    procedure SetAngle(const AAngle: Single);

    /// <summary>
    /// Calculates and returns the current camera view rectangle in world coordinates.
    /// </summary>
    /// <returns>A TpxRect representing the visible world area covered by the camera</returns>
    /// <remarks>
    /// The view rectangle accounts for camera position, zoom level, and logical screen size.
    /// Useful for culling objects outside the camera's view or implementing minimap systems.
    /// </remarks>
    function  GetViewRect(): TpxRect;

    /// <summary>
    /// Initiates smooth camera movement toward a target position with interpolation.
    /// </summary>
    /// <param name="ATarget">The target world position to move toward</param>
    /// <param name="ALerpSpeed">The interpolation speed (0.0 to 1.0). Higher values = faster movement</param>
    /// <remarks>
    /// The camera will smoothly interpolate toward the target position each frame during Update() calls.
    /// ALerpSpeed of 1.0 causes immediate movement (like SetPosition).
    /// ALerpSpeed of 0.1 creates slow, smooth following motion.
    /// Commonly used for player following cameras or smooth camera transitions.
    /// </remarks>
    /// <seealso cref="Update"/>
    procedure LookAt(const ATarget: TpxVector; const ALerpSpeed: Single);

    /// <summary>
    /// Updates the camera's smooth following motion and screen shake effects.
    /// Should be called once per frame in your game loop.
    /// </summary>
    /// <param name="ADelta">The time elapsed since the last update in seconds (typically 1/60 for 60fps)</param>
    /// <remarks>
    /// This method handles smooth interpolation for LookAt() movement and updates screen shake effects.
    /// Must be called before BeginTransform() to ensure current camera state is applied.
    /// In PIXELS' locked 60fps system, ADelta is typically 1/60 (0.01667) seconds.
    /// </remarks>
    /// <seealso cref="LookAt"/>
    /// <seealso cref="ShakeCamera"/>
    procedure Update(const ADelta: Single);

    /// <summary>
    /// Checks if the camera is currently performing a screen shake effect.
    /// </summary>
    /// <returns>True if screen shake is active, False if no shake is occurring</returns>
    function  IsShaking(): Boolean;

    /// <summary>
    /// Initiates a screen shake effect with specified duration and intensity.
    /// </summary>
    /// <param name="ADuration">The shake duration in seconds</param>
    /// <param name="AStrength">The shake intensity in pixels (higher values = more violent shake)</param>
    /// <remarks>
    /// Screen shake adds random offset to the camera position for dramatic effect.
    /// Commonly used for explosions, impacts, or other game events requiring visual feedback.
    /// The shake effect diminishes over time and stops automatically after ADuration seconds.
    /// Multiple calls to ShakeCamera will restart the effect with new parameters.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Create a 0.5 second shake with 10 pixel intensity for an explosion
    /// Camera.ShakeCamera(0.5, 10.0);
    /// </code>
    /// </example>
    procedure ShakeCamera(const ADuration, AStrength: Single);

    /// <summary>
    /// Begins applying the camera's transformation matrix to subsequent rendering operations.
    /// Must be paired with EndTransform() after drawing.
    /// </summary>
    /// <remarks>
    /// All drawing operations between BeginTransform() and EndTransform() will be affected by
    /// the camera's position, zoom, rotation, and shake effects.
    /// Saves the current transformation state to restore it later with EndTransform().
    /// </remarks>
    /// <example>
    /// <code>
    /// Camera.BeginTransform();
    /// try
    ///   // Draw game world objects here - they will be transformed by camera
    ///   Sprite.Render();
    ///   Background.Draw();
    /// finally
    ///   Camera.EndTransform();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="EndTransform"/>
    procedure BeginTransform();

    /// <summary>
    /// Ends the camera transformation and restores the previous transformation matrix.
    /// Must be called after BeginTransform() to restore normal rendering.
    /// </summary>
    /// <remarks>
    /// Restores the transformation state that was active before BeginTransform() was called.
    /// Always pair this with BeginTransform() using try/finally blocks for safety.
    /// </remarks>
    /// <seealso cref="BeginTransform"/>
    procedure EndTransform();

    /// <summary>
    /// Converts a world coordinate position to screen coordinate position using current camera transform.
    /// </summary>
    /// <param name="APosition">The world position to convert</param>
    /// <returns>The corresponding screen position in pixels</returns>
    /// <remarks>
    /// Accounts for camera position, zoom, rotation, and shake effects.
    /// Useful for placing UI elements at world object positions or converting mouse coordinates.
    /// Screen coordinates use the logical screen size set with SetLogicalSize().
    /// </remarks>
    /// <seealso cref="ScreenToWorld"/>
    function  WorldToScreen(const APosition: TpxVector): TpxVector;

    /// <summary>
    /// Converts a screen coordinate position to world coordinate position using current camera transform.
    /// </summary>
    /// <param name="APosition">The screen position to convert (in logical screen coordinates)</param>
    /// <returns>The corresponding world position</returns>
    /// <remarks>
    /// Accounts for camera position, zoom, rotation, and shake effects.
    /// Useful for converting mouse clicks to world positions or placing objects at screen locations.
    /// Screen coordinates should use the logical screen size set with SetLogicalSize().
    /// </remarks>
    /// <seealso cref="WorldToScreen"/>
    function  ScreenToWorld(const APosition: TpxVector): TpxVector;
  end;

/// <summary>
/// Represents the current state of a video playback operation in the PIXELS video system.
/// Used to track video lifecycle from loading through playback completion.
/// </summary>
/// <remarks>
/// Video state transitions follow the pattern: vsLoad -> vsPlaying -> (vsPaused) -> vsFinished -> vsUnload.
/// The paused state is optional and can occur during playback.
/// These states are used internally by the video system and in callback events.
/// </remarks>
TpxVideoState = (
    /// <summary>Video is being loaded into memory</summary>
    vsLoad,
    /// <summary>Video is being unloaded and resources freed</summary>
    vsUnload,
    /// <summary>Video is currently playing with audio</summary>
    vsPlaying,
    /// <summary>Video playback is paused but ready to resume</summary>
    vsPaused,
    /// <summary>Video has finished playing (reached the end)</summary>
    vsFinished
  );

  /// <summary>
  /// Provides comprehensive video playback functionality for the PIXELS game engine,
  /// supporting various formats and playback controls with audio integration.
  /// </summary>
  /// <remarks>
  /// TpxVideo is a static class that manages a single video stream at a time.
  /// Supports common video formats through Allegro's video addon (typically .ogv, .mp4, .avi).
  /// Video playback includes audio and can be controlled independently.
  /// Only one video can be active at a time - loading a new video stops the current one.
  /// Video state changes trigger callback events for integration with game logic.
  /// The video system integrates with PIXELS' 60fps game loop for smooth playback.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Play a video file with looping and 80% volume
  /// if TpxVideo.PlayFromFile('intro.ogv', True, 0.8) then
  /// begin
  ///   while TpxVideo.IsPlaying() do
  ///   begin
  ///     // Update game loop
  ///     TpxVideo.Draw(0, 0, 1.0);
  ///     // Handle other game logic
  ///   end;
  /// end;
  /// </code>
  /// </example>
  TpxVideo = class(TpxStaticObject)
  private class var
    FVoice: PALLEGRO_VOICE;
    FMixer: PALLEGRO_MIXER;
    FHandle: PALLEGRO_VIDEO;
    FLoop: Boolean;
    FPlaying: Boolean;
    FPaused: Boolean;
    FFilename: string;
  private
    class procedure OnVideoState(const AState: TpxVideoState; const AFilename: string); static;
    class function  Load(var AFile: PpxFile; const AFilename: string): Boolean; static;
    class procedure Play(const ALoop: Boolean; const AVolume: Single); overload; static;
    class constructor Create();
    class destructor Destroy();
  public
    /// <summary>
    /// Internal callback method for handling video completion events.
    /// Called automatically when a video reaches its end.
    /// </summary>
    /// <param name="AHandle">The internal Allegro video handle that finished playing</param>
    /// <remarks>
    /// This method is called internally by the PIXELS engine and should not be called directly.
    /// Handles looping logic and triggers appropriate state change events.
    /// When a looped video finishes, this method restarts playback automatically.
    /// For non-looped videos, this triggers the vsFinished state.
    /// </remarks>
    class procedure OnFinished(AHandle: PALLEGRO_VIDEO); static;

    /// <summary>
    /// Unloads the currently loaded video and frees all associated resources.
    /// </summary>
    /// <returns>True if a video was successfully unloaded, False if no video was loaded</returns>
    /// <remarks>
    /// Stops playback immediately if the video is currently playing and releases memory.
    /// Called automatically when loading a new video or destroying the video system.
    /// After unloading, all video state is reset and IsPlaying() will return False.
    /// This triggers the vsUnload state change event.
    /// </remarks>
    class function  Unload(): Boolean; static;

    /// <summary>
    /// Checks if the currently loaded video is in a paused state.
    /// </summary>
    /// <returns>True if video is paused, False if playing, stopped, or no video loaded</returns>
    /// <remarks>
    /// A paused video retains its current playback position and can be resumed.
    /// This differs from stopped state where the video would restart from the beginning.
    /// </remarks>
    /// <seealso cref="SetPause"/>
    class function  IsPaused(): Boolean; static;

    /// <summary>
    /// Pauses or unpauses the currently playing video.
    /// </summary>
    /// <param name="APause">True to pause the video, False to resume playback</param>
    /// <remarks>
    /// Pausing preserves the current playback position and audio state.
    /// Has no effect if no video is currently loaded.
    /// Cannot unpause a video that was never started with Play methods.
    /// Triggers vsPaused state when pausing, vsPlaying state when resuming.
    /// </remarks>
    /// <seealso cref="IsPaused"/>
    /// <seealso cref="SetPlaying"/>
    class procedure SetPause(const APause: Boolean); static;

    /// <summary>
    /// Checks if the currently loaded video is set to loop when it reaches the end.
    /// </summary>
    /// <returns>True if video will loop continuously, False if it will stop after one playthrough</returns>
    /// <remarks>
    /// Looping behavior is set when the video is first played and can be modified during playback.
    /// </remarks>
    /// <seealso cref="SetLoping"/>
    class function  IsLooping():  Boolean; static;

    /// <summary>
    /// Sets whether the currently loaded video should loop continuously.
    /// </summary>
    /// <param name="ALoop">True to enable looping, False to play once and stop</param>
    /// <remarks>
    /// Can be changed during playback to modify looping behavior dynamically.
    /// Looping videos automatically restart from the beginning when they reach the end.
    /// Non-looping videos trigger the vsFinished state and stop playing when complete.
    /// </remarks>
    /// <seealso cref="IsLooping"/>
    class procedure SetLoping(const ALoop: Boolean); static;

    /// <summary>
    /// Checks if a video is currently playing (actively displaying frames and playing audio).
    /// </summary>
    /// <returns>True if video is actively playing, False if paused, stopped, or no video loaded</returns>
    /// <remarks>
    /// Returns False for paused videos - use IsPaused() to distinguish between paused and stopped states.
    /// A playing video updates its frames automatically and advances its playback position.
    /// </remarks>
    /// <seealso cref="IsPaused"/>
    /// <seealso cref="SetPlaying"/>
    class function  IsPlaying(): Boolean; static;

    /// <summary>
    /// Starts or stops playback of the currently loaded video.
    /// </summary>
    /// <param name="APlay">True to start playback, False to stop</param>
    /// <remarks>
    /// Starting playback resumes from the current position if previously paused.
    /// Stopping playback halts the video but does not reset the position (use Rewind() for that).
    /// Has no effect if no video is currently loaded.
    /// Triggers vsPlaying state when starting, appropriate state when stopping.
    /// </remarks>
    /// <seealso cref="IsPlaying"/>
    /// <seealso cref="Rewind"/>
    class procedure SetPlaying(const APlay: Boolean); static;

    /// <summary>
    /// Gets the filename of the currently loaded video.
    /// </summary>
    /// <returns>The filename string as provided when loaded, or empty string if no video is loaded</returns>
    /// <remarks>
    /// Returns the filename as provided when the video was loaded.
    /// For ZIP-based videos, this includes the path within the ZIP archive.
    /// Useful for debugging, logging, or displaying current video information.
    /// </remarks>
    class function  GetFilename(): string; static;

    /// <summary>
    /// Loads and starts playing a video from a file handle with specified settings.
    /// </summary>
    /// <param name="AFile">The file handle to load from (consumed and set to nil on success)</param>
    /// <param name="AFilename">The original filename for identification and format detection</param>
    /// <param name="ALoop">True to loop the video continuously, False to play once</param>
    /// <param name="AVolume">The playback volume (0.0 = silent, 1.0 = full volume)</param>
    /// <returns>True if video loaded and started successfully, False on failure</returns>
    /// <remarks>
    /// The AFile parameter is consumed and automatically set to nil on success to prevent double-closing.
    /// Video format is determined from the filename extension (.ogv, .mp4, .avi, etc.).
    /// Any previously loaded video is automatically unloaded first.
    /// Triggers vsLoad state during loading, then vsPlaying state if successful.
    /// Volume uses logarithmic scaling for natural audio perception.
    /// </remarks>
    /// <example>
    /// <code>
    /// var
    ///   LFile: PpxFile;
    /// begin
    ///   LFile := TpxFile.OpenDisk('video.ogv', 'rb');
    ///   if TpxVideo.Play(LFile, 'video.ogv', False, 0.8) then
    ///     ShowMessage('Video started successfully');
    /// end;
    /// </code>
    /// </example>
    class function  Play(var AFile: PpxFile; const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean; overload; static;

    /// <summary>
    /// Loads and plays a video from a memory buffer.
    /// </summary>
    /// <param name="AMemory">Pointer to the video data in memory</param>
    /// <param name="ASize">Size of the video data in bytes</param>
    /// <param name="AFilename">Filename for format detection (extension determines codec)</param>
    /// <param name="ALoop">True to loop the video continuously, False to play once</param>
    /// <param name="AVolume">The playback volume (0.0 = silent, 1.0 = full volume)</param>
    /// <returns>True if video loaded and started successfully, False on failure</returns>
    /// <remarks>
    /// The memory buffer must remain valid and unchanged throughout video playback.
    /// Video format is determined from the filename extension, not the actual data.
    /// Useful for embedded video resources compiled into your executable.
    /// Memory is not freed by this method - caller retains ownership.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Play video from embedded resource
    /// var
    ///   LResource: TResourceStream;
    /// begin
    ///   LResource := TResourceStream.Create(HInstance, 'INTRO_VIDEO', RT_RCDATA);
    ///   try
    ///     TpxVideo.PlayFromMemory(LResource.Memory, LResource.Size, 'intro.ogv', False, 1.0);
    ///   finally
    ///     // Keep resource alive during playback
    ///   end;
    /// end;
    /// </code>
    /// </example>
    class function  PlayFromMemory(const AMemory: Pointer; const ASize: Int64; const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean; static;

    /// <summary>
    /// Loads and plays a video from a disk file.
    /// </summary>
    /// <param name="AFilename">Path to the video file on disk (relative or absolute)</param>
    /// <param name="ALoop">True to loop the video continuously, False to play once</param>
    /// <param name="AVolume">The playback volume (0.0 = silent, 1.0 = full volume)</param>
    /// <returns>True if video loaded and started successfully, False on failure</returns>
    /// <remarks>
    /// The file path can be relative to the executable or an absolute path.
    /// Video format is automatically detected from the file extension.
    /// Common supported formats include .ogv, .mp4, .avi (depends on Allegro build and system codecs).
    /// This is the most common method for playing video files in games.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Play intro video once at 90% volume
    /// if TpxVideo.PlayFromFile('assets/intro.ogv', False, 0.9) then
    /// begin
    ///   // Video is now playing
    /// end;
    /// </code>
    /// </example>
    class function  PlayFromFile(const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean; static;

    /// <summary>
    /// Loads and plays a video from within a ZIP archive.
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP archive file</param>
    /// <param name="AFilename">Path to the video file within the ZIP archive</param>
    /// <param name="ALoop">True to loop the video continuously, False to play once</param>
    /// <param name="AVolume">The playback volume (0.0 = silent, 1.0 = full volume)</param>
    /// <param name="APassword">Password for encrypted ZIP files (default: PIXELS default password)</param>
    /// <returns>True if video loaded and started successfully, False on failure</returns>
    /// <remarks>
    /// Useful for packaging video assets with your game distribution to reduce file count.
    /// The AFilename path should use forward slashes as separators within the ZIP.
    /// Video format is determined from the AFilename extension, not the ZIP name.
    /// Supports password-protected ZIP files for asset protection.
    /// The entire video is loaded into memory from the ZIP, so consider file sizes.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Play video from game assets ZIP
    /// TpxVideo.PlayFromZip('gamedata.zip', 'videos/cutscene1.ogv', False, 0.8);
    /// </code>
    /// </example>
    class function  PlayFromZip(const AZipFilename, AFilename: string; const ALoop: Boolean; const AVolume: Single; const APassword: string=CpxDefaultZipPassword): Boolean; static;

    /// <summary>
    /// Renders the current video frame to the screen at the specified position and scale.
    /// </summary>
    /// <param name="AX">The X coordinate for the top-left corner of the video display</param>
    /// <param name="AY">The Y coordinate for the top-left corner of the video display</param>
    /// <param name="AScale">The scaling factor (1.0 = original size, 2.0 = double size, 0.5 = half size)</param>
    /// <remarks>
    /// Must be called every frame while video is playing to display the current frame.
    /// Video frames are automatically updated by the underlying video system at the correct framerate.
    /// Scale must be greater than 0.0 or the video will not be drawn.
    /// If no video is playing or the video is paused, nothing is drawn.
    /// Video is drawn using current blend mode settings - ensure appropriate blend mode is set.
    /// Coordinates are in logical screen space as defined by TpxWindow.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Draw video at screen center with original size
    /// var
    ///   LWidth, LHeight: Single;
    /// begin
    ///   TpxVideo.GetSize(@LWidth, @LHeight);
    ///   TpxVideo.Draw((ScreenWidth - LWidth) / 2, (ScreenHeight - LHeight) / 2, 1.0);
    /// end;
    /// </code>
    /// </example>
    class procedure Draw(const AX, AY, AScale: Single); static;

    /// <summary>
    /// Gets the original pixel dimensions of the currently loaded video.
    /// </summary>
    /// <param name="AWidth">Pointer to receive the video width in pixels (can be nil)</param>
    /// <param name="AHeight">Pointer to receive the video height in pixels (can be nil)</param>
    /// <remarks>
    /// Returns the video's native resolution before any scaling is applied in Draw().
    /// If no video is loaded, both width and height are set to 0.
    /// Either parameter can be nil if you only need one dimension.
    /// Useful for centering videos, calculating aspect ratios, or UI layout.
    /// </remarks>
    /// <example>
    /// <code>
    /// var
    ///   LWidth, LHeight: Single;
    /// begin
    ///   TpxVideo.GetSize(@LWidth, @LHeight);
    ///   if (LWidth > 0) and (LHeight > 0) then
    ///     ShowMessage(Format('Video resolution: %.0fx%.0f', [LWidth, LHeight]));
    /// end;
    /// </code>
    /// </example>
    class procedure GetSize(AWidth: System.PSingle; AHeight: System.PSingle); static;

    /// <summary>
    /// Seeks to a specific time position in the currently loaded video.
    /// </summary>
    /// <param name="ASeconds">The target time position in seconds from the start of the video</param>
    /// <remarks>
    /// Seeking accuracy depends on the video format and codec used.
    /// Some formats only allow seeking to keyframes, which may result in approximate positioning.
    /// Has no effect if no video is currently loaded.
    /// Seeking while paused will update the current frame but maintain paused state.
    /// Audio and video are synchronized during seeking operations.
    /// Negative values are clamped to 0, values beyond video duration are clamped to maximum.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Skip to 30 seconds into the video
    /// TpxVideo.Seek(30.0);
    ///
    /// // Jump to 25% through the video (assuming 4 minute video)
    /// TpxVideo.Seek(60.0); // 1 minute in
    /// </code>
    /// </example>
    /// <seealso cref="Rewind"/>
    class procedure Seek(const ASeconds: Single); static;

    /// <summary>
    /// Rewinds the currently loaded video back to the beginning (time position 0).
    /// </summary>
    /// <remarks>
    /// Equivalent to calling Seek(0.0) but may be more efficient for some video formats.
    /// The video maintains its current playing/paused state after rewinding.
    /// Has no effect if no video is currently loaded.
    /// Useful for restarting videos without changing their loop settings.
    /// Both audio and video are reset to the beginning synchronously.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Restart the current video from the beginning
    /// TpxVideo.Rewind();
    ///
    /// // Rewind and pause for manual control
    /// TpxVideo.Rewind();
    /// TpxVideo.SetPause(True);
    /// </code>
    /// </example>
    /// <seealso cref="Seek"/>
    class procedure Rewind(); static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IOUtils,
  PIXELS.Utils,
  PIXELS.Game,
  PIXELS.Core;

{ TpxColor }
function TpxColor.FromByte(const AR, AG, AB, AA: Byte): TpxColor;
var
  LColor: ALLEGRO_COLOR;
begin
  LColor := al_map_rgba(AR, AG, AB, AA);
  r := LColor.r;
  g := LColor.g;
  b := LColor.b;
  a := LColor.a;
  Result := Self;
end;

function TpxColor.FromFloat(const AR, AG, AB, AA: Single): TpxColor;
var
  LColor: ALLEGRO_COLOR;
begin
  LColor := al_map_rgba_f(AR, AG, AB, AA);
  r := LColor.r;
  g := LColor.g;
  b := LColor.b;
  a := LColor.a;
  Result := Self;
end;

function TpxColor.FromName(const AName: string): TpxColor;
var
  LColor: ALLEGRO_COLOR absolute Result;
begin
  LColor := al_color_name(TpxUtils.AsUTF8(AName));
  r := LColor.r;
  g := LColor.g;
  b := LColor.b;
  a := LColor.a;
  Result := Self;
end;

function TpxColor.Fade(const ATo: TpxColor; APos: Single): TpxColor;
var
  LColor: TpxColor;
begin
  // clip to ranage 0.0 - 1.0
  if APos < 0 then
    APos := 0
  else if APos > 1.0 then
    APos := 1.0;

  // fade colors
  LColor.a := a + ((ATo.a - a) * APos);
  LColor.b := b + ((ATo.b - b) * APos);
  LColor.g := g + ((ATo.g - g) * APos);
  LColor.r := r + ((ATo.r - r) * APos);
  Result := FromFloat(LColor.r, LColor.g, LColor.b, LColor.a);
end;

function TpxColor.Equal(const AColor: TpxColor): Boolean;
begin
  if (r = AColor.r) and (g = AColor.g) and
     (b = AColor.b) and (a = AColor.a) then
    Result := True
  else
    Result := False;
end;

function TpxColor.Ease(const ATo: TpxColor; const AProgress: Double; const AEase: TpxEase): TpxColor;
begin
  Result.R := Round(TpxMath.EaseLerp(R, ATo.R, AProgress, AEase));
  Result.G := Round(TpxMath.EaseLerp(G, ATo.G, AProgress, AEase));
  Result.B := Round(TpxMath.EaseLerp(B, ATo.B, AProgress, AEase));
  Result.A := Round(TpxMath.EaseLerp(A, ATo.A, AProgress, AEase));
end;

// Direct import with delayed loading for backward compatibility
function GetDpiForWindow(hWnd: HWND): UINT; stdcall; external 'user32.dll' delayed;

class function TpxWindow.GetCurrentDeviceDPI: UINT;
var
  LForegroundWindow: HWND;
  LDC: HDC;
begin
  LForegroundWindow := GetForegroundWindow();
  if LForegroundWindow = 0 then
  begin
    Result := 96;
    Exit;
  end;

  try
    Result := GetDpiForWindow(LForegroundWindow);
  except
    // Fallback for older Windows versions
    LDC := GetDC(LForegroundWindow);
    if LDC <> 0 then
    try
      Result := GetDeviceCaps(LDC, LOGPIXELSX);
    finally
      ReleaseDC(LForegroundWindow, LDC);
    end
    else
      Result := 96;
  end;
end;

{ TpxWindow }
class constructor TpxWindow.Create();
begin
  inherited;
end;

class destructor TpxWindow.Destroy();
begin
  inherited;
end;

class function  TpxWindow.Init(const ATitle: string; const AWidth: Cardinal; const AHeight: Cardinal; const AVsync: Boolean; AResizable: Boolean): Boolean;
var
  //LDC: HDC;
  LFlags: Int32;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if IsInit() then
  begin
    Result := True;
    Exit;
  end;

  FTitle := ATitle;
  FLogicalSize.w := AWidth;
  FLogicalSize.h := AHeight;
  FVSync := AVsync;
  FResizable := AResizable;

  // Get system DPI for proper scaling on high-DPI displays
  FDpi := GetCurrentDeviceDPI();

  // Calculate scaling factor based on system DPI (96 is the reference DPI)
  FDpiScale := FDpi / 96;

  // Calculate initial window size with DPI scaling
  FPhysicalSize.w := FLogicalSize.w * FDpiScale;
  FPhysicalSize.h := FLogicalSize.h * FDpiScale;
  FIsFullscreen := False;

  // Set display flags for OpenGL rendering and resizable window
  LFlags := ALLEGRO_OPENGL or ALLEGRO_PROGRAMMABLE_PIPELINE;
  if FResizable then
    LFlags := LFlags or ALLEGRO_RESIZABLE or ALLEGRO_GENERATE_EXPOSE_EVENTS;

  al_set_new_display_flags(LFlags);

  // Set vertical sync if enabled
  if FVSync then
  begin
    al_set_new_display_option(ALLEGRO_VSYNC, 1, ALLEGRO_SUGGEST);
  end;

  al_set_new_display_option(ALLEGRO_SAMPLE_BUFFERS, 1, ALLEGRO_SUGGEST);
  al_set_new_display_option(ALLEGRO_SAMPLES, 4, ALLEGRO_SUGGEST); // enable multisampling

  // Create the display window with our calculated dimensions
  FDisplay := al_create_display(Round(FPhysicalSize.w), Round(FPhysicalSize.h));
  if not Assigned(FDisplay) then
  begin
    SetError('Failed to create display', []);
    Exit;
  end;

  // Set the window title
  SeTTitle(FTitle);

  // Initialize timer for precise frame timing
  SetTargetFPS(60);

  // Set up event handling
  al_register_event_source(TPixels.Queue, al_get_display_event_source(FDisplay));

  Clear(pxBLACK);

  FHWNDHandle := al_get_win_window_handle(FDisplay);

  // Initialize and register custom events
  al_init_user_event_source(@FDPIEventSource);
  al_register_event_source(TPixels.Queue, @FDPIEventSource);


  //InstallCustomWndProc(LWindow);

  // Initialize timing variables
  ResetTiming();

  Result := True;
end;

class function  TpxWindow.IsInit(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;

  Result := Assigned(FDisplay);
end;

class function  TpxWindow.Handle(): PALLEGRO_DISPLAY;
begin
  Result := nil;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FDisplay;
end;

class function  TpxWindow.IsReady(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FReady;
end;

class procedure TpxWindow.SetReady(const AReady: Boolean);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  FReady := AReady;
end;

class function  TpxWindow.Dpi(): Cardinal;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FDpi;
end;

class function  TpxWindow.DpiScale(): Single;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FDpiScale;
end;

class procedure TpxWindow.UpdateDpiScaling();
var
  LScaleX: Double;
  LScaleY: Double;
  LScale: Double;
  LOffsetX: Int32;
  LOffsetY: Int32;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  // Get system DPI for proper scaling on high-DPI displays

  FDpi := GetCurrentDeviceDPI();

  // Calculate scaling factor based on system DPI (96 is the reference DPI)
  FDpiScale := FDpi / 96;

  // Get the current window dimensions (important for proper resizing)
  FPhysicalSize.w := al_get_display_width(FDisplay);
  FPhysicalSize.h := al_get_display_height(FDisplay);

  // Calculate the scaling factors needed to fit our virtual resolution
  // into the current window while maintaining aspect ratio
  LScaleX := FPhysicalSize.w / FLogicalSize.w;    // How much we need to scale horizontally
  LScaleY := FPhysicalSize.h / FLogicalSize.h;  // How much we need to scale vertically

  // Take the smaller scale to avoid distortion (letterboxing/pillarboxing)
  LScale := Min(LScaleX, LScaleY);

  // Calculate offsets to center the virtual screen in the window
  // This creates the letterbox/pillarbox effect when needed
  LOffsetX := Round(FPhysicalSize.w - Round(FLogicalSize.w * LScale)) div 2;
  LOffsetY := Round(FPhysicalSize.h - Round(FLogicalSize.h * LScale)) div 2;

  FOffset.x := LOffsetX;
  FOffset.y := LOffsetY;

  al_reset_clipping_rectangle();
  al_clear_to_color(al_map_rgba(0,0,0,0));

  // CRITICAL: Set up transformation to properly scale and position the virtual screen
  // Note: Allegro applies transforms in REVERSE order from how they're specified
  al_identity_transform(@FTransform);  // Start with no transformation

  // Specify scaling first (but this will be applied SECOND by Allegro)
  // This scales our content by the calculated factor
  al_scale_transform(@FTransform, LScale, LScale);

  // Specify translation last (but this will be applied FIRST by Allegro)
  // This moves our content to the correct position after scaling
  al_translate_transform(@FTransform, LOffsetX, LOffsetY);

  // Apply the transformation
  al_use_transform(@FTransform);

  // Set clipping rectangle to prevent drawing outside our virtual screen area
  // This ensures nothing is drawn in the letterbox/pillarbox areas
  al_set_clipping_rectangle(LOffsetX, LOffsetY, Round(FLogicalSize.w * LScale), Round(FLogicalSize.h * LScale));
end;

class procedure TpxWindow.Close();
begin
  if not TPixels.IsInit() then Exit;
  if not Assigned(FDisplay) then Exit;

  // Unregister custom events and queue
  al_unregister_event_source(TPixels.Queue, @FDPIEventSource);
  al_destroy_user_event_source(@FDPIEventSource);

  // Unregister event source
  al_unregister_event_source(TPixels.Queue, al_get_display_event_source(FDisplay));

  // Destroy the display handle and other  states
  al_destroy_display(FDisplay);
  FDisplay := nil;
  FReady := False;
  FHWNDHandle := 0;
end;

class procedure TpxWindow.Focus();
var
  LWnd: HWND;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  LWnd := al_get_win_window_handle(FDisplay);
  if LWnd <> 0 then
  begin
    SetForegroundWindow(LWnd);
    SetFocus(LWnd);
  end;
end;

class function  TpxWindow.HasFocus(): Boolean;
var
  LWnd: HWND;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  LWnd := al_get_win_window_handle(FDisplay);
  if LWnd <> 0 then
    Result := Boolean(GetForegroundWindow() = LWnd);
end;

class function  TpxWindow.GeTTitle(): string;
begin
  Result := '';
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FTitle;
end;

class procedure TpxWindow.SetTitle(const ATitle: string);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  FTitle := ATitle;
  al_set_window_title(FDisplay, TpxUtils.AsUTF8(ATitle));
end;

class function  TpxWindow.GetLogicalSize(): TpxSize;
begin
  Result := Default(TpxSize);
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FLogicalSize;
end;

class function  TpxWindow.GetPhysicalSize(): TpxSize;
begin
  Result := Default(TpxSize);
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FPhysicalSize;
end;

class function  TpxWindow.IsVsyncEnabled(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FVSync;
end;

class function  TpxWindow.IsResiable(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FResizable;
end;

class function  TpxWindow.GetTargetFPS(): Cardinal;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FTargetFPS;
end;

class procedure TpxWindow.SetTargetFPS(const AFrameRate: Cardinal);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  FTargetFPS := AFrameRate;
  FFrameTime := 1 / FTargetFPS;

  ResetTiming();
end;

class function  TpxWindow.GetFrameTime(): Single;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FFrameTime;
end;

class function  TpxWindow.GetFPS(): Cardinal;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FActualFPS;
end;

class procedure TpxWindow.ResetTiming();
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  FCurrentTime := al_get_time();
  FLastTime := FCurrentTime;
  FSecondCounter := 0;
  FFrameCount := 0;
  FActualFPS := 0;
  FNeedRender := False;
  FNextFrameTime := FCurrentTime + FFrameTime;
end;

class procedure TpxWindow.UpdateTiming();
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;
  if not IsReady() then Exit;

  // Get current time for this frame
  FCurrentTime := al_get_time();

  // Calculate delta time (time since last frame)
  FDeltaTime := FCurrentTime - FLastTime;
  FLastTime := FCurrentTime;

  // Update FPS counter
  FSecondCounter := FSecondCounter + FDeltaTime;
  if FSecondCounter >= 1.0 then
  begin
    FActualFPS := FFrameCount;
    FFrameCount := 0;
    FSecondCounter := FSecondCounter - 1.0;
  end;
end;

class procedure TpxWindow.Clear(const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_clear_to_color(LColor);
end;

class function  TpxWindow.IsFullscreen(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  Result := FIsFullscreen
end;

class procedure TpxWindow.SetWindowFullscreen(const AFullscreen: Boolean);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_set_display_flag(FDisplay, ALLEGRO_FULLSCREEN_WINDOW, AFullscreen);
  FIsFullscreen := AFullscreen;

  if not AFullscreen then
  begin
    FDpi := GetCurrentDeviceDPI();
    FPhysicalSize.w := FLogicalSize.w * FDpiScale;
    FPhysicalSize.h := FLogicalSize.h * FDpiScale;
    al_resize_display(FDisplay, Round(FPhysicalSize.w), Round(FPhysicalSize.h));
  end;
end;

class procedure TpxWindow.ToggleFullscreen();
begin
  SetWindowFullscreen(not FIsFullscreen);
end;

class procedure TpxWindow.ShowFrame();
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  // Swap buffers to display the rendered frame
  al_flip_display;

  // Increment frame counter
  Inc(FFrameCount);

  // Update current time after rendering
  FCurrentTime := al_get_time();

  // If we're ahead of schedule, sleep until next frame time
  if FCurrentTime < FNextFrameTime then
  begin
    // Sleep for slightly less time than needed to avoid overshooting
    al_rest(FNextFrameTime - FCurrentTime - 0.001);
  end;

  // Calculate next frame time
  FNextFrameTime := FNextFrameTime + FFrameTime;

  // If we're falling behind too much, reset the next frame time
  // This prevents the game from trying to "catch up" after a large pause
  if FCurrentTime > FNextFrameTime + FFrameTime then
  begin
    FNextFrameTime := FCurrentTime + FFrameTime;
  end;
end;

class procedure TpxWindow.SetBlender(const AOperation, ASource, ADestination: Integer);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_set_blender(AOperation, ASource, ADestination);
end;

class procedure TpxWindow.GetBlender(AOperation: PInteger; ASource: PInteger; ADestination: PInteger);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_get_blender(AOperation, ASource, ADestination);
end;

class procedure TpxWindow.SetBlendColor(const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_set_blend_color(LColor);
end;

class function  TpxWindow.GetBlendColor(): TpxColor;
var
  LResult: ALLEGRO_COLOR absolute Result;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  LResult := al_get_blend_color();
end;

class procedure TpxWindow.SetBlendMode(const AMode: TpxBlendMode);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  case AMode of
    pxPreMultipliedAlphaBlendMode:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_INVERSE_ALPHA);
      end;
    pxNonPreMultipliedAlphaBlendMode:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_ALPHA, ALLEGRO_INVERSE_ALPHA);
      end;
    pxAdditiveAlphaBlendMode:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
      end;
    pxCopySrcToDestBlendMode:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ZERO);
      end;
    MultiplySrcAndDestBlendMode:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_DEST_COLOR, ALLEGRO_ZERO)
      end;
  end;
end;

class procedure TpxWindow.SetBlendModeColor(const AMode: TpxBlendModeColor; const AColor: TpxColor);
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  case AMode of
    pxColorNormalBlendModeColor:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_CONST_COLOR, ALLEGRO_ONE);
        al_set_blend_color(al_map_rgba_f(AColor.r, AColor.g, AColor.b, AColor.a));
      end;
    ColorAvgSrcDestBlendModeColor:
      begin
        al_set_blender(ALLEGRO_ADD, ALLEGRO_CONST_COLOR, ALLEGRO_CONST_COLOR);
        al_set_blend_color(al_map_rgba_f(AColor.r, AColor.g, AColor.b, AColor.a));
      end;
  end;
end;

class procedure TpxWindow.RestoreDefaultBlendMode();
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_INVERSE_ALPHA);
  al_set_blend_color(al_map_rgba(255, 255, 255, 255));
end;

class function TpxWindow.Save(const AFilename: string): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;
  if AFilename.IsEmpty then Exit;

  Result := al_save_bitmap(TpxUtils.AsUTF8(AFilename), al_get_backbuffer(FDisplay));
end;


class procedure TpxWindow.DrawPixel(const AX, AY: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_put_blended_pixel(Round(AX), Round(AY), LColor);
end;

class procedure TpxWindow.DrawLine(const X1, Y1, X2, Y2: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_line(X1, Y1, X2, Y2, LColor, AThickness);
end;

class procedure TpxWindow.DrawTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_triangle(X1, Y1, X2, Y2, X3, Y3, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_triangle(X1, Y1, X2, Y2, X3, Y3, LColor);
end;

class procedure TpxWindow.DrawRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_rectangle(AX, AY, AX+AWidth, AY+AHeight, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_rectangle(AX, AY, AX+AWidth, AY+AHeight, LColor);
end;

class procedure TpxWindow.DrawRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_rounded_rectangle(AX, AY, AX+AWidth, AY+AHeight, RX, RY, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_rounded_rectangle(AX, AY, AX+AWidth, AY+AHeight, RX, RY, LColor);
end;

class procedure TpxWindow.DrawCircle(const CX, CY, ARadius: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_circle(CX, CY, ARadius, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillCircle(const CX, CY, ARadius: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_circle(CX, CY, ARadius, LColor);
end;

class procedure TpxWindow.DrawEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_ellipse(CX, CY, RX, RY, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_ellipse(CX, CY, RX, RY, LColor);
end;

class procedure TpxWindow.DrawPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_pieslice(CX, CY, ARadius, AStartTheta, ADeltaTheta, LColor, AThickness);
end;

class procedure TpxWindow.DrawFillPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_filled_pieslice(CX, CY, ARadius, AStartTheta, ADeltaTheta, LColor);
end;

class procedure TpxWindow.DrawArc(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_arc(CX, CY, ARadius, AStartTheta, ADeltaTheta, LColor, AThickness);
end;

class procedure TpxWindow.DrawEllipticalArc(const CX, CY, RX, RY, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single);
var
  LColor: ALLEGRO_COLOR absolute AColor;
begin
  if not TPixels.IsInit() then Exit;
  if not IsInit() then Exit;

  al_draw_elliptical_arc(CX, CY, RX, RY, AStartTheta, ADeltaTheta, LColor, AThickness);
end;

{ TpxFont }
constructor TpxFont.Create();
begin
  inherited;

  TPixels.ResourceTracker.TrackObject(Self, 'TpxFont');
end;

destructor TpxFont.Destroy();
begin
  Unload();

  inherited;

  TPixels.ResourceTracker.Untrack(Self);
end;

function  TpxFont.LoadDefault(const ASize: Cardinal): Boolean;
var
  LResStream: TResourceStream;
  LFile: PpxFile;
begin
  Result := False;
  LResStream := TResourceStream.Create(HInStance, '8392d94c90a643eabbe718d10f85a047', RT_RCDATA);
  try
    LFile := TpxFile.OpenMemory(LResStream.Memory, LResStream.Size, 'rb');
    if not Assigned(LFIle) then Exit;
    Result := Load(LFile, ASize);
  finally
    LResStream.Free();
  end;
end;

function  TpxFont.Load(var AFile: PpxFile; const ASize: Cardinal): Boolean;
var
  LHandle: PALLEGRO_FONT;
  LSize: Integer;
  LOldFlags: Integer;
begin
  Result := False;
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;

  if not Assigned(AFile) then Exit;

  LSize := Round(ASize * TpxWindow.DpiScale());
  LOldFlags := al_get_new_bitmap_flags();
  al_set_new_bitmap_flags(ALLEGRO_MIN_LINEAR or ALLEGRO_MAG_LINEAR);
  LHandle := al_load_ttf_font_f(AFile, nil, LSize, 0);
  al_set_new_bitmap_flags(LOldFlags);
  if not Assigned(LHandle) then Exit;

  Unload();

  FHandle := LHandle;
  AFile := nil;

  Result := True;
end;

function  TpxFont.Loaded(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;

  Result := Assigned(FHandle);
end;

procedure TpxFont.Unload();
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;

  if Assigned(FHandle) then
  begin
    al_destroy_font(FHandle);
    FHandle := nil;
  end;
end;

procedure TpxFont.DrawText(const AColor: TpxColor; const AX, AY: Single; AAlign: TpxAlign; const AText: string; const AArgs: array of const);
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LText: string;
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Loaded() then Exit;

  LText := Format(AText, AArgs);
  if LText.IsEmpty then Exit;

  al_draw_text(FHandle, LColor, AX, AY, Ord(AAlign), TpxUtils.AsUTF8(LText));
end;

procedure TpxFont.DrawText(const AColor: TpxColor; const AX: Single; var AY: Single; const ALineSpace: Single; const AAlign: TpxAlign; const AText: string; const AArgs: array of const);
begin
  DrawText(AColor, AX, AY, AAlign, AText, AArgs);
  AY := AY + GetLineHeight() + ALineSpace;
end;

procedure TpxFont.DrawText(const AColor: TpxColor; const AX, AY, AAngle: Single; const AText: string; const AArgs: array of const);
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LText: string;
  LTransform, LPrevTransform: ALLEGRO_TRANSFORM;
  LTextWidth, LTextHeight: Single;
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Loaded() then Exit;

  LText := Format(AText, AArgs);
  if LText.IsEmpty then Exit;

  LTextWidth := GetTextWidth(LText, AArgs);
  LTextHeight := GetLineHeight();

  LPrevTransform := al_get_current_transform^;

  // Set up transform to rotate around center (X, Y)
  al_identity_transform(@LTransform);
  al_translate_transform(@LTransform, -LTextWidth / 2, -LTextHeight / 2); // Move origin to text center
  al_rotate_transform(@LTransform, AAngle * pxDEG2RAD);                   // Rotate around origin
  al_translate_transform(@LTransform, AX, AY);                              // Move to final position
  al_compose_transform(@LTransform, @LPrevTransform);
  al_use_transform(@LTransform);

  // Draw at 0,0 since transform already places it correctly
  al_draw_text(FHandle, LColor, 0, 0, ALLEGRO_ALIGN_LEFT or ALLEGRO_ALIGN_INTEGER, TpxUtils.AsUTF8(LText));

  // Restore previous transform
  al_use_transform(@LPrevTransform);

end;

function  TpxFont.GetTextWidth(const AText: string; const AArgs: array of const): Single;
var
  LText: string;
begin
  Result := 0;
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Loaded() then Exit;

  LText := Format(AText, AArgs);
  if LText.IsEmpty then Exit;

  Result := al_get_text_width(FHandle, TpxUtils.AsUTF8(LText));
end;

function  TpxFont.GetLineHeight(): Single;
begin
  Result := 0;
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Loaded() then Exit;

  Result := al_get_font_line_height(FHandle);
end;

constructor TpxTexture.Create();
begin
  inherited;

  FHandle := nil;
  FSize.W := 0;
  FSize.H := 0;
  FLocked := False;
  FLockedData := nil;
  FKind := pxPixelArtTexture;
  FOldTarget := nil;
  FLockedRegion.Assign(0, 0, 0, 0);

  TPixels.ResourceTracker.TrackObject(Self, 'TpxTexture');
end;

destructor TpxTexture.Destroy();
begin
  try
    // Ensure render target is restored before cleanup
    if Assigned(FOldTarget) then
      UnsetAsRenderTarget();

    // Ensure texture is unlocked before destruction
    if FLocked then
      Unlock();

    // Unload the texture
    Unload();
  finally
    TPixels.ResourceTracker.Untrack(Self);
    inherited;
  end;
end;

function TpxTexture.Alloc(const AWidth, AHeight: Cardinal; const AColor: TpxColor; const AKind: TpxTextureKind): Boolean;
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LHandle: PALLEGRO_BITMAP;
  LOldFlags: Integer;
  LOldTarget: PALLEGRO_BITMAP;
begin
  Result := False;

  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if (AWidth = 0) or (AHeight = 0) then Exit;

  LOldFlags := al_get_new_bitmap_flags();
  try
    case AKind of
      pxPixelArtTexture:
        al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP or ALLEGRO_ALPHA_TEST);
      pxHDTexture:
        al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP or ALLEGRO_MIN_LINEAR or ALLEGRO_MAG_LINEAR or ALLEGRO_ALPHA_TEST);
    end;

    LHandle := al_create_bitmap(AWidth, AHeight);
    if not Assigned(LHandle) then Exit;

    // Store current target and set to new bitmap
    LOldTarget := al_get_target_bitmap();
    al_set_target_bitmap(LHandle);
    al_clear_to_color(LColor);
    al_set_target_bitmap(LOldTarget);

    // Clean up existing texture before assigning new one
    Unload();

    FHandle := LHandle;
    FSize.W := al_get_bitmap_width(FHandle);
    FSize.H := al_get_bitmap_height(FHandle);
    FKind := AKind;

    Result := True;
  finally
    al_set_new_bitmap_flags(LOldFlags);
  end;
end;

function TpxTexture.Load(const AFile: PpxFile; const AExtension: string; const AKind: TpxTextureKind; const AColorKey: PpxColor): Boolean;
var
  LColorKey: PALLEGRO_COLOR absolute AColorKey;
  LHandle: PALLEGRO_BITMAP;
  LOldFlags: Integer;
begin
  Result := False;

  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Assigned(AFile) then Exit;
  if AExtension.IsEmpty then Exit;

  LOldFlags := al_get_new_bitmap_flags();
  try
    case AKind of
      pxPixelArtTexture:
        al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP or ALLEGRO_ALPHA_TEST);
      pxHDTexture:
        al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP or ALLEGRO_MIN_LINEAR or ALLEGRO_MAG_LINEAR or ALLEGRO_ALPHA_TEST);
    end;

    LHandle := al_load_bitmap_f(AFile, TpxUtils.AsUTF8(AExtension));
    if not Assigned(LHandle) then Exit;

    if Assigned(AColorKey) then
      al_convert_mask_to_alpha(LHandle, LColorKey^);

    Unload();

    FHandle := LHandle;
    FSize.W := al_get_bitmap_width(FHandle);
    FSize.H := al_get_bitmap_height(FHandle);
    FKind := AKind;

    Result := True;
  finally
    al_set_new_bitmap_flags(LOldFlags);
  end;
end;

function TpxTexture.IsLoaded(): Boolean;
begin
  Result := TPixels.IsInit and TpxWindow.IsInit and Assigned(FHandle);
end;

procedure TpxTexture.Unload();
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;

  // Ensure we're not locked before unloading
  if FLocked then
    Unlock();

  // Ensure we're not set as render target
  if Assigned(FOldTarget) then
    UnsetAsRenderTarget();

  if Assigned(FHandle) then
  begin
    al_destroy_bitmap(FHandle);
    FHandle := nil;
    FSize.W := 0;
    FSize.H := 0;
  end;
end;

function TpxTexture.Handle(): PALLEGRO_BITMAP;
begin
  Result := FHandle;
end;

function TpxTexture.Kind(): TpxTextureKind;
begin
  Result := FKind;
end;

function TpxTexture.GetSize(): TpxSize;
begin
  Result := FSize;
end;

procedure TpxTexture.Draw(const AX, AY: Single; const AColor: TpxColor; const ARegion: PpxRect; const AOrigin: PpxVector; const AScale: PpxVector; const AAngle: Single; const AHFlip, AVFlip: Boolean);
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LAngleRad: Single;
  LRG: TpxRect;
  LCP: TpxVector;
  LSC: TpxVector;
  LFlags: Integer;
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;

  // Convert angle to radians
  LAngleRad := AAngle * (PI / 180.0);

  // Set up region
  if Assigned(ARegion) then
  begin
    LRG := ARegion^;
    // Clamp region to texture bounds
    LRG.X := Max(0, Min(LRG.X, FSize.W - 1));
    LRG.Y := Max(0, Min(LRG.Y, FSize.H - 1));
    LRG.W := Max(0, Min(LRG.W, FSize.W - LRG.X));
    LRG.H := Max(0, Min(LRG.H, FSize.H - LRG.Y));
  end
  else
  begin
    LRG.X := 0;
    LRG.Y := 0;
    LRG.W := FSize.W;
    LRG.H := FSize.H;
  end;

  // Set up origin
  if Assigned(AOrigin) then
  begin
    LCP.X := LRG.W * AOrigin.X;
    LCP.Y := LRG.H * AOrigin.Y;
  end
  else
  begin
    LCP.X := 0;
    LCP.Y := 0;
  end;

  // Set up scale
  if Assigned(AScale) then
  begin
    LSC.X := AScale.X;
    LSC.Y := AScale.Y;
  end
  else
  begin
    LSC.X := 1.0;
    LSC.Y := 1.0;
  end;

  // Set up flags
  LFlags := 0;
  if AHFlip then LFlags := LFlags or ALLEGRO_FLIP_HORIZONTAL;
  if AVFlip then LFlags := LFlags or ALLEGRO_FLIP_VERTICAL;

  // Render
  al_draw_tinted_scaled_rotated_bitmap_region(FHandle, LRG.X, LRG.Y, LRG.W, LRG.H,
    LColor, LCP.X, LCP.Y, AX, AY, LSC.X, LSC.Y, LAngleRad, LFlags);
end;

procedure TpxTexture.DrawEx(const AX, AY: Single;  const AColor: TpxColor; const AScaleX, AScaleY: Single; const AAngle: Single; const AOriginX, AOriginY: Single);
var
  LOrigin: TpxVector;
  LScale: TpxVector;
begin
  LOrigin.X := AOriginX;
  LOrigin.Y := AOriginY;
  LScale.X := AScaleX;
  LScale.Y := AScaleY;

  Draw(AX, AY, AColor, nil, @LOrigin, @LScale, AAngle, False, False);
end;

procedure TpxTexture.DrawTiled(const ADeltaX, ADeltaY: Single);
var
  LW: Integer;
  LH: Integer;
  LOX: Integer;
  LOY: Integer;
  LPX: Single;
  LPY: Single;
  LFX: Single;
  LFY: Single;
  LTX: Integer;
  LTY: Integer;
  LVPW: Integer;
  LVPH: Integer;
  LVR: Integer;
  LVB: Integer;
  LIX: Integer;
  LIY: Integer;
begin
  if not IsLoaded() then Exit;

  LVPW := Round(TpxWindow.GetLogicalSize.W);
  LVPH := Round(TpxWindow.GetLogicalSize.H);

  LW := Round(FSize.W);
  LH := Round(FSize.H);

  LOX := -LW + 1;
  LOY := -LH + 1;

  LPX := ADeltaX;
  LPY := ADeltaY;

  LFX := LPX - Floor(LPX);
  LFY := LPY - Floor(LPY);

  LTX := Floor(LPX) - LOX;
  LTY := Floor(LPY) - LOY;

  if LTX >= 0 then
    LTX := LTX mod LW + LOX
  else
    LTX := LW - (-LTX mod LW) + LOX;

  if LTY >= 0 then
    LTY := LTY mod LH + LOY
  else
    LTY := LH - (-LTY mod LH) + LOY;

  LVR := LVPW;
  LVB := LVPH;
  LIY := LTY;

  while LIY < LVB do
  begin
    LIX := LTX;
    while LIX < LVR do
    begin
      al_draw_bitmap(FHandle, LIX + LFX, LIY + LFY, 0);
      LIX := LIX + LW;
    end;
    LIY := LIY + LH;
  end;
end;

function TpxTexture.Lock(const ARegion: PpxRect; const AData: PpxTextureData): Boolean;
begin
  Result := False;

  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;
  if FLocked then Exit;

  if Assigned(ARegion) then
  begin
    FLockedData := al_lock_bitmap_region(FHandle, Round(ARegion.X), Round(ARegion.Y),
      Round(ARegion.W), Round(ARegion.H), ALLEGRO_PIXEL_FORMAT_ANY, ALLEGRO_LOCK_READWRITE);
    if not Assigned(FLockedData) then Exit;
    FLockedRegion := ARegion^;
  end
  else
  begin
    FLockedData := al_lock_bitmap(FHandle, ALLEGRO_PIXEL_FORMAT_ANY, ALLEGRO_LOCK_READWRITE);
    if not Assigned(FLockedData) then Exit;
    FLockedRegion.X := 0;
    FLockedRegion.Y := 0;
    FLockedRegion.W := FSize.W;
    FLockedRegion.H := FSize.H;
  end;

  FLocked := True;

  if Assigned(AData) then
  begin
    AData.Memory := FLockedData.Data;
    AData.Format := FLockedData.Format;
    AData.Pitch := FLockedData.Pitch;
    AData.PixelSize := FLockedData.Pixel_Size;
  end;

  Result := True;
end;

function TpxTexture.IsLocked(): Boolean;
begin
  Result := TPixels.IsInit and TpxWindow.IsInit and IsLoaded() and FLocked;
end;

function TpxTexture.Unlock(): Boolean;
begin
  Result := False;

  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;
  if not FLocked then Exit;

  al_unlock_bitmap(FHandle);
  FLocked := False;
  FLockedRegion.Assign(0, 0, 0, 0);

  Result := True;
end;

function TpxTexture.GetPixel(const AX, AY: Integer): TpxColor;
var
  LResult: ALLEGRO_COLOR absolute Result;
begin
  Result := pxBLANK;

  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;
  if (AX < 0) or (AX >= FSize.W) or (AY < 0) or (AY >= FSize.H) then Exit;

  LResult := al_get_pixel(FHandle, AX, AY);
end;

procedure TpxTexture.SetPixel(const AX, AY: Integer; const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LOldTarget: PALLEGRO_BITMAP;
  LNeedRestore: Boolean;
begin
  LOldTarget :=  nil;
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;
  if (AX < 0) or (AX >= FSize.W) or (AY < 0) or (AY >= FSize.H) then Exit;

  // Check if this texture is already the current render target
  LNeedRestore := not IsRenderTarget();

  if LNeedRestore then
  begin
    LOldTarget := al_get_target_bitmap();
    al_set_target_bitmap(FHandle);
  end;

  al_put_pixel(AX, AY, LColor);

  if LNeedRestore then
    al_set_target_bitmap(LOldTarget);
end;

function  TpxTexture.IsRenderTarget(): Boolean;
begin
  Result := TPixels.IsInit and TpxWindow.IsInit and IsLoaded() and
            (al_get_target_bitmap() = FHandle);
end;

procedure TpxTexture.SetAsRenderTarget();
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not IsLoaded() then Exit;
  if Assigned(FOldTarget) then Exit; // Already set as render target

  FOldTarget := al_get_target_bitmap();
  al_set_target_bitmap(FHandle);
end;

procedure TpxTexture.UnsetAsRenderTarget();
begin
  if not TPixels.IsInit then Exit;
  if not TpxWindow.IsInit then Exit;
  if not Assigned(FOldTarget) then Exit;

  al_set_target_bitmap(FOldTarget);
  FOldTarget := nil;
end;

function TpxTexture.CopyTo(const ADestTexture: TpxTexture; const ASourceRegion: PpxRect; const ADestX, ADestY: Integer): Boolean;
var
  LSourceRect: TpxRect;
  LOldTarget: PALLEGRO_BITMAP;
begin
  Result := False;

  if not IsLoaded() then Exit;
  if not Assigned(ADestTexture) then Exit;
  if not ADestTexture.IsLoaded() then Exit;

  if Assigned(ASourceRegion) then
    LSourceRect := ASourceRegion^
  else
    LSourceRect.Assign(0, 0, FSize.W, FSize.H);

  LOldTarget := al_get_target_bitmap();
  al_set_target_bitmap(ADestTexture.Handle);

  al_draw_bitmap_region(FHandle, LSourceRect.X, LSourceRect.Y, LSourceRect.W, LSourceRect.H, ADestX, ADestY, 0);

  al_set_target_bitmap(LOldTarget);

  Result := True;
end;

function TpxTexture.Clone(): TpxTexture;
begin
  Result := nil;

  if not IsLoaded() then Exit;

  Result := TpxTexture.Create();
  if Result.Alloc(Round(FSize.W), Round(FSize.H), pxBLANK, FKind) then
  begin
    if not CopyTo(Result) then
    begin
      Result.Free;
      Result := nil;
    end;
  end
  else
  begin
    Result.Free;
    Result := nil;
  end;
end;

procedure TpxTexture.Clear(const AColor: TpxColor);
var
  LColor: ALLEGRO_COLOR absolute AColor;
  LOldTarget: PALLEGRO_BITMAP;
begin
  if not IsLoaded() then Exit;

  LOldTarget := al_get_target_bitmap();
  al_set_target_bitmap(FHandle);
  al_clear_to_color(LColor);
  al_set_target_bitmap(LOldTarget);
end;

function TpxTexture.Save(const AFilename: string): Boolean;
begin
  Result := False;

  if not IsLoaded() then Exit;
  if AFilename.IsEmpty then Exit;

  Result := al_save_bitmap(TpxUtils.AsUTF8(AFilename), FHandle);
end;

class function TpxTexture.LoadFromFile(const AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil): TpxTexture;
var
  LFile: PpxFile;
begin
  Result := nil;

  LFile := TpxFile.OpenDisk(AFilename, 'rb');
  if not Assigned(LFile) then Exit;
  try
    Result := TpxTexture.Create();
    if not Result.Load(LFile, '.'+TPath.GetExtension(AFilename), AKind, AColorKey) then
    begin
      Result.Free();
      Exit;
    end;
  finally
    TpxFile.Close(LFile);
  end;
end;

class function TpxTexture.LoadFromZip(const AZipFilename, AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil; const APassword: string=CpxDefaultZipPassword): TpxTexture;
var
  LFile: PpxFile;
begin
  Result := nil;

  LFile := TpxFile.OpenZip(AZipFilename, AFilename, APassword);
  if not Assigned(LFile) then Exit;
  try
    Result := TpxTexture.Create();
    if not Result.Load(LFile, TPath.GetExtension(AFilename), AKind, AColorKey) then
    begin
      Result.Free();
      Exit;
    end;
  finally
    TpxFile.Close(LFile);
  end;
end;

{ TpxShader }
constructor TpxShader.Create();
begin
  inherited;

  FHandle := al_create_shader(ALLEGRO_SHADER_GLSL);
  if not Assigned(FHandle) then
    TpxUtils.FatalError('Failed to create shader', []);

  Clear();

  TPixels.ResourceTracker.TrackObject(Self, 'TpxShader');
end;

destructor TpxShader.Destroy();
begin
  try
    Clear();
    if Assigned(FHandle) then
    begin
      al_destroy_shader(FHandle);
      FHandle := nil;
    end;
  finally
    TPixels.ResourceTracker.Untrack(Self);
    inherited;
  end;
end;

procedure TpxShader.Clear();
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;

  // Ensure no shader is currently in use before clearing
  al_use_shader(nil);

  // Clear vertex shader
  al_attach_shader_source(FHandle, ALLEGRO_VERTEX_SHADER, nil);

  // Clear pixel shader
  al_attach_shader_source(FHandle, ALLEGRO_PIXEL_SHADER, nil);

  // Restore default vertex shader
  al_attach_shader_source(FHandle, ALLEGRO_VERTEX_SHADER,
    al_get_default_shader_source(ALLEGRO_SHADER_GLSL, ALLEGRO_VERTEX_SHADER));

  // Restore default pixel shader
  al_attach_shader_source(FHandle, ALLEGRO_PIXEL_SHADER,
    al_get_default_shader_source(ALLEGRO_SHADER_GLSL, ALLEGRO_PIXEL_SHADER));
end;

function TpxShader.Load(const AKind: TpxShaderKind; const ASource: string): Boolean;
var
  LSource: string;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if ASource.IsEmpty then Exit;

  // Clear existing shader source for this kind
  al_attach_shader_source(FHandle, Ord(AKind), nil);

  LSource := ASource;

  if SameText(LSource, CpxDefaultShaderSource) then
    LSource := string(al_get_default_shader_source(ALLEGRO_SHADER_AUTO, Ord(AKind)));

  // Attach new shader source
  Result := al_attach_shader_source(FHandle, Ord(AKind), TpxUtils.AsUTF8(LSource));
end;

function TpxShader.Load(const AFile: PpxFile; const AKind: TpxShaderKind): Boolean;
var
  LBuffer: array of AnsiChar;
  LSize: Int64;
  LSource: string;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if not Assigned(AFile) then Exit;

  LSize := al_fsize(AFile);
  if LSize <= 0 then Exit;

  SetLength(LBuffer, LSize);
  if al_fgets(AFile, @LBuffer[0], LSize) <> nil then
    LSource := string(AnsiString(PAnsiChar(@LBuffer[0])))
  else
    LSource := '';

  Result := Load(AKind, LSource);
end;

function TpxShader.Build(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;

  Result := al_build_shader(FHandle);
end;

function TpxShader.Enable(const AEnable: Boolean): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;

  if AEnable then
    Result := al_use_shader(FHandle)
  else
    Result := al_use_shader(nil);
end;

function TpxShader.Log(): string;
begin
  Result := '';
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;

  Result := string(al_get_shader_log(FHandle));
end;

function TpxShader.SetIntUniform(const AName: string; const AValue: Integer): Boolean;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;

  Result := al_set_shader_int(TpxUtils.AsUTF8(AName), AValue);
end;

function TpxShader.SetIntUniform(const AName: string; const ANumComponents: Integer; const AValue: PInteger; const ANumElements: Integer): Boolean;
begin
  Result := False;

  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;
  if not Assigned(AValue) then Exit;
  if (ANumComponents <= 0) or (ANumElements <= 0) then Exit;

  Result := al_set_shader_int_vector(TpxUtils.AsUTF8(AName), ANumComponents, AValue, ANumElements);
end;

function TpxShader.SetFloatUniform(const AName: string; const AValue: Single): Boolean;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;

  Result := al_set_shader_float(TpxUtils.AsUTF8(AName), AValue);
end;

function TpxShader.SetFloatUniform(const AName: string; const ANumComponents: Integer; const AValue: PSingle; const ANumElements: Integer): Boolean;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;
  if not Assigned(AValue) then Exit;
  if (ANumComponents <= 0) or (ANumElements <= 0) then Exit;

  Result := al_set_shader_float_vector(TpxUtils.AsUTF8(AName), ANumComponents, AValue, ANumElements);
end;

function TpxShader.SetBoolUniform(const AName: string; const AValue: Boolean): Boolean;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;

  Result := al_set_shader_bool(TpxUtils.AsUTF8(AName), AValue);
end;

function TpxShader.SetTextureUniform(const AName: string; const ATexture: TpxTexture; const AUnit: Integer): Boolean;
begin
  Result := False;

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;
  if not Assigned(FHandle) then Exit;
  if AName.IsEmpty then Exit;
  if not Assigned(ATexture) then Exit;

  Result := al_set_shader_sampler(TpxUtils.AsUTF8(AName), ATexture.Handle, AUnit);
end;

function TpxShader.SetVec2Uniform(const AName: string; const AValue: TpxVector): Boolean;
var
  LVec2: array[0..1] of Single;
begin
  LVec2[0] := AValue.X;
  LVec2[1] := AValue.Y;
  Result := SetFloatUniform(AName, 2, @LVec2, 1);
end;

function TpxShader.SetVec2Uniform(const AName: string; const X: Single; const Y: Single): Boolean;
var
  LVec2: array[0..1] of Single;
begin
  LVec2[0] := X;
  LVec2[1] := Y;
  Result := SetFloatUniform(AName, 2, @LVec2, 1);
end;

function TpxShader.SetVec3Uniform(const AName: string; const AValue: TpxVector): Boolean;
var
  LVec3: array[0..2] of Single;
begin
  LVec3[0] := AValue.X;
  LVec3[1] := AValue.Y;
  LVec3[2] := AValue.Z;
  Result := SetFloatUniform(AName, 3, @LVec3, 1);
end;

function TpxShader.SetVec3Uniform(const AName: string; const X, Y, Z: Single): Boolean;
var
  LVec3: array[0..2] of Single;
begin
  LVec3[0] := X;
  LVec3[1] := Y;
  LVec3[2] := Z;
  Result := SetFloatUniform(AName, 3, @LVec3, 1);
end;

{ TpxCamera }
procedure TpxCamera.ClampToBounds();
var
  ViewW: Single;
  ViewH: Single;
begin
  ViewW := FLogicalSize.w / FZoom;
  ViewH := FLogicalSize.h / FZoom;
  FPosition.x := EnsureRange(FPosition.x, FBounds.minx + ViewW / 2, FBounds.maxx - ViewW / 2);
  FPosition.y := EnsureRange(FPosition.y, FBounds.miny + ViewH / 2, FBounds.maxy - ViewH / 2);
end;

procedure TpxCamera.UpdateShake(const ADelta: Single);
begin
if FShakeTime > 0 then
  begin
    FShakeTime := FShakeTime - ADelta;
    FShakeOffset.x := (Random - 0.5) * 2 * FShakeStrength;
    FShakeOffset.y := (Random - 0.5) * 2 * FShakeStrength;
    if FShakeTime <= 0 then
    begin
      FShakeTime := 0;
      FShakeOffset := TpxVector.Create(0, 0);
      FIsShaking := False;
    end;
  end
  else
    FShakeOffset := TpxVector.Create(0, 0);
end;

constructor TpxCamera.Create();
begin
  inherited;

  FPosition := TpxVector.Create(0, 0);
  FTarget := FPosition;
  FZoom := 1.0;
  FAngle := 0.0; // Degrees
  FOrigin := TpxVector.Create(0, 0);
  FBounds := TpxRange.Create(-MaxSingle, -MaxSingle, MaxSingle, MaxSingle);
  FShakeTime := 0;
  FShakeStrength := 0;
  FShakeOffset := TpxVector.Create(0, 0);
  FFollowLerp := 1.0;
  FIsShaking := False;
  FLogicalSize := TpxSize.Create(1280, 720);

  TPixels.ResourceTracker.TrackObject(Self, 'TpxCamera');
end;

destructor TpxCamera.Destroy();
begin
  inherited;

  TPixels.ResourceTracker.Untrack(Self);
end;

function  TpxCamera.GetPosition(): TpxVector;
begin
  Result := Default(TpxVector);
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FPosition;
end;

procedure TpxCamera.SetPosition(const AX, AY: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FPosition := TpxVector.Create(AX, AY);
  FTarget := FPosition;
  ClampToBounds();
end;

function  TpxCamera.GetOrigin(): TpxVector;
begin
  Result := Default(TpxVector);
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FOrigin;
end;

procedure TpxCamera.SetOrigin(const AX, AY: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FOrigin := TpxVector.Create(AX, AY);
end;

function  TpxCamera.GetBounds(): TpxRange;
begin
  Result := Default(TpxRange);

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FBounds;
end;

procedure TpxCamera.SetBounds(const AMinX, AMinY, AMaxX, AMaxY: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FBounds := TpxRange.Create(AMinX, AMinY, AMaxX, AMaxY);
end;

function  TpxCamera.GetLogicalSize(): TpxSize;
begin
  Result := Default(TpxSize);

  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FLogicalSize;
end;

procedure TpxCamera.SetLogicalSize(const AWidth, AHeight: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FLogicalSize.Create(AWidth, AHeight);
end;

function  TpxCamera.GetZoom(): Single;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FZoom;
end;

procedure TpxCamera.SetZoom(const AZoom: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FZoom := EnsureRange(AZoom, 0.05, 100.0);
end;

function  TpxCamera.GetAngle(): Single;
begin
  Result := 0;
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FAngle;
end;

procedure TpxCamera.SetAngle(const AAngle: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FAngle := EnsureRange(AAngle, 0, 360);
end;

function  TpxCamera.GetViewRect(): TpxRect;
var
  W, H: Single;
begin
  Result := Default(TpxRect);
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  W := FLogicalSize.w / FZoom;
  H := FLogicalSize.h / FZoom;
  Result := TpxRect.Create(
    FPosition.x - W / 2, FPosition.y - H / 2,
    W, H
  );
end;

procedure TpxCamera.LookAt(const ATarget: TpxVector; const ALerpSpeed: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FTarget := ATarget;
  FFollowLerp := EnsureRange(ALerpSpeed, 0.0, 1.0);
end;

procedure TpxCamera.Update(const ADelta: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  // Smooth follow, if enabled
  if FFollowLerp < 1.0 then
  begin
    FPosition.x := FPosition.x + (FTarget.x - FPosition.x) * FFollowLerp;
    FPosition.y := FPosition.y + (FTarget.y - FPosition.y) * FFollowLerp;
    ClampToBounds();
  end;

  // Update shake effect
  UpdateShake(ADelta);
end;

function  TpxCamera.IsShaking(): Boolean;
begin
  Result := False;
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result := FIsShaking;
end;

procedure TpxCamera.ShakeCamera(const ADuration, AStrength: Single);
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  FShakeTime := ADuration;
  FShakeStrength := AStrength;
  FIsShaking := True;
end;

procedure TpxCamera.BeginTransform();
var
  CurTrans: ALLEGRO_TRANSFORM;
  CamTrans: ALLEGRO_TRANSFORM;
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  // Save the current (virtual/logical) transform
  al_copy_transform(@FSavedTransform, al_get_current_transform);

  // Build the camera transform
  al_identity_transform(@CamTrans);
  al_translate_transform(@CamTrans, -FPosition.x, -FPosition.y);
  al_rotate_transform(@CamTrans, FAngle * pxDEG2RAD); // Degrees to radians
  al_scale_transform(@CamTrans, FZoom, FZoom);
  al_translate_transform(@CamTrans, FOrigin.x + FShakeOffset.x, FOrigin.y + FShakeOffset.y);

  // Compose: start with saved, then add camera on top!
  al_copy_transform(@CurTrans, @FSavedTransform);      // CurTrans = base (logical transform)
  al_compose_transform(@CurTrans, @CamTrans);          // CurTrans = base * camera

  // Set as active transform
  al_use_transform(@CurTrans);
end;

procedure TpxCamera.EndTransform();
begin
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  al_use_transform(@FSavedTransform);
end;

function  TpxCamera.WorldToScreen(const APosition: TpxVector): TpxVector;
begin
  Result := Default(TpxVector);
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result.x := (APosition.x - FPosition.x) * FZoom + FOrigin.x + FShakeOffset.x;
  Result.y := (APosition.y - FPosition.y) * FZoom + FOrigin.y + FShakeOffset.y;
end;

function  TpxCamera.ScreenToWorld(const APosition: TpxVector): TpxVector;
begin
  Result := Default(TpxVector);
  if not TPixels.IsInit() then Exit;
  if not TpxWindow.IsInit() then Exit;

  Result.x := (APosition.x - FOrigin.x - FShakeOffset.x) / FZoom + FPosition.x;
  Result.y := (APosition.y - FOrigin.y - FShakeOffset.y) / FZoom + FPosition.y;
end;

{ TpxVideo }
class procedure TpxVideo.OnFinished(AHandle: PALLEGRO_VIDEO);
begin
  if FHandle <> aHandle then Exit;

  Rewind;
  if FLoop then
    begin
      if not FPaused then
        SetPlaying(True);
    end
  else
    begin
      OnVideoState(vsFinished, FFilename);
    end;
end;

class procedure TpxVideo.OnVideoState(const AState: TpxVideoState; const AFilename: string);
begin
  if Assigned(GGame) then
    GGame.OnVideoState(AState, AFilename)
end;

class procedure TpxVideo.Play(const ALoop: Boolean; const AVolume: Single);
var
  LVolume: Single;
begin
  if not Assigned(FHandle) then Exit;
  al_start_video(FHandle, FMixer);
  LVolume := TpxUtils.LogarithmicVolume(AVolume);
  al_set_mixer_gain(FMixer, LVolume);
  al_set_video_playing(FHandle, True);
  FLoop := aLoop;
  FPlaying := True;
  FPaused := False;
  OnVideoState(vsPlaying, FFilename);
end;

class constructor TpxVideo.Create();
begin
  inherited;
end;

class destructor TpxVideo.Destroy();
begin
  Unload();
  inherited;
end;

class function  TpxVideo.Load(var AFile: PpxFile; const AFilename: string): Boolean;
var
  LFilename: string;
  LHandle: PALLEGRO_VIDEO;
begin
  Result := False;
  LFilename := AFilename;

  LHandle := al_open_video_f(AFile, TpxUtils.AsUTF8(TPath.GetExtension(LFilename)));
  if not Assigned(LHandle) then Exit;

  Unload();

  FHandle := LHandle;
  FFilename := LFilename;
  FLoop := False;
  FPlaying := False;
  FPaused := False;
  OnVideoState(vsLoad, FFilename);

  AFile := nil;

  if al_is_audio_installed then
  begin
    if not Assigned(FVoice) then
    begin
      FVoice := al_create_voice(44100, ALLEGRO_AUDIO_DEPTH_INT16, ALLEGRO_CHANNEL_CONF_2);
      FMixer := al_create_mixer(44100, ALLEGRO_AUDIO_DEPTH_FLOAT32, ALLEGRO_CHANNEL_CONF_2);
      al_attach_mixer_to_voice(FMixer, FVoice);
    end;
  end;

  al_register_event_source(TPixels.Queue(), al_get_video_event_source(LHandle));

  al_set_video_playing(LHandle, True);

  Result := True;
end;

class function  TpxVideo.Unload(): Boolean;
begin
  Result := False;
  if not Assigned(FHandle) then Exit;
  OnVideoState(vsUnload, FFilename);
  al_set_video_playing(FHandle, False);
  al_unregister_event_source(TPixels.Queue(), al_get_video_event_source(FHandle));
  al_close_video(FHandle);

  if al_is_audio_installed then
  begin
    al_detach_mixer(FMixer);
    al_destroy_mixer(FMixer);
    al_destroy_voice(FVoice);
  end;

  FHandle := nil;
  FMixer := nil;
  FVoice := nil;
  FFilename := '';
  FLoop := False;
  FPlaying := False;
  FPaused := False;
end;

class function  TpxVideo.IsPaused(): Boolean;
begin
  Result := False;
  if not Assigned(FHandle) then Exit;
  Result := FPaused;
end;

class procedure TpxVideo.SetPause(const APause: Boolean);
begin
  if not Assigned(FHandle) then Exit;

  // if trying to pause and video is not playing, just exit
  if (aPause = True) then
  begin
    if not al_is_video_playing(FHandle) then
    Exit;
  end;

  // if trying to unpause without first being paused, just exit
  if (aPause = False) then
  begin
    if FPaused = False then
      Exit;
  end;

  al_set_video_playing(FHandle, not aPause);
  FPaused := aPause;
  if FPaused then
    OnVideoState(vsPaused, FFilename)
  else
    OnVideoState(vsPlaying, FFilename);
end;

class function  TpxVideo.IsLooping():  Boolean;
begin
  Result := False;
  if not Assigned(FHandle) then Exit;
  Result := FLoop;
end;

class procedure TpxVideo.SetLoping(const ALoop: Boolean);
begin
  if not Assigned(FHandle) then Exit;
  FLoop := aLoop;
end;

class function  TpxVideo.IsPlaying(): Boolean;
begin
  Result := False;
  if not Assigned(FHandle) then Exit;
  Result := al_is_video_playing(FHandle);
end;

class procedure TpxVideo.SetPlaying(const APlay: Boolean);
begin
  if not Assigned(FHandle) then Exit;
  if FPaused then Exit;
  al_set_video_playing(FHandle, aPlay);
  FPlaying := aPlay;
  FPaused := False;
  OnVideoState(vsPlaying, FFilename);
end;

class function  TpxVideo.GetFilename(): string;
begin
  Result := '';
  if not Assigned(FHandle) then Exit;
  Result := FFilename;
end;

class function TpxVideo.Play(var AFile: PpxFile; const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean;
begin
  Result := False;
  if not Load(AFile, AFilename) then Exit;
  Play(ALoop, AVolume);
  Result := IsPlaying();
end;

class function TpxVideo.PlayFromMemory(const AMemory: Pointer; const ASize: Int64; const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  LFile := TpxFile.OpenMemory(AMemory, ASize, 'rb');
  if not Assigned(LFile) then Exit;

  Play(LFile, AFilename, ALoop, AVolume);
end;

class function TpxVideo.PlayFromFile(const AFilename: string; const ALoop: Boolean; const AVolume: Single): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  LFile := TpxFile.OpenDisk(AFilename, 'rb');
  if not Assigned(LFile) then Exit;

  Play(LFile, AFilename, ALoop, AVolume);
end;

class function TpxVideo.PlayFromZip(const AZipFilename, AFilename: string; const ALoop: Boolean; const AVolume: Single; const APassword: string): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  LFile := TpxFile.OpenZip(AZipFilename, AFilename, APassword);
  if not Assigned(LFile) then Exit;

  Play(LFile, AFilename, ALoop, AVolume);
end;

class procedure TpxVideo.Draw(const AX, AY, AScale: Single);
var
  LFrame: PALLEGRO_BITMAP;
  LSize: TpxVector;
  LScaled: TpxVector;
  LScale: Single;
begin
  if not Assigned(FHandle) then Exit;
  if aScale <= 0 then Exit;
  LScale := aScale;

  if (not IsPlaying) and (not FPaused) then Exit;

  if not al_is_video_playing(FHandle) then
   writeln('bad news');

  LFrame := al_get_video_frame(FHandle);
  if Assigned(LFrame) then
  begin
    LSize.X := al_get_bitmap_width(LFrame);
    LSize.Y := al_get_bitmap_height(LFrame);
    LScaled.X := al_get_video_scaled_width(FHandle);
    LScaled.Y := al_get_video_scaled_height(FHandle);

    al_draw_scaled_bitmap(LFrame, 0, 0,
      LSize.X,
      LSize.Y,
      aX, aY,
      LScaled.X*LScale,
      LScaled.Y*LScale,
      0);
  end;
end;

class procedure TpxVideo.GetSize(AWidth: System.PSingle; AHeight: System.PSingle);
begin
  if not Assigned(FHandle) then
  begin
    if Assigned(aWidth) then
      aWidth^ := 0;
    if Assigned(aHeight) then
      aHeight^ := 0;
    Exit;
  end;
  if Assigned(aWidth) then
    aWidth^ := al_get_video_scaled_width(FHandle);
  if Assigned(aHeight) then
    aHeight^ := al_get_video_scaled_height(FHandle);
end;

class procedure TpxVideo.Seek(const ASeconds: Single);
begin
  if not Assigned(FHandle) then Exit;
  al_seek_video(FHandle, aSeconds);
end;

class procedure TpxVideo.Rewind();
begin
  if not Assigned(FHandle) then Exit;
  al_seek_video(FHandle, 0);
end;


end.
