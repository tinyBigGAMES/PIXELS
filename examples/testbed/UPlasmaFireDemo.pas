(******************************************************************************
  PIXELS - Plasma Fire Effect Demo (GPU Shader Implementation)
  Advanced real-time plasma fire simulation using programmable pixel shaders

  This demo showcases advanced GPU-accelerated plasma generation techniques
  using GLSL pixel shaders to create dynamic, animated fire effects with
  realistic color gradients, wind simulation, and multi-layer compositing.
  Demonstrates sophisticated shader programming, render-to-texture workflows,
  and real-time parameter animation within the PIXELS game library framework.

  Technical Complexity Level: Advanced

  OVERVIEW:

  The Plasma Fire demo implements a sophisticated real-time fire simulation
  entirely on the GPU using custom GLSL pixel shaders. The system generates
  organic, flame-like patterns through multi-octave noise functions combined
  with height-based intensity mapping and wind displacement effects. The demo
  serves as an advanced example of shader programming, demonstrating how
  mathematical noise functions can create visually compelling natural effects.

  Primary educational objectives include teaching shader-based procedural
  generation, render-to-texture techniques, and real-time parameter animation.
  Target audience includes intermediate to advanced game developers seeking
  to understand GPU programming and visual effects implementation.

  TECHNICAL IMPLEMENTATION:

  Core Systems:
  - Custom GLSL pixel shader for plasma generation
  - Render-to-texture pipeline with 800x600 resolution
  - Real-time uniform parameter updates at 60 FPS
  - Multi-layer additive blending composition
  - Deterministic animation system using locked timestep

  Data Structures:
  - TpxShader: Encapsulates GLSL shader program management
  - TpxTexture: Render target for plasma generation (800x600, pxHDTexture)
  - TpxFont: UI text rendering for parameter display
  - Animation variables: FTime, FFireIntensity, FWindEffect

  Mathematical Foundations:
  The plasma generation relies on layered noise functions:

    float noise(vec2 p) {
        return sin(p.x * 0.5 + u_time * 3.0) * sin(p.y * 0.3 + u_time * 2.5) +
               cos(p.x * 0.7 + u_time * 1.8) * cos(p.y * 0.4 + u_time * 3.2) +
               sin((p.x + p.y) * 0.25 + u_time * 4.0) * 0.5;
    }

  Height-based intensity calculation:
    float heightFactor = 1.0 - uv.y;
    heightFactor = heightFactor * heightFactor;  // Quadratic falloff

  Wind displacement implementation:
    FWindEffect := TpxMath.AngleSin(Round(FTime * 30)) * 0.3;
    pos.x += u_wind * heightFactor * 0.5;

  FEATURES DEMONSTRATED:

  • GPU-accelerated procedural generation using pixel shaders
  • Multi-octave noise synthesis for organic pattern creation
  • Real-time uniform parameter animation and interpolation
  • Render-to-texture workflows with fullscreen quad rendering
  • Multi-layer additive blending for depth and intensity
  • Height-based effect intensity mapping for realistic fire behavior
  • Sinusoidal wind displacement simulation
  • Dynamic fire intensity variation using trigonometric functions
  • Efficient GPU memory management and texture allocation
  • Cross-platform GLSL shader compilation and uniform binding

  RENDERING TECHNIQUES:

  Multi-Pass Rendering Pipeline:
  1. Set render target to FRenderTexture (800x600)
  2. Clear render target with pxBLACK
  3. Enable plasma shader with current uniforms
  4. Render fullscreen quad (0,0 to 800,600) with pxWHITE
  5. Disable shader and restore main render target
  6. Composite three offset layers with additive blending:
     - Base layer at (0,0)
     - Secondary layer at (2,-1) for depth
     - Tertiary layer at (-1,1) for complexity

  Shader Uniform Management:
    FPlasmaShader.SetFloatUniform('u_time', FTime);
    FPlasmaShader.SetFloatUniform('u_intensity', FFireIntensity);
    FPlasmaShader.SetFloatUniform('u_wind', FWindEffect);
    FPlasmaShader.SetVec2Uniform('u_resolution', LSize.w, LSize.h);

  CONTROLS:

  • ESC / Joystick X Button: Exit demonstration
  • F11: Toggle fullscreen mode
  • Automatic wind animation: 30-degree sine wave cycle
  • Automatic intensity variation: 45-degree sine wave cycle

  MATHEMATICAL FOUNDATION:

  Fire Color Gradient Implementation:
    if (intensity < 0.25) color = mix(black, red, intensity * 4.0);
    else if (intensity < 0.5) color = mix(red, orange, (intensity - 0.25) * 4.0);
    else if (intensity < 0.75) color = mix(orange, yellow, (intensity - 0.5) * 4.0);
    else color = mix(yellow, white, (intensity - 0.75) * 4.0);

  Animation Parameter Calculations:
    FTime := FTime + 0.016;  // 60 FPS delta time
    FWindEffect := TpxMath.AngleSin(Round(FTime * 30)) * 0.3;
    FFireIntensity := 0.8 + (TpxMath.AngleSin(Round(FTime * 45)) * 0.2);

  Coordinate Space: UV coordinates (0,0 to 1,1) mapped to texture space
  Noise Scaling: UV coordinates multiplied by 4.0 for appropriate frequency
  Temporal Animation: Multiple time-based frequencies (1.8, 2.5, 3.0, 3.2, 4.0, 5.0)

  PERFORMANCE CHARACTERISTICS:

  Expected Performance: 60 FPS at 800x600 resolution on modern GPUs
  Memory Usage: ~1.9 MB for render texture (800*600*4 bytes RGBA)
  GPU Utilization: Moderate pixel shader workload with trigonometric functions
  Scalability: Linear scaling with resolution; suitable for 1080p+ displays

  Optimization Techniques:
  - Pre-computed sine/cosine tables via TpxMath.AngleSin/AngleCos
  - Single-pass shader execution with minimal texture sampling
  - Efficient additive blending for multi-layer composition
  - Locked timestep prevents frame rate dependencies

  EDUCATIONAL VALUE:

  Core Learning Objectives:
  • Understanding GPU shader programming with GLSL
  • Implementing procedural generation techniques
  • Real-time parameter animation and interpolation
  • Render-to-texture workflows and fullscreen quad rendering
  • Multi-layer blending and compositing techniques
  • Mathematical noise function implementation
  • Performance optimization for real-time graphics

  Transferable Concepts:
  - Shader-based special effects for particles, explosions, magic spells
  - Procedural texture generation for materials and environments
  - Real-time animation systems with trigonometric functions
  - GPU-accelerated post-processing and visual effects
  - Cross-platform graphics programming best practices

  Real-World Applications:
  Game visual effects, interactive art installations, real-time visualizations,
  educational graphics programming, and advanced 2D rendering techniques.
  Serves as foundation for more complex effects like fluid simulation,
  atmospheric effects, and dynamic lighting systems.
******************************************************************************)

