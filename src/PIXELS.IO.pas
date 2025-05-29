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

unit PIXELS.IO;

{$I PIXELS.Defines.inc}

interface

uses
  PIXELS.Deps,
  PIXELS.Base;

const
  /// <summary>
  /// Default password used for ZIP file encryption/decryption operations in PIXELS
  /// </summary>
  /// <remarks>
  /// This is a complex default password that provides reasonable security for game assets.
  /// While not intended for high-security applications, it prevents casual access to game resources.
  /// You can override this password by providing your own when calling ZIP-related functions.
  /// </remarks>
  /// <seealso cref="TpxFile.BuildZip"/>
  /// <seealso cref="TpxFile.OpenZip"/>

  CpxDefaultZipPassword = 'ep8uNv%DyjKc#$@jQ.<g%zw[k6T,7:4N2DWC>Y]+n;(r3yj@JcF?Ru=s5LbM`paPf!%AG!7TASJJ4#sSTt';

type
  /// <summary>
  /// Enumeration of file seeking modes for positioning the file pointer
  /// </summary>
  /// <remarks>
  /// These modes determine how the file position is calculated during seek operations.
  /// Works with both regular disk files and ZIP archive entries.
  /// </remarks>
  /// <seealso cref="TpxFile.Seek"/>
  TpxSeekMode = (
    /// <summary>
    /// Seek from the beginning of the file (absolute position)
    /// </summary>
    smStart   = ALLEGRO_SEEK_SET,
    /// <summary>
    /// Seek relative to the current file position
    /// </summary>
    smCurrent = ALLEGRO_SEEK_CUR,
    /// <summary>
    /// Seek from the end of the file (negative offsets move backward)
    /// </summary>
    smEnd     = ALLEGRO_SEEK_END
  );

  /// <summary>
  /// Opaque pointer type representing a file handle in the PIXELS file system
  /// </summary>
  /// <remarks>
  /// This type encapsulates the underlying Allegro file handle and should not be manipulated directly.
  /// Always use TpxFile class methods to work with file handles.
  /// File handles must be properly closed using TpxFile.Close to prevent resource leaks.
  /// </remarks>
  /// <seealso cref="TpxFile"/>
  PpxFile = type PALLEGRO_FILE;

  /// <summary>
  /// Static class providing comprehensive file I/O operations for disk files, memory buffers, and ZIP archives
  /// </summary>
  /// <remarks>
  /// TpxFile is the primary interface for all file operations in PIXELS. It supports:
  /// - Standard disk file operations (read, write, seek)
  /// - Memory-based file operations for embedded resources
  /// - ZIP archive creation and extraction with password protection
  /// - Cross-platform file access with consistent behavior
  ///
  /// All file operations are performed through static methods, and file handles must be
  /// properly closed using the Close method to prevent resource leaks.
  ///
  /// The class automatically handles different file formats and provides transparent
  /// access to files whether they're on disk, in memory, or within ZIP archives.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Open a file from disk
  /// LFile := TpxFile.OpenDisk('data/texture.png', 'rb');
  /// if Assigned(LFile) then
  /// try
  ///   LSize := TpxFile.Size(LFile);
  ///   // Use the file...
  /// finally
  ///   TpxFile.Close(LFile);
  /// end;
  ///
  /// // Open a file from ZIP archive
  /// LFile := TpxFile.OpenZip('assets.zip', 'images/player.png');
  /// if Assigned(LFile) then
  /// try
  ///   // Load texture from ZIP file...
  /// finally
  ///   TpxFile.Close(LFile);
  /// end;
  /// </code>
  /// </example>
  TpxFile = class(TpxStaticObject)
  private class var
    FZipFI: ALLEGRO_FILE_INTERFACE;
  private
    class constructor Create();
    class destructor Destroy();
  public
    /// <summary>
    /// Opens a file from a memory buffer for reading or writing
    /// </summary>
    /// <param name="AMemory">Pointer to the memory buffer containing the file data</param>
    /// <param name="ASize">Size of the memory buffer in bytes</param>
    /// <param name="AMode">File access mode (e.g., 'rb' for read binary, 'wb' for write binary)</param>
    /// <returns>File handle if successful, nil if the operation failed</returns>
    /// <remarks>
    /// This method allows you to treat a memory buffer as if it were a file, enabling
    /// you to use standard file operations on embedded resources or dynamically generated data.
    /// The memory buffer must remain valid for the lifetime of the file handle.
    /// Common modes: 'rb' (read binary), 'wb' (write binary), 'r' (read text), 'w' (write text).
    /// </remarks>
    /// <example>
    /// <code>
    /// // Load data from a resource and open as file
    /// LResStream := TResourceStream.Create(HInstance, 'MYDATA', RT_RCDATA);
    /// try
    ///   LFile := TpxFile.OpenMemory(LResStream.Memory, LResStream.Size, 'rb');
    ///   // Use the file handle...
    /// finally
    ///   LResStream.Free;
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OpenDisk"/>
    /// <seealso cref="Close"/>
    class function OpenMemory(const AMemory: Pointer; const ASize: Int64; const AMode: string): PpxFile; static;

    /// <summary>
    /// Opens a file from the disk file system
    /// </summary>
    /// <param name="AFilename">Path to the file to open (relative or absolute)</param>
    /// <param name="AMode">File access mode (e.g., 'rb' for read binary, 'wb' for write binary)</param>
    /// <returns>File handle if successful, nil if the file could not be opened</returns>
    /// <remarks>
    /// This is the standard method for opening disk files. The filename can be relative to the
    /// application directory or an absolute path. The function supports all standard C-style
    /// file modes including text and binary modes.
    /// Common modes: 'rb' (read binary), 'wb' (write binary), 'r' (read text), 'w' (write text),
    /// 'a' (append), 'r+' (read/write), 'w+' (create read/write).
    /// </remarks>
    /// <example>
    /// <code>
    /// // Open file for reading
    /// LFile := TpxFile.OpenDisk('config.ini', 'r');
    /// if Assigned(LFile) then
    /// try
    ///   // Read configuration data...
    /// finally
    ///   TpxFile.Close(LFile);
    /// end;
    ///
    /// // Open file for writing
    /// LFile := TpxFile.OpenDisk('savegame.dat', 'wb');
    /// if Assigned(LFile) then
    /// try
    ///   // Write save data...
    /// finally
    ///   TpxFile.Close(LFile);
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OpenMemory"/>
    /// <seealso cref="OpenZip"/>
    class function OpenDisk(const AFilename, AMode: string): PpxFile; static;

    /// <summary>
    /// Creates a password-protected ZIP archive from a directory structure
    /// </summary>
    /// <param name="AZipFilename">Path where the ZIP file will be created</param>
    /// <param name="ADirectoryName">Directory containing files to add to the ZIP</param>
    /// <param name="APassword">Password for ZIP encryption (defaults to CpxDefaultZipPassword)</param>
    /// <returns>True if the ZIP file was created successfully, False otherwise</returns>
    /// <remarks>
    /// This method recursively adds all files from the specified directory to a new ZIP archive.
    /// All files are encrypted using the provided password. The directory structure is preserved
    /// within the ZIP file. This is commonly used to package game assets into a single encrypted file.
    /// The operation may take time for large directories and will call the OnZipFileBuildProgress
    /// callback if available in the current game instance.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Create a ZIP file from game assets
    /// if TpxFile.BuildZip('assets.zip', 'GameAssets\', 'MySecretPassword') then
    ///   ShowMessage('Assets packed successfully')
    /// else
    ///   ShowMessage('Failed to create ZIP file');
    /// </code>
    /// </example>
    /// <seealso cref="OpenZip"/>
    /// <seealso cref="CpxDefaultZipPassword"/>
    class function BuildZip(const AZipFilename, ADirectoryName: string; const APassword: string=CpxDefaultZipPassword): Boolean; static;

    /// <summary>
    /// Opens a file from within a password-protected ZIP archive
    /// </summary>
    /// <param name="AZipFilename">Path to the ZIP file</param>
    /// <param name="AFilename">Path of the file within the ZIP archive</param>
    /// <param name="APassword">Password for ZIP decryption (defaults to CpxDefaultZipPassword)</param>
    /// <returns>File handle if successful, nil if the file could not be opened</returns>
    /// <remarks>
    /// This method allows transparent access to files stored within ZIP archives. The file path
    /// within the ZIP should use forward slashes (/) as separators regardless of platform.
    /// The ZIP file must have been created with the same password for successful decryption.
    /// The returned file handle can be used with all standard file operations like Read, Seek, etc.
    /// This is commonly used for loading game assets from encrypted archive files.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Load a texture from ZIP archive
    /// LFile := TpxFile.OpenZip('assets.zip', 'textures/player.png', 'MyPassword');
    /// if Assigned(LFile) then
    /// try
    ///   LTexture := TpxTexture.Create;
    ///   LTexture.Load(LFile, '.png', pxHDTexture);
    /// finally
    ///   TpxFile.Close(LFile);
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="BuildZip"/>
    /// <seealso cref="CpxDefaultZipPassword"/>
    class function OpenZip(const AZipFilename, AFilename: string; const APassword: string=CpxDefaultZipPassword): PpxFile; static;

    /// <summary>
    /// Closes a file handle and releases associated resources
    /// </summary>
    /// <param name="AFile">File handle to close</param>
    /// <returns>True if the file was closed successfully, False otherwise</returns>
    /// <remarks>
    /// This method must be called for every file handle opened with OpenMemory, OpenDisk, or OpenZip
    /// to prevent resource leaks. After calling Close, the file handle becomes invalid and should
    /// not be used for further operations. It's safe to call Close on a nil file handle.
    /// Always use try/finally blocks to ensure files are properly closed even if exceptions occur.
    /// </remarks>
    /// <example>
    /// <code>
    /// LFile := TpxFile.OpenDisk('data.txt', 'r');
    /// if Assigned(LFile) then
    /// try
    ///   // Use the file...
    /// finally
    ///   TpxFile.Close(LFile);  // Always close in finally block
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="OpenMemory"/>
    /// <seealso cref="OpenDisk"/>
    /// <seealso cref="OpenZip"/>
    class function Close(const AFile: PpxFile): Boolean; static;

    /// <summary>
    /// Reads data from a file into a buffer
    /// </summary>
    /// <param name="AFile">File handle to read from</param>
    /// <param name="AData">Pointer to buffer where data will be stored</param>
    /// <param name="ASize">Number of bytes to read</param>
    /// <returns>Actual number of bytes read (may be less than requested if EOF reached)</returns>
    /// <remarks>
    /// This method reads binary data from the current file position into the provided buffer.
    /// The buffer must be large enough to hold the requested number of bytes. The file position
    /// is advanced by the number of bytes actually read. If fewer bytes are read than requested,
    /// it typically indicates the end of file has been reached.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Read file header
    /// SetLength(LBuffer, 1024);
    /// LBytesRead := TpxFile.Read(LFile, @LBuffer[0], 1024);
    /// if LBytesRead > 0 then
    ///   // Process the data...
    /// </code>
    /// </example>
    /// <seealso cref="Write"/>
    /// <seealso cref="Size"/>
    /// <seealso cref="Pos"/>
    class function Read(const AFile: PpxFile; AData: Pointer; const ASize: UInt32): UInt32; static;

    /// <summary>
    /// Writes data from a buffer to a file
    /// </summary>
    /// <param name="AFile">File handle to write to</param>
    /// <param name="AData">Pointer to buffer containing data to write</param>
    /// <param name="ASize">Number of bytes to write</param>
    /// <returns>Actual number of bytes written</returns>
    /// <remarks>
    /// This method writes binary data from the provided buffer to the file at the current position.
    /// The file position is advanced by the number of bytes written. The file must have been opened
    /// with a write mode ('w', 'wb', 'a', 'r+', etc.). For text files, consider the line ending
    /// conversions that may occur on different platforms.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Write game save data
    /// LData := 'SAVE_V1.0';
    /// LBytesWritten := TpxFile.Write(LFile, PChar(LData), Length(LData));
    /// if LBytesWritten = Length(LData) then
    ///   // Write successful...
    /// </code>
    /// </example>
    /// <seealso cref="Read"/>
    /// <seealso cref="Pos"/>
    class function Write(const AFile: PpxFile; const AData: Pointer; const ASize: UInt32): UInt32; static;

    /// <summary>
    /// Gets the current position of the file pointer
    /// </summary>
    /// <param name="AFile">File handle to query</param>
    /// <returns>Current file position in bytes from the beginning of the file</returns>
    /// <remarks>
    /// This method returns the current byte offset within the file where the next read or write
    /// operation will occur. The position starts at 0 for the beginning of the file.
    /// Use this with Seek to implement custom file navigation or to save and restore positions.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Save current position
    /// LSavedPos := TpxFile.Pos(LFile);
    ///
    /// // Read some data...
    /// TpxFile.Read(LFile, @LBuffer, SizeOf(LBuffer));
    ///
    /// // Restore position
    /// TpxFile.Seek(LFile, LSavedPos, smStart);
    /// </code>
    /// </example>
    /// <seealso cref="Seek"/>
    /// <seealso cref="Size"/>
    class function Pos(const AFile: PpxFile): Int64; static;

    /// <summary>
    /// Moves the file pointer to a specific position
    /// </summary>
    /// <param name="AFile">File handle to seek within</param>
    /// <param name="AOffset">Byte offset for the seek operation</param>
    /// <param name="AWhence">Seek mode determining how the offset is interpreted</param>
    /// <returns>True if the seek operation was successful, False otherwise</returns>
    /// <remarks>
    /// This method repositions the file pointer for subsequent read/write operations.
    /// The offset interpretation depends on the AWhence parameter:
    /// - smStart: Absolute position from beginning of file
    /// - smCurrent: Relative to current position (can be negative)
    /// - smEnd: Relative to end of file (typically negative to move backward)
    /// Seeking beyond the end of a file may extend the file when writing.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Seek to beginning of file
    /// TpxFile.Seek(LFile, 0, smStart);
    ///
    /// // Skip 100 bytes forward
    /// TpxFile.Seek(LFile, 100, smCurrent);
    ///
    /// // Go to 10 bytes before end
    /// TpxFile.Seek(LFile, -10, smEnd);
    /// </code>
    /// </example>
    /// <seealso cref="Pos"/>
    /// <seealso cref="TpxSeekMode"/>
    class function Seek(const AFile: PpxFile; const AOffset: Int64; const AWhence: TpxSeekMode): Boolean; static;

    /// <summary>
    /// Checks if the file pointer has reached the end of the file
    /// </summary>
    /// <param name="AFile">File handle to check</param>
    /// <returns>True if at end of file, False if more data is available</returns>
    /// <remarks>
    /// This method tests whether the file position is at or beyond the end of the file.
    /// It's commonly used in loops when reading file data to detect when all content
    /// has been processed. Note that EOF may not be set until an actual read operation
    /// attempts to read beyond the end of the file.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Read entire file in chunks
    /// while not TpxFile.Eof(LFile) do
    /// begin
    ///   LBytesRead := TpxFile.Read(LFile, @LBuffer, SizeOf(LBuffer));
    ///   if LBytesRead > 0 then
    ///     ProcessChunk(@LBuffer, LBytesRead);
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="Read"/>
    /// <seealso cref="Size"/>
    class function Eof(const AFile: PpxFile): Boolean; static;

    /// <summary>
    /// Gets the total size of the file in bytes
    /// </summary>
    /// <param name="AFile">File handle to query</param>
    /// <returns>Total file size in bytes, or -1 if size cannot be determined</returns>
    /// <remarks>
    /// This method returns the complete size of the file in bytes. For ZIP archive entries,
    /// this returns the uncompressed size of the file. The size is useful for allocating
    /// buffers, calculating progress bars, or validating file integrity.
    /// Note that the current file position does not affect the returned size.
    /// </remarks>
    /// <example>
    /// <code>
    /// // Allocate buffer for entire file
    /// LFileSize := TpxFile.Size(LFile);
    /// if LFileSize > 0 then
    /// begin
    ///   SetLength(LBuffer, LFileSize);
    ///   LBytesRead := TpxFile.Read(LFile, @LBuffer[0], LFileSize);
    ///   // Process entire file...
    /// end;
    /// </code>
    /// </example>
    /// <seealso cref="Read"/>
    /// <seealso cref="Pos"/>
    class function Size(const AFile: PpxFile): Int64; static;
  end;

