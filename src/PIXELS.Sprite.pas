unit PIXELS.Sprite;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Math,
  PIXELS.Deps,
  PIXELS.Base,
  PIXELS.Math,
  PIXELS.Graphics,
  PIXELS.IO;

type
  // Forward declarations
  TpxSprite = class;
  TpxTextureAtlas = class;

  /// <summary>
  /// Defines the collision detection method to use for sprite collision checking.
  /// Different methods offer trade-offs between accuracy and performance.
  /// </summary>
  /// <remarks>
  /// cmAuto automatically selects the best method based on sprite properties.
  /// cmCircle is fastest for circular objects like bullets and pickups.
  /// cmAABB is fast for rectangular objects and platforms.
  /// cmOBB handles rotated sprites with moderate performance cost.
  /// cmPixelPerfect provides ultra-precise collision at the highest performance cost.
  /// </remarks>
  TpxCollisionMethod = (
    cmAuto,        // Choose best method automatically
    cmCircle,      // Fastest - perfect for bullets, enemies, pickups
    cmAABB,        // Fast - platforms, simple rectangular objects
    cmOBB,         // Moderate - rotated sprites, complex shapes
    cmPixelPerfect // Slowest - ultra-precise collision when needed
  );

  /// <summary>
  /// Defines how sprite animations should play and loop.
  /// Controls the playback behavior of animation sequences.
  /// </summary>
  /// <remarks>
  /// Used in conjunction with animation sequences to control playback flow.
  /// amOnce is ideal for one-shot effects like explosions.
  /// amLoop is perfect for idle animations and continuous effects.
  /// amPingPong creates smooth back-and-forth motion.
  /// amReverse plays animations backwards in a loop.
  /// </remarks>
  TpxAnimationMode = (
    amOnce,     // Play once and stop
    amLoop,     // Loop continuously
    amPingPong, // Play forward then backward
    amReverse   // Play in reverse
  );

  /// <summary>
  /// Event callback triggered when a sprite animation sequence completes.
  /// </summary>
  /// <param name="ASprite">The sprite whose animation completed</param>
  /// <param name="AAnimationName">The name of the animation that completed</param>
  /// <remarks>
  /// Only fires for amOnce animations or when amPingPong completes a full cycle.
  /// Use this to chain animations or trigger game logic based on animation completion.
  /// </remarks>
  TpxAnimationCompleteEvent = procedure(const ASprite: TpxSprite; const AAnimationName: string) of object;

  /// <summary>
  /// Event callback triggered when a sprite animation advances to a new frame.
  /// </summary>
  /// <param name="ASprite">The sprite whose frame changed</param>
  /// <param name="AFrameIndex">The new frame index (0-based)</param>
  /// <remarks>
  /// Fires every time the animation frame changes during playback.
  /// Useful for frame-based sound effects or gameplay triggers.
  /// </remarks>
  TpxAnimationFrameEvent = procedure(const ASprite: TpxSprite; const AFrameIndex: Integer) of object;

  /// <summary>
  /// Defines a named animation sequence with frame range and playback properties.
  /// Used to create reusable animation definitions within a texture atlas.
  /// </summary>
  /// <remarks>
  /// Animation sequences reference frame indices within a texture atlas group.
  /// FrameSpeed is measured in frames per second (fps).
  /// StartFrame and EndFrame are inclusive indices.
  /// </remarks>
  TpxAnimationSequence = record
    Name: string;
    StartFrame: Integer;
    EndFrame: Integer;
    FrameSpeed: Single;
    Mode: TpxAnimationMode;
  end;

  /// <summary>
  /// Defines a rectangular region within a texture page, used for sprite frames.
  /// Links a texture coordinate rectangle to a specific texture index.
  /// </summary>
  /// <remarks>
  /// TextureIndex refers to the texture page within the atlas.
  /// Rect defines the pixel coordinates within that texture page.
  /// Used internally by the texture atlas system for efficient sprite rendering.
  /// </remarks>
  TpxTextureRegion = record
    Rect: TpxRect;
    TextureIndex: Integer;
  end;

  /// <summary>
  /// Manages multiple texture pages and organizes sprite frames into logical groups.
  /// Provides efficient storage and access to sprite animation data.
  /// </summary>
  /// <remarks>
  /// A texture atlas combines multiple images into organized groups for efficient rendering.
  /// Groups allow logical organization (e.g., "player", "enemies", "effects").
  /// Supports loading from disk files or ZIP archives.
  /// Automatically manages texture memory and provides fast frame access.
  /// </remarks>
  /// <example>
  /// <code>
  /// LAtlas := TpxTextureAtlas.Create();
  /// LTextureIndex := LAtlas.LoadTextureFromDisk('spritesheet.png');
  /// LGroupIndex := LAtlas.AddGroup('player');
  /// LAtlas.AddImagesFromGrid(LTextureIndex, LGroupIndex, 4, 4, 32, 32);
  /// LAtlas.DefineAnimation('walk', 0, 3, 8.0, amLoop);
  /// </code>
  /// </example>
  TpxTextureAtlas = class(TpxObject)
  private type
    TGroupData = record
      Images: array of TpxTextureRegion;
      Count: Integer;
    end;
  private
    FTextures: array of TpxTexture;
    FGroups: array of TGroupData;
    FGroupNames: TDictionary<string, Integer>;
    FAnimations: TDictionary<string, TpxAnimationSequence>;
    FTextureCount: Integer;
    FGroupCount: Integer;
  public
    constructor Create(); override;
    destructor Destroy(); override;

    // Texture page management
    /// <summary>
    /// Loads a texture from disk and adds it to the atlas as a new texture page.
    /// </summary>
    /// <param name="AFilename">Path to the image file to load</param>
    /// <param name="AKind">Texture filtering mode (pxPixelArtTexture for pixel art, pxHDTexture for smooth graphics)</param>
    /// <param name="AColorKey">Optional color to treat as transparent (nil for no color key)</param>
    /// <returns>The texture index for referencing this texture, or -1 on failure</returns>
    /// <remarks>
    /// Supports common image formats like PNG, JPG, BMP, TGA.
    /// Use pxPixelArtTexture for crisp pixel art without filtering.
    /// Use pxHDTexture for smooth scaling with linear filtering.
    /// The returned index is used when adding images to groups.
    /// </remarks>
    /// <example>
    /// <code>
    /// LTextureIndex := LAtlas.LoadTextureFromDisk('player.png', pxPixelArtTexture);
    /// if LTextureIndex >= 0 then
    ///   // Texture loaded successfully
    /// </code>
    /// </example>
    function LoadTextureFromDisk(const AFilename: string; const AKind: TpxTextureKind = pxHDTexture; const AColorKey: PpxColor = nil): Integer;

    /// <summary>
    /// Loads a texture from a ZIP archive and adds it to the atlas as a new texture page.
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP archive file</param>
    /// <param name="AFilename">Path within the ZIP archive to the image file</param>
    /// <param name="AKind">Texture filtering mode (pxPixelArtTexture for pixel art, pxHDTexture for smooth graphics)</param>
    /// <param name="AColorKey">Optional color to treat as transparent (nil for no color key)</param>
    /// <returns>The texture index for referencing this texture, or -1 on failure</returns>
    /// <remarks>
    /// Useful for packaging game assets into compressed archives.
    /// ZIP files are automatically decompressed during loading.
    /// Supports password-protected ZIP files using the default PIXELS password.
    /// </remarks>
    function LoadTextureFromZip(const AZipFilename: string; const AFilename: string; const AKind: TpxTextureKind = pxHDTexture; const AColorKey: PpxColor = nil): Integer;

    /// <summary>
    /// Retrieves a texture object by its index within the atlas.
    /// </summary>
    /// <param name="AIndex">The texture index returned from LoadTexture methods</param>
    /// <returns>The texture object, or nil if index is invalid</returns>
    /// <remarks>
    /// Used for direct texture access when needed.
    /// Most sprite operations don't require direct texture access.
    /// </remarks>
    function GetTexture(const AIndex: Integer): TpxTexture;

    /// <summary>
    /// Returns the total number of texture pages currently loaded in the atlas.
    /// </summary>
    /// <returns>The number of texture pages</returns>
    function GetTextureCount(): Integer;

    // Group management
    /// <summary>
    /// Creates a new sprite group for organizing related frames.
    /// </summary>
    /// <param name="AName">Optional name for the group (empty string for unnamed group)</param>
    /// <returns>The group index for referencing this group</returns>
    /// <remarks>
    /// Groups provide logical organization for sprite frames (e.g., "player", "enemies").
    /// Named groups can be accessed by name later for convenience.
    /// Unnamed groups can only be accessed by index.
    /// </remarks>
    /// <example>
    /// <code>
    /// LPlayerGroup := LAtlas.AddGroup('player');
    /// LEnemyGroup := LAtlas.AddGroup('enemy');
    /// LEffectsGroup := LAtlas.AddGroup(); // Unnamed group
    /// </code>
    /// </example>
    function AddGroup(const AName: string = ''): Integer;

    /// <summary>
    /// Finds a group by its name and returns the group index.
    /// </summary>
    /// <param name="AName">The name of the group to find</param>
    /// <returns>The group index, or -1 if not found</returns>
    /// <remarks>
    /// Only works for groups that were created with a name.
    /// Case-sensitive name matching.
    /// </remarks>
    function GetGroupIndex(const AName: string): Integer;

    /// <summary>
    /// Returns the total number of groups currently in the atlas.
    /// </summary>
    /// <returns>The number of groups</returns>
    function GetGroupCount(): Integer;

    // Image management
    /// <summary>
    /// Adds a single image frame from a rectangular region of a texture to a group.
    /// </summary>
    /// <param name="ATextureIndex">Index of the texture page containing the image</param>
    /// <param name="AGroupIndex">Index of the group to add the image to</param>
    /// <param name="ARect">Rectangle defining the image area within the texture</param>
    /// <returns>The image index within the group, or -1 on failure</returns>
    /// <remarks>
    /// Provides precise control over frame boundaries.
    /// Rectangle coordinates are in pixels relative to the texture's top-left corner.
    /// The returned index is used for animation sequences and direct frame access.
    /// </remarks>
    /// <example>
    /// <code>
    /// LRect := TpxRect.Create(0, 0, 32, 32);
    /// LImageIndex := LAtlas.AddImageFromRect(LTextureIndex, LGroupIndex, LRect);
    /// </code>
    /// </example>
    function AddImageFromRect(const ATextureIndex: Integer; const AGroupIndex: Integer; const ARect: TpxRect): Integer;

    /// <summary>
    /// Adds a single image frame from a grid cell within a texture to a group.
    /// </summary>
    /// <param name="ATextureIndex">Index of the texture page containing the grid</param>
    /// <param name="AGroupIndex">Index of the group to add the image to</param>
    /// <param name="AGridX">Grid column index (0-based)</param>
    /// <param name="AGridY">Grid row index (0-based)</param>
    /// <param name="ACellWidth">Width of each grid cell in pixels</param>
    /// <param name="ACellHeight">Height of each grid cell in pixels</param>
    /// <returns>The image index within the group, or -1 on failure</returns>
    /// <remarks>
    /// Convenient for adding individual frames from a regular grid layout.
    /// Grid coordinates start at (0,0) in the top-left corner.
    /// </remarks>
    function AddImageFromGrid(const ATextureIndex: Integer; const AGroupIndex: Integer; const AGridX: Integer; const AGridY: Integer; const ACellWidth: Integer; const ACellHeight: Integer): Integer;

    /// <summary>
    /// Adds multiple image frames from a rectangular grid within a texture to a group.
    /// </summary>
    /// <param name="ATextureIndex">Index of the texture page containing the grid</param>
    /// <param name="AGroupIndex">Index of the group to add the images to</param>
    /// <param name="AColumns">Number of columns in the grid</param>
    /// <param name="ARows">Number of rows in the grid</param>
    /// <param name="ACellWidth">Width of each grid cell in pixels</param>
    /// <param name="ACellHeight">Height of each grid cell in pixels</param>
    /// <param name="AStartX">Starting grid column (default 0)</param>
    /// <param name="AStartY">Starting grid row (default 0)</param>
    /// <returns>True if all images were added successfully, False otherwise</returns>
    /// <remarks>
    /// Most efficient way to import sprite sheets with regular grid layouts.
    /// Images are added left-to-right, top-to-bottom within the specified grid area.
    /// Frame indices are assigned sequentially starting from the current group size.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Add a 4x4 grid of 32x32 sprites starting at (0,0)
    /// LSuccess := LAtlas.AddImagesFromGrid(LTextureIndex, LGroupIndex, 4, 4, 32, 32);
    /// </code>
    /// </example>
    function AddImagesFromGrid(const ATextureIndex: Integer; const AGroupIndex: Integer; const AColumns: Integer; const ARows: Integer; const ACellWidth: Integer; const ACellHeight: Integer; const AStartX: Integer = 0; const AStartY: Integer = 0): Boolean;

    // Image access
    /// <summary>
    /// Returns the number of image frames in the specified group.
    /// </summary>
    /// <param name="AGroupIndex">Index of the group to query</param>
    /// <returns>The number of images in the group, or 0 if group doesn't exist</returns>
    function GetImageCount(const AGroupIndex: Integer): Integer; overload;

    /// <summary>
    /// Returns the number of image frames in the specified named group.
    /// </summary>
    /// <param name="AGroupName">Name of the group to query</param>
    /// <returns>The number of images in the group, or 0 if group doesn't exist</returns>
    function GetImageCount(const AGroupName: string): Integer; overload;

    /// <summary>
    /// Returns the pixel dimensions of a specific image frame within a group.
    /// </summary>
    /// <param name="AImageIndex">Index of the image within the group</param>
    /// <param name="AGroupIndex">Index of the group containing the image</param>
    /// <returns>Size structure with width and height in pixels</returns>
    /// <remarks>
    /// Returns zero size if indices are invalid.
    /// Useful for calculating collision bounds or positioning.
    /// </remarks>
    function GetImageSize(const AImageIndex: Integer; const AGroupIndex: Integer): TpxSize; overload;

    /// <summary>
    /// Returns the pixel dimensions of a specific image frame within a named group.
    /// </summary>
    /// <param name="AImageIndex">Index of the image within the group</param>
    /// <param name="AGroupName">Name of the group containing the image</param>
    /// <returns>Size structure with width and height in pixels</returns>
    function GetImageSize(const AImageIndex: Integer; const AGroupName: string): TpxSize; overload;

    /// <summary>
    /// Returns the texture region information for a specific image frame.
    /// </summary>
    /// <param name="AImageIndex">Index of the image within the group</param>
    /// <param name="AGroupIndex">Index of the group containing the image</param>
    /// <returns>Texture region with rectangle and texture index information</returns>
    /// <remarks>
    /// Used internally by the sprite system for rendering.
    /// Contains the exact pixel coordinates and source texture information.
    /// </remarks>
    function GetImageRegion(const AImageIndex: Integer; const AGroupIndex: Integer): TpxTextureRegion; overload;

    /// <summary>
    /// Returns the texture region information for a specific image frame within a named group.
    /// </summary>
    /// <param name="AImageIndex">Index of the image within the group</param>
    /// <param name="AGroupName">Name of the group containing the image</param>
    /// <returns>Texture region with rectangle and texture index information</returns>
    function GetImageRegion(const AImageIndex: Integer; const AGroupName: string): TpxTextureRegion; overload;

    // Animation sequences
    /// <summary>
    /// Defines a named animation sequence using a range of frames from the current group.
    /// </summary>
    /// <param name="AName">Unique name for the animation sequence</param>
    /// <param name="AStartFrame">First frame index in the sequence (inclusive)</param>
    /// <param name="AEndFrame">Last frame index in the sequence (inclusive)</param>
    /// <param name="AFrameSpeed">Playback speed in frames per second</param>
    /// <param name="AMode">Animation playback mode (default: amLoop)</param>
    /// <remarks>
    /// Animation names must be unique within the atlas.
    /// Frame indices refer to images within any group that uses this atlas.
    /// FrameSpeed determines how fast the animation plays (e.g., 8.0 = 8 fps).
    /// Animations can be played by sprites using the animation name.
    /// </remarks>
    /// <example>
    /// <code>
    /// LAtlas.DefineAnimation('walk', 0, 7, 12.0, amLoop);
    /// LAtlas.DefineAnimation('jump', 8, 11, 8.0, amOnce);
    /// LAtlas.DefineAnimation('idle', 12, 15, 4.0, amPingPong);
    /// </code>
    /// </example>
    procedure DefineAnimation(const AName: string; const AStartFrame: Integer; const AEndFrame: Integer; const AFrameSpeed: Single; const AMode: TpxAnimationMode = amLoop);

    /// <summary>
    /// Retrieves the animation sequence data for a named animation.
    /// </summary>
    /// <param name="AName">Name of the animation to retrieve</param>
    /// <returns>Animation sequence data, or empty sequence if not found</returns>
    /// <remarks>
    /// Returns a copy of the animation data.
    /// Check the Name field to verify if the animation was found.
    /// </remarks>
    function GetAnimation(const AName: string): TpxAnimationSequence;

    /// <summary>
    /// Checks if a named animation sequence exists in the atlas.
    /// </summary>
    /// <param name="AName">Name of the animation to check</param>
    /// <returns>True if the animation exists, False otherwise</returns>
    function HasAnimation(const AName: string): Boolean;

    // Cleanup
    /// <summary>
    /// Clears all textures, groups, and animations from the atlas, freeing all resources.
    /// </summary>
    /// <remarks>
    /// Destroys all loaded textures and resets the atlas to an empty state.
    /// Any sprites using this atlas will become invalid and should be recreated.
    /// Called automatically during destruction.
    /// </remarks>
    procedure Clear();
  end;

  /// <summary>
  /// A high-performance 2D sprite class with built-in animation, collision, and transform support.
  /// Provides a complete solution for animated game objects with minimal setup.
  /// </summary>
  /// <remarks>
  /// Sprites are linked to texture atlases for efficient rendering and animation.
  /// Supports multiple collision detection methods for different performance needs.
  /// Uses a frame-based animation system with 60fps locked timing.
  /// All transform operations (position, rotation, scale) are relative to the sprite center.
  /// Coordinates use the standard PIXELS coordinate system (0,0 at top-left).
  /// </remarks>
  /// <example>
  /// <code>
  /// LSprite := TpxSprite.Create();
  /// LSprite.Init(LAtlas, 'player');
  /// LSprite.SetPosition(100, 200);
  /// LSprite.PlayAnimation('walk');
  ///
  /// // In game loop:
  /// LSprite.Update();
  /// LSprite.Render();
  /// </code>
  /// </example>
  TpxSprite = class(TpxObject)
  private
    // Core references
    FAtlas: TpxTextureAtlas;
    FGroupIndex: Integer;

    // Transform properties
    FPosition: TpxVector;
    FVelocity: TpxVector;
    FScale: TpxVector;
    FAngle: Single;
    FAngularVelocity: Single;
    FColor: TpxColor;
    FAlpha: Single;

    // Visual properties
    FHFlip: Boolean;
    FVFlip: Boolean;
    FVisible: Boolean;
    FBlendMode: TpxBlendMode;

    // Animation state
    FCurrentFrame: Integer;
    FFrameSpeed: Single;
    FFrameTimer: Single;
    FCurrentAnimation: string;
    FAnimationMode: TpxAnimationMode;
    FFirstFrame: Integer;
    FLastFrame: Integer;
    FAnimationDirection: Integer; // 1 for forward, -1 for reverse
    FLoopAnimation: Boolean;
    FAnimFramesPerUpdate: Single;
    FAnimationFinished: Boolean; // NEW: Flag to indicate if amOnce animation has completed

    // Collision properties
    FCollisionMethod: TpxCollisionMethod;
    FCollisionRadius: Single;
    FCollisionRect: TpxRect;
    FCollisionScale: Single;

    // Size cache
    FWidth: Single;
    FHeight: Single;
    FRadius: Single;

    // Animation events
    FOnAnimationComplete: TpxAnimationCompleteEvent;
    FOnAnimationFrame: TpxAnimationFrameEvent;

    // Component hooks (for future expansion)
    FUserData: Pointer;
    FTag: Integer;

    // Internal methods
    procedure UpdateFrameSize();
    procedure UpdateAnimation();
    function GetBestCollisionMethod(const AOther: TpxSprite): TpxCollisionMethod;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    // Initialization
    /// <summary>
    /// Initializes the sprite with a texture atlas and group index.
    /// </summary>
    /// <param name="AAtlas">The texture atlas containing sprite frames</param>
    /// <param name="AGroupIndex">Index of the group within the atlas to use</param>
    /// <returns>True if initialization succeeded, False otherwise</returns>
    /// <remarks>
    /// Must be called before using the sprite for rendering or animation.
    /// The atlas must remain valid for the lifetime of the sprite.
    /// Sets the initial frame to 0 and prepares animation ranges.
    /// </remarks>
    /// <example>
    /// <code>
    /// LPlayerGroup := LAtlas.GetGroupIndex('player');
    /// if LSprite.Init(LAtlas, LPlayerGroup) then
    ///   // Sprite ready for use
    /// </code>
    /// </example>
    function Init(const AAtlas: TpxTextureAtlas; const AGroupIndex: Integer): Boolean; overload;

    /// <summary>
    /// Initializes the sprite with a texture atlas and named group.
    /// </summary>
    /// <param name="AAtlas">The texture atlas containing sprite frames</param>
    /// <param name="AGroupName">Name of the group within the atlas to use</param>
    /// <returns>True if initialization succeeded, False otherwise</returns>
    /// <remarks>
    /// Convenience method for named groups. The group must exist in the atlas.
    /// Equivalent to calling Init with GetGroupIndex.
    /// </remarks>
    function Init(const AAtlas: TpxTextureAtlas; const AGroupName: string): Boolean; overload;

    // Transform properties
    /// <summary>
    /// Gets the current world position of the sprite center.
    /// </summary>
    /// <returns>Vector containing the X and Y coordinates in pixels</returns>
    /// <remarks>
    /// Position represents the center point of the sprite.
    /// Coordinates are in the PIXELS world space coordinate system.
    /// </remarks>
    function GetPosition(): TpxVector;

    /// <summary>
    /// Sets the world position of the sprite center.
    /// </summary>
    /// <param name="APosition">New position vector with X and Y coordinates</param>
    /// <remarks>
    /// Updates collision bounds automatically.
    /// Position change takes effect immediately.
    /// </remarks>
    procedure SetPosition(const APosition: TpxVector); overload;

    /// <summary>
    /// Sets the world position of the sprite center using separate coordinates.
    /// </summary>
    /// <param name="AX">New X coordinate in pixels</param>
    /// <param name="AY">New Y coordinate in pixels</param>
    procedure SetPosition(const AX: Single; const AY: Single); overload;

    /// <summary>
    /// Gets the current velocity of the sprite.
    /// </summary>
    /// <returns>Vector containing velocity in pixels per frame</returns>
    /// <remarks>
    /// Velocity is automatically applied during Update() calls.
    /// Measured in pixels per frame at 60fps locked framerate.
    /// </remarks>
    function GetVelocity(): TpxVector;

    /// <summary>
    /// Sets the velocity of the sprite.
    /// </summary>
    /// <param name="AVelocity">New velocity vector in pixels per frame</param>
    /// <remarks>
    /// Velocity is applied to position during each Update() call.
    /// Use zero velocity to stop automatic movement.
    /// </remarks>
    procedure SetVelocity(const AVelocity: TpxVector); overload;

    /// <summary>
    /// Sets the velocity of the sprite using separate components.
    /// </summary>
    /// <param name="AX">X velocity component in pixels per frame</param>
    /// <param name="AY">Y velocity component in pixels per frame</param>
    procedure SetVelocity(const AX: Single; const AY: Single); overload;

    /// <summary>
    /// Gets the current scale factors of the sprite.
    /// </summary>
    /// <returns>Vector containing X and Y scale multipliers</returns>
    /// <remarks>
    /// Scale of 1.0 represents original size.
    /// Scales greater than 1.0 enlarge the sprite.
    /// Scales less than 1.0 shrink the sprite.
    /// Negative scales flip the sprite.
    /// </remarks>
    function GetScale(): TpxVector;

    /// <summary>
    /// Sets the scale factors of the sprite.
    /// </summary>
    /// <param name="AScale">New scale vector with X and Y multipliers</param>
    /// <remarks>
    /// Updates sprite dimensions and collision bounds automatically.
    /// Scale affects rendering size but not texture quality.
    /// </remarks>
    procedure SetScale(const AScale: TpxVector); overload;

    /// <summary>
    /// Sets the scale factors of the sprite using separate components.
    /// </summary>
    /// <param name="AX">X scale multiplier</param>
    /// <param name="AY">Y scale multiplier</param>
    procedure SetScale(const AX: Single; const AY: Single); overload;

    /// <summary>
    /// Sets uniform scale for both X and Y axes.
    /// </summary>
    /// <param name="AUniform">Scale multiplier applied to both axes</param>
    /// <remarks>
    /// Convenient for proportional scaling without distortion.
    /// </remarks>
    procedure SetScale(const AUniform: Single); overload;

    /// <summary>
    /// Gets the current rotation angle of the sprite.
    /// </summary>
    /// <returns>Rotation angle in degrees (0-360)</returns>
    /// <remarks>
    /// Angle 0 points to the right (positive X axis).
    /// Rotation is clockwise in the standard coordinate system.
    /// </remarks>
    function GetAngle(): Single;

    /// <summary>
    /// Sets the rotation angle of the sprite.
    /// </summary>
    /// <param name="AAngle">New rotation angle in degrees</param>
    /// <remarks>
    /// Angle is automatically wrapped to 0-360 range.
    /// Rotation is around the sprite center point.
    /// </remarks>
    procedure SetAngle(const AAngle: Single);

    /// <summary>
    /// Gets the current angular velocity of the sprite.
    /// </summary>
    /// <returns>Angular velocity in degrees per frame</returns>
    /// <remarks>
    /// Positive values rotate clockwise.
    /// Negative values rotate counter-clockwise.
    /// Applied automatically during Update() calls.
    /// </remarks>
    function GetAngularVelocity(): Single;

    /// <summary>
    /// Sets the angular velocity of the sprite.
    /// </summary>
    /// <param name="AAngularVelocity">Angular velocity in degrees per frame</param>
    /// <remarks>
    /// Use zero to stop automatic rotation.
    /// Large values may cause visual artifacts due to frame-stepping.
    /// </remarks>
    procedure SetAngularVelocity(const AAngularVelocity: Single);

    // Visual properties
    /// <summary>
    /// Gets the current color tint applied to the sprite.
    /// </summary>
    /// <returns>Color tint with RGBA components (0.0-1.0 range)</returns>
    /// <remarks>
    /// White color (1,1,1,1) renders the sprite with original colors.
    /// Alpha component controls transparency separately from the Alpha property.
    /// </remarks>
    function GetColor(): TpxColor;

    /// <summary>
    /// Sets the color tint applied to the sprite.
    /// </summary>
    /// <param name="AColor">New color tint with RGBA components</param>
    /// <remarks>
    /// Color tinting is applied during rendering using multiplication.
    /// Useful for damage flashing, team colors, or lighting effects.
    /// </remarks>
    procedure SetColor(const AColor: TpxColor);

    /// <summary>
    /// Gets the current alpha transparency level of the sprite.
    /// </summary>
    /// <returns>Alpha value from 0.0 (transparent) to 1.0 (opaque)</returns>
    function GetAlpha(): Single;

    /// <summary>
    /// Sets the alpha transparency level of the sprite.
    /// </summary>
    /// <param name="AAlpha">Alpha value from 0.0 (transparent) to 1.0 (opaque)</param>
    /// <remarks>
    /// Value is automatically clamped to 0.0-1.0 range.
    /// Also updates the alpha component of the Color property.
    /// </remarks>
    procedure SetAlpha(const AAlpha: Single);

    /// <summary>
    /// Gets the current horizontal flip state of the sprite.
    /// </summary>
    /// <returns>True if horizontally flipped, False otherwise</returns>
    function GetHFlip(): Boolean;

    /// <summary>
    /// Sets the horizontal flip state of the sprite.
    /// </summary>
    /// <param name="AFlip">True to flip horizontally, False for normal orientation</param>
    /// <remarks>
    /// Flipping is applied during rendering without affecting collision bounds.
    /// Useful for character facing direction or mirrored effects.
    /// </remarks>
    procedure SetHFlip(const AFlip: Boolean);

    /// <summary>
    /// Gets the current vertical flip state of the sprite.
    /// </summary>
    /// <returns>True if vertically flipped, False otherwise</returns>
    function GetVFlip(): Boolean;

    /// <summary>
    /// Sets the vertical flip state of the sprite.
    /// </summary>
    /// <param name="AFlip">True to flip vertically, False for normal orientation</param>
    procedure SetVFlip(const AFlip: Boolean);

    /// <summary>
    /// Gets the current visibility state of the sprite.
    /// </summary>
    /// <returns>True if visible and will be rendered, False if hidden</returns>
    function GetVisible(): Boolean;

    /// <summary>
    /// Sets the visibility state of the sprite.
    /// </summary>
    /// <param name="AVisible">True to show the sprite, False to hide it</param>
    /// <remarks>
    /// Hidden sprites are not rendered but continue to update animation and physics.
    /// Useful for temporary hiding without stopping game logic.
    /// </remarks>
    procedure SetVisible(const AVisible: Boolean);

    /// <summary>
    /// Gets the current blend mode used for rendering the sprite.
    /// </summary>
    /// <returns>Current blend mode setting</returns>
    function GetBlendMode(): TpxBlendMode;

    /// <summary>
    /// Sets the blend mode used for rendering the sprite.
    /// </summary>
    /// <param name="AMode">New blend mode for rendering</param>
    /// <remarks>
    /// Blend modes control how the sprite is composited with the background.
    /// Default is usually pxPreMultipliedAlphaBlendMode for normal transparency.
    /// pxAdditiveAlphaBlendMode is useful for glowing effects.
    /// </remarks>
    procedure SetBlendMode(const AMode: TpxBlendMode);

    // Animation control
    /// <summary>
    /// Starts playing a named animation sequence defined in the texture atlas.
    /// </summary>
    /// <param name="AName">Name of the animation sequence to play</param>
    /// <returns>True if animation was found and started, False otherwise</returns>
    /// <remarks>
    /// Resets animation state and begins playback from the first frame.
    /// Animation must be defined in the associated texture atlas.
    /// Stops any currently playing animation.
    /// </remarks>
    /// <example>
    /// <code>
    /// if LSprite.PlayAnimation('walk') then
    ///   // Animation started successfully
    /// else
    ///   // Animation not found
    /// </code>
    /// </example>
    function PlayAnimation(const AName: string): Boolean;

    /// <summary>
    /// Sets the sprite to display a specific frame index.
    /// </summary>
    /// <param name="AFrame">Frame index to display (0-based)</param>
    /// <remarks>
    /// Stops any playing animation and shows a static frame.
    /// Frame index is automatically clamped to valid range.
    /// Useful for static sprites or manual frame control.
    /// </remarks>
    procedure SetFrame(const AFrame: Integer);

    /// <summary>
    /// Gets the currently displayed frame index.
    /// </summary>
    /// <returns>Current frame index (0-based)</returns>
    function GetFrame(): Integer;

    /// <summary>
    /// Sets the animation playback speed in frames per second.
    /// </summary>
    /// <param name="ASpeed">Playback speed in frames per second (minimum 0.01)</param>
    /// <remarks>
    /// Higher values play animation faster.
    /// Lower values play animation slower.
    /// Minimum value prevents division by zero.
    /// </remarks>
    procedure SetFrameSpeed(const ASpeed: Single);

    /// <summary>
    /// Gets the current animation playback speed.
    /// </summary>
    /// <returns>Current playback speed in frames per second</returns>
    function GetFrameSpeed(): Single;

    /// <summary>
    /// Checks if the current animation has completed playback.
    /// </summary>
    /// <returns>True if amOnce animation has finished, False otherwise</returns>
    /// <remarks>
    /// Only returns True for amOnce animations that have reached the end.
    /// Always returns False for looping animations.
    /// Useful for triggering events when animations complete.
    /// </remarks>
    function IsAnimationComplete(): Boolean;

    /// <summary>
    /// Resets the current animation to the beginning and clears completion flag.
    /// </summary>
    /// <remarks>
    /// Restarts animation from the first frame.
    /// Clears the animation finished flag for amOnce animations.
    /// Useful for replaying completed animations.
    /// </remarks>
    procedure ResetAnimation();

    // Movement helpers
    /// <summary>
    /// Moves the sprite by the specified offset from its current position.
    /// </summary>
    /// <param name="ADeltaX">Horizontal offset in pixels</param>
    /// <param name="ADeltaY">Vertical offset in pixels</param>
    /// <remarks>
    /// Updates position immediately and recalculates collision bounds.
    /// Positive X moves right, positive Y moves down.
    /// </remarks>
    procedure Move(const ADeltaX: Single; const ADeltaY: Single);

    /// <summary>
    /// Applies thrust in the sprite's current facing direction.
    /// </summary>
    /// <param name="ASpeed">Thrust force in pixels per frame</param>
    /// <remarks>
    /// Direction is based on the sprite's current angle plus 90 degrees.
    /// Updates the velocity vector for frame-based movement.
    /// Useful for player movement or physics simulation.
    /// </remarks>
    procedure Thrust(const ASpeed: Single);

    /// <summary>
    /// Applies thrust in a specific direction regardless of sprite rotation.
    /// </summary>
    /// <param name="AAngle">Direction angle in degrees (0 = right)</param>
    /// <param name="ASpeed">Thrust force in pixels per frame</param>
    /// <remarks>
    /// Updates the velocity vector for frame-based movement.
    /// Angle 0 points right, 90 points down, etc.
    /// </remarks>
    procedure ThrustAtAngle(const AAngle: Single; const ASpeed: Single);

    /// <summary>
    /// Smoothly moves the sprite toward a target position at the specified speed.
    /// </summary>
    /// <param name="ATargetX">Target X coordinate in pixels</param>
    /// <param name="ATargetY">Target Y coordinate in pixels</param>
    /// <param name="ASpeed">Movement speed in pixels per frame</param>
    /// <returns>True if target was reached this frame, False if still moving</returns>
    /// <remarks>
    /// Automatically stops at the target position to prevent overshoot.
    /// Updates velocity to move toward the target.
    /// Useful for AI movement or smooth position transitions.
    /// </remarks>
    function MoveToward(const ATargetX: Single; const ATargetY: Single; const ASpeed: Single): Boolean;

    /// <summary>
    /// Smoothly rotates the sprite toward a target angle at the specified speed.
    /// </summary>
    /// <param name="ATargetAngle">Target angle in degrees</param>
    /// <param name="ASpeed">Rotation speed in degrees per frame</param>
    /// <returns>True if target angle was reached this frame, False if still rotating</returns>
    /// <remarks>
    /// Takes the shortest rotation path (may go through 0/360 boundary).
    /// Updates angular velocity to rotate toward the target.
    /// Useful for smooth rotation animations or AI facing behavior.
    /// </remarks>
    function RotateToward(const ATargetAngle: Single; const ASpeed: Single): Boolean;

    /// <summary>
    /// Smoothly rotates the sprite to face toward a target point at the specified speed.
    /// </summary>
    /// <param name="ATargetX">Target X coordinate in pixels</param>
    /// <param name="ATargetY">Target Y coordinate in pixels</param>
    /// <param name="ASpeed">Rotation speed in degrees per frame</param>
    /// <returns>True if target direction was reached this frame, False if still rotating</returns>
    /// <remarks>
    /// Automatically calculates the angle to face the target point.
    /// Useful for turrets, enemies tracking players, or guided projectiles.
    /// </remarks>
    function RotateTowardPoint(const ATargetX: Single; const ATargetY: Single; const ASpeed: Single): Boolean;

    // Collision
    /// <summary>
    /// Tests for collision between this sprite and another sprite using the specified method.
    /// </summary>
    /// <param name="AOther">The other sprite to test collision against</param>
    /// <param name="AMethod">Collision detection method to use (default: cmAuto)</param>
    /// <returns>True if sprites are colliding, False otherwise</returns>
    /// <remarks>
    /// cmAuto automatically selects the best method based on sprite properties.
    /// Performance order (fastest to slowest): cmCircle, cmAABB, cmOBB, cmPixelPerfect.
    /// Collision bounds are affected by sprite scale and collision scale settings.
    /// </remarks>
    /// <example>
    /// <code>
    /// if LPlayer.Collide(LEnemy, cmCircle) then
    ///   // Handle collision
    /// </code>
    /// </example>
    function Collide(const AOther: TpxSprite; const AMethod: TpxCollisionMethod = cmAuto): Boolean; overload;

    /// <summary>
    /// Tests for collision between this sprite and a circular area.
    /// </summary>
    /// <param name="AX">X coordinate of the circle center</param>
    /// <param name="AY">Y coordinate of the circle center</param>
    /// <param name="ARadius">Radius of the circle in pixels</param>
    /// <returns>True if sprite overlaps the circle, False otherwise</returns>
    /// <remarks>
    /// Uses circular collision detection regardless of sprite's collision method.
    /// Useful for testing against explosions, trigger areas, or pickups.
    /// </remarks>
    function Collide(const AX: Single; const AY: Single; const ARadius: Single): Boolean; overload;

    /// <summary>
    /// Tests for collision between this sprite and a rectangular area.
    /// </summary>
    /// <param name="ARect">Rectangle to test collision against</param>
    /// <returns>True if sprite overlaps the rectangle, False otherwise</returns>
    /// <remarks>
    /// Uses AABB collision detection regardless of sprite's collision method.
    /// Rectangle coordinates are in world space.
    /// </remarks>
    function CollideRect(const ARect: TpxRect): Boolean;

    /// <summary>
    /// Sets the collision detection method for this sprite.
    /// </summary>
    /// <param name="AMethod">New collision detection method</param>
    /// <remarks>
    /// Affects performance and accuracy of collision detection.
    /// cmAuto is recommended for most cases.
    /// </remarks>
    procedure SetCollisionMethod(const AMethod: TpxCollisionMethod);

    /// <summary>
    /// Sets a custom collision radius for circular collision detection.
    /// </summary>
    /// <param name="ARadius">New collision radius in pixels</param>
    /// <remarks>
    /// Only affects cmCircle collision detection.
    /// By default, radius is calculated from sprite dimensions.
    /// </remarks>
    procedure SetCollisionRadius(const ARadius: Single);

    /// <summary>
    /// Sets a custom collision rectangle for AABB collision detection.
    /// </summary>
    /// <param name="ARect">New collision rectangle in local sprite coordinates</param>
    /// <remarks>
    /// Only affects cmAABB collision detection.
    /// Rectangle is relative to sprite position.
    /// By default, calculated from sprite dimensions.
    /// </remarks>
    procedure SetCollisionRect(const ARect: TpxRect);

    /// <summary>
    /// Sets a scale factor applied to collision bounds.
    /// </summary>
    /// <param name="AScale">Scale multiplier for collision bounds (minimum 0.1)</param>
    /// <remarks>
    /// Values less than 1.0 shrink collision bounds.
    /// Values greater than 1.0 expand collision bounds.
    /// Useful for fine-tuning collision feel without changing visual size.
    /// </remarks>
    procedure SetCollisionScale(const AScale: Single);

    // Bounds checking
    /// <summary>
    /// Tests if any part of the sprite is visible within the specified view rectangle.
    /// </summary>
    /// <param name="AViewRect">View rectangle in world coordinates</param>
    /// <returns>True if sprite overlaps the view area, False otherwise</returns>
    /// <remarks>
    /// Useful for frustum culling to skip rendering off-screen sprites.
    /// Uses the sprite's current bounds including scale.
    /// </remarks>
    function IsVisible(const AViewRect: TpxRect): Boolean;

    /// <summary>
    /// Tests if the sprite is completely contained within the specified view rectangle.
    /// </summary>
    /// <param name="AViewRect">View rectangle in world coordinates</param>
    /// <returns>True if sprite is fully inside the view area, False otherwise</returns>
    /// <remarks>
    /// Stricter test than IsVisible - requires complete containment.
    /// Useful for determining when sprites are fully on-screen.
    /// </remarks>
    function IsFullyVisible(const AViewRect: TpxRect): Boolean;

    /// <summary>
    /// Returns the current bounding rectangle of the sprite in world coordinates.
    /// </summary>
    /// <returns>Rectangle encompassing the sprite's current position and size</returns>
    /// <remarks>
    /// Bounds include current scale factor and are centered on sprite position.
    /// Updated automatically when position or scale changes.
    /// </remarks>
    function GetBounds(): TpxRect;

    // Size properties
    /// <summary>
    /// Gets the current rendered width of the sprite in pixels.
    /// </summary>
    /// <returns>Sprite width including scale factor</returns>
    /// <remarks>
    /// Width includes the current X scale factor.
    /// Original texture width multiplied by scale.
    /// </remarks>
    function GetWidth(): Single;

    /// <summary>
    /// Gets the current rendered height of the sprite in pixels.
    /// </summary>
    /// <returns>Sprite height including scale factor</returns>
    /// <remarks>
    /// Height includes the current Y scale factor.
    /// Original texture height multiplied by scale.
    /// </remarks>
    function GetHeight(): Single;

    /// <summary>
    /// Gets the current collision radius of the sprite.
    /// </summary>
    /// <returns>Collision radius in pixels including scale factor</returns>
    /// <remarks>
    /// Calculated as average of width and height unless custom radius is set.
    /// Used for circular collision detection.
    /// </remarks>
    function GetRadius(): Single;

    // Update and render
    /// <summary>
    /// Updates the sprite's animation, physics, and internal state for one frame.
    /// </summary>
    /// <remarks>
    /// Must be called once per frame in the game loop for proper operation.
    /// Updates position based on velocity, angle based on angular velocity.
    /// Advances animation frames and triggers animation events.
    /// Call before Render() in the game loop.
    /// </remarks>
    /// <example>
    /// <code>
    /// // In game loop:
    /// LSprite.Update();
    /// LSprite.Render();
    /// </code>
    /// </example>
    procedure Update();

    /// <summary>
    /// Renders the sprite to the screen using its current state and properties.
    /// </summary>
    /// <remarks>
    /// Draws the current frame with applied transforms, color, and blend mode.
    /// Only renders if the sprite is visible.
    /// Must call Update() before Render() in the game loop.
    /// Uses the currently active camera transform if any.
    /// </remarks>
    procedure Render();

    // Animation
    /// <summary>
    /// Gets the name of the currently playing animation sequence.
    /// </summary>
    /// <returns>Name of the current animation, or empty string if none</returns>
    function GetCurrentAnimation(): string;

    // Animation events
    /// <summary>
    /// Event triggered when an animation sequence completes playback.
    /// </summary>
    /// <remarks>
    /// Fires for amOnce animations when they finish.
    /// Also fires for amPingPong animations when they complete a full cycle.
    /// Assign a handler to respond to animation completion.
    /// </remarks>
    property OnAnimationComplete: TpxAnimationCompleteEvent read FOnAnimationComplete write FOnAnimationComplete;

    /// <summary>
    /// Event triggered when animation advances to a new frame.
    /// </summary>
    /// <remarks>
    /// Fires every time the animation frame changes.
    /// Useful for frame-based sound effects or visual effects.
    /// Assign a handler to respond to frame changes.
    /// </remarks>
    property OnAnimationFrame: TpxAnimationFrameEvent read FOnAnimationFrame write FOnAnimationFrame;

    // Component hooks (for future expansion)
    /// <summary>
    /// Generic pointer for attaching custom data to the sprite.
    /// </summary>
    /// <remarks>
    /// Provides a way to associate custom game objects or data with sprites.
    /// Memory management of UserData is the responsibility of the game code.
    /// </remarks>
    property UserData: Pointer read FUserData write FUserData;

    /// <summary>
    /// Generic integer tag for categorizing or identifying sprites.
    /// </summary>
    /// <remarks>
    /// Useful for sprite type identification, team assignment, or flags.
    /// Can be used with collision filtering or game logic.
    /// </remarks>
    property Tag: Integer read FTag write FTag;

    // Properties for easy access
    /// <summary>
    /// The world position of the sprite center in pixels.
    /// </summary>
    property Position: TpxVector read GetPosition write SetPosition;

    /// <summary>
    /// The velocity of the sprite in pixels per frame.
    /// </summary>
    property Velocity: TpxVector read GetVelocity write SetVelocity;

    /// <summary>
    /// The scale factors for sprite rendering (1.0 = original size).
    /// </summary>
    property Scale: TpxVector read GetScale write SetScale;

    /// <summary>
    /// The rotation angle of the sprite in degrees (0-360).
    /// </summary>
    property Angle: Single read GetAngle write SetAngle;

    /// <summary>
    /// The color tint applied to the sprite (RGBA, 0.0-1.0 range).
    /// </summary>
    property Color: TpxColor read GetColor write SetColor;

    /// <summary>
    /// The alpha transparency level (0.0 = transparent, 1.0 = opaque).
    /// </summary>
    property Alpha: Single read GetAlpha write SetAlpha;

    /// <summary>
    /// Whether the sprite is horizontally flipped during rendering.
    /// </summary>
    property HFlip: Boolean read GetHFlip write SetHFlip;

    /// <summary>
    /// Whether the sprite is vertically flipped during rendering.
    /// </summary>
    property VFlip: Boolean read GetVFlip write SetVFlip;

    /// <summary>
    /// Whether the sprite is visible and will be rendered.
    /// </summary>
    property Visible: Boolean read GetVisible write SetVisible;

    /// <summary>
    /// The blend mode used for compositing the sprite with the background.
    /// </summary>
    property BlendMode: TpxBlendMode read GetBlendMode write SetBlendMode;

    /// <summary>
    /// The currently displayed frame index (0-based).
    /// </summary>
    property Frame: Integer read GetFrame write SetFrame;

    /// <summary>
    /// The animation playback speed in frames per second.
    /// </summary>
    property FrameSpeed: Single read GetFrameSpeed write SetFrameSpeed;

    /// <summary>
    /// The current rendered width of the sprite including scale.
    /// </summary>
    property Width: Single read GetWidth;

    /// <summary>
    /// The current rendered height of the sprite including scale.
    /// </summary>
    property Height: Single read GetHeight;

    /// <summary>
    /// The current collision radius of the sprite including scale.
    /// </summary>
    property Radius: Single read GetRadius;
  end;

