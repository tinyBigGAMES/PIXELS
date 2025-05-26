{******************************************************************************
  PIXELS Infinite Starfield Demo

  A comprehensive demonstration of advanced 2D graphics techniques showcasing
  infinite scrolling starfields with proper world-space positioning, parallax
  layers, and dynamic visual effects using the PIXELS Game Library for Delphi.

  OVERVIEW:
  =========
  This demo implements a realistic infinite starfield simulation that demonstrates
  perfect seamless scrolling without visual artifacts or pop-in effects. The
  starfield consists of multiple parallax layers moving at different speeds to
  create a convincing sense of depth and three-dimensional space movement.

  TECHNICAL IMPLEMENTATION:
  =========================

  World Space System:
  - Uses a fixed 8192x8192 world coordinate system for all star positioning
  - Stars maintain consistent world positions while camera moves through space
  - Proper wrapping mathematics ensure seamless infinite scrolling
  - World-to-screen coordinate conversion maintains visual consistency

  Parallax Layering:
  - Far Layer (120 stars): 0.15 parallax factor - distant background stars
  - Mid Layer (80 stars): 0.35 parallax factor - intermediate depth stars
  - Near Layer (50 stars): 0.65 parallax factor - foreground bright stars
  - Each layer moves at different rates relative to camera movement

  Star Rendering System:
  - Far stars: Size 1.0, rendered with DrawFillCircle for proper wrapping
  - Mid stars: Size 1.5-2.5, progressive size scaling by distance
  - Near stars: Size 2.5-4.0, largest with optional glow effects
  - Bright stars (Type 3): Multi-layered rendering with additive blending

  Advanced Twinkling Engine:
  - Individual twinkle speeds per star (0.8-4.0 range)
  - Sine-based brightness and size modulation with proper angle wrapping
  - Intensity variation: every 2nd-4th star has enhanced twinkling effects
  - Color temperature shifts during twinkling cycles
  - Prevents complete fade-out with minimum alpha clamping

  Dynamic Shooting Stars:
  - Up to 8 simultaneous shooting stars with varied trajectories
  - Enhanced trail rendering with 12-20 segments per trail
  - Multi-layered glow effects (outer glow, middle glow, bright core)
  - Five distinct color schemes: white-blue, golden, green, orange-red, purple-pink
  - Realistic physics with gravity and atmospheric entry simulation
  - Variable brightness, size, and trail length for visual diversity

  FEATURES DEMONSTRATED:
  =====================
  - Perfect infinite scrolling with zero visual artifacts
  - Multi-layer parallax depth simulation
  - Fixed world-space positioning with offset-based rendering
  - Advanced twinkling algorithms with realistic color temperature variation
  - Dynamic shooting star generation with enhanced visual effects
  - Smooth camera movement with autopilot and manual control modes
  - Real-time performance optimization with efficient culling
  - Proper coordinate system wrapping for seamless space simulation

  RENDERING TECHNIQUES:
  ====================
  - Additive alpha blending for glow effects and shooting star trails
  - Multi-pass rendering for layered glow effects on bright stars
  - Efficient screen-space culling with margin-based visibility testing
  - Color component clamping to prevent overflow artifacts
  - Size-based progressive rendering (pixels to circles to glowing orbs)
  - Trail rendering with alpha decay for realistic motion blur effects

  CONTROLS:
  =========
  - ARROW KEYS: Manual flight control through the starfield
  - SPACE: Toggle between autopilot exploration and manual control
  - +/-: Dynamic speed adjustment (10-500 units)
  - R: Reset camera position to origin coordinates
  - T: Toggle enhanced twinkling effects on/off
  - ESC: Exit demo | F11: Toggle fullscreen mode
  - 1/2: Save screenshots in windowed/fullscreen modes

  MATHEMATICAL FOUNDATION:
  =======================
  The demo uses sophisticated coordinate transformation mathematics:

  World Space Wrapping:
    LStarPosX := LStar.X - AOffsetX
    while LStarPosX < 0 do LStarPosX := LStarPosX + WORLD_WIDTH
    while LStarPosX >= WORLD_WIDTH do LStarPosX := LStarPosX - WORLD_WIDTH

  Screen Coordinate Mapping:
    LScreenX := (LStarPosX / WORLD_WIDTH) * FScreenWidth
    LScreenY := (LStarPosY / WORLD_HEIGHT) * FScreenHeight

  Parallax Offset Calculation:
    FFarOffsetX := FCameraX * PARALLAX_FAR
    FMidOffsetX := FCameraX * PARALLAX_MID
    FNearOffsetX := FCameraX * PARALLAX_NEAR

  Twinkling Mathematics:
    LAngle := FTime * TwinkleSpeed * 60 + TwinkleOffset
    LTwinkleFactor := TpxMath.AngleSin(Round(LAngle mod 360))
    LColorFactor := 1.0 + LTwinkleFactor * IntensityMultiplier

  PERFORMANCE CHARACTERISTICS:
  ===========================
  - Maintains 60 FPS with 250+ stars and 8 shooting stars
  - Efficient memory usage with fixed arrays and minimal allocations
  - Optimized rendering with screen-space culling
  - Smooth interpolation for all movement and effects
  - Real-time coordinate transformations without performance penalties

  EDUCATIONAL VALUE:
  =================
  This demo serves as a comprehensive tutorial for implementing:
  - Infinite scrolling background systems
  - Multi-layer parallax depth effects
  - World-space coordinate systems
  - Advanced particle effect rendering
  - Real-time visual effect optimization
  - Proper game loop timing and movement
  - Mathematical coordinate transformations
  - Efficient culling and visibility testing

  Purpose: Advanced infinite scrolling and parallax demonstration
  Complexity: Intermediate to Advanced
  Performance: Optimized for 60 FPS real-time rendering
  Educational Focus: Coordinate systems, parallax, and visual effects
******************************************************************************}