implementation

uses
  System.Types,
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  System.Classes,
  PIXELS.Console,
  PIXELS.Utils,
  PIXELS.Game;

type
  { TZipData }
  PZipData = ^TZipData;
  TZipData = record
    Handle: unzFile;
    Password: AnsiString;
    Filename: AnsiString;
  end;

{ ZipFile Callbacks }
function zip_fopen(const path: PUTF8Char; const mode: PUTF8Char): Pointer; cdecl;
begin
  Result := nil;
end;

function zip_fclose(handle: PALLEGRO_FILE): Boolean; cdecl;
var
  LZipData: PZipData;
begin
  Result := False;
  LZipData := al_get_file_userdata(handle);

  if not Assigned(LZipData.Handle) then Exit;

  Assert(unzCloseCurrentFile(LZipData.Handle) = UNZ_OK);
  Assert(unzClose(LZipData.Handle) = UNZ_OK);

  Dispose(LZipData);

  Result := True;
end;

function zip_fread(f: PALLEGRO_FILE; ptr: Pointer; size: NativeUInt): NativeUInt; cdecl;
var
  LZipData: PZipData;
begin
  LZipData := al_get_file_userdata(f);

  Result := unzReadCurrentFile(LZipData.Handle, ptr, size);
end;

function zip_fwrite(f: PALLEGRO_FILE; const ptr: Pointer; size: NativeUInt): NativeUInt; cdecl;
begin
  Result := 0;
