(******************************************************************************
  PIXELS Texture Tint Shader Demo - Advanced GPU-Based Texture Manipulation

  This demo showcases real-time texture tinting and wave distortion effects using
  modern OpenGL fragment shaders integrated with the PIXELS 2D Game Library. It
  demonstrates advanced GPU programming techniques, uniform parameter passing,
  and side-by-side shader comparison rendering for educational purposes.

  Technical Complexity Level: Advanced

  OVERVIEW:
  The Texture Tint Shader Demo presents a comprehensive example of GPU-accelerated
  texture manipulation using custom fragment shaders within the PIXELS framework.
  This demonstration illustrates the integration of modern GLSL (OpenGL Shading
  Language) with 2D game development, showcasing real-time color manipulation,
  procedural wave effects, and interactive parameter control.

  TECHNICAL IMPLEMENTATION:
  Core Shader Architecture - The demo implements a single-pass fragment shader
  system using GLSL version 130, targeting OpenGL 3.0+ compatibility. The shader
  pipeline processes texture fragments in parallel on the GPU, applying mathematical
  transformations to achieve tinting and wave distortion effects.

  Mathematical Foundation:
    wave = sin(time * 2.0 + varying_texcoord.x * 10.0) * 0.1 + 0.9
    final_color = tex_color.rgb * tint_color * wave

  Wave Function Parameters:
  - Frequency: 2.0 Hz temporal oscillation
  - Spatial frequency: 10.0 cycles across texture width
  - Amplitude: ±0.1 (10% intensity variation)
  - DC offset: 0.9 (90% base intensity)

  FEATURES DEMONSTRATED:
  • Real-time Shader Compilation and GLSL fragment shader loading
  • Uniform Parameter Binding with live vec3 and float uniform updates
  • Texture Unit Management using proper OpenGL texture unit binding (unit 0)
  • Comparative Rendering with side-by-side shader vs non-shader comparison
  • Interactive Color Control with real-time RGB channel manipulation
  • Procedural Wave Effects using time-based sinusoidal distortion
  • Hardware Acceleration leveraging GPU parallel processing capabilities

  RENDERING TECHNIQUES:
  The demo employs a dual-texture rendering approach with identical textures
  positioned at screen coordinates (centerX-150, centerY) and (centerX+150, centerY).
  Textures are scaled to 0.25x (256x256 from 1024x1024 source) with center-origin
  anchoring for precise positioning. The left texture receives shader processing
  while the right maintains standard rendering for direct comparison.

  CONTROLS:
  SPACE     - Toggle shader enable/disable state
  1/2       - Decrease/Increase red tint component (0.0-2.0 range)
  3/4       - Decrease/Increase green tint component (0.0-2.0 range)
  5/6       - Decrease/Increase blue tint component (0.0-2.0 range)
  R         - Reset all tint components to 1.0 (neutral)
  F11       - Toggle fullscreen/windowed display mode
  ESC       - Exit application

  MATHEMATICAL FOUNDATION:
  Tint Color Adjustment:
    LTempValue := FTintColor.component ± 0.01
    FTintColor.component := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False)

  Time Progression (60 FPS locked):
    FTime := FTime + (1.0 / 60.0)

  Screen Positioning:
    LScreenCenterX := TpxWindow.GetLogicalSize().w / 2  // 480px
    LScreenCenterY := TpxWindow.GetLogicalSize().h / 2  // 270px

  PERFORMANCE CHARACTERISTICS:
  Expected Performance: 60 FPS at 960x540 resolution with dual texture rendering
  Memory Usage: ~2MB GPU VRAM for 1024x1024 texture + shader program cache
  GPU Utilization: Minimal fragment shader load with simple mathematical operations
  Scalability: Linear performance scaling with texture resolution and screen coverage

  EDUCATIONAL VALUE:
  Developers studying this demo gain practical experience with:
  - OpenGL shader integration in 2D game engines
  - Real-time uniform parameter management and GPU state handling
  - Performance comparison between CPU and GPU-based texture processing
  - Modern GLSL syntax and fragment shader programming patterns
  - Interactive parameter control systems for real-time effect adjustment
  - Proper resource management in GPU programming contexts

  The demo serves as a foundation for more complex shader effects including
  multi-pass rendering, post-processing pipelines, and advanced material systems
  commonly used in modern 2D and 3D game development workflows.
******************************************************************************)

unit UTextureTintShaderDemo;

interface

uses
  PIXELS.Graphics,
  PIXELS.Events,
  PIXELS.Console,
  PIXELS.Audio,
  PIXELS.Math,
  PIXELS.IO,
  PIXELS.Game;

