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

{$DEFINE REPORT_ALLEGRO_MEMLEAKS}
{$DEFINE TRACK_ALLEGRO_MEM}

interface

uses
  System.Generics.Collections,
  PIXELS.Deps,
  PIXELS.Base;

type

  { TPixels }
  TPixels = class(TpxStaticObject)
  private class var
    LMemInterface: ALLEGRO_MEMORY_INTERFACE;
    LMemList: TDictionary<Pointer, NativeUInt>;
    FEvent: ALLEGRO_EVENT;
    FQueue: PALLEGRO_EVENT_QUEUE;
    FVoice: PALLEGRO_VOICE;
    FMixer: PALLEGRO_MIXER;
    FUserEventSrc: ALLEGRO_EVENT_SOURCE;
    FIsInit: Boolean;
    FResourceTracker: TpxResourceTracker;

  private
    class function  StartupAllegro(): Boolean; static;
    class procedure ShutdownAllegro(); static;
    class constructor Create();
    class destructor Destroy();
  public
    class function  IsInit(): Boolean; static;
    class function  ResourceTracker: TpxResourceTracker; static;

    class function  GetVersion(): string; static;
    class function  GetAllegroVersion(): string; static;
    class procedure PrintASCIILogo(); static;

    class function  Event(): PALLEGRO_EVENT; static;
    class function  Mixer(): PALLEGRO_MIXER; static;
    class function  Queue(): PALLEGRO_EVENT_QUEUE; static;

  end;

implementation

uses
  System.SysUtils,
  PIXELS.Console,
  PIXELS.Utils,
  PIXELS.IO,
  PIXELS.Graphics,
  PIXELS.Audio,
  PIXELS.Events,
  PIXELS.Math;

function MyMalloc(size: NativeUInt; line: Integer; const file_: PAnsiChar; const func: PAnsiChar): Pointer; cdecl;
begin
  Result := AllocMem(size);
  if Result <> nil then
    TPixels.LMemList.Add(Result, size);
end;

procedure MyFree(ptr: Pointer; line: Integer; const file_: PAnsiChar; const func: PAnsiChar); cdecl;
begin
  if ptr <> nil then
    TPixels.LMemList.Remove(ptr);
  FreeMem(ptr);
end;

function MyRealloc(ptr: Pointer; size: NativeUInt; line: Integer; const file_: PAnsiChar; const func: PAnsiChar): Pointer; cdecl;
begin
  if ptr <> nil then
    TPixels.LMemList.Remove(ptr);
  Result := ReallocMemory(ptr, size);
  if Result <> nil then
    TPixels.LMemList.Add(Result, size);
end;

function MyCalloc(n: NativeUInt; size: NativeUInt; line: Integer; const file_: PAnsiChar; const func: PAnsiChar): Pointer; cdecl;
begin
  Result := AllocMem(n * size);
  if Result <> nil then
    TPixels.LMemList.Add(Result, n * size);
end;

{ TPixels }
class function TPixels.StartupAllegro(): Boolean;
begin
  Result := False;

  if al_is_system_installed then
  begin
    Result := True;
    Exit;
  end;

  LMemList := TDictionary<Pointer, NativeUInt>.Create;

  LMemInterface.mi_malloc := MyMalloc;
  LMemInterface.mi_free := MyFree;
  LMemInterface.mi_realloc := MyRealloc;
  LMemInterface.mi_calloc := MyCalloc;

  // Apply the custom memory interface to Allegro
  {$IFDEF TRACK_ALLEGRO_MEM}
  al_set_memory_interface(@LMemInterface);
  {$ENDIF}

  // init allegro
  if not al_install_system(ALLEGRO_VERSION_INT, nil) then Exit;

  // init devices
  if not al_install_joystick() then Exit;;
  if not al_install_keyboard() then Exit;
  if not al_install_mouse() then Exit;
  if not al_install_touch_input() then Exit;
  if not al_install_audio() then Exit;

  // init addons
  if not al_init_acodec_addon() then Exit;
  if not al_init_font_addon() then Exit;
  if not al_init_image_addon() then Exit;
  if not al_init_native_dialog_addon() then Exit;
  if not al_init_primitives_addon() then Exit;
  if not al_init_ttf_addon() then Exit;
  if not al_init_video_addon() then Exit;

  // int user event source
  al_init_user_event_source(@FUserEventSrc);

  // init event queues
  FQueue := al_create_event_queue;
  al_register_event_source(FQueue, al_get_joystick_event_source);
  al_register_event_source(FQueue, al_get_keyboard_event_source);
  al_register_event_source(FQueue, al_get_mouse_event_source);
  al_register_event_source(FQueue, al_get_touch_input_event_source);
  al_register_event_source(FQueue, al_get_touch_input_mouse_emulation_event_source);
  al_register_event_source(FQueue , @FUserEventSrc);

  // init audio
  if al_is_audio_installed then
  begin
    FVoice := al_create_voice(44100, ALLEGRO_AUDIO_DEPTH_INT16,  ALLEGRO_CHANNEL_CONF_2);
    FMixer := al_create_mixer(44100, ALLEGRO_AUDIO_DEPTH_FLOAT32,  ALLEGRO_CHANNEL_CONF_2);
    al_set_default_mixer(FMixer);
    al_attach_mixer_to_voice(FMixer, FVoice);
    al_reserve_samples(CpxAUDIO_CHANNEL_COUNT);
  end;

  Result := True;
end;

class procedure TPixels.ShutdownAllegro;
var
  LItem: TPair<Pointer, NativeUint>;
  LCount: NativeInt;
