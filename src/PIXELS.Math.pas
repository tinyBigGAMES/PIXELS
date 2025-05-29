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
  /// <summary>
  /// Conversion factor from radians to degrees (180.0 / PI)
  /// </summary>
  /// <remarks>
  /// Use this constant to convert radian values to degrees. PIXELS primarily uses degrees for angle calculations.
  /// Multiply a radian value by this constant to get the equivalent degree value.
  /// </remarks>
  /// <example>
  /// <code>
  /// LDegrees := LRadians * pxRAD2DEG;
  /// </code>
  /// </example>
  pxRAD2DEG = 180.0 / PI;

  /// <summary>
  /// Conversion factor from degrees to radians (PI / 180.0)
  /// </summary>
  /// <remarks>
  /// Use this constant to convert degree values to radians when interfacing with standard math functions.
  /// Multiply a degree value by this constant to get the equivalent radian value.
  /// </remarks>
  /// <example>
  /// <code>
  /// LRadians := LDegrees * pxDEG2RAD;
  /// </code>
  /// </example>
  pxDEG2RAD = PI / 180.0;

  /// <summary>
  /// Small floating-point value used for epsilon comparisons (0.00001)
  /// </summary>
  /// <remarks>
  /// Use this constant when comparing floating-point values for near-equality to account for floating-point precision errors.
  /// Essential for reliable floating-point comparisons in game mathematics.
  /// </remarks>
  /// <example>
  /// <code>
  /// if Abs(LValue1 - LValue2) < pxEPSILON then
  ///   // Values are considered equal
  /// </code>
  /// </example>
  pxEPSILON = 0.00001;

  /// <summary>
  /// Not-a-Number (NaN) floating-point value
  /// </summary>
  /// <remarks>
  /// Use this constant to represent invalid or undefined numerical results.
  /// Can be used to initialize variables or indicate error conditions in mathematical operations.
  /// </remarks>
  /// <example>
  /// <code>
  /// LResult := pxNaN; // Indicate invalid result
  /// </code>
  /// </example>
  pxNaN     =  0.0 / 0.0;

type
  /// <summary>
  /// Enumeration of easing functions for smooth animation transitions
  /// </summary>
  /// <remarks>
  /// Easing functions control the rate of change during animations, providing natural-looking motion.
  /// Linear provides constant speed, In functions start slow, Out functions end slow, InOut combines both.
  /// Elastic, Back, and Bounce provide special effects like overshooting or bouncing.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Smooth fade-in with ease out
  /// LAlpha := TpxMath.EaseValue(LTime, 0.0, 1.0, 2.0, pxEaseOutQuad);
  /// </code>
  /// </example>
  { TpxEase }
  TpxEase = (
    /// <summary>Linear interpolation with constant speed</summary>
    pxEaseLinearTween,
    /// <summary>Quadratic easing starting slow</summary>
    pxEaseInQuad,
    /// <summary>Quadratic easing ending slow</summary>
    pxEaseOutQuad,
    /// <summary>Quadratic easing slow at both ends</summary>
    pxEaseInOutQuad,
    /// <summary>Cubic easing starting slow</summary>
    pxEaseInCubic,
    /// <summary>Cubic easing ending slow</summary>
    pxEaseOutCubic,
    /// <summary>Cubic easing slow at both ends</summary>
    pxEaseInOutCubic,
    /// <summary>Quartic easing starting slow</summary>
    pxEaseInQuart,
    /// <summary>Quartic easing ending slow</summary>
    pxEaseOutQuart,
    /// <summary>Quartic easing slow at both ends</summary>
    pxEaseInOutQuart,
    /// <summary>Quintic easing starting slow</summary>
    pxEaseInQuint,
    /// <summary>Quintic easing ending slow</summary>
    pxEaseOutQuint,
    /// <summary>Quintic easing slow at both ends</summary>
    pxEaseInOutQuint,
    /// <summary>Sine wave easing starting slow</summary>
    pxEaseInSine,
    /// <summary>Sine wave easing ending slow</summary>
    pxEaseOutSine,
    /// <summary>Sine wave easing slow at both ends</summary>
    pxEaseInOutSine,
    /// <summary>Exponential easing starting slow</summary>
    pxEaseInExpo,
    /// <summary>Exponential easing ending slow</summary>
    pxEaseOutExpo,
    /// <summary>Exponential easing slow at both ends</summary>
    pxEaseInOutExpo,
    /// <summary>Circular easing starting slow</summary>
    pxEaseInCircle,
    /// <summary>Circular easing ending slow</summary>
    pxEaseOutCircle,
    /// <summary>Circular easing slow at both ends</summary>
    pxEaseInOutCircle,
    /// <summary>Elastic easing with spring-like overshoot at start</summary>
    pxEaseInElastic,
    /// <summary>Elastic easing with spring-like overshoot at end</summary>
    pxEaseOutElastic,
    /// <summary>Elastic easing with spring-like overshoot at both ends</summary>
    pxEaseInOutElastic,
    /// <summary>Back easing with slight overshoot at start</summary>
    pxEaseInBack,
    /// <summary>Back easing with slight overshoot at end</summary>
    pxEaseOutBack,
    /// <summary>Back easing with slight overshoot at both ends</summary>
    pxEaseInOutBack,
    /// <summary>Bounce easing with bouncing effect at start</summary>
    pxEaseInBounce,
    /// <summary>Bounce easing with bouncing effect at end</summary>
    pxEaseOutBounce,
    /// <summary>Bounce easing with bouncing effect at both ends</summary>
    pxEaseInOutBounce
  );
  /// <summary>
  /// Enumeration of loop modes for repeating animations
  /// </summary>
  /// <remarks>
  /// Controls how animations behave when they reach their end point.
  /// Used with TpxMath.EaseLoop to create various looping behaviors.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Create pulsing effect that goes back and forth
  /// LPulse := TpxMath.EaseLoop(LTime, 2.0, pxEaseInOutSine, pxLoopPingPong);
  /// </code>
  /// </example>
  { TpxLoopMode }
  TpxLoopMode = (
    /// <summary>No looping - animation plays once and stops</summary>
    pxLoopNone,
    /// <summary>Animation repeats from the beginning when it reaches the end</summary>
    pxLoopRepeat,
    /// <summary>Animation plays forward then backward continuously</summary>
    pxLoopPingPong,
    /// <summary>Animation plays in reverse direction continuously</summary>
    pxLoopReverse
  );
  /// <summary>
  /// Parameters for advanced easing functions that support customization
  /// </summary>
  /// <remarks>
  /// Used with elastic, back, and spring easing functions to control amplitude, period, and overshoot behavior.
  /// Allows fine-tuning of easing effects for specific animation requirements.
  /// </remarks>
  /// <example>
  /// <code>
  /// LParams.Amplitude := 1.5;
  /// LParams.Period := 0.4;
  /// LParams.Overshoot := 1.2;
  /// LResult := TpxMath.EaseWithParams(LProgress, pxEaseOutElastic, LParams);
  /// </code>
  /// </example>
  { TpxEaseParams }
  TpxEaseParams = record
    /// <summary>
    /// Controls the amplitude of elastic and spring animations
    /// </summary>
    /// <remarks>
    /// Higher values create more pronounced oscillations in elastic easing.
    /// Typical range is 0.5 to 2.0, with 1.0 being the default.
    /// </remarks>
    Amplitude: Double;
    /// <summary>
    /// Controls the period/frequency of oscillations in elastic animations
    /// </summary>
    /// <remarks>
    /// Lower values create faster oscillations, higher values create slower ones.
    /// Typical range is 0.1 to 0.5, with 0.3 being the default.
    /// </remarks>
    Period: Double;
    /// <summary>
    /// Controls how much back easing overshoots the target value
    /// </summary>
    /// <remarks>
    /// Higher values create more pronounced overshoot in back easing.
    /// Typical range is 0.5 to 2.0, with 1.0 being the default.
    /// </remarks>
    Overshoot: Double;
  end;