unit UPlasmaFireDemo;

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
  { TPlasmaFireDemo }
  TPlasmaFireDemo = class(TpxGame)
  private
    FFont: TpxFont;
    FPlasmaShader: TpxShader;
    FRenderTexture: TpxTexture;
    FTime: Single;
    FFireIntensity: Single;
    FWindEffect: Single;
    function LoadPlasmaShader(): Boolean;
  public
    function  OnStartup(): Boolean; override;
    procedure OnShutdown(); override;
    procedure OnUpdate(); override;
    procedure OnRender(); override;
    procedure OnRenderHUD(); override;
  end;

implementation

const
  // Plasma fire pixel shader
  CPlasmaFireShader =
    '#version 330 core' + #13#10 +
    'precision mediump float;' + #13#10 +
    'uniform float u_time;' + #13#10 +
    'uniform float u_intensity;' + #13#10 +
    'uniform float u_wind;' + #13#10 +
    'uniform vec2 u_resolution;' + #13#10 +
    'out vec4 fragColor;' + #13#10 +
    '' + #13#10 +
    'float noise(vec2 p) {' + #13#10 +
    '    return sin(p.x * 0.5 + u_time * 3.0) * sin(p.y * 0.3 + u_time * 2.5) +' + #13#10 +
    '           cos(p.x * 0.7 + u_time * 1.8) * cos(p.y * 0.4 + u_time * 3.2) +' + #13#10 +
    '           sin((p.x + p.y) * 0.25 + u_time * 4.0) * 0.5;' + #13#10 +
    '}' + #13#10 +
    '' + #13#10 +
    'vec3 fireColor(float intensity) {' + #13#10 +
    '    vec3 black = vec3(0.0);' + #13#10 +
    '    vec3 red = vec3(1.0, 0.0, 0.0);' + #13#10 +
    '    vec3 orange = vec3(1.0, 0.5, 0.0);' + #13#10 +
    '    vec3 yellow = vec3(1.0, 1.0, 0.0);' + #13#10 +
    '    vec3 white = vec3(1.0, 1.0, 1.0);' + #13#10 +
    '    ' + #13#10 +
    '    if (intensity < 0.25)' + #13#10 +
    '        return mix(black, red, intensity * 4.0);' + #13#10 +
    '    else if (intensity < 0.5)' + #13#10 +
    '        return mix(red, orange, (intensity - 0.25) * 4.0);' + #13#10 +
    '    else if (intensity < 0.75)' + #13#10 +
    '        return mix(orange, yellow, (intensity - 0.5) * 4.0);' + #13#10 +
    '    else' + #13#10 +
    '        return mix(yellow, white, (intensity - 0.75) * 4.0);' + #13#10 +
    '}' + #13#10 +
    '' + #13#10 +
    'void main() {' + #13#10 +
    '    vec2 uv = gl_FragCoord.xy / u_resolution.xy;' + #13#10 +
    '    vec2 pos = uv * 4.0;' + #13#10 +
    '    ' + #13#10 +
    '    // Height factor for fire effect (stronger at bottom)' + #13#10 +
    '    float heightFactor = 1.0 - uv.y;' + #13#10 +
    '    heightFactor = heightFactor * heightFactor;' + #13#10 +
    '    ' + #13#10 +
    '    // Wind displacement' + #13#10 +
    '    pos.x += u_wind * heightFactor * 0.5;' + #13#10 +
    '    ' + #13#10 +
    '    // Generate multiple noise layers' + #13#10 +
    '    float n1 = noise(pos * 2.0);' + #13#10 +
    '    float n2 = noise(pos * 4.0 + vec2(100.0, 100.0)) * 0.5;' + #13#10 +
    '    float n3 = noise(pos * 8.0 + vec2(200.0, 200.0)) * 0.25;' + #13#10 +
    '    ' + #13#10 +
    '    float plasma = (n1 + n2 + n3) * 0.5 + 0.5;' + #13#10 +
    '    plasma *= heightFactor * u_intensity;' + #13#10 +
    '    ' + #13#10 +
    '    // Additional turbulence' + #13#10 +
    '    float turbulence = sin(pos.x * 3.0 + u_time * 5.0) * ' + #13#10 +
    '                      cos(pos.y * 2.0 + u_time * 4.0) * 0.1;' + #13#10 +
    '    plasma += turbulence * heightFactor;' + #13#10 +
    '    ' + #13#10 +
    '    plasma = clamp(plasma, 0.0, 1.0);' + #13#10 +
    '    ' + #13#10 +
    '    vec3 color = fireColor(plasma);' + #13#10 +
    '    float alpha = plasma;' + #13#10 +
    '    ' + #13#10 +
    '    fragColor = vec4(color, alpha);' + #13#10 +
    '}';

