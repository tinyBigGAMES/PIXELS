unit UMisc;

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
  { TTest01 }
  TTest01 = class(TpxGame)
  private
    FFont: TpxFont;
    FPos: TpxVector;
    FTexture: array[0..3] of TpxTexture;
  public
    function  OnStartup(): Boolean; override;
    procedure OnShutdown(); override;
    procedure OnUpdate(); override;
    procedure OnRender(); override;
    procedure OnRenderHUD(); override;
    procedure OnAfterRender(); override;
  end;

implementation

function  TTest01.OnStartup(): Boolean;
var
  LFile: PpxFile;
begin
  Result := False;
  if not TpxWindow.Init('PIXELS Test01', 800, 600, True, True) then Exit;

  FFont := TpxFont.Create();
  FFont.LoadDefault(12);

  FTexture[0] := TpxTexture.Create();
  FTexture[0].Alloc(50, 50, pxWHITE, pxPixelArtTexture);
  FTexture[0].SetAsRenderTarget();
  FTexture[0].SetPixel(25, 25, pxRED);
  FTexture[0].UnsetAsRenderTarget();

  FTexture[1] := TpxTexture.Create();
  LFile := TpxFile.OpenZip('Data.zip', 'res/images/pixels.png');
  FTexture[1].Load(LFile, '.png', pxHDTexture, nil);
  TpxFile.Close(LFile);

  FTexture[2] := TpxTexture.Create();
  LFile := TpxFile.OpenZip('Data.zip', 'res/backgrounds/nebula1.png');
  FTexture[2].Load(LFile, '.png', pxHDTexture, nil);
  TpxFile.Close(LFile);

  FTexture[3] := TpxTexture.LoadFromZip('Data.zip', 'res/backgrounds/space.png', pxHDTexture, nil);

  FPos.x := -50;
  FPos.y := 0;
  FPos.z := 0;

  Result := True;
end;

procedure TTest01.OnShutdown();
begin
  FTexture[3].Free();
  FTexture[2].Free();
  FTexture[1].Free();
  FTexture[0].Free();
  FFont.Free();
  TpxWindow.Close();
end;

procedure TTest01.OnUpdate();
begin
  if TpxInput.JoystickPressed(pxJOY_BTN_X) then
    SetTerminate(True);

  if TpxInput.KeyPressed(pxKEY_ESCAPE) then
    SetTerminate(True);

  if TpxInput.KeyReleased(pxKEY_F11) then
    TpxWindow.ToggleFullscreen();

  FPos.x := FPos.x + 1;
  if FPos.x > TpxWindow.GetLogicalSize.w + 50 then
    FPos.x := -50;

  FPos.z := FPos.z + 0.3;
  FPos.z := TpxMath.ClipValueFloat(FPos.z, 0, 360, True);

  FPos.w := FPos.w + 0.5;

end;

procedure TTest01.OnRender();
var
  LOrigin: TpxVector;
  LPos: TpxVector;
  LScale: TpxVector;
begin
  TpxWindow.Clear(pxDARKSLATEBROWN);

  FTexture[3].DrawTiled(0, FPos.w / 2);


  TpxWindow.SetBlendMode(pxAdditiveAlphaBlendMode);
  FTexture[2].DrawTiled(0, FPos.w);
  TpxWindow.RestoreDefaultBlendMode();

  TpxWindow.DrawFillRectangle(FPos.x, FPos.y, 50, 50, pxDARKGREEN);

  FTexture[0].Draw(50, 50, pxWhite);


  LOrigin.x := 0.5;
  LOrigin.y := 0.5;
  LPos.x := TpxWindow.GetLogicalSize.w/2;
  LPos.y := TpxWindow.GetLogicalSize.h/2;
  LScale.x := 1.0;
  LScale.y := 1.0;

  FTexture[1].Draw(LPos.x, LPos.y, pxWhite, nil, @LOrigin, @LScale, FPos.z);
end;

procedure TTest01.OnRenderHUD();
begin
  FFont.DrawText(pxWHITE, 3, 3, pxAlignLeft, 'fps %d', [TpxWindow.GetFPS()]);
end;

procedure TTest01.OnAfterRender();
begin

  if TpxWindow.IsFullscreen then
    begin
      if TpxInput.KeyPressed(pxKEY_2) then
        TpxWindow.Save('image-fullscreen.png')
    end
  else
    begin
      if TpxInput.KeyPressed(pxKEY_1) then
       TpxWindow.Save('image-non-fullscreen.png');
    end;

end;

end.