/// <summary>
  /// Pointer to TpxVector for reference passing and dynamic allocation
  /// </summary>
  /// <remarks>
  /// Used when you need to pass vectors by reference or work with dynamically allocated vectors.
  /// </remarks>
  { TVector }
  PpxVector = ^TpxVector;
  /// <summary>
  /// 4-component vector for 2D/3D positions, directions, and mathematical operations
  /// </summary>
  /// <remarks>
  /// Primary vector type in PIXELS for representing positions, velocities, directions, and performing vector math.
  /// Components x,y are used for 2D operations, z for depth, w for homogeneous coordinates or custom data.
  /// All mathematical operations modify the vector in-place unless otherwise specified.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Create and manipulate a 2D position vector
  /// LPosition := TpxVector.Create(100.0, 50.0);
  /// LVelocity := TpxVector.Create(5.0, -2.0);
  /// LPosition.Add(LVelocity); // Move by velocity
  /// </code>
  /// </example>
  TpxVector = record
    /// <summary>
    /// X component (horizontal axis)
    /// </summary>
    /// <remarks>
    /// In 2D graphics, positive X typically points right.
    /// </remarks>
    x: Single;
    /// <summary>
    /// Y component (vertical axis)
    /// </summary>
    /// <remarks>
    /// In 2D graphics, positive Y typically points down (screen coordinates).
    /// </remarks>
    y: Single;
    /// <summary>
    /// Z component (depth axis)
    /// </summary>
    /// <remarks>
    /// Used for 3D operations or as a third data component.
    /// In 3D graphics, positive Z typically points toward the viewer.
    /// </remarks>
    z: Single;
    /// <summary>
    /// W component (homogeneous coordinate or custom data)
    /// </summary>
    /// <remarks>
    /// Used for homogeneous coordinates in 3D transformations or as a fourth data component.
    /// Can also be used to store additional data like alpha values or custom properties.
    /// </remarks>
    w: Single;
    /// <summary>
    /// Creates a 2D vector with specified X and Y components
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <remarks>
    /// Z and W components are automatically set to 0.
    /// Most common constructor for 2D game development.
    /// </remarks>
    constructor Create(const AX, AY: Single); overload;
    /// <summary>
    /// Creates a 3D vector with specified X, Y, and Z components
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <param name="AZ">Z component value</param>
    /// <remarks>
    /// W component is automatically set to 0.
    /// Useful for 3D positions and directions.
    /// </remarks>
    constructor Create(const AX, AY, AZ: Single); overload;
    /// <summary>
    /// Creates a 4D vector with all components specified
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <param name="AZ">Z component value</param>
    /// <param name="AW">W component value</param>
    /// <remarks>
    /// Full 4D vector creation for advanced mathematical operations or homogeneous coordinates.
    /// </remarks>
    constructor Create(const AX, AY, AZ, AW: Single); overload;
    /// <summary>
    /// Assigns 2D values to the vector
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <remarks>
    /// Z and W components are set to 0. Equivalent to Create constructor but for existing vectors.
    /// </remarks>
    procedure Assign(const AX, AY: Single); overload;
    /// <summary>
    /// Assigns 3D values to the vector
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <param name="AZ">Z component value</param>
    /// <remarks>
    /// W component is set to 0. Useful for updating existing vectors with 3D data.
    /// </remarks>
    procedure Assign(const AX, AY, AZ: Single); overload;
    /// <summary>
    /// Assigns 4D values to the vector
    /// </summary>
    /// <param name="AX">X component value</param>
    /// <param name="AY">Y component value</param>
    /// <param name="AZ">Z component value</param>
    /// <param name="AW">W component value</param>
    /// <remarks>
    /// Full 4D assignment for complete vector updates.
    /// </remarks>
    procedure Assign(const AX, AY, AZ, AW: Single); overload;
    /// <summary>
    /// Copies all components from another vector
    /// </summary>
    /// <param name="aVector">Source vector to copy from</param>
    /// <remarks>
    /// Performs a complete copy of all four components from the source vector.
    /// </remarks>
    procedure Assign(const aVector: TpxVector); overload;
    /// <summary>
    /// Sets all vector components to zero
    /// </summary>
    /// <remarks>
    /// Resets the vector to origin position (0, 0, 0, 0).
    /// Useful for initializing vectors or resetting accumulated values.
    /// </remarks>
    procedure Clear();
    /// <summary>
    /// Adds another vector to this vector (component-wise addition)
    /// </summary>
    /// <param name="aVector">Vector to add</param>
    /// <remarks>
    /// Modifies this vector: this = this + aVector.
    /// Each component is added separately: x+x, y+y, z+z, w+w.
    /// Commonly used for applying velocity to position.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Apply velocity to position
    /// LPosition.Add(LVelocity);
    /// </code>
    /// </example>
    procedure Add(const aVector: TpxVector);
    /// <summary>
    /// Subtracts another vector from this vector (component-wise subtraction)
    /// </summary>
    /// <param name="aVector">Vector to subtract</param>
    /// <remarks>
    /// Modifies this vector: this = this - aVector.
    /// Each component is subtracted separately: x-x, y-y, z-z, w-w.
    /// Useful for calculating direction vectors between points.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Calculate direction from enemy to player
    /// LDirection := LPlayerPos;
    /// LDirection.Subtract(LEnemyPos);
    /// </code>
    /// </example>
    procedure Subtract(const aVector: TpxVector);
    /// <summary>
    /// Multiplies this vector by another vector (component-wise multiplication)
    /// </summary>
    /// <param name="aVector">Vector to multiply by</param>
    /// <remarks>
    /// Modifies this vector: this = this * aVector.
    /// Each component is multiplied separately: x*x, y*y, z*z, w*w.
    /// Useful for scaling different axes by different amounts.
    /// </remarks>
    procedure Multiply(const aVector: TpxVector);
    /// <summary>
    /// Divides this vector by another vector (component-wise division)
    /// </summary>
    /// <param name="aVector">Vector to divide by</param>
    /// <remarks>
    /// Modifies this vector: this = this / aVector.
    /// Each component is divided separately: x/x, y/y, z/z, w/w.
    /// Be careful to avoid division by zero in any component.
    /// </remarks>
    procedure Divide(const aVector: TpxVector);
    /// <summary>
    /// Calculates the magnitude (length) of the vector
    /// </summary>
    /// <returns>The magnitude of the vector</returns>
    /// <remarks>
    /// Uses Euclidean distance formula: sqrt(x² + y²) for 2D, sqrt(x² + y² + z²) for 3D.
    /// Essential for distance calculations and normalization.
    /// For performance-critical code where exact magnitude isn't needed, consider MagnitudeSquared.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if object is within range
    /// LDistance := LTargetVector.Magnitude();
    /// if LDistance < LMaxRange then
    ///   // Target is in range
    /// </code>
    /// </example>
    function  Magnitude(): Single;
    /// <summary>
    /// Returns a copy of this vector with magnitude clamped to specified maximum
    /// </summary>
    /// <param name="aMaxMagitude">Maximum allowed magnitude</param>
    /// <returns>New vector with clamped magnitude</returns>
    /// <remarks>
    /// If current magnitude exceeds maximum, returns normalized vector scaled to maximum.
    /// If current magnitude is within limit, returns copy of original vector.
    /// Useful for limiting velocity or force vectors.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Limit player velocity to maximum speed
    /// LVelocity := LVelocity.MagnitudeTruncate(LMaxSpeed);
    /// </code>
    /// </example>
    function  MagnitudeTruncate(const aMaxMagitude: Single): TpxVector;
    /// <summary>
    /// Calculates the distance between this vector and another vector
    /// </summary>
    /// <param name="AVector">Target vector to measure distance to</param>
    /// <returns>Distance between the two vectors</returns>
    /// <remarks>
    /// Treats both vectors as position points and calculates Euclidean distance.
    /// Equivalent to calculating (AVector - this).Magnitude().
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check distance between player and enemy
    /// LDistance := LPlayerPos.Distance(LEnemyPos);
    /// if LDistance < LAttackRange then
    ///   // Enemy can attack
    /// </code>
    /// </example>
    function  Distance(const AVector: TpxVector): Single;
    /// <summary>
    /// Normalizes this vector to unit length (magnitude = 1)
    /// </summary>
    /// <remarks>
    /// Modifies this vector in-place by dividing each component by the vector's magnitude.
    /// If magnitude is zero, vector remains unchanged to avoid division by zero.
    /// Normalized vectors are essential for direction calculations and unit vectors.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Create unit direction vector
    /// LDirection := LTargetPos;
    /// LDirection.Subtract(LStartPos);
    /// LDirection.Normalize(); // Now points toward target with magnitude 1
    /// </code>
    /// </example>
    procedure Normalize();
    /// <summary>
    /// Calculates the angle between this vector and another vector
    /// </summary>
    /// <param name="AVector">Vector to calculate angle to</param>
    /// <returns>Angle in degrees</returns>
    /// <remarks>
    /// Returns the angle from this vector to the target vector.
    /// Result is in degrees, following PIXELS' standard angle convention.
    /// Useful for determining facing direction or rotation needed.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Calculate angle to rotate enemy toward player
    /// LTargetAngle := LEnemyPos.Angle(LPlayerPos);
    /// </code>
    /// </example>
    function  Angle(const AVector: TpxVector): Single;
    /// <summary>
    /// Applies thrust force to this vector at specified angle and speed
    /// </summary>
    /// <param name="AAngle">Thrust direction in degrees</param>
    /// <param name="ASpeed">Thrust magnitude</param>
    /// <remarks>
    /// Adds a force vector to this vector in the specified direction.
    /// Angle follows PIXELS convention: 0° = right, 90° = up, 180° = left, 270° = down.
    /// Commonly used for spaceship-style movement where thrust is applied in facing direction.
    /// Modifies this vector by adding the thrust vector.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Apply forward thrust to spaceship velocity
    /// if TpxInput.KeyDown(pxKEY_UP) then
    ///   LVelocity.Thrust(LShipAngle, LThrustPower);
    /// </code>
    /// </example>
    procedure Thrust(const AAngle, ASpeed: Single);
    /// <summary>
    /// Calculates the squared magnitude of the vector
    /// </summary>
    /// <returns>Squared magnitude (x² + y² + z² + w²)</returns>
    /// <remarks>
    /// More efficient than Magnitude() since it avoids the expensive square root operation.
    /// Perfect for distance comparisons where you only need to know which is closer.
    /// Also useful in physics calculations involving kinetic energy (proportional to v²).
    /// </remarks>
    /// <example>
    /// <code>
    /// // Fast distance comparison without square root
    /// LDistSqr1 := LPos1.MagnitudeSquared();
    /// LDistSqr2 := LPos2.MagnitudeSquared();
    /// if LDistSqr1 < LDistSqr2 then
    ///   // Pos1 is closer to origin
    /// </code>
    /// </example>
    function  MagnitudeSquared(): Single;
    /// <summary>
    /// Calculates the dot product with another vector
    /// </summary>
    /// <param name="AVector">Vector to calculate dot product with</param>
    /// <returns>Dot product value (scalar)</returns>
    /// <remarks>
    /// Dot product = x1*x2 + y1*y2 + z1*z2 + w1*w2.
    /// Result > 0 means acute angle, = 0 means perpendicular, < 0 means obtuse angle.
    /// Essential for determining relative direction and projection calculations.
    /// When both vectors are normalized, dot product equals cosine of angle between them.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if target is in front of player
    /// LDot := LPlayerForward.DotProduct(LToTarget);
    /// if LDot > 0 then
    ///   // Target is in front
    /// </code>
    /// </example>
    function  DotProduct(const AVector: TpxVector): Single;
    /// <summary>
    /// Scales this vector by a scalar value
    /// </summary>
    /// <param name="AValue">Scaling factor</param>
    /// <remarks>
    /// Multiplies all components by the scalar value: x*s, y*s, z*s, w*s.
    /// Values > 1 make the vector longer, values < 1 make it shorter.
    /// Negative values reverse the vector direction.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Double the velocity
    /// LVelocity.Scale(2.0);
    /// // Reverse direction
    /// LVelocity.Scale(-1.0);
    /// </code>
    /// </example>
    procedure Scale(const AValue: Single);
    /// <summary>
    /// Divides this vector by a scalar value
    /// </summary>
    /// <param name="AValue">Division factor</param>
    /// <remarks>
    /// Divides all components by the scalar value: x/s, y/s, z/s, w/s.
    /// Equivalent to scaling by 1/AValue but more intuitive for division operations.
    /// Be careful to avoid division by zero.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Halve the vector magnitude
    /// LVector.DivideBy(2.0);
    /// </code>
    /// </example>
    procedure DivideBy(const AValue: Single);
    /// <summary>
    /// Projects this vector onto another vector
    /// </summary>
    /// <param name="AVector">Vector to project onto</param>
    /// <returns>Projected vector component</returns>
    /// <remarks>
    /// Vector projection finds the component of this vector in the direction of AVector.
    /// Result is the "shadow" of this vector cast onto AVector's direction.
    /// Useful for decomposing motion into components, collision response, and physics.
    /// Formula: proj = (this·target / |target|²) * target
    /// </remarks>
    /// <example>
    /// <code>
    /// // Project velocity onto surface normal for collision response
    /// LNormalComponent := LVelocity.Project(LSurfaceNormal);
    /// </code>
    /// </example>
    function  Project(const AVector: TpxVector): TpxVector;
    /// <summary>
    /// Negates all components of this vector
    /// </summary>
    /// <remarks>
    /// Reverses the direction of the vector by multiplying all components by -1.
    /// Equivalent to Scale(-1.0) but more explicit for direction reversal.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Reverse velocity for bounce effect
    /// LVelocity.Negate();
    /// </code>
    /// </example>
    procedure Negate();
  end;