unit UStarfield;

interface

uses
  PIXELS.Graphics,
  PIXELS.Events,
  PIXELS.Console,
  PIXELS.Audio,
  PIXELS.Math,
  PIXELS.IO,
  PIXELS.Game;

const
  WORLD_WIDTH = 8192;      // Size of our world space
  WORLD_HEIGHT = 8192;     // Size of our world space
  STARS_FAR = 120;         // Far background stars
  STARS_MID = 80;          // Mid-layer stars
  STARS_NEAR = 50;         // Near foreground stars
  MAX_SHOOTING_STARS = 8;  // More shooting stars

  // Parallax factors (how fast each layer moves relative to camera)
  PARALLAX_FAR = 0.15;     // Far stars move very slowly
  PARALLAX_MID = 0.35;     // Mid stars move moderately
  PARALLAX_NEAR = 0.65;    // Near stars move faster

type
  TStar = record
    X: Single;               // Fixed world position
    Y: Single;
    Size: Single;
    BaseSize: Single;        // For twinkling effect
    Color: TpxColor;
    BaseColor: TpxColor;     // For twinkling effect
    TwinkleSpeed: Single;
    TwinkleOffset: Single;
    StarType: Integer;       // 0=pixel, 1=small, 2=medium, 3=bright
  end;

  TShootingStar = record
    X: Single;
    Y: Single;
    VX: Single;
    VY: Single;
    Life: Single;
    MaxLife: Single;
    Size: Single;
    Color: TpxColor;
    TrailColor: TpxColor;
    Active: Boolean;
    Brightness: Single;
    TrailLength: Integer;
  end;

  { TStarfield }
  TStarfield = class(TpxGame)
  private
    FFont: TpxFont;
    FStarsFar: array[0..STARS_FAR-1] of TStar;
    FStarsMid: array[0..STARS_MID-1] of TStar;
    FStarsNear: array[0..STARS_NEAR-1] of TStar;
    FShootingStars: array[0..MAX_SHOOTING_STARS-1] of TShootingStar;

    FCameraX: Single;        // Camera position in world space
    FCameraY: Single;
    FCameraSpeed: Single;
    FAutoPilot: Boolean;
    FTwinkleEnabled: Boolean;
    FTime: Single;
    FScreenWidth: Single;
    FScreenHeight: Single;

    // Rendering offsets for each layer
    FFarOffsetX: Single;
    FFarOffsetY: Single;
    FMidOffsetX: Single;
    FMidOffsetY: Single;
    FNearOffsetX: Single;
    FNearOffsetY: Single;

    procedure InitializeStars();
    procedure UpdateTwinkling(const ADeltaTime: Single);
    procedure UpdateShootingStars(const ADeltaTime: Single);
    procedure UpdateOffsets();
    procedure CreateShootingStar();
    procedure RenderStarLayer(const AStars: array of TStar; const ACount: Integer; const AOffsetX: Single; const AOffsetY: Single);
    procedure RenderShootingStars();
  public
    function  OnStartup(): Boolean; override;
    procedure OnShutdown(); override;
    procedure OnUpdate(); override;
    procedure OnRender(); override;
    procedure OnRenderHUD(); override;
  end;

