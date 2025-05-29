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

unit PIXELS.Console;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Base,
  PIXELS.Graphics;

/// <summary>
/// Line feed character constant for console text formatting.
/// </summary>
/// <remarks>
/// Represents the ASCII line feed character (ASCII 10) used for line breaks in console output.
/// </remarks>
const
  pxLF   = AnsiChar(#10);

/// <summary>
/// Carriage return character constant for console text formatting.
/// </summary>
/// <remarks>
/// Represents the ASCII carriage return character (ASCII 13) used for moving cursor to start of line.
/// </remarks>
  pxCR   = AnsiChar(#13);

/// <summary>
/// Combined carriage return and line feed constant for Windows-style line endings.
/// </summary>
/// <remarks>
/// Standard Windows line ending sequence combining line feed and carriage return.
/// </remarks>
  pxCRLF = pxLF+pxCR;

/// <summary>
/// Escape character constant used in ANSI escape sequences.
/// </summary>
/// <remarks>
/// The ASCII escape character (ASCII 27) that begins all ANSI terminal control sequences.
/// </remarks>
  pxESC  = AnsiChar(#27);

/// <summary>
/// Virtual key code for the Escape key.
/// </summary>
/// <remarks>
/// Standard Windows virtual key code for the Escape key, commonly used for canceling operations.
/// </remarks>
  VK_ESC = 27;

  // Cursor Movement
/// <summary>
/// ANSI escape sequence template for positioning the cursor at specific row and column coordinates.
/// </summary>
/// <remarks>
/// Format string that takes row and column parameters to create a cursor positioning command.
/// Coordinates are 1-based. Usage: Format(pxCSICursorPos, [Row, Column])
/// </remarks>
  pxCSICursorPos       = pxESC + '[%d;%dH';     // Set cursor to (row, col)

/// <summary>
/// ANSI escape sequence template for moving the cursor up by specified number of lines.
/// </summary>
/// <remarks>
/// Format string that takes a line count parameter. Usage: Format(pxCSICursorUp, [LineCount])
/// </remarks>
  pxCSICursorUp        = pxESC + '[%dA';        // Move cursor up by n lines

/// <summary>
/// ANSI escape sequence template for moving the cursor down by specified number of lines.
/// </summary>
/// <remarks>
/// Format string that takes a line count parameter. Usage: Format(pxCSICursorDown, [LineCount])
/// </remarks>
  pxCSICursorDown      = pxESC + '[%dB';        // Move cursor down by n lines

/// <summary>
/// ANSI escape sequence template for moving the cursor forward (right) by specified number of columns.
/// </summary>
/// <remarks>
/// Format string that takes a column count parameter. Usage: Format(pxCSICursorForward, [ColumnCount])
/// </remarks>
  pxCSICursorForward   = pxESC + '[%dC';        // Move cursor forward (right) by n columns

/// <summary>
/// ANSI escape sequence template for moving the cursor backward (left) by specified number of columns.
/// </summary>
/// <remarks>
/// Format string that takes a column count parameter. Usage: Format(pxCSICursorBack, [ColumnCount])
/// </remarks>
  pxCSICursorBack      = pxESC + '[%dD';        // Move cursor back (left) by n columns

/// <summary>
/// ANSI escape sequence for saving the current cursor position.
/// </summary>
/// <remarks>
/// Saves the cursor position so it can be restored later with pxCSIRestoreCursorPos.
/// </remarks>
  pxCSISaveCursorPos   = pxESC + '[s';          // Save current cursor position

/// <summary>
/// ANSI escape sequence for restoring the previously saved cursor position.
/// </summary>
/// <remarks>
/// Restores the cursor to the position saved with pxCSISaveCursorPos.
/// </remarks>
  pxCSIRestoreCursorPos= pxESC + '[u';          // Restore previously saved cursor position

/// <summary>
/// ANSI escape sequence for moving the cursor to the home position (1,1).
/// </summary>
/// <remarks>
/// Moves the cursor to the top-left corner of the console window.
/// </remarks>
  pxCSICursorHomePos   = pxESC + '[H';          // Move cursor to home position (1,1)

  // Cursor Visibility
/// <summary>
/// ANSI escape sequence for making the cursor visible.
/// </summary>
/// <remarks>
/// Shows the cursor if it was previously hidden. Most terminals show cursor by default.
/// </remarks>
  pxCSIShowCursor      = pxESC + '[?25h';       // Show cursor

/// <summary>
/// ANSI escape sequence for hiding the cursor.
/// </summary>
/// <remarks>
/// Makes the cursor invisible. Useful during output operations to prevent flicker.
/// </remarks>
  pxCSIHideCursor      = pxESC + '[?25l';       // Hide cursor

/// <summary>
/// ANSI escape sequence for enabling cursor blinking.
/// </summary>
/// <remarks>
/// Makes the cursor blink on and off. Not supported by all terminals.
/// </remarks>
  pxCSIBlinkCursor     = pxESC + '[?12h';       // Enable blinking cursor

/// <summary>
/// ANSI escape sequence for disabling cursor blinking (steady cursor).
/// </summary>
/// <remarks>
/// Makes the cursor display steadily without blinking.
/// </remarks>
  pxCSISteadyCursor    = pxESC + '[?12l';       // Disable blinking cursor (steady)

  // Screen Manipulation
/// <summary>
/// ANSI escape sequence for clearing the entire screen and moving cursor to home position.
/// </summary>
/// <remarks>
/// Clears all text from the console and positions the cursor at the top-left corner.
/// </remarks>
  pxCSIClearScreen     = pxESC + '[2J';         // Clear entire screen and move cursor to home

/// <summary>
/// ANSI escape sequence for clearing the entire current line.
/// </summary>
/// <remarks>
/// Erases all text on the line where the cursor is currently positioned.
/// </remarks>
  pxCSIClearLine       = pxESC + '[2K';         // Clear entire current line

/// <summary>
/// ANSI escape sequence for clearing from cursor position to end of line.
/// </summary>
/// <remarks>
/// Erases text from the cursor position to the end of the current line.
/// </remarks>
  pxCSIClearToEndOfLine= pxESC + '[K';          // Clear from cursor to end of line

/// <summary>
/// ANSI escape sequence template for scrolling the screen up by specified number of lines.
/// </summary>
/// <remarks>
/// Format string that takes a line count parameter. Usage: Format(pxCSIScrollUp, [LineCount])
/// </remarks>
  pxCSIScrollUp        = pxESC + '[%dS';        // Scroll screen up by n lines

/// <summary>
/// ANSI escape sequence template for scrolling the screen down by specified number of lines.
/// </summary>
/// <remarks>
/// Format string that takes a line count parameter. Usage: Format(pxCSIScrollDown, [LineCount])
/// </remarks>
  pxCSIScrollDown      = pxESC + '[%dT';        // Scroll screen down by n lines

  // Text Formatting
/// <summary>
/// ANSI escape sequence for enabling bold text formatting.
/// </summary>
/// <remarks>
/// Makes subsequent text appear in bold/bright style until reset.
/// </remarks>
  pxCSIBold            = pxESC + '[1m';         // Enable bold text

/// <summary>
/// ANSI escape sequence for enabling underlined text formatting.
/// </summary>
/// <remarks>
/// Makes subsequent text appear underlined until reset.
/// </remarks>
  pxCSIUnderline       = pxESC + '[4m';         // Enable underline

/// <summary>
/// ANSI escape sequence for resetting all text formatting attributes to default.
/// </summary>
/// <remarks>
/// Removes all text formatting (bold, underline, colors, etc.) and returns to normal text.
/// </remarks>
  pxCSIResetFormat     = pxESC + '[0m';         // Reset all text attributes

/// <summary>
/// ANSI escape sequence for resetting background color to default.
/// </summary>
/// <remarks>
/// Resets only the background color while preserving other formatting attributes.
/// </remarks>
  pxCSIResetBackground = pxESC + '[49m';           // Reset background color to default

/// <summary>
/// ANSI escape sequence for resetting foreground color to default.
/// </summary>
/// <remarks>
/// Resets only the text color while preserving other formatting attributes.
/// </remarks>
  pxCSIResetForeground = pxESC + '[39m';           // Reset foreground color to default

/// <summary>
/// ANSI escape sequence for inverting foreground and background colors.
/// </summary>
/// <remarks>
/// Swaps text and background colors for a reverse video effect.
/// </remarks>
  pxCSIInvertColors    = pxESC + '[7m';         // Invert foreground and background colors

/// <summary>
/// ANSI escape sequence for disabling color inversion.
/// </summary>
/// <remarks>
/// Returns colors to normal (non-inverted) display.
/// </remarks>
  pxCSINormalColors    = pxESC + '[27m';        // Disable inverted colors

/// <summary>
/// ANSI escape sequence for dim (faint) text formatting.
/// </summary>
/// <remarks>
/// Makes text appear dimmer than normal. Not supported by all terminals.
/// </remarks>
  pxCSIDim             = pxESC + '[2m';         // Dim (faint) text

/// <summary>
/// ANSI escape sequence for italic text formatting.
/// </summary>
/// <remarks>
/// Makes text appear in italic style. Not supported by all terminals.
/// </remarks>
  pxCSIItalic          = pxESC + '[3m';         // Italic text

/// <summary>
/// ANSI escape sequence for blinking text formatting.
/// </summary>
/// <remarks>
/// Makes text blink on and off. Rarely supported in modern terminals.
/// </remarks>
  pxCSIBlink           = pxESC + '[5m';         // Blinking text

/// <summary>
/// ANSI escape sequence for framed text formatting.
/// </summary>
/// <remarks>
/// Draws a frame around text. Very rarely supported.
/// </remarks>
  pxCSIFramed          = pxESC + '[51m';        // Framed text

/// <summary>
/// ANSI escape sequence for encircled text formatting.
/// </summary>
/// <remarks>
/// Draws a circle around text. Very rarely supported.
/// </remarks>
  pxCSIEncircled       = pxESC + '[52m';        // Encircled text

  // Text Modification
/// <summary>
/// ANSI escape sequence template for inserting blank characters at cursor position.
/// </summary>
/// <remarks>
/// Format string that takes a character count parameter. Usage: Format(pxCSIInsertChar, [CharCount])
/// </remarks>
  pxCSIInsertChar      = pxESC + '[%d@';        // Insert n blank characters at cursor

/// <summary>
/// ANSI escape sequence template for deleting characters at cursor position.
/// </summary>
/// <remarks>
/// Format string that takes a character count parameter. Usage: Format(pxCSIDeleteChar, [CharCount])
/// </remarks>
  pxCSIDeleteChar      = pxESC + '[%dP';        // Delete n characters at cursor

/// <summary>
/// ANSI escape sequence template for erasing characters at cursor position (replaces with spaces).
/// </summary>
/// <remarks>
/// Format string that takes a character count parameter. Usage: Format(pxCSIEraseChar, [CharCount])
/// </remarks>
  pxCSIEraseChar       = pxESC + '[%dX';        // Erase n characters at cursor (replaces with space)

  // Colors (Foreground)
/// <summary>
/// ANSI escape sequence for setting foreground color to black.
/// </summary>
  pxCSIFGBlack         = pxESC + '[30m';        // Set foreground to black

/// <summary>
/// ANSI escape sequence for setting foreground color to red.
/// </summary>
  pxCSIFGRed           = pxESC + '[31m';        // Set foreground to red

/// <summary>
/// ANSI escape sequence for setting foreground color to green.
/// </summary>
  pxCSIFGGreen         = pxESC + '[32m';        // Set foreground to green

/// <summary>
/// ANSI escape sequence for setting foreground color to yellow.
/// </summary>
  pxCSIFGYellow        = pxESC + '[33m';        // Set foreground to yellow

/// <summary>
/// ANSI escape sequence for setting foreground color to blue.
/// </summary>
  pxCSIFGBlue          = pxESC + '[34m';        // Set foreground to blue

/// <summary>
/// ANSI escape sequence for setting foreground color to magenta.
/// </summary>
  pxCSIFGMagenta       = pxESC + '[35m';        // Set foreground to magenta

/// <summary>
/// ANSI escape sequence for setting foreground color to cyan.
/// </summary>
  pxCSIFGCyan          = pxESC + '[36m';        // Set foreground to cyan

/// <summary>
/// ANSI escape sequence for setting foreground color to white.
/// </summary>
  pxCSIFGWhite         = pxESC + '[37m';        // Set foreground to white

  // Colors (Background)
/// <summary>
/// ANSI escape sequence for setting background color to black.
/// </summary>
  pxCSIBGBlack         = pxESC + '[40m';        // Set background to black

/// <summary>
/// ANSI escape sequence for setting background color to red.
/// </summary>
  pxCSIBGRed           = pxESC + '[41m';        // Set background to red

/// <summary>
/// ANSI escape sequence for setting background color to green.
/// </summary>
  pxCSIBGGreen         = pxESC + '[42m';        // Set background to green

/// <summary>
/// ANSI escape sequence for setting background color to yellow.
/// </summary>
  pxCSIBGYellow        = pxESC + '[43m';        // Set background to yellow

/// <summary>
/// ANSI escape sequence for setting background color to blue.
/// </summary>
  pxCSIBGBlue          = pxESC + '[44m';        // Set background to blue

/// <summary>
/// ANSI escape sequence for setting background color to magenta.
/// </summary>
  pxCSIBGMagenta       = pxESC + '[45m';        // Set background to magenta

/// <summary>
/// ANSI escape sequence for setting background color to cyan.
/// </summary>
  pxCSIBGCyan          = pxESC + '[46m';        // Set background to cyan

/// <summary>
/// ANSI escape sequence for setting background color to white.
/// </summary>
  pxCSIBGWhite         = pxESC + '[47m';        // Set background to white

  // Bright Foreground Colors
/// <summary>
/// ANSI escape sequence for setting bright foreground color to black (gray).
/// </summary>
  pxCSIFGBrightBlack   = pxESC + '[90m';        // Set bright foreground to black (gray)

/// <summary>
/// ANSI escape sequence for setting bright foreground color to red.
/// </summary>
  pxCSIFGBrightRed     = pxESC + '[91m';        // Set bright foreground to red

/// <summary>
/// ANSI escape sequence for setting bright foreground color to green.
/// </summary>
  pxCSIFGBrightGreen   = pxESC + '[92m';        // Set bright foreground to green

/// <summary>
/// ANSI escape sequence for setting bright foreground color to yellow.
/// </summary>
  pxCSIFGBrightYellow  = pxESC + '[93m';        // Set bright foreground to yellow

/// <summary>
/// ANSI escape sequence for setting bright foreground color to blue.
/// </summary>
  pxCSIFGBrightBlue    = pxESC + '[94m';        // Set bright foreground to blue

/// <summary>
/// ANSI escape sequence for setting bright foreground color to magenta.
/// </summary>
  pxCSIFGBrightMagenta = pxESC + '[95m';        // Set bright foreground to magenta

/// <summary>
/// ANSI escape sequence for setting bright foreground color to cyan.
/// </summary>
  pxCSIFGBrightCyan    = pxESC + '[96m';        // Set bright foreground to cyan

/// <summary>
/// ANSI escape sequence for setting bright foreground color to white.
/// </summary>
  pxCSIFGBrightWhite   = pxESC + '[97m';        // Set bright foreground to white

  // Bright Background Colors
/// <summary>
/// ANSI escape sequence for setting bright background color to black (gray).
/// </summary>
  pxCSIBGBrightBlack   = pxESC + '[100m';       // Set bright background to black (gray)

/// <summary>
/// ANSI escape sequence for setting bright background color to red.
/// </summary>
  pxCSIBGBrightRed     = pxESC + '[101m';       // Set bright background to red

/// <summary>
/// ANSI escape sequence for setting bright background color to green.
/// </summary>
  pxCSIBGBrightGreen   = pxESC + '[102m';       // Set bright background to green

/// <summary>
/// ANSI escape sequence for setting bright background color to yellow.
/// </summary>
  pxCSIBGBrightYellow  = pxESC + '[103m';       // Set bright background to yellow

/// <summary>
/// ANSI escape sequence for setting bright background color to blue.
/// </summary>
  pxCSIBGBrightBlue    = pxESC + '[104m';       // Set bright background to blue

/// <summary>
/// ANSI escape sequence for setting bright background color to magenta.
/// </summary>
  pxCSIBGBrightMagenta = pxESC + '[105m';       // Set bright background to magenta

/// <summary>
/// ANSI escape sequence for setting bright background color to cyan.
/// </summary>
  pxCSIBGBrightCyan    = pxESC + '[106m';       // Set bright background to cyan

/// <summary>
/// ANSI escape sequence for setting bright background color to white.
/// </summary>
  pxCSIBGBrightWhite   = pxESC + '[107m';       // Set bright background to white

  // RGB Colors
/// <summary>
/// ANSI escape sequence template for setting foreground color using RGB values.
/// </summary>
/// <remarks>
/// Format string that takes red, green, and blue parameters (0-255 each).
/// Usage: Format(pxCSIFGRGB, [Red, Green, Blue])
/// </remarks>
  pxCSIFGRGB           = pxESC + '[38;2;%d;%d;%dm'; // Set foreground to RGB color

/// <summary>
/// ANSI escape sequence template for setting background color using RGB values.
/// </summary>
/// <remarks>
/// Format string that takes red, green, and blue parameters (0-255 each).
/// Usage: Format(pxCSIBGRGB, [Red, Green, Blue])
/// </remarks>
  pxCSIBGRGB           = pxESC + '[48;2;%d;%d;%dm'; // Set background to RGB color

type

  /// <summary>
  /// Set of AnsiChar characters used for input validation and text processing operations.
  /// </summary>
  /// <remarks>
  /// This type is commonly used to specify allowed characters for input functions
  /// or to define character sets for text parsing and validation operations.
  /// </remarks>
  /// <example>
  /// <code>
  /// var LDigits: TpxCharSet := ['0'..'9'];
  /// var LAlpha: TpxCharSet := ['a'..'z', 'A'..'Z'];
  /// </code>
  /// </example>
  { TpxCharSet }
  TpxCharSet = set of AnsiChar;

  /// <summary>
  /// Static class providing comprehensive console input/output operations with ANSI color and cursor control support.
  /// Offers platform-specific console functionality including text formatting, cursor positioning, and user input handling.
  /// </summary>
  /// <remarks>
  /// TpxConsole provides a rich set of console manipulation features including:
  /// - ANSI color support with RGB precision
  /// - Cursor positioning and visibility control
  /// - Text formatting (bold, underline, etc.)
  /// - Clipboard integration
  /// - Special input functions like teletype effect
  /// - Cross-platform console detection and handling
  ///
  /// The class automatically enables virtual terminal processing on Windows for ANSI escape sequence support.
  /// All color operations use RGB values (0-255) or TpxColor records for consistency with the graphics system.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Basic colored output
  /// TpxConsole.SetForegroundColor(255, 0, 0); // Red text
  /// TpxConsole.PrintLn('This is red text');
  /// TpxConsole.ResetTextFormat();
  ///
  /// // Cursor manipulation
  /// TpxConsole.SetCursorPos(10, 5);
  /// TpxConsole.Print('Text at position 10,5');
  /// </code>
  /// </example>
  { TpxConsole }
  TpxConsole = class(TpxStaticObject)
  private class var
    FTeletypeDelay: Integer;
    FKeyState: array [0..1, 0..255] of Boolean;
    FPerformanceFrequency: Int64;
  private
    class constructor Create();
    class destructor Destroy();
  public
    /// <summary>
    /// Checks if the application has console output capability.
    /// </summary>
    /// <returns>True if console output is available, False otherwise</returns>
    /// <remarks>
    /// This method determines whether the application can write to a console window.
    /// Returns False if the application is running without a console (e.g., as a Windows GUI app)
    /// or if console output has been redirected.
    /// </remarks>
    class function  HasConsoleOutput(): Boolean; static;

    /// <summary>
    /// Determines if the application was started from a command line console.
    /// </summary>
    /// <returns>True if started from console, False if started from GUI or other means</returns>
    /// <remarks>
    /// Useful for determining whether to show pause prompts or console-specific behavior.
    /// Applications started from GUI (like double-clicking) typically return False.
    /// </remarks>
    class function  StartedFromConsole(): Boolean; static;

    /// <summary>
    /// Detects if the application is running under the Delphi IDE environment.
    /// </summary>
    /// <returns>True if running in Delphi IDE, False otherwise</returns>
    /// <remarks>
    /// Checks for Delphi IDE environment variables to determine execution context.
    /// Useful for enabling debug-specific console behavior during development.
    /// </remarks>
    class function  StartedFromDelphiIDE(): Boolean; static;

    /// <summary>
    /// Creates an ANSI escape sequence string for setting foreground color using RGB values.
    /// </summary>
    /// <param name="ARed">Red component (0-255)</param>
    /// <param name="AGreen">Green component (0-255)</param>
    /// <param name="ABlue">Blue component (0-255)</param>
    /// <returns>ANSI escape sequence string for the specified color</returns>
    /// <remarks>
    /// Returns an empty string if console output is not available. The returned string
    /// can be embedded in text or used with print functions for color formatting.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LRedColor := TpxConsole.CreateForegroundColor(255, 0, 0);
    /// TpxConsole.Print(LRedColor + 'Red text' + pxCSIResetFormat);
    /// </code>
    /// </example>
    class function  CreateForegroundColor(const ARed, AGreen, ABlue: Byte): string; overload; static;

    /// <summary>
    /// Creates an ANSI escape sequence string for setting foreground color using a TpxColor record.
    /// </summary>
    /// <param name="AColor">TpxColor record with RGBA components (0.0-1.0 range)</param>
    /// <returns>ANSI escape sequence string for the specified color</returns>
    /// <remarks>
    /// Converts TpxColor floating-point values (0.0-1.0) to RGB byte values (0-255) internally.
    /// The alpha component is ignored for console text coloring.
    /// </remarks>
    /// <seealso cref="CreateForegroundColor"/>
    class function  CreateForegroundColor(const AColor: TpxColor): string; overload; static;

    /// <summary>
    /// Creates an ANSI escape sequence string for setting background color using RGB values.
    /// </summary>
    /// <param name="ARed">Red component (0-255)</param>
    /// <param name="AGreen">Green component (0-255)</param>
    /// <param name="ABlue">Blue component (0-255)</param>
    /// <returns>ANSI escape sequence string for the specified background color</returns>
    /// <remarks>
    /// Similar to CreateForegroundColor but affects the background color behind text.
    /// Returns an empty string if console output is not available.
    /// </remarks>
    class function  CreateBackgroundColor(const ARed, AGreen, ABlue: Byte): string; overload; static;

    /// <summary>
    /// Creates an ANSI escape sequence string for setting background color using a TpxColor record.
    /// </summary>
    /// <param name="AColor">TpxColor record with RGBA components (0.0-1.0 range)</param>
    /// <returns>ANSI escape sequence string for the specified background color</returns>
    /// <remarks>
    /// Converts TpxColor floating-point values to RGB byte values internally.
    /// The alpha component is ignored for console background coloring.
    /// </remarks>
    class function  CreateBackgroundColor(const AColor: TpxColor): string; overload; static;

    /// <summary>
    /// Immediately sets the console foreground (text) color using RGB values.
    /// </summary>
    /// <param name="ARed">Red component (0-255)</param>
    /// <param name="AGreen">Green component (0-255)</param>
    /// <param name="ABlue">Blue component (0-255)</param>
    /// <remarks>
    /// This color setting affects all subsequent text output until changed or reset.
    /// No effect if console output is not available.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.SetForegroundColor(255, 128, 0); // Orange text
    /// TpxConsole.PrintLn('This text is orange');
    /// TpxConsole.ResetTextFormat(); // Back to default
    /// </code>
    /// </example>
    class procedure SetForegroundColor(const ARed, AGreen, ABlue: Byte); overload; static;

    /// <summary>
    /// Immediately sets the console foreground (text) color using a TpxColor record.
    /// </summary>
    /// <param name="AColor">TpxColor record with RGBA components (0.0-1.0 range)</param>
    /// <remarks>
    /// Converts floating-point color values to RGB bytes internally. More convenient
    /// when working with TpxColor records from the graphics system.
    /// </remarks>
    class procedure SetForegroundColor(const AColor: TpxColor); overload; static;

    /// <summary>
    /// Immediately sets the console background color using RGB values.
    /// </summary>
    /// <param name="ARed">Red component (0-255)</param>
    /// <param name="AGreen">Green component (0-255)</param>
    /// <param name="ABlue">Blue component (0-255)</param>
    /// <remarks>
    /// This background color affects all subsequent text output until changed or reset.
    /// No effect if console output is not available.
    /// </remarks>
    class procedure SetBackgroundColor(const ARed, AGreen, ABlue: Byte); overload; static;

    /// <summary>
    /// Immediately sets the console background color using a TpxColor record.
    /// </summary>
    /// <param name="AColor">TpxColor record with RGBA components (0.0-1.0 range)</param>
    /// <remarks>
    /// Converts floating-point color values to RGB bytes internally.
    /// The alpha component is ignored for console background coloring.
    /// </remarks>
    class procedure SetBackgroundColor(const AColor: TpxColor); overload; static;

    /// <summary>
    /// Enables bold text formatting for subsequent console output.
    /// </summary>
    /// <remarks>
    /// Makes text appear bold/bright until formatting is reset. Some terminals
    /// may display this as brighter colors instead of actual bold text.
    /// </remarks>
    /// <seealso cref="ResetTextFormat"/>
    class procedure SetBoldText(); static;

    /// <summary>
    /// Resets all text formatting attributes to default values.
    /// </summary>
    /// <remarks>
    /// Clears all text formatting including colors, bold, underline, and other attributes.
    /// Returns the console to normal text display mode.
    /// </remarks>
    class procedure ResetTextFormat(); static;

    /// <summary>
    /// Outputs text to the console with optional formatting reset.
    /// </summary>
    /// <param name="AMsg">Text string to output</param>
    /// <param name="AResetFormat">Whether to reset formatting after output (default: True)</param>
    /// <remarks>
    /// Outputs text without adding a line break. If AResetFormat is True, all text
    /// formatting is reset after the text is printed. Uses Unicode console output for
    /// proper character display.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.Print(pxCSIFGRed + 'Red text', False); // Keep red formatting
    /// TpxConsole.Print(' more red text', True);         // Reset after this
    /// </code>
    /// </example>
    class procedure Print(const AMsg: string; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Outputs text to the console followed by a line break, with optional formatting reset.
    /// </summary>
    /// <param name="AMsg">Text string to output</param>
    /// <param name="AResetFormat">Whether to reset formatting after output (default: True)</param>
    /// <remarks>
    /// Similar to Print but automatically adds a line break after the text.
    /// Most commonly used method for console text output.
    /// </remarks>
    class procedure PrintLn(const AMsg: string; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Outputs formatted text to the console using Format-style parameters.
    /// </summary>
    /// <param name="AMsg">Format string with placeholders</param>
    /// <param name="AArgs">Array of values to substitute into format string</param>
    /// <param name="AResetFormat">Whether to reset formatting after output (default: True)</param>
    /// <remarks>
    /// Combines Format() functionality with console output. Supports all standard
    /// Delphi format specifiers (%d, %s, %f, etc.).
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.Print('Player: %s, Score: %d', ['Alice', 1500]);
    /// </code>
    /// </example>
    class procedure Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Outputs formatted text to the console with line break using Format-style parameters.
    /// </summary>
    /// <param name="AMsg">Format string with placeholders</param>
    /// <param name="AArgs">Array of values to substitute into format string</param>
    /// <param name="AResetFormat">Whether to reset formatting after output (default: True)</param>
    /// <remarks>
    /// Combines Format() functionality with console output and automatic line break.
    /// Most versatile method for formatted console output.
    /// </remarks>
    class procedure PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Outputs just formatting codes or empty content with optional reset.
    /// </summary>
    /// <param name="AResetFormat">Whether to reset formatting (default: True)</param>
    /// <remarks>
    /// Useful for applying or resetting formatting without outputting visible text.
    /// </remarks>
    class procedure Print(const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Outputs a line break with optional formatting reset.
    /// </summary>
    /// <param name="AResetFormat">Whether to reset formatting (default: True)</param>
    /// <remarks>
    /// Outputs just a line break, optionally resetting text formatting.
    /// Equivalent to Print('') with a line break.
    /// </remarks>
    class procedure PrintLn(const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    /// Retrieves text content from the system clipboard.
    /// </summary>
    /// <returns>String containing clipboard text, or empty string if clipboard is empty or inaccessible</returns>
    /// <remarks>
    /// Accesses the Windows clipboard to retrieve text content. Returns empty string
    /// if the clipboard contains non-text data or if access fails.
    /// </remarks>
    /// <seealso cref="SetClipboardText"/>
    class function  GetClipboardText(): string; static;

    /// <summary>
    /// Sets text content to the system clipboard.
    /// </summary>
    /// <param name="AText">Text string to place in clipboard</param>
    /// <remarks>
    /// Places the specified text into the Windows clipboard, making it available
    /// for pasting into other applications. Replaces any existing clipboard content.
    /// </remarks>
    class procedure SetClipboardText(const AText: string); static;

    /// <summary>
    /// Gets the current cursor position in the console window.
    /// </summary>
    /// <param name="X">Pointer to receive X coordinate (column), or nil to ignore</param>
    /// <param name="Y">Pointer to receive Y coordinate (row), or nil to ignore</param>
    /// <remarks>
    /// Retrieves the current cursor position as 0-based coordinates. Pass nil for
    /// either parameter if you only need one coordinate.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LX, LY: Integer;
    /// TpxConsole.GetCursorPos(@LX, @LY);
    /// WriteLn('Cursor at: ', LX, ', ', LY);
    /// </code>
    /// </example>
    class procedure GetCursorPos(X, Y: PInteger); static;

    /// <summary>
    /// Sets the cursor position in the console window.
    /// </summary>
    /// <param name="X">Column position (0-based)</param>
    /// <param name="Y">Row position (0-based)</param>
    /// <remarks>
    /// Moves the cursor to the specified position. Coordinates are 0-based, meaning
    /// (0,0) is the top-left corner. Invalid coordinates are automatically clamped.
    /// </remarks>
    class procedure SetCursorPos(const X, Y: Integer); static;

    /// <summary>
    /// Sets the visibility of the console cursor.
    /// </summary>
    /// <param name="AVisible">True to show cursor, False to hide it</param>
    /// <remarks>
    /// Controls whether the cursor is visible in the console window. Hidden cursors
    /// can reduce flicker during rapid text updates.
    /// </remarks>
    class procedure SetCursorVisible(const AVisible: Boolean); static;

    /// <summary>
    /// Hides the console cursor from view.
    /// </summary>
    /// <remarks>
    /// Convenience method equivalent to SetCursorVisible(False). Useful during
    /// text output operations to prevent cursor flicker.
    /// </remarks>
    /// <seealso cref="ShowCursor"/>
    class procedure HideCursor(); static;

    /// <summary>
    /// Shows the console cursor.
    /// </summary>
    /// <remarks>
    /// Convenience method equivalent to SetCursorVisible(True). Restores normal
    /// cursor visibility for user input operations.
    /// </remarks>
    /// <seealso cref="HideCursor"/>
    class procedure ShowCursor(); static;

    /// <summary>
    /// Saves the current cursor position for later restoration.
    /// </summary>
    /// <remarks>
    /// Saves the cursor position in the terminal's memory. Use RestoreCursorPos()
    /// to return to this saved position. Only one position can be saved at a time.
    /// </remarks>
    /// <seealso cref="RestoreCursorPos"/>
    class procedure SaveCursorPos(); static;

    /// <summary>
    /// Restores the cursor to the previously saved position.
    /// </summary>
    /// <remarks>
    /// Returns the cursor to the position saved by SaveCursorPos(). Has no effect
    /// if no position was previously saved.
    /// </remarks>
    /// <seealso cref="SaveCursorPos"/>
    class procedure RestoreCursorPos(); static;

    /// <summary>
    /// Moves the cursor up by the specified number of lines.
    /// </summary>
    /// <param name="ALines">Number of lines to move up</param>
    /// <remarks>
    /// Moves the cursor upward without changing the column position. If the cursor
    /// is already at the top of the console, it remains at the top.
    /// </remarks>
    class procedure MoveCursorUp(const ALines: Integer); static;

    /// <summary>
    /// Moves the cursor down by the specified number of lines.
    /// </summary>
    /// <param name="ALines">Number of lines to move down</param>
    /// <remarks>
    /// Moves the cursor downward without changing the column position. If the cursor
    /// reaches the bottom of the console, behavior depends on the terminal settings.
    /// </remarks>
    class procedure MoveCursorDown(const ALines: Integer); static;

    /// <summary>
    /// Moves the cursor forward (right) by the specified number of columns.
    /// </summary>
    /// <param name="ACols">Number of columns to move right</param>
    /// <remarks>
    /// Moves the cursor rightward without changing the row position. If the cursor
    /// reaches the right edge, behavior depends on the terminal settings.
    /// </remarks>
    class procedure MoveCursorForward(const ACols: Integer); static;

    /// <summary>
    /// Moves the cursor backward (left) by the specified number of columns.
    /// </summary>
    /// <param name="ACols">Number of columns to move left</param>
    /// <remarks>
    /// Moves the cursor leftward without changing the row position. If the cursor
    /// is already at the left edge, it remains there.
    /// </remarks>
    class procedure MoveCursorBack(const ACols: Integer); static;

    /// <summary>
    /// Clears the entire console screen and moves cursor to home position.
    /// </summary>
    /// <remarks>
    /// Erases all text from the console window and positions the cursor at the
    /// top-left corner (0,0). Also clears the scrollback buffer on some terminals.
    /// </remarks>
    class procedure ClearScreen(); static;

    /// <summary>
    /// Clears the current line and moves cursor to the beginning of the line.
    /// </summary>
    /// <remarks>
    /// Erases all text on the current line and positions the cursor at the start
    /// of the line. Other lines are not affected.
    /// </remarks>
    class procedure ClearLine(); static;

    /// <summary>
    /// Clears text from the cursor position to the end of the current line.
    /// </summary>
    /// <remarks>
    /// Erases text from the cursor to the end of the line without moving the cursor.
    /// Text before the cursor position remains unchanged.
    /// </remarks>
    class procedure ClearToEndOfLine(); static;

    /// <summary>
    /// Clears the current line from cursor position and applies the specified color.
    /// </summary>
    /// <param name="AColor">ANSI color sequence string to apply</param>
    /// <remarks>
    /// Combines line clearing with color setting. Useful for creating colored
    /// background areas or preparing colored text areas.
    /// </remarks>
    class procedure ClearLineFromCursor(const AColor: string); static;

    /// <summary>
    /// Gets the current size of the console window in character columns and rows.
    /// </summary>
    /// <param name="AWidth">Pointer to receive width in columns, or nil to ignore</param>
    /// <param name="AHeight">Pointer to receive height in rows, or nil to ignore</param>
    /// <remarks>
    /// Returns the console buffer size, which may be different from the visible
    /// window size if scrollbars are present. Pass nil for parameters you don't need.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LWidth, LHeight: Integer;
    /// TpxConsole.GetSize(@LWidth, @LHeight);
    /// WriteLn('Console: ', LWidth, 'x', LHeight);
    /// </code>
    /// </example>
    class procedure GetSize(AWidth: PInteger; AHeight: PInteger); static;

    /// <summary>
    /// Gets the current console window title.
    /// </summary>
    /// <returns>String containing the current window title</returns>
    /// <remarks>
    /// Retrieves the title text displayed in the console window's title bar.
    /// Returns empty string if the title cannot be retrieved.
    /// </remarks>
    /// <seealso cref="SetTitle"/>
    class function  GetTitle(): string; static;

    /// <summary>
    /// Sets the console window title.
    /// </summary>
    /// <param name="ATitle">New title text for the console window</param>
    /// <remarks>
    /// Changes the text displayed in the console window's title bar. Useful for
    /// showing application status or progress information.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.SetTitle('My Game - Level 3');
    /// </code>
    /// </example>
    class procedure SetTitle(const ATitle: string); static;

    /// <summary>
    /// Checks if any key is currently pressed or available in the input buffer.
    /// </summary>
    /// <returns>True if a key press is available, False otherwise</returns>
    /// <remarks>
    /// Non-blocking check for keyboard input. Returns True if any key has been
    /// pressed and is waiting to be processed. Does not consume the key press.
    /// </remarks>
    class function  AnyKeyPressed(): Boolean; static;

    /// <summary>
    /// Clears all keyboard state tracking information.
    /// </summary>
    /// <remarks>
    /// Resets internal key state arrays and clears the keyboard input buffer.
    /// Useful for preventing key repeat issues when transitioning between input modes.
    /// </remarks>
    class procedure ClearKeyStates(); static;

    /// <summary>
    /// Clears the keyboard input buffer of pending key presses.
    /// </summary>
    /// <remarks>
    /// Removes all pending keyboard events from both console and Windows message queues.
    /// Prevents old key presses from being processed after mode changes.
    /// </remarks>
    class procedure ClearKeyboardBuffer(); static;

    /// <summary>
    /// Waits for any key to be pressed, blocking program execution.
    /// </summary>
    /// <remarks>
    /// Blocks execution until a key is pressed. The key press is consumed and not
    /// available for further processing. Commonly used for "press any key to continue" prompts.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.PrintLn('Press any key to continue...');
    /// TpxConsole.WaitForAnyConsoleKey();
    /// </code>
    /// </example>
    class procedure WaitForAnyConsoleKey(); static;

    /// <summary>
    /// Checks if a specific key is currently being held down.
    /// </summary>
    /// <param name="AKey">Virtual key code to check</param>
    /// <returns>True if the key is currently pressed, False otherwise</returns>
    /// <remarks>
    /// Real-time key state check using Windows GetAsyncKeyState. Returns the current
    /// physical state of the key, regardless of console focus.
    /// </remarks>
    class function  IsKeyPressed(AKey: Byte): Boolean;

    /// <summary>
    /// Checks if a key was released since the last check (state change detection).
    /// </summary>
    /// <param name="AKey">Virtual key code to check</param>
    /// <returns>True if the key was just released, False otherwise</returns>
    /// <remarks>
    /// Detects key release events by tracking state changes. Only returns True once
    /// per release event. Useful for detecting key up events.
    /// </remarks>
    class function  WasKeyReleased(AKey: Byte): Boolean;

    /// <summary>
    /// Checks if a key was pressed since the last check (state change detection).
    /// </summary>
    /// <param name="AKey">Virtual key code to check</param>
    /// <returns>True if the key was just pressed, False otherwise</returns>
    /// <remarks>
    /// Detects key press events by tracking state changes. Only returns True once
    /// per press event, preventing key repeat issues.
    /// </remarks>
    class function  WasKeyPressed(AKey: Byte): Boolean;

    /// <summary>
    /// Reads a single character from console input, blocking until available.
    /// </summary>
    /// <returns>WideChar representing the key that was pressed</returns>
    /// <remarks>
    /// Waits for and returns the next character typed. Supports Unicode characters.
    /// The character is consumed and removed from the input buffer.
    /// </remarks>
    class function  ReadKey(): WideChar;

    /// <summary>
    /// Reads a line of input with character filtering and length limiting.
    /// </summary>
    /// <param name="AAllowedChars">Set of characters that are allowed in the input</param>
    /// <param name="AMaxLength">Maximum number of characters to accept</param>
    /// <param name="AColor">ANSI color sequence to apply to input text</param>
    /// <returns>String containing the user's input (without Enter key)</returns>
    /// <remarks>
    /// Provides filtered input with visual feedback. Only characters in AAllowedChars
    /// are accepted. Supports backspace for editing. Input is echoed in the specified color.
    /// Returns when Enter is pressed.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LName := TpxConsole.ReadLnX(['a'..'z', 'A'..'Z', ' '], 20, pxCSIFGGreen);
    /// </code>
    /// </example>
    class function  ReadLnX(const AAllowedChars: TpxCharSet; AMaxLength: Integer; const AColor: string): string;

    /// <summary>
    /// Wraps text to fit within specified column width with intelligent line breaking.
    /// </summary>
    /// <param name="ALine">Text string to wrap</param>
    /// <param name="AMaxCol">Maximum column width for wrapped lines</param>
    /// <param name="ABreakChars">Set of characters where line breaks are preferred (default: space, hyphen, comma, colon, tab)</param>
    /// <returns>String with embedded line breaks at appropriate positions</returns>
    /// <remarks>
    /// Intelligently wraps text by preferring to break at word boundaries defined by
    /// ABreakChars. If no suitable break point is found, breaks at the column limit.
    /// Preserves existing line breaks in the input text.
    /// </remarks>
    /// <example>
    /// <code>
    /// var LWrapped := TpxConsole.WrapTextEx('This is a long line of text', 20);
    /// TpxConsole.PrintLn(LWrapped);
    /// </code>
    /// </example>
    class function  WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TpxCharSet = [' ', '-', ',', ':', #9]): string; static;

    /// <summary>
    /// Displays text with typewriter effect, showing characters one by one with configurable timing.
    /// </summary>
    /// <param name="AText">Text to display with teletype effect</param>
    /// <param name="AColor">ANSI color sequence for the text (default: white)</param>
    /// <param name="AMargin">Right margin for automatic text wrapping (default: 10)</param>
    /// <param name="AMinDelay">Minimum delay between characters in milliseconds (default: 0)</param>
    /// <param name="AMaxDelay">Maximum delay between characters in milliseconds (default: 3)</param>
    /// <param name="ABreakKey">Virtual key code that cancels the effect (default: Escape)</param>
    /// <remarks>
    /// Creates a classic typewriter/teletype effect by displaying characters individually
    /// with random delays. Automatically wraps text at the specified margin. Can be
    /// interrupted by pressing the break key. Processes Windows messages during display.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.Teletype('Welcome to the game!', pxCSIFGGreen, 10, 50, 150, VK_ESC);
    /// </code>
    /// </example>
    class procedure Teletype(const AText: string; const AColor: string = pxCSIFGWhite; const AMargin: Integer = 10; const AMinDelay: Integer = 0; const AMaxDelay: Integer = 3; const ABreakKey: Byte = VK_ESC); static;

    /// <summary>
    /// Precise timing delay using high-resolution performance counters.
    /// </summary>
    /// <param name="AMilliseconds">Number of milliseconds to wait (supports fractional values)</param>
    /// <remarks>
    /// Provides precise timing delays using QueryPerformanceCounter for sub-millisecond
    /// accuracy. More accurate than Sleep() for short delays. Blocks execution completely.
    /// </remarks>
    class procedure Wait(const AMilliseconds: Double); static;

    /// <summary>
    /// Displays a "press any key to continue" prompt with intelligent behavior based on execution context.
    /// </summary>
    /// <param name="AForcePause">If True, always shows pause prompt regardless of context (default: False)</param>
    /// <param name="AColor">ANSI color sequence for the prompt text (default: empty)</param>
    /// <param name="AMsg">Custom message to display (default: "Press any key to continue...")</param>
    /// <remarks>
    /// Intelligently determines whether to show a pause prompt based on how the application
    /// was started (console vs GUI, IDE vs standalone). Typically pauses when run from IDE
    /// or when AForcePause is True. Clears keyboard buffer before waiting for input.
    /// </remarks>
    /// <example>
    /// <code>
    /// TpxConsole.Pause(False, pxCSIFGYellow, 'Press any key to exit...');
    /// </code>
    /// </example>
    class procedure Pause(const AForcePause: Boolean=False; AColor: string=''; const AMsg: string=''); static;
  end;

implementation

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  PIXELS.Utils,
  PIXELS.Math;

{ TpxConsole }
class constructor TpxConsole.Create();
begin
  inherited;

  FTeletypeDelay := 0;
  QueryPerformanceFrequency(FPerformanceFrequency);
  ClearKeyStates();
end;

class destructor TpxConsole.Destroy();
begin
  inherited;
end;

class function  TpxConsole.HasConsoleOutput(): Boolean;
var
  LStdHandle: THandle;
begin
  LStdHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  Result := (LStdHandle <> INVALID_HANDLE_VALUE) and
            (GetFileType(LStdHandle) = FILE_TYPE_CHAR);
end;

class function  TpxConsole.CreateForegroundColor(const ARed, AGreen, ABlue: Byte): string;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;
  Result := Format(pxCSIFGRGB, [ARed, AGreen, ABlue])
end;

class function  TpxConsole.CreateForegroundColor(const AColor: TpxColor): string;
var
  r,g,b: Byte;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);

  Result := Format(pxCSIFGRGB, [r, g, b]);
end;

class function  TpxConsole.CreateBackgroundColor(const ARed, AGreen, ABlue: Byte): string;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  Result := '';
  if not HasConsoleOutput() then Exit;

  Result := Format(pxCSIBGRGB, [ARed, AGreen, ABlue]);
end;

class function  TpxConsole.CreateBackgroundColor(const AColor: TpxColor): string;
var
  r,g,b: Byte;
begin
  Result := '';
  if not HasConsoleOutput() then Exit;

  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);

  Result := Format(pxCSIBGRGB, [r, g, b]);
end;

class procedure TpxConsole.SetForegroundColor(const ARed, AGreen, ABlue: Byte);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSIFGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TpxConsole.SetForegroundColor(const AColor: TpxColor);
var
  r, g, b: Byte;
begin
  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);
  SetForegroundColor(r, g, b);
end;

class procedure TpxConsole.SetBackgroundColor(const ARed, AGreen, ABlue: Byte);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSIBGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TpxConsole.SetBackgroundColor(const AColor: TpxColor);
var
  r, g, b: Byte;
begin
  r := Round(AColor.r * $FF);
  g := Round(AColor.g * $FF);
  b := Round(AColor.b * $FF);
  SetBackgroundColor(r, g, b);
end;

class procedure TpxConsole.Print(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs)+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs) + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.Print(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TpxConsole.PrintLn(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasConsoleOutput() then Exit;
  if AResetFormat then
    LREsetFormat := pxCSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS :=  sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class function  TpxConsole.GetClipboardText(): string;
var
  Handle: THandle;
  Ptr: PChar;
begin
  Result := '';
  if not OpenClipboard(0) then Exit;
  try
    Handle := GetClipboardData(CF_TEXT);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Result := Ptr;
        GlobalUnlock(Handle);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

class procedure TpxConsole.SetClipboardText(const AText: string);
var
  Handle: THandle;
  Ptr: PChar;
  Size: Integer;
begin
  if not OpenClipboard(0) then Exit;
  try
    EmptyClipboard;
    Size := (Length(AText) + 1) * SizeOf(Char);
    Handle := GlobalAlloc(GMEM_MOVEABLE, Size);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Move(PChar(AText)^, Ptr^, Size);
        GlobalUnlock(Handle);
        SetClipboardData(CF_TEXT, Handle);
      end else
        GlobalFree(Handle);
    end;
  finally
    CloseClipboard;
  end;
end;

class procedure TpxConsole.GetCursorPos(X, Y: PInteger);
var
  hConsole: THandle;
  BufferInfo: TConsoleScreenBufferInfo;
begin
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  if hConsole = INVALID_HANDLE_VALUE then
    Exit;

  if not GetConsoleScreenBufferInfo(hConsole, BufferInfo) then
    Exit;

  if Assigned(X) then
    X^ := BufferInfo.dwCursorPosition.X;
  if Assigned(Y) then
    Y^ := BufferInfo.dwCursorPosition.Y;
end;

class procedure TpxConsole.SetCursorPos(const X, Y: Integer);
begin
  if not HasConsoleOutput() then Exit;
  // CSICursorPos expects Y parameter first, then X
  Write(Format(pxCSICursorPos, [Y + 1, X + 1])); // +1 because ANSI is 1-based
end;

class procedure TpxConsole.SetCursorVisible(const AVisible: Boolean);
var
  ConsoleInfo: TConsoleCursorInfo;
  ConsoleHandle: THandle;
begin
  ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  ConsoleInfo.dwSize := 25; // You can adjust cursor size if needed
  ConsoleInfo.bVisible := AVisible;
  SetConsoleCursorInfo(ConsoleHandle, ConsoleInfo);
end;

class procedure TpxConsole.HideCursor();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIHideCursor);
end;

class procedure TpxConsole.ShowCursor();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIShowCursor);
end;

class procedure TpxConsole.SaveCursorPos();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSISaveCursorPos);
end;

class procedure TpxConsole.RestoreCursorPos();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIRestoreCursorPos);
end;

class procedure TpxConsole.MoveCursorUp(const ALines: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorUp, [ALines]));
end;

class procedure TpxConsole.MoveCursorDown(const ALines: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorDown, [ALines]));
end;

