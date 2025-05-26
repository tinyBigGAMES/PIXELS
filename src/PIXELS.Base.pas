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

unit PIXELS.Base;

{$I PIXELS.Defines.inc}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  PIXELS.Deps;


type

  { TpxStaticObject }
  TpxStaticObject = class
  private class var
    FError: string;
  private
    class constructor Create();
    class destructor Destroy();
  public
    class procedure UnitInit(); static;
    class function  GetError(): string; static;
    class function  SetError(const AText: string; const AArgs: array of const): string; static;
  end;

  { TpxObject }
  TpxObject = class
  protected
    FError: string;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    function  GetError(): string;
    function  SetError(const AText: string; const AArgs: array of const): string;
  end;

  { TpxResourceTracker }
  TpxResourceTracker = class(TpxObject)
  public type
    FreePtrCallback = reference to procedure(const APtr: Pointer; const ATag: string);
  private type
    TKind = (rkPointer, rkObject);
    TInfo = record
      Kind: TKind;
      ObjClass: TClass;
      Tag: string;
    end;
  private
    FMap: TDictionary<Pointer, TInfo>;
    FFreePointerCallback: TpxResourceTracker.FreePtrCallback;
    function  GetFreePtrCallback(): TpxResourceTracker.FreePtrCallback;
    procedure SetFreePtrCallback(const ACallback: TpxResourceTracker.FreePtrCallback);
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure TrackPointer(const APtr: Pointer; const ATag: string = '');
    procedure TrackObject(const AObj: TObject; const ATag: string = '');
    procedure Untrack(const APtr: Pointer);
    procedure Cleanup(const ATag: string = '');
    function  Count(): Integer;

    property FreePointerCallback: TpxResourceTracker.FreePtrCallback read GetFreePtrCallback write SetFreePtrCallback;
  end;

implementation

{ TpxStaticObject }
class constructor TpxStaticObject.Create();
begin
end;

class destructor TpxStaticObject.Destroy();
begin
end;

class procedure TpxStaticObject.UnitInit();
begin
end;

class function  TpxStaticObject.GetError(): string;
begin
  Result := FError;
end;

class function  TpxStaticObject.SetError(const AText: string; const AArgs: array of const): string;
begin
  FError := Format(AText, AArgs);
end;

{ TpxObject }
constructor TpxObject.Create();
begin
  inherited;
end;

destructor TpxObject.Destroy();
begin
  inherited;
end;

function  TpxObject.GetError(): string;
begin
  Result := FError;
end;

function  TpxObject.SetError(const AText: string; const AArgs: array of const): string;
begin
  FError := Format(AText, AArgs);
  Result := GetError();
end;

{ TpxResourceTracker }
constructor TpxResourceTracker.Create();
begin
  inherited;
  FMap := TDictionary<Pointer, TInfo>.Create;
end;

destructor TpxResourceTracker.Destroy();
begin
  Cleanup();
  FMap.Free();

  inherited;
end;

function  TpxResourceTracker.GetFreePtrCallback(): TpxResourceTracker.FreePtrCallback;
begin
  Result := FFreePointerCallback;
end;

procedure TpxResourceTracker.SetFreePtrCallback(const ACallback: TpxResourceTracker.FreePtrCallback);
begin
  FFreePointerCallback := ACallback;
end;

procedure TpxResourceTracker.TrackPointer(const APtr: Pointer; const ATag: string);
var
  Info: TInfo;
begin
  Info.Kind := rkPointer;
  Info.ObjClass := nil;
  Info.Tag := ATag;
  FMap.AddOrSetValue(APtr, Info);
end;

procedure TpxResourceTracker.TrackObject(const AObj: TObject; const ATag: string);
var
  Info: TInfo;
begin
  Info.Kind := rkObject;
  Info.ObjClass := AObj.ClassType;
  Info.Tag := ATag;
  FMap.AddOrSetValue(AObj, Info);
end;

procedure TpxResourceTracker.Untrack(const APtr: Pointer);
begin
  FMap.Remove(APtr);
end;

procedure TpxResourceTracker.Cleanup(const ATag: string);
var
  List: TList<Pointer>;
  Pair: TPair<Pointer, TInfo>;
begin
  List := TList<Pointer>.Create;
  try
    for Pair in FMap do
      if (ATag = '') or SameText(Pair.Value.Tag, ATag) then
        List.Add(Pair.Key);

    for var Key in List do
    begin
      case FMap[Key].Kind of
        rkPointer:
          if Assigned(FFreePointerCallback) then
            FFreePointerCallback(Key, FMap[Key].Tag)
          else
            Dispose(Key);
        rkObject:
          TObject(Key).Free;
      end;
      FMap.Remove(Key);
    end;
  finally
    List.Free;
  end;
end;

function TpxResourceTracker.Count(): Integer;
begin
  Result := FMap.Count;
end;

initialization

finalization

end.