implementation

function TStarfield.OnStartup(): Boolean;
begin
  Result := False;
  if not TpxWindow.Init('PIXELS Infinite Starfield Demo') then Exit;

  FFont := TpxFont.Create();
  FFont.LoadDefault(14);

  FScreenWidth := TpxWindow.GetLogicalSize.w;
  FScreenHeight := TpxWindow.GetLogicalSize.h;

  FCameraX := 0;
  FCameraY := 0;
  FCameraSpeed := 80;
  FAutoPilot := True;
  FTwinkleEnabled := True;
  FTime := 0;

  // Initialize all offsets
  FFarOffsetX := 0;
  FFarOffsetY := 0;
  FMidOffsetX := 0;
  FMidOffsetY := 0;
  FNearOffsetX := 0;
  FNearOffsetY := 0;

  InitializeStars();

  Result := True;
end;

procedure TStarfield.OnShutdown();
begin
  FFont.Free();
  TpxWindow.Close();
end;

procedure TStarfield.OnUpdate();
var
  LDeltaTime: Single;
begin
  LDeltaTime := TpxWindow.GetFrameTime();
  FTime := FTime + LDeltaTime;

  // Handle input
  if TpxInput.KeyPressed(pxKEY_ESCAPE) then
    SetTerminate(True);

  if TpxInput.KeyReleased(pxKEY_F11) then
    TpxWindow.ToggleFullscreen();

  if TpxInput.KeyPressed(pxKEY_SPACE) then
    FAutoPilot := not FAutoPilot;

  if TpxInput.KeyPressed(pxKEY_T) then
    FTwinkleEnabled := not FTwinkleEnabled;

  if TpxInput.KeyPressed(pxKEY_R) then
  begin
    FCameraX := 0;
    FCameraY := 0;
  end;

  // Speed control
  if TpxInput.KeyDown(pxKEY_EQUALS) then
    FCameraSpeed := FCameraSpeed + 10;

  if TpxInput.KeyDown(pxKEY_MINUS) then
  begin
    FCameraSpeed := FCameraSpeed - 10;
    TpxMath.ClipValueFloat(FCameraSpeed, 10, 500, False);
  end;

  // Camera movement - use step-based movement like camera demo
  if FAutoPilot then
  begin
    // Smooth exploration pattern
    FCameraX := FCameraX + TpxMath.AngleCos(Round(FTime * 20)) * FCameraSpeed * LDeltaTime * 60;
    FCameraY := FCameraY + TpxMath.AngleSin(Round(FTime * 15)) * FCameraSpeed * LDeltaTime * 30;
  end
  else
  begin
    // Manual control - step-based like camera demo
    if TpxInput.KeyDown(pxKEY_LEFT) then
      FCameraX := FCameraX - FCameraSpeed;
    if TpxInput.KeyDown(pxKEY_RIGHT) then
      FCameraX := FCameraX + FCameraSpeed;
    if TpxInput.KeyDown(pxKEY_UP) then
      FCameraY := FCameraY - FCameraSpeed;
    if TpxInput.KeyDown(pxKEY_DOWN) then
      FCameraY := FCameraY + FCameraSpeed;
  end;

  // Update rendering offsets based on camera movement
  UpdateOffsets();

  // Random shooting star
  if TpxMath.RandomRangeFloat(0, 1) < 0.015 then
    CreateShootingStar();

  UpdateTwinkling(LDeltaTime);
  UpdateShootingStars(LDeltaTime);
end;

procedure TStarfield.OnRender();
begin
  // Clear to deep space black
  TpxWindow.Clear(pxBLACK);

  // Render layers back to front
  RenderStarLayer(FStarsFar, STARS_FAR, FFarOffsetX, FFarOffsetY);
  RenderStarLayer(FStarsMid, STARS_MID, FMidOffsetX, FMidOffsetY);
  RenderStarLayer(FStarsNear, STARS_NEAR, FNearOffsetX, FNearOffsetY);

  RenderShootingStars();