implementation

{ TpxTextureAtlas }
constructor TpxTextureAtlas.Create();
begin
  inherited Create();
  FTextures := nil;
  FGroups := nil;
  FGroupNames := TDictionary<string, Integer>.Create();
  FAnimations := TDictionary<string, TpxAnimationSequence>.Create();
  FTextureCount := 0;
  FGroupCount := 0;
end;

destructor TpxTextureAtlas.Destroy();
begin
  Clear();
  FGroupNames.Free();
  FAnimations.Free();
  inherited Destroy();
end;

function TpxTextureAtlas.LoadTextureFromDisk(const AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor): Integer;
var
  LTexture: TpxTexture;
begin
  Result := -1;

  LTexture := TpxTexture.LoadFromFile(AFilename, AKind, AColorKey);
  if not Assigned(LTexture) then
  begin
    SetError('Failed to load texture: %s', [AFilename]);
    Exit;
  end;

  Result := FTextureCount;
  Inc(FTextureCount);
  SetLength(FTextures, FTextureCount);
  FTextures[Result] := LTexture;
end;

function TpxTextureAtlas.LoadTextureFromZip(const AZipFilename: string; const AFilename: string; const AKind: TpxTextureKind; const AColorKey: PpxColor): Integer;
var
  LTexture: TpxTexture;
