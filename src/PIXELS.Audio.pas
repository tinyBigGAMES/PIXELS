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

unit PIXELS.Audio;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Deps,
  PIXELS.Base,
  PIXELS.IO;

const
  CpxAUDIO_CHANNEL_COUNT   = 16;
  CpxAUDIO_PAN_NONE        = -1000.0;

type
  { TpxPlayMode }
  TpxPlayMode = (
    pxPlayModeOnce     = ALLEGRO_PLAYMODE_ONCE,
    pxPlayModeLoop     = ALLEGRO_PLAYMODE_LOOP,
    pxPlayModeBiDir    = ALLEGRO_PLAYMODE_BIDIR,
    pxPlayModeLoopOnce = ALLEGRO_PLAYMODE_LOOP_ONCE
  );

  { TpxSample }
  PpxSample = type PALLEGRO_SAMPLE;

  { TpxSampleID }
  PpxSampleID = ^TpxSampleID;
  TpxSampleID = record
    Index: Integer;
    Id: Integer;
  end;

  { TpxAudio }
  TpxAudio = class(TpxStaticObject)
  protected class var
    FMusic: PALLEGRO_AUDIO_STREAM;
  private
    class function LogarithmicVolume(const ALinear: Single): Single;
    class constructor Create();
    class destructor Destroy();
  public
    class procedure Pause(const APause: Boolean); static;
    class procedure Clear(); static;

    class function  LoadMusic(var AFile: PpxFile; const AExtension: string): Boolean; static;
    class procedure UnloadMusic(); static;
    class function  PlayMusic(const AVolume: Single; const AMode: TpxPlayMode): Boolean; overload; static;
    class function  PlayMusic(var AFile: PpxFile; const AVolume: Single; const AMode: TpxPlayMode): Boolean; overload; static;
    class function  StopMusic(): Boolean; static;
    class function  GetMusicPlayMode(): TpxPlayMode; static;
    class function  SetMusicPlayMode(const AMode: TpxPlayMode): Boolean; static;
    class function  IsMusicPlaying(): Boolean; static;
    class function  SetMusicPlaying(const APlay: Boolean): Boolean; static;
    class function  SetMusicVolume(const AVolume: Single): Boolean; static;
    class function  GetMusicVolume(): Single; static;
    class function  SeekMusic(const ATime: Single): Boolean; static;
    class function  RewindMusic(const ATime: Single): Boolean; static;

    class function  ReserveSampleChannels(const ACount: UInt32): Boolean; static;
    class function  LoadSample(const AFile: PpxFile): PpxSample; static;
    class procedure UnloadSample(var ASample: PpxSample); static;
    class function  PlaySample(const ASample: PpxSample; const AVolume, APan, ASpeed: Single; const AMode: TpxPlayMode; AId: PpxSampleID): Boolean; static;
    class procedure StopSample(const AId: TpxSampleID); static;
    class procedure StopAllSamples(); static;
    class function  IsSamplePlaying(const AId: TpxSampleID): Boolean; static;
  end;

implementation

uses
  System.Math,
  PIXELS.Utils,
  PIXELS;

{ TpxAudio }
class function TpxAudio.LogarithmicVolume(const ALinear: Single): Single;
const
  MinDb = -40.0; // Minimum dB attenuation (e.g., -40 dB = almost silence)
var
  L: Single;
begin
  L := EnsureRange(ALinear, 0.0, 1.0);
  if L = 0 then
    Result := 0
  else if L = 1 then
    Result := 1
  else
    Result := Power(10, (MinDb * (1 - L)) / 20);
end;

class constructor TpxAudio.Create();
begin
  inherited;
end;

class destructor TpxAudio.Destroy();
begin
  Clear();
  inherited;
end;

class procedure TpxAudio.Pause(const APause: Boolean);
begin
  if not al_is_audio_installed() then Exit;
  al_set_mixer_playing(TPixels.Mixer(), not APause);
end;

class procedure TpxAudio.Clear();
begin
  UnloadMusic();
  StopAllSamples();
end;

class function  TpxAudio.LoadMusic(var AFile: PpxFile; const AExtension: string): Boolean;
var
  LHandle: PALLEGRO_AUDIO_STREAM;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;

  LHandle := al_load_audio_stream_f(AFile, TpxUtils.AsUTF8(AExtension), 4, 2048);
  if not Assigned(LHandle) then Exit;

  UnloadMusic();

  FMusic := LHandle;

  al_set_audio_stream_playmode(FMusic, ALLEGRO_PLAYMODE_ONCE);
  al_attach_audio_stream_to_mixer(FMusic, TPixels.Mixer());
  al_set_audio_stream_playing(FMusic, False);

  AFile := nil;

  Result := True;
end;

class procedure TpxAudio.UnloadMusic();
begin
  if not al_is_audio_installed() then Exit;

  if Assigned(FMusic) then
  begin
    al_set_audio_stream_playing(FMusic, False);
    al_drain_audio_stream(FMusic);
    al_detach_audio_stream(FMusic);
    al_destroy_audio_stream(FMusic);
    FMusic := nil;
  end;
