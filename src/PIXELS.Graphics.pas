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
  { TpxColor }
  PpxColor = ^TpxColor;
  TpxColor = record
    r,g,b,a: Single;
    function FromByte(const AR, AG, AB,  AA: Byte): TpxColor;
    function FromFloat(const AR, AG, AB, AA: Single): TpxColor;
    function FromName(const AName: string): TpxColor; overload;
    function Fade(const ATo: TpxColor; APos: Single): TpxColor;
    function Equal(const AColor: TpxColor): Boolean;
    function Ease(const ATo: TpxColor; const AProgress: Double; const AEase: TpxEase): TpxColor;

  end;

{$REGION ' COMMON COLORS '}
const
  pxALICEBLUE           : TpxColor = (r:$F0/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  pxANTIQUEWHITE        : TpxColor = (r:$FA/$FF; g:$EB/$FF; b:$D7/$FF; a:$FF/$FF);
  pxAQUA                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxAQUAMARINE          : TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$D4/$FF; a:$FF/$FF);
  pxAZURE               : TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxBEIGE               : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$DC/$FF; a:$FF/$FF);
  pxBISQUE              : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$C4/$FF; a:$FF/$FF);
  pxBLACK               : TpxColor = (r:$00/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxBLANCHEDALMOND      : TpxColor = (r:$FF/$FF; g:$EB/$FF; b:$CD/$FF; a:$FF/$FF);
  pxBLUE                : TpxColor = (r:$00/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxBLUEVIOLET          : TpxColor = (r:$8A/$FF; g:$2B/$FF; b:$E2/$FF; a:$FF/$FF);
  pxBROWN               : TpxColor = (r:$A5/$FF; g:$2A/$FF; b:$2A/$FF; a:$FF/$FF);
  pxBURLYWOOD           : TpxColor = (r:$DE/$FF; g:$B8/$FF; b:$87/$FF; a:$FF/$FF);
  pxCADETBLUE           : TpxColor = (r:$5F/$FF; g:$9E/$FF; b:$A0/$FF; a:$FF/$FF);
  pxCHARTREUSE          : TpxColor = (r:$7F/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxCHOCOLATE           : TpxColor = (r:$D2/$FF; g:$69/$FF; b:$1E/$FF; a:$FF/$FF);
  pxCORAL               : TpxColor = (r:$FF/$FF; g:$7F/$FF; b:$50/$FF; a:$FF/$FF);
  pxCORNFLOWERBLUE      : TpxColor = (r:$64/$FF; g:$95/$FF; b:$ED/$FF; a:$FF/$FF);
  pxCORNSILK            : TpxColor = (r:$FF/$FF; g:$F8/$FF; b:$DC/$FF; a:$FF/$FF);
  pxCRIMSON             : TpxColor = (r:$DC/$FF; g:$14/$FF; b:$3C/$FF; a:$FF/$FF);
  pxCYAN                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxDARKBLUE            : TpxColor = (r:$00/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKCYAN            : TpxColor = (r:$00/$FF; g:$8B/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKGOLDENROD       : TpxColor = (r:$B8/$FF; g:$86/$FF; b:$0B/$FF; a:$FF/$FF);
  pxDARKGRAY            : TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  pxDARKGREEN           : TpxColor = (r:$00/$FF; g:$64/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKGREY            : TpxColor = (r:$A9/$FF; g:$A9/$FF; b:$A9/$FF; a:$FF/$FF);
  pxDARKKHAKI           : TpxColor = (r:$BD/$FF; g:$B7/$FF; b:$6B/$FF; a:$FF/$FF);
  pxDARKMAGENTA         : TpxColor = (r:$8B/$FF; g:$00/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKOLIVEGREEN      : TpxColor = (r:$55/$FF; g:$6B/$FF; b:$2F/$FF; a:$FF/$FF);
  pxDARKORANGE          : TpxColor = (r:$FF/$FF; g:$8C/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKORCHID          : TpxColor = (r:$99/$FF; g:$32/$FF; b:$CC/$FF; a:$FF/$FF);
  pxDARKRED             : TpxColor = (r:$8B/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxDARKSALMON          : TpxColor = (r:$E9/$FF; g:$96/$FF; b:$7A/$FF; a:$FF/$FF);
  pxDARKSEAGREEN        : TpxColor = (r:$8F/$FF; g:$BC/$FF; b:$8F/$FF; a:$FF/$FF);
  pxDARKSLATEBLUE       : TpxColor = (r:$48/$FF; g:$3D/$FF; b:$8B/$FF; a:$FF/$FF);
  pxDARKSLATEGRAY       : TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  pxDARKSLATEGREY       : TpxColor = (r:$2F/$FF; g:$4F/$FF; b:$4F/$FF; a:$FF/$FF);
  pxDARKTURQUOISE       : TpxColor = (r:$00/$FF; g:$CE/$FF; b:$D1/$FF; a:$FF/$FF);
  pxDARKVIOLET          : TpxColor = (r:$94/$FF; g:$00/$FF; b:$D3/$FF; a:$FF/$FF);
  pxDEEPPINK            : TpxColor = (r:$FF/$FF; g:$14/$FF; b:$93/$FF; a:$FF/$FF);
  pxDEEPSKYBLUE         : TpxColor = (r:$00/$FF; g:$BF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxDIMGRAY             : TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  pxDIMGREY             : TpxColor = (r:$69/$FF; g:$69/$FF; b:$69/$FF; a:$FF/$FF);
  pxDODGERBLUE          : TpxColor = (r:$1E/$FF; g:$90/$FF; b:$FF/$FF; a:$FF/$FF);
  pxFIREBRICK           : TpxColor = (r:$B2/$FF; g:$22/$FF; b:$22/$FF; a:$FF/$FF);
  pxFLORALWHITE         : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$F0/$FF; a:$FF/$FF);
  pxFORESTGREEN         : TpxColor = (r:$22/$FF; g:$8B/$FF; b:$22/$FF; a:$FF/$FF);
  pxFUCHSIA             : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxGAINSBORO           : TpxColor = (r:$DC/$FF; g:$DC/$FF; b:$DC/$FF; a:$FF/$FF);
  pxGHOSTWHITE          : TpxColor = (r:$F8/$FF; g:$F8/$FF; b:$FF/$FF; a:$FF/$FF);
  pxGOLD                : TpxColor = (r:$FF/$FF; g:$D7/$FF; b:$00/$FF; a:$FF/$FF);
  pxGOLDENROD           : TpxColor = (r:$DA/$FF; g:$A5/$FF; b:$20/$FF; a:$FF/$FF);
  pxGRAY                : TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxGREEN               : TpxColor = (r:$00/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  pxGREENYELLOW         : TpxColor = (r:$AD/$FF; g:$FF/$FF; b:$2F/$FF; a:$FF/$FF);
  pxGREY                : TpxColor = (r:$80/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxHONEYDEW            : TpxColor = (r:$F0/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  pxHOTPINK             : TpxColor = (r:$FF/$FF; g:$69/$FF; b:$B4/$FF; a:$FF/$FF);
  pxINDIANRED           : TpxColor = (r:$CD/$FF; g:$5C/$FF; b:$5C/$FF; a:$FF/$FF);
  pxINDIGO              : TpxColor = (r:$4B/$FF; g:$00/$FF; b:$82/$FF; a:$FF/$FF);
  pxIVORY               : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$F0/$FF; a:$FF/$FF);
  pxKHAKI               : TpxColor = (r:$F0/$FF; g:$E6/$FF; b:$8C/$FF; a:$FF/$FF);
  pxLAVENDER            : TpxColor = (r:$E6/$FF; g:$E6/$FF; b:$FA/$FF; a:$FF/$FF);
  pxLAVENDERBLUSH       : TpxColor = (r:$FF/$FF; g:$F0/$FF; b:$F5/$FF; a:$FF/$FF);
  pxLAWNGREEN           : TpxColor = (r:$7C/$FF; g:$FC/$FF; b:$00/$FF; a:$FF/$FF);
  pxLEMONCHIFFON        : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$CD/$FF; a:$FF/$FF);
  pxLIGHTBLUE           : TpxColor = (r:$AD/$FF; g:$D8/$FF; b:$E6/$FF; a:$FF/$FF);
  pxLIGHTCORAL          : TpxColor = (r:$F0/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxLIGHTCYAN           : TpxColor = (r:$E0/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxLIGHTGOLDENRODYELLOW: TpxColor = (r:$FA/$FF; g:$FA/$FF; b:$D2/$FF; a:$FF/$FF);
  pxLIGHTGRAY           : TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  pxLIGHTGREEN          : TpxColor = (r:$90/$FF; g:$EE/$FF; b:$90/$FF; a:$FF/$FF);
  pxLIGHTGREY           : TpxColor = (r:$D3/$FF; g:$D3/$FF; b:$D3/$FF; a:$FF/$FF);
  pxLIGHTPINK           : TpxColor = (r:$FF/$FF; g:$B6/$FF; b:$C1/$FF; a:$FF/$FF);
  pxLIGHTSALMON         : TpxColor = (r:$FF/$FF; g:$A0/$FF; b:$7A/$FF; a:$FF/$FF);
  pxLIGHTSEAGREEN       : TpxColor = (r:$20/$FF; g:$B2/$FF; b:$AA/$FF; a:$FF/$FF);
  pxLIGHTSKYBLUE        : TpxColor = (r:$87/$FF; g:$CE/$FF; b:$FA/$FF; a:$FF/$FF);
  pxLIGHTSLATEGRAY      : TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  pxLIGHTSLATEGREY      : TpxColor = (r:$77/$FF; g:$88/$FF; b:$99/$FF; a:$FF/$FF);
  pxLIGHTSTEELBLUE      : TpxColor = (r:$B0/$FF; g:$C4/$FF; b:$DE/$FF; a:$FF/$FF);
  pxLIGHTYELLOW         : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$E0/$FF; a:$FF/$FF);
  pxLIME                : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxLIMEGREEN           : TpxColor = (r:$32/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  pxLINEN               : TpxColor = (r:$FA/$FF; g:$F0/$FF; b:$E6/$FF; a:$FF/$FF);
  pxMAGENTA             : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$FF/$FF; a:$FF/$FF);
  pxMAROON              : TpxColor = (r:$80/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxMEDIUMAQUAMARINE    : TpxColor = (r:$66/$FF; g:$CD/$FF; b:$AA/$FF; a:$FF/$FF);
  pxMEDIUMBLUE          : TpxColor = (r:$00/$FF; g:$00/$FF; b:$CD/$FF; a:$FF/$FF);
  pxMEDIUMORCHID        : TpxColor = (r:$BA/$FF; g:$55/$FF; b:$D3/$FF; a:$FF/$FF);
  pxMEDIUMPURPLE        : TpxColor = (r:$93/$FF; g:$70/$FF; b:$DB/$FF; a:$FF/$FF);
  pxMEDIUMSEAGREEN      : TpxColor = (r:$3C/$FF; g:$B3/$FF; b:$71/$FF; a:$FF/$FF);
  pxMEDIUMSLATEBLUE     : TpxColor = (r:$7B/$FF; g:$68/$FF; b:$EE/$FF; a:$FF/$FF);
  pxMEDIUMSPRINGGREEN   : TpxColor = (r:$00/$FF; g:$FA/$FF; b:$9A/$FF; a:$FF/$FF);
  pxMEDIUMTURQUOISE     : TpxColor = (r:$48/$FF; g:$D1/$FF; b:$CC/$FF; a:$FF/$FF);
  pxMEDIUMVIOLETRED     : TpxColor = (r:$C7/$FF; g:$15/$FF; b:$85/$FF; a:$FF/$FF);
  pxMIDNIGHTBLUE        : TpxColor = (r:$19/$FF; g:$19/$FF; b:$70/$FF; a:$FF/$FF);
  pxMINTCREAM           : TpxColor = (r:$F5/$FF; g:$FF/$FF; b:$FA/$FF; a:$FF/$FF);
  pxMISTYROSE           : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$E1/$FF; a:$FF/$FF);
  pxMOCCASIN            : TpxColor = (r:$FF/$FF; g:$E4/$FF; b:$B5/$FF; a:$FF/$FF);
  pxNAVAJOWHITE         : TpxColor = (r:$FF/$FF; g:$DE/$FF; b:$AD/$FF; a:$FF/$FF);
  pxNAVY                : TpxColor = (r:$00/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  pxOLDLACE             : TpxColor = (r:$FD/$FF; g:$F5/$FF; b:$E6/$FF; a:$FF/$FF);
  pxOLIVE               : TpxColor = (r:$80/$FF; g:$80/$FF; b:$00/$FF; a:$FF/$FF);
  pxOLIVEDRAB           : TpxColor = (r:$6B/$FF; g:$8E/$FF; b:$23/$FF; a:$FF/$FF);
  pxORANGE              : TpxColor = (r:$FF/$FF; g:$A5/$FF; b:$00/$FF; a:$FF/$FF);
  pxORANGERED           : TpxColor = (r:$FF/$FF; g:$45/$FF; b:$00/$FF; a:$FF/$FF);
  pxORCHID              : TpxColor = (r:$DA/$FF; g:$70/$FF; b:$D6/$FF; a:$FF/$FF);
  pxPALEGOLDENROD       : TpxColor = (r:$EE/$FF; g:$E8/$FF; b:$AA/$FF; a:$FF/$FF);
  pxPALEGREEN           : TpxColor = (r:$98/$FF; g:$FB/$FF; b:$98/$FF; a:$FF/$FF);
  pxPALETURQUOISE       : TpxColor = (r:$AF/$FF; g:$EE/$FF; b:$EE/$FF; a:$FF/$FF);
  pxPALEVIOLETRED       : TpxColor = (r:$DB/$FF; g:$70/$FF; b:$93/$FF; a:$FF/$FF);
  pxPAPAYAWHIP          : TpxColor = (r:$FF/$FF; g:$EF/$FF; b:$D5/$FF; a:$FF/$FF);
  pxPEACHPUFF           : TpxColor = (r:$FF/$FF; g:$DA/$FF; b:$B9/$FF; a:$FF/$FF);
  pxPERU                : TpxColor = (r:$CD/$FF; g:$85/$FF; b:$3F/$FF; a:$FF/$FF);
  pxPINK                : TpxColor = (r:$FF/$FF; g:$C0/$FF; b:$CB/$FF; a:$FF/$FF);
  pxPLUM                : TpxColor = (r:$DD/$FF; g:$A0/$FF; b:$DD/$FF; a:$FF/$FF);
  pxPOWDERBLUE          : TpxColor = (r:$B0/$FF; g:$E0/$FF; b:$E6/$FF; a:$FF/$FF);
  pxPURPLE              : TpxColor = (r:$80/$FF; g:$00/$FF; b:$80/$FF; a:$FF/$FF);
  pxREBECCAPURPLE       : TpxColor = (r:$66/$FF; g:$33/$FF; b:$99/$FF; a:$FF/$FF);
  pxRED                 : TpxColor = (r:$FF/$FF; g:$00/$FF; b:$00/$FF; a:$FF/$FF);
  pxROSYBROWN           : TpxColor = (r:$BC/$FF; g:$8F/$FF; b:$8F/$FF; a:$FF/$FF);
  pxROYALBLUE           : TpxColor = (r:$41/$FF; g:$69/$FF; b:$E1/$FF; a:$FF/$FF);
  pxSADDLEBROWN         : TpxColor = (r:$8B/$FF; g:$45/$FF; b:$13/$FF; a:$FF/$FF);
  pxSALMON              : TpxColor = (r:$FA/$FF; g:$80/$FF; b:$72/$FF; a:$FF/$FF);
  pxSANDYBROWN          : TpxColor = (r:$F4/$FF; g:$A4/$FF; b:$60/$FF; a:$FF/$FF);
  pxSEAGREEN            : TpxColor = (r:$2E/$FF; g:$8B/$FF; b:$57/$FF; a:$FF/$FF);
  pxSEASHELL            : TpxColor = (r:$FF/$FF; g:$F5/$FF; b:$EE/$FF; a:$FF/$FF);
  pxSIENNA              : TpxColor = (r:$A0/$FF; g:$52/$FF; b:$2D/$FF; a:$FF/$FF);
  pxSILVER              : TpxColor = (r:$C0/$FF; g:$C0/$FF; b:$C0/$FF; a:$FF/$FF);
  pxSKYBLUE             : TpxColor = (r:$87/$FF; g:$CE/$FF; b:$EB/$FF; a:$FF/$FF);
  pxSLATEBLUE           : TpxColor = (r:$6A/$FF; g:$5A/$FF; b:$CD/$FF; a:$FF/$FF);
  pxSLATEGRAY           : TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  pxSLATEGREY           : TpxColor = (r:$70/$FF; g:$80/$FF; b:$90/$FF; a:$FF/$FF);
  pxSNOW                : TpxColor = (r:$FF/$FF; g:$FA/$FF; b:$FA/$FF; a:$FF/$FF);
  pxSPRINGGREEN         : TpxColor = (r:$00/$FF; g:$FF/$FF; b:$7F/$FF; a:$FF/$FF);
  pxSTEELBLUE           : TpxColor = (r:$46/$FF; g:$82/$FF; b:$B4/$FF; a:$FF/$FF);
  pxTAN                 : TpxColor = (r:$D2/$FF; g:$B4/$FF; b:$8C/$FF; a:$FF/$FF);
  pxTEAL                : TpxColor = (r:$00/$FF; g:$80/$FF; b:$80/$FF; a:$FF/$FF);
  pxTHISTLE             : TpxColor = (r:$D8/$FF; g:$BF/$FF; b:$D8/$FF; a:$FF/$FF);
  pxTOMATO              : TpxColor = (r:$FF/$FF; g:$63/$FF; b:$47/$FF; a:$FF/$FF);
  pxTURQUOISE           : TpxColor = (r:$40/$FF; g:$E0/$FF; b:$D0/$FF; a:$FF/$FF);
  pxVIOLET              : TpxColor = (r:$EE/$FF; g:$82/$FF; b:$EE/$FF; a:$FF/$FF);
  pxWHEAT               : TpxColor = (r:$F5/$FF; g:$DE/$FF; b:$B3/$FF; a:$FF/$FF);
  pxWHITE               : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$FF/$FF; a:$FF/$FF);
  pxWHITESMOKE          : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  pxYELLOW              : TpxColor = (r:$FF/$FF; g:$FF/$FF; b:$00/$FF; a:$FF/$FF);
  pxYELLOWGREEN         : TpxColor = (r:$9A/$FF; g:$CD/$FF; b:$32/$FF; a:$FF/$FF);
  pxBLANK               : TpxColor = (r:$00;     g:$00;     b:$00;     a:$00);
  pxWHITE2              : TpxColor = (r:$F5/$FF; g:$F5/$FF; b:$F5/$FF; a:$FF/$FF);
  pxRED2                : TpxColor = (r:$7E/$FF; g:$32/$FF; b:$3F/$FF; a:255/$FF);
  pxCOLORKEY            : TpxColor = (r:$FF/$FF; g:$00;     b:$FF/$FF; a:$FF/$FF);
  pxOVERLAY1            : TpxColor = (r:$00/$FF; g:$20/$FF; b:$29/$FF; a:$B4/$FF);
  pxOVERLAY2            : TpxColor = (r:$01/$FF; g:$1B/$FF; b:$01/$FF; a:255/$FF);
  pxDIMWHITE            : TpxColor = (r:$10/$FF; g:$10/$FF; b:$10/$FF; a:$10/$FF);
  pxDARKSLATEBROWN      : TpxColor = (r:30/255; g:31/255; b:30/255; a:1/255);
{$ENDREGION}


const
  pxBLEND_ZERO = 0;
  pxBLEND_ONE = 1;
  pxBLEND_ALPHA = 2;
  pxBLEND_INVERSE_ALPHA = 3;
  pxBLEND_SRC_COLOR = 4;
  pxBLEND_DEST_COLOR = 5;
  pxBLEND_INVERSE_SRC_COLOR = 6;
  pxBLEND_INVERSE_DEST_COLOR = 7;
  pxBLEND_CONST_COLOR = 8;
  pxBLEND_INVERSE_CONST_COLOR = 9;
  pxBLEND_ADD = 0;
  pxBLEND_SRC_MINUS_DEST = 1;
  pxBLEND_DEST_MINUS_SRC = 2;

  CpxDefaultWindowWidth  = 1920 div 2;
  CpxDefaultWindowHeight = 1080 div 2;

type
  { TpxBlendMode }
  TpxBlendMode = (pxPreMultipliedAlphaBlendMode,
    pxNonPreMultipliedAlphaBlendMode, pxAdditiveAlphaBlendMode,
    pxCopySrcToDestBlendMode, MultiplySrcAndDestBlendMode);

  { TpxBlendModeColor }
  TpxBlendModeColor = (pxColorNormalBlendModeColor,
    ColorAvgSrcDestBlendModeColor);

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
    class function  Init(const ATitle: string; const AWidth: Cardinal=CpxDefaultWindowWidth; const AHeight: Cardinal=CpxDefaultWindowHeight; const AVsync: Boolean=True; AResizable: Boolean=True): Boolean; static;
    class function  IsInit(): Boolean; static;
    class function  Handle(): PALLEGRO_DISPLAY; static;
    class function  IsReady(): Boolean; static;
    class procedure SetReady(const AReady: Boolean); static;
    class function  Dpi(): Cardinal; static;
    class function  DpiScale(): Single; static;
    class procedure UpdateDpiScaling(); static;
    class procedure Close(); static;

    class procedure Focus(); static;
    class function  HasFocus(): Boolean; static;

    class function  GeTTitle(): string; static;
    class procedure SetTitle(const ATitle: string); static;

    class function  GetLogicalSize(): TpxSize; static;
    class function  GetPhysicalSize(): TpxSize; static;

    class function  IsVsyncEnabled(): Boolean; static;
    class function  IsResiable(): Boolean; static;

    class function  GetTargetFPS(): Cardinal; static;
    class procedure SetTargetFPS(const AFrameRate: Cardinal); static;
    class function  GetFrameTime(): Single; static;
    class function  GetFPS(): Cardinal; static;
    class procedure ResetTiming(); static;
    class procedure UpdateTiming(); static;

    class procedure Clear(const AColor: TpxColor); static;


    class function  IsFullscreen(): Boolean; static;
    class procedure SetWindowFullscreen(const AFullscreen: Boolean); static;
    class procedure ToggleFullscreen(); static;

    class procedure ShowFrame(); static;

    class procedure SetBlender(const AOperation, ASource, ADestination: Integer); static;
    class procedure GetBlender(AOperation: PInteger; ASource: PInteger; ADestination: PInteger); static;
    class procedure SetBlendColor(const AColor: TpxColor); static;
    class function  GetBlendColor(): TpxColor; static;
    class procedure SetBlendMode(const AMode: TpxBlendMode); static;
    class procedure SetBlendModeColor(const AMode: TpxBlendModeColor; const AColor: TpxColor); static;
    class procedure RestoreDefaultBlendMode(); static;

    class function  Save(const AFilename: string): Boolean; static;

    class procedure DrawPixel(const AX, AY: Single; const AColor: TpxColor); static;

    class procedure DrawLine(const X1, Y1, X2, Y2: Single; const AColor: TpxColor; const AThickness: Single); static;

    class procedure DrawTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillTriangle(const X1, Y1, X2, Y2, X3, Y3: Single; const AColor: TpxColor); static;

    class procedure DrawRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillRectangle(const AX, AY, AWidth, AHeight: Single; const AColor: TpxColor); static;
    class procedure DrawRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillRoundedRect(const AX, AY, AWidth, AHeight, RX, RY: Single; const AColor: TpxColor); static;

    class procedure DrawCircle(const CX, CY, ARadius: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillCircle(const CX, CY, ARadius: Single; const AColor: TpxColor); static;

    class procedure DrawEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillEllipse(const CX, CY, RX, RY: Single; const AColor: TpxColor); static;

    class procedure DrawPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawFillPieSlice(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor); static;

    class procedure DrawArc(const CX, CY, ARadius, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
    class procedure DrawEllipticalArc(const CX, CY, RX, RY, AStartTheta, ADeltaTheta: Single; const AColor: TpxColor; const AThickness: Single); static;
  end;

type
  { TpxAlign }
  TpxAlign = (
    pxAlignLeft   =ALLEGRO_ALIGN_LEFT,
    pxAlignCenter =ALLEGRO_ALIGN_CENTER,
    pxAlignRight  =ALLEGRO_ALIGN_RIGHT,
    pxAlignInteger=ALLEGRO_ALIGN_INTEGER
  );

  { TpxFont }
  TpxFont = class(TpxObject)
  protected
    FHandle: PALLEGRO_FONT;
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function  LoadDefault(const ASize: Cardinal): Boolean;
    function  Load(var AFile: PpxFile; const ASize: Cardinal): Boolean;
    function  Loaded(): Boolean;
    procedure Unload();

    procedure DrawText(const AColor: TpxColor; const AX, AY: Single; AAlign: TpxAlign; const AText: string; const AArgs: array of const); overload;
    procedure DrawText(const AColor: TpxColor; const AX: Single; var AY: Single; const ALineSpace: Single; const AAlign: TpxAlign; const AText: string; const AArgs: array of const); overload;
    procedure DrawText(const AColor: TpxColor; const AX, AY, AAngle: Single; const AText: string; const AArgs: array of const); overload;

    function  GetTextWidth(const AText: string; const AArgs: array of const): Single;
    function  GetLineHeight(): Single;
  end;

type
  { TpxTextureKind }
  TpxTextureKind = (pxPixelArtTexture, pxHDTexture);

  PpxTextureData = ^TpxTextureData;
  TpxTextureData = record
    Memory: Pointer;
    Format: Integer;
    Pitch: Integer;
    PixelSize: Integer;
  end;

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
    function  Alloc(const AWidth, AHeight: Cardinal; const AColor: TpxColor; const AKind: TpxTextureKind): Boolean;
    function  Load(const AFile: PpxFile; const AExtension: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil): Boolean;
    function  IsLoaded(): Boolean;
    procedure Unload();
    function  Handle(): PALLEGRO_BITMAP;
    function  Kind(): TpxTextureKind;
    function  GetSize(): TpxSize;
    procedure Draw(const AX, AY: Single; const AColor: TpxColor; const ARegion: PpxRect = nil; const AOrigin: PpxVector = nil; const AScale: PpxVector = nil; const AAngle: Single = 0; const AHFlip: Boolean = False; const AVFlip: Boolean = False);
    procedure DrawTiled(const ADeltaX, ADeltaY: Single);
    procedure DrawEx(const AX, AY: Single; const AColor: TpxColor; const AScaleX: Single = 1.0; const AScaleY: Single = 1.0; const AAngle: Single = 0; const AOriginX: Single = 0; const AOriginY: Single = 0);
    function  Lock(const ARegion: PpxRect = nil; const AData: PpxTextureData = nil): Boolean;
    function  IsLocked(): Boolean;
    function  Unlock(): Boolean;
    function  GetPixel(const AX, AY: Integer): TpxColor;
    procedure SetPixel(const AX, AY: Integer; const AColor: TpxColor);
    function  IsRenderTarget(): Boolean;
    procedure SetAsRenderTarget();
    procedure UnsetAsRenderTarget();
    function  CopyTo(const ADestTexture: TpxTexture; const ASourceRegion: PpxRect = nil; const ADestX: Integer = 0; const ADestY: Integer = 0): Boolean;
    function  Clone(): TpxTexture;
    procedure Clear(const AColor: TpxColor);
    function  Save(const AFilename: string): Boolean;
    class function LoadFromFile(const AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil): TpxTexture;
    class function LoadFromZip(const AZipFilename, AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor = nil; const APassword: string=CpxDefaultZipPassword): TpxTexture;
  end;


const
  CpxDefaultShaderSource = 'CpxDefaultShaderSource';

type
  { TpxShaderKind }
  TpxShaderKind = (pxVertexShader=ALLEGRO_VERTEX_SHADER, pxPixelShader=ALLEGRO_PIXEL_SHADER);

  { TpxShader }
  TpxShader = class(TpxObject)
  protected
    FHandle: PALLEGRO_SHADER;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure Clear();
    function  Load(const AKind: TpxShaderKind; const ASource: string): Boolean; overload;
    function  Load(const AFile: PpxFile; const AKind: TpxShaderKind): Boolean; overload;
    function  Build(): Boolean;
    function  Enable(const AEnable: Boolean): Boolean;
    function  Log(): string;
    function  SetIntUniform(const AName: string; const AValue: Integer): Boolean; overload;
    function  SetIntUniform(const AName: string; const ANumComponents: Integer; const AValue: PInteger; const ANumElements: Integer): Boolean; overload;
    function  SetFloatUniform(const AName: string; const AValue: Single): Boolean; overload;
    function  SetFloatUniform(const AName: string; const ANumComponents: Integer; const AValue: PSingle; const ANumElements: Integer): Boolean; overload;
    function  SetBoolUniform(const AName: string; const AValue: Boolean): Boolean;
    function  SetTextureUniform(const AName: string; const ATexture: TpxTexture; const AUnit: Integer): Boolean;
    function  SetVec2Uniform(const AName: string; const AValue: TpxVector): Boolean; overload;
    function  SetVec2Uniform(const AName: string; const X: Single; const Y: Single): Boolean; overload;
    function  SetVec3Uniform(const AName: string; const AValue: TpxVector): Boolean; overload;
    function  SetVec3Uniform(const AName: string; const X, Y, Z: Single): Boolean; overload;
  end;

type
  { TpxCamera }
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
    constructor Create(); override;
    destructor Destroy(); override;
    function  GetPosition(): TpxVector;
    procedure SetPosition(const AX, AY: Single);
    function  GetOrigin(): TpxVector;
    procedure SetOrigin(const AX, AY: Single);
    function  GetBounds(): TpxRange;
    procedure SetBounds(const AMinX, AMinY, AMaxX, AMaxY: Single);
    function  GetLogicalSize(): TpxSize;
    procedure SetLogicalSize(const AWidth, AHeight: Single);
    function  GetZoom(): Single;
    procedure SetZoom(const AZoom: Single);
    function  GetAngle(): Single;
    procedure SetAngle(const AAngle: Single);
    function  GetViewRect(): TpxRect;
    procedure LookAt(const ATarget: TpxVector; const ALerpSpeed: Single);
    procedure Update(const ADelta: Single);
    function  IsShaking(): Boolean;
    procedure ShakeCamera(const ADuration, AStrength: Single);
    procedure BeginTransform();
    procedure EndTransform();
    function  WorldToScreen(const APosition: TpxVector): TpxVector;
    function  ScreenToWorld(const APosition: TpxVector): TpxVector;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.IOUtils,
  PIXELS.Utils,
  PIXELS;

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

  //FTexture[3] := TpxTexture.Create();
  //LFile := TpxFile.OpenZip('Data.zip', 'res/backgrounds/space.png');
  //FTexture[3].Load(LFile, '.png', pxHDTexture, nil);
  //TpxFile.Close(LFile);

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

end.