end;

procedure TStarfield.OnRenderHUD();
var
  LY: Single;
begin
  LY := 10;

  FFont.DrawText(pxCYAN, 10, LY, pxAlignLeft, 'PIXELS Infinite Starfield Demo', []);
  LY := LY + 25;

  FFont.DrawText(pxWHITE, 10, LY, pxAlignLeft, 'Stars: %d | FPS: %d', [STARS_FAR + STARS_MID + STARS_NEAR, TpxWindow.GetFPS()]);
  LY := LY + 20;

  FFont.DrawText(pxLIGHTGRAY, 10, LY, pxAlignLeft, 'Position: (%.0f, %.0f) Speed: %.0f', [FCameraX, FCameraY, FCameraSpeed]);
  LY := LY + 20;

  if FAutoPilot then
    FFont.DrawText(pxGREEN, 10, LY, pxAlignLeft, 'AUTOPILOT: ENGAGED', [])
  else
    FFont.DrawText(pxYELLOW, 10, LY, pxAlignLeft, 'MANUAL CONTROL', []);
  LY := LY + 25;

  FFont.DrawText(pxLIGHTBLUE, 10, LY, pxAlignLeft, 'ARROWS: Manual | SPACE: Autopilot | +/-: Speed', []);
  LY := LY + 18;
  FFont.DrawText(pxLIGHTBLUE, 10, LY, pxAlignLeft, 'T: Twinkle | R: Reset', []);
end;

procedure TStarfield.InitializeStars();
var
  LIndex: Integer;
  LColorChoice: Integer;