begin
  Result := -1;

  LTexture := TpxTexture.LoadFromZip(AZipFilename, AFilename, AKind, AColorKey);
  if not Assigned(LTexture) then
  begin
    SetError('Failed to load texture %s from zip %s', [AFilename, AZipFilename]);
    Exit;
  end;

  Result := FTextureCount;
  Inc(FTextureCount);
  SetLength(FTextures, FTextureCount);
  FTextures[Result] := LTexture;
end;

function TpxTextureAtlas.GetTexture(const AIndex: Integer): TpxTexture;
begin
  Result := nil;
  if not InRange(AIndex, 0, FTextureCount - 1) then
  begin
    SetError('Texture index %d out of range (0-%d)', [AIndex, FTextureCount - 1]);
    Exit;
  end;
  Result := FTextures[AIndex];
end;

function TpxTextureAtlas.GetTextureCount(): Integer;
begin
  Result := FTextureCount;
end;

function TpxTextureAtlas.AddGroup(const AName: string = ''): Integer;
begin
  Result := FGroupCount;
  Inc(FGroupCount);
  SetLength(FGroups, FGroupCount);

  FGroups[Result].Images := nil;
  FGroups[Result].Count := 0;

  if AName <> '' then
    FGroupNames.Add(AName, Result);
end;