begin
  if not al_is_system_installed() then Exit;

  // shutdown audio
  if al_is_audio_installed() then
  begin
    al_stop_samples();
    al_reserve_samples(0);
    al_set_default_mixer(nil);
    al_detach_mixer(FMixer);
    al_destroy_mixer(FMixer);
    al_destroy_voice(FVoice);
    al_uninstall_audio();
  end;

  // shutdown event queues
  al_unregister_event_source(FQueue, al_get_joystick_event_source);
  al_unregister_event_source(FQueue, al_get_keyboard_event_source);
  al_unregister_event_source(FQueue, al_get_mouse_event_source);
  al_unregister_event_source(FQueue, al_get_touch_input_event_source);
  al_unregister_event_source(FQueue, al_get_touch_input_mouse_emulation_event_source);
  al_unregister_event_source(FQueue, @FUserEventSrc);
  al_destroy_user_event_source(@FUserEventSrc);
  al_destroy_event_queue(FQueue);

  // shutdown addon
  if al_is_video_addon_initialized() then
  begin
    al_shutdown_video_addon();
  end;

  if al_is_ttf_addon_initialized() then
  begin
    al_shutdown_ttf_addon();
  end;

  if al_is_primitives_addon_initialized() then
  begin
    al_shutdown_primitives_addon();
  end;

  if al_is_native_dialog_addon_initialized() then
  begin
    al_shutdown_native_dialog_addon();
  end;

  if al_is_image_addon_initialized() then
  begin
    al_shutdown_image_addon();
  end;

  if al_is_font_addon_initialized() then
  begin
    al_shutdown_font_addon();
  end;

  if al_is_acodec_addon_initialized() then
  begin
    //
  end;

  // shutdown devices
  if al_is_touch_input_installed() then
  begin
    al_uninstall_touch_input();
  end;

  if al_is_mouse_installed() then
  begin
    al_uninstall_mouse();
  end;

  if al_is_keyboard_installed() then
  begin
    al_uninstall_keyboard();
  end;

  if al_is_joystick_installed() then
  begin
    al_uninstall_joystick();
  end;

  if al_is_system_installed() then
  begin
    al_uninstall_system();
  end;

  LCount := LMemList.Count;

  if LCount > 0 then
  begin
    {$IFDEF REPORT_ALLEGRO_MEMLEAKS}
    TpxConsole.PrintLn(pxCSIFGRed+'Dangling Allegro allocations: %d', [LMemList.Count]);
    {$ENDIF}
  end;

  for LItem in LMemList do
  begin
    FreeMem(LItem.Key);
    {$IFDEF REPORT_ALLEGRO_MEMLEAKS}
    TpxConsole.SetForegroundColor(pxYELLOW);
    TpxConsole.PrintLn('  Size: %d bytes', [LItem.Value]);
    {$ENDIF}
  end;

  if LCount > 0 then
  begin
    {$IFDEF REPORT_ALLEGRO_MEMLEAKS}
    TpxConsole.PrintLn(pxCSIFGRed+'Relased all dangling Allegro allocations');
    TpxConsole.Pause(True);
    {$ENDIF}
  end;

  LMemList.Free();
end;

class constructor TPixels.Create();
begin
  inherited;
  if not StartupAllegro() then
  begin
    TpxUtils.FatalError('Not able to initalize Allegro', []);
  end;

  FResourceTracker := TpxResourceTracker.Create();

  FIsInit := True;
end;

class destructor TPixels.Destroy();
begin
  FResourceTracker.Free();
  ShutdownAllegro();
  FIsInit := False;
  inherited;
end;

class function  TPixels.IsInit(): Boolean;
begin
  Result := FIsInit;
end;

class function  TPixels.ResourceTracker: TpxResourceTracker;
begin
  Result := FResourceTracker;
end;

class function TPixels.GetVersion(): string;
begin
  Result := '0.1.0';
end;

class function  TPixels.GetAllegroVersion(): string;
var
  LVersion: Cardinal;
  LMajor, LMinor, LPatch, LRelease: Integer;
begin
  LVersion := al_get_allegro_version();
  LMajor := (LVersion shr 24) and $FF;
  LMinor := (LVersion shr 16) and $FF;
  LPatch := (LVersion shr 8) and $FF;
  LRelease := LVersion and $FF;
  Result := Format('%d.%d.%d.%d', [LMajor, LMinor, LPatch, LRelease]);
end;

class procedure TPixels.PrintASCIILogo();
begin
  TpxConsole.PrintLn('   ___ _____  _____ _    ___ ™', False);
  TpxConsole.PrintLn('  | _ \_ _\ \/ / __| |  / __|', False);
  TpxConsole.PrintLn('  |  _/| | >  <| _|| |__\__ \', False);
  TpxConsole.PrintLn('  |_| |___/_/\_\___|____|___/', False);
  TpxConsole.PrintLn('Advanced Delphi 2D Game Library');
end;

class function  TPixels.Event(): PALLEGRO_EVENT;
begin
  Result := @FEvent;
end;

class function  TPixels.Mixer(): PALLEGRO_MIXER;
begin
  Result := FMixer;
end;

class function  TPixels.Queue(): PALLEGRO_EVENT_QUEUE;
begin
  Result := FQueue;
end;

initialization
  TpxMath.UnitInit();
  TpxConsole.UnitInit();
  TpxUtils.UnitInit();
  TpxFile.UnitInit();
  TpxAudio.UnitInit();
  TpxWindow.UnitInit();

finalization


end.