/// <summary>
  /// Pointer to TpxRect for reference passing and dynamic allocation
  /// </summary>
  /// <remarks>
  /// Used when you need to pass rectangles by reference or work with dynamically allocated rectangles.
  /// </remarks>
  { TRectangle }
  PpxRect = ^TpxRect;
  /// <summary>
  /// Rectangle representation with position and size for collision detection and area definitions
  /// </summary>
  /// <remarks>
  /// Used extensively for collision detection, UI layout, and area definitions in PIXELS.
  /// Coordinates follow standard 2D graphics convention: origin (0,0) at top-left.
  /// Position (x,y) represents the top-left corner, while w,h represent width and height.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Create a rectangle for collision detection
  /// LPlayerRect := TpxRect.Create(LPlayerX, LPlayerY, 32, 48);
  /// if LPlayerRect.Intersect(LEnemyRect) then
  ///   // Handle collision
  /// </code>
  /// </example>
  TpxRect = record
    /// <summary>
    /// X position (left edge of rectangle)
    /// </summary>
    /// <remarks>
    /// Represents the horizontal position of the rectangle's left edge in world coordinates.
    /// </remarks>
    x: Single;
    /// <summary>
    /// Y position (top edge of rectangle)
    /// </summary>
    /// <remarks>
    /// Represents the vertical position of the rectangle's top edge in world coordinates.
    /// </remarks>
    y: Single;
    /// <summary>
    /// Width of rectangle
    /// </summary>
    /// <remarks>
    /// Horizontal size of the rectangle. Must be positive for proper collision detection.
    /// </remarks>
    w: Single;
    /// <summary>
    /// Height of rectangle
    /// </summary>
    /// <remarks>
    /// Vertical size of the rectangle. Must be positive for proper collision detection.
    /// </remarks>
    h: Single;
    /// <summary>
    /// Creates a rectangle with specified position and size
    /// </summary>
    /// <param name="AX">X position (left edge)</param>
    /// <param name="AY">Y position (top edge)</param>
    /// <param name="AW">Width of rectangle</param>
    /// <param name="AH">Height of rectangle</param>
    /// <remarks>
    /// Creates a new rectangle with the specified dimensions. All parameters should be positive for width and height.
    /// </remarks>
    constructor Create(const AX, AY, AW, AH: Single);
    /// <summary>
    /// Assigns position and size values to the rectangle
    /// </summary>
    /// <param name="AX">X position (left edge)</param>
    /// <param name="AY">Y position (top edge)</param>
    /// <param name="AW">Width of rectangle</param>
    /// <param name="AH">Height of rectangle</param>
    /// <remarks>
    /// Updates an existing rectangle with new position and size values.
    /// </remarks>
    procedure Assign(const AX, AY, AW, AH: Single); overload;
    /// <summary>
    /// Copies all values from another rectangle
    /// </summary>
    /// <param name="ARect">Source rectangle to copy from</param>
    /// <remarks>
    /// Performs a complete copy of position and size from the source rectangle.
    /// </remarks>
    procedure Assign(const ARect: TpxRect); overload;
    /// <summary>
    /// Sets all rectangle values to zero
    /// </summary>
    /// <remarks>
    /// Resets the rectangle to zero position and size. Useful for initialization or clearing.
    /// </remarks>
    procedure Clear();
    /// <summary>
    /// Tests if this rectangle intersects with another rectangle
    /// </summary>
    /// <param name="ARect">Rectangle to test intersection with</param>
    /// <returns>True if rectangles overlap, False otherwise</returns>
    /// <remarks>
    /// Performs fast AABB (Axis-Aligned Bounding Box) intersection test.
    /// Essential for collision detection between rectangular game objects.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check collision between player and enemy
    /// if LPlayerRect.Intersect(LEnemyRect) then
    ///   // Handle collision damage
    /// </code>
    /// </example>
    function Intersect(const ARect: TpxRect): Boolean;
  end;
  /// <summary>
  /// Pointer to TpxSize for reference passing and dynamic allocation
  /// </summary>
  PpxSize = ^TpxSize;
  /// <summary>
  /// Size representation with width and height components
  /// </summary>
  /// <remarks>
  /// Used for representing dimensions of textures, windows, sprites, and other 2D objects.
  /// Commonly used in graphics operations and layout calculations.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Get texture dimensions
  /// LTextureSize := LTexture.GetSize();
  /// LCenterX := LTextureSize.w / 2;
  /// LCenterY := LTextureSize.h / 2;
  /// </code>
  /// </example>
  TpxSize = record
    /// <summary>
    /// Width component
    /// </summary>
    /// <remarks>
    /// Horizontal dimension in pixels or world units.
    /// </remarks>
    w: Single;
    /// <summary>
    /// Height component
    /// </summary>
    /// <remarks>
    /// Vertical dimension in pixels or world units.
    /// </remarks>
    h: Single;
    /// <summary>
    /// Creates a size with specified width and height
    /// </summary>
    /// <param name="AWidth">Width value</param>
    /// <param name="AHeight">Height value</param>
    /// <remarks>
    /// Creates a new size record with the specified dimensions.
    /// </remarks>
    constructor Create(const AWidth, AHeight: Single);
  end;
  /// <summary>
  /// Pointer to TpxRange for reference passing and dynamic allocation
  /// </summary>
  PpxRange = ^TpxRange;
  /// <summary>
  /// Range representation defining minimum and maximum bounds in 2D space
  /// </summary>
  /// <remarks>
  /// Used for defining camera boundaries, world limits, collision bounds, and constraining object movement.
  /// Essential for keeping objects within playable areas and implementing camera systems.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Define world boundaries for camera
  /// LWorldBounds := TpxRange.Create(0, 0, 2000, 1500);
  /// // Clamp camera position to stay within bounds
  /// LCamera.SetBounds(LWorldBounds.minx, LWorldBounds.miny, LWorldBounds.maxx, LWorldBounds.maxy);
  /// </code>
  /// </example>
  TpxRange = record
    /// <summary>
    /// Minimum X coordinate (left boundary)
    /// </summary>
    /// <remarks>
    /// Defines the leftmost allowed position in the range.
    /// </remarks>
    minx: Single;
    /// <summary>
    /// Minimum Y coordinate (top boundary)
    /// </summary>
    /// <remarks>
    /// Defines the topmost allowed position in the range.
    /// </remarks>
    miny: Single;
    /// <summary>
    /// Maximum X coordinate (right boundary)
    /// </summary>
    /// <remarks>
    /// Defines the rightmost allowed position in the range.
    /// </remarks>
    maxx: Single;
    /// <summary>
    /// Maximum Y coordinate (bottom boundary)
    /// </summary>
    /// <remarks>
    /// Defines the bottommost allowed position in the range.
    /// </remarks>
    maxy: Single;
    /// <summary>
    /// Creates a range with specified bounds
    /// </summary>
    /// <param name="AMinX">Minimum X coordinate</param>
    /// <param name="AMinY">Minimum Y coordinate</param>
    /// <param name="AMaxX">Maximum X coordinate</param>
    /// <param name="AMaxY">Maximum Y coordinate</param>
    /// <remarks>
    /// Creates a new range with the specified boundaries. Ensure min values are less than max values.
    /// </remarks>
    constructor Create(const AMinX, AMinY, AMaxX, AMaxY: Single);
  end;
  /// <summary>
  /// Result enumeration for line intersection calculations
  /// </summary>
  /// <remarks>
  /// Used by TpxMath.LineIntersection to indicate the result of line intersection tests.
  /// Essential for collision detection with line-based geometry.
  /// </remarks>
  /// <example>
  /// <code>
  /// LResult := TpxMath.LineIntersection(LX1, LY1, LX2, LY2, LX3, LY3, LX4, LY4, LIntX, LIntY);
  /// case LResult of
  ///   liTrue: // Lines intersect at (LIntX, LIntY)
  ///   liParallel: // Lines are parallel
  ///   liNone: // Lines don't intersect
  /// end;
  /// </code>
  /// </example>
  { TpxLineIntersection }
  TpxLineIntersection = (
    /// <summary>Lines do not intersect within their segments</summary>
    liNone,
    /// <summary>Lines intersect at a specific point</summary>
    liTrue,
    /// <summary>Lines are parallel and do not intersect</summary>
    liParallel
  );
  /// <summary>
  /// Ray representation for raycasting and intersection tests
  /// </summary>
  /// <remarks>
  /// Used for line-of-sight calculations, collision detection, physics queries, and shooting mechanics.
  /// Direction vector should be normalized for accurate distance calculations.
  /// Essential for implementing lasers, bullets, and visibility systems.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Create ray from player to mouse position
  /// LRay.Origin := LPlayerPosition;
  /// LRay.Direction := LMouseWorldPos;
  /// LRay.Direction.Subtract(LPlayerPosition);
  /// LRay.Direction.Normalize();
  /// // Test intersection with walls
  /// if TpxMath.RayIntersectsAABB(LRay, LWallRect, LDistance) then
  ///   // Hit detected at distance
  /// </code>
  /// </example>
  // Fast AABB vs Ray intersection
  TpxRay = record
    /// <summary>
    /// Starting point of the ray in world coordinates
    /// </summary>
    /// <remarks>
    /// Represents where the ray begins, such as player position or gun muzzle location.
    /// </remarks>
    Origin: TpxVector;
    /// <summary>
    /// Direction vector indicating ray direction (should be normalized)
    /// </summary>
    /// <remarks>
    /// Must be normalized (magnitude = 1) for accurate distance calculations.
    /// Points in the direction the ray travels from the origin.
    /// </remarks>
    Direction: TpxVector; // Should be normalized
  end;
  /// <summary>
  /// Oriented Bounding Box for precise collision detection of rotated rectangles
  /// </summary>
  /// <remarks>
  /// OBB provides accurate collision detection for rotated objects compared to AABB.
  /// More computationally expensive than AABB but essential for rotated sprite collision.
  /// Uses separating axis theorem for precise overlap detection.
  /// Perfect for rotated ships, cars, or any game object that rotates.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Set up OBB for rotated sprite collision
  /// LOBB.Center := LSpritePosition;
  /// LOBB.HalfWidth := LSpriteWidth / 2;
  /// LOBB.HalfHeight := LSpriteHeight / 2;
  /// LOBB.Rotation := LSpriteAngle;
  /// // Test collision with another OBB
  /// if TpxMath.OBBsOverlap(LOBB1, LOBB2) then
  ///   // Handle rotated collision
  /// </code>
  /// </example>
  // Oriented Bounding Box (OBB) collision
  TpxOBB = record
    /// <summary>
    /// Center point of the oriented bounding box
    /// </summary>
    /// <remarks>
    /// The geometric center around which the box rotates.
    /// Typically matches the sprite or object center.
    /// </remarks>
    Center: TpxVector;
    /// <summary>
    /// Half-width from center to edge (radius in X direction)
    /// </summary>
    /// <remarks>
    /// Distance from center to left/right edges before rotation.
    /// Should be half the object's width for proper collision detection.
    /// </remarks>
    HalfWidth: Single;
    /// <summary>
    /// Half-height from center to edge (radius in Y direction)
    /// </summary>
    /// <remarks>
    /// Distance from center to top/bottom edges before rotation.
    /// Should be half the object's height for proper collision detection.
    /// </remarks>
    HalfHeight: Single;
    /// <summary>
    /// Rotation angle in degrees
    /// </summary>
    /// <remarks>
    /// Clockwise rotation angle following PIXELS' degree convention.
    /// 0° = no rotation, 90° = rotated clockwise by 90 degrees.
    /// </remarks>
    Rotation: Single; // In degrees
  end;