function TpxTextureAtlas.GetGroupIndex(const AName: string): Integer;
begin
  if not FGroupNames.TryGetValue(AName, Result) then
    Result := -1;
end;

function TpxTextureAtlas.GetGroupCount(): Integer;
begin
  Result := FGroupCount;
end;

function TpxTextureAtlas.AddImageFromRect(const ATextureIndex: Integer; const AGroupIndex: Integer; const ARect: TpxRect): Integer;
var
  LRegion: TpxTextureRegion;
begin
  Result := -1;

  if not InRange(ATextureIndex, 0, FTextureCount - 1) then
  begin
    SetError('Texture index %d out of range', [ATextureIndex]);
    Exit;
  end;

  if not InRange(AGroupIndex, 0, FGroupCount - 1) then
  begin
    SetError('Group index %d out of range', [AGroupIndex]);
    Exit;
  end;

  LRegion.Rect := ARect;
  LRegion.TextureIndex := ATextureIndex;

  Result := FGroups[AGroupIndex].Count;
  Inc(FGroups[AGroupIndex].Count);
  SetLength(FGroups[AGroupIndex].Images, FGroups[AGroupIndex].Count);
  FGroups[AGroupIndex].Images[Result] := LRegion;
end;

function TpxTextureAtlas.AddImageFromGrid(const ATextureIndex: Integer; const AGroupIndex: Integer; const AGridX: Integer; const AGridY: Integer; const ACellWidth: Integer; const ACellHeight: Integer): Integer;
var
  LRect: TpxRect;
