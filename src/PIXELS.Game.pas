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
  PIXELS.Base,
  PIXELS.Graphics;

type

  /// <summary>
  /// Class reference type for TpxGame descendants, used to specify which game class to instantiate when calling pxRunGame.
  /// </summary>
  /// <remarks>
  /// This metaclass type allows the PIXELS framework to create instances of your custom game class.
  /// You pass your game class (not an instance) to pxRunGame, which will create and manage the instance internally.
  /// </remarks>
  /// <seealso cref="pxRunGame"/>
  /// <seealso cref="TpxGame"/>
  TpxGameClass = class of TpxGame;

  /// <summary>
  /// Base class for all PIXELS games, providing the main game loop and lifecycle management.
  /// Inherit from this class to create your game and override the virtual methods to implement game logic.
  /// </summary>
  /// <remarks>
  /// TpxGame manages the complete game lifecycle including initialization, the main game loop, and cleanup.
  /// The framework runs at a locked 60 FPS by default and handles window management, input processing, and rendering.
  /// You must use pxRunGame to start your game - direct instantiation is not allowed.
  /// The game loop calls OnUpdate for logic updates and OnRender for drawing every frame.
  /// </remarks>
  /// <example>
  /// <code>
  /// type
  ///   TMyGame = class(TpxGame)
  ///   public
  ///     function OnStartup(): Boolean; override;
  ///     procedure OnUpdate(); override;
  ///     procedure OnRender(); override;
  ///   end;
  ///
  /// // Start the game
  /// pxRunGame(TMyGame);
  /// </code>
  /// </example>
  /// <seealso cref="pxRunGame"/>
  /// <seealso cref="TpxGameClass"/>
  TpxGame = class(TpxObject)
  private class var
    FAllowCreate: Boolean;
  private
   class procedure InternalRunGame(const AGame: TpxGameClass); static;
  protected
    FRunning: Boolean;
  public
    /// <summary>
    /// Creates a new game instance. This constructor is protected by the framework and should not be called directly.
    /// </summary>
    /// <remarks>
    /// Direct instantiation will raise an exception. Use pxRunGame to properly create and start your game.
    /// The framework controls game instance creation to ensure proper initialization order.
    /// </remarks>
    /// <exception cref="Exception">Raised if called directly instead of through pxRunGame</exception>
    /// <seealso cref="pxRunGame"/>
    constructor Create(); override;

    /// <summary>
    /// Destroys the game instance and releases resources.
    /// </summary>
    /// <remarks>
    /// Called automatically by the framework when the game terminates.
    /// Override OnShutdown for custom cleanup logic instead of overriding this destructor.
    /// </remarks>
    /// <seealso cref="OnShutdown"/>
    destructor Destroy(); override;

    /// <summary>
    /// Checks if the game has been marked for termination.
    /// </summary>
    /// <returns>True if the game should terminate, False if it should continue running</returns>
    /// <remarks>
    /// The game loop continues as long as this returns False. The game terminates when SetTerminate(True) is called
    /// or when the user closes the window. Check this in your game logic to handle graceful shutdown.
    /// </remarks>
    /// <seealso cref="SetTerminate"/>
    function  HasTerminated(): Boolean;

    /// <summary>
    /// Sets the game termination flag to control when the main game loop should exit.
    /// </summary>
    /// <param name="ATerminate">True to mark the game for termination, False to continue running</param>
    /// <remarks>
    /// Calling SetTerminate(True) will cause the main game loop to exit after the current frame completes.
    /// This provides a clean way to exit your game from within your game logic, such as when the player
    /// presses Escape or completes the game. OnShutdown will be called before the game actually terminates.
    /// </remarks>
    /// <example>
    /// <code>
    /// // In your OnUpdate method
    /// if TpxInput.KeyPressed(pxKEY_ESCAPE) then
    ///   SetTerminate(True);
    /// </code>
    /// </example>
    /// <seealso cref="HasTerminated"/>
    /// <seealso cref="OnShutdown"/>
    procedure SetTerminate(const ATerminate: Boolean);

    /// <summary>
    /// Starts and runs the main game loop. This method contains the complete game lifecycle.
    /// </summary>
    /// <remarks>
    /// Run manages the entire game execution: calls OnStartup for initialization, enters the main loop
    /// that calls OnUpdate and OnRender each frame, handles window events, and calls OnShutdown on exit.
    /// The game runs at 60 FPS by default with precise timing. This method blocks until the game terminates.
    /// You should not call this directly - use pxRunGame instead.
    /// </remarks>
    /// <seealso cref="pxRunGame"/>
    /// <seealso cref="OnStartup"/>
    /// <seealso cref="OnUpdate"/>
    /// <seealso cref="OnRender"/>
    /// <seealso cref="OnShutdown"/>
    procedure Run(); virtual;

    /// <summary>
    /// Called once when the game starts, before entering the main loop. Override to initialize your game.
    /// </summary>
    /// <returns>True if initialization succeeded and the game should start, False to abort startup</returns>
    /// <remarks>
    /// This is where you should load resources, initialize game objects, set up the game state, and create
    /// the game window. If you return False, the game will terminate immediately without entering the main loop.
    /// The PIXELS system is fully initialized when this is called, so all PIXELS functionality is available.
    /// </remarks>
    /// <example>
    /// <code>
    /// function TMyGame.OnStartup(): Boolean;
    /// begin
    ///   Result := TpxWindow.Init('My Game', 800, 600, True, True);
    ///   if not Result then Exit;
    ///
    ///   // Load resources, initialize game objects
    ///   LoadTextures();
    ///   InitializePlayer();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnShutdown"/>
    /// <seealso cref="Run"/>
    function  OnStartup(): Boolean; virtual;

    /// <summary>
    /// Called once when the game terminates, after exiting the main loop. Override for cleanup.
    /// </summary>
    /// <remarks>
    /// This is where you should free resources, save game state, and perform final cleanup.
    /// All PIXELS systems are still available when this is called, but the main loop has ended.
    /// This method is guaranteed to be called even if the game exits due to an error or window closure.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnShutdown();
    /// begin
    ///   SavePlayerProgress();
    ///   FreeGameResources();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnStartup"/>
    /// <seealso cref="Run"/>
    procedure OnShutdown(); virtual;

    /// <summary>
    /// Called every frame for game logic updates. Override to implement your game's update logic.
    /// </summary>
    /// <remarks>
    /// This method is called 60 times per second (at 60 FPS) before OnRender. Use this for game logic:
    /// update player positions, handle input, run AI, check collisions, update animations, etc.
    /// Keep this method efficient as it runs every frame. Heavy processing should be spread across multiple frames.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnUpdate();
    /// begin
    ///   UpdatePlayer();
    ///   UpdateEnemies();
    ///   CheckCollisions();
    ///   UpdateParticles();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnRender"/>
    /// <seealso cref="Run"/>
    procedure OnUpdate(); virtual;

    /// <summary>
    /// Called every frame for rendering graphics. Override to draw your game's visuals.
    /// </summary>
    /// <remarks>
    /// This method is called 60 times per second (at 60 FPS) after OnUpdate. Use this to draw all game graphics:
    /// backgrounds, sprites, effects, etc. The screen is automatically cleared before this is called.
    /// OnRenderHUD is called after this for UI elements. Keep rendering efficient for smooth 60 FPS performance.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnRender();
    /// begin
    ///   DrawBackground();
    ///   DrawGameObjects();
    ///   DrawParticles();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnRenderHUD"/>
    /// <seealso cref="OnUpdate"/>
    /// <seealso cref="Run"/>
    procedure OnRender(); virtual;

    /// <summary>
    /// Called every frame after OnRender for drawing user interface elements. Override to draw HUD/UI.
    /// </summary>
    /// <remarks>
    /// This method is called after OnRender specifically for UI elements that should appear on top of the game graphics:
    /// health bars, score displays, menus, debug information, etc. This separation helps organize rendering layers.
    /// UI elements drawn here will appear above everything drawn in OnRender.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnRenderHUD();
    /// begin
    ///   DrawHealthBar();
    ///   DrawScore();
    ///   DrawMiniMap();
    ///   if FShowDebug then DrawDebugInfo();
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnRender"/>
    /// <seealso cref="OnAfterRender"/>
    procedure OnRenderHUD(); virtual;

    /// <summary>
    /// Called every frame after all rendering is complete. Override for post-render processing.
    /// </summary>
    /// <remarks>
    /// This method is called after OnRender and OnRenderHUD, after the frame buffer has been presented to the screen.
    /// Use this for operations that should happen after rendering: screenshot capture, performance monitoring,
    /// or any processing that doesn't involve drawing. This is the last callback in the frame cycle.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnAfterRender();
    /// begin
    ///   if FCaptureScreenshot then
    ///   begin
    ///     TpxWindow.Save('screenshot.png');
    ///     FCaptureScreenshot := False;
    ///   end;
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OnRender"/>
    /// <seealso cref="OnRenderHUD"/>
    procedure OnAfterRender(); virtual;

    /// <summary>
    /// Called when video playback state changes. Override to handle video events.
    /// </summary>
    /// <param name="AState">The new video state (vsLoad, vsUnload, vsPlaying, vsPaused, vsFinished)</param>
    /// <param name="AFilename">The filename of the video file associated with this state change</param>
    /// <remarks>
    /// This callback is triggered by the TpxVideo system when video playback state changes.
    /// Use this to respond to video events: show UI when a video starts, hide UI when it ends,
    /// or transition to gameplay when a cutscene finishes.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnVideoState(const AState: TVideoState; const AFilename: string);
    /// begin
    ///   case AState of
    ///     vsPlaying: HideGameUI();
    ///     vsFinished: ShowGameUI();
    ///   end;
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="TpxVideo"/>
    procedure OnVideoState(const AState: TpxVideoState; const AFilename: string); virtual;

    /// <summary>
    /// Called during ZIP file building to report progress. Override to show progress feedback.
    /// </summary>
    /// <param name="AFilename">The name of the file currently being added to the ZIP archive</param>
    /// <param name="AProgress">Progress percentage (0-100) for the current file</param>
    /// <param name="ANewFile">True if this is the first progress report for this file, False for subsequent updates</param>
    /// <remarks>
    /// This callback is used by TpxFile.BuildZip to report compression progress. Override this to display
    /// progress bars, file lists, or other feedback during ZIP file creation. The progress is per-file,
    /// not overall archive progress.
    /// </remarks>
    /// <example>
    /// <code>
    /// procedure TMyGame.OnZipFileBuildProgress(const AFilename: string; const AProgress: Integer; const ANewFile: Boolean);
    /// begin
    ///   if ANewFile then
    ///     WriteLn('Adding: ', ExtractFileName(AFilename));
    ///   Write(#13'Progress: ', AProgress, '%');
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="TpxFile.BuildZip"/>
    procedure OnZipFileBuildProgress(const AFilename: string; const AProgress: Integer; const ANewFile: Boolean); virtual;
  end;