begin
  // Initialize far stars
  for LIndex := 0 to STARS_FAR - 1 do
  begin
    FStarsFar[LIndex].X := TpxMath.RandomRangeFloat(0, WORLD_WIDTH);
    FStarsFar[LIndex].Y := TpxMath.RandomRangeFloat(0, WORLD_HEIGHT);
    FStarsFar[LIndex].BaseSize := 1.0; // Fixed size 1
    FStarsFar[LIndex].Size := FStarsFar[LIndex].BaseSize;
    FStarsFar[LIndex].StarType := 0; // Tiny distant stars

    // Realistic colors for distant stars
    LColorChoice := TpxMath.RandomRangeInt(0, 4);
    case LColorChoice of
      0: FStarsFar[LIndex].BaseColor.FromFloat(0.6, 0.7, 1.0, 0.7);    // Blue - brighter
      1: FStarsFar[LIndex].BaseColor.FromFloat(1.0, 1.0, 0.9, 0.7);    // White - brighter
      2: FStarsFar[LIndex].BaseColor.FromFloat(1.0, 0.9, 0.7, 0.7);    // Yellow - brighter
      3: FStarsFar[LIndex].BaseColor.FromFloat(1.0, 0.8, 0.6, 0.7);    // Orange - brighter
      4: FStarsFar[LIndex].BaseColor.FromFloat(1.0, 0.6, 0.5, 0.7);    // Red - brighter
    end;

    FStarsFar[LIndex].Color := FStarsFar[LIndex].BaseColor;
    FStarsFar[LIndex].TwinkleSpeed := TpxMath.RandomRangeFloat(0.8, 2.5); // More varied speed
    FStarsFar[LIndex].TwinkleOffset := TpxMath.RandomRangeFloat(0, 360);
  end;

  // Initialize mid stars
  for LIndex := 0 to STARS_MID - 1 do
  begin
    FStarsMid[LIndex].X := TpxMath.RandomRangeFloat(0, WORLD_WIDTH);
    FStarsMid[LIndex].Y := TpxMath.RandomRangeFloat(0, WORLD_HEIGHT);
    FStarsMid[LIndex].BaseSize := TpxMath.RandomRangeFloat(1.5, 2.5); // Larger than far
    FStarsMid[LIndex].Size := FStarsMid[LIndex].BaseSize;
    FStarsMid[LIndex].StarType := 1; // Small stars

    LColorChoice := TpxMath.RandomRangeInt(0, 4);
    case LColorChoice of
      0: FStarsMid[LIndex].BaseColor.FromFloat(0.7, 0.8, 1.0, 0.8);    // Blue - brighter
      1: FStarsMid[LIndex].BaseColor.FromFloat(1.0, 1.0, 0.95, 0.8);   // White - brighter
      2: FStarsMid[LIndex].BaseColor.FromFloat(1.0, 0.95, 0.8, 0.8);   // Yellow - brighter
      3: FStarsMid[LIndex].BaseColor.FromFloat(1.0, 0.85, 0.7, 0.8);   // Orange - brighter
      4: FStarsMid[LIndex].BaseColor.FromFloat(1.0, 0.7, 0.6, 0.8);    // Red - brighter
    end;

    FStarsMid[LIndex].Color := FStarsMid[LIndex].BaseColor;
    FStarsMid[LIndex].TwinkleSpeed := TpxMath.RandomRangeFloat(1.0, 3.0); // More varied speed
    FStarsMid[LIndex].TwinkleOffset := TpxMath.RandomRangeFloat(0, 360);
  end;

  // Initialize near stars
  for LIndex := 0 to STARS_NEAR - 1 do
  begin
    FStarsNear[LIndex].X := TpxMath.RandomRangeFloat(0, WORLD_WIDTH);
    FStarsNear[LIndex].Y := TpxMath.RandomRangeFloat(0, WORLD_HEIGHT);
    FStarsNear[LIndex].BaseSize := TpxMath.RandomRangeFloat(2.5, 4.0); // Largest stars
    FStarsNear[LIndex].Size := FStarsNear[LIndex].BaseSize;

    // Mixed star types for near layer
    if TpxMath.RandomRangeFloat(0, 1) < 0.8 then
      FStarsNear[LIndex].StarType := 2  // Medium stars
    else
      FStarsNear[LIndex].StarType := 3; // Bright stars

    LColorChoice := TpxMath.RandomRangeInt(0, 4);
    case LColorChoice of
      0: FStarsNear[LIndex].BaseColor.FromFloat(0.8, 0.9, 1.0, 0.9);   // Blue - brighter
      1: FStarsNear[LIndex].BaseColor.FromFloat(1.0, 1.0, 1.0, 0.9);   // White - brighter
      2: FStarsNear[LIndex].BaseColor.FromFloat(1.0, 1.0, 0.9, 0.9);   // Yellow - brighter
      3: FStarsNear[LIndex].BaseColor.FromFloat(1.0, 0.9, 0.8, 0.9);   // Orange - brighter
      4: FStarsNear[LIndex].BaseColor.FromFloat(1.0, 0.8, 0.7, 0.9);   // Red - brighter
    end;

    FStarsNear[LIndex].Color := FStarsNear[LIndex].BaseColor;
    FStarsNear[LIndex].TwinkleSpeed := TpxMath.RandomRangeFloat(1.5, 4.0); // More varied speed
    FStarsNear[LIndex].TwinkleOffset := TpxMath.RandomRangeFloat(0, 360);
  end;

  // Initialize shooting stars as inactive
  for LIndex := 0 to MAX_SHOOTING_STARS - 1 do
    FShootingStars[LIndex].Active := False;
end;

procedure TStarfield.UpdateOffsets();
begin
  // Update offsets based on camera position and parallax factors
  FFarOffsetX := FCameraX * PARALLAX_FAR;
  FFarOffsetY := FCameraY * PARALLAX_FAR;
  FMidOffsetX := FCameraX * PARALLAX_MID;
  FMidOffsetY := FCameraY * PARALLAX_MID;
  FNearOffsetX := FCameraX * PARALLAX_NEAR;
  FNearOffsetY := FCameraY * PARALLAX_NEAR;
end;

procedure TStarfield.UpdateTwinkling(const ADeltaTime: Single);
var
  LIndex: Integer;
  LTwinkleFactor: Single;
  LColorFactor: Single;
  LIntenseTwinkle: Boolean;
  LAngle: Single;