end;

function zip_fflush(f: PALLEGRO_FILE): Boolean; cdecl;
begin
  Result := True;
end;

function zip_ftell(f: PALLEGRO_FILE): Int64; cdecl;
var
  LZipData: PZipData;
begin
  LZipData := al_get_file_userdata(f);

  Result := unztell64(LZipData.Handle);
end;

function zip_fseek(f: PALLEGRO_FILE; offset: Int64; whence: Integer): Boolean; cdecl;
const
  CBufferSize = 1024*4;
var
  LZipData: PZipData;
  LFileInfo: unz_file_info64;
  LCurrentOffset, LBytesToRead: UInt64;
  LOffset: Int64;
  LBuffer: TArray<Byte>;

  procedure SeekToLoc;
  begin
    LBytesToRead := UInt64(LOffset) - unztell64(LZipData.Handle);
    while LBytesToRead > 0 do
    begin
      if LBytesToRead > CBufferSize then
        unzReadCurrentFile(LZipData.Handle, @LBuffer[0], CBufferSize)
      else
        unzReadCurrentFile(LZipData.Handle, @LBuffer[0], LBytesToRead);

      LBytesToRead := UInt64(LOffset) - unztell64(LZipData.Handle);
    end;
  end;
begin
  Result := False;
  LZipData := al_get_file_userdata(f);

  SetLength(LBuffer, CBufferSize);

  if unzGetCurrentFileInfo64(LZipData.Handle, @LFileInfo, nil, 0, nil, 0, nil, 0) <> UNZ_OK then Exit;

  LOffset := offset;

  LCurrentOffset := unztell64(LZipData.Handle);
  if LCurrentOffset = -1 then Exit;

  case whence of
    // offset is already relative to the start of the file
    ALLEGRO_SEEK_SET : ;

    // offset is relative to current position
    ALLEGRO_SEEK_CUR : Inc(LOffset, LCurrentOffset);

    // offset is relative to end of the file
    ALLEGRO_SEEK_END : Inc(LOffset, LFileInfo.uncompressed_size);
  else
    Exit;
  end;

  if LOffset < 0 then Exit

  else if offset > LCurrentOffset then
    begin
      SeekToLoc();
    end
  else // offset < current_offset
    begin
      unzCloseCurrentFile(LZipData.Handle);
      unzLocateFile(LZipData.Handle, PAnsiChar(LZipData.Filename), 0);
      unzOpenCurrentFilePassword(LZipData.Handle, PAnsiChar(LZipData.Password));
      SeekToLoc();
    end;

  Result := True;
