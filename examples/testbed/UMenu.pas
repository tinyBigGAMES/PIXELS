unit UMenu;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  PIXELS.Console,
  PIXELS.Graphics,
  PIXELS.Game,
  PIXELS.Utils;

const
  // Virtual Key Codes for navigation
  VK_RETURN = 13;
  VK_ESC = 27;
  VK_LEFT = 37;
  VK_UP = 38;
  VK_RIGHT = 39;
  VK_DOWN = 40;

type
  { TMenuItem }
  TMenuItem = record
    GameClass: TpxGameClass;
    Description: string;
    constructor Create(const AGameClass: TpxGameClass; const ADescription: string);
  end;

  { TMenu }
  TMenu = class
  private
    FItems: TList<TMenuItem>;
    FCurrentIndex: Integer;
    FConsoleWidth: Integer;
    FConsoleHeight: Integer;
    FItemsPerColumn: Integer;
    FColumnWidth: Integer;
    FColumnCount: Integer;
    FCurrentColumn: Integer;
    FCurrentRow: Integer;
    FTopIndex: Integer;
    FStartY: Integer;
    FMenuHeight: Integer;
    FNeedRedraw: Boolean;
    procedure CalculateLayout();
    procedure UpdateColumnAndRow();
    procedure DrawMenu();
    procedure DrawFooter();
    procedure ClearMenuArea();
    function HandleInput(): Boolean;
    procedure MoveUp();
    procedure MoveDown();
    procedure MoveLeft();
    procedure MoveRight();
    function GetMaxDescriptionLength(): Integer;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure AddItem(const AGameClass: TpxGameClass; const ADescription: string);
    procedure Clear();
    function Run(): TpxGameClass;
    function GetItemCount(): Integer;
  end;

implementation

{ TMenuItem }

constructor TMenuItem.Create(const AGameClass: TpxGameClass; const ADescription: string);
begin
  GameClass := AGameClass;
  Description := ADescription;
end;

{ TMenu }

constructor TMenu.Create();
begin
  inherited Create();
  FItems := TList<TMenuItem>.Create();
  FCurrentIndex := 0;
  FTopIndex := 0;
  FCurrentColumn := 0;
  FCurrentRow := 0;
  FStartY := 0;
  FMenuHeight := 0;
  FNeedRedraw := True;
end;

destructor TMenu.Destroy();
begin
  FItems.Free();
  inherited Destroy();
end;

procedure TMenu.AddItem(const AGameClass: TpxGameClass; const ADescription: string);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(AGameClass, ADescription);
  FItems.Add(LItem);
end;

procedure TMenu.Clear();
begin
  FItems.Clear();
  FCurrentIndex := 0;
  FTopIndex := 0;
  FCurrentColumn := 0;
  FCurrentRow := 0;
  FStartY := 0;
  FMenuHeight := 0;
  FNeedRedraw := True;
end;

function TMenu.GetItemCount(): Integer;
begin
  Result := FItems.Count;
end;

function TMenu.GetMaxDescriptionLength(): Integer;
var
  LIndex: Integer;
  LMaxLength: Integer;
begin
  LMaxLength := 0;
  for LIndex := 0 to FItems.Count - 1 do
  begin
    if Length(FItems[LIndex].Description) > LMaxLength then
      LMaxLength := Length(FItems[LIndex].Description);
  end;
  Result := LMaxLength;
end;

procedure TMenu.CalculateLayout();
var
  LMaxDescLength: Integer;
  LAvailableHeight: Integer;
begin
  TpxConsole.GetSize(@FConsoleWidth, @FConsoleHeight);

  // Get current cursor position to start menu from there
  TpxConsole.GetCursorPos(nil, @FStartY);

  // Calculate available height from current position to bottom minus 2 lines for footer
  LAvailableHeight := FConsoleHeight - FStartY - 2;
  if LAvailableHeight < 1 then
    LAvailableHeight := 1;

  FItemsPerColumn := LAvailableHeight;
  FMenuHeight := FItemsPerColumn;

  // Calculate column width (max description + padding)
  LMaxDescLength := GetMaxDescriptionLength();
  FColumnWidth := LMaxDescLength + 4; // Add some padding

  // Calculate how many columns fit
  FColumnCount := FConsoleWidth div FColumnWidth;
  if FColumnCount < 1 then
    FColumnCount := 1;

  // Adjust column width if we have extra space
  if FColumnCount > 0 then
    FColumnWidth := FConsoleWidth div FColumnCount;
end;

procedure TMenu.UpdateColumnAndRow();
begin
  if FItems.Count = 0 then
  begin
    FCurrentColumn := 0;
    FCurrentRow := 0;
    Exit;
  end;

  FCurrentColumn := FCurrentIndex div FItemsPerColumn;
  FCurrentRow := FCurrentIndex mod FItemsPerColumn;
end;

procedure TMenu.ClearMenuArea();
var
  LLine: Integer;
begin
  // Only clear the menu area, not the entire screen or footer
  for LLine := 0 to FMenuHeight - 1 do
  begin
    TpxConsole.SetCursorPos(0, FStartY + LLine);
    TpxConsole.ClearLine();
  end;
end;

procedure TMenu.DrawMenu();
var
  LIndex: Integer;
  LColumn: Integer;
  LRow: Integer;
  LX: Integer;
  LY: Integer;
  LItem: TMenuItem;