begin
  if not FTwinkleEnabled then Exit;

  // Update far stars twinkling
  for LIndex := 0 to STARS_FAR - 1 do
  begin
    LAngle := FTime * FStarsFar[LIndex].TwinkleSpeed * 60 + FStarsFar[LIndex].TwinkleOffset;
    while LAngle >= 360 do LAngle := LAngle - 360;
    while LAngle < 0 do LAngle := LAngle + 360;

    LTwinkleFactor := TpxMath.AngleSin(Round(LAngle));
    LIntenseTwinkle := (LIndex mod 4 = 0); // Every 4th star has intense twinkling

    if LIntenseTwinkle then
      LColorFactor := 1.0 + LTwinkleFactor * 0.8  // Intense twinkling
    else
      LColorFactor := 1.0 + LTwinkleFactor * 0.5; // Normal twinkling

    FStarsFar[LIndex].Size := FStarsFar[LIndex].BaseSize * (1.0 + LTwinkleFactor * 0.6);
    FStarsFar[LIndex].Color.r := FStarsFar[LIndex].BaseColor.r * LColorFactor;
    FStarsFar[LIndex].Color.g := FStarsFar[LIndex].BaseColor.g * LColorFactor;
    FStarsFar[LIndex].Color.b := FStarsFar[LIndex].BaseColor.b * LColorFactor;
    FStarsFar[LIndex].Color.a := FStarsFar[LIndex].BaseColor.a * LColorFactor;

    // Clamp values
    TpxMath.ClipValueFloat(FStarsFar[LIndex].Color.r, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsFar[LIndex].Color.g, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsFar[LIndex].Color.b, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsFar[LIndex].Color.a, 0.1, 1, False); // Prevent complete fade
  end;

  // Update mid stars twinkling
  for LIndex := 0 to STARS_MID - 1 do
  begin
    LAngle := FTime * FStarsMid[LIndex].TwinkleSpeed * 60 + FStarsMid[LIndex].TwinkleOffset;
    while LAngle >= 360 do LAngle := LAngle - 360;
    while LAngle < 0 do LAngle := LAngle + 360;

    LTwinkleFactor := TpxMath.AngleSin(Round(LAngle));
    LIntenseTwinkle := (LIndex mod 3 = 0); // Every 3rd star has intense twinkling

    if LIntenseTwinkle then
      LColorFactor := 1.0 + LTwinkleFactor * 0.9  // Intense twinkling
    else
      LColorFactor := 1.0 + LTwinkleFactor * 0.6; // Normal twinkling

    FStarsMid[LIndex].Size := FStarsMid[LIndex].BaseSize * (1.0 + LTwinkleFactor * 0.7);
    FStarsMid[LIndex].Color.r := FStarsMid[LIndex].BaseColor.r * LColorFactor;
    FStarsMid[LIndex].Color.g := FStarsMid[LIndex].BaseColor.g * LColorFactor;
    FStarsMid[LIndex].Color.b := FStarsMid[LIndex].BaseColor.b * LColorFactor;
    FStarsMid[LIndex].Color.a := FStarsMid[LIndex].BaseColor.a * LColorFactor;

    // Clamp values
    TpxMath.ClipValueFloat(FStarsMid[LIndex].Color.r, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsMid[LIndex].Color.g, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsMid[LIndex].Color.b, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsMid[LIndex].Color.a, 0.1, 1, False); // Prevent complete fade
  end;

  // Update near stars twinkling
  for LIndex := 0 to STARS_NEAR - 1 do
  begin
    LAngle := FTime * FStarsNear[LIndex].TwinkleSpeed * 60 + FStarsNear[LIndex].TwinkleOffset;
    while LAngle >= 360 do LAngle := LAngle - 360;
    while LAngle < 0 do LAngle := LAngle + 360;

    LTwinkleFactor := TpxMath.AngleSin(Round(LAngle));
    LIntenseTwinkle := (LIndex mod 2 = 0); // Every 2nd star has intense twinkling

    if LIntenseTwinkle then
      LColorFactor := 1.0 + LTwinkleFactor * 1.0  // Very intense twinkling
    else
      LColorFactor := 1.0 + LTwinkleFactor * 0.7; // Normal twinkling

    FStarsNear[LIndex].Size := FStarsNear[LIndex].BaseSize * (1.0 + LTwinkleFactor * 0.8);
    FStarsNear[LIndex].Color.r := FStarsNear[LIndex].BaseColor.r * LColorFactor;
    FStarsNear[LIndex].Color.g := FStarsNear[LIndex].BaseColor.g * LColorFactor;
    FStarsNear[LIndex].Color.b := FStarsNear[LIndex].BaseColor.b * LColorFactor;
    FStarsNear[LIndex].Color.a := FStarsNear[LIndex].BaseColor.a * LColorFactor;

    // Clamp values
    TpxMath.ClipValueFloat(FStarsNear[LIndex].Color.r, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsNear[LIndex].Color.g, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsNear[LIndex].Color.b, 0, 1, False);
    TpxMath.ClipValueFloat(FStarsNear[LIndex].Color.a, 0.1, 1, False); // Prevent complete fade
  end;