class procedure TpxConsole.MoveCursorForward(const ACols: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorForward, [ACols]));
end;

class procedure TpxConsole.MoveCursorBack(const ACols: Integer);
begin
  if not HasConsoleOutput() then Exit;
  Write(Format(pxCSICursorBack, [ACols]));
end;

class procedure TpxConsole.ClearScreen();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIClearScreen);
  Write(pxESC + '[3J');
  Write(pxCSICursorHomePos);
end;

class procedure TpxConsole.ClearLine();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCR);
  Write(pxCSIClearLine);
end;

class procedure TpxConsole.ClearToEndOfLine();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIClearToEndOfLine);
end;

class procedure TpxConsole.ClearLineFromCursor(const AColor: string);
var
  LConsoleOutput: THandle;
  LConsoleInfo: TConsoleScreenBufferInfo;
  LNumCharsWritten: DWORD;
  LCoord: TCoord;
begin
  LConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(LConsoleOutput, LConsoleInfo) then
  begin
    LCoord.X := 0;
    LCoord.Y := LConsoleInfo.dwCursorPosition.Y;

    Print(AColor);
    FillConsoleOutputCharacter(LConsoleOutput, ' ', LConsoleInfo.dwSize.X
      - LConsoleInfo.dwCursorPosition.X, LCoord, LNumCharsWritten);
    SetConsoleCursorPosition(LConsoleOutput, LCoord);
  end;