begin
  LRect.x := AGridX * ACellWidth;
  LRect.y := AGridY * ACellHeight;
  LRect.w := ACellWidth;
  LRect.h := ACellHeight;

  Result := AddImageFromRect(ATextureIndex, AGroupIndex, LRect);
end;

function TpxTextureAtlas.AddImagesFromGrid(const ATextureIndex: Integer; const AGroupIndex: Integer; const AColumns: Integer; const ARows: Integer; const ACellWidth: Integer; const ACellHeight: Integer; const AStartX: Integer; const AStartY: Integer): Boolean;
var
  LRow: Integer;
  LCol: Integer;
begin
  Result := True;

  for LRow := 0 to ARows - 1 do
  begin
    for LCol := 0 to AColumns - 1 do
    begin
      if AddImageFromGrid(ATextureIndex, AGroupIndex, AStartX + LCol, AStartY + LRow, ACellWidth, ACellHeight) = -1 then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;


function TpxTextureAtlas.GetImageCount(const AGroupIndex: Integer): Integer;
begin
  Result := 0;
  if not InRange(AGroupIndex, 0, FGroupCount - 1) then
  begin
    SetError('Group index %d out of range', [AGroupIndex]);
    Exit;
  end;
  Result := FGroups[AGroupIndex].Count;
