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

unit PIXELS.Game;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Math,
  PIXELS.Base;

type

  { TpxGameClass }
  TpxGameClass = class of TpxGame;

  { TpxGame }
  TpxGame = class(TpxObject)
  private class var
    FAllowCreate: Boolean;
  private
   class procedure InternalRunGame(const AGame: TpxGameClass); static;
  protected
    FRunning: Boolean;
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function  HasTerminated(): Boolean;
    procedure SetTerminate(const ATerminate: Boolean);

    procedure Run();

    function  OnStartup(): Boolean; virtual;
    procedure OnShutdown(); virtual;
    procedure OnUpdate(); virtual;
    procedure OnRender(); virtual;
    procedure OnRenderHUD(); virtual;
    procedure OnAfterRender(); virtual;
  end;


var
  GGame: TpxGame = nil;

procedure pxRunGame(const AGame: TpxGameClass);

implementation

uses
  WinApi.Windows,
  System.SysUtils,
  PIXELS.Deps,
  PIXELS.Graphics,
  PIXELS.Events,
  PIXELS;

{ TpxGame }
class procedure TpxGame.InternalRunGame(const AGame: TpxGameClass);
var
  LGame: TpxGame;
begin
  LGame := GGame;
  try
    FAllowCreate := True;
    try
      GGame := AGame.Create();
    finally
      FAllowCreate := False;
    end;
    try
      GGame.Run();
    finally
      GGame.Free();
    end;
  finally
    GGame := LGame;
  end;
end;

constructor TpxGame.Create();
begin
  if not FAllowCreate then
    raise Exception.Create('TpxGame.Create: Use pxRunGame to instantiate the game.');

  inherited Create();
end;

destructor TpxGame.Destroy();
begin
 inherited;
end;

function  TpxGame.HasTerminated(): Boolean;
begin
  Result := not FRunning;
end;

procedure TpxGame.SetTerminate(const ATerminate: Boolean);
begin
  FRunning := not ATerminate;
end;

procedure TpxGame.Run();
begin
  if not TPixels.IsInit() then Exit;

  (*
  if Assigned(LPIXELS.RunStartCallback.Handler) then
    LPIXELS.RunStartCallback.Handler(AWindow, LPIXELS.RunStartCallback.UserData);
  *)

  if not OnStartup() then Exit;

  if not TpxWindow.IsInit() then Exit;


  // Main game loop
  TpxWindow.Focus();

  TpxWindow.SetReady(TpxWindow.HasFocus());

  FRunning := TpxWindow.IsReady();

  // Set initial timing values
  TpxWindow.ResetTiming();

  while FRunning do
  begin
    TpxWindow.UpdateTiming();

    //LPIXELS.MouseWheel := 0;

    // Process all pending events
    while al_get_next_event(TPixels.Queue, TPixels.Event) do
    begin
      case TPixels.Event.&type of
        ALLEGRO_EVENT_DISPLAY_CLOSE:
        begin
          // User clicked the window close button
          FRunning := False;
        end;

        ALLEGRO_EVENT_DISPLAY_RESIZE:
        begin
          // Window was resized - acknowledge to complete the resize
          al_acknowledge_resize(TpxWindow.Handle());
        end;

        ALLEGRO_EVENT_MOUSE_AXES:
        begin
          //LPIXELS.MouseWheel := LEvent.mouse.dz / al_get_mouse_wheel_precision();
        end;

        // Loose focus
        //ALLEGRO_EVENT_MOUSE_LEAVE_DISPLAY,
        ALLEGRO_EVENT_DISPLAY_SWITCH_OUT,
        ALLEGRO_EVENT_DISPLAY_LOST,
        ALLEGRO_EVENT_DISPLAY_HALT_DRAWING:
        begin
          //LPIXELS.Ready := False;
          TpxWindow.SetReady(False);
        end;

        // Gain focus
        //ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY,
        ALLEGRO_EVENT_DISPLAY_SWITCH_IN,
        ALLEGRO_EVENT_DISPLAY_FOUND,
        ALLEGRO_EVENT_DISPLAY_RESUME_DRAWING:
        begin
          //LPIXELS.Ready := True;
          //pxResetWindowTiming(LWindow);
          TpxWindow.SetReady(True);
          TpxWindow.ResetTiming();
        end;

        (*
        ALLEGRO_EVENT_DPI_CHANGED:
        begin
          // Get system DPI for proper scaling on high-DPI displays
          LDc := GetDC(0);
          LWindow.Dpi := GetDeviceCaps(LDc, LOGPIXELSX);
          ReleaseDC(0, LDc);

          // Calculate scaling factor based on system DPI (96 is the reference DPI)
          LWindow.DpiScale := LWindow.Dpi / 96;
        end;
        *)
      end;

      TpxInput.Update();
    end;

    if not TpxWindow.IsReady() then
    begin
      al_rest(0.01); // sleep 10ms to reduce CPU usage
      continue;
    end;

    TpxWindow.UpdateDpiScaling();

    OnUpdate();

    OnRender();

    OnRenderHUD();

    TpxWindow.ShowFrame();

    OnAfterRender();
  end;

  OnShutdown();
end;

function  TpxGame.OnStartup(): Boolean;
begin
  Result := True;
end;

procedure TpxGame.OnShutdown();
begin
end;

procedure TpxGame.OnUpdate();
begin
end;

procedure TpxGame.OnRender();
begin
end;

procedure TpxGame.OnRenderHUD();
begin
end;

procedure TpxGame.OnAfterRender();
begin
end;

{ pxRunGame }
procedure pxRunGame(const AGame: TpxGameClass);
begin
  TpxGame.InternalRunGame(AGame);
end;

end.