end;

class procedure TpxConsole.SetBoldText();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIBold);
end;

class procedure TpxConsole.ResetTextFormat();
begin
  if not HasConsoleOutput() then Exit;
  Write(pxCSIResetFormat);
end;

class procedure TpxConsole.GetSize(AWidth: PInteger; AHeight: PInteger);
var
  LConsoleInfo: TConsoleScreenBufferInfo;
begin
  if not HasConsoleOutput() then Exit;

  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), LConsoleInfo);
  if Assigned(AWidth) then
    AWidth^ := LConsoleInfo.dwSize.X;

  if Assigned(AHeight) then
  AHeight^ := LConsoleInfo.dwSize.Y;
end;

class function  TpxConsole.GetTitle(): string;
const
  MAX_TITLE_LENGTH = 1024;
var
  LTitle: array[0..MAX_TITLE_LENGTH] of WideChar;
  LTitleLength: DWORD;
begin
  // Get the console title and store it in LTitle
  LTitleLength := GetConsoleTitleW(LTitle, MAX_TITLE_LENGTH);

  // If the title is retrieved, assign it to the result
  if LTitleLength > 0 then
    Result := string(LTitle)
  else
    Result := '';
end;

class procedure TpxConsole.SetTitle(const ATitle: string);
begin
  WinApi.Windows.SetConsoleTitle(PChar(ATitle));