end;

function TpxTextureAtlas.GetImageCount(const AGroupName: string): Integer;
var
  LGroupIndex: Integer;
begin
  LGroupIndex := GetGroupIndex(AGroupName);
  if LGroupIndex = -1 then
  begin
    SetError('Group "%s" not found', [AGroupName]);
    Result := 0;
    Exit;
  end;
  Result := GetImageCount(LGroupIndex);
end;

function TpxTextureAtlas.GetImageSize(const AImageIndex: Integer; const AGroupIndex: Integer): TpxSize;
var
  LRegion: TpxTextureRegion;
begin
  Result.w := 0;
  Result.h := 0;

  if not InRange(AGroupIndex, 0, FGroupCount - 1) then
  begin
    SetError('Group index %d out of range', [AGroupIndex]);
    Exit;
  end;

  if not InRange(AImageIndex, 0, FGroups[AGroupIndex].Count - 1) then
  begin
    SetError('Image index %d out of range for group %d', [AImageIndex, AGroupIndex]);
    Exit;
  end;

  LRegion := FGroups[AGroupIndex].Images[AImageIndex];
  Result.w := LRegion.Rect.w;
  Result.h := LRegion.Rect.h;
end;

function TpxTextureAtlas.GetImageSize(const AImageIndex: Integer; const AGroupName: string): TpxSize;
var
  LGroupIndex: Integer;
begin
  LGroupIndex := GetGroupIndex(AGroupName);
  if LGroupIndex = -1 then
  begin
    SetError('Group "%s" not found', [AGroupName]);
    Result.w := 0;
    Result.h := 0;
    Exit;
  end;
  Result := GetImageSize(AImageIndex, LGroupIndex);
end;

function TpxTextureAtlas.GetImageRegion(const AImageIndex: Integer; const AGroupIndex: Integer): TpxTextureRegion;
begin
  Result.Rect.x := 0;
  Result.Rect.y := 0;
  Result.Rect.w := 0;
  Result.Rect.h := 0;
  Result.TextureIndex := -1;

  if not InRange(AGroupIndex, 0, FGroupCount - 1) then
  begin
    SetError('Group index %d out of range', [AGroupIndex]);
    Exit;
  end;

  if not InRange(AImageIndex, 0, FGroups[AGroupIndex].Count - 1) then
  begin
    SetError('Image index %d out of range for group %d', [AImageIndex, AGroupIndex]);
    Exit;
  end;

  Result := FGroups[AGroupIndex].Images[AImageIndex];
end;

function TpxTextureAtlas.GetImageRegion(const AImageIndex: Integer; const AGroupName: string): TpxTextureRegion;
var
  LGroupIndex: Integer;
begin
  LGroupIndex := GetGroupIndex(AGroupName);
  if LGroupIndex = -1 then
  begin
    SetError('Group "%s" not found', [AGroupName]);
    Result.Rect.x := 0;
    Result.Rect.y := 0;
    Result.Rect.w := 0;
    Result.Rect.h := 0;
    Result.TextureIndex := -1;
    Exit;
  end;
  Result := GetImageRegion(AImageIndex, LGroupIndex);
end;

procedure TpxTextureAtlas.DefineAnimation(const AName: string; const AStartFrame: Integer; const AEndFrame: Integer; const AFrameSpeed: Single; const AMode: TpxAnimationMode);
var
  LSequence: TpxAnimationSequence;
begin
  LSequence.Name := AName;
  LSequence.StartFrame := AStartFrame;
  LSequence.EndFrame := AEndFrame;
  LSequence.FrameSpeed := AFrameSpeed;
  LSequence.Mode := AMode;

  if FAnimations.ContainsKey(AName) then
    FAnimations[AName] := LSequence
  else
    FAnimations.Add(AName, LSequence);
end;

function TpxTextureAtlas.GetAnimation(const AName: string): TpxAnimationSequence;
begin
  if not FAnimations.TryGetValue(AName, Result) then
  begin
    SetError('Animation "%s" not found', [AName]);
    Result.Name := '';
    Result.StartFrame := 0;
    Result.EndFrame := 0;
    Result.FrameSpeed := 1.0;
    Result.Mode := amOnce;
  end;
end;

function TpxTextureAtlas.HasAnimation(const AName: string): Boolean;
begin
  Result := FAnimations.ContainsKey(AName);
end;

procedure TpxTextureAtlas.Clear();
var
  LIndex: Integer;
  LGroupIndex: Integer;
begin
  // Free textures
  for LIndex := 0 to FTextureCount - 1 do
  begin
    if Assigned(FTextures[LIndex]) then
      FTextures[LIndex].Free();
  end;

  // Clear group data
  for LGroupIndex := 0 to FGroupCount - 1 do
  begin
    FGroups[LGroupIndex].Images := nil;
  end;

  FTextures := nil;
  FGroups := nil;
  FGroupNames.Clear();
  FAnimations.Clear();
  FTextureCount := 0;
  FGroupCount := 0;
end;

{ TpxSprite }
constructor TpxSprite.Create();
begin
  inherited Create();

  FAtlas := nil;
  FGroupIndex := -1;

  // Initialize transform
  FPosition := TpxVector.Create(0, 0);
  FVelocity := TpxVector.Create(0, 0);
  FScale := TpxVector.Create(1.0, 1.0);
  FAngle := 0.0;
  FAngularVelocity := 0.0;
  FColor := pxWHITE;
  FAlpha := 1.0;

  // Initialize visual properties
  FHFlip := False;
  FVFlip := False;
  FVisible := True;
  FBlendMode := pxPreMultipliedAlphaBlendMode;

  // Initialize animation
  FCurrentFrame := 0;
  FFrameSpeed := 12.0;
  FFrameTimer := 0.0;
  FCurrentAnimation := '';
  FAnimationMode := amLoop;
  FFirstFrame := 0;
  FLastFrame := 0;
  FAnimationDirection := 1;
  FLoopAnimation := True;
  FAnimationFinished := False; // NEW: Initialize the finished flag

  // Initialize collision
  FCollisionMethod := cmAuto;
  FCollisionRadius := 0.0;
  FCollisionRect := TpxRect.Create(0, 0, 0, 0);
  FCollisionScale := 1.0;

  // Initialize size cache
  FWidth := 0.0;
  FHeight := 0.0;
  FRadius := 0.0;

  // Initialize component hooks
  FUserData := nil;
  FTag := 0;
end;

destructor TpxSprite.Destroy();
begin
  // Note: We don't own the atlas, so don't free it
  inherited Destroy();
end;

function TpxSprite.Init(const AAtlas: TpxTextureAtlas; const AGroupIndex: Integer): Boolean;
var
  LImageCount: Integer;
begin
  Result := False;

  if not Assigned(AAtlas) then
  begin
    SetError('Atlas cannot be nil', []);
    Exit;
  end;

  if not InRange(AGroupIndex, 0, AAtlas.GetGroupCount() - 1) then
  begin
    SetError('Group index %d out of range', [AGroupIndex]);
    Exit;
  end;

  FAtlas := AAtlas;
  FGroupIndex := AGroupIndex;

  LImageCount := FAtlas.GetImageCount(AGroupIndex);
  if LImageCount > 0 then
  begin
    FFirstFrame := 0;
    FLastFrame := LImageCount - 1;
    SetFrame(0);
  end;

  FAnimationFinished := False; // Ensure it's not marked finished on init
  Result := True;
end;

function TpxSprite.Init(const AAtlas: TpxTextureAtlas; const AGroupName: string): Boolean;
var
  LGroupIndex: Integer;
begin
  LGroupIndex := AAtlas.GetGroupIndex(AGroupName);
  if LGroupIndex = -1 then
  begin
    SetError('Group "%s" not found in atlas', [AGroupName]);
    Result := False;
    Exit;
  end;

  Result := Init(AAtlas, LGroupIndex);
end;

procedure TpxSprite.UpdateFrameSize();
var
  LSize: TpxSize;
  LRadius: Single;
begin
  if not Assigned(FAtlas) or (FGroupIndex = -1) then
    Exit;

  LSize := FAtlas.GetImageSize(FCurrentFrame, FGroupIndex);
  FWidth := LSize.w * FScale.x;
  FHeight := LSize.h * FScale.y;

  // Calculate radius as average of width and height
  LRadius := (LSize.w + LSize.h) * 0.5;
  FRadius := LRadius * ((FScale.x + FScale.y) * 0.5);

  // Update collision rect if using auto collision
  if FCollisionMethod = cmAuto then
  begin
    FCollisionRect.x := FPosition.x - (FWidth * 0.5);
    FCollisionRect.y := FPosition.y - (FHeight * 0.5);
    FCollisionRect.w := FWidth;
    FCollisionRect.h := FHeight;
    FCollisionRadius := FRadius;
  end;