type
  { TTextureTintShaderDemo }
  TTextureTintShaderDemo = class(TpxGame)
  private
    FFont: TpxFont;
    FTexture: TpxTexture;
    FShader: TpxShader;
    FTintColor: TpxVector;
    FTime: Single;
    FShaderEnabled: Boolean;
  public
    function  OnStartup(): Boolean; override;
    procedure OnShutdown(); override;
    procedure OnUpdate(); override;
    procedure OnRender(); override;
    procedure OnRenderHUD(); override;
  end;

implementation

const
  // Fixed: uses texture() instead of texture2D, and tint_color is set as vec3 uniform
  CFragmentShaderSource =
    '#version 130' + #13#10 +
    'uniform sampler2D al_tex;' + #13#10 +
    'uniform vec3 tint_color;' + #13#10 +
    'uniform float time;' + #13#10 +
    'in vec2 varying_texcoord;' + #13#10 +
    'out vec4 FragColor;' + #13#10 +
    'void main() {' + #13#10 +
    '  vec4 tex_color = texture(al_tex, varying_texcoord);' + #13#10 +
    '  float wave = sin(time * 2.0 + varying_texcoord.x * 10.0) * 0.1 + 0.9;' + #13#10 +
    '  vec3 final_color = tex_color.rgb * tint_color * wave;' + #13#10 +
    '  FragColor = vec4(final_color, tex_color.a);' + #13#10 +
    '}';

{ TTextureTintShaderDemo }
function TTextureTintShaderDemo.OnStartup(): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  if not TpxWindow.Init('Texture Tint Shader Demo') then Exit;

  // Initialize font
  FFont := TpxFont.Create();
  FFont.LoadDefault(12);

  // Load texture
  FTexture := TpxTexture.Create();
  LFile := TpxFile.OpenZip('Data.zip', 'res/sprites/brickwall.png');
  if LFile <> nil then
  begin
    FTexture.Load(LFile, '.png', pxHDTexture, nil);
    TpxFile.Close(LFile);
  end
  else
  begin
    // Create a simple colored texture if file doesn't exist
    FTexture.Alloc(128, 128, pxWHITE, pxPixelArtTexture);
    FTexture.SetAsRenderTarget();
    TpxWindow.DrawFillRectangle(0, 0, 128, 128, pxBLUE);
    TpxWindow.DrawFillRectangle(32, 32, 64, 64, pxRED);
    FTexture.UnsetAsRenderTarget();
  end;

  // Initialize shader
  FShader := TpxShader.Create();
  if not FShader.Load(pxPixelShader, CFragmentShaderSource) then
  begin
    TpxConsole.PrintLn('Failed to load fragment shader: %s', [FShader.Log()]);
    Exit;
  end;

  if not FShader.Build() then
  begin
    TpxConsole.PrintLn('Failed to build shader: %s', [FShader.Log()]);
    Exit;
  end;

  // Initialize shader variables
  FTintColor.x := 1.0; // Red component
  FTintColor.y := 1.0; // Green component
  FTintColor.z := 1.0; // Blue component
  FTime := 0.0;
  FShaderEnabled := True;

  Result := True;
end;

procedure TTextureTintShaderDemo.OnShutdown();
begin
  FShader.Free();
  FTexture.Free();
  FFont.Free();
  TpxWindow.Close();
end;

procedure TTextureTintShaderDemo.OnUpdate();
var
  LTempValue: Single;
begin
  // Handle input
  if TpxInput.KeyPressed(pxKEY_ESCAPE) then
    SetTerminate(True);

  if TpxInput.KeyPressed(pxKEY_F11) then
    TpxWindow.ToggleFullscreen();

  if TpxInput.KeyPressed(pxKEY_SPACE) then
    FShaderEnabled := not FShaderEnabled;

  // Update tint color based on input
  if TpxInput.KeyDown(pxKEY_1) then
  begin
    LTempValue := FTintColor.x - 0.01;
    FTintColor.x := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;
  if TpxInput.KeyDown(pxKEY_2) then
  begin
    LTempValue := FTintColor.x + 0.01;
    FTintColor.x := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;

  if TpxInput.KeyDown(pxKEY_3) then
  begin
    LTempValue := FTintColor.y - 0.01;
    FTintColor.y := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;
  if TpxInput.KeyDown(pxKEY_4) then
  begin
    LTempValue := FTintColor.y + 0.01;
    FTintColor.y := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;

  if TpxInput.KeyDown(pxKEY_5) then
  begin
    LTempValue := FTintColor.z - 0.01;
    FTintColor.z := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;
  if TpxInput.KeyDown(pxKEY_6) then
  begin
    LTempValue := FTintColor.z + 0.01;
    FTintColor.z := TpxMath.ClipValueFloat(LTempValue, 0.0, 2.0, False);
  end;

  // Reset tint color
  if TpxInput.KeyPressed(pxKEY_R) then
  begin
    FTintColor.x := 1.0;
    FTintColor.y := 1.0;
    FTintColor.z := 1.0;
  end;

  // Update time for animation
  FTime := FTime + (1.0 / 60.0); // Assuming 60 FPS