end;

class function  TpxConsole.AnyKeyPressed(): Boolean;
var
  LNumberOfEvents     : DWORD;
  LBuffer             : TInputRecord;
  LNumberOfEventsRead : DWORD;
  LStdHandle           : THandle;
begin
  Result:=false;
  //get the console handle
  LStdHandle := GetStdHandle(STD_INPUT_HANDLE);
  LNumberOfEvents:=0;
  //get the number of events
  GetNumberOfConsoleInputEvents(LStdHandle,LNumberOfEvents);
  if LNumberOfEvents<> 0 then
  begin
    //retrieve the event
    PeekConsoleInput(LStdHandle,LBuffer,1,LNumberOfEventsRead);
    if LNumberOfEventsRead <> 0 then
    begin
      if LBuffer.EventType = KEY_EVENT then //is a Keyboard event?
      begin
        if LBuffer.Event.KeyEvent.bKeyDown then //the key was pressed?
          Result:=true
        else
          FlushConsoleInputBuffer(LStdHandle); //flush the buffer
      end
      else
      FlushConsoleInputBuffer(LStdHandle);//flush the buffer
    end;
  end;
end;

class procedure TpxConsole.ClearKeyStates();
begin
  FillChar(FKeyState, SizeOf(FKeyState), 0);
  ClearKeyboardBuffer();