end;

function zip_ferror(f: PALLEGRO_FILE): Integer; cdecl;
begin
  Result := 0;
end;

function zip_ferrmsg(f: PALLEGRO_FILE): PUTF8Char; cdecl;
begin
  Result := nil;
end;

procedure zip_fclearerr(f: PALLEGRO_FILE); cdecl;
begin
end;

function zip_fungetc(f: PALLEGRO_FILE; c: Integer): Integer; cdecl;
begin
  Result := -1;
end;

function zip_fsize(f: PALLEGRO_FILE): off_t; cdecl;
var
  LZipData: PZipData;
  LInfo: unz_file_info64;
begin
  LZipData := al_get_file_userdata(f);
  unzGetCurrentFileInfo64(LZipData.Handle, @LInfo, nil, 0, nil, 0, nil, 0);

  Result := LInfo.uncompressed_size;
end;

function zip_feof(f: PALLEGRO_FILE): Boolean; cdecl;
begin
  Result := Boolean(zip_ftell(f) >= zip_fsize(f));
end;

{ TpxFile }
class constructor TpxFile.Create();
begin
  inherited;

  FZipFI.fi_fopen := zip_fopen;
  FZipFI.fi_fclose := zip_fclose;
  FZipFI.fi_fread := zip_fread;
  FZipFI.fi_fwrite := zip_fwrite;
  FZipFI.fi_fflush := zip_fflush;
  FZipFI.fi_ftell := zip_ftell;
  FZipFI.fi_fseek := zip_fseek;
  FZipFI.fi_feof := zip_feof;
  FZipFI.fi_ferror := zip_ferror;
  FZipFI.fi_ferrmsg := zip_ferrmsg;
  FZipFI.fi_fclearerr := zip_fclearerr;
  FZipFI.fi_fungetc := zip_fungetc;
  FZipFI.fi_fsize := zip_fsize;