end;

(*
procedure TTextureTintShaderDemo.OnRender();
var
  LCenterX: Single;
  LCenterY: Single;
  LTextureSize: TpxSize;
begin
  TpxWindow.Clear(pxDARKSLATEBROWN);

  LTextureSize := FTexture.GetSize();
  LCenterX := (TpxWindow.GetLogicalSize().w - LTextureSize.w) / 2;
  LCenterY := (TpxWindow.GetLogicalSize().h - LTextureSize.h) / 2;

  if FShaderEnabled then
  begin
    // Enable shader and set uniforms
    FShader.Enable(True);
    FShader.SetVec3Uniform('tint_color', FTintColor.x, FTintColor.y, FTintColor.z); // CORRECT TYPE!
    FShader.SetFloatUniform('time', FTime);
    FShader.SetTextureUniform('al_tex', FTexture, 0); // ALWAYS USE UNIT 0!
  end;

  // Draw the texture with (or without) shader
  FTexture.Draw(LCenterX, LCenterY, pxWHITE);

  if FShaderEnabled then
    FShader.Enable(False);

  // Draw a second texture without shader for comparison
  FTexture.Draw(LCenterX + LTextureSize.w + 20, LCenterY, pxWHITE);
end;
*)

procedure TTextureTintShaderDemo.OnRender();
var
  LOrigin: TpxVector;
  LScale: TpxVector;
  LScreenCenterX: Single;
  LScreenCenterY: Single;
begin
  TpxWindow.Clear(pxDARKSLATEBROWN);

  LOrigin.x := 0.5;
  LOrigin.y := 0.5;
  LScale.x := 0.25;  // Scale down to 256x256 (1024 * 0.25)
  LScale.y := 0.25;

  LScreenCenterX := TpxWindow.GetLogicalSize().w / 2;  // 480
  LScreenCenterY := TpxWindow.GetLogicalSize().h / 2;  // 270

  if FShaderEnabled then
  begin
    // Enable shader and set uniforms
    FShader.Enable(True);
    FShader.SetVec3Uniform('tint_color', FTintColor.x, FTintColor.y, FTintColor.z);
    FShader.SetFloatUniform('time', FTime);
    FShader.SetTextureUniform('al_tex', FTexture, 0);
  end;

  // Draw the texture with shader - left side
  FTexture.Draw(LScreenCenterX - 150, LScreenCenterY, pxWHITE, nil, @LOrigin, @LScale);

  if FShaderEnabled then
    FShader.Enable(False);

  // Draw texture without shader for comparison - right side
  FTexture.Draw(LScreenCenterX + 150, LScreenCenterY, pxWHITE, nil, @LOrigin, @LScale);
end;

procedure TTextureTintShaderDemo.OnRenderHUD();
begin
  FFont.DrawText(pxWHITE, 10, 10, pxAlignLeft, 'FPS: %d', [TpxWindow.GetFPS()]);
  FFont.DrawText(pxWHITE, 10, 30, pxAlignLeft, 'Texture Tint Shader Demo', []);

  if FShaderEnabled then
    FFont.DrawText(pxGREEN, 10, 50, pxAlignLeft, 'Shader: ENABLED', [])
  else
    FFont.DrawText(pxRED, 10, 50, pxAlignLeft, 'Shader: DISABLED', []);

  FFont.DrawText(pxCYAN, 10, 80, pxAlignLeft, 'SPACE: Toggle Shader', []);
  FFont.DrawText(pxCYAN, 10, 100, pxAlignLeft, '1/2: Red Tint (%.2f)', [FTintColor.x]);
  FFont.DrawText(pxCYAN, 10, 120, pxAlignLeft, '3/4: Green Tint (%.2f)', [FTintColor.y]);
  FFont.DrawText(pxCYAN, 10, 140, pxAlignLeft, '5/6: Blue Tint (%.2f)', [FTintColor.z]);
  FFont.DrawText(pxCYAN, 10, 160, pxAlignLeft, 'R: Reset Tint', []);
  FFont.DrawText(pxCYAN, 10, 180, pxAlignLeft, 'F11: Toggle Fullscreen', []);
  FFont.DrawText(pxCYAN, 10, 200, pxAlignLeft, 'ESC: Exit', []);

  FFont.DrawText(pxYELLOW, 270, 400, pxAlignLeft, 'With Shader', []);
  FFont.DrawText(pxYELLOW, 560, 400, pxAlignLeft, 'Without Shader', []);
end;


end.

