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
  /// <summary>
  /// Maximum number of audio channels available for simultaneous sample playback.
  /// </summary>
  /// <remarks>
  /// This constant defines the upper limit for concurrent sample playback in the PIXELS audio system.
  /// Used internally by the audio reservation system and as a reference for capacity planning.
  /// </remarks>
  CpxAUDIO_CHANNEL_COUNT   = 16;

  /// <summary>
  /// Special constant indicating no panning should be applied to audio playback.
  /// </summary>
  /// <remarks>
  /// Use this value when you want audio to play without any left/right channel panning.
  /// Normal panning values range from -1.0 (full left) to 1.0 (full right), with 0.0 being center.
  /// This special value disables panning entirely.
  /// </remarks>
  CpxAUDIO_PAN_NONE        = -1000.0;

type
  /// <summary>
  /// Defines how audio samples and music should be played back.
  /// </summary>
  /// <remarks>
  /// These playback modes control the looping and repetition behavior of audio content.
  /// Different modes are appropriate for different types of audio (music vs sound effects).
  /// </remarks>
  TpxPlayMode = (
    /// <summary>Play the audio once and stop</summary>
    pmOnce     = ALLEGRO_PLAYMODE_ONCE,
    /// <summary>Loop the audio continuously until stopped</summary>
    pmLoop     = ALLEGRO_PLAYMODE_LOOP,
    /// <summary>Play forward, then backward, then forward again (ping-pong style)</summary>
    pmBiDir    = ALLEGRO_PLAYMODE_BIDIR,
    /// <summary>Play the audio once, then loop only a portion of it</summary>
    pmLoopOnce = ALLEGRO_PLAYMODE_LOOP_ONCE
  );

  /// <summary>
  /// Pointer type for audio sample data used in the PIXELS audio system.
  /// </summary>
  /// <remarks>
  /// This represents a loaded audio sample that can be played multiple times simultaneously.
  /// Samples are typically used for sound effects rather than background music.
  /// Manage sample lifetime carefully - load once and reuse, then unload when no longer needed.
  /// </remarks>
  PpxSample = type PALLEGRO_SAMPLE;

  /// <summary>
  /// Pointer type for TpxSampleID record.
  /// </summary>
  PpxSampleID = ^TpxSampleID;

  /// <summary>
  /// Unique identifier for tracking individual sample playback instances.
  /// </summary>
  /// <remarks>
  /// When a sample is played, this ID can be used to control that specific playback instance.
  /// Multiple instances of the same sample can play simultaneously, each with its own ID.
  /// Use this ID to stop, check status, or modify individual sample playbacks.
  /// </remarks>
  TpxSampleID = record
    /// <summary>Internal index component of the sample ID</summary>
    Index: Integer;
    /// <summary>Internal ID component for unique identification</summary>
    Id: Integer;
  end;

  /// <summary>
  /// Static class providing comprehensive audio management for music and sound effects in PIXELS.
  /// Handles music streaming, sample playback, volume control, and audio resource management.
  /// </summary>
  /// <remarks>
  /// TpxAudio manages two types of audio content:
  /// 1. Music - Streamed audio for background music (only one at a time)
  /// 2. Samples - Loaded sound effects that can play simultaneously
  ///
  /// The audio system supports various formats including OGG, WAV, and others.
  /// All audio operations are frame-rate independent and use logarithmic volume scaling
  /// for natural-sounding volume control. The system automatically handles mixing
  /// and provides spatial audio features like panning.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Play background music
  /// TpxAudio.PlayMusicFromDisk('music/background.ogg', 0.8, pmLoop);
  ///
  /// // Load and play a sound effect
  /// var LSample := TpxAudio.LoadSampleFromDisk('sounds/explosion.ogg', 1.0, pmOnce);
  /// var LId: TpxSampleID;
  /// TpxAudio.PlaySample(LSample, 1.0, 0.0, 1.0, pmOnce, @LId);
  /// </code>
  /// </example>
  TpxAudio = class(TpxStaticObject)
  protected class var
    FMusic: PALLEGRO_AUDIO_STREAM;
  private
    class function  PlayMusic(const AVolume: Single; const AMode: TpxPlayMode): Boolean; overload; static;
    class constructor Create();
    class destructor Destroy();
  public
    /// <summary>
    /// Pauses or resumes all audio playback including music and samples.
    /// </summary>
    /// <param name="APause">True to pause all audio, False to resume playback</param>
    /// <remarks>
    /// This affects all audio output from the PIXELS audio system. Useful for implementing
    /// game pause functionality or when the application loses focus. Paused audio will
    /// resume from where it left off when unpaused.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Pause all audio when game is paused
    /// TpxAudio.Pause(True);
    ///
    /// // Resume audio when game is unpaused
    /// TpxAudio.Pause(False);
    /// </code>
    /// </example>
    class procedure Pause(const APause: Boolean); static;

    /// <summary>
    /// Stops all audio playback and clears all loaded audio resources.
    /// </summary>
    /// <remarks>
    /// This method stops all currently playing music and samples, and releases all
    /// audio resources. Use this for cleanup when shutting down the audio system
    /// or when you need to completely reset the audio state.
    /// </remarks>
    class procedure Clear(); static;

    /// <summary>
    /// Loads music from an open file handle for later playback.
    /// </summary>
    /// <param name="AFile">Open file handle containing the music data (will be consumed and set to nil)</param>
    /// <param name="AExtension">File extension indicating the audio format (e.g., '.ogg', '.wav')</param>
    /// <returns>True if the music was loaded successfully, False otherwise</returns>
    /// <remarks>
    /// Only one music track can be loaded at a time. Loading new music will unload any
    /// previously loaded music. The file handle is consumed by this operation and will
    /// be set to nil. Music is streamed during playback to minimize memory usage.
    /// </remarks>
    /// <seealso cref="PlayMusicFromDisk"/>
    /// <seealso cref="UnloadMusic"/>
    class function  LoadMusic(var AFile: PpxFile; const AExtension: string): Boolean; static;

    /// <summary>
    /// Unloads the currently loaded music and releases its resources.
    /// </summary>
    /// <remarks>
    /// Stops music playback if currently playing and frees all associated memory.
    /// Always call this when you're done with music to prevent memory leaks.
    /// Loading new music automatically unloads previous music.
    /// </remarks>
    class procedure UnloadMusic(); static;

    /// <summary>
    /// Loads and immediately plays music from an open file handle.
    /// </summary>
    /// <param name="AFile">Open file handle containing the music data (will be consumed and set to nil)</param>
    /// <param name="AExtension">File extension indicating the audio format (e.g., '.ogg', '.wav')</param>
    /// <param name="AVolume">Playback volume from 0.0 (silent) to 1.0 (full volume)</param>
    /// <param name="AMode">Playback mode (once, loop, etc.)</param>
    /// <returns>True if the music was loaded and started successfully, False otherwise</returns>
    /// <remarks>
    /// This is a convenience method that combines LoadMusic and PlayMusic operations.
    /// The volume uses logarithmic scaling for natural sound perception.
    /// </remarks>
    /// <seealso cref="LoadMusic"/>
    class function  PlayMusic(var AFile: PpxFile; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean; overload; static;

    /// <summary>
    /// Loads and plays music from memory buffer.
    /// </summary>
    /// <param name="AMemory">Pointer to memory buffer containing the music data</param>
    /// <param name="ASize">Size of the memory buffer in bytes</param>
    /// <param name="AExtension">File extension indicating the audio format</param>
    /// <param name="AVolume">Playback volume from 0.0 to 1.0</param>
    /// <param name="AMode">Playback mode</param>
    /// <returns>True if successful, False otherwise</returns>
    /// <remarks>
    /// Useful for playing music embedded as resources or loaded from custom sources.
    /// The memory buffer must remain valid until the music is unloaded.
    /// </remarks>
    class function  PlayMusicFromMemory(const AMemory: Pointer; const ASize: Int64; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean; static;

    /// <summary>
    /// Loads and plays music from a disk file.
    /// </summary>
    /// <param name="AFilename">Path to the music file</param>
    /// <param name="AVolume">Playback volume from 0.0 to 1.0</param>
    /// <param name="AMode">Playback mode</param>
    /// <returns>True if successful, False otherwise</returns>
    /// <remarks>
    /// This is the most common way to play background music. The file extension
    /// is automatically detected from the filename. Supports common formats like
    /// OGG, WAV, MP3 (depending on Allegro build).
    /// </remarks>
    /// <example>
    /// <code>
    /// // Play looping background music at 80% volume
    /// TpxAudio.PlayMusicFromDisk('assets/background.ogg', 0.8, pmLoop);
    /// </code>
    /// </example>
    class function  PlayMusicFromDisk(const AFilename: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean; static;

    /// <summary>
    /// Loads and plays music from a file stored in a ZIP archive.
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP archive file</param>
    /// <param name="AFilename">Path to the music file within the ZIP archive</param>
    /// <param name="AVolume">Playback volume from 0.0 to 1.0</param>
    /// <param name="AMode">Playback mode</param>
    /// <param name="APassword">Password for the ZIP archive (uses default if not specified)</param>
    /// <returns>True if successful, False otherwise</returns>
    /// <remarks>
    /// Enables playing music from compressed archives, useful for asset packaging.
    /// The ZIP file must be accessible and the internal path must be correct.
    /// </remarks>
    class function  PlayMusicFromZip(const AZipFilename, AFilename: string; const AVolume: Single; const AMode: TpxPlayMode; const APassword: string=CpxDefaultZipPassword): Boolean;  static;

    /// <summary>
    /// Stops the currently playing music.
    /// </summary>
    /// <returns>True if music was stopped successfully, False if no music was playing</returns>
    /// <remarks>
    /// Stops playback and rewinds the music to the beginning. The music remains loaded
    /// and can be started again with SetMusicPlaying(True). Does not unload the music.
    /// </remarks>
    /// <seealso cref="SetMusicPlaying"/>
    /// <seealso cref="UnloadMusic"/>
    class function  StopMusic(): Boolean; static;

    /// <summary>
    /// Gets the current playback mode of the loaded music.
    /// </summary>
    /// <returns>The current TpxPlayMode of the music</returns>
    /// <remarks>
    /// Returns the playback mode that was set when the music started playing.
    /// If no music is loaded, returns pmOnce.
    /// </remarks>
    /// <seealso cref="SetMusicPlayMode"/>
    class function  GetMusicPlayMode(): TpxPlayMode; static;

    /// <summary>
    /// Sets the playback mode for the currently loaded music.
    /// </summary>
    /// <param name="AMode">New playback mode to apply</param>
    /// <returns>True if the mode was set successfully, False if no music is loaded</returns>
    /// <remarks>
    /// Changes how the music will behave when it reaches the end. Can be changed
    /// during playback to dynamically alter looping behavior.
    /// </remarks>
    class function  SetMusicPlayMode(const AMode: TpxPlayMode): Boolean; static;

    /// <summary>
    /// Checks if music is currently playing.
    /// </summary>
    /// <returns>True if music is actively playing, False if stopped or paused</returns>
    /// <remarks>
    /// This only indicates if music is actively producing audio. Paused music
    /// will return False even though it's loaded and ready to resume.
    /// </remarks>
    /// <seealso cref="SetMusicPlaying"/>
    class function  IsMusicPlaying(): Boolean; static;

    /// <summary>
    /// Starts or stops music playback without unloading.
    /// </summary>
    /// <param name="APlay">True to start playing, False to stop</param>
    /// <returns>True if the operation was successful, False if no music is loaded</returns>
    /// <remarks>
    /// Unlike StopMusic(), this doesn't rewind the music position. Stopping and
    /// restarting will continue from where it left off. Useful for pause/resume functionality.
    /// </remarks>
    /// <seealso cref="StopMusic"/>
    class function  SetMusicPlaying(const APlay: Boolean): Boolean; static;

    /// <summary>
    /// Sets the volume of the currently playing music.
    /// </summary>
    /// <param name="AVolume">Volume level from 0.0 (silent) to 1.0 (full volume)</param>
    /// <returns>True if the volume was set successfully, False if no music is loaded</returns>
    /// <remarks>
    /// Uses logarithmic volume scaling for natural sound perception. Volume changes
    /// take effect immediately. Values outside 0.0-1.0 are automatically clamped.
    /// </remarks>
    /// <seealso cref="GetMusicVolume"/>
    class function  SetMusicVolume(const AVolume: Single): Boolean; static;

    /// <summary>
    /// Gets the current volume of the music.
    /// </summary>
    /// <returns>Current volume level from 0.0 to 1.0, or 0.0 if no music is loaded</returns>
    /// <remarks>
    /// Returns the current volume setting. This reflects the logarithmically-scaled
    /// volume value that was set, not the raw audio gain.
    /// </remarks>
    /// <seealso cref="SetMusicVolume"/>
    class function  GetMusicVolume(): Single; static;

    /// <summary>
    /// Seeks to a specific time position in the currently playing music.
    /// </summary>
    /// <param name="ATime">Time position in seconds to seek to</param>
    /// <returns>True if seeking was successful, False otherwise</returns>
    /// <remarks>
    /// Jumps to the specified time position in the music track. Not all audio
    /// formats support seeking. The time is measured from the beginning of the track.
    /// </remarks>
    /// <seealso cref="RewindMusic"/>
    class function  SeekMusic(const ATime: Single): Boolean; static;

    /// <summary>
    /// Rewinds the music to the beginning.
    /// </summary>
    /// <param name="ATime">Reserved parameter (not used)</param>
    /// <returns>True if rewinding was successful, False otherwise</returns>
    /// <remarks>
    /// Sets the music playback position back to the start of the track.
    /// The music continues playing from the beginning if it was already playing.
    /// </remarks>
    /// <seealso cref="SeekMusic"/>
    class function  RewindMusic(const ATime: Single): Boolean; static;

    /// <summary>
    /// Reserves a specific number of audio channels for sample playback.
    /// </summary>
    /// <param name="ACount">Number of channels to reserve (0 to CpxAUDIO_CHANNEL_COUNT)</param>
    /// <returns>True if the channels were reserved successfully, False otherwise</returns>
    /// <remarks>
    /// Allocates audio mixing channels for simultaneous sample playback. More channels
    /// allow more sounds to play at once but use more system resources. The count is
    /// automatically clamped to the maximum supported by the system.
    /// </remarks>
    class function  ReserveSampleChannels(const ACount: UInt32): Boolean; static;

    /// <summary>
    /// Loads an audio sample from an open file handle.
    /// </summary>
    /// <param name="AFile">Open file handle containing the sample data</param>
    /// <returns>Pointer to the loaded sample, or nil if loading failed</returns>
    /// <remarks>
    /// Loads the entire audio file into memory for fast playback. Unlike music,
    /// samples are fully loaded and can play multiple instances simultaneously.
    /// The file handle is consumed by this operation. Remember to unload samples
    /// when no longer needed to free memory.
    /// </remarks>
    /// <seealso cref="UnloadSample"/>
    class function  LoadSample(const AFile: PpxFile): PpxSample; static;

    /// <summary>
    /// Loads an audio sample from a memory buffer.
    /// </summary>
    /// <param name="AMemory">Pointer to memory buffer containing the sample data</param>
    /// <param name="ASize">Size of the memory buffer in bytes</param>
    /// <param name="AExtension">File extension indicating the audio format</param>
    /// <param name="AVolume">Default volume for this sample (0.0 to 1.0)</param>
    /// <param name="AMode">Default playback mode for this sample</param>
    /// <returns>Pointer to the loaded sample, or nil if loading failed</returns>
    /// <remarks>
    /// Loads sample data from memory rather than a file. Useful for embedded
    /// resources or custom audio sources. The volume and mode parameters set
    /// defaults but can be overridden when playing the sample.
    /// </remarks>
    class function  LoadSampleMemory(const AMemory: Pointer; const ASize: Int64; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): PpxSample; static;

    /// <summary>
    /// Loads an audio sample from a disk file.
    /// </summary>
    /// <param name="AFilename">Path to the sample file</param>
    /// <param name="AVolume">Default volume for this sample (0.0 to 1.0)</param>
    /// <param name="AMode">Default playback mode for this sample</param>
    /// <returns>Pointer to the loaded sample, or nil if loading failed</returns>
    /// <remarks>
    /// This is the most common way to load sound effects. The entire file is
    /// loaded into memory for fast, low-latency playback. Ideal for short
    /// audio clips like sound effects.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LExplosion := TpxAudio.LoadSampleFromDisk('sounds/explosion.ogg', 1.0, pmOnce);
    /// </code>
    /// </example>
    class function  LoadSampleFromDisk(const AFilename: string; const AVolume: Single; const AMode: TpxPlayMode): PpxSample; static;

    /// <summary>
    /// Loads an audio sample from a file stored in a ZIP archive.
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP archive file</param>
    /// <param name="AFilename">Path to the sample file within the ZIP archive</param>
    /// <param name="AVolume">Default volume for this sample (0.0 to 1.0)</param>
    /// <param name="AMode">Default playback mode for this sample</param>
    /// <param name="APassword">Password for the ZIP archive (uses default if not specified)</param>
    /// <returns>Pointer to the loaded sample, or nil if loading failed</returns>
    /// <remarks>
    /// Enables loading samples from compressed archives, useful for organizing
    /// and distributing game assets efficiently.
    /// </remarks>
    class function  LoadSampleZip(const AZipFilename, AFilename: string; const AVolume: Single; const AMode: TpxPlayMode; const APassword: string=CpxDefaultZipPassword): PpxSample;  static;

    /// <summary>
    /// Unloads a sample and frees its memory.
    /// </summary>
    /// <param name="ASample">Sample to unload (will be set to nil)</param>
    /// <remarks>
    /// Releases the memory used by the sample. Any currently playing instances
    /// of this sample will continue to play, but no new instances can be started.
    /// Always unload samples when no longer needed to prevent memory leaks.
    /// The sample pointer is set to nil after unloading.
    /// </remarks>
    class procedure UnloadSample(var ASample: PpxSample); static;

    /// <summary>
    /// Plays a loaded sample with specified audio parameters.
    /// </summary>
    /// <param name="ASample">Sample to play</param>
    /// <param name="AVolume">Playback volume (0.0 to 1.0)</param>
    /// <param name="APan">Stereo panning (-1.0 = full left, 0.0 = center, 1.0 = full right)</param>
    /// <param name="ASpeed">Playback speed (1.0 = normal, 2.0 = double speed, etc.)</param>
    /// <param name="AMode">Playback mode</param>
    /// <param name="AId">Optional pointer to receive the sample instance ID for later control</param>
    /// <returns>True if the sample started playing successfully, False otherwise</returns>
    /// <remarks>
    /// Starts playing the sample immediately. Multiple instances of the same sample
    /// can play simultaneously. The ID parameter allows you to control the specific
    /// playback instance later (stop, check status, etc.). Speed changes also affect pitch.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LId: TpxSampleID;
    /// TpxAudio.PlaySample(LExplosion, 0.8, 0.0, 1.0, pmOnce, @LId);
    /// </code>
    /// </example>
    class function  PlaySample(const ASample: PpxSample; const AVolume, APan, ASpeed: Single; const AMode: TpxPlayMode; AId: PpxSampleID): Boolean; static;

    /// <summary>
    /// Stops a specific sample instance identified by its ID.
    /// </summary>
    /// <param name="AId">ID of the sample instance to stop</param>
    /// <remarks>
    /// Stops only the specific sample instance identified by the ID. Other instances
    /// of the same sample continue playing. The ID must be obtained from PlaySample().
    /// </remarks>
    /// <seealso cref="PlaySample"/>
    /// <seealso cref="IsSamplePlaying"/>
    class procedure StopSample(const AId: TpxSampleID); static;

    /// <summary>
    /// Immediately stops all currently playing samples.
    /// </summary>
    /// <remarks>
    /// Stops all sample playback across all channels. This does not affect music playback.
    /// Useful for implementing "quiet" modes or when transitioning between game states.
    /// </remarks>
    class procedure StopAllSamples(); static;

    /// <summary>
    /// Checks if a specific sample instance is currently playing.
    /// </summary>
    /// <param name="AId">ID of the sample instance to check</param>
    /// <returns>True if the sample instance is still playing, False if it has stopped or finished</returns>
    /// <remarks>
    /// Use this to determine if a specific sample playback is still active.
    /// The ID must be obtained from PlaySample(). Returns False for invalid or expired IDs.
    /// </remarks>
    /// <seealso cref="PlaySample"/>
    /// <seealso cref="StopSample"/>
    class function  IsSamplePlaying(const AId: TpxSampleID): Boolean; static;
  end;

implementation

uses
  System.Math,
  System.IOUtils,
  PIXELS.Utils,
  PIXELS.Core;

{ TpxAudio }
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

class function  TpxAudio.PlayMusic(var AFile: PpxFile; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean;
begin
  Result := False;
  if not LoadMusic(AFile, AExtension) then Exit;
  Result := PlayMusic(AVolume, AMode);
end;

class function  TpxAudio.PlayMusicFromMemory(const AMemory: Pointer; const ASize: Int64; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;

  LFile := TpxFile.OpenMemory(AMemory, ASize, 'rb');
  if not Assigned(LFile) then Exit;

  Result := PlayMusic(LFile, AExtension, AVolume, AMode);
end;

class function  TpxAudio.PlayMusicFromDisk(const AFilename: string; const AVolume: Single; const AMode: TpxPlayMode): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  LFile := TpxFile.OpenDisk(AFilename, 'rb');
  if not Assigned(LFile) then Exit;

  Result := PlayMusic(LFile, TPath.GetExtension(AFilename), AVolume, AMode);
end;

class function  TpxAudio.PlayMusicFromZip(const AZipFilename, AFilename: string; const AVolume: Single; const AMode: TpxPlayMode; const APassword: string): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  LFile := TpxFile.OpenZip(AZipFilename, AFilename, APassword);
  if not Assigned(LFile) then Exit;

  Result := PlayMusic(LFile, TPath.GetExtension(AFilename), AVolume, AMode);
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
  Result := pmOnce;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := TpxPlayMode(al_get_audio_stream_playmode(FMusic));
end;

class function TpxAudio.SetMusicPlayMode(const AMode: TpxPlayMode): Boolean;
begin
  Result := False;
  if not al_is_audio_installed() then Exit;
  if not Assigned(FMusic) then Exit;

  Result := al_set_audio_stream_playmode(FMusic, Ord(AMode));
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

  LVolume := TpxUtils.LogarithmicVolume(AVolume);
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

class function  TpxAudio.LoadSampleMemory(const AMemory: Pointer; const ASize: Int64; const AExtension: string; const AVolume: Single; const AMode: TpxPlayMode): PpxSample;
var
  LFile: PpxFile;
begin
  Result := nil;

  LFile := TpxFile.OpenMemory(AMemory, ASize, 'rb');
  if not Assigned(LFile) then Exit;
  try
    Result := LoadSample(LFile);
  finally
    TpxFile.Close(LFile);
  end;
end;

class function  TpxAudio.LoadSampleFromDisk(const AFilename: string; const AVolume: Single; const AMode: TpxPlayMode): PpxSample;
var
  LFile: PpxFile;
begin
  Result := nil;

  LFile := TpxFile.OpenDisk(AFilename, 'rb');
  if not Assigned(LFile) then Exit;
  try
    Result := LoadSample(LFile);
  finally
    TpxFile.Close(LFile);
  end;
end;

class function  TpxAudio.LoadSampleZip(const AZipFilename, AFilename: string; const AVolume: Single; const AMode: TpxPlayMode; const APassword: string): PpxSample;
var
  LFile: PpxFile;
begin
  Result := nil;

  LFile := TpxFile.OpenZip(AZipFilename, AFilename, APassword);
  if not Assigned(LFile) then Exit;
  try
    Result := LoadSample(LFile);
  finally
    TpxFile.Close(LFile);
  end;
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

  LVolume := TpxUtils.LogarithmicVolume(AVolume);
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