end;

class destructor TpxFile.Destroy();
begin
  inherited;
end;

class function TpxFile.OpenMemory(const AMemory: Pointer; const ASize: Int64; const AMode: string): PpxFile;
begin
  Result := al_open_memfile(AMemory, ASize, TpxUtils.AsUTF8(AMode));
end;

class function TpxFile.OpenDisk(const AFilename, AMode: string): PpxFile;
begin
  Result := al_fopen(TpxUtils.AsUTF8(AFilename), TpxUtils.AsUTF8(AMode));
end;

class function TpxFile.BuildZip(const AZipFilename, ADirectoryName: string; const APassword: string): Boolean;
const
  CBufferSize = 1024*4;
var
  LFileList: TStringDynArray;
  LArchive: PAnsiChar;
  LFilename: string;
  LFilename2: PAnsiChar;
  LPassword: PAnsiChar;
  LZipFile: zipFile;
  LZipFileInfo: zip_fileinfo;
  LFile: System.Classes.TStream;
  LCrc: Cardinal;
  LBytesRead: Integer;
  LFileSize: Int64;
  LProgress: Single;
  LNewFile: Boolean;
  LBuffer: TArray<Byte>;

  function GetCRC32(aStream: System.Classes.TStream): uLong;
  var
    LBytesRead: Integer;
  begin
    Result := crc32(0, nil, 0);
    repeat
      LBytesRead := AStream.Read(LBuffer[0], CBufferSize);
      Result := crc32(Result, PBytef(@LBuffer[0]), LBytesRead);
    until LBytesRead = 0;

  end;