end;

class function TpxAudio.PlayMusic(const AVolume: Single; const AMode: TpxPlayMode): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  StopMusic();
  SetMusicPlayMode(AMode);
  SetMusicVolume(AVolume);
  al_rewind_audio_stream(FMusic);

  Result := SetMusicPlaying(True);
end;

class function TpxAudio.PlayMusic(var AFile: PpxFile; const AVolume: Single; const AMode: TpxPlayMode): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(AFile) then Exit;

  Result := LoadMusic(AFile, '.ogg');
  if Result then
    PlayMusic(AVolume, AMode);
end;

class function  TpxAudio.StopMusic(): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_set_audio_stream_playing(FMusic, False);
  if Result then
    al_rewind_audio_stream(FMusic);
end;

class function  TpxAudio.GetMusicPlayMode(): TpxPlayMode;
begin
  Result := pxPlayModeOnce;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := TpxPlayMode(al_get_audio_stream_playmode(FMusic));
end;

class function TpxAudio.SetMusicPlayMode(const AMode: TpxPlayMode): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_set_audio_stream_playmode(FMusic, _ALLEGRO_PLAYMODE_STREAM_ONEDIR{Ord(AMode)});
end;

class function  TpxAudio.IsMusicPlaying(): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;

  Result := al_get_audio_stream_playing(FMusic);
end;

class function  TpxAudio.SetMusicPlaying(const APlay: Boolean): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_set_audio_stream_playing(FMusic, aPlay);
end;

class function  TpxAudio.SetMusicVolume(const AVolume: Single): Boolean;
var
  LVolume: Single;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  LVolume := LogarithmicVolume(AVolume);
  Result := al_set_audio_stream_gain(FMusic, LVolume);
end;

class function  TpxAudio.GetMusicVolume(): Single;
begin
  Result := 0;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_get_audio_stream_gain(FMusic);
end;

class function  TpxAudio.SeekMusic(const ATime: Single): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_seek_audio_stream_secs(FMusic, ATime);
end;

class function  TpxAudio.RewindMusic(const ATime: Single): Boolean;
begin
  Result := False;
  if not Assigned(FMusic) then Exit;
  if not al_is_audio_installed() then Exit;

  Result := al_rewind_audio_stream(FMusic);
end;

class function  TpxAudio.ReserveSampleChannels(const ACount: UInt32): Boolean;
var
  LCount: Int32;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;

  LCount := EnsureRange(ACount, 0, CpxAUDIO_CHANNEL_COUNT);
  Result := al_reserve_samples(LCount);
end;

class function  TpxAudio.LoadSample(const AFile: PpxFile): PpxSample;
var
  LSample: PpxSample;
begin
  Result := Default(PpxSample);
  if not al_is_audio_installed() then Exit;
  if not Assigned(AFile) then Exit;

  LSample := al_load_sample_f(AFile, '.ogg');
  if not Assigned(LSample) then Exit;

  Result := LSample;
end;

class procedure TpxAudio.UnloadSample(var ASample: PpxSample);
begin
  if not al_is_audio_installed() then Exit;
  if not Assigned(ASample) then Exit;

  al_destroy_sample(ASample);
  ASample := nil;
end;

class function TpxAudio.PlaySample(const ASample: PpxSample; const AVolume, APan, ASpeed: Single; const AMode: TpxPlayMode; AId: PpxSampleID): Boolean;
var
  LID: ALLEGRO_SAMPLE_ID;
  LVolume: Single;
  LPan: Single;
  LSpeed: Single;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(ASample) then Exit;

  if Assigned(AId) then
  begin
    aId.Index := -1;
    aId.Id := -1;
  end;

  LVolume := LogarithmicVolume(AVolume);
  LPan := EnsureRange(APan, -1, 1);
  LSpeed := EnsureRange(ASpeed, 1, 2);

  if al_play_sample(ASample, LVolume, LPan, LSpeed, Ord(AMode), @LID) then
  begin
    if Assigned(aId) then
    begin
      aId.Index := LID._index;
      aId.Id := LID._id;
    end;
    Result := True;
  end;
end;

class procedure TpxAudio.StopSample(const AId: TpxSampleID);
var
  LId: ALLEGRO_SAMPLE_ID;
begin
  if not al_is_audio_installed() then Exit;

  if IsSamplePlaying(AId) then
  begin
    LId._index := AId.Index;
    LId._id := AId.Id;
    al_stop_sample(@LId);
  end;
end;

class procedure TpxAudio.StopAllSamples();
begin
  if not al_is_audio_installed() then Exit;

  al_stop_samples();
end;

class function  TpxAudio.IsSamplePlaying(const AId: TpxSampleID): Boolean;
var
  LInstance: PALLEGRO_SAMPLE_INSTANCE;
  LID: ALLEGRO_SAMPLE_ID;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;

  LID._index := aID.Index;
  LID._id := aID.Id;
  LInstance := al_lock_sample_id(@LID);
  if Assigned(LInstance) then
  begin
    Result := al_get_sample_instance_playing(LInstance);
    al_unlock_sample_id(@LID);
  end;
end;

end.