/// <summary>
/// Global reference to the currently running game instance, or nil if no game is active.
/// </summary>
/// <remarks>
/// This variable is automatically set by the framework when a game is started with pxRunGame
/// and cleared when the game terminates. You can use this to access the current game instance
/// from anywhere in your code, but be careful to check for nil. This is useful for global
/// callbacks that need to communicate with the game.
/// </remarks>
/// <seealso cref="TpxGame"/>
/// <seealso cref="pxRunGame"/>
var
  GGame: TpxGame = nil;

/// <summary>
/// Starts a PIXELS game by creating an instance of the specified game class and running it.
/// This is the main entry point for all PIXELS applications.
/// </summary>
/// <param name="AGame">The game class to instantiate and run (pass the class type, not an instance)</param>
/// <remarks>
/// This procedure handles the complete game lifecycle: creates an instance of your game class,
/// calls its Run method which manages the game loop, and cleans up when the game terminates.
/// The PIXELS framework must be initialized before calling this. This call blocks until the game exits.
/// You should call this from your main program file after any necessary initialization.
/// </remarks>
/// <example>
/// <code>
/// program MyGame;
/// uses
///   PIXELS.Game;
///
/// type
///   TMyGame = class(TpxGame)
///     // ... implement your game methods
///   end;
///
/// begin
///   pxRunGame(TMyGame);  // Start the game
/// end.
/// </code>
/// </example>
/// <seealso cref="TpxGame"/>
/// <seealso cref="TpxGameClass"/>
/// <seealso cref="GGame"/>
procedure pxRunGame(const AGame: TpxGameClass);