begin
  Result := False;

  // check if directory exists
  if not TDirectory.Exists(ADirectoryName) then Exit;

  SetLength(LBuffer, CBufferSize);

  // init variabls
  FillChar(LZipFileInfo, SizeOf(LZipFileInfo), 0);

  // scan folder and build file list
  LFileList := TDirectory.GetFiles(ADirectoryName, '*',
    TSearchOption.soAllDirectories);

  LArchive := PAnsiChar(AnsiString(AZipFilename));
  LPassword := PAnsiChar(AnsiString(APassword));

  // create a zip file
  LZipFile := zipOpen64(LArchive, APPEND_STATUS_CREATE);

  // process zip file
  if LZipFile <> nil then
  begin
    // loop through all files in list
    for LFilename in LFileList do
    begin
      // open file
      LFile := TFile.OpenRead(LFilename);

      // get file size
      LFileSize := LFile.Size;

      // get file crc
      LCrc := GetCRC32(LFile);

      // open new file in zip
      LFilename2 := PAnsiChar(AnsiString(LFilename));
      if ZipOpenNewFileInZip3_64(LZipFile, LFilename2, @LZipFileInfo, nil, 0,
        nil, 0, '',  Z_DEFLATED, 9, 0, 15, 9, Z_DEFAULT_STRATEGY,
        LPassword, LCrc, 1) = Z_OK then
      begin
        // make sure we start at star of stream
        LFile.Position := 0;

        LNewFile := True;

        // read through file
        repeat
          // read in a buffer length of file
          LBytesRead := LFile.Read(LBuffer[0], CBufferSize);

          // write buffer out to zip file
          zipWriteInFileInZip(LZipFile, @LBuffer[0], LBytesRead);

          // calc file progress percentage
          LProgress := 100.0 * (LFile.Position / LFileSize);

          // show progress
          if Assigned(GGame) then
          begin
            GGame.OnZipFileBuildProgress(LFilename, Round(LProgress), LNewFile);
          end;

          LNewFile := False;

        until LBytesRead = 0;

        // close file in zip
        zipCloseFileInZip(LZipFile);

        // free file stream
        LFile.Free;
      end;
    end;

    // close zip file
    zipClose(LZipFile, '');
  end;

  // return true if new zip file exits
  Result := TFile.Exists(LFilename);