end;

class procedure TpxConsole.ClearKeyboardBuffer();
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
  LMsg: TMsg;
begin
  while PeekConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead) and (LEventsRead > 0) do
  begin
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  end;

  while PeekMessage(LMsg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE) do
  begin
    // No operation; just removing messages from the queue
  end;
end;

class procedure TpxConsole.WaitForAnyConsoleKey();
var
  LInputRec: TInputRecord;
  LNumRead: Cardinal;
  LOldMode: DWORD;
  LStdIn: THandle;
begin
  LStdIn := GetStdHandle(STD_INPUT_HANDLE);
  GetConsoleMode(LStdIn, LOldMode);
  SetConsoleMode(LStdIn, 0);
  repeat
    ReadConsoleInput(LStdIn, LInputRec, 1, LNumRead);
  until (LInputRec.EventType and KEY_EVENT <> 0) and
    LInputRec.Event.KeyEvent.bKeyDown;
  SetConsoleMode(LStdIn, LOldMode);
end;

class function  TpxConsole.IsKeyPressed(AKey: Byte): Boolean;
begin
  Result := (GetAsyncKeyState(AKey) and $8000) <> 0;
end;

class function  TpxConsole.WasKeyReleased(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := True;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := False;
  end;
end;

class function  TpxConsole.WasKeyPressed(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := False;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := True;
  end;
end;

class function  TpxConsole.ReadKey(): WideChar;
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
begin
  repeat
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  until (LInputRecord.EventType = KEY_EVENT) and LInputRecord.Event.KeyEvent.bKeyDown;
  Result := LInputRecord.Event.KeyEvent.UnicodeChar;
end;

class function  TpxConsole.ReadLnX(const AAllowedChars: TpxCharSet; AMaxLength: Integer; const AColor: string): string;
var
  LInputChar: Char;
begin
  Result := '';

  repeat
    LInputChar := ReadKey;

    if CharInSet(LInputChar, AAllowedChars) then
    begin
      if Length(Result) < AMaxLength then
      begin
        if not CharInSet(LInputChar, [#10, #0, #13, #8])  then
        begin
          //Print(LInputChar, AColor);
          Print('%s%s', [AColor, LInputChar]);
          Result := Result + LInputChar;
        end;
      end;
    end;
    if LInputChar = #8 then
    begin
      if Length(Result) > 0 then
      begin
        //Print(#8 + ' ' + #8);
        Print(#8 + ' ' + #8, []);
        Delete(Result, Length(Result), 1);
      end;
    end;
  until (LInputChar = #13);

  PrintLn();
end;

class function  TpxConsole.WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TpxCharSet): string;
var
  LText: string;
  LPos: integer;
  LChar: Char;
  LLen: Integer;
  I: Integer;
begin
  LText := ALine.Trim;

  LPos := 0;
  LLen := 0;

  while LPos < LText.Length do
  begin
    Inc(LPos);

    LChar := LText[LPos];

    if LChar = #10 then
    begin
      LLen := 0;
      continue;
    end;

    Inc(LLen);

    if LLen >= AMaxCol then
    begin
      for I := LPos downto 1 do
      begin
        LChar := LText[I];

        if CharInSet(LChar, ABreakChars) then
        begin
          LText.Insert(I, #10);
          Break;
        end;
      end;

      LLen := 0;
    end;
  end;

  Result := LText;
end;

class procedure TpxConsole.Teletype(const AText: string; const AColor: string; const AMargin: Integer; const AMinDelay: Integer; const AMaxDelay: Integer; const ABreakKey: Byte);
var
  LText: string;
  LMaxCol: Integer;
  LChar: Char;
  LWidth: Integer;
begin
  GetSize(@LWidth, nil);
  LMaxCol := LWidth - AMargin;

  LText := WrapTextEx(AText, LMaxCol);

  for LChar in LText do
  begin
    TpxUtils.ProcessMessages();
    Print('%s%s', [AColor, LChar]);
    if not TpxMath.RandomBool() then
      FTeletypeDelay := TpxMath.RandomRangeInt(AMinDelay, AMaxDelay);
    Wait(FTeletypeDelay);
    if IsKeyPressed(ABreakKey) then
    begin
      ClearKeyboardBuffer;
      Break;
    end;
  end;
end;

class procedure TpxConsole.Wait(const AMilliseconds: Double);
var
  LStartCount, LCurrentCount: Int64;
  LElapsedTime: Double;

begin
  // Get the starting value of the performance counter
  QueryPerformanceCounter(LStartCount);

  // Convert milliseconds to seconds for precision timing
  repeat
    QueryPerformanceCounter(LCurrentCount);
    LElapsedTime := (LCurrentCount - LStartCount) / FPerformanceFrequency * 1000.0; // Convert to milliseconds
  until LElapsedTime >= AMilliseconds;
end;

class function  TpxConsole.StartedFromConsole(): Boolean;
var
  LStartupInfo: TStartupInfo;
begin
  LStartupInfo.cb := SizeOf(TStartupInfo);
  GetStartupInfo(LStartupInfo);
  Result := ((LStartupInfo.dwFlags and STARTF_USESHOWWINDOW) = 0);
end;

class function TpxConsole.StartedFromDelphiIDE(): Boolean;
begin
  // Check if the IDE environment variable is present
  Result := (GetEnvironmentVariable('BDS') <> '');
end;

class procedure TpxConsole.Pause(const AForcePause: Boolean; AColor: string; const AMsg: string);
var
  LDoPause: Boolean;
begin
  if not HasConsoleOutput then Exit;

  ClearKeyboardBuffer();

  if not AForcePause then
  begin
    LDoPause := True;
    if StartedFromConsole() then LDoPause := False;
    if StartedFromDelphiIDE() then LDoPause := True;
    if not LDoPause then Exit;
  end;

  //ShowCursor();

  PrintLn();
  if AMsg = '' then
    Print('%sPress any key to continue... ', [aColor])
  else
    Print('%s%s', [aColor, AMsg]);

  WaitForAnyConsoleKey();
  PrintLn();
end;

function EnableVirtualTerminalProcessing(): Boolean;
var
  HOut: THandle;
  LMode: DWORD;
begin
  Result := False;

  HOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if HOut = INVALID_HANDLE_VALUE then Exit;
  if not GetConsoleMode(HOut, LMode) then Exit;

  LMode := LMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
  if not SetConsoleMode(HOut, LMode) then Exit;

  Result := True;
end;

initialization
  if not EnableVirtualTerminalProcessing() then
    TpxUtils.FatalError('ERROR: Virtual Terminal Processing not supported. Console features unavailable.', []);

  SetConsoleCP(CP_UTF8);
  SetConsoleOutputCP(CP_UTF8);

finalization

end.