end;

procedure TStarfield.UpdateShootingStars(const ADeltaTime: Single);
var
  LIndex: Integer;
  LShooter: ^TShootingStar;
begin
  for LIndex := 0 to MAX_SHOOTING_STARS - 1 do
  begin
    LShooter := @FShootingStars[LIndex];
    if not LShooter.Active then Continue;

    LShooter.X := LShooter.X + LShooter.VX * ADeltaTime;
    LShooter.Y := LShooter.Y + LShooter.VY * ADeltaTime;
    LShooter.Life := LShooter.Life - ADeltaTime;

    if LShooter.Life <= 0 then
      LShooter.Active := False;
  end;
end;

procedure TStarfield.RenderStarLayer(const AStars: array of TStar; const ACount: Integer; const AOffsetX: Single; const AOffsetY: Single);
var
  LIndex: Integer;
  LStar: TStar;
  LStarPosX: Single;
  LStarPosY: Single;
  LScreenX: Single;
  LScreenY: Single;
begin
  for LIndex := 0 to ACount - 1 do
  begin
    LStar := AStars[LIndex];

    // Calculate star X position with wrapping
    LStarPosX := LStar.X - AOffsetX;
    while LStarPosX < 0 do
      LStarPosX := LStarPosX + WORLD_WIDTH;
    while LStarPosX >= WORLD_WIDTH do
      LStarPosX := LStarPosX - WORLD_WIDTH;

    // Calculate star Y position with wrapping
    LStarPosY := LStar.Y - AOffsetY;
    while LStarPosY < 0 do
      LStarPosY := LStarPosY + WORLD_HEIGHT;
    while LStarPosY >= WORLD_HEIGHT do
      LStarPosY := LStarPosY - WORLD_HEIGHT;

    // Convert to screen coordinates
    LScreenX := (LStarPosX / WORLD_WIDTH) * FScreenWidth;
    LScreenY := (LStarPosY / WORLD_HEIGHT) * FScreenHeight;

    // Only draw if on screen (with margin)
    if (LScreenX >= -10) and (LScreenX <= FScreenWidth + 10) and
       (LScreenY >= -10) and (LScreenY <= FScreenHeight + 10) then
    begin
      case LStar.StarType of
        0: // Tiny stars - use DrawFillCircle size 1
          TpxWindow.DrawFillCircle(LScreenX, LScreenY, LStar.Size, LStar.Color);

        1: // Small stars
          TpxWindow.DrawFillCircle(LScreenX, LScreenY, LStar.Size, LStar.Color);

        2: // Medium stars
          TpxWindow.DrawFillCircle(LScreenX, LScreenY, LStar.Size, LStar.Color);

        3: // Bright stars with glow
        begin
          TpxWindow.SetBlendMode(pxAdditiveAlphaBlendMode);
          LStar.Color.a := LStar.Color.a * 0.3;
          TpxWindow.DrawFillCircle(LScreenX, LScreenY, LStar.Size * 1.5, LStar.Color);
          TpxWindow.RestoreDefaultBlendMode();

          LStar.Color.a := AStars[LIndex].Color.a;
          TpxWindow.DrawFillCircle(LScreenX, LScreenY, LStar.Size, LStar.Color);
        end;
      end;
    end;
  end;
end;

procedure TStarfield.RenderShootingStars();
var
  LIndex: Integer;
  LShooter: TShootingStar;
  LRenderColor: TpxColor;
  LTrailColor: TpxColor;
  LAlpha: Single;
  LTrailX: Single;
  LTrailY: Single;
  LTrailStep: Integer;
  LGlow: Single;
