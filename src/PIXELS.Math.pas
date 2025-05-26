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

unit PIXELS.Math;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Deps,
  PIXELS.Base;

const
  pxRAD2DEG = 180.0 / PI;
  pxDEG2RAD = PI / 180.0;
  pxEPSILON = 0.00001;
  pxNaN     =  0.0 / 0.0;

type

  { TpxEase }
  TpxEase = (
    pxEaseLinearTween, pxEaseInQuad, pxEaseOutQuad, pxEaseInOutQuad,
    pxEaseInCubic, pxEaseOutCubic, pxEaseInOutCubic, pxEaseInQuart,
    pxEaseOutQuart, pxEaseInOutQuart, pxEaseInQuint, pxEaseOutQuint,
    pxEaseInOutQuint, pxEaseInSine, pxEaseOutSine, pxEaseInOutSine,
    pxEaseInExpo, pxEaseOutExpo, pxEaseInOutExpo, pxEaseInCircle,
    pxEaseOutCircle, pxEaseInOutCircle,pxEaseInElastic, pxEaseOutElastic,
    pxEaseInOutElastic, pxEaseInBack, pxEaseOutBack, pxEaseInOutBack,
    pxEaseInBounce, pxEaseOutBounce, pxEaseInOutBounce
  );

  { TpxLoopMode }
  TpxLoopMode = (pxLoopNone, pxLoopRepeat, pxLoopPingPong, pxLoopReverse);

  { TpxEaseParams }
  TpxEaseParams = record
    Amplitude: Double;
    Period: Double;
    Overshoot: Double;
  end;

  { TVector }
  PpxVector = ^TpxVector;
  TpxVector = record
    x,y,z,w: Single;
    constructor Create(const AX, AY: Single); overload;
    constructor Create(const AX, AY, AZ: Single); overload;
    constructor Create(const AX, AY, AZ, AW: Single); overload;
    procedure Assign(const AX, AY: Single); overload;
    procedure Assign(const AX, AY, AZ: Single); overload;
    procedure Assign(const AX, AY, AZ, AW: Single); overload;
    procedure Assign(const aVector: TpxVector); overload;
    procedure Clear();
    procedure Add(const aVector: TpxVector);
    procedure Subtract(const aVector: TpxVector);
    procedure Multiply(const aVector: TpxVector);
    procedure Divide(const aVector: TpxVector);
    function  Magnitude(): Single;
    function  MagnitudeTruncate(const aMaxMagitude: Single): TpxVector;
    function  Distance(const AVector: TpxVector): Single;
    procedure Normalize();
    function  Angle(const AVector: TpxVector): Single;
    procedure Thrust(const AAngle, ASpeed: Single);
    function  MagnitudeSquared(): Single;
    function  DotProduct(const AVector: TpxVector): Single;
    procedure Scale(const AValue: Single);
    procedure DivideBy(const AValue: Single);
    function  Project(const AVector: TpxVector): TpxVector;
    procedure Negate();
  end;

  { TRectangle }
  PpxRect = ^TpxRect;
  TpxRect = record
    x, y, w, h: Single;
    constructor Create(const AX, AY, AW, AH: Single);
    procedure Assign(const AX, AY, AW, AH: Single); overload;
    procedure Assign(const ARect: TpxRect); overload;
    procedure Clear();
    function Intersect(const ARect: TpxRect): Boolean;
  end;

  PpxSize = ^TpxSize;
  TpxSize = record
    w,h: Single;
    constructor Create(const AWidth, AHeight: Single);
  end;

  PpxRange = ^TpxRange;
  TpxRange = record
    minx,miny,maxx, maxy: Single;
    constructor Create(const AMinX, AMinY, AMaxX, AMaxY: Single);
  end;

  { TpxLineIntersection }
  TpxLineIntersection = (liNone, liTrue, liParallel);

  // Fast AABB vs Ray intersection
  TpxRay = record
    Origin: TpxVector;
    Direction: TpxVector; // Should be normalized
  end;

  // Oriented Bounding Box (OBB) collision
  TpxOBB = record
    Center: TpxVector;
    HalfWidth: Single;
    HalfHeight: Single;
    Rotation: Single; // In degrees
  end;

  { TpxMath }
  TpxMath = class(TpxStaticObject)
  private class var
    FCosTable: array [0 .. 360] of Single;
    FSinTable: array [0 .. 360] of Single;
  private
    class constructor Create();
    class destructor  Destroy();
  public
    class function  RandomRangeInt(const AMin, AMax: Integer): Integer; static;
    class function  RandomRangeFloat(const AMin, AMax: Single): Single; static;
    class function  RandomBool(): Boolean; static;
    class function  GetRandomSeed(): Integer; static;
    class procedure SetRandomSeed(const AValue: Integer); static;
    class function  AngleCos(const AAngle: Integer): Single; static;
    class function  AngleSin(const AAngle: Integer): Single; static;
    class function  AngleDifference(const ASrcAngle, ADestAngle: Single): Single; static;
    class procedure AngleRotatePos(const AAngle: Single; var AX: Single; var AY: Single); static;
    class function  ClipValueFloat(var AValue: Single; const AMin, AMax: Single; const AWrap: Boolean): Single; static;
    class function  ClipValueInt(var AValue: Integer; const AMin, AMax: Integer; const AWrap: Boolean): Integer; static;
    class function  SameSignExt(const AValue1, AValue2: Integer): Boolean; static;
    class function  SameSignFloat(const AValue1, AValue2: Single): Boolean; static;
    class function  SameValueExt(const AA, AB: Double; const AEpsilon: Double = 0): Boolean; static;
    class function  SameValueFloat(const AA, AB: Single; const AEpsilon: Single = 0): Boolean; static;
    class procedure SmoothMove(var AValue: Single; const AAmount, AMax, ADrag: Single); static;
    class function  Lerp(const AFrom, ATo, ATime: Double): Double; static;

    class function PointInRectangle(const APoint: TpxVector; const ARect: TpxRect): Boolean;
    class function PointInCircle(const APoint, ACenter: TpxVector; const ARadius: Single): Boolean;
    class function PointInTriangle(const APoint, APoint1, APoint2, APoint3: TpxVector): Boolean;
    class function CirclesOverlap(const ACenter1: TpxVector; const ARadius1: Single; const ACenter2: TpxVector; const ARadius2: Single): Boolean;
    class function CircleInRectangle(const ACenter: TpxVector; const ARadius: Single; const ARect: TpxRect): Boolean;
    class function RectanglesOverlap(const ARect1, ARect2: TpxRect): Boolean;
    class function RectangleIntersection(const ARect1, ARect2: TpxRect): TpxRect;
    class function LineIntersection(const AX1, AY1, AX2, AY2, AX3, AY3, AX4, AY4: Integer; var AX: Integer; var AY: Integer): TpxLineIntersection;
    class function PointToLineDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
    class function PointToLineSegmentDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
    class function LineSegmentIntersectsCircle(const ALineStart, ALineEnd, ACenter: TpxVector; const ARadius: Single): Boolean;
    class function ClosestPointOnLineSegment(const APoint, ALineStart, ALineEnd: TpxVector): TpxVector;
    class function OBBsOverlap(const AOBB1, AOBB2: TpxOBB): Boolean;
    class function PointInConvexPolygon(const APoint: TpxVector; const AVertices: array of TpxVector): Boolean;
    class function RayIntersectsAABB(const ARay: TpxRay; const ARect: TpxRect; out ADistance: Single): Boolean;

    class function  EaseValue(const ACurrentTime, AStartValue, AChangeInValue, ADuration: Double; const AEase: TpxEase): Double; static;
    class function  EasePosition(const AStartPos, AEndPos, ACurrentPos: Double; const AEase: TpxEase): Double; static;
    class function  EaseNormalized(const AProgress: Double; const AEase: TpxEase): Double;
    class function  EaseLerp(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
    class function  EaseVector(const AFrom, ATo: TpxVector; const AProgress: Double; const AEase: TpxEase): TpxVector;
    class function  EaseSmooth(const AFrom, ATo: Double; const AProgress: Double): Double;
    class function  EaseAngle(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
    class function  EaseKeyframes(const AKeyframes: array of Double; const AProgress: Double; const AEase: TpxEase): Double;
    class function  EaseLoop(const ATime, ADuration: Double; const AEase: TpxEase; const ALoopMode: TpxLoopMode): Double;
    class function  EaseStepped(const AFrom, ATo: Double; const AProgress: Double; const ASteps: Integer; const AEase: TpxEase): Double;
    class function  EaseSpring(const ATime: Double; const AAmplitude: Double = 1.0; const APeriod: Double = 0.3): Double;
    class function  EaseBezier(const AProgress: Double; const AX1, AY1, AX2, AY2: Double): Double;
    class function  EaseWithParams(const AProgress: Double; const AEase: TpxEase; const AParams: TpxEaseParams): Double;
  end;

implementation

uses
  System.Math;

{ TVector }
constructor TpxVector.Create(const AX, AY: Single);
begin
  X := AX;
  Y := AY;
  Z := 0;
  W := 0;
end;

constructor TpxVector.Create(const AX, AY, AZ: Single);
begin
  X := AX;
  Y := AY;
  Z := AZ;
  W := 0;
end;

constructor TpxVector.Create(const AX, AY, AZ, AW: Single);
begin
  X := AX;
  Y := AY;
  Z := AZ;
  W := AW;
end;

procedure TpxVector.Assign(const AX, AY: Single);
begin
  X := AX;
  Y := AY;
  Z := 0;
  W := 0;
end;

procedure TpxVector.Assign(const AX, AY, AZ: Single);
begin
  X := AX;
  Y := AY;
  Z := AZ;
  W := 0;
end;

procedure TpxVector.Assign(const AX, AY, AZ, AW: Single);
begin
  X := AX;
  Y := AY;
  Z := AZ;
  W := AW;
end;

procedure TpxVector.Assign(const AVector: TpxVector);
begin
  Self := AVector;
end;

procedure TpxVector.Clear();
begin
  X := 0;
  Y := 0;
  Z := 0;
  W := 0;
end;

procedure TpxVector.Add(const AVector: TpxVector);
begin
  X := X + AVector.X;
  Y := Y + AVector.Y;
end;

procedure TpxVector.Subtract(const AVector: TpxVector);
begin
  X := X - AVector.X;
  Y := Y - AVector.Y;
end;

procedure TpxVector.Multiply(const AVector: TpxVector);
begin
  X := X * AVector.X;
  Y := Y * AVector.Y;
end;

procedure TpxVector.Divide(const AVector: TpxVector);
begin
  X := X / AVector.X;
  Y := Y / AVector.Y;
end;

function  TpxVector.Magnitude(): Single;
begin
  Result := Sqrt((X * X) + (Y * Y));
end;

function  TpxVector.MagnitudeTruncate(const AMaxMagitude: Single): TpxVector;
var
  LMaxMagSqrd: Single;
  LVecMagSqrd: Single;
  LTruc: Single;
begin
  Result.Assign(X, Y);
  LMaxMagSqrd := AMaxMagitude * AMaxMagitude;
  LVecMagSqrd := Result.Magnitude();
  if LVecMagSqrd > LMaxMagSqrd then
  begin
    LTruc := (AMaxMagitude / Sqrt(LVecMagSqrd));
    Result.X := Result.X * LTruc;
    Result.Y := Result.Y * LTruc;
  end;
end;

function  TpxVector.Distance(const AVector: TpxVector): Single;
var
  LDirVec: TpxVector;
begin
  LDirVec.X := X - AVector.X;
  LDirVec.Y := Y - AVector.Y;
  Result := LDirVec.Magnitude();
end;

procedure TpxVector.Normalize();
var
  LLen, LOOL: Single;
begin
  LLen := self.Magnitude();
  if LLen <> 0 then
  begin
    LOOL := 1.0 / LLen;
    X := X * LOOL;
    Y := Y * LOOL;
  end;
end;

function  TpxVector.Angle(const AVector: TpxVector): Single;
var
  LXOY: Single;
  LR: TpxVector;
begin
  LR.Assign(self);
  LR.Subtract(AVector);
  LR.Normalize;

  if LR.Y = 0 then
  begin
    LR.Y := 0.001;
  end;

  LXOY := LR.X / LR.Y;

  Result := ArcTan(LXOY) * pxRAD2DEG;
  if LR.Y < 0 then
    Result := Result + 180.0;
end;

procedure TpxVector.Thrust(const AAngle, ASpeed: Single);
var
  LA: Single;

begin
  LA := AAngle + 90.0;

  TpxMath.ClipValueFloat(LA, 0, 360, True);

  X := X + TpxMath.AngleCos(Round(LA)) * -(aSpeed);
  Y := Y + TpxMath.AngleSin(Round(LA)) * -(aSpeed);
end;

function  TpxVector.MagnitudeSquared(): Single;
begin
  Result := (X * X) + (Y * Y);
end;

function  TpxVector.DotProduct(const AVector: TpxVector): Single;
begin
  Result := (X * AVector.X) + (Y * AVector.Y);
end;

procedure TpxVector.Scale(const AValue: Single);
begin
  X := X * AValue;
  Y := Y * AValue;
end;

procedure TpxVector.DivideBy(const AValue: Single);
begin
  X := X / AValue;
  Y := Y / AValue;
end;

function  TpxVector.Project(const AVector: TpxVector): TpxVector;
var
  LDP: Single;
begin
  LDP := DotProduct(AVector);
  Result.X := (LDP / (AVector.X * AVector.X + AVector.Y * AVector.Y)) * AVector.X;
  Result.Y := (LDP / (AVector.X * AVector.X + AVector.Y * AVector.Y)) * AVector.Y;
end;

procedure TpxVector.Negate();
begin
  X := -X;
  Y := -Y;
end;

{ TRectangle }
constructor TpxRect.Create(const AX, AY, AW, AH: Single);
begin
  x := AX;
  y := AY;
  w := AW;
  h := AH;
end;

procedure TpxRect.Assign(const AX, AY, AW, AH: Single);
begin
  x := AX;
  y := AY;
  w := AW;
  h := AH;
end;

procedure TpxRect.Assign(const ARect: TpxRect);
begin
  x := ARect.x;
  y := ARect.y;
  w := ARect.w;
  h := ARect.h;
end;

procedure TpxRect.Clear();
begin
  x := 0;
  y := 0;
  w := 0;
  h := 0;
end;

function TpxRect.Intersect(const ARect: TpxRect): Boolean;
var
  LR1R, LR1B: Single;
  LR2R, LR2B: Single;
begin
  LR1R := x - (w - 1);
  LR1B := y - (h - 1);
  LR2R := ARect.x - (ARect.w - 1);
  LR2B := ARect.y - (ARect.h - 1);

  Result := (x < LR2R) and (LR1R > ARect.x) and (y < LR2B) and (LR1B > ARect.y);
end;

{ TpxSize }
constructor TpxSize.Create(const AWidth: Single; const AHeight: Single);
begin
  w := AWidth;
  h := AHeight;
end;

{ TpxRange }
constructor TpxRange.Create(const AMinX: Single; const AMinY: Single; const AMaxX: Single; const AMaxY: Single);
begin
  minx := AMinX;
  miny := AMinY;
  maxx := AMaxX;
  maxy := AMaxY;
end;

{ TpxMath }
class constructor TpxMath.Create();
var
  I: Integer;
begin
  inherited;

  System.Randomize();

  for I := 0 to 360 do
  begin
    FCosTable[I] := cos((I * PI / 180.0));
    FSinTable[I] := sin((I * PI / 180.0));
  end;

end;

class destructor  TpxMath.Destroy();
begin
  inherited;
end;

function _RandomRange(const aFrom, aTo: Integer): Integer;
var
  LFrom: Integer;
  LTo: Integer;
begin
  LFrom := aFrom;
  LTo := aTo;

  if AFrom > ATo then
    Result := Random(LFrom - LTo) + ATo
  else
    Result := Random(LTo - LFrom) + AFrom;
end;

class function  TpxMath.RandomRangeInt(const AMin, AMax: Integer): Integer;
begin
  Result := _RandomRange(AMin, AMax + 1);
end;

class function  TpxMath.RandomRangeFloat(const AMin, AMax: Single): Single;
var
  LNum: Single;
begin
  LNum := _RandomRange(0, MaxInt) / MaxInt;
  Result := AMin + (LNum * (AMax - AMin));
end;

class function  TpxMath.RandomBool: Boolean;
begin
  Result := Boolean(_RandomRange(0, 2) = 1);
end;

class function  TpxMath.GetRandomSeed: Integer;
begin
  Result := System.RandSeed;
end;

class procedure TpxMath.SetRandomSeed(const AValue: Integer);
begin
  System.RandSeed := AValue;
end;

class function  TpxMath.AngleCos(const AAngle: Integer): Single;
var
  LAngle: Integer;
begin
  LAngle := EnsureRange(AAngle, 0, 360);
  Result := FCosTable[LAngle];
end;

class function  TpxMath.AngleSin(const AAngle: Integer): Single;
var
  LAngle: Integer;
begin
  LAngle := EnsureRange(AAngle, 0, 360);
  Result := FSinTable[LAngle];
end;

class function  TpxMath.AngleDifference(const ASrcAngle, ADestAngle: Single): Single;
var
  LC: Single;
begin
  LC := ADestAngle - ASrcAngle -
    (Floor((ADestAngle - ASrcAngle) / 360.0) * 360.0);

  if LC >= (360.0 / 2) then
  begin
    LC := LC - 360.0;
  end;
  Result := LC;
end;

class procedure TpxMath.AngleRotatePos(const AAngle: Single; var AX: Single; var AY: Single);
var
  LNX, LNY: Single;
  LIA: Integer;
  LAngle: Single;
begin
  LAngle := AAngle;
  ClipValueFloat(LAngle, 0, 359, True);

  LIA := Round(LAngle);

  LNX := AX * FCosTable[LIA] - AY * FSinTable[LIA];
  LNY := AY * FCosTable[LIA] + AX * FSinTable[LIA];

  AX := LNX;
  AY := LNY;
end;

class function  TpxMath.ClipValueFloat(var AValue: Single; const AMin, AMax: Single; const AWrap: Boolean): Single;
begin
  if AWrap then
    begin
      if (AValue > AMax) then
      begin
        AValue := AMin + Abs(AValue - AMax);
        if AValue > AMax then
          AValue := AMax;
      end
      else if (AValue < AMin) then
      begin
        AValue := AMax - Abs(AValue - AMin);
        if AValue < AMin then
          AValue := AMin;
      end
    end
  else
    begin
      if AValue < AMin then
        AValue := AMin
      else if AValue > AMax then
        AValue := AMax;
    end;

  Result := AValue;

end;

class function  TpxMath.ClipValueInt(var AValue: Integer; const AMin, AMax: Integer; const AWrap: Boolean): Integer;
begin
  if AWrap then
    begin
      if (AValue > AMax) then
      begin
        AValue := AMin + Abs(AValue - AMax);
        if AValue > AMax then
          AValue := AMax;
      end
      else if (AValue < AMin) then
      begin
        AValue := AMax - Abs(AValue - AMin);
        if AValue < AMin then
          AValue := AMin;
      end
    end
  else
    begin
      if AValue < AMin then
        AValue := AMin
      else if AValue > AMax then
        AValue := AMax;
    end;

  Result := AValue;
end;

class function  TpxMath.SameSignExt(const AValue1, AValue2: Integer): Boolean;
begin
  if System.Math.Sign(AValue1) = System.Math.Sign(AValue2) then
    Result := True
  else
    Result := False;
end;

class function  TpxMath.SameSignFloat(const AValue1, AValue2: Single): Boolean;
begin
  if System.Math.Sign(AValue1) = System.Math.Sign(AValue2) then
    Result := True
  else
    Result := False;
end;

class function  TpxMath.SameValueExt(const AA, AB: Double; const AEpsilon: Double): Boolean;
const
  CFuzzFactor = 1000;
  CDoubleResolution   = 1E-15 * CFuzzFactor;
var
  LEpsilon: Double;
begin
  LEpsilon := AEpsilon;
  if LEpsilon = 0 then
    LEpsilon := Max(Min(Abs(AA), Abs(AB)) * CDoubleResolution, CDoubleResolution);
  if AA > AB then
    Result := (AA - AB) <= LEpsilon
  else
    Result := (AB - AA) <= LEpsilon;
end;

class function  TpxMath.SameValueFloat(const AA, AB: Single; const AEpsilon: Single): Boolean;
begin
  Result := SameValueExt(AA, AB, AEpsilon);
end;

class procedure TpxMath.SmoothMove(var AValue: Single; const AAmount, AMax, ADrag: Single);
var
  LAmt: Single;
begin
  LAmt := AAmount;

  if LAmt > 0 then
  begin
    AValue := AValue + LAmt;
    if AValue > AMax then
      AValue := AMax;
  end else if LAmt < 0 then
  begin
    AValue := AValue + LAmt;
    if AValue < -AMax then
      AValue := -AMax;
  end else
  begin
    if AValue > 0 then
    begin
      AValue := AValue - ADrag;
      if AValue < 0 then
        AValue := 0;
    end else if AValue < 0 then
    begin
      AValue := AValue + ADrag;
      if AValue > 0 then
        AValue := 0;
    end;
  end;
end;

class function  TpxMath.Lerp(const AFrom,  ATo, ATime: Double): Double;
begin
  if ATime <= 0.5 then
    Result := AFrom + (ATo - AFrom) * ATime
  else
    Result := ATo - (ATo - AFrom) * (1.0 - ATime);
end;

// FIXED: Basic collision detection routines
class function TpxMath.PointInRectangle(const APoint: TpxVector; const ARect: TpxRect): Boolean;
begin
  Result := (APoint.X >= ARect.X) and (APoint.X <= (ARect.X + ARect.W)) and
            (APoint.Y >= ARect.Y) and (APoint.Y <= (ARect.Y + ARect.H));
end;

class function TpxMath.PointInCircle(const APoint, ACenter: TpxVector; const ARadius: Single): Boolean;
begin
  Result := CirclesOverlap(APoint, 0, ACenter, ARadius);
end;

class function TpxMath.PointInTriangle(const APoint, APoint1, APoint2, APoint3: TpxVector): Boolean;
var
  LDenominator: Single;
  LAlpha: Single;
  LBeta: Single;
  LGamma: Single;
begin
  Result := False;

  // Calculate denominator first to check for degenerate triangle
  LDenominator := (APoint2.Y - APoint3.Y) * (APoint1.X - APoint3.X) +
                  (APoint3.X - APoint2.X) * (APoint1.Y - APoint3.Y);

  // Check for degenerate triangle (zero area)
  if Abs(LDenominator) < 1e-10 then Exit;

  LAlpha := ((APoint2.Y - APoint3.Y) * (APoint.X - APoint3.X) +
             (APoint3.X - APoint2.X) * (APoint.Y - APoint3.Y)) / LDenominator;

  LBeta := ((APoint3.Y - APoint1.Y) * (APoint.X - APoint3.X) +
            (APoint1.X - APoint3.X) * (APoint.Y - APoint3.Y)) / LDenominator;

  LGamma := 1.0 - LAlpha - LBeta;

  Result := (LAlpha >= 0) and (LBeta >= 0) and (LGamma >= 0);
end;

class function TpxMath.CirclesOverlap(const ACenter1: TpxVector; const ARadius1: Single; const ACenter2: TpxVector; const ARadius2: Single): Boolean;
var
  LDistanceSquared: Single;
  LRadiusSum: Single;
begin
  // Use squared distance to avoid expensive sqrt
  LDistanceSquared := (ACenter2.X - ACenter1.X) * (ACenter2.X - ACenter1.X) +
                      (ACenter2.Y - ACenter1.Y) * (ACenter2.Y - ACenter1.Y);
  LRadiusSum := ARadius1 + ARadius2;

  Result := LDistanceSquared <= (LRadiusSum * LRadiusSum);
end;

// FIXED: Simplified circle-rectangle collision
class function TpxMath.CircleInRectangle(const ACenter: TpxVector; const ARadius: Single; const ARect: TpxRect): Boolean;
var
  LClosestX: Single;
  LClosestY: Single;
  LDistanceSquared: Single;
begin
  // Find closest point on rectangle to circle center
  LClosestX := ACenter.X;
  if LClosestX < ARect.X then
    LClosestX := ARect.X
  else if LClosestX > ARect.X + ARect.W then
    LClosestX := ARect.X + ARect.W;

  LClosestY := ACenter.Y;
  if LClosestY < ARect.Y then
    LClosestY := ARect.Y
  else if LClosestY > ARect.Y + ARect.H then
    LClosestY := ARect.Y + ARect.H;

  // Check if distance from circle center to closest point is within radius
  LDistanceSquared := (ACenter.X - LClosestX) * (ACenter.X - LClosestX) +
                      (ACenter.Y - LClosestY) * (ACenter.Y - LClosestY);

  Result := LDistanceSquared <= (ARadius * ARadius);
end;

class function TpxMath.RectanglesOverlap(const ARect1, ARect2: TpxRect): Boolean;
begin
  Result := (ARect1.X < ARect2.X + ARect2.W) and
            (ARect1.X + ARect1.W > ARect2.X) and
            (ARect1.Y < ARect2.Y + ARect2.H) and
            (ARect1.Y + ARect1.H > ARect2.Y);
end;

// FIXED: Simplified rectangle intersection
class function TpxMath.RectangleIntersection(const ARect1, ARect2: TpxRect): TpxRect;
var
  LLeft: Single;
  LTop: Single;
  LRight: Single;
  LBottom: Single;
begin
  Result.Assign(0, 0, 0, 0);

  if not RectanglesOverlap(ARect1, ARect2) then Exit;

  LLeft := Max(ARect1.X, ARect2.X);
  LTop := Max(ARect1.Y, ARect2.Y);
  LRight := Min(ARect1.X + ARect1.W, ARect2.X + ARect2.W);
  LBottom := Min(ARect1.Y + ARect1.H, ARect2.Y + ARect2.H);

  Result.X := LLeft;
  Result.Y := LTop;
  Result.W := LRight - LLeft;
  Result.H := LBottom - LTop;
end;

// SIMPLIFIED: Line intersection (keeping your implementation but cleaned up)
class function TpxMath.LineIntersection(const AX1, AY1, AX2, AY2, AX3, AY3, AX4, AY4: Integer; var AX: Integer; var AY: Integer): TpxLineIntersection;
var
  LAX: Integer;
  LBX: Integer;
  LCX: Integer;
  LAY: Integer;
  LBY: Integer;
  LCY: Integer;
  LD: Integer;
  LE: Integer;
  LF: Integer;
  LNum: Integer;
  LOffset: Integer;
  LX1Lo: Integer;
  LX1Hi: Integer;
  LY1Lo: Integer;
  LY1Hi: Integer;
begin
  Result := liNone;

  LAX := AX2 - AX1;
  LBX := AX3 - AX4;

  // X bound box test
  if LAX < 0 then
  begin
    LX1Lo := AX2;
    LX1Hi := AX1;
  end
  else
  begin
    LX1Hi := AX2;
    LX1Lo := AX1;
  end;

  if LBX > 0 then
  begin
    if (LX1Hi < AX4) or (AX3 < LX1Lo) then Exit;
  end
  else
  begin
    if (LX1Hi < AX3) or (AX4 < LX1Lo) then Exit;
  end;

  LAY := AY2 - AY1;
  LBY := AY3 - AY4;

  // Y bound box test
  if LAY < 0 then
  begin
    LY1Lo := AY2;
    LY1Hi := AY1;
  end
  else
  begin
    LY1Hi := AY2;
    LY1Lo := AY1;
  end;

  if LBY > 0 then
  begin
    if (LY1Hi < AY4) or (AY3 < LY1Lo) then Exit;
  end
  else
  begin
    if (LY1Hi < AY3) or (AY4 < LY1Lo) then Exit;
  end;

  LCX := AX1 - AX3;
  LCY := AY1 - AY3;
  LD := LBY * LCX - LBX * LCY;
  LF := LAY * LBX - LAX * LBY;

  if LF > 0 then
  begin
    if (LD < 0) or (LD > LF) then Exit;
  end
  else
  begin
    if (LD > 0) or (LD < LF) then Exit;
  end;

  LE := LAX * LCY - LAY * LCX;
  if LF > 0 then
  begin
    if (LE < 0) or (LE > LF) then Exit;
  end
  else
  begin
    if (LE > 0) or (LE < LF) then Exit;
  end;

  if LF = 0 then
  begin
    Result := liParallel;
    Exit;
  end;

  LNum := LD * LAX;
  if Sign(LNum) = Sign(LF) then
    LOffset := LF div 2
  else
    LOffset := -LF div 2;
  AX := AX1 + (LNum + LOffset) div LF;

  LNum := LD * LAY;
  if Sign(LNum) = Sign(LF) then
    LOffset := LF div 2
  else
    LOffset := -LF div 2;

  AY := AY1 + (LNum + LOffset) div LF;

  Result := liTrue;
end;

// REMOVED: RadiusOverlap (use CirclesOverlap instead)

// NEW: Additional useful collision routines

// Point to line distance
class function TpxMath.PointToLineDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
var
  LA: Single;
  LB: Single;
  LC: Single;
begin
  LA := ALineEnd.Y - ALineStart.Y;
  LB := ALineStart.X - ALineEnd.X;
  LC := ALineEnd.X * ALineStart.Y - ALineStart.X * ALineEnd.Y;

  Result := Abs(LA * APoint.X + LB * APoint.Y + LC) / Sqrt(LA * LA + LB * LB);
end;

// Point to line segment distance
class function TpxMath.PointToLineSegmentDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
var
  LLength: Single;
  LT: Single;
  LProjection: TpxVector;
begin
  LLength := ALineStart.Distance(ALineEnd);
  if LLength < 1e-10 then
  begin
    Result := APoint.Distance(ALineStart);
    Exit;
  end;

  LT := ((APoint.X - ALineStart.X) * (ALineEnd.X - ALineStart.X) +
         (APoint.Y - ALineStart.Y) * (ALineEnd.Y - ALineStart.Y)) / (LLength * LLength);

  if LT < 0 then
    Result := APoint.Distance(ALineStart)
  else if LT > 1 then
    Result := APoint.Distance(ALineEnd)
  else
  begin
    LProjection.X := ALineStart.X + LT * (ALineEnd.X - ALineStart.X);
    LProjection.Y := ALineStart.Y + LT * (ALineEnd.Y - ALineStart.Y);
    Result := APoint.Distance(LProjection);
  end;
end;

// Line segment to circle collision
class function TpxMath.LineSegmentIntersectsCircle(const ALineStart, ALineEnd, ACenter: TpxVector; const ARadius: Single): Boolean;
begin
  Result := PointToLineSegmentDistance(ACenter, ALineStart, ALineEnd) <= ARadius;
end;

// Closest point on line segment to a point
class function TpxMath.ClosestPointOnLineSegment(const APoint, ALineStart, ALineEnd: TpxVector): TpxVector;
var
  LLength: Single;
  LT: Single;
begin
  LLength := ALineStart.Distance(ALineEnd);
  if LLength < 1e-10 then
  begin
    Result := ALineStart;
    Exit;
  end;

  LT := ((APoint.X - ALineStart.X) * (ALineEnd.X - ALineStart.X) +
         (APoint.Y - ALineStart.Y) * (ALineEnd.Y - ALineStart.Y)) / (LLength * LLength);

  if LT < 0 then
    Result := ALineStart
  else if LT > 1 then
    Result := ALineEnd
  else
  begin
    Result.X := ALineStart.X + LT * (ALineEnd.X - ALineStart.X);
    Result.Y := ALineStart.Y + LT * (ALineEnd.Y - ALineStart.Y);
  end;
end;

class function TpxMath.OBBsOverlap(const AOBB1, AOBB2: TpxOBB): Boolean;
var
  LCos1: Single;
  LSin1: Single;
  LCos2: Single;
  LSin2: Single;
  LDX: Single;
  LDY: Single;
  LAxis: array[0..3] of TpxVector;
  LI: Integer;
  LProjection1: Single;
  LProjection2: Single;
  LRadians1: Single;
  LRadians2: Single;
begin
  // Convert degrees to radians
  LRadians1 := DegToRad(AOBB1.Rotation);
  LRadians2 := DegToRad(AOBB2.Rotation);

  // Get rotation values
  LCos1 := Cos(LRadians1);
  LSin1 := Sin(LRadians1);
  LCos2 := Cos(LRadians2);
  LSin2 := Sin(LRadians2);

  // Vector between centers
  LDX := AOBB2.Center.X - AOBB1.Center.X;
  LDY := AOBB2.Center.Y - AOBB1.Center.Y;

  // Separating axes (4 total: 2 for each OBB)
  LAxis[0].X := LCos1; LAxis[0].Y := LSin1;     // OBB1 X axis
  LAxis[1].X := -LSin1; LAxis[1].Y := LCos1;    // OBB1 Y axis
  LAxis[2].X := LCos2; LAxis[2].Y := LSin2;     // OBB2 X axis
  LAxis[3].X := -LSin2; LAxis[3].Y := LCos2;    // OBB2 Y axis

  // Test each axis
  for LI := 0 to 3 do
  begin
    // Project both OBBs onto this axis
    LProjection1 := Abs(LDX * LAxis[LI].X + LDY * LAxis[LI].Y);
    LProjection2 := Abs(AOBB1.HalfWidth * (LCos1 * LAxis[LI].X + LSin1 * LAxis[LI].Y)) +
                    Abs(AOBB1.HalfHeight * (-LSin1 * LAxis[LI].X + LCos1 * LAxis[LI].Y)) +
                    Abs(AOBB2.HalfWidth * (LCos2 * LAxis[LI].X + LSin2 * LAxis[LI].Y)) +
                    Abs(AOBB2.HalfHeight * (-LSin2 * LAxis[LI].X + LCos2 * LAxis[LI].Y));

    // Check for separation
    if LProjection1 > LProjection2 then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;


// Polygon collision (simple convex polygon)
class function TpxMath.PointInConvexPolygon(const APoint: TpxVector; const AVertices: array of TpxVector): Boolean;
var
  LI: Integer;
  LJ: Integer;
  LCount: Integer;
begin
  Result := False;
  LCount := Length(AVertices);
  if LCount < 3 then Exit;

  LJ := LCount - 1;
  for LI := 0 to LCount - 1 do
  begin
    if ((AVertices[LI].Y > APoint.Y) <> (AVertices[LJ].Y > APoint.Y)) and
       (APoint.X < (AVertices[LJ].X - AVertices[LI].X) * (APoint.Y - AVertices[LI].Y) /
        (AVertices[LJ].Y - AVertices[LI].Y) + AVertices[LI].X) then
      Result := not Result;
    LJ := LI;
  end;
end;

// Fast AABB vs Ray intersection
class function TpxMath.RayIntersectsAABB(const ARay: TpxRay; const ARect: TpxRect; out ADistance: Single): Boolean;
var
  LInvDirX: Single;
  LInvDirY: Single;
  LT1: Single;
  LT2: Single;
  LTMin: Single;
  LTMax: Single;
  LTemp: Single;
begin
  Result := False;
  ADistance := 0;

  // Avoid division by zero
  if Abs(ARay.Direction.X) < 1e-10 then
    LInvDirX := 1e10
  else
    LInvDirX := 1.0 / ARay.Direction.X;

  if Abs(ARay.Direction.Y) < 1e-10 then
    LInvDirY := 1e10
  else
    LInvDirY := 1.0 / ARay.Direction.Y;

  // Calculate t values for X slabs
  LT1 := (ARect.X - ARay.Origin.X) * LInvDirX;
  LT2 := (ARect.X + ARect.W - ARay.Origin.X) * LInvDirX;

  if LT1 > LT2 then
  begin
    LTemp := LT1;
    LT1 := LT2;
    LT2 := LTemp;
  end;

  LTMin := LT1;
  LTMax := LT2;

  // Calculate t values for Y slabs
  LT1 := (ARect.Y - ARay.Origin.Y) * LInvDirY;
  LT2 := (ARect.Y + ARect.H - ARay.Origin.Y) * LInvDirY;

  if LT1 > LT2 then
  begin
    LTemp := LT1;
    LT1 := LT2;
    LT2 := LTemp;
  end;

  LTMin := Max(LTMin, LT1);
  LTMax := Min(LTMax, LT2);

  if (LTMax >= 0) and (LTMin <= LTMax) then
  begin
    ADistance := LTMin;
    if ADistance < 0 then
      ADistance := LTMax;
    Result := ADistance >= 0;
  end;
end;


class function TpxMath.EaseValue(const ACurrentTime, AStartValue, AChangeInValue, ADuration: Double; const AEase: TpxEase): Double;
var
  LNormalizedTime: Double;
  LHalfDuration: Double;
  LTemp: Double;
begin
  Result := AStartValue;

  // Input validation
  if ADuration <= 0 then Exit;
  if ACurrentTime < 0 then Exit;

  // Clamp current time to duration
  LNormalizedTime := ACurrentTime;
  if LNormalizedTime > ADuration then
    LNormalizedTime := ADuration;

  case AEase of
    pxEaseLinearTween:
      begin
        Result := AChangeInValue * LNormalizedTime / ADuration + AStartValue;
      end;

    pxEaseInQuad:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        Result := AChangeInValue * LNormalizedTime * LNormalizedTime + AStartValue;
      end;

    pxEaseOutQuad:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        Result := -AChangeInValue * LNormalizedTime * (LNormalizedTime - 2) + AStartValue;
      end;

    pxEaseInOutQuad:
      begin
        LHalfDuration := ADuration / 2;
        LNormalizedTime := LNormalizedTime / LHalfDuration;
        if LNormalizedTime < 1 then
          Result := AChangeInValue / 2 * LNormalizedTime * LNormalizedTime + AStartValue
        else
        begin
          LNormalizedTime := LNormalizedTime - 1;
          Result := -AChangeInValue / 2 * (LNormalizedTime * (LNormalizedTime - 2) - 1) + AStartValue;
        end;
      end;

    pxEaseInCubic:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        Result := AChangeInValue * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue;
      end;

    pxEaseOutCubic:
      begin
        LNormalizedTime := (LNormalizedTime / ADuration) - 1;
        Result := AChangeInValue * (LNormalizedTime * LNormalizedTime * LNormalizedTime + 1) + AStartValue;
      end;

    pxEaseInOutCubic:
      begin
        LHalfDuration := ADuration / 2;
        LNormalizedTime := LNormalizedTime / LHalfDuration;
        if LNormalizedTime < 1 then
          Result := AChangeInValue / 2 * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue
        else
        begin
          LNormalizedTime := LNormalizedTime - 2;
          Result := AChangeInValue / 2 * (LNormalizedTime * LNormalizedTime * LNormalizedTime + 2) + AStartValue;
        end;
      end;

    pxEaseInQuart:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        Result := AChangeInValue * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue;
      end;

    pxEaseOutQuart:
      begin
        LNormalizedTime := (LNormalizedTime / ADuration) - 1;
        Result := -AChangeInValue * (LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime - 1) + AStartValue;
      end;

    pxEaseInOutQuart:
      begin
        LHalfDuration := ADuration / 2;
        LNormalizedTime := LNormalizedTime / LHalfDuration;
        if LNormalizedTime < 1 then
          Result := AChangeInValue / 2 * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue
        else
        begin
          LNormalizedTime := LNormalizedTime - 2;
          Result := -AChangeInValue / 2 * (LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime - 2) + AStartValue;
        end;
      end;

    pxEaseInQuint:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        Result := AChangeInValue * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue;
      end;

    pxEaseOutQuint:
      begin
        LNormalizedTime := (LNormalizedTime / ADuration) - 1;
        Result := AChangeInValue * (LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + 1) + AStartValue;
      end;

    pxEaseInOutQuint:
      begin
        LHalfDuration := ADuration / 2;
        LNormalizedTime := LNormalizedTime / LHalfDuration;
        if LNormalizedTime < 1 then
          Result := AChangeInValue / 2 * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + AStartValue
        else
        begin
          LNormalizedTime := LNormalizedTime - 2;
          Result := AChangeInValue / 2 * (LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime * LNormalizedTime + 2) + AStartValue;
        end;
      end;

    pxEaseInSine:
      begin
        Result := -AChangeInValue * Cos(LNormalizedTime / ADuration * (PI / 2)) + AChangeInValue + AStartValue;
      end;

    pxEaseOutSine:
      begin
        Result := AChangeInValue * Sin(LNormalizedTime / ADuration * (PI / 2)) + AStartValue;
      end;

    pxEaseInOutSine:
      begin
        Result := -AChangeInValue / 2 * (Cos(PI * LNormalizedTime / ADuration) - 1) + AStartValue;
      end;

    pxEaseInExpo:
      begin
        if LNormalizedTime = 0 then
          Result := AStartValue
        else
          Result := AChangeInValue * Power(2, 10 * (LNormalizedTime / ADuration - 1)) + AStartValue;
      end;

    pxEaseOutExpo:
      begin
        if LNormalizedTime = ADuration then
          Result := AStartValue + AChangeInValue
        else
          Result := AChangeInValue * (-Power(2, -10 * LNormalizedTime / ADuration) + 1) + AStartValue;
      end;

    pxEaseInOutExpo:
      begin
        if LNormalizedTime = 0 then
          Result := AStartValue
        else if LNormalizedTime = ADuration then
          Result := AStartValue + AChangeInValue
        else
        begin
          LHalfDuration := ADuration / 2;
          LNormalizedTime := LNormalizedTime / LHalfDuration;
          if LNormalizedTime < 1 then
            Result := AChangeInValue / 2 * Power(2, 10 * (LNormalizedTime - 1)) + AStartValue
          else
          begin
            LNormalizedTime := LNormalizedTime - 1;
            Result := AChangeInValue / 2 * (-Power(2, -10 * LNormalizedTime) + 2) + AStartValue;
          end;
        end;
      end;

    pxEaseInCircle:
      begin
        LNormalizedTime := LNormalizedTime / ADuration;
        LTemp := 1 - LNormalizedTime * LNormalizedTime;
        if LTemp < 0 then LTemp := 0; // Prevent negative sqrt
        Result := -AChangeInValue * (Sqrt(LTemp) - 1) + AStartValue;
      end;

    pxEaseOutCircle:
      begin
        LNormalizedTime := (LNormalizedTime / ADuration) - 1;
        LTemp := 1 - LNormalizedTime * LNormalizedTime;
        if LTemp < 0 then LTemp := 0; // Prevent negative sqrt
        Result := AChangeInValue * Sqrt(LTemp) + AStartValue;
      end;

    pxEaseInOutCircle:
      begin
        LHalfDuration := ADuration / 2;
        LNormalizedTime := LNormalizedTime / LHalfDuration;
        if LNormalizedTime < 1 then
        begin
          LTemp := 1 - LNormalizedTime * LNormalizedTime;
          if LTemp < 0 then LTemp := 0; // Prevent negative sqrt
          Result := -AChangeInValue / 2 * (Sqrt(LTemp) - 1) + AStartValue;
        end
        else
        begin
          LNormalizedTime := LNormalizedTime - 2;
          LTemp := 1 - LNormalizedTime * LNormalizedTime;
          if LTemp < 0 then LTemp := 0; // Prevent negative sqrt
          Result := AChangeInValue / 2 * (Sqrt(LTemp) + 1) + AStartValue;
        end;
      end;
  end;
end;

class function TpxMath.EasePosition(const AStartPos, AEndPos, ACurrentPos: Double; const AEase: TpxEase): Double;
var
  LProgress: Double;
  LRange: Double;
  LClampedPos: Double;
begin
  Result := AStartPos;

  // Input validation
  if AStartPos = AEndPos then Exit;

  // Calculate range and clamp current position
  LRange := Abs(AEndPos - AStartPos);
  LClampedPos := ACurrentPos;

  // Clamp current position to valid range
  if AStartPos < AEndPos then
  begin
    if LClampedPos < AStartPos then LClampedPos := AStartPos;
    if LClampedPos > AEndPos then LClampedPos := AEndPos;
  end
  else
  begin
    if LClampedPos > AStartPos then LClampedPos := AStartPos;
    if LClampedPos < AEndPos then LClampedPos := AEndPos;
  end;

  // Calculate progress (0 to 100)
  if AStartPos < AEndPos then
    LProgress := ((LClampedPos - AStartPos) / LRange) * 100
  else
    LProgress := ((AStartPos - LClampedPos) / LRange) * 100;

  // Apply easing
  Result := EaseValue(LProgress, 0, 100, 100, AEase);

  // Clamp result to 0-100 range
  if Result < 0 then Result := 0;
  if Result > 100 then Result := 100;
end;

// 1. Normalized easing - returns 0.0 to 1.0 curve value
class function TpxMath.EaseNormalized(const AProgress: Double; const AEase: TpxEase): Double;
var
  LClampedProgress: Double;
begin
  // Clamp progress to 0-1 range
  LClampedProgress := AProgress;
  if LClampedProgress < 0 then LClampedProgress := 0;
  if LClampedProgress > 1 then LClampedProgress := 1;

  // Use existing EaseValue with normalized parameters
  Result := EaseValue(LClampedProgress, 0.0, 1.0, 1.0, AEase);
end;

// 2. Interpolate between any two values with easing
class function TpxMath.EaseLerp(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
var
  LNormalizedCurve: Double;
begin
  LNormalizedCurve := EaseNormalized(AProgress, AEase);
  Result := AFrom + (ATo - AFrom) * LNormalizedCurve;
end;

// 3. Vector/Point easing
class function TpxMath.EaseVector(const AFrom, ATo: TpxVector; const AProgress: Double; const AEase: TpxEase): TpxVector;
begin
  Result.X := EaseLerp(AFrom.X, ATo.X, AProgress, AEase);
  Result.Y := EaseLerp(AFrom.Y, ATo.Y, AProgress, AEase);
end;

// 4. Smooth interpolation (smoothstep function - very commonly used)
class function TpxMath.EaseSmooth(const AFrom, ATo: Double; const AProgress: Double): Double;
var
  LClampedProgress: Double;
  LSmoothProgress: Double;
begin
  // Clamp progress to 0-1 range
  LClampedProgress := AProgress;
  if LClampedProgress < 0 then LClampedProgress := 0;
  if LClampedProgress > 1 then LClampedProgress := 1;

  // Smoothstep formula: 3t² - 2t³
  LSmoothProgress := LClampedProgress * LClampedProgress * (3.0 - 2.0 * LClampedProgress);

  Result := AFrom + (ATo - AFrom) * LSmoothProgress;
end;

// 5. Angle easing (handles 360° wrapping)
class function TpxMath.EaseAngle(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
var
  LDifference: Double;
  LNormalizedCurve: Double;
begin
  // Calculate shortest path between angles
  LDifference := ATo - AFrom;

  // Normalize to -180 to 180 range
  while LDifference > 180 do
    LDifference := LDifference - 360;
  while LDifference < -180 do
    LDifference := LDifference + 360;

  LNormalizedCurve := EaseNormalized(AProgress, AEase);
  Result := AFrom + LDifference * LNormalizedCurve;

  // Keep result in 0-360 range
  while Result < 0 do
    Result := Result + 360;
  while Result >= 360 do
    Result := Result - 360;
end;

// 6. Multi-keyframe easing (animate through multiple points)
class function TpxMath.EaseKeyframes(const AKeyframes: array of Double; const AProgress: Double; const AEase: TpxEase): Double;
var
  LSegmentCount: Integer;
  LSegmentIndex: Integer;
  LSegmentProgress: Double;
  LSegmentSize: Double;
begin
  Result := 0.0;

  LSegmentCount := Length(AKeyframes) - 1;
  if LSegmentCount <= 0 then Exit;

  // Clamp progress
  if AProgress <= 0 then
  begin
    Result := AKeyframes[0];
    Exit;
  end;
  if AProgress >= 1 then
  begin
    Result := AKeyframes[High(AKeyframes)];
    Exit;
  end;

  // Find which segment we're in
  LSegmentSize := 1.0 / LSegmentCount;
  LSegmentIndex := Trunc(AProgress / LSegmentSize);

  // Prevent index overflow
  if LSegmentIndex >= LSegmentCount then
    LSegmentIndex := LSegmentCount - 1;

  // Calculate progress within this segment
  LSegmentProgress := (AProgress - (LSegmentIndex * LSegmentSize)) / LSegmentSize;

  // Ease between the two keyframe values
  Result := EaseLerp(AKeyframes[LSegmentIndex], AKeyframes[LSegmentIndex + 1], LSegmentProgress, AEase);
end;

// 7. Looping/repeating animations
class function TpxMath.EaseLoop(const ATime, ADuration: Double; const AEase: TpxEase; const ALoopMode: TpxLoopMode): Double;
var
  LNormalizedTime: Double;
  LCycleTime: Double;
  LProgress: Double;
begin
  Result := 0.0;

  if ADuration <= 0 then Exit;

  case ALoopMode of
    pxLoopNone:
      begin
        LProgress := ATime / ADuration;
        if LProgress > 1 then LProgress := 1;
        Result := EaseNormalized(LProgress, AEase);
      end;

    pxLoopRepeat:
      begin
        LCycleTime := Fmod(ATime, ADuration);
        LProgress := LCycleTime / ADuration;
        Result := EaseNormalized(LProgress, AEase);
      end;

    pxLoopPingPong:
      begin
        LNormalizedTime := ATime / ADuration;
        LCycleTime := Fmod(LNormalizedTime, 2.0);
        if LCycleTime <= 1.0 then
          LProgress := LCycleTime
        else
          LProgress := 2.0 - LCycleTime; // Reverse direction
        Result := EaseNormalized(LProgress, AEase);
      end;

    pxLoopReverse:
      begin
        LCycleTime := Fmod(ATime, ADuration);
        LProgress := 1.0 - (LCycleTime / ADuration);
        Result := EaseNormalized(LProgress, AEase);
      end;
  end;
end;

// 8. Stepped/discrete easing (for pixel-perfect or discrete animations)
class function TpxMath.EaseStepped(const AFrom, ATo: Double; const AProgress: Double; const ASteps: Integer; const AEase: TpxEase): Double;
var
  LStepSize: Double;
  LStepIndex: Integer;
  LStepProgress: Double;
begin
  if ASteps <= 1 then
  begin
    Result := EaseLerp(AFrom, ATo, AProgress, AEase);
    Exit;
  end;

  LStepSize := 1.0 / (ASteps - 1);
  LStepIndex := Round(AProgress / LStepSize);

  if LStepIndex >= ASteps then
    LStepIndex := ASteps - 1;

  LStepProgress := LStepIndex * LStepSize;
  Result := EaseLerp(AFrom, ATo, LStepProgress, AEase);
end;

// 9. Spring-based easing (more natural physics motion)
class function TpxMath.EaseSpring(const ATime: Double; const AAmplitude: Double = 1.0; const APeriod: Double = 0.3): Double;
var
  LDampening: Double;
  LAngularFreq: Double;
begin
  if ATime <= 0 then
  begin
    Result := 0.0;
    Exit;
  end;
  if ATime >= 1 then
  begin
    Result := 1.0;
    Exit;
  end;

  LDampening := 0.3;
  LAngularFreq := 2 * PI / APeriod;

  Result := 1 - (AAmplitude * Power(2, -10 * ATime) * Sin((ATime - LDampening / 4) * LAngularFreq));
end;

// 10. Bezier curve easing (custom curves)
class function TpxMath.EaseBezier(const AProgress: Double; const AX1, AY1, AX2, AY2: Double): Double;
var
  LT: Double;
  LInvT: Double;
begin
  // Simplified cubic bezier calculation
  // For full implementation, you'd need iterative solving
  LT := AProgress;
  LInvT := 1.0 - LT;

  // Cubic bezier: (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
  // Where P₀=(0,0), P₁=(AX1,AY1), P₂=(AX2,AY2), P₃=(1,1)
  Result := 3 * LInvT * LInvT * LT * AY1 +
            3 * LInvT * LT * LT * AY2 +
            LT * LT * LT;
end;

// 11. Easing with overshoot/undershoot control
class function TpxMath.EaseWithParams(const AProgress: Double; const AEase: TpxEase; const AParams: TpxEaseParams): Double;
begin
  case AEase of
    pxEaseInElastic,
    pxEaseOutElastic,
    pxEaseInOutElastic:
      Result := EaseSpring(AProgress, AParams.Amplitude, AParams.Period);
    pxEaseInBack,
    pxEaseOutBack,
    pxEaseInOutBack:
      begin
        // Back easing with overshoot parameter
        if AProgress < 0.5 then
          Result := 2 * AProgress * AProgress * ((AParams.Overshoot + 1) * 2 * AProgress - AParams.Overshoot)
        else
          Result := 1 + 2 * (AProgress - 1) * (AProgress - 1) * ((AParams.Overshoot + 1) * 2 * (AProgress - 1) + AParams.Overshoot);
      end;
    else
      Result := EaseNormalized(AProgress, AEase);
  end;
end;

end.