/// <summary>
  /// Static class providing comprehensive mathematical utilities for 2D game development
  /// </summary>
  /// <remarks>
  /// TpxMath is the core mathematics library for PIXELS, providing optimized functions for:
  /// - Vector and geometry operations
  /// - Collision detection algorithms
  /// - Easing and interpolation functions
  /// - Random number generation
  /// - Angle calculations with precomputed lookup tables
  /// All angle parameters use degrees unless specified otherwise.
  /// The class uses precomputed sine/cosine lookup tables for optimal performance in real-time games.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Fast angle calculations
  /// LCos := TpxMath.AngleCos(45);
  /// LSin := TpxMath.AngleSin(45);
  /// // Collision detection
  /// if TpxMath.CirclesOverlap(LPos1, LRadius1, LPos2, LRadius2) then
  ///   // Handle collision
  /// // Smooth animations
  /// LValue := TpxMath.EaseLerp(0.0, 100.0, LProgress, pxEaseOutQuad);
  /// </code>
  /// </example>
  { TpxMath }
  TpxMath = class(TpxStaticObject)
  private class var
    FCosTable: array [0 .. 360] of Single;
    FSinTable: array [0 .. 360] of Single;
  private
    class constructor Create();
    class destructor  Destroy();
  public
    /// <summary>
    /// Generates a random integer within the specified range (inclusive)
    /// </summary>
    /// <param name="AMin">Minimum value (inclusive)</param>
    /// <param name="AMax">Maximum value (inclusive)</param>
    /// <returns>Random integer between AMin and AMax</returns>
    /// <remarks>
    /// Both AMin and AMax are included in the possible results.
    /// Uses high-quality random number generation suitable for games.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Generate a random number between 1 and 6 (dice roll)
    /// LDiceRoll := TpxMath.RandomRangeInt(1, 6);
    /// // Random enemy spawn position
    /// LEnemyX := TpxMath.RandomRangeInt(0, 800);
    /// </code>
    /// </example>
    class function  RandomRangeInt(const AMin, AMax: Integer): Integer; static;
    /// <summary>
    /// Generates a random floating-point number within the specified range
    /// </summary>
    /// <param name="AMin">Minimum value</param>
    /// <param name="AMax">Maximum value</param>
    /// <returns>Random float between AMin and AMax</returns>
    /// <remarks>
    /// Provides uniform distribution between the specified bounds.
    /// Perfect for generating random speeds, positions, or animation timings.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Generate random speed between 50.0 and 150.0
    /// LSpeed := TpxMath.RandomRangeFloat(50.0, 150.0);
    /// // Random particle lifetime
    /// LLifetime := TpxMath.RandomRangeFloat(1.0, 3.0);
    /// </code>
    /// </example>
    class function  RandomRangeFloat(const AMin, AMax: Single): Single; static;
    /// <summary>
    /// Generates a random boolean value (true or false)
    /// </summary>
    /// <returns>True or False with equal probability (50% each)</returns>
    /// <remarks>
    /// Useful for making random binary decisions in game logic.
    /// Each call has exactly 50% chance of returning true or false.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Randomly decide enemy direction
    /// if TpxMath.RandomBool() then
    ///   LEnemyDirection := 1
    /// else
    ///   LEnemyDirection := -1;
    /// // Random power-up spawn
    /// if TpxMath.RandomBool() then
    ///   SpawnHealthPack()
    /// else
    ///   SpawnAmmo();
    /// </code>
    /// </example>
    class function  RandomBool(): Boolean; static;
    /// <summary>
    /// Gets the current random number generator seed
    /// </summary>
    /// <returns>Current random seed value</returns>
    /// <remarks>
    /// Use this to save the current random state for reproducible sequences.
    /// Essential for implementing replay systems or deterministic gameplay.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Save random state for replay
    /// LSavedSeed := TpxMath.GetRandomSeed();
    /// // Later restore for identical sequence
    /// TpxMath.SetRandomSeed(LSavedSeed);
    /// </code>
    /// </example>
    class function  GetRandomSeed(): Integer; static;
    /// <summary>
    /// Sets the random number generator seed for reproducible sequences
    /// </summary>
    /// <param name="AValue">Seed value to use</param>
    /// <remarks>
    /// Setting the same seed will produce identical random sequences, useful for debugging and replay systems.
    /// Essential for deterministic gameplay where random events must be reproducible.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Set seed for reproducible random generation
    /// TpxMath.SetRandomSeed(12345);
    /// // All subsequent random calls will follow same pattern
    /// </code>
    /// </example>
    class procedure SetRandomSeed(const AValue: Integer); static;
    /// <summary>
    /// Fast cosine calculation using precomputed lookup table
    /// </summary>
    /// <param name="AAngle">Angle in degrees (0-360)</param>
    /// <returns>Cosine value (-1.0 to 1.0)</returns>
    /// <remarks>
    /// Much faster than standard cos() function, optimized for real-time games.
    /// Angle is automatically clamped to 0-360 range for table lookup.
    /// Essential for performance-critical code that needs frequent angle calculations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Calculate X component of direction vector
    /// LDirX := TpxMath.AngleCos(Round(LAngle)) * LSpeed;
    /// // Rotate point around origin
    /// LNewX := LX * TpxMath.AngleCos(LRotation) - LY * TpxMath.AngleSin(LRotation);
    /// </code>
    /// </example>
    class function  AngleCos(const AAngle: Integer): Single; static;
    /// <summary>
    /// Fast sine calculation using precomputed lookup table
    /// </summary>
    /// <param name="AAngle">Angle in degrees (0-360)</param>
    /// <returns>Sine value (-1.0 to 1.0)</returns>
    /// <remarks>
    /// Much faster than standard sin() function, optimized for real-time games.
    /// Angle is automatically clamped to 0-360 range for table lookup.
    /// Essential for performance-critical code that needs frequent angle calculations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Calculate Y component of direction vector
    /// LDirY := TpxMath.AngleSin(Round(LAngle)) * LSpeed;
    /// // Create circular motion
    /// LY := LCenterY + TpxMath.AngleSin(LTime * 90) * LRadius;
    /// </code>
    /// </example>
    class function  AngleSin(const AAngle: Integer): Single; static;
    /// <summary>
    /// Calculates the shortest angular difference between two angles
    /// </summary>
    /// <param name="ASrcAngle">Source angle in degrees</param>
    /// <param name="ADestAngle">Destination angle in degrees</param>
    /// <returns>Shortest angular difference (-180 to +180 degrees)</returns>
    /// <remarks>
    /// Handles 360-degree wrapping correctly. Positive result means clockwise rotation needed.
    /// Essential for smooth rotation animations that don't "spin the long way around".
    /// Always returns the shortest path between angles.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Rotate smoothly toward target
    /// LAngleDiff := TpxMath.AngleDifference(LCurrentAngle, LTargetAngle);
    /// LCurrentAngle := LCurrentAngle + LAngleDiff * 0.1; // 10% interpolation
    /// // Check if angles are nearly equal
    /// if Abs(TpxMath.AngleDifference(LAngle1, LAngle2)) < 5 then
    ///   // Angles are within 5 degrees
    /// </code>
    /// </example>
    class function  AngleDifference(const ASrcAngle, ADestAngle: Single): Single; static;
    /// <summary>
    /// Rotates a point around the origin by the specified angle
    /// </summary>
    /// <param name="AAngle">Rotation angle in degrees</param>
    /// <param name="AX">X coordinate to rotate (modified in-place)</param>
    /// <param name="AY">Y coordinate to rotate (modified in-place)</param>
    /// <remarks>
    /// Rotates point (AX, AY) around origin (0, 0) using 2D rotation matrix.
    /// For rotation around other points, translate to origin first, rotate, then translate back.
    /// Uses fast lookup table for sine/cosine calculations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Rotate a gun barrel offset relative to ship center
    /// LBarrelX := 20.0;
    /// LBarrelY := 0.0;
    /// TpxMath.AngleRotatePos(LShipAngle, LBarrelX, LBarrelY);
    /// LBarrelWorldX := LShipX + LBarrelX;
    /// LBarrelWorldY := LShipY + LBarrelY;
    /// </code>
    /// </example>
    class procedure AngleRotatePos(const AAngle: Single; var AX: Single; var AY: Single); static;
    /// <summary>
    /// Clamps a floating-point value to the specified range
    /// </summary>
    /// <param name="AValue">Value to clamp (modified in-place)</param>
    /// <param name="AMin">Minimum allowed value</param>
    /// <param name="AMax">Maximum allowed value</param>
    /// <param name="AWrap">If true, wraps value around range; if false, clamps to edges</param>
    /// <returns>The clamped value</returns>
    /// <remarks>
    /// When AWrap is true, values outside range wrap around (useful for angles).
    /// When AWrap is false, values are clamped to min/max (useful for positions).
    /// Essential for keeping values within valid ranges.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Keep angle in 0-360 range with wrapping
    /// TpxMath.ClipValueFloat(LAngle, 0, 360, True);
    /// // Keep health between 0-100 without wrapping
    /// TpxMath.ClipValueFloat(LHealth, 0, 100, False);
    /// // Constrain player position to screen bounds
    /// TpxMath.ClipValueFloat(LPlayerX, 0, 800, False);
    /// </code>
    /// </example>
    class function  ClipValueFloat(var AValue: Single; const AMin, AMax: Single; const AWrap: Boolean): Single; static;
    /// <summary>
    /// Clamps an integer value to the specified range
    /// </summary>
    /// <param name="AValue">Value to clamp (modified in-place)</param>
    /// <param name="AMin">Minimum allowed value</param>
    /// <param name="AMax">Maximum allowed value</param>
    /// <param name="AWrap">If true, wraps value around range; if false, clamps to edges</param>
    /// <returns>The clamped value</returns>
    /// <remarks>
    /// Integer version of ClipValueFloat with identical behavior.
    /// Perfect for array indices, discrete values, and integer-based game logic.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Keep array index in valid range
    /// TpxMath.ClipValueInt(LIndex, 0, 9, False);
    /// // Wrap menu selection around
    /// TpxMath.ClipValueInt(LMenuIndex, 0, 4, True);
    /// </code>
    /// </example>
    /// <seealso cref="ClipValueFloat"/>
    class function  ClipValueInt(var AValue: Integer; const AMin, AMax: Integer; const AWrap: Boolean): Integer; static;
    /// <summary>
    /// Tests if two integers have the same sign
    /// </summary>
    /// <param name="AValue1">First value</param>
    /// <param name="AValue2">Second value</param>
    /// <returns>True if both values have the same sign</returns>
    /// <remarks>
    /// Zero is considered to have a positive sign.
    /// Useful for determining if values point in the same direction.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if velocities are in same direction
    /// if TpxMath.SameSignExt(LVelX1, LVelX2) then
    ///   // Both moving in same horizontal direction
    /// </code>
    /// </example>
    class function  SameSignExt(const AValue1, AValue2: Integer): Boolean; static;
    /// <summary>
    /// Tests if two floating-point values have the same sign
    /// </summary>
    /// <param name="AValue1">First value</param>
    /// <param name="AValue2">Second value</param>
    /// <returns>True if both values have the same sign</returns>
    /// <remarks>
    /// Zero is considered to have a positive sign.
    /// Useful for determining if values point in the same direction.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if forces are opposing
    /// if not TpxMath.SameSignFloat(LForce1, LForce2) then
    ///   // Forces are in opposite directions
    /// </code>
    /// </example>
    class function  SameSignFloat(const AValue1, AValue2: Single): Boolean; static;
    /// <summary>
    /// Tests if two double-precision values are approximately equal
    /// </summary>
    /// <param name="AA">First value</param>
    /// <param name="AB">Second value</param>
    /// <param name="AEpsilon">Tolerance for comparison (0 = automatic)</param>
    /// <returns>True if values are within epsilon tolerance</returns>
    /// <remarks>
    /// Essential for floating-point comparisons due to precision errors.
    /// If AEpsilon is 0, an appropriate tolerance is calculated automatically.
    /// Never use direct equality (=) for floating-point comparisons.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Safe floating-point comparison
    /// if TpxMath.SameValueExt(LDistance, LTargetDistance, 0.1) then
    ///   // Distance is close enough to target
    /// // Automatic epsilon
    /// if TpxMath.SameValueExt(LCalculatedValue, LExpectedValue) then
    ///   // Values are essentially equal
    /// </code>
    /// </example>
    class function  SameValueExt(const AA, AB: Double; const AEpsilon: Double = 0): Boolean; static;
    /// <summary>
    /// Tests if two single-precision values are approximately equal
    /// </summary>
    /// <param name="AA">First value</param>
    /// <param name="AB">Second value</param>
    /// <param name="AEpsilon">Tolerance for comparison (0 = automatic)</param>
    /// <returns>True if values are within epsilon tolerance</returns>
    /// <remarks>
    /// Single-precision version of SameValueExt with identical behavior.
    /// Most commonly used version for game mathematics.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if player reached checkpoint
    /// if TpxMath.SameValueFloat(LPlayerX, LCheckpointX, 5.0) then
    ///   // Player is within 5 units of checkpoint
    /// </code>
    /// </example>
    /// <seealso cref="SameValueExt"/>
    class function  SameValueFloat(const AA, AB: Single; const AEpsilon: Single = 0): Boolean; static;
    /// <summary>
    /// Smoothly adjusts a value with acceleration and drag physics
    /// </summary>
    /// <param name="AValue">Current value to modify (modified in-place)</param>
    /// <param name="AAmount">Acceleration amount to apply</param>
    /// <param name="AMax">Maximum absolute value</param>
    /// <param name="ADrag">Drag/friction amount when no acceleration</param>
    /// <remarks>
    /// Perfect for implementing ship controls or character movement with momentum.
    /// When AAmount is 0, drag is applied to slow down the value naturally.
    /// Provides realistic physics-based movement feel.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth spaceship movement with acceleration and drag
    /// if TpxInput.KeyDown(pxKEY_LEFT) then
    ///   TpxMath.SmoothMove(LVelocityX, -5.0, 200.0, 10.0)
    /// else
    ///   TpxMath.SmoothMove(LVelocityX, 0, 200.0, 10.0);
    /// // Apply velocity to position
    /// LPlayerX := LPlayerX + LVelocityX;
    /// </code>
    /// </example>
    class procedure SmoothMove(var AValue: Single; const AAmount, AMax, ADrag: Single); static;
    /// <summary>
    /// Linear interpolation between two values
    /// </summary>
    /// <param name="AFrom">Starting value</param>
    /// <param name="ATo">Ending value</param>
    /// <param name="ATime">Interpolation factor (0.0 to 1.0)</param>
    /// <returns>Interpolated value between AFrom and ATo</returns>
    /// <remarks>
    /// ATime = 0.0 returns AFrom, ATime = 1.0 returns ATo, ATime = 0.5 returns midpoint.
    /// Values outside 0.0-1.0 range will extrapolate beyond the endpoints.
    /// Foundation for all interpolation and animation systems.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Fade between two colors over time
    /// LCurrentAlpha := TpxMath.Lerp(0.0, 1.0, LFadeProgress);
    /// // Smooth camera movement
    /// LCameraX := TpxMath.Lerp(LCurrentX, LTargetX, 0.05);
    /// </code>
    /// </example>
    class function  Lerp(const AFrom, ATo, ATime: Double): Double; static;

    /// <summary>
    /// Tests if a point lies within a rectangle
    /// </summary>
    /// <param name="APoint">Point to test</param>
    /// <param name="ARect">Rectangle bounds</param>
    /// <returns>True if point is inside rectangle</returns>
    /// <remarks>
    /// Fast AABB point-in-rectangle test using simple coordinate comparisons.
    /// Essential for UI hit testing and simple collision detection.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if mouse click hit button
    /// if TpxMath.PointInRectangle(LMousePos, LButtonRect) then
    ///   LButton.OnClick();
    /// </code>
    /// </example>
    class function  PointInRectangle(const APoint: TpxVector; const ARect: TpxRect): Boolean;
    /// <summary>
    /// Tests if a point lies within a circle
    /// </summary>
    /// <param name="APoint">Point to test</param>
    /// <param name="ACenter">Circle center</param>
    /// <param name="ARadius">Circle radius</param>
    /// <returns>True if point is inside circle</returns>
    /// <remarks>
    /// Uses squared distance comparison to avoid expensive square root calculation.
    /// Perfect for circular UI elements and point-to-circle collision.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if click hit circular button
    /// if TpxMath.PointInCircle(LMousePos, LButtonCenter, 25) then
    ///   LCircularButton.OnClick();
    /// </code>
    /// </example>
    class function  PointInCircle(const APoint, ACenter: TpxVector; const ARadius: Single): Boolean;
    /// <summary>
    /// Tests if a point lies within a triangle using barycentric coordinates
    /// </summary>
    /// <param name="APoint">Point to test</param>
    /// <param name="APoint1">First triangle vertex</param>
    /// <param name="APoint2">Second triangle vertex</param>
    /// <param name="APoint3">Third triangle vertex</param>
    /// <returns>True if point is inside triangle</returns>
    /// <remarks>
    /// Handles degenerate triangles (zero area) correctly by returning false.
    /// Useful for complex collision shapes and navigation mesh queries.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if point is in triangular region
    /// if TpxMath.PointInTriangle(LPos, LVertex1, LVertex2, LVertex3) then
    ///   // Point is inside triangle
    /// </code>
    /// </example>
    class function  PointInTriangle(const APoint, APoint1, APoint2, APoint3: TpxVector): Boolean;
    /// <summary>
    /// Tests if two circles overlap
    /// </summary>
    /// <param name="ACenter1">First circle center</param>
    /// <param name="ARadius1">First circle radius</param>
    /// <param name="ACenter2">Second circle center</param>
    /// <param name="ARadius2">Second circle radius</param>
    /// <returns>True if circles overlap</returns>
    /// <remarks>
    /// Fastest collision detection method. Perfect for bullets, enemies, and power-ups.
    /// Uses squared distance calculation to avoid expensive square root operations.
    /// Most commonly used collision detection function in 2D games.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check bullet collision with enemy
    /// if TpxMath.CirclesOverlap(LBulletPos, 2.0, LEnemyPos, 15.0) then
    /// begin
    ///   // Handle collision
    ///   LEnemyHealth := LEnemyHealth - LBulletDamage;
    ///   LBullet.Destroy();
    /// end;
    /// </code>
    /// </example>
    class function  CirclesOverlap(const ACenter1: TpxVector; const ARadius1: Single; const ACenter2: TpxVector; const ARadius2: Single): Boolean;
    /// <summary>
    /// Tests if a circle intersects with a rectangle
    /// </summary>
    /// <param name="ACenter">Circle center</param>
    /// <param name="ARadius">Circle radius</param>
    /// <param name="ARect">Rectangle bounds</param>
    /// <returns>True if circle intersects rectangle</returns>
    /// <remarks>
    /// Useful for circular objects colliding with rectangular obstacles or platforms.
    /// Handles edge cases where circle touches rectangle corners correctly.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if ball hits platform
    /// if TpxMath.CircleInRectangle(LBallPos, LBallRadius, LPlatformRect) then
    ///   LBall.Bounce();
    /// </code>
    /// </example>
    class function  CircleInRectangle(const ACenter: TpxVector; const ARadius: Single; const ARect: TpxRect): Boolean;
    /// <summary>
    /// Tests if two rectangles overlap
    /// </summary>
    /// <param name="ARect1">First rectangle</param>
    /// <param name="ARect2">Second rectangle</param>
    /// <returns>True if rectangles overlap</returns>
    /// <remarks>
    /// Fast AABB (Axis-Aligned Bounding Box) collision detection.
    /// Good for platforms, UI elements, and non-rotated sprites.
    /// More accurate than circle collision for rectangular objects.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check platform collision
    /// if TpxMath.RectanglesOverlap(LPlayerRect, LPlatformRect) then
    ///   LPlayer.OnPlatform := True;
    /// </code>
    /// </example>
    class function  RectanglesOverlap(const ARect1, ARect2: TpxRect): Boolean;
    /// <summary>
    /// Calculates the intersection area of two rectangles
    /// </summary>
    /// <param name="ARect1">First rectangle</param>
    /// <param name="ARect2">Second rectangle</param>
    /// <returns>Rectangle representing the intersection area</returns>
    /// <remarks>
    /// If rectangles don't overlap, returns a rectangle with zero width and height.
    /// Useful for determining overlap regions, damage calculations, and clipping.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Calculate damage based on overlap area
    /// LOverlap := TpxMath.RectangleIntersection(LExplosionRect, LEnemyRect);
    /// LDamage := (LOverlap.w * LOverlap.h) / (LEnemyRect.w * LEnemyRect.h);
    /// </code>
    /// </example>
    class function  RectangleIntersection(const ARect1, ARect2: TpxRect): TpxRect;
    /// <summary>
    /// Calculates intersection point of two line segments
    /// </summary>
    /// <param name="AX1">First line start X</param>
    /// <param name="AY1">First line start Y</param>
    /// <param name="AX2">First line end X</param>
    /// <param name="AY2">First line end Y</param>
    /// <param name="AX3">Second line start X</param>
    /// <param name="AY3">Second line start Y</param>
    /// <param name="AX4">Second line end X</param>
    /// <param name="AY4">Second line end Y</param>
    /// <param name="AX">Output intersection X coordinate</param>
    /// <param name="AY">Output intersection Y coordinate</param>
    /// <returns>Intersection result type</returns>
    /// <remarks>
    /// Returns intersection coordinates in AX, AY when result is liTrue.
    /// Useful for laser/bullet collision with walls or line-based obstacles.
    /// Handles parallel lines and edge cases correctly.
    /// </remarks>
    /// <example>
    /// <code>
    /// LResult := TpxMath.LineIntersection(LX1, LY1, LX2, LY2, LWallX1, LWallY1, LWallX2, LWallY2, LHitX, LHitY);
    /// if LResult = liTrue then
    ///   SpawnImpactEffect(LHitX, LHitY);
    /// </code>
    /// </example>
    class function  LineIntersection(const AX1, AY1, AX2, AY2, AX3, AY3, AX4, AY4: Integer; var AX: Integer; var AY: Integer): TpxLineIntersection;
    /// <summary>
    /// Calculates shortest distance from a point to an infinite line
    /// </summary>
    /// <param name="APoint">Point to measure from</param>
    /// <param name="ALineStart">Line start point</param>
    /// <param name="ALineEnd">Line end point</param>
    /// <returns>Perpendicular distance to line</returns>
    /// <remarks>
    /// Calculates distance to infinite line, not line segment.
    /// Result is always positive (absolute distance).
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if enemy is close to player's path
    /// LDistance := TpxMath.PointToLineDistance(LEnemyPos, LPathStart, LPathEnd);
    /// if LDistance < 50 then
    ///   LEnemyAlert := True;
    /// </code>
    /// </example>
    class function  PointToLineDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
    /// <summary>
    /// Calculates shortest distance from a point to a line segment
    /// </summary>
    /// <param name="APoint">Point to measure from</param>
    /// <param name="ALineStart">Line segment start</param>
    /// <param name="ALineEnd">Line segment end</param>
    /// <returns>Distance to closest point on line segment</returns>
    /// <remarks>
    /// Unlike PointToLineDistance, this considers the line segment endpoints.
    /// If closest point is beyond segment endpoints, returns distance to nearest endpoint.
    /// More accurate for finite line segments like walls or platforms.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Find closest point on wall for AI pathfinding
    /// LDistance := TpxMath.PointToLineSegmentDistance(LAIPos, LWallStart, LWallEnd);
    /// </code>
    /// </example>
    class function  PointToLineSegmentDistance(const APoint, ALineStart, ALineEnd: TpxVector): Single;
    /// <summary>
    /// Tests if a line segment intersects with a circle
    /// </summary>
    /// <param name="ALineStart">Line segment start</param>
    /// <param name="ALineEnd">Line segment end</param>
    /// <param name="ACenter">Circle center</param>
    /// <param name="ARadius">Circle radius</param>
    /// <returns>True if line segment intersects circle</returns>
    /// <remarks>
    /// Useful for laser/bullet collision with circular enemies or obstacles.
    /// More accurate than point-based collision for fast-moving projectiles.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if laser beam hits circular enemy
    /// if TpxMath.LineSegmentIntersectsCircle(LLaserStart, LLaserEnd, LEnemyPos, LEnemyRadius) then
    ///   LEnemyHealth := LEnemyHealth - LLaserDamage;
    /// </code>
    /// </example>
    class function  LineSegmentIntersectsCircle(const ALineStart, ALineEnd, ACenter: TpxVector; const ARadius: Single): Boolean;
    /// <summary>
    /// Finds the closest point on a line segment to a given point
    /// </summary>
    /// <param name="APoint">Reference point</param>
    /// <param name="ALineStart">Line segment start</param>
    /// <param name="ALineEnd">Line segment end</param>
    /// <returns>Closest point on the line segment</returns>
    /// <remarks>
    /// Result will be somewhere on the line segment between start and end points.
    /// Useful for finding contact points, reflection calculations, and AI navigation.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Find closest point on wall for collision response
    /// LClosestPoint := TpxMath.ClosestPointOnLineSegment(LPlayerPos, LWallStart, LWallEnd);
    /// // Calculate reflection direction
    /// LReflection := LPlayerPos;
    /// LReflection.Subtract(LClosestPoint);
    /// </code>
    /// </example>
    class function  ClosestPointOnLineSegment(const APoint, ALineStart, ALineEnd: TpxVector): TpxVector;
    /// <summary>
    /// Tests if two Oriented Bounding Boxes (OBBs) overlap
    /// </summary>
    /// <param name="AOBB1">First oriented bounding box</param>
    /// <param name="AOBB2">Second oriented bounding box</param>
    /// <returns>True if OBBs overlap</returns>
    /// <remarks>
    /// More accurate than AABB collision for rotated objects but computationally more expensive.
    /// Essential for collision detection between rotated sprites like ships, cars, or planes.
    /// Uses separating axis theorem for precise detection.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check collision between two rotated sprites
    /// LOBB1.Center := LSprite1Position;
    /// LOBB1.HalfWidth := LSprite1Width / 2;
    /// LOBB1.HalfHeight := LSprite1Height / 2;
    /// LOBB1.Rotation := LSprite1Angle;
    /// // Similar setup for LOBB2...
    /// if TpxMath.OBBsOverlap(LOBB1, LOBB2) then
    ///   // Handle rotated collision
    /// </code>
    /// </example>
    class function  OBBsOverlap(const AOBB1, AOBB2: TpxOBB): Boolean;
    /// <summary>
    /// Tests if a point lies within a convex polygon
    /// </summary>
    /// <param name="APoint">Point to test</param>
    /// <param name="AVertices">Array of polygon vertices in order</param>
    /// <returns>True if point is inside polygon</returns>
    /// <remarks>
    /// Only works with convex polygons. Vertices must be specified in consistent order.
    /// Useful for complex collision shapes, navigation areas, and trigger zones.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if player is in safe zone
    /// LSafeZone := [TpxVector.Create(100, 100), TpxVector.Create(200, 100),
    ///               TpxVector.Create(200, 200), TpxVector.Create(100, 200)];
    /// if TpxMath.PointInConvexPolygon(LPlayerPos, LSafeZone) then
    ///   LPlayerSafe := True;
    /// </code>
    /// </example>
    class function  PointInConvexPolygon(const APoint: TpxVector; const AVertices: array of TpxVector): Boolean;
    /// <summary>
    /// Tests if a ray intersects with an Axis-Aligned Bounding Box
    /// </summary>
    /// <param name="ARay">Ray with origin and direction</param>
    /// <param name="ARect">AABB rectangle</param>
    /// <param name="ADistance">Output parameter for intersection distance</param>
    /// <returns>True if ray intersects AABB</returns>
    /// <remarks>
    /// Fast algorithm for raycasting against rectangular objects.
    /// ADistance contains the distance from ray origin to intersection point.
    /// Essential for line-of-sight, shooting mechanics, and physics queries.
    /// Ray direction should be normalized for accurate distance calculations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Check if enemy can see player (line of sight)
    /// LRay.Origin := LEnemyPosition;
    /// LRay.Direction := LPlayerPos;
    /// LRay.Direction.Subtract(LEnemyPos);
    /// LRay.Direction.Normalize();
    /// if TpxMath.RayIntersectsAABB(LRay, LWallRect, LDistance) then
    ///   // Wall blocks line of sight
    /// else
    ///   // Clear line of sight to player
    /// </code>
    /// </example>
    class function  RayIntersectsAABB(const ARay: TpxRay; const ARect: TpxRect; out ADistance: Single): Boolean;

    /// <summary>
    /// Applies easing function to interpolate between values over time
    /// </summary>
    /// <param name="ACurrentTime">Current time position</param>
    /// <param name="AStartValue">Starting value</param>
    /// <param name="AChangeInValue">Total change in value</param>
    /// <param name="ADuration">Total duration</param>
    /// <param name="AEase">Easing function to apply</param>
    /// <returns>Eased value at current time</returns>
    /// <remarks>
    /// Classic easing function signature. Final value = AStartValue + AChangeInValue.
    /// Essential for smooth animations, UI transitions, and game object movement.
    /// Time-based approach perfect for frame-rate independent animations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth fade-in animation over 2 seconds
    /// LAlpha := TpxMath.EaseValue(LCurrentTime, 0.0, 1.0, 2.0, pxEaseInOutQuad);
    /// // Smooth position animation
    /// LPosX := TpxMath.EaseValue(LAnimTime, 100.0, 200.0, 3.0, pxEaseOutBounce);
    /// </code>
    /// </example>
    class function  EaseValue(const ACurrentTime, AStartValue, AChangeInValue, ADuration: Double; const AEase: TpxEase): Double; static;
    /// <summary>
    /// Calculates easing curve value based on current position along a path
    /// </summary>
    /// <param name="AStartPos">Starting position</param>
    /// <param name="AEndPos">Ending position</param>
    /// <param name="ACurrentPos">Current position</param>
    /// <param name="AEase">Easing function</param>
    /// <returns>Eased progress value (0-100)</returns>
    /// <remarks>
    /// Useful when you know positions but want to convert to eased progress percentage.
    /// Less commonly used than other easing functions.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Convert position to eased progress
    /// LProgress := TpxMath.EasePosition(0.0, 100.0, LCurrentPos, pxEaseInQuad);
    /// </code>
    /// </example>
    class function  EasePosition(const AStartPos, AEndPos, ACurrentPos: Double; const AEase: TpxEase): Double; static;
    /// <summary>
    /// Applies easing to a normalized progress value (0.0 to 1.0)
    /// </summary>
    /// <param name="AProgress">Progress value from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function to apply</param>
    /// <returns>Eased progress value from 0.0 to 1.0</returns>
    /// <remarks>
    /// Most commonly used easing function. Perfect for progress-based animations.
    /// Input and output are both normalized to 0.0-1.0 range.
    /// Ideal when you have a progress percentage and want to apply easing.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth UI element slide-in
    /// LEasedProgress := TpxMath.EaseNormalized(LAnimProgress, pxEaseOutBounce);
    /// LElementX := TpxMath.Lerp(-100, 50, LEasedProgress);
    /// </code>
    /// </example>
    class function  EaseNormalized(const AProgress: Double; const AEase: TpxEase): Double;
    /// <summary>
    /// Linear interpolation between two values with easing applied
    /// </summary>
    /// <param name="AFrom">Starting value</param>
    /// <param name="ATo">Ending value</param>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function</param>
    /// <returns>Eased interpolated value</returns>
    /// <remarks>
    /// Combines linear interpolation with easing for smooth value transitions.
    /// Most versatile easing function for animating any numeric property.
    /// Perfect for animating positions, scales, colors, or any continuous values.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth camera zoom with easing
    /// LCurrentZoom := TpxMath.EaseLerp(1.0, 3.0, LZoomProgress, pxEaseInOutCubic);
    /// // Animate button scale on hover
    /// LButtonScale := TpxMath.EaseLerp(1.0, 1.2, LHoverProgress, pxEaseOutElastic);
    /// </code>
    /// </example>
    class function  EaseLerp(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
    /// <summary>
    /// Applies easing to interpolate between two vectors
    /// </summary>
    /// <param name="AFrom">Starting vector</param>
    /// <param name="ATo">Ending vector</param>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function</param>
    /// <returns>Eased interpolated vector</returns>
    /// <remarks>
    /// Perfect for animating positions, scaling, or any vector-based properties.
    /// Each component (x, y, z, w) is eased independently using the same curve.
    /// Essential for smooth object movement and transformation animations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth object movement along path
    /// LCurrentPos := TpxMath.EaseVector(LStartPos, LEndPos, LMoveProgress, pxEaseInOutSine);
    /// // Animate sprite scaling
    /// LCurrentScale := TpxMath.EaseVector(LStartScale, LEndScale, LScaleProgress, pxEaseOutBack);
    /// </code>
    /// </example>
    class function  EaseVector(const AFrom, ATo: TpxVector; const AProgress: Double; const AEase: TpxEase): TpxVector;
    /// <summary>
    /// Smooth interpolation using smoothstep function (3t² - 2t³)
    /// </summary>
    /// <param name="AFrom">Starting value</param>
    /// <param name="ATo">Ending value</param>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <returns>Smoothly interpolated value</returns>
    /// <remarks>
    /// Classic smoothstep function providing smooth acceleration and deceleration.
    /// Good general-purpose easing when you don't need specific easing curves.
    /// Faster than complex easing functions while still providing smooth motion.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Simple smooth transition
    /// LValue := TpxMath.EaseSmooth(0.0, 100.0, LProgress);
    /// </code>
    /// </example>
    class function  EaseSmooth(const AFrom, ATo: Double; const AProgress: Double): Double;
    /// <summary>
    /// Eases between two angles with proper 360-degree wrapping
    /// </summary>
    /// <param name="AFrom">Starting angle in degrees</param>
    /// <param name="ATo">Ending angle in degrees</param>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function</param>
    /// <returns>Eased angle in degrees (0-360 range)</returns>
    /// <remarks>
    /// Automatically chooses shortest rotation path, preventing "long way around" spinning.
    /// Essential for smooth rotation animations of sprites, turrets, and UI elements.
    /// Handles angle wrapping correctly across the 0/360 degree boundary.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Smooth turret rotation to target
    /// LCurrentAngle := TpxMath.EaseAngle(LTurretAngle, LTargetAngle, LRotateProgress, pxEaseOutQuad);
    /// // Smooth camera rotation
    /// LCameraAngle := TpxMath.EaseAngle(LCurrentAngle, LTargetAngle, 0.05, pxEaseLinearTween);
    /// </code>
    /// </example>
    class function  EaseAngle(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
    /// <summary>
    /// Animates through multiple keyframe values with easing
    /// </summary>
    /// <param name="AKeyframes">Array of keyframe values</param>
    /// <param name="AProgress">Overall progress from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function applied to each segment</param>
    /// <returns>Interpolated value between appropriate keyframes</returns>
    /// <remarks>
    /// Perfect for complex animations with multiple waypoints or color transitions.
    /// Progress is distributed evenly across all keyframe segments.
    /// Each segment between keyframes uses the same easing function.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Animate through multiple positions
    /// LKeyframes := [0.0, 100.0, 50.0, 200.0]; // X positions
    /// LCurrentX := TpxMath.EaseKeyframes(LKeyframes, LAnimProgress, pxEaseInOutQuad);
    /// // Traffic light color animation: red -> yellow -> green
    /// LRedKeyframes := [1.0, 1.0, 0.0]; // Red component
    /// LRedValue := TpxMath.EaseKeyframes(LRedKeyframes, LLightProgress, pxEaseLinearTween);
    /// </code>
    /// </example>
    class function  EaseKeyframes(const AKeyframes: array of Double; const AProgress: Double; const AEase: TpxEase): Double;
    /// <summary>
    /// Creates looping animations with various repeat modes
    /// </summary>
    /// <param name="ATime">Current time</param>
    /// <param name="ADuration">Loop duration</param>
    /// <param name="AEase">Easing function</param>
    /// <param name="ALoopMode">How the animation should loop</param>
    /// <returns>Eased value for current loop position</returns>
    /// <remarks>
    /// Essential for creating repeating animations like floating pickups, pulsing UI, or idle animations.
    /// Different loop modes provide variety in animation behavior.
    /// Time-based system ensures consistent animation speed regardless of framerate.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Pulsing power-up with ping-pong loop
    /// LPulseScale := TpxMath.EaseLoop(LGameTime, 2.0, pxEaseInOutSine, pxLoopPingPong);
    /// LFinalScale := 1.0 + (LPulseScale * 0.2); // Scale from 1.0 to 1.2 and back
    /// // Rotating platform
    /// LRotation := TpxMath.EaseLoop(LGameTime, 5.0, pxEaseLinearTween, pxLoopRepeat) * 360;
    /// </code>
    /// </example>
    class function  EaseLoop(const ATime, ADuration: Double; const AEase: TpxEase; const ALoopMode: TpxLoopMode): Double;
    /// <summary>
    /// Creates stepped/discrete easing for pixel-perfect animations
    /// </summary>
    /// <param name="AFrom">Starting value</param>
    /// <param name="ATo">Ending value</param>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="ASteps">Number of discrete steps</param>
    /// <param name="AEase">Easing function</param>
    /// <returns>Stepped eased value</returns>
    /// <remarks>
    /// Perfect for retro-style animations or when you need discrete value changes.
    /// Useful for frame-based sprites, step-wise UI transitions, or quantized animations.
    /// Combines smooth easing curves with discrete output values.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Discrete health bar animation (10 segments)
    /// LHealthSteps := TpxMath.EaseStepped(0.0, 10.0, LHealthProgress, 10, pxEaseOutQuad);
    /// // Retro-style position animation
    /// LPixelX := TpxMath.EaseStepped(0.0, 100.0, LMoveProgress, 25, pxEaseInOutCubic);
    /// </code>
    /// </example>
    class function  EaseStepped(const AFrom, ATo: Double; const AProgress: Double; const ASteps: Integer; const AEase: TpxEase): Double;
    /// <summary>
    /// Spring-based easing for natural physics motion
    /// </summary>
    /// <param name="ATime">Time value from 0.0 to 1.0</param>
    /// <param name="AAmplitude">Spring amplitude (default 1.0)</param>
    /// <param name="APeriod">Spring period/frequency (default 0.3)</param>
    /// <returns>Spring-based eased value</returns>
    /// <remarks>
    /// Provides natural bouncing motion like a spring or elastic band.
    /// Great for UI elements that should have satisfying, physics-based feel.
    /// Higher amplitude creates more pronounced oscillations.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Bouncy button press effect
    /// LButtonScale := 1.0 + TpxMath.EaseSpring(LPressProgress, 0.3, 0.2) * 0.1;
    /// // Spring-loaded door opening
    /// LDoorAngle := TpxMath.EaseSpring(LOpenProgress, 1.2, 0.4) * 90;
    /// </code>
    /// </example>
    class function  EaseSpring(const ATime: Double; const AAmplitude: Double = 1.0; const APeriod: Double = 0.3): Double;
    /// <summary>
    /// Custom Bezier curve easing for precise control
    /// </summary>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="AX1">First control point X</param>
    /// <param name="AY1">First control point Y</param>
    /// <param name="AX2">Second control point X</param>
    /// <param name="AY2">Second control point Y</param>
    /// <returns>Bezier-eased value</returns>
    /// <remarks>
    /// Allows creation of custom easing curves using Bezier control points.
    /// Advanced feature for designers who need precise animation timing control.
    /// Control points define the shape of the easing curve.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Custom easing curve matching CSS cubic-bezier
    /// LCustomEase := TpxMath.EaseBezier(LProgress, 0.25, 0.1, 0.25, 1.0);
    /// </code>
    /// </example>
    class function  EaseBezier(const AProgress: Double; const AX1, AY1, AX2, AY2: Double): Double;
    /// <summary>
    /// Advanced easing with customizable parameters for elastic and back functions
    /// </summary>
    /// <param name="AProgress">Progress from 0.0 to 1.0</param>
    /// <param name="AEase">Easing function type</param>
    /// <param name="AParams">Parameters for customization</param>
    /// <returns>Eased value with custom parameters applied</returns>
    /// <remarks>
    /// Provides fine-tuned control over elastic, back, and spring easing functions.
    /// Use when default easing parameters don't provide the desired effect.
    /// Allows customization of amplitude, period, and overshoot values.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Custom elastic bounce with specific amplitude and period
    /// LParams.Amplitude := 1.5;
    /// LParams.Period := 0.4;
    /// LParams.Overshoot := 1.2;
    /// LValue := TpxMath.EaseWithParams(LProgress, pxEaseOutElastic, LParams);
    /// </code>
    /// </example>
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

// Normalized easing - returns 0.0 to 1.0 curve value
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

// Interpolate between any two values with easing
class function TpxMath.EaseLerp(const AFrom, ATo: Double; const AProgress: Double; const AEase: TpxEase): Double;
var
  LNormalizedCurve: Double;
begin
  LNormalizedCurve := EaseNormalized(AProgress, AEase);
  Result := AFrom + (ATo - AFrom) * LNormalizedCurve;
end;

// Vector/Point easing
class function TpxMath.EaseVector(const AFrom, ATo: TpxVector; const AProgress: Double; const AEase: TpxEase): TpxVector;
begin
  Result.X := EaseLerp(AFrom.X, ATo.X, AProgress, AEase);
  Result.Y := EaseLerp(AFrom.Y, ATo.Y, AProgress, AEase);
end;

// Smooth interpolation (smoothstep function - very commonly used)
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

// Angle easing (handles 360° wrapping)
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

// Multi-keyframe easing (animate through multiple points)
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

// Looping/repeating animations
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

// Stepped/discrete easing (for pixel-perfect or discrete animations)
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

// Spring-based easing (more natural physics motion)
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

// Bezier curve easing (custom curves)
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

// Easing with overshoot/undershoot control
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