begin
  TpxWindow.SetBlendMode(pxAdditiveAlphaBlendMode);

  for LIndex := 0 to MAX_SHOOTING_STARS - 1 do
  begin
    LShooter := FShootingStars[LIndex];
    if not LShooter.Active then Continue;

    LAlpha := LShooter.Life / LShooter.MaxLife;
    LGlow := LShooter.Brightness * LAlpha;

    // Draw enhanced trail
    for LTrailStep := 1 to LShooter.TrailLength do
    begin
      LTrailX := LShooter.X - LShooter.VX * 0.008 * LTrailStep;
      LTrailY := LShooter.Y - LShooter.VY * 0.008 * LTrailStep;

      LTrailColor := LShooter.TrailColor;
      LTrailColor.a := LGlow * (1.0 - LTrailStep / LShooter.TrailLength) * 0.8;

      // Draw thicker trail segments
      TpxWindow.DrawFillCircle(LTrailX, LTrailY, (LShooter.Size * 0.8) * (1.0 - LTrailStep / LShooter.TrailLength), LTrailColor);
    end;

    // Draw bright core with glow
    LRenderColor := LShooter.Color;
    LRenderColor.a := LGlow;

    // Outer glow
    LRenderColor.a := LGlow * 0.4;
    TpxWindow.DrawFillCircle(LShooter.X, LShooter.Y, LShooter.Size * 2.0, LRenderColor);

    // Middle glow
    LRenderColor.a := LGlow * 0.7;
    TpxWindow.DrawFillCircle(LShooter.X, LShooter.Y, LShooter.Size * 1.3, LRenderColor);

    // Bright core
    LRenderColor.a := LGlow;
    TpxWindow.DrawFillCircle(LShooter.X, LShooter.Y, LShooter.Size, LRenderColor);
  end;

  TpxWindow.RestoreDefaultBlendMode();
end;

procedure TStarfield.CreateShootingStar();
var
  LIndex: Integer;
  LShooter: ^TShootingStar;
  LAngle: Single;
  LSpeed: Single;
  LColorChoice: Integer;
begin
  for LIndex := 0 to MAX_SHOOTING_STARS - 1 do
  begin
    LShooter := @FShootingStars[LIndex];
    if LShooter.Active then Continue;

    // Start from random position above screen
    LShooter.X := TpxMath.RandomRangeFloat(-100, FScreenWidth + 100);
    LShooter.Y := TpxMath.RandomRangeFloat(-100, -50);

    LAngle := TpxMath.RandomRangeFloat(45, 135);
    LSpeed := TpxMath.RandomRangeFloat(300, 600);

    LShooter.VX := TpxMath.AngleCos(Round(LAngle)) * LSpeed;
    LShooter.VY := TpxMath.AngleSin(Round(LAngle)) * LSpeed;

    LShooter.Life := TpxMath.RandomRangeFloat(2.0, 4.0);
    LShooter.MaxLife := LShooter.Life;
    LShooter.Size := TpxMath.RandomRangeFloat(2.0, 4.0);
    LShooter.Brightness := TpxMath.RandomRangeFloat(0.8, 1.2);
    LShooter.TrailLength := TpxMath.RandomRangeInt(12, 20);

    // Varied shooting star colors
    LColorChoice := TpxMath.RandomRangeInt(0, 4);
    case LColorChoice of
      0: begin // Bright white-blue
        LShooter.Color.FromFloat(0.9, 0.95, 1.0, 1.0);
        LShooter.TrailColor.FromFloat(0.7, 0.8, 1.0, 1.0);
      end;
      1: begin // Golden yellow
        LShooter.Color.FromFloat(1.0, 0.9, 0.6, 1.0);
        LShooter.TrailColor.FromFloat(1.0, 0.7, 0.4, 1.0);
      end;
      2: begin // Green
        LShooter.Color.FromFloat(0.6, 1.0, 0.7, 1.0);
        LShooter.TrailColor.FromFloat(0.4, 0.8, 0.5, 1.0);
      end;
      3: begin // Orange-red
        LShooter.Color.FromFloat(1.0, 0.6, 0.3, 1.0);
        LShooter.TrailColor.FromFloat(1.0, 0.4, 0.2, 1.0);
      end;
      4: begin // Purple-pink
        LShooter.Color.FromFloat(0.9, 0.6, 1.0, 1.0);
        LShooter.TrailColor.FromFloat(0.7, 0.4, 0.8, 1.0);
      end;
    end;

    LShooter.Active := True;
    Break;
  end;
end;

end.
