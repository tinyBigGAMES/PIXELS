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

unit PIXELS.Utils;

{$I PIXELS.Defines.inc}

interface

uses
  System.SysUtils,
  PIXELS.Base;

type
  { TpxCallback }
  TpxCallback<T> = record
    Handler: T;
    UserData: Pointer;
  end;

  { TpxUtils }
  TpxUtils = class(TpxStaticObject)
  private class var
    FMarshaller: TMarshaller;
  private
    class constructor Create();
    class destructor Destroy();
  public
    class procedure FatalError(const AMsg: string; const AArgs: array of const); static;
    class function  AsUTF8(const AText: string): Pointer; static;
    class procedure ProcessMessages();

  end;

implementation

uses
  WinApi.Windows,
  System.Math;

{ TpxUtils }
class constructor TpxUtils.Create();
begin
  inherited;
end;

class destructor TpxUtils.Destroy();
begin
  inherited;
end;

class procedure TpxUtils.FatalError(const AMsg: string; const AArgs: array of const);
var
  LText: string;
begin
  LText := Format(AMsg, AArgs);
  MessageBox(0, PChar(LText), 'Fatal Error', MB_ICONERROR or MB_OK);
  Halt(1);
end;

class function  TpxUtils.AsUTF8(const AText: string): Pointer;
begin
  Result := FMarshaller.AsUtf8(AText).ToPointer;
end;

class procedure TpxUtils.ProcessMessages();
var
  LMsg: TMsg;
begin
  while Integer(PeekMessage(LMsg, 0, 0, 0, PM_REMOVE)) <> 0 do
  begin
    TranslateMessage(LMsg);
    DispatchMessage(LMsg);
  end;
end;

end.