end;

procedure TpxSprite.UpdateAnimation();
var
  LCompleted: Boolean;
begin
  if FFrameSpeed <= 0 then Exit;

  // NEW: If amOnce animation has already completed, do not update further.
  if FAnimationFinished then Exit;

  FFrameTimer := FFrameTimer + 1.0;
  LCompleted := False; // Reset LCompleted flag for current frame

  if FFrameTimer >= FAnimFramesPerUpdate then
  begin
    FFrameTimer := FFrameTimer - FAnimFramesPerUpdate;

    case FAnimationMode of
      amOnce:
        begin
          if FAnimationDirection > 0 then
          begin
            if FCurrentFrame < FLastFrame then
            begin
              Inc(FCurrentFrame);
              if Assigned(FOnAnimationFrame) then
                FOnAnimationFrame(Self, FCurrentFrame);
              if FCurrentFrame = FLastFrame then // If we just reached the last frame
                LCompleted := True;
            end
            else // Already at or past the last frame
              LCompleted := True;
          end
          else // FAnimationDirection is -1 (reverse)
          begin
            if FCurrentFrame > FFirstFrame then
            begin
              Dec(FCurrentFrame);
              if Assigned(FOnAnimationFrame) then
                FOnAnimationFrame(Self, FCurrentFrame);
              if FCurrentFrame = FFirstFrame then // If we just reached the first frame (in reverse)
                LCompleted := True;
            end
            else // Already at or past the first frame
              LCompleted := True;
          end;
        end;

      amLoop:
        begin
          if FAnimationDirection > 0 then
          begin
            Inc(FCurrentFrame);
            if FCurrentFrame > FLastFrame then
              FCurrentFrame := FFirstFrame;
          end
          else // FAnimationDirection is -1 (reverse loop)
          begin
            Dec(FCurrentFrame);
            if FCurrentFrame < FFirstFrame then
              FCurrentFrame := FLastFrame;
          end;
          if Assigned(FOnAnimationFrame) then
            FOnAnimationFrame(Self, FCurrentFrame);
          // LCompleted is not set for amLoop as it never 'completes' in the sense of stopping
        end;

      amPingPong:
        begin
          Inc(FCurrentFrame, FAnimationDirection);
          if (FCurrentFrame >= FLastFrame) or (FCurrentFrame <= FFirstFrame) then
          begin
            FAnimationDirection := -FAnimationDirection;
            TpxMath.ClipValueInt(FCurrentFrame, FFirstFrame, FLastFrame, False);
            // LCompleted only if a full forward-backward cycle is complete (back to start and going forward)
            if (FCurrentFrame = FFirstFrame) and (FAnimationDirection = 1) then
              LCompleted := True;
          end;
          if Assigned(FOnAnimationFrame) then
            FOnAnimationFrame(Self, FCurrentFrame);
        end;

      amReverse:
        begin
          Dec(FCurrentFrame);
          if FCurrentFrame < FFirstFrame then
          begin
            // Based on FLoopAnimation (always true by default in constructor), this mode always loops.
            if FLoopAnimation then
              FCurrentFrame := FLastFrame;
            // else if not looping, LCompleted would be set here, but FLoopAnimation is always true.
          end;
          if Assigned(FOnAnimationFrame) then
            FOnAnimationFrame(Self, FCurrentFrame);
          // LCompleted is not set for amReverse as it always loops.
        end;
    end;
  end;

  UpdateFrameSize();

  if LCompleted then // If any animation mode signaled completion
  begin
    // For amOnce, mark as finished to stop future updates
    if FAnimationMode = amOnce then
      FAnimationFinished := True;

    if Assigned(FOnAnimationComplete) then
      FOnAnimationComplete(Self, FCurrentAnimation);
  end;
end;

function TpxSprite.GetBestCollisionMethod(const AOther: TpxSprite): TpxCollisionMethod;
begin
  // Simple heuristic for auto collision selection
  if (FAngle = 0) and (AOther.FAngle = 0) then
    Result := cmAABB  // Both sprites not rotated - use fast AABB
  else if (Abs(FAngle) < 5) and (Abs(AOther.FAngle) < 5) then
    Result := cmAABB  // Nearly not rotated - AABB is close enough
  else
    Result := cmOBB;  // Rotated sprites - use OBB
end;

// Transform property implementations
function TpxSprite.GetPosition(): TpxVector;
begin
  Result := FPosition;
end;

procedure TpxSprite.SetPosition(const APosition: TpxVector);
begin
  FPosition := APosition;
  UpdateFrameSize(); // Update collision rect
end;

procedure TpxSprite.SetPosition(const AX: Single; const AY: Single);
begin
  FPosition.x := AX;
  FPosition.y := AY;
  UpdateFrameSize(); // Update collision rect
end;

function TpxSprite.GetVelocity(): TpxVector;
begin
  Result := FVelocity;
end;

procedure TpxSprite.SetVelocity(const AVelocity: TpxVector);
begin
  FVelocity := AVelocity;
end;

procedure TpxSprite.SetVelocity(const AX: Single; const AY: Single);
begin
  FVelocity.x := AX;
  FVelocity.y := AY;
end;

function TpxSprite.GetScale(): TpxVector;
begin
  Result := FScale;
end;

procedure TpxSprite.SetScale(const AScale: TpxVector);
begin
  FScale := AScale;
  UpdateFrameSize();
end;

procedure TpxSprite.SetScale(const AX: Single; const AY: Single);
begin
  FScale.x := AX;
  FScale.y := AY;
  UpdateFrameSize();
end;

procedure TpxSprite.SetScale(const AUniform: Single);
begin
  FScale.x := AUniform;
  FScale.y := AUniform;
  UpdateFrameSize();
end;

function TpxSprite.GetAngle(): Single;
begin
  Result := FAngle;
end;

procedure TpxSprite.SetAngle(const AAngle: Single);
begin
  FAngle := AAngle;
  TpxMath.ClipValueFloat(FAngle, 0, 360, True);
end;

function TpxSprite.GetAngularVelocity(): Single;
begin
  Result := FAngularVelocity;
end;

procedure TpxSprite.SetAngularVelocity(const AAngularVelocity: Single);
begin
  FAngularVelocity := AAngularVelocity;
end;

// Visual property implementations
function TpxSprite.GetColor(): TpxColor;
begin
  Result := FColor;
end;

procedure TpxSprite.SetColor(const AColor: TpxColor);
begin
  FColor := AColor;
end;

function TpxSprite.GetAlpha(): Single;
begin
  Result := FAlpha;
end;

procedure TpxSprite.SetAlpha(const AAlpha: Single);
begin
  FAlpha := AAlpha;
  TpxMath.ClipValueFloat(FAlpha, 0.0, 1.0, False);
  FColor.a := FAlpha;
end;

function TpxSprite.GetHFlip(): Boolean;
begin
  Result := FHFlip;
end;

procedure TpxSprite.SetHFlip(const AFlip: Boolean);
begin
  FHFlip := AFlip;
end;

function TpxSprite.GetVFlip(): Boolean;
begin
  Result := FVFlip;
end;

procedure TpxSprite.SetVFlip(const AFlip: Boolean);
begin
  FVFlip := AFlip;
end;

function TpxSprite.GetVisible(): Boolean;
begin
  Result := FVisible;
end;

procedure TpxSprite.SetVisible(const AVisible: Boolean);
begin
  FVisible := AVisible;
end;

function TpxSprite.GetBlendMode(): TpxBlendMode;
begin
  Result := FBlendMode;
end;

procedure TpxSprite.SetBlendMode(const AMode: TpxBlendMode);
begin
  FBlendMode := AMode;
end;

// Animation control implementations
function TpxSprite.PlayAnimation(const AName: string): Boolean;
var
  LSequence: TpxAnimationSequence;
begin
  Result := False;

  if not Assigned(FAtlas) then
  begin
    SetError('Atlas not assigned', []);
    Exit;
  end;

  if not FAtlas.HasAnimation(AName) then
  begin
    SetError('Animation "%s" not found', [AName]);
    Exit;
  end;

  LSequence := FAtlas.GetAnimation(AName);
  FCurrentAnimation := AName;
  FFirstFrame := LSequence.StartFrame;
  FLastFrame := LSequence.EndFrame;
  SetFrameSpeed(LSequence.FrameSpeed);
  FAnimationMode := LSequence.Mode;
  FAnimationDirection := 1;
  FCurrentFrame := FFirstFrame;
  FFrameTimer := 0.0;
  FAnimationFinished := False; // NEW: Reset the finished flag when playing a new animation

  UpdateFrameSize();
  Result := True;
end;

procedure TpxSprite.SetFrame(const AFrame: Integer);
var
  LImageCount: Integer;
begin
  if not Assigned(FAtlas) or (FGroupIndex = -1) then
    Exit;

  LImageCount := FAtlas.GetImageCount(FGroupIndex);
  FCurrentFrame := AFrame;
  TpxMath.ClipValueInt(FCurrentFrame, 0, LImageCount - 1, False);
  UpdateFrameSize();
  // Setting frame manually might imply animation is not "finished" if it was amOnce
  // But generally SetFrame is for static frames or starting a new animation.
  FAnimationFinished := False;
end;

function TpxSprite.GetFrame(): Integer;
begin
  Result := FCurrentFrame;
end;

procedure TpxSprite.SetFrameSpeed(const ASpeed: Single);
begin
  FFrameSpeed := Max(0.01, ASpeed); // Animation frames per second
  if TpxWindow.GetTargetFPS() > 0 then
    FAnimFramesPerUpdate := TpxWindow.GetTargetFPS() / FFrameSpeed
  else
    FAnimFramesPerUpdate := 1.0; // If TargetFPS is 0 (unlimited), advance frame every update
end;


function TpxSprite.GetFrameSpeed(): Single;
begin
  Result := FFrameSpeed;
end;

function TpxSprite.IsAnimationComplete(): Boolean;
begin
  // NEW: Now directly returns the FAnimationFinished flag
  Result := FAnimationFinished;