implementation

uses
  WinApi.Windows,
  System.SysUtils,
  System.IOUtils,
  PIXELS.Deps,
  PIXELS.Events,
  PIXELS.Audio,
  PIXELS.Console,
  PIXELS.Core;

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
        end;

        // Loose focus
        //ALLEGRO_EVENT_MOUSE_LEAVE_DISPLAY,
        ALLEGRO_EVENT_DISPLAY_SWITCH_OUT,
        ALLEGRO_EVENT_DISPLAY_LOST,
        ALLEGRO_EVENT_DISPLAY_HALT_DRAWING:
        begin
          //LPIXELS.Ready := False;
          TpxWindow.SetReady(False);
          TpxAudio.Pause(True);
          TpxVideo.SetPause(True);
        end;

        // Gain focus
        //ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY,
        ALLEGRO_EVENT_DISPLAY_SWITCH_IN,
        ALLEGRO_EVENT_DISPLAY_FOUND,
        ALLEGRO_EVENT_DISPLAY_RESUME_DRAWING:
        begin
          TpxWindow.SetReady(True);
          TpxAudio.Pause(False);
          TpxVideo.SetPause(False);
          TpxWindow.ResetTiming();
        end;

        ALLEGRO_EVENT_VIDEO_FINISHED:
        begin
          TpxVideo.OnFinished(PALLEGRO_VIDEO(TPixels.Event.user.data1));
        end;

        ALLEGRO_EVENT_VIDEO_FRAME_SHOW:
        begin
        end;
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

procedure TpxGame.OnVideoState(const AState: TpxVideoState; const AFilename: string);
begin
end;

procedure TpxGame.OnZipFileBuildProgress(const AFilename: string; const AProgress: Integer; const ANewFile: Boolean);
begin
  if aNewFile then TpxConsole.PrintLn();
  TpxConsole.Print(pxCR+'Adding %s(%d%%)...', [TPath.GetFileName(AFilename), aProgress]);
end;

{ pxRunGame }
procedure pxRunGame(const AGame: TpxGameClass);
begin
  TpxGame.InternalRunGame(AGame);
end;

end.