{ TPlasmaFireDemo }
function TPlasmaFireDemo.OnStartup(): Boolean;
begin
  Result := False;

  if not TpxWindow.Init('PIXELS - Plasma Fire Effect Demo (Shader)', 800, 600, True, True) then
    Exit;

  // Initialize font
  FFont := TpxFont.Create();
  FFont.LoadDefault(12);

  // Create render texture
  FRenderTexture := TpxTexture.Create();
  FRenderTexture.Alloc(800, 600, pxBLACK, pxHDTexture);

  // Load plasma shader
  if not LoadPlasmaShader() then
  begin
    TpxConsole.PrintLn('Failed to load plasma shader: %s', [FPlasmaShader.GetError()]);
    Exit;
  end;

  // Initialize animation variables
  FTime := 0.0;
  FFireIntensity := 1.0;
  FWindEffect := 0.0;

  Result := True;
end;

procedure TPlasmaFireDemo.OnShutdown();
begin
  FPlasmaShader.Free();
  FRenderTexture.Free();
  FFont.Free();
  TpxWindow.Close();
end;

procedure TPlasmaFireDemo.OnUpdate();
begin
  // Handle input
  if TpxInput.JoystickPressed(pxJOY_BTN_X) or TpxInput.KeyPressed(pxKEY_ESCAPE) then
    SetTerminate(True);

  if TpxInput.KeyReleased(pxKEY_F11) then
    TpxWindow.ToggleFullscreen();

  // Update animation time
  FTime := FTime + 0.016; // Locked 60fps delta time

  // Create wind effect with sine wave
  FWindEffect := TpxMath.AngleSin(Round(FTime * 30)) * 0.3;

  // Vary fire intensity
  FFireIntensity := 0.8 + (TpxMath.AngleSin(Round(FTime * 45)) * 0.2);