end;

class function TpxFile.OpenZip(const AZipFilename, AFilename: string; const APassword: string=CpxDefaultZipPassword): PpxFile;
var
  LPassword: PAnsiChar;
  LZipFilename: PAnsiChar;
  LFilename: PAnsiChar;
  LFile: unzFile;
  LZipData: PZipData;

begin
  Result := nil;
  LPassword := PAnsiChar(AnsiString(APassword));
  LZipFilename := PAnsiChar(AnsiString(StringReplace(AZipFilename, '/', '\', [rfReplaceAll])));
  LFilename := PAnsiChar(AnsiString(StringReplace(string(AFilename), '/', '\', [rfReplaceAll])));

  LFile := unzOpen64(LZipFilename);
  if not Assigned(LFile) then Exit;

  if unzLocateFile(LFile, LFilename, 0) <> UNZ_OK then
  begin
    unzClose(LFile);
    Exit;
  end;

  if unzOpenCurrentFilePassword(LFile, LPassword) <> UNZ_OK then
  begin
    unzClose(LFile);
    Exit;
  end;

  New(LZipData);
  LZipData^ := Default(TZipData);

  LZipData.Handle := LFile;
  LZipData.Password := LPassword;
  LZipData.Filename := LFilename;

  Result := al_create_file_handle(@FZipFI, LZipData);
end;

class function TpxFile.Close(const AFile: PpxFile): Boolean;
begin
  Result := al_fclose(AFile);
end;

class function TpxFile.Read(const AFile: PpxFile; AData: Pointer; const ASize: UInt32): UInt32;
begin
  Result := al_fread(AFile, AData, ASize);
end;

class function TpxFile.Write(const AFile: PpxFile; const AData: Pointer; const ASize: UInt32): UInt32;
begin
  Result := al_fwrite(AFile, AData, ASize);
end;

class function TpxFile.Pos(const AFile: PpxFile): Int64;
begin
  Result := al_ftell(AFile);
end;

class function TpxFile.Seek(const AFile: PpxFile; const AOffset: Int64; const AWhence: TpxSeekMode): Boolean;
begin
  Result := al_fseek(AFile, AOffset, Ord(AWhence));
end;

class function TpxFile.Eof(const AFile: PpxFile): Boolean;
begin
  Result := al_feof(AFile);
end;

class function TpxFile.Size(const AFile: PpxFile): Int64;
begin
  Result := al_fsize(AFile);
end;

end.