end;

procedure TpxSprite.ResetAnimation();
begin
  FCurrentFrame := FFirstFrame;
  FFrameTimer := 0.0;
  FAnimationDirection := 1;
  FAnimationFinished := False; // NEW: Reset the finished flag on animation reset
  UpdateFrameSize();
end;

// Movement helper implementations
procedure TpxSprite.Move(const ADeltaX: Single; const ADeltaY: Single);
begin
  FPosition.x := FPosition.x + ADeltaX;
  FPosition.y := FPosition.y + ADeltaY;
  UpdateFrameSize(); // Update collision rect
end;

procedure TpxSprite.Thrust(const ASpeed: Single);
var
  LAngleInt: Integer;
  LCos: Single;
  LSin: Single;
begin
  LAngleInt := Round(FAngle + 90.0);
  LAngleInt := TpxMath.ClipValueInt(LAngleInt, 0, 360, True);

  LCos := TpxMath.AngleCos(LAngleInt);
  LSin := TpxMath.AngleSin(LAngleInt);

  FVelocity.x := LCos * ASpeed;
  FVelocity.y := -LSin * ASpeed; // Negative because Y is typically inverted in 2D graphics
end;

procedure TpxSprite.ThrustAtAngle(const AAngle: Single; const ASpeed: Single);
var
  LAngleInt: Integer;
  LCos: Single;
  LSin: Single;
begin
  LAngleInt := Round(AAngle);
  TpxMath.ClipValueInt(LAngleInt, 0, 360, True);

  LCos := TpxMath.AngleCos(LAngleInt);
  LSin := TpxMath.AngleSin(LAngleInt);

  FVelocity.x := LCos * ASpeed;
  FVelocity.y := -LSin * ASpeed; // Negative because Y is typically inverted in 2D graphics
end;

function TpxSprite.MoveToward(const ATargetX: Single; const ATargetY: Single; const ASpeed: Single): Boolean;
var
  LTarget: TpxVector;
  LDistance: Single;
  LDirection: TpxVector;
begin
  LTarget.x := ATargetX;
  LTarget.y := ATargetY;

  LDistance := FPosition.Distance(LTarget);
  Result := LDistance <= ASpeed;

  if Result then
  begin
    FPosition := LTarget;
    FVelocity.x := 0;
    FVelocity.y := 0;
  end
  else
  begin
    LDirection := LTarget;
    LDirection.Subtract(FPosition);
    LDirection.Normalize();

    FVelocity.x := LDirection.x * ASpeed;
    FVelocity.y := LDirection.y * ASpeed;
  end;

  UpdateFrameSize(); // Update collision rect
end;

function TpxSprite.RotateToward(const ATargetAngle: Single; const ASpeed: Single): Boolean;
var
  LAngleDiff: Single;
  LAbsDiff: Single;
begin
  LAngleDiff := TpxMath.AngleDifference(FAngle, ATargetAngle);
  LAbsDiff := Abs(LAngleDiff);

  Result := LAbsDiff <= ASpeed;

  if Result then
  begin
    FAngle := ATargetAngle;
    FAngularVelocity := 0;
  end
  else
  begin
    if LAngleDiff > 0 then
      FAngularVelocity := ASpeed
    else
      FAngularVelocity := -ASpeed;
  end;
end;

function TpxSprite.RotateTowardPoint(const ATargetX: Single; const ATargetY: Single; const ASpeed: Single): Boolean;
var
  LTarget: TpxVector;
  LTargetAngle: Single;
begin
  LTarget.x := ATargetX - FPosition.x;
  LTarget.y := ATargetY - FPosition.y;

  LTargetAngle := Arctan2(LTarget.y, LTarget.x) * pxRAD2DEG;
  TpxMath.ClipValueFloat(LTargetAngle, 0, 360, True);

  Result := RotateToward(LTargetAngle, ASpeed);
end;

// Collision implementations
function TpxSprite.Collide(const AOther: TpxSprite; const AMethod: TpxCollisionMethod): Boolean;
var
  LMethod: TpxCollisionMethod;
  LCenter1: TpxVector;
  LCenter2: TpxVector;
  LOBB1: TpxOBB;
  LOBB2: TpxOBB;
  LRect1: TpxRect;
  LRect2: TpxRect;
begin
  Result := False;

  if not Assigned(AOther) then
    Exit;

  LMethod := AMethod;
  if LMethod = cmAuto then
    LMethod := GetBestCollisionMethod(AOther);

  case LMethod of
    cmCircle:
      begin
        Result := TpxMath.CirclesOverlap(
          FPosition, FRadius * FCollisionScale,
          AOther.FPosition, AOther.FRadius * AOther.FCollisionScale
        );
      end;

    cmAABB:
      begin
        LRect1 := GetBounds();
        LRect2 := AOther.GetBounds();
        Result := TpxMath.RectanglesOverlap(LRect1, LRect2);
      end;

    cmOBB:
      begin
        LCenter1 := FPosition;
        LCenter2 := AOther.FPosition;

        LOBB1.Center := LCenter1;
        LOBB1.HalfWidth := FWidth * 0.5 * FCollisionScale;
        LOBB1.HalfHeight := FHeight * 0.5 * FCollisionScale;
        LOBB1.Rotation := FAngle;

        LOBB2.Center := LCenter2;
        LOBB2.HalfWidth := AOther.FWidth * 0.5 * AOther.FCollisionScale;
        LOBB2.HalfHeight := AOther.FHeight * 0.5 * AOther.FCollisionScale;
        LOBB2.Rotation := AOther.FAngle;

        Result := TpxMath.OBBsOverlap(LOBB1, LOBB2);
      end;

    cmPixelPerfect:
      begin
        // For pixel-perfect collision, fall back to OBB for now
        // This could be enhanced with actual pixel-level collision detection
        Result := Collide(AOther, cmOBB);
      end;
  end;
end;

function TpxSprite.Collide(const AX: Single; const AY: Single; const ARadius: Single): Boolean;
var
  LPoint: TpxVector;
begin
  LPoint.x := AX;
  LPoint.y := AY;

  Result := TpxMath.CirclesOverlap(
    FPosition, FRadius * FCollisionScale,
    LPoint, ARadius
  );
end;

function TpxSprite.CollideRect(const ARect: TpxRect): Boolean;
var
  LBounds: TpxRect;
begin
  LBounds := GetBounds();
  Result := TpxMath.RectanglesOverlap(LBounds, ARect);
end;

procedure TpxSprite.SetCollisionMethod(const AMethod: TpxCollisionMethod);
begin
  FCollisionMethod := AMethod;
end;

procedure TpxSprite.SetCollisionRadius(const ARadius: Single);
begin
  FCollisionRadius := ARadius;
end;

procedure TpxSprite.SetCollisionRect(const ARect: TpxRect);
begin
  FCollisionRect := ARect;
end;

procedure TpxSprite.SetCollisionScale(const AScale: Single);
begin
  FCollisionScale := Max(0.1, AScale);
end;

// Bounds checking implementations
function TpxSprite.IsVisible(const AViewRect: TpxRect): Boolean;
var
  LBounds: TpxRect;
begin
  LBounds := GetBounds();
  Result := TpxMath.RectanglesOverlap(LBounds, AViewRect);
end;

function TpxSprite.IsFullyVisible(const AViewRect: TpxRect): Boolean;
var
  LBounds: TpxRect;
begin
  LBounds := GetBounds();
  Result := (LBounds.x >= AViewRect.x) and
            (LBounds.y >= AViewRect.y) and
            (LBounds.x + LBounds.w <= AViewRect.x + AViewRect.w) and
            (LBounds.y + LBounds.h <= AViewRect.y + AViewRect.h);
end;

function TpxSprite.GetBounds(): TpxRect;
begin
  Result.x := FPosition.x - (FWidth * 0.5);
  Result.y := FPosition.y - (FHeight * 0.5);
  Result.w := FWidth;
  Result.h := FHeight;
end;

// Size property implementations
function TpxSprite.GetWidth(): Single;
begin
  Result := FWidth;
end;

function TpxSprite.GetHeight(): Single;
begin
  Result := FHeight;
end;

function TpxSprite.GetRadius(): Single;
begin
  Result := FRadius;
end;

// Update and render implementations
procedure TpxSprite.Update();
begin
  // Update position based on velocity (frame-based)
  FPosition.x := FPosition.x + FVelocity.x;
  FPosition.y := FPosition.y + FVelocity.y;

  // Update angle based on angular velocity (frame-based)
  if FAngularVelocity <> 0 then
  begin
    FAngle := FAngle + FAngularVelocity;
    TpxMath.ClipValueFloat(FAngle, 0, 360, True);
  end;

  // Update animation (frame-based)
  UpdateAnimation();

  // Update collision bounds
  UpdateFrameSize();
end;

procedure TpxSprite.Render();
var
  LTexture: TpxTexture;
  LRegion: TpxTextureRegion;
  LOrigin: TpxVector;
  LScale: TpxVector;
  LRegionRect: TpxRect;
begin
  if not FVisible or not Assigned(FAtlas) or (FGroupIndex = -1) then
    Exit;

  LRegion := FAtlas.GetImageRegion(FCurrentFrame, FGroupIndex);
  LTexture := FAtlas.GetTexture(LRegion.TextureIndex);

  if not Assigned(LTexture) then
    Exit;

  // Set up rendering parameters
  LOrigin.x := 0.5; // Center origin
  LOrigin.y := 0.5;
  LScale := FScale;
  LRegionRect := LRegion.Rect;

  // Apply current blend mode
  TpxWindow.SetBlendMode(FBlendMode);

  // Draw the sprite
  LTexture.Draw(
    FPosition.x, FPosition.y,    // Position
    FColor,                      // Color tint
    @LRegionRect,               // Source region
    @LOrigin,                   // Origin point
    @LScale,                    // Scale
    FAngle,                     // Rotation angle
    FHFlip,                     // Horizontal flip
    FVFlip                      // Vertical flip
  );

  // Restore default blend mode
  TpxWindow.RestoreDefaultBlendMode();
end;

function TpxSprite.GetCurrentAnimation(): string;
begin
  Result := FCurrentAnimation;
end;

end.