end;

procedure TPlasmaFireDemo.OnRender();
var
  LSize: TpxSize;
begin
  // Clear with dark background
  TpxWindow.Clear(pxBLACK);

  // Set render target to our texture
  FRenderTexture.SetAsRenderTarget();
  FRenderTexture.Clear(pxBLACK);

  // Enable shader and set uniforms
  FPlasmaShader.Enable(True);
  FPlasmaShader.SetFloatUniform('u_time', FTime);
  FPlasmaShader.SetFloatUniform('u_intensity', FFireIntensity);
  FPlasmaShader.SetFloatUniform('u_wind', FWindEffect);

  LSize := FRenderTexture.GetSize();
  FPlasmaShader.SetVec2Uniform('u_resolution', LSize.w, LSize.h);

  // Draw fullscreen quad to generate plasma
  TpxWindow.DrawFillRectangle(0, 0, LSize.w, LSize.h, pxWHITE);

  // Disable shader
  FPlasmaShader.Enable(False);

  // Restore main render target
  FRenderTexture.UnsetAsRenderTarget();

  // Draw the plasma texture with additive blending
  TpxWindow.SetBlendMode(pxAdditiveAlphaBlendMode);
  FRenderTexture.Draw(0, 0, pxWHITE);

  // Add second layer with slight offset for more depth
  FRenderTexture.Draw(2, -1, pxWHITE);

  // Add third layer with different offset
  FRenderTexture.Draw(-1, 1, pxWHITE);

  // Restore normal blending for UI
  TpxWindow.RestoreDefaultBlendMode();
end;

procedure TPlasmaFireDemo.OnRenderHUD();
begin
  FFont.DrawText(pxWHITE, 10, 10, pxAlignLeft, 'PIXELS - Plasma Fire Effect (GPU Shader)', []);
  FFont.DrawText(pxCYAN, 10, 30, pxAlignLeft, 'FPS: %d', [TpxWindow.GetFPS()]);
  FFont.DrawText(pxYELLOW, 10, 50, pxAlignLeft, 'ESC: Exit', []);
  FFont.DrawText(pxYELLOW, 10, 70, pxAlignLeft, 'F11: Toggle Fullscreen', []);
  FFont.DrawText(pxORANGE, 10, 90, pxAlignLeft, 'Fire Intensity: %.2f', [FFireIntensity]);
  FFont.DrawText(pxGREEN, 10, 110, pxAlignLeft, 'GPU Accelerated', []);
end;

function TPlasmaFireDemo.LoadPlasmaShader(): Boolean;
begin
  Result := False;

  FPlasmaShader := TpxShader.Create();

  // Load pixel shader
  if not FPlasmaShader.Load(pxPixelShader, CPlasmaFireShader) then
    Exit;

  // Build shader program
  if not FPlasmaShader.Build() then
    Exit;

  Result := True;
end;

end.
