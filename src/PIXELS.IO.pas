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
  { CpsSeek }
  CpxSeekStart   = ALLEGRO_SEEK_SET;
  CpxSeekCurrent = ALLEGRO_SEEK_CUR;
  CpxSeekEnd     = ALLEGRO_SEEK_END;

  { CpxDefaultZipPassword }
  CpxDefaultZipPassword = 'ep8uNv%DyjKc#$@jQ.<g%zw[k6T,7:4N2DWC>Y]+n;(r3yj@JcF?Ru=s5LbM`paPf!%AG!7TASJJ4#sSTt';

type
  { PpxFile }
  PpxFile = type PALLEGRO_FILE;

  { TpxZipFileBuildProgressCallback }
  TpxZipFileBuildProgressCallback = reference to procedure(const AFilename: string; const AProgress: Integer; const ANewFile: Boolean; const AUserData: Pointer);

  { TpxFile }
  TpxFile = class(TpxStaticObject)
  private class var
    FZipFI: ALLEGRO_FILE_INTERFACE;
  private
    class constructor Create();
    class destructor Destroy();
  public
    class function OpenMemory(const AMemory: Pointer; const ASize: Int64; const AMode: string): PpxFile; static;
    class function OpenDisk(const AFilename, AMode: string): PpxFile; static;

    class function BuildZip(const AZipFilename, ADirectoryName: string; const ACallback: TpxZipFileBuildProgressCallback=nil; const AUserData: Pointer=nil; const APassword: string=CpxDefaultZipPassword): Boolean; static;
    class function OpenZip(const AZipFilename, AFilename: string; const APassword: string=CpxDefaultZipPassword): PpxFile; static;

    class function Close(const AFile: PpxFile): Boolean; static;
    class function Read(const AFile: PpxFile; AData: Pointer; const ASize: UInt32): UInt32; static;
    class function Write(const AFile: PpxFile; const AData: Pointer; const ASize: UInt32): UInt32; static;
    class function Pos(const AFile: PpxFile): Int64; static;
    class function Seek(const AFile: PpxFile; const AOffset: Int64; const AWhence: Int32): Boolean; static;
    class function Eof(const AFile: PpxFile): Boolean; static;
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
  PIXELS.Utils;

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

procedure TpxFile_BuildZipFileProgress(const AFilename: string; const AProgress: Integer; const ANewFile: Boolean; const AUserData: Pointer);
begin
  if aNewFile then TpxConsole.PrintLn();
  TpxConsole.Print(pxCR+'Adding %s(%d%%)...', [TPath.GetFileName(AFilename), aProgress]);
end;

class function TpxFile.OpenMemory(const AMemory: Pointer; const ASize: Int64; const AMode: string): PpxFile;
begin
  Result := al_open_memfile(AMemory, ASize, TpxUtils.AsUTF8(AMode));
end;

class function TpxFile.OpenDisk(const AFilename, AMode: string): PpxFile;
begin
  Result := al_fopen(TpxUtils.AsUTF8(AFilename), TpxUtils.AsUTF8(AMode));
end;

class function TpxFile.BuildZip(const AZipFilename, ADirectoryName: string; const ACallback: TpxZipFileBuildProgressCallback; const AUserData: Pointer; const APassword: string): Boolean;
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
  LHandler: TpxZipFileBuildProgressCallback;
  LUserData: Pointer;
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

  // init handler
  LHandler := ACallback;
  LUserData := AUserData;

  if not Assigned(LHandler) then
    LHandler := TpxFile_BuildZipFileProgress;

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
          if Assigned(LHandler) then
          begin
            LHandler(LFilename, Round(LProgress), LNewFile, LUserData);
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

class function TpxFile.Seek(const AFile: PpxFile; const AOffset: Int64; const AWhence: Int32): Boolean;
begin
  Result := al_fseek(AFile, AOffset, AWhence);
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
