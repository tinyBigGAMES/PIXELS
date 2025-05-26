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

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UTestbed in 'UTestbed.pas',
  PIXELS in '..\..\src\PIXELS.pas',
  PIXELS.Audio in '..\..\src\PIXELS.Audio.pas',
  PIXELS.Console in '..\..\src\PIXELS.Console.pas',
  PIXELS.Deps in '..\..\src\PIXELS.Deps.pas',
  PIXELS.Events in '..\..\src\PIXELS.Events.pas',
  PIXELS.Graphics in '..\..\src\PIXELS.Graphics.pas',
  PIXELS.IO in '..\..\src\PIXELS.IO.pas',
  PIXELS.Math in '..\..\src\PIXELS.Math.pas',
  PIXELS.Utils in '..\..\src\PIXELS.Utils.pas',
  PIXELS.Game in '..\..\src\PIXELS.Game.pas',
  PIXELS.Network in '..\..\src\PIXELS.Network.pas',
  PIXELS.AI in '..\..\src\PIXELS.AI.pas',
  PIXELS.Base in '..\..\src\PIXELS.Base.pas',
  UMisc in 'UMisc.pas',
  UParticleUniverse in 'UParticleUniverse.pas',
  UPlasmaFire in 'UPlasmaFire.pas',
  UStarfield in 'UStarfield.pas',
  UDefender in 'UDefender.pas',
  UAsteroids in 'UAsteroids.pas';

begin
  try
    RunTests();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