begin
  ClearMenuArea();

  // Draw items starting from FStartY
  for LIndex := 0 to FItems.Count - 1 do
  begin
    LColumn := LIndex div FItemsPerColumn;
    LRow := LIndex mod FItemsPerColumn;

    // Only draw if within visible area
    if (LColumn < FColumnCount) and (LRow < FItemsPerColumn) then
    begin
      LX := LColumn * FColumnWidth;
      LY := FStartY + LRow;  // Position relative to start Y

      TpxConsole.SetCursorPos(LX, LY);

      LItem := FItems[LIndex];

      // Highlight current selection
      if LIndex = FCurrentIndex then
      begin
        TpxConsole.SetForegroundColor(pxBLACK);
        TpxConsole.SetBackgroundColor(pxWHITE);
        TpxConsole.Print('> ' + LItem.Description, False);
        TpxConsole.ResetTextFormat();
      end
      else
      begin
        TpxConsole.ResetTextFormat();
        TpxConsole.SetForegroundColor(pxWHITE);
        TpxConsole.Print('  ' + LItem.Description, False);
      end;
    end;
  end;
end;

procedure TMenu.DrawFooter();
var
  LFooterY: Integer;
begin
  LFooterY := FStartY + FMenuHeight;  // Position footer after menu area

  TpxConsole.SetCursorPos(0, LFooterY);
  TpxConsole.SetForegroundColor(pxYELLOW);
  TpxConsole.PrintLn('', False);
  TpxConsole.Print('Arrow Keys: Navigate | ENTER: Select | ESC: Quit', False);
  TpxConsole.ResetTextFormat();
end;

procedure TMenu.MoveUp();
begin
  if FItems.Count = 0 then
    Exit;

  if FCurrentRow > 0 then
  begin
    Dec(FCurrentIndex);
  end
  else
  begin
    // Move to bottom of current column
    FCurrentIndex := FCurrentColumn * FItemsPerColumn + (FItemsPerColumn - 1);
    if FCurrentIndex >= FItems.Count then
      FCurrentIndex := FItems.Count - 1;
  end;

  UpdateColumnAndRow();
  FNeedRedraw := True;
end;

procedure TMenu.MoveDown();
begin
  if FItems.Count = 0 then
    Exit;

  if FCurrentRow < FItemsPerColumn - 1 then
  begin
    if FCurrentIndex + 1 < FItems.Count then
      Inc(FCurrentIndex);
  end
  else
  begin
    // Move to top of current column
    FCurrentIndex := FCurrentColumn * FItemsPerColumn;
  end;

  UpdateColumnAndRow();
  FNeedRedraw := True;
end;

procedure TMenu.MoveLeft();
begin
  if FItems.Count = 0 then
    Exit;

  if FCurrentColumn > 0 then
  begin
    FCurrentIndex := (FCurrentColumn - 1) * FItemsPerColumn + FCurrentRow;
    if FCurrentIndex >= FItems.Count then
      FCurrentIndex := FItems.Count - 1;
  end
  else
  begin
    // Move to rightmost column
    FCurrentIndex := ((FItems.Count - 1) div FItemsPerColumn) * FItemsPerColumn + FCurrentRow;
    if FCurrentIndex >= FItems.Count then
      FCurrentIndex := FItems.Count - 1;
  end;

  UpdateColumnAndRow();
  FNeedRedraw := True;
end;

procedure TMenu.MoveRight();
var
  LNewIndex: Integer;
begin
  if FItems.Count = 0 then
    Exit;

  LNewIndex := (FCurrentColumn + 1) * FItemsPerColumn + FCurrentRow;

  if LNewIndex < FItems.Count then
  begin
    FCurrentIndex := LNewIndex;
  end
  else
  begin
    // Move to first column
    FCurrentIndex := FCurrentRow;
    if FCurrentIndex >= FItems.Count then
      FCurrentIndex := 0;
  end;

  UpdateColumnAndRow();
  FNeedRedraw := True;
end;

function TMenu.HandleInput(): Boolean;
begin
  Result := True;

  // Check for key presses using TpxConsole
  if TpxConsole.WasKeyPressed(VK_UP) then
    MoveUp()
  else if TpxConsole.WasKeyPressed(VK_DOWN) then
    MoveDown()
  else if TpxConsole.WasKeyPressed(VK_LEFT) then
    MoveLeft()
  else if TpxConsole.WasKeyPressed(VK_RIGHT) then
    MoveRight()
  else if TpxConsole.WasKeyPressed(VK_RETURN) then
    Result := False // Signal to exit and return selection
  else if TpxConsole.WasKeyPressed(VK_ESC) then
  begin
    FCurrentIndex := -1; // Signal canceled
    Result := False;
  end;
end;

function TMenu.Run(): TpxGameClass;
var
  LRunning: Boolean;
begin
  Result := nil;

  if FItems.Count = 0 then
    Exit;

  CalculateLayout();
  UpdateColumnAndRow();

  // Hide cursor for cleaner display
  TpxConsole.HideCursor();

  while TpxConsole.IsKeyPressed(VK_ESC) or
        TpxConsole.IsKeyPressed(VK_RETURN)  do
  begin
    TpxUtils.ProcessMessages();
  end;

  // Clear any previous key states
  TpxConsole.ClearKeyStates();

  LRunning := True;
  FNeedRedraw := True;

  try
    // Draw footer once at the beginning
    DrawFooter();

    while LRunning do
    begin
      // Only redraw when needed
      if FNeedRedraw then
      begin
        DrawMenu();
        FNeedRedraw := False;
      end;

      LRunning := HandleInput();

      // Small delay to prevent excessive CPU usage and allow key state updates
      //TpxConsole.Wait(16); // ~60 FPS
      TpxUtils.ProcessMessages();
    end;
  finally
    // Restore cursor visibility
    TpxConsole.ShowCursor();
  end;

  // Return selected game class or nil if canceled
  if (FCurrentIndex >= 0) and (FCurrentIndex < FItems.Count) then
    Result := FItems[FCurrentIndex].GameClass
  else
    Result := nil;
end;

end.
