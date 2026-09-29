<div align="center">

![PIXELS](../media/logo.jpg)

</div>

<a id="overview"></a>

## 🚀 Overview

> **PIXELS at a glance**  
> A general-purpose language with game-first tooling, wasm64 output, bundled desktop runtime, and a zero-setup build pipeline.


**PIXELS** is a general-purpose, game-first language: write Pascal-style code, get a desktop game or app. Games come first, so everything a game needs is built in, but nothing is games-only: tools, utilities and data apps are just as much at home. The compiler turns a Pascal/Oberon-inspired language into wasm64 and packages the result as an Electron desktop app for Windows (`win-x64`) or Linux (`linux-x64`). The Electron runtimes, the WebAssembly tools and the JavaScript bundler all ship inside the toolkit's `bin/` folder. No external toolchain, no Node install, no npm.

<p align="center">
  <strong>General-purpose, game-first</strong> · <code>wasm64</code> · <strong>Windows + Linux</strong> · <strong>Bundled Electron</strong> · <strong>No Node/npm setup</strong>
</p>

Four ideas hold the whole system up:

| Pillar | Principle |
|--------|-----------|
| 🎮 **Games come first** | The standard library is a game library: `app` (lifecycle, game loop, window), `canvas2d` (2D drawing), `audio` (sound and music), `input` (keyboard/mouse/gamepad), `video` (playback), `localstorage` (save data), `sqlite3` (a real SQLite database), `dom` and `browser`, plus the vendor binding `phaser`. Game-first, not games-only: the same language builds tools, utilities and data apps. |
| ⚙️ **WebAssembly is the machine code** | wasm64 is the compile target -- portable, sandboxed, near-native speed. The same `output.wasm` runs on both targets. |
| 📜 **JavaScript is the device driver** | All platform access flows through thin JS shims. Every standard module is a `.pxl` + `.js` pair: the wasm module declares imports, the JS layer satisfies them. |
| 📦 **Electron is the executable** | Every `exe` build becomes an `app.asar` inside the bundled Electron runtime. `-bm distro` renames the Electron executable after your game and zips the whole app for shipping. |

```pxl
module exe hello;

@exeicon "$P:res/assets/icons/pixels.ico";

begin
  println("Hello, I am %s! 🚀🔥✨", "PIXELS");
  
  var i: int32 = 0;
  var s: string = "PIXELS™ " + "Game Toolkit";
  
  println(s);
  
  for i := 1 to 10 do
    println("%d", i);
  end
end.
```

```
> pixels hello -r
```

The compiler builds `hello.pxl` into `bin/res/electron/win-x64/resources/app.asar`, then launches the bundled Electron runtime. The window shows the module name as a heading and prints stdout into the page -- no canvas, no framework, just text on a dark page. (This is `bin/res/examples/hello.pxl`.)

### ⚙️ The Pipeline

Every `.pxl` source file flows through the same stages:

```
.pxl source
  --> PIXELS.Lexer           (source text --> tokens)
  --> PIXELS.Parser          (tokens --> AST)
  --> PIXELS.Semantics       (type checking, name resolution)
  --> PIXELS.Emitter         (AST --> .wat, WebAssembly text format)
  --> wasm-opt               (.wat --> .wasm; -O0 in debug, -O3 in
                              release and distro)
  --> wasm-merge             (exe only: when PIXELS libs or external .wasm
                              modules are linked)
  --> esbuild                (runtime.js + every JS shim --> output.js;
                              minified in release and distro)
  --> PIXELS.Build           (main.js, preload.js, index.html,
                              package.json; PIXELS.Asar packs app.asar)
  --> Electron app           (bin/res/electron/<target>/resources/app.asar)
```

Two bundled tools handle the binary and JavaScript stages: **wasm-opt** (Binaryen) assembles, validates and optimizes the `.wat` into a `.wasm` in one step; **esbuild** wraps CommonJS/ESM vendor libraries and runs a final pass over the combined JavaScript (minifying in release and distro). Both are standalone executables shipped in `bin/res/wasm/` -- no npm, no package manager. The `app.asar` archive is written by the compiler's own asar writer, so Node's `asar` package is not needed either.

A third tool, **wasm-merge**, activates only when an `exe` links a `.wasm` library -- a PIXELS `lib` build or a foreign module. It merges the program module with those modules into one binary after wasm-opt and before the JavaScript and asar steps; a `lib` build merges nothing.

### 📋 Key Capabilities

| Capability | Details |
|---|---|
| **Electron output** | An `exe` build writes `app.asar` (`package.json`, `main.js`, `preload.js`, `index.html`, `output.js`, `output.wasm`, `assets.json`) into `bin/res/electron/<target>/resources/`. The page is served from `pxl://app/` and streams `output.wasm` with `WebAssembly.instantiateStreaming`. |
| **Three module kinds** | `exe` produces an Electron app. `lib` produces a `.wasm` library (plus its `.wat`) in the output folder that other PIXELS programs can link against. `unit` is validated only and compiled into the modules that import it. |
| **wasm64 features** | memory64, bulk-memory, nontrapping-float-to-int, exception-handling, multivalue -- all enabled by default. |
| **Game library** | Nine standard modules ship with the compiler: `app`, `canvas2d`, `input`, `audio`, `video`, `dom`, `browser`, `localstorage`, `sqlite3`. One vendor binding ships beside them: `phaser`. |
| **Three build modes** | `debug` (default, wasm-opt `-O0`, leak report), `release` (`-O3`, minified JS, menu bar hidden, DevTools off) and `distro` (release plus a shippable `<name>-<target>.zip`). Set with `-bm` or `@buildmode`. |
| **Two targets** | `win-x64` (default) and `linux-x64`, each with its own bundled Electron runtime. Set with `-t`. |
| **Conditional compilation** | `@define`, `@undef`, `@ifdef`, `@ifndef`, `@elseif`, `@else`, `@endif`. Four predefined symbols: `PIXELS`, `WASM64`, `BUILD_EXE`, `BUILD_LIB`. |
| **Module system** | `exe`, `lib`, and `unit` modules with `import`, full module qualification, `initialize`/`finalize` lifecycle hooks, and `public` declaration sections. |
| **Unit tests** | `test` blocks after `end.` with eight assertion intrinsics. Enable with `@unittestmode on;` and the test runner runs inside the exe's entry point instead of the main body. |
| **Game assets** | `@assets` maps files into the app by key. `debug` and `release` builds serve them in place over `pxl://app/<key>`; a `distro` build packs them into `resources/__assets/` next to `app.asar`. `canvas2d`, `audio` and `video` load them on demand by key. |

### 💡 What Makes It Different

The user installs nothing beyond the toolkit itself. No wasm toolchain to configure, no JavaScript bundler to manage, no Electron to download. wasm-opt, esbuild, wasm-merge and both Electron runtimes ship inside the compiler's own directory -- they are invisible to the workflow.

One command builds and runs your game. `-bm distro` turns it into one zip that IS the game.

### 🖥️ System Requirements

| Area | Requirement |
|---|---|
| **Host OS** | Windows x64 (the compiler runs here) |
| **Targets** | `win-x64` and `linux-x64` desktop apps on the bundled Electron 44.4.3 runtime |
| **Runtime dependencies** | None -- the distro zip carries its own Electron runtime |
| **Building the compiler** | Delphi (RAD Studio) |

> [!NOTE]
> **Two targets, one compiler host.** The compiler itself runs on Windows. The *output* is a Windows or Linux desktop app: add `-t linux-x64 -bm distro` to package the same game with the bundled Linux Electron runtime.

---

<p align="right"><a href="#overview">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="documentation-guide"></a>

## 🧭 Documentation Guide

> **Find your way**  
> Start fast, then move directly to the language, game APIs, runtime, or recipes you need.


> [!TIP]
> **Fast path:** read [Getting Started](#getting-started), skim [Language Reference](#language-reference), then jump to [Standard Library](#standard-library) for the game modules and [JS Interop](#js-interop) when you are ready to call your own JavaScript from your game.

### 🧩 Pick a Path

| I want to... | Go here |
|---|---|
| **Build something immediately** | [Getting Started](#getting-started) → [Common Tasks](#common-tasks) |
| **Learn the language** | [Language Reference](#language-reference) → [Module System](#module-system) |
| **Make a game** | [Standard Library](#standard-library) → [Common Tasks](#common-tasks) |
| **Connect JS or wasm code** | [JavaScript Interop](#js-interop) |
| **Understand internals** | [Memory and Data Structures](#memory-data-structures) → [Runtime](#runtime-library) → [Diagnostics](#debugging) |
| **Ship a build** | [Build Modes](#build-modes) → [Getting Started](#getting-started) |

### 🎯 Who Is This For?

- **Game developers** who want Pascal-style syntax, wasm64 performance, and a desktop build with no JavaScript tooling. PIXELS is a general-purpose, game-first language: write Pascal-style code, get a desktop game or app.
- **Delphi and Pascal developers** who want to make games with familiar syntax and ship them to Windows and Linux with nothing extra to install.
- **Anyone building a desktop app** -- tools, utilities, editors and data apps. PIXELS is general-purpose: `dom` gives you menus and panels, and `sqlite3` and `localstorage` store your data.
- **Anyone who wants one file to hand out** -- `-bm distro` packages the game and its Electron runtime into one `<name>-<target>.zip`.

### 🖥️ CLI Reference

<a id="cli-reference"></a>

PIXELS ships a single command-line compiler, `pixels`. The Electron runtimes and build tools it needs ship with it. There is nothing else to install.

**Syntax:**

```
pixels <source> [OPTIONS]
```

Pass the source filename with or without the `.pxl` extension -- the compiler normalizes it (any other extension is replaced with `.pxl`).

| Flag | Description |
|---|---|
| `<source>` | PIXELS source file (`.pxl`) |
| `-r, --run` | Run the app in the bundled Electron runtime after building (ignored with a warning for `distro`) |
| `-o, --output <path>` | Set output directory (default: `output/` under the working directory) |
| `-bm, --buildmode <mode>` | Set build mode: `debug` (default), `release`, `distro` (see table below) |
| `-t, --target <target>` | Set target platform: `win-x64` (default), `linux-x64` |
| `-h, --help` | Show help |

**Examples:**

```
pixels hello
pixels hello -r
pixels hello -r -bm release
pixels hello --target win-x64 --buildmode release
```

The value of `-o`, `-bm` and `-t` must be the next argument (there is no `--flag=value` form). The exit code is `0` on success (or the app's own exit code when `-r` ran it), `1` when compilation failed, and `2` for a command-line error such as an unknown flag or a missing source file.

**Editor:** `pixels editor [files]` opens the PIXELS Editor, with any files given opened in tabs, and returns at once (see [Editor](#editor)).

> [!NOTE]
> **CLI overrides source directives.** A `-bm` flag on the command line takes precedence over a `@buildmode` directive in the source file, and `-o` takes precedence over `@outputpath`.

### 🎚️ Build Modes

<a id="build-modes"></a>
<a id="optimization-levels"></a>

The build mode controls the wasm-opt level, the JavaScript bundle, the Electron window and packaging. Set it with `-bm <mode>` on the command line or `@buildmode <mode>;` in source.

| Aspect | `debug` (default) | `release` | `distro` |
|---|---|---|---|
| wasm-opt flag | `-O0` | `-O3` | `-O3` |
| esbuild pass | runs, not minified | `--minify` | `--minify` |
| Electron menu bar | visible (default menu) | hidden | hidden |
| Leak report at exit | yes | no | no |
| Output | shared app in `bin/res/electron/<target>/` | shared app in `bin/res/electron/<target>/` | shared app plus `<outdir>/<name>-<target>.zip` |
| `-r` | runs the app | runs the app | ignored (warning `CMP002`) |

> [!IMPORTANT]
> **Only distro produces a file you can ship.** `debug` and `release` builds overwrite the one shared app in `bin/res/electron/<target>/resources/` every time, for every project. `distro` copies that app, renames `electron.exe` (or `electron` on Linux) after your module, applies the `@exeicon` icon on `win-x64`, and zips the result into the output folder. No build mode opens DevTools automatically.

### 📌 Current Status

The compiler is working end-to-end. Feature summary:

- 17 primitive types (16 plus `varargs`) with exact wasm64 sizes (BNF sec 3)
- Variables, typed and untyped constants, constant folding
- Arithmetic, comparison, logical, bitwise, and compound assignment operators (BNF sec 4)
- Control flow: `if`/`else`, `while`, `for`, `repeat`/`until`, `match`, `break`, `continue` (BNF sec 11)
- Exception handling: `guard`/`except`/`finally`, `throw`, `throwcode`, `exccode`, `excmsg` (BNF sec 11)
- Routines: procedures, functions, unconditional overloading, const/var parameters, variadic arguments (BNF sec 9, 14)
- Records: plain, packed, aligned, derived, overlay, bitfield (BNF sec 10)
- Choices (named `int32` constants), sets, fixed arrays, dynamic arrays (BNF sec 10)
- Typed and untyped pointers (BNF sec 10); `new`/`dispose`, `getmem`/`freemem`/`resizemem`, `setlength` statements (BNF sec 11)
- Module system: `exe`, `lib`, `unit` with `import`, full qualification, `initialize`/`finalize` (BNF sec 6)
- JS interop: `external` clause with library resolution for `.js` and `.wasm` files (BNF sec 9)
- Conditional compilation: `@define`/`@undef`/`@ifdef`/`@ifndef`/`@elseif`/`@else`/`@endif` (BNF sec 7)
- Game assets: `@assets` maps files into the app (served in place in debug/release, packed into `resources/__assets/` in distro)
- Standard library: `app`, `canvas2d`, `input`, `audio`, `video`, `dom`, `browser`, `localstorage`, `sqlite3`; vendor binding `phaser`
- Build modes `debug`/`release`/`distro` and targets `win-x64`/`linux-x64` on the bundled Electron runtime
- Built-in testing: `test` blocks with eight assertion intrinsics (BNF sec 15)
- 10 compiler intrinsics: `len`, `size`, `format`, `utf8`, `cstr`, `wstr`, `paramcount`, `paramstr`, `exccode`, `excmsg` (BNF sec 13); `print` and `println` are statements (BNF sec 11)

### 🗺️ Table of Contents

- 🚀 [Overview](#overview) -- what PIXELS is, the pipeline, key capabilities
- 🧭 [Documentation Guide](#documentation-guide) -- audience, CLI reference, build modes, status
- 📖 [Getting Started](#getting-started) -- install, first program, build and run
- 📘 [Language Reference](#language-reference) -- types, operators, routines, control flow
- 📦 [Module System](#module-system) -- exe, lib, unit, imports, visibility, directives
- 🔗 [JS Interop](#js-interop) -- external clause, JS libs, wasm libs, marshalling
- 🧠 [Memory](#memory-data-structures) -- heap, strings, arrays, cleanup, leak report
- 🧾 [Formal Grammar](#bnf-grammar) -- BNF rules derived from the parser
- 📦 [Standard Library](#standard-library) -- app, canvas2d, input, audio, video, dom, browser, localstorage, sqlite3, phaser
- ⚙️ [Runtime](#runtime-library) -- runtime.wat, runtime.js, WASI shim, exceptions, assets
- 🔍 [Diagnostics](#debugging) -- build modes, leak report, DevTools, conditional compilation
- ✍️ [Code Style](#code-style) -- naming conventions and formatting
- 🛠️ [Common Tasks](#common-tasks) -- practical recipes for everyday PIXELS work
- ✏️ [Editor](#editor) -- the PIXELS code editor: language server, build and run, navigation, shortcuts

---

<p align="right"><a href="#documentation-guide">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="getting-started"></a>

## 🚀 Getting Started

> **From source to running game**  
> Install once, write Pascal-style code, and launch a desktop build with one command.


*Install the toolkit, write a program, build it, run it as a desktop app.*

> [!TIP]
> **Already set up?** Skip to [Your First Program](#your-first-program). For the big picture, see the [Overview](#overview).


### 📋 Prerequisites

PIXELS compiles your `.pxl` source into an Electron desktop app. No linker, no external SDK, no JavaScript toolchain, no Node install. You need:

| Requirement | Details |
|---|---|
| **Host OS** | Windows x64 (the compiler runs here) |
| **Target** | `win-x64` (default) or `linux-x64` desktop app, running on the bundled Electron 44.4.3 runtime |

That is all. The tools the compiler uses internally -- wasm-opt, esbuild, wasm-merge -- ship inside `bin/res/wasm/`, and both Electron runtimes ship inside `bin/res/electron/`. They are invisible to your workflow.

> [!NOTE]
> **Building the compiler from source** requires Delphi (RAD Studio); `bin/build-pixels.cmd` runs the build. Most users only need the pre-built `pixels` binary.


### 📥 Installation

<a id="installation"></a>

1. Download the latest release from [Releases](https://github.com/tinyBigGAMES/PIXELS/releases) and extract it. The release carries the pre-built `bin/` folder; cloning the repository is only for building the compiler from source (see the note above).
2. Add the `bin/` directory to your system `PATH`, or run `pixels.exe` directly from it.

There is nothing to download on first build and nothing to cache.

The `bin/` directory contains everything the compiler needs:

| Path | What it is |
|---|---|
| `bin/pixels.exe` | The compiler |
| `bin/run-pixels.cmd` | Runs `pixels.exe` with `bin/` as the working directory and writes its console output to `bin/pixels.txt` |
| `bin/res/runtime/` | Runtime files (`runtime.wat`, `runtime.js`) |
| `bin/res/wasm/` | Build tools (wasm-opt, wasm-merge, esbuild) |
| `bin/res/electron/` | Electron runtimes (`win-x64`, `linux-x64`); your built app is written here |
| `bin/res/libs/std/` | Standard library modules (`app`, `canvas2d`, `input`, `audio`, `video`, `dom`, `browser`, `localstorage`, `sqlite3`) |
| `bin/res/libs/vendor/` | Third-party library bindings, one folder each (`phaser`) |
| `bin/res/assets/` | Sample assets used by the examples (`audio`, `fonts`, `icons`, `images`, `video`) |
| `bin/res/examples/` | Runnable example programs including `hello.pxl` |
| `bin/res/tests/` | Compliance and probe test suites |
| `bin/res/stage/`, `bin/res/asar/` | Scratch folders the build uses for intermediate files |


### 📝 Your First Program

<a id="your-first-program"></a>

Create a file called `hello.pxl` (or open `bin/res/examples/hello.pxl`):

```pxl
module exe hello;

@exeicon "$P:res/assets/icons/pixels.ico";

begin
  println("Hello, I am %s! 🚀🔥✨", "PIXELS");
  
  var i: int32 = 0;
  var s: string = "PIXELS™ " + "Game Toolkit";
  
  println(s);
  
  for i := 1 to 10 do
    println("%d", i);
  end
end.
```

Every PIXELS program starts with a **module declaration**: `module exe hello;`. The keyword `exe` means this module produces an Electron desktop app. The name `hello` must match the source filename without extension.

`@exeicon` sets the icon of the executable that a `distro` build produces on `win-x64`. The `$P:` prefix means "relative to the folder of `pixels.exe`".

`begin...end.` is the program entry point. The period after `end` marks the end of the module.

A few things to notice in this snippet:

- `println` uses printf-style format strings: `%s` for strings, `%d` for integers.
- Variables are declared with `var` in the body.
- `for...do...end` -- control structures are block-terminated, not semicolon-terminated.


### 🔨 Build and Run

<a id="building-and-running"></a>

Open a terminal in the directory containing `hello.pxl` and run:

```
pixels hello -r
```

The compiler builds `hello.pxl` into the bundled Electron runtime and launches it. You will see status lines like these (from a debug build of `canvas2d_tour.pxl`, trimmed):

```
Parsing canvas2d_tour.pxl...
Parsing unit 'browser'...
Analyzing unit 'browser'...
Analyzing...
Processing directives...
Emitting code...
Building canvas2d_tour...
Optimization: debug (no optimization, devtools enabled)
Wrote canvas2d_tour.wat
Assembling canvas2d_tour.wat...
Assembled canvas2d_tour.wasm (20047 bytes)
Minifying JS bundle...
Packaging Electron app...
Packed app.asar (93357 bytes)
Build succeeded.
```

In the app: an 800x600 Electron window titled with the module name, a dark page with the module name as a heading, your program's `println` output in the body, and `exit code: 0` at the bottom. Despite the "devtools enabled" status text, no build mode opens DevTools automatically.

> [!NOTE]
> **The source extension is optional.** `pixels hello` and `pixels hello.pxl` are equivalent -- the compiler normalizes the extension.

To build without running, drop the `-r` flag:

```
pixels hello
```

The full set of command-line options:

| Flag | Argument | Effect |
|---|---|---|
| `<source>` | | PIXELS source file (`.pxl`), extension optional |
| `-r`, `--run` | | Run the app in the bundled Electron runtime after building (ignored for `distro`) |
| `-o`, `--output` | `<path>` | Set the output directory |
| `-bm`, `--buildmode` | `<mode>` | Set build mode: `debug` (default), `release`, `distro` |
| `-t`, `--target` | `<target>` | Set target platform: `win-x64` (default), `linux-x64` |
| `-h`, `--help` | | Display the help message |

> [!TIP]
> **Build modes in depth.** Each mode sets a wasm-opt level, JavaScript minification, the menu bar and packaging. See [Build Modes](#build-modes) for the full table.


### 📂 Output Folder

<a id="output-folder"></a>

By default the compiler writes output to `output/` under the current working directory. Three settings control the output path, highest priority first:

1. **`-o <path>`** on the command line.
2. **`@outputpath "path";`** directive in the source file.
3. **Default** -- `output/` under the working directory.

> [!NOTE]
> A relative path in a directive (`@outputpath`, `@assets`, `@exeicon`, `@addlibrarypath`) resolves against the current working directory, not the source file's folder: use absolute or `$P:` paths to compile from any folder, or run through `bin/run-pixels.cmd`.

What lands where depends on the module kind and build mode:

| Module kind | Files produced |
|---|---|
| `exe` (`debug`, `release`) | Nothing is kept in the output folder. The app is written to `bin/res/electron/<target>/resources/app.asar`, assets served in place from their source folders (listed by `assets.json` in `app.asar`), and the `.wat`/`.wasm` intermediates to `bin/res/stage/` |
| `exe` (`distro`) | The same app, plus **`hello-win-x64.zip`** (or `hello-linux-x64.zip`) in the output folder -- the deliverable |
| `lib` | `hello.wat`, `hello.wasm` |
| `unit` | Nothing -- unit modules are compiled inline into the importing module |

> [!TIP]
> **Ship only the distro zip.** `debug` and `release` builds overwrite the one shared app in `bin/res/electron/<target>/` on every build, for every project. The zip from `-bm distro` holds a complete copy of the Electron runtime with `electron.exe` renamed to `hello.exe` (or `electron` to `hello` on Linux), your `app.asar` and your assets.


### 📦 What the App Contains

The generated `app.asar` carries seven files:

1. **`package.json`** -- `{"name":"<module>","main":"main.js"}`.
2. **`main.js`** -- the Electron main process. It opens an 800x600 window (`nodeIntegration` on, `contextIsolation` off), serves the app as `pxl://app/` and loads `pxl://app/index.html`, hides the menu bar and disables DevTools in `release` and `distro`, and on close asks the page to shut the program down before the window goes away (after at most 3 seconds). It also handles the `set-title` and `set-content-size` messages from the page.
3. **`preload.js`** -- a placeholder; it exposes nothing.
4. **`index.html`** -- the page shell (module name as `<title>` and `<h1>`, console output areas) and the runner: it waits for the asset manifest (`PxlAssets.init`), streams `output.wasm` with `WebAssembly.instantiateStreaming`, instantiates the wasm module with its imports, calls `_start`, and calls `_shutdown` when the program ends (its main block returns without `app.Run`, or `app.Quit`, `app.Close` or a failure ends it) or when the window closes.
5. **`output.js`** -- the JavaScript host layer: runtime.js (a vendored WASI preview1 shim for memory64, MIT OR Apache-2.0, plus the `PXL` helpers and the `PxlAssets` loader) followed by every standard-library, vendor and user `.js` file the program pulled in, passed through esbuild.
6. **`output.wasm`** -- the compiled wasm64 module.
7. **`assets.json`** -- the asset manifest: each key's file path (debug/release) or key (distro), size and MIME type; the page reads it as `__assets.json`.

Assets are not inside `app.asar`. `debug` and `release` builds serve `@assets` files in place from their source folders; a `distro` build packs them into `resources/__assets/` beside it. Shims load them on demand by key over `pxl://app/<key>`.

> [!NOTE]
> **Bundled Electron 44.4.3.** Both targets run on the Electron runtime that ships in `bin/res/electron/<target>/` (version 44.4.3), so your game does not depend on the player's browser, and players install nothing.

> [!NOTE]
> **linux-x64 under WSL2.** A linux-x64 build runs under WSL2 with no setup: dev manifests use `/mnt/<drive>/...` paths, and when a GPU is exposed (`/dev/dxg`) the app relaunches itself once with Mesa's d3d12 driver so WebGL runs on the GPU.

Next: [Language Reference](#language-reference)

---

<p align="right"><a href="#getting-started">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="language-reference"></a>

## 📘 Language Reference

> **The language, in one place**  
> Types, expressions, flow control, routines, declarations, directives, and tests.


*Everything the language can express -- types, operators, control flow, routines, and more -- in one place with worked examples.*

Keywords and built-in type names are case-insensitive: `begin`, `Begin`, and `BEGIN` are the same keyword, and `Int32` is `int32`. Lowercase is the convention. Identifiers keep their case, and identifiers that differ only in case are distinct. The module kinds `exe`, `lib`, and `unit` are the exception: they must be written in lowercase. The naming convention is PascalCase for types, camelCase for variables, and UPPER_CASE for constants. There is no `T` prefix on type names.

> [!TIP]
> **Where to look next.** This section covers syntax and constructs. For multi-module projects see [Module System](#module-system). For calling JavaScript or linking wasm libraries see [JS Interop](#js-interop). For heap allocation, strings, and dynamic arrays see [Memory](#memory-data-structures).


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🔢 1. Primitive Types](#language-reference-primitive-types)
- [✏️ 2. Literals](#language-reference-literals)
- [📦 3. Variables](#language-reference-variables)
- [🔒 4. Constants](#language-reference-constants)
- [➕ 5. Operators](#language-reference-operators)
- [🔀 6. Control Flow](#language-reference-control-flow)
- [⚠️ 7. Exception Handling](#language-reference-exception-handling)
- [🔧 8. Routines](#language-reference-routines)
- [🔠 9. Type Declarations](#language-reference-type-declarations)
- [🔤 10. Type Casts](#language-reference-type-casts)
- [💬 11. Comments](#language-reference-comments)
- [⚡ 12. Intrinsics](#language-reference-intrinsics)
- [🔀 13. Conditional Compilation](#language-reference-conditional-compilation)
- [📋 14. Module-Level Directives](#language-reference-module-level-directives)
- [🧪 15. Testing](#language-reference-testing)

</details>

<a id="language-reference-primitive-types"></a>

### 🔢 1. Primitive Types

*Seventeen built-in types map directly to WebAssembly value types.*

| Type | Size | Wasm type | Description |
|------|------|-----------|-------------|
| `int8` | 1 byte | i32 | Signed 8-bit integer |
| `int16` | 2 bytes | i32 | Signed 16-bit integer |
| `int32` | 4 bytes | i32 | Signed 32-bit integer |
| `int64` | 8 bytes | i64 | Signed 64-bit integer |
| `uint8` | 1 byte | i32 | Unsigned 8-bit integer |
| `uint16` | 2 bytes | i32 | Unsigned 16-bit integer |
| `uint32` | 4 bytes | i32 | Unsigned 32-bit integer |
| `uint64` | 8 bytes | i64 | Unsigned 64-bit integer |
| `float32` | 4 bytes | f32 | 32-bit IEEE 754 float |
| `float64` | 8 bytes | f64 | 64-bit IEEE 754 float |
| `bool` | 1 byte | i32 | Boolean (`true` or `false`) |
| `char` | 1 byte | i32 | 8-bit character (UTF-8 code unit) |
| `wchar` | 2 bytes | i32 | 16-bit wide character (UTF-16 code unit) |
| `string` | 8 bytes | i64 | Managed, refcounted UTF-8 string |
| `wstring` | 8 bytes | i64 | Managed, refcounted wide string (length and comparison in UTF-16 units) |
| `ptr` | 8 bytes | i64 | Untyped pointer |
| `varargs` | 8 bytes | i64 | Variadic argument pack (see [Routines](#language-reference)) |

All type names are reserved words (in any letter case) and cannot be used as identifiers.

> [!NOTE]
> **Wasm64 and pointer width.** PIXELS targets wasm64 (memory64), so pointers, strings, and dynamic arrays are 64-bit addresses. Sub-32-bit integer types (int8, uint16, etc.) are stored in memory at their natural size but are widened to i32 for computation.


<a id="language-reference-literals"></a>

### ✏️ 2. Literals

*Integer, float, string, character, boolean, nil, record, and set.*

#### Integer literals

```pxl
42          // decimal
0xFF        // hexadecimal (0x or 0X prefix)
```

An integer literal is `int32` when nothing else decides its type. In a typed context (a constant or variable initializer, an assignment, a routine argument, a `return`, a `match` label, or the other operand of a binary operator) the literal takes the type of that context, so `var big: int64 = 5000000000;` is an `int64` literal. The one place a literal is widened by its value is a variadic argument: a bare integer literal outside the `int32` range is passed as `int64`.

There are no binary, octal, or digit-separator forms, and no integer suffixes. Negative numbers are unary minus applied to a literal.

#### Float literals

```pxl
3.14        // float64 unless the context gives another type
3.14f       // float32 (f or F suffix) unless the context gives another type
1.0e10      // scientific notation
1e10        // also a float: an exponent alone is enough
2f          // also a float: a suffix alone is enough
```

A number becomes a float literal when it has a decimal point, an exponent, or an `f`/`F` suffix. In `1..10` the `..` is a range, so both ends stay integers. A leading dot (`.5`) is not a float; write `0.5`. Hex literals never take a suffix (`0x1F` is the integer 31).

Without a suffix, a float literal is `float64`; with the `f` or `F` suffix it is `float32`. In a typed context the context type wins over both, just as for integers: `var x: float64 = 1.5f;` stores a `float64`, and `var y: float32 = 1.5;` stores a `float32`.

A float literal is read correctly rounded to the nearest `float64`. A literal beyond the `float64` range is a compile error (LEX006); one too small to represent reads as 0.

#### String literals

Strings use double quotes with C-style escape sequences. A string literal must end on the line where it starts; a raw line break inside the quotes is an error (use `\n`):

```pxl
"hello world"
"line1\nline2\ttab"
```

| Escape | Meaning |
|--------|---------|
| `\n` | Newline |
| `\t` | Tab |
| `\r` | Carriage return |
| `\0` | Null character |
| `\\` | Backslash |
| `\'` | Single quote |
| `\"` | Double quote |
| `\xHH` | Code point U+00HH (exactly two hex digits) |

`\xHH` names a character, not a raw byte: the string is stored as UTF-8, so `"\xFF"` (U+00FF) takes two bytes. Any other character after `\` is an error. There is no single-quoted literal form; `'` outside a string is an invalid character.

The empty string is `nil`: `""`, an empty `format()` result and every runtime operation that yields no characters give `nil`, so `s = ""` and `s = nil` are the same test and `assertnil("")` passes. `cstr` of an empty string points at a NUL byte, never at address 0.

#### Wide string literals

Prefix a string with lowercase `w` for a `wstring` (an uppercase `W` is not a prefix):

```pxl
w"hello wide world"
```

Wide strings support the same escape sequences. A wide literal is stored as UTF-8 like any other string; the runtime builds its UTF-16 form on demand, and `len` of a `wstring` counts UTF-16 code units.

#### Boolean literals

```pxl
true
false
```

#### Nil

```pxl
nil       // null pointer, null routine reference
```

#### Character assignment

There is no dedicated character literal. Characters are assigned from strings of exactly one code unit:

```pxl
var c: char;
c := "A";          // one UTF-8 code unit (ASCII)

var wc: wchar;
wc := w"X";        // one UTF-16 code unit
```

A literal assigned to a `char` must be exactly one UTF-8 code unit (ASCII), and one assigned to a `wchar` exactly one UTF-16 code unit; anything else, including `""`, is error SEM003. Use `"\0"` for NUL. The same rule holds for a literal compared with a `char` or `wchar` (`=`, `<>`, the ordering operators) and for `asserteq`, which takes the literal rule of `=`: `c = "ab"` is error SEM003 at the literal.

A `string` or `wstring` indexes from 0: `s[i]` is UTF-8 code unit `i` of `s` (a `char`, the same byte as `cstr(s)[i]`) and `ws[i]` is UTF-16 code unit `i` (a `wchar`). Storing an element (`s[i] := "x";`) is legal: the string is made unique first (copy-on-write), so every other holder of the old text keeps it. The string must itself be a variable or other location (SEM016 otherwise). `@s[i]` is error SEM003; use `cstr(s)` for a pointer to the bytes. A `debug` build raises exception 1005 for an index outside `0..len(s)-1`; `release` and `distro` builds do not check it.

#### Record literals

Construct a record value inline by naming the type and its fields:

```pxl
type
  Point = record
    x: int32;
    y: int32;
  end;

var p: Point;

begin
  p := Point(x: 10, y: 20);
end.
```

#### Set literals

```pxl
[]              // empty set
[5]             // single element
[1, 3, 5, 7]   // multiple elements
[1..10]         // range
[1, 3..7, 10]   // mixed elements and ranges
```

Set elements must be in the range 0..63 (a set is a 64-bit mask). Adding an element outside that range raises exception code 1001.


<a id="language-reference-variables"></a>

### 📦 3. Variables

*Declared with `var`, zero-initialized by default.*

Variables are declared in a `var` section with a type and an optional initializer:

```pxl
var
  x: int32;                  // zero-initialized
  y: int32 = 10;             // explicit initializer
  name: string = "Alice";
```

Variables can also be declared inline at statement level:

```pxl
begin
  var sum: int32 = a + b;
  println("sum = %d", sum);
end.
```

> [!NOTE]
> **Inline `var` is statement-level.** The declaration `var ident: Type [= expr];` can appear anywhere a statement is expected, not only at the top of a block.


<a id="language-reference-constants"></a>

### 🔒 4. Constants

*Compile-time values, typed or untyped.*

```pxl
const
  MAX: int32 = 100;           // typed constant
  PI: float64 = 3.14159;
  GREETING = "hello";         // untyped -- type inferred from the value
  DOUBLED = 21 * 2;           // expression constant (42)
  IS_EQ = 5 = 5;              // boolean expression constant (true)
```

Constant expressions are evaluated at compile time. Untyped integer constants default to `int32`; untyped string constants to `string`.


<a id="language-reference-operators"></a>

### ➕ 5. Operators

*Arithmetic, comparison, logical, bitwise, compound assignment, and pointer operators.*

#### Arithmetic

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` | Addition | `a + b` |
| `-` | Subtraction / unary negation | `a - b`, `-x` |
| `*` | Multiplication | `a * b` |
| `/` | Division | `a / b` |
| `div` | Integer division | `a div b` |
| `mod` | Modulo | `a mod b` |

#### Comparison

| Operator | Meaning |
|----------|---------|
| `=` | Equal |
| `<>` | Not equal |
| `<` | Less than |
| `>` | Greater than |
| `<=` | Less or equal |
| `>=` | Greater or equal |
| `in` | Set membership |

Records, overlays and static arrays cannot be compared (error SEM003): compare their fields or elements. Dynamic arrays compare by reference.

#### Logical and bitwise

| Operator | Meaning |
|----------|---------|
| `and` | Logical/bitwise AND |
| `or` | Logical/bitwise OR |
| `xor` | Logical/bitwise XOR |
| `not` | Logical NOT on a `bool`, bitwise NOT on an integer (result has the operand's type: `not 5` is `-6`) |
| `shl` | Bit shift left |
| `shr` | Bit shift right |

#### Compound assignment

| Operator | Equivalent |
|----------|------------|
| `+=` | `x := x + y` |
| `-=` | `x := x - y` |
| `*=` | `x := x * y` |
| `/=` | `x := x / y` |

#### Other operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `:=` | Assignment | `x := 42` |
| `^` | Pointer dereference (postfix) | `p^` |
| `address of` | Address-of (prefix) | `address of x` |

#### Precedence (highest to lowest)

| Level | Operators |
|-------|-----------|
| 1 (highest) | `not`, unary `-`, unary `+`, `address of` |
| 2 | `*`, `/`, `div`, `mod`, `and`, `shl`, `shr` |
| 3 | `+`, `-`, `or`, `xor` |
| 4 (lowest) | `=`, `<>`, `<`, `>`, `<=`, `>=`, `in` |

All operators are left-associative at every level. Use parentheses to override precedence.


<a id="language-reference-control-flow"></a>

### 🔀 6. Control Flow

*Block-terminated statements -- no parentheses around conditions, no `begin` inside loops.*

#### if / then / else / end

```pxl
if x > 0 then
  println("positive");
end;

if x > 0 then
  println("positive");
else
  println("non-positive");
end;
```

#### while / do / end

```pxl
while x > 0 do
  x -= 1;
end;
```

> [!NOTE]
> **No `begin` in loops.** The syntax is `while expr do stmts end` -- the `do` keyword opens the body directly.

#### for / to / downto / do / end

```pxl
for i := 1 to 10 do
  println("%d", i);
end;

for i := 10 downto 1 do
  println("%d", i);
end;
```

The name after `for` is the loop variable. If it names an integer variable declared earlier in this module (a local or a module variable, not an imported one), the loop drives that variable, and after the loop it holds the end value after a normal finish, the value it had when `break` left the loop, or its old value when the loop ran zero times. Otherwise the loop declares its own variable, scoped to the loop and typed from its bounds (the wider of the start and end types; `1 to 10` gives `int32`). Do not write `var` in the loop header. The start and end expressions are evaluated once, before the first iteration. Assigning to the loop variable inside the body is compile error SEM017; so is a loop name that is a parameter, a constant, an imported variable or the variable of an enclosing loop. A non-integer variable is SEM003. `continue` moves on to the next value.

#### repeat / until

```pxl
repeat
  x += 1;
until x >= 10;
```

The body executes at least once. `repeat...until` does **not** use `end` -- the `until` keyword closes the loop.

#### match / of / end

```pxl
match value of
  1: println("one");
  2, 3: println("two or three");
  4..10: println("four through ten");
else
  println("something else");
end;
```

`match` supports single values, comma-separated lists, and ranges (`low..high`). The `else` branch handles unmatched values.

#### break and continue

`break` exits the innermost loop. `continue` skips the rest of the loop body: a `while` loop re-tests its condition, a `for` loop moves on to the next value, and a `repeat` loop tests its `until` condition. Both are valid only inside `while`, `for`, and `repeat` loops.


<a id="language-reference-exception-handling"></a>

### ⚠️ 7. Exception Handling

*guard/except/finally protects code; throw/throwcode raises exceptions.*

#### guard / except / finally / end

```pxl
guard
  // protected code
except
  println("error: code=%d, msg=%s", exccode(), excmsg());
finally
  // runs after the guard body, or after the except body
end;
```

You can use `except` alone, `finally` alone, or both. `finally` always runs: when the guard body finishes normally, after the `except` body has handled an exception, and when a `return`, `break` or `continue` leaves the guard. An exception that is not handled -- there is no `except`, or the `except` body itself raises -- propagates after `finally` runs. A `finally` body cannot itself be left with `return`, `break` or `continue` (compile error SEM014); a loop inside the `finally` body may still use `break` and `continue`.

A `guard` catches PIXELS exceptions only: those raised by `throw`/`throwcode` and those the runtime raises itself (see the code table below). Integer `div` and `mod` by zero are checked at runtime and raise code 1002, so they are catchable. WebAssembly traps (out-of-bounds memory access, running out of memory, `unreachable`) are not exceptions: no `guard` catches them, and they end the program. An exception that no `guard` catches also ends the program: the error is reported on stderr (the app window shows it) and the program exits with code 1, and shutdown still runs -- `finalize` sections, global cleanup and, in a `debug` build, the heap report.

#### throw and throwcode

```pxl
throw("something went wrong");           // code is always 1000
throwcode(42, "custom error");            // user-defined error code
```

#### Exception codes raised by the runtime

| Code | Raised by |
|------|-----------|
| 1000 | `throw(msg)` |
| 1001 | A set element outside 0..63; `excmsg()` is `set element <n> is out of range 0..63` |
| 1002 | Integer `div` or `mod` by zero; `excmsg()` is `division by zero` |
| 1003 | `varargs.next` / `varargs.get` type mismatch |
| 1004 | `varargs.get` index out of range |
| 1005 | A string or array index outside its bounds, `debug` builds only; `excmsg()` is `index <i> is out of range <lo>..<hi>`. A debugging aid: never rely on catching it |
| 1100 | A failed assertion outside unit test mode; `excmsg()` is the failure text |

Codes 1000 to 1999 are reserved for the runtime and compiler. Pick `throwcode` values from 1 to 1073741823 outside that range when you need to tell your exceptions apart.

#### Exception intrinsics

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `exccode()` | `int32` | Error code of the current exception |
| `excmsg()` | `string` | Error message of the current exception |


<a id="language-reference-routines"></a>

### 🔧 8. Routines

*Declared with `routine`. No return type means procedure; with a return type, function.*

#### Procedures

```pxl
routine greet(const name: string);
begin
  println("Hello, %s!", cstr(name));
end;
```

#### Functions

```pxl
routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;
```

> [!IMPORTANT]
> **Semicolons separate parameters.** Parameters use `;` between groups, not commas. Use `return` to return a value.

#### Parameter modifiers

| Modifier | Behavior |
|----------|----------|
| *(none)* | Pass by value -- caller's value is copied |
| `const` | Immutable pass by value -- the routine cannot modify the copy |
| `var` | Pass by reference -- the routine modifies the caller's variable |

```pxl
routine swap(var a: int32; var b: int32);
var
  temp: int32;
begin
  temp := a;
  a := b;
  b := temp;
end;
```

> [!TIP]
> **Convention: `const` on every value parameter.** PIXELS convention is to mark every value parameter `const` unless `var` is needed. Bare (no modifier) is syntactically valid but `const` makes intent explicit.

#### Local declarations

Routines can contain their own `const`, `type`, and `var` sections in any order:

```pxl
routine compute(): int32;
const
  LOCAL_CONST: int32 = 10;
var
  x: int32;
begin
  x := LOCAL_CONST * 2;
  return x;
end;
```

#### Overloading

Routines with the same name but different parameter signatures are permitted unconditionally -- no opt-in required:

```pxl
routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

routine add(const a: float64; const b: float64): float64;
begin
  return a + b;
end;
```

Resolution prefers an exact non-variadic match; failing that, a variadic routine whose fixed parameters match. Each fixed argument must match its parameter type exactly; no implicit conversion is tried to find an overload. The signature is the parameter count, the parameter types, and the variadic marker; the parameter modifier (`const`, `var`) is not part of it, so two routines that differ only in modifiers are a duplicate-declaration error.

#### Forward declarations

Declare a routine's signature before its implementation:

```pxl
forward routine myFunc(const a: int32): int32;

// ... other code ...

routine myFunc(const a: int32): int32;
begin
  return a * 2;
end;
```

The full declaration must appear later in the same module and must match the forward exactly.

#### Variadic routines

A trailing `...` in the parameter list accepts extra arguments of any type. Access them through `varargs.*`, which is only valid inside a routine declared with `...`:

```pxl
routine sum(...): int32;
var
  total: int32;
begin
  total := 0;
  for i := 0 to varargs.count - 1 do
    total += varargs.next(int32);
  end;
  return total;
end;

// sum(1, 2, 3) returns 6
```

| Access | Description |
|--------|-------------|
| `varargs.count` | Number of extra arguments (`int32`) |
| `varargs.next(T)` | Consume and return the next argument as type `T` |
| `varargs.get(i, T)` | Return argument at index `i` as type `T` (no advance) |
| `varargs.reset()` | Reset the cursor to the first argument |
| `varargs.copy()` | Return an independent copy of the pack |

> [!WARNING]
> **Type-checked at runtime.** `next(T)` and `get(i, T)` verify the stored type matches `T`. A mismatch raises a runtime exception (code 1003 for type, 1004 for index).


<a id="language-reference-type-declarations"></a>

### 🔠 9. Type Declarations

*Aliases, pointers, records, choices, overlays, arrays, sets, and routine types.*

#### Type aliases

```pxl
type
  Age = int32;
  Meters = float64;
```

#### Pointer types

```pxl
type
  IntPtr = ptr to int32;
  ConstPtr = ptr to const int32;
```

`^` can be written in place of the word `ptr`, but `to` is still required: `^ to T` means `ptr to T`. A bare `^T` is not a pointer type and is a parse error.

```pxl
type
  IntPtr2 = ^ to int32;        // same as ptr to int32
```

A `ptr` (or `^`) with no `to` target type is an untyped pointer (equivalent to the built-in `ptr` type). Use `address of expr` to take an address and `p^` to dereference.

#### Record types

Records group named fields into a single value:

```pxl
type
  Point = record
    x: int32;
    y: int32;
  end;
```

Records support **single inheritance**, **packed layout**, **alignment control**, and **bit fields**:

```pxl
type
  // Inheritance -- Point3D extends Point
  Point3D = record(Point)
    z: int32;
  end;

  // Packed record -- no padding between fields
  PackedHeader = record packed
    tag: uint8;
    len: uint16;
  end;

  // Alignment -- 16-byte aligned
  AlignedBlock = record align(16)
    data: int64;
  end;

  // Bit fields -- width in bits after the colon
  BitPack = record
    a: uint32 : 4;
    b: uint32 : 4;
    c: uint32 : 8;
  end;
```

> [!NOTE]
> **Record literals.** Construct a value inline: `Point(x: 10, y: 20)`. See [Literals](#language-reference).

#### Choices (enumerations)

`choices` defines a set of named `int32` constants:

```pxl
type
  Color = choices(red, green, blue = 5, alpha);
  Dir = choices(north, east, south, west);
```

Values are assigned sequentially starting from 0. An explicit `= N` sets the value and subsequent entries continue from `N + 1`. In the example above, `red = 0`, `green = 1`, `blue = 5`, `alpha = 6`. An explicit value must be a constant integer expression (literals, integer constants, and integer operators).

#### Overlay types (unions)

`overlay` shares memory between fields -- all fields occupy the same address:

```pxl
type
  Value = overlay
    asInt: int64;
    asFloat: float64;
  end;
```

Anonymous overlays can nest inside records, and anonymous records inside overlays:

```pxl
type
  Tagged = record
    tag: int32;
    overlay
      iVal: int64;
      fVal: float64;
    end;
  end;
```

#### Array types

Static arrays have fixed bounds; dynamic arrays are resizable:

```pxl
type
  Matrix = array[0..3] of array[0..3] of float64;   // static 4x4
  IntList = array of int32;                          // dynamic
```

A static array indexes from its declared low bound (`array[1..3] of int32` takes `1`, `2` and `3`); a dynamic array indexes from 0. A `debug` build raises exception 1005 for an index outside the bounds; `release` and `distro` builds do not check it. Indexing a `ptr to T` gives element `i` of type `T` (address + i * size of `T`) and is never checked; indexing an untyped pointer or any other non-indexable value is error SEM003.

Use `setlength(arr, n)` to resize a dynamic array and `len(arr)` to query its length. See [Memory](#memory-data-structures) for details.

#### Set types

Bounded bitsets supporting membership, union, intersection, and difference:

```pxl
var s: set;
s := [1, 3..7, 10];
if 5 in s then
  println("five is in the set");
end;

var a: set;
var b: set;
a := [1, 2, 3];
b := [3, 4, 5];
println("union has 1: %d", int32(1 in (a + b)));    // union
println("isect has 3: %d", int32(3 in (a * b)));    // intersection
println("diff has 1: %d", int32(1 in (a - b)));     // difference
```

Sets support `+` (union), `*` (intersection), `-` (difference), `=` (equality), `<>` (inequality), and `in` (membership). Elements are limited to 0..63; adding an element outside that range raises exception code 1001, while `in` with an out-of-range value simply returns `false`.

#### Routine types

Function and procedure types for callbacks:

```pxl
type
  MathFunc = routine(const x: float64): float64;
  Callback = routine(const a: int32; const b: int32): int32;
  Action = routine();
```

A routine-typed variable holds a reference to a routine. A `nil` value means "no routine".

#### Forward types

Declare a type name before its full definition, typically so a pointer type can refer to a record that is defined later:

```pxl
forward type Node;

type
  NodePtr = ptr to Node;

type
  Node = record
    value: int32;
    next: NodePtr;
  end;
```

The full definition must appear later in the same module.


<a id="language-reference-type-casts"></a>

### 🔤 10. Type Casts

*Explicit conversions use the target primitive as a function call.*

```pxl
var x: int64 = 12345;
var y: int32 = int32(x);         // narrow cast
var f: float64 = 3.14;
var i: int32 = int32(f);         // float to int (truncates)
var g: float64 = float64(y);     // int to float
```

Only built-in type keywords can be used as cast operators (`int32(x)`, `float64(n)`). A user-defined type name followed by parentheses is a call or record literal, not a cast.

#### Automatic type promotion

When mixing types in expressions, the compiler promotes to the wider type:

| Expression | Result type |
|------------|-------------|
| integer + float | float (integer promoted) |
| smaller int + larger int | larger int |
| `float32` + `float64` | `float64` |
| `and`, `or`, `xor`, `not` on `bool` | `bool` |
| `and`, `or`, `xor` on integers | the promoted integer type (bitwise) |
| `not` on an integer | the operand's type (bitwise) |
| comparisons (`=`, `<>`, `<`, etc.) | `bool` |
| `string` + `string` | `string` (concatenation) |

#### Implicit conversions

A value is used where another type is expected (assignment, initializer, argument, `return`, record literal field, comparison) only when the table allows it; anything else is a located SEM003 and needs an explicit cast.

| Expected type | Accepts without a cast |
|---------------|------------------------|
| integer, float | numbers by widening (narrowing needs a cast), a choices value |
| choices | the same or another choices type, an `int8`..`uint32` value |
| `bool`, `char`, `wchar` | the same type only (`int32(c)`, `char(n)`, `bool(n)` cross) |
| `string`, `wstring` | `string`, `wstring`, `nil` (empty), `ptr to char` (copied into a new string) |
| `ptr` | any pointer, `nil` (not a string) |
| `ptr to T` | `ptr to T`, `ptr` (untyped), `nil`; `ptr to const T` also takes `ptr to T`; `ptr to char` takes a `string` (borrowed: outside an argument it must be a variable, field, param, const or literal, not a temporary) |
| dynamic array | the same array type, `nil` |
| static array, set | a type of the same shape: same bounds and element type (a bare set is 0..63) |
| record, overlay | the same type only |
| routine type | a routine with the identical signature, `nil` |

`if`, `while` and `until` conditions must be `bool`. A comparison needs two numbers, or two values the table relates in either direction; `nil` compares only with a pointer, dynamic array, string or routine value. Records, overlays and static arrays never compare, not even with their own type (`=`, `<>`, the ordering operators, `match`, `asserteq`): compare their fields or elements.


<a id="language-reference-comments"></a>

### 💬 11. Comments

*Line comments and nestable block comments.*

```pxl
// This is a line comment

/* This is a block comment.
   Block comments can span multiple lines.
   /* They can also be nested. */
*/
```

> [!NOTE]
> **No Pascal-style comments.** The `{ }` and `(* *)` comment forms are not supported.


<a id="language-reference-intrinsics"></a>

### ⚡ 12. Intrinsics

*Ten value intrinsics plus statement-level and output built-ins, available without imports.*

#### Value intrinsics

| Intrinsic | Returns | Description |
|-----------|---------|-------------|
| `len(x)` | `int64` | Length of a `string` (bytes), `wstring` (UTF-16 units), or dynamic array (elements) |
| `size(T)` | `int64` | Byte size of a type name or expression, computed at compile time |
| `format(fmt, ...)` | `string` | Build a managed string from printf-style format and arguments |
| `utf8(s)` | `ptr` | Newly allocated NUL-terminated UTF-8 copy of a `string` or `wstring` (caller owns; release with `freemem`) |
| `cstr(s)` | `ptr` | Borrowed raw `char*` into a managed string's storage (do not free) |
| `wstr(s)` | `ptr` | Borrowed `wchar*` with runtime caching (do not free) |
| `paramcount()` | `int64` | Number of command-line arguments (excludes program name) |
| `paramstr(i)` | `string` | Command-line argument by index (0 = program name) |
| `exccode()` | `int32` | Error code of the current exception |
| `excmsg()` | `string` | Error message of the current exception |

`size` accepts a type name (`size(int32)`, `size(Point)`, `size(unitName.Type)`) or an expression. A structural type such as `ptr to int32` or `array of int32` cannot be written inside `size`; declare a named type for it first.

#### Statement-level intrinsics

| Intrinsic | Description |
|-----------|-------------|
| `new(p)` | Allocate and zero-initialize a typed pointer target |
| `dispose(p)` | Free a typed pointer target and set the pointer to nil |
| `getmem(p)` | Allocate and zero-fill memory for the pointer's target type |
| `freemem(p)` | Free raw memory |
| `resizemem(p, n)` | Resize raw memory |
| `setlength(arr, n)` | Resize a dynamic array |

#### Output intrinsics

| Intrinsic | Description |
|-----------|-------------|
| `print(fmt, ...)` | Printf-style formatted output, no newline |
| `println(fmt, ...)` | Printf-style formatted output with newline |

The format string must be a string literal (for `format`, anything else is a compile error); it is decoded at compile time. The same specifiers apply to `print`, `println`, and `format`:

| Specifier | Output |
|-----------|--------|
| `%d`, `%i` | Signed integer of any width |
| `%u` | Unsigned integer |
| `%x`, `%X` | Hexadecimal, lower or upper case |
| `%f`, `%.Nf` | Float, 6 decimals by default or `N` decimals: the correctly rounded decimal of the exact binary value (ties away from zero), at any precision and magnitude |
| `%e`, `%E`, `%g`, `%G` | Accepted, printed the same as `%f` |
| `%s` | A `string`, or a `ptr` to a NUL-terminated C string |
| `%c` | `char` |
| `%p` | Pointer, printed as `0x` + hex |
| `%%` | Literal percent sign |

Flags (`-`, `+`, space, `0`, `#`), a field width, and the length modifiers `l`/`h` are accepted and ignored, so `%lld` works and prints the same as `%d`.

The integer specifiers `%d`, `%i`, `%u`, `%x`, `%X`, `%c` and `%p` do not take a float: a `float32` or `float64` argument is a compile error (SEM003) at that argument. Use `%.0f`, or an explicit cast such as `int32(x)`. An integer argument to `%f` is fine (it widens).

Every argument must fit its specifier, else it is a compile error (SEM003) at that argument: `%d %i %u %x %X` take an integer (a `choices` value widens), `%f %e %E %g %G` a number, `%s` a `string` or a pointer to a C string (`ptr`, `ptr to char`), `%c` a `char`, `%p` a pointer; `nil` fits `%s` and `%p`. Cast to print a value as another class, for example `int32(c)` for the code of a `char`. Without a format string (`println(x)`), a `ptr to char` prints as text.

For `print` and `println`, a first argument that is a string literal is always a format string, so `println("100%%");` prints `100%`. Any other first argument prints with default formatting: `println(n)` or `println(s)` print the value. Every spec needs an argument and every argument a spec, for `format` too: a spec with no argument is error SEM009 at the call, an argument with no spec is error SEM009 at that argument. A `%` that starts no spec, such as a lone `%`, prints as it is.

> [!TIP]
> **`format` builds a string; `println` writes to the console.** Use `format` when you need the result as a value -- for concatenation, passing to a routine, or assigning to a variable. Example: `var msg: string = format("count: %d", n);`


<a id="language-reference-conditional-compilation"></a>

### 🔀 13. Conditional Compilation

*Compile-time symbol tests that control which code is included.*

Conditional directives are processed at the parser level and do **not** end with semicolons:

```pxl
@define MY_FEATURE

@ifdef MY_FEATURE
  println("feature enabled");
@endif

@ifndef SOME_FLAG
  println("flag not set");
@endif

@ifdef BUILD_EXE
  println("building an executable");
@elseif BUILD_LIB
  println("building a library");
@else
  println("building a unit");
@endif
```

| Directive | Purpose |
|-----------|---------|
| `@define SYMBOL` | Define a compilation symbol |
| `@undef SYMBOL` | Undefine a compilation symbol |
| `@ifdef SYMBOL` | Compile block if symbol is defined |
| `@ifndef SYMBOL` | Compile block if symbol is not defined |
| `@elseif SYMBOL` | Alternate branch with condition |
| `@else` | Alternate branch |
| `@endif` | End conditional block |

Conditional blocks can be nested, and they can appear anywhere: between declarations, between statements, or inside an expression. Symbol names are case-sensitive. A symbol defined with `@define` stays defined for every module parsed after it, including imported units.

Conditionals also work inside imported unit modules, and every predefined symbol is visible there: `BUILD_EXE` and `BUILD_LIB` name the kind of the program (the root module), not of the unit. `PIXELS` and `WASM64` are defined from the first line, so conditionals placed before the `module` line see them too.

#### Predefined symbols

| Symbol | Defined when |
|--------|-------------|
| `PIXELS` | Always, from the first line of every compile (also before the `module` line) |
| `WASM64` | Always (wasm64 architecture), like `PIXELS` |
| `BUILD_EXE` | The program (the root module) is an `exe`: from its `module` line on, in every module, units included |
| `BUILD_LIB` | The program (the root module) is a `lib`: from its `module` line on, in every module, units included |
| `UNITTESTMODE` | After `@unittestmode on;` in the `exe` module, from that line on (`@unittestmode off;` removes it) |

> [!NOTE]
> **No DEBUG or RELEASE symbols.** The build mode (`@buildmode` or `-bm`) does not define a symbol. Use `@define DEBUG` explicitly if you want conditional debug code. See [Diagnostics](#debugging) for the `@ifdef DEBUG` pattern.


<a id="language-reference-module-level-directives"></a>

### 📋 14. Module-Level Directives

*Brief reference -- full details in [Module System](#module-system).*

These directives configure the build and end with a semicolon:

| Directive | Value | Purpose |
|-----------|-------|---------|
| `@buildmode` | `debug\|release\|distro` | Build mode (`debug` = wasm-opt `-O0`, `release` and `distro` = `-O3`; `distro` also packages a zip). The `-bm` CLI flag overrides it |
| `@outputpath` | `"path"` | Output directory for intermediate files, a lib's `.wasm`, and the distro zip. The `-o` CLI flag overrides it |
| `@addlibrarypath` | `"path"` | Add a directory to the one search path for `import` (units) and `external` (JS/wasm libraries); program-wide, applied before the declaring module's own imports resolve |
| `@modulepath` | -- | Removed (error); use `@addlibrarypath` |
| `@unittestmode` | `on\|off` | Enable test block emission and the test runner |
| `@exeicon` | `"path.ico"` | Icon for the packaged executable in a `distro` build (win-x64) |
| `@vimajor` `@viminor` `@vipatch` | `0..65535` | Version number of the packaged executable in a `distro` build (win-x64); default `0.0.0` |
| `@viproductname` `@videscription` `@vifilename` `@vicompanyname` `@vicopyright` | `"text"` | Version info strings of the packaged executable in a `distro` build (win-x64); defaults: module name, module name, `<module>.exe`, empty, empty |
| `@assets` | `"srcdir" "vdir" ["pattern"]` | Map every file under `srcdir` matching `pattern` (default `*`), recursively; its key is `vdir/` + the path relative to `srcdir`. `exe` only. Served in place in debug/release, copied into the distro |
| `@asset` | -- | Removed (error); use `@assets` |
| `@message` | `hint\|warn\|error\|fatal "text"` | Emit a compiler diagnostic |

An unknown directive name is a compile error (there is no `@optimize` or `@favicon`). An invalid `@buildmode` value is an error; an invalid `@unittestmode` or `@message` value is a warning. In a `unit` module only `@addlibrarypath` and `@message` take effect; any other directive there is an error (CMP004).

Of these, only `@message` may also appear inside a routine body or the main body; any other directive there is error PAR009 at the directive.

#### Path prefixes

| Prefix | Base directory |
|--------|---------------|
| `$P:` | Compiler executable directory |
| `$D:` | Current working directory |
| `$S:` | Same as no prefix (the current working directory); the explicit spelling of the default |

A path with no prefix resolves against the current working directory of the compiler, so a module meant to be compiled from any folder uses `$P:` or an absolute path.


<a id="language-reference-testing"></a>

### 🧪 15. Testing

*Built-in test runner with eight non-aborting assertions.*

Enable testing with `@unittestmode on;` in an `exe` module and place test blocks after the module's `end.`. The module still needs its normal `begin ... end.` main body (an `exe` without one does not compile), because the test runner is started from the program entry point:

```pxl
module exe mathlib;

@unittestmode on;

routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

begin
  println("add(2, 3) = %d", add(2, 3));  // skipped while @unittestmode is on
end.

test "add returns correct sum"
var
  result: int32;
begin
  result := add(2, 3);
  asserteq(5, result);
end;

test "add handles negative numbers"
begin
  asserteq(-2, add(-5, 3));
  asserteq(-8, add(-5, -3));
end;
```

When `@unittestmode` is on, the program runs `initialize` sections, then the test runner instead of the main body. Each test runs independently; failures accumulate and the runner prints a `[PASS]`/`[FAIL]` line per test and a `=== Results: P passed, F failed, T total ===` summary. With `@unittestmode off` (the default) test blocks are still parsed and checked, but not compiled into the program. Tests in `lib` and `unit` modules never run. The process exit code is 1 when any test fails and 0 otherwise, on both hosts; a program with no test blocks prints `No tests registered.` and exits 0.

The test name is optional (`test begin ... end;` is valid), and the `;` after the block is optional.

#### Assertion reference

| Assertion | Purpose |
|-----------|---------|
| `assert(expr [, "msg"])` | Fail if `expr` is false |
| `asserttrue(expr [, "msg"])` | Fail if not true |
| `assertfalse(expr [, "msg"])` | Fail if not false |
| `asserteq(expected, actual [, "msg"])` | Fail if values are not equal. Takes the pairs `=` takes: two numbers compare at the wider type, any other pair must be one `=` can compare (SEM003 otherwise). Type-dispatched on `expected`: string, wstring, float, bool, char, wchar, unsigned, pointer, or integer |
| `asserteqf(expected, actual, epsilon [, "msg"])` | Float equality within tolerance (all operands must be numbers; converted to `float64`) |
| `assertnil(expr [, "msg"])` | Fail if not nil |
| `assertnotnil(expr [, "msg"])` | Fail if nil |
| `assertfail(["msg"])` | Unconditional failure, with an optional message |

`assert`, `asserttrue` and `assertfalse` take a `bool`; `assertnil` and `assertnotnil` take a pointer, dynamic array, string or routine value. A message is a `string`, printed after the failure as ` (msg)`. A wrong number of arguments is error SEM009; an argument of the wrong kind is error SEM003 at that argument.

Outside unit test mode (`@unittestmode off`), a failed assertion raises exception 1100 whose message is the failure text: `guard ... except` can catch it, and uncaught it ends the program with exit code 1.

> [!TIP]
> **Test blocks can include `var` sections** for local variables. The compiler injects source file and line number into failure messages automatically.

Next: [Module System](#module-system)

---

<p align="right"><a href="#language-reference">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="module-system"></a>

## 📦 Module System

> **Structure larger PIXELS projects**  
> Choose what a source file produces, control visibility, import dependencies, and manage lifecycle hooks.


*Every source file is a module. The module kind decides what the compiler produces -- a desktop app packaged for Electron, a wasm library that links into a PIXELS exe, or inline code folded into the importer. One declaration, one rule for visibility, one rule for naming, and the rest follows.*

PIXELS compiles one `.pxl` file at a time. The first line declares the module kind and name, and that single decision controls everything downstream: what the output artifact is, whether a main body is allowed, and which symbols other modules can see. Imports are explicit, qualification is mandatory, and every module can define startup and shutdown logic that the runtime wires into the correct order automatically.

> [!TIP]
> **Where to look next.** For the language constructs available inside a module see [Language Reference](#language-reference). For calling JavaScript or linking external wasm libraries see [JS Interop](#js-interop). For heap allocation, strings, and dynamic arrays see [Memory](#memory-data-structures).


<details>
<summary><strong>Jump to a topic</strong></summary>

- [📝 1. Module Kinds](#module-system-module-kinds)
- [📥 2. Imports](#module-system-imports)
- [🔒 3. Visibility](#module-system-visibility)
- [🚀 4. Initialize and Finalize](#module-system-initialize-and-finalize)
- [🔀 5. Directives](#module-system-directives)
- [🧪 6. Unit Testing](#module-system-unit-testing)
- [🏗️ 7. Module Structure Summary](#module-system-module-structure-summary)

</details>

<a id="module-system-module-kinds"></a>

### 📝 1. Module Kinds

*Three kinds, three outputs -- pick the one that matches what you are shipping.*

Every `.pxl` file starts with a module declaration:

```pxl
module <kind> <name>;
```

The name must match the source filename without extension (case-insensitive). A file named `demo.pxl` declares `module exe demo;`.

| Kind | Output | Main body | Description |
|------|--------|-----------|-------------|
| `exe` | `app.asar` (Electron app) | `begin...end.` | Desktop program: the wasm64 binary, the JS runtime, and every JS library packed into an Electron app. `-bm distro` also produces a shippable `<name>-<arch>.zip`. |
| `lib` | `.wat` + `.wasm` | `end.` | wasm64 library that links into a PIXELS exe (like a C `.lib`). Public routines and variables exported under mangled names. Consumed via `external`. |
| `unit` | None (inline) | `end.` | Code incorporated directly into the importing module. Compiling a unit on its own only validates it. |

> [!NOTE]
> **Exe is an Electron app.** The build packs `package.json`, `main.js`, `preload.js`, `index.html`, `output.js` (runtime plus JS libraries) and `output.wasm` into `app.asar`, and writes it into the bundled Electron runtime at `bin\res\electron\<arch>\resources\app.asar`. Assets are not in the archive: debug and release serve them in place from their source files, a distro build copies them into the zip at `resources\__assets\`. Debug and release builds overwrite the shared Electron runtime folder on every build; only a distro build writes a shippable zip to the output directory.

#### Exe module

An exe module is a standalone program. It has a `begin...end.` main body that serves as the entry point:

```pxl
// hello.pxl -- from examples/hello.pxl
module exe hello;

@exeicon "$P:res/assets/icons/pixels.ico";

begin
  println("Hello, I am %s! 🚀🔥✨", "PIXELS");
  
  var i: int32 = 0;
  var s: string = "PIXELS™ " + "Game Toolkit";
  
  println(s);
  
  for i := 1 to 10 do
    println("%d", i);
  end
end.
```

An exe module must have a main body and a unit module must not (error `SEM007`). Compiling `hello.pxl` builds the Electron app for module `hello`; add `-r` to launch it.

#### Unit module

A unit module contains reusable declarations -- routines, types, constants, variables -- that other modules import. Units are compiled inline: their code is emitted into the importing module's wasm output.

```pxl
// bnf_unit_compliance.pxl (trimmed) -- from tests/compliance/bnf_unit_compliance.pxl
module unit bnf_unit_compliance;

public const
  UNIT_VERSION: int32 = 1;

public type
  UnitPoint = record
    x: int32;
    y: int32;
  end;

public var
  unit_global_x: int32 = 0;
  unit_global_flag: bool = false;

public routine unit_add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

initialize
  unit_global_x := 1;
  unit_global_flag := true;
end;

finalize
  unit_global_x := 0;
  unit_global_flag := false;
end;

end.
```

A unit has no main body -- it ends with `end.` after the optional `initialize`/`finalize` blocks.

#### Lib module

A lib module produces a `.wasm` library that a PIXELS `exe` links in:

```pxl
// mathlib -- a lib module
module lib mathlib;

@outputpath "$P:res/tests/libs";

public routine Add(const a: int64; const b: int64): int64;
begin
  return a + b;
end;

routine Mul(const a: int64; const b: int64): int64;
begin
  return a * b;
end;

end.
```

`Add` is exported as `mathlib.Add__int64_int64`. `Mul` is private -- compiled but not exported. The build writes `mathlib.wat` and `mathlib.wasm` into the output directory. A lib build has no JS runtime, no Electron app and no assets: its memory and runtime routines are imported from the exe that links it.

> [!IMPORTANT]
> **Lib export rules.** `public` routines are exported under their mangled name `<lib>.<Name>__<param kinds>`, so overloads are exported too; a consumer's `external` declaration selects one by its own parameter list. `public` variables are exported as `<lib>.<name>`. Constants and types have no binary form and are not exported: a consumer redeclares them. A lib is reached only through `external`; importing a lib is error CMP006.

For how another program consumes a `.wasm` lib, see [JS Interop](#js-interop).


<a id="module-system-imports"></a>

### 📥 2. Imports

*Import a module, qualify every use -- no shortcuts, no ambiguity.*

```pxl
import bnf_unit_compliance;
```

Multiple modules may be imported in one statement or in separate statements. Imports appear after the module header and may also appear among declarations:

```pxl
// bnf_exe_compliance.pxl (trimmed) -- from tests/compliance/bnf_exe_compliance.pxl
module exe bnf_exe_compliance;

import bnf_unit_compliance;

const
  MAX: int32 = 100;

// ...

begin
  println("bnf_unit_compliance.UNIT_VERSION = %d", bnf_unit_compliance.UNIT_VERSION);
  println("bnf_unit_compliance.unit_add(3, 4) = %d", bnf_unit_compliance.unit_add(3, 4));
end.
```

Every imported symbol must be fully qualified with the module name. `bnf_unit_compliance.unit_add(3, 4)` is correct; bare `unit_add(3, 4)` is a compile error. This applies to routines, types, constants, and variables alike.

> [!NOTE]
> **No unqualified imports.** There is no `use` or `from X import Y` syntax. You always write `module.symbol`. This keeps the origin of every reference immediately visible in the source.

#### Module search paths

The compiler resolves imports by searching for a `.pxl` file in this order:

1. Directory of the importing module's source file
2. Built-in standard library: `$P:res/libs/std`
3. Built-in vendor libraries: each subfolder of `$P:res/libs/vendor`
4. Paths added via `@addlibrarypath "path";` directives, in the order they are added

The std and vendor folders are added before any source is parsed. A module's `@addlibrarypath` entries, wherever they stand in the module, are added right before that module's own imports are resolved, so a module can import a unit from a directory it adds itself. The list is program-wide: an entry added by one module also serves every import resolved after it. The same list serves `external` libraries. A missing unit is error `CMP003` ("Imported unit not found"). `@modulepath` is removed (error CMP001).

Diamond imports (A imports B and C, both of which import D) are handled by an internal cache -- the unit is parsed and analyzed once and reused. A unit import cycle (A imports B, B imports A) is error `CMP011` at the `import` that closes the cycle.


<a id="module-system-visibility"></a>

### 🔒 3. Visibility

*Private by default. Say `public` to export.*

All declarations are private unless marked `public`. The `public` keyword works on constants, types, variables, and routines:

```pxl
public const
  UNIT_VERSION: int32 = 1;

public type
  UnitPoint = record x: int32; y: int32; end;

public var
  unit_global_x: int32;

public routine unit_add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;
```

`public` marks a module's intended API, and it is what a lib module exports. An importer reaches only `public` members; any other is error SEM010 at the access.


<a id="module-system-initialize-and-finalize"></a>

### 🚀 4. Initialize and Finalize

*Startup and shutdown hooks, wired in dependency order.*

Any module kind can declare `initialize` and `finalize` blocks:

```pxl
initialize
  unit_global_x := 1;
  unit_global_flag := true;
  private_counter := 0;
end;

finalize
  unit_global_x := 0;
  unit_global_flag := false;
end;
```

Both blocks are optional. They run as part of an exe program's `_start` and `_shutdown` exports. A lib module's blocks run from the exe that links it: the exe calls the lib's startup (its data, constants, globals, then its units' and its own `initialize` blocks) and, at shutdown, the lib's teardown (`finalize` blocks, then its global cleanup).

**Startup order (`_start`):** every linked PIXELS lib's startup, dependencies first (a lib whose startup fails ends `_start`) -> constant initializers (imported units, then the exe) -> heap-backed globals allocated (imported units, then the exe) -> each imported unit, dependency-first: its `var` initializers, then its `initialize` -> the exe module's `var` initializers -> this module's `initialize` -> main body (exe only). A unit reached only through another unit is included, and every unit is initialized once, before the units that import it.

**Shutdown order (`_shutdown`):** the `app.Run` shutdown handler, if one was given -> this module's `finalize` -> unit `finalize` blocks in reverse initialization order -> global cleanup, the exact reverse of allocation (the exe, then the units in reverse order) -> every linked PIXELS lib's teardown in reverse link order, for each lib whose startup began -> the last exception message released -> heap leak report (debug builds only).

This is the standard Pascal/Delphi pattern: units initialize in dependency order, finalize in reverse.

> [!TIP]
> **Use `initialize` for one-time setup** -- allocating resources, registering callbacks, setting initial state. **Use `finalize` for cleanup** -- freeing memory, zeroing handles.


<a id="module-system-directives"></a>

### 🔀 5. Directives

*Fifteen module-level directives configure the build (two older names, `@modulepath` and `@asset`, are removed). Seven conditional-compilation directives gate code at parse time.*

#### Module-level directives

These appear after the module header, before or among declarations. Each is terminated by `;`. An unknown directive name is error `CMP001`.

| Directive | Arguments | Effect |
|-----------|-----------|--------|
| `@outputpath "path";` | Quoted string | Sets the output directory: a lib's `.wat`/`.wasm`, the distro zip, and build temporaries. The CLI `-o` flag overrides it |
| `@addlibrarypath "path";` | Quoted string | Adds a directory to the one search path for `import` (units, see Module search paths) and `external` (JS/wasm libraries) |
| `@modulepath ...` | -- | Removed; error CMP001. Use `@addlibrarypath` |
| `@buildmode debug|release|distro;` | Bare identifier | Sets the build mode: `debug` (the default, wasm-opt `-O0`), `release` (`-O3`, minified JS), `distro` (release plus a zip). Any other value is an error. The CLI `-bm` flag overrides it |
| `@unittestmode on|off;` | Bare identifier | Enables or disables test block emission and the test runner |
| `@exeicon "path.ico";` | Quoted string | Sets the icon patched into the distro executable (win-x64 distro builds only) |
| `@vimajor 1;` `@viminor 0;` `@vipatch 0;` | Whole number 0..65535 | Sets the version number stamped into the distro executable (win-x64 distro builds only). Default `0.0.0`. Any other value is an error |
| `@viproductname "text";` `@videscription "text";` `@vifilename "text";` `@vicompanyname "text";` `@vicopyright "text";` | Quoted string | Sets a version info string of the distro executable (win-x64 distro builds only). Defaults: module name, module name, `<module>.exe`, empty, empty |
| `@assets "source" "virtual_path" ["pattern"];` | Two or three quoted strings | Maps every file under `source` matching the pattern (default `*`, recursive) to the key `virtual_path/<path relative to source>`. `exe` only |
| `@asset ...` | -- | Removed; error CMP001. Use `@assets` |
| `@message hint|warn|error|fatal "text";` | Severity + text | Emits a compiler diagnostic at the directive's source location |

Debug and release builds serve assets in place from their source files (zero copy); a distro build copies them to `resources\__assets\<key>` beside `app.asar`. Assets are never packed into `app.asar`. A duplicate key keeps its first mapping (a different file under the same key gives one warning).

> [!NOTE]
> **Directives in units.** Only `@addlibrarypath` and `@message` take effect in imported unit modules. Any other directive in a unit is error CMP004 -- they are a property of the root module.

#### Path prefixes

Every directive taking a `"path"` resolves a relative path against the current working directory of the `pixels` process, not the declaring module's directory. An optional prefix overrides the base:

| Prefix | Base directory | Typical use |
|--------|---------------|-------------|
| `$P:` | Compiler executable directory | Shipped assets under the compiler's `res` tree |
| `$D:` | Current working directory | Paths relative to where the compiler was invoked |
| `$S:` | Same as no prefix (the current working directory) | Explicit spelling of the default |

```pxl
@addlibrarypath "$P:res/tests/libs";
@exeicon "$P:res/assets/icons/pixels.ico";
@assets "$P:res/assets/images" "assets/images" "pixels.png";
```

> [!NOTE]
> A relative or `$S:` path depends on where `pixels` was started, so the same module resolves it differently from another folder. `bin\run-pixels.cmd` runs from `bin\`.

> [!TIP]
> **Use `$P:` for portable modules.** A vendor binding that uses a bare relative path breaks as soon as the compiler is started from another folder. The `$P:` form always resolves against the compiler's own directory.

#### Conditional compilation directives

These take no terminator (no `;`) and may appear at module level or inside statements. They are evaluated at parse time.

| Directive | Purpose |
|-----------|---------|
| `@define <ident>` | Define a symbol |
| `@undef <ident>` | Undefine a symbol |
| `@ifdef <ident>` | Compile the following block if the symbol is defined |
| `@ifndef <ident>` | Compile the following block if the symbol is not defined |
| `@elseif <ident>` | Else-if: compile if this symbol is defined instead |
| `@else` | Else branch |
| `@endif` | End the conditional block |

```pxl
@define UNIT_FEATURE_A

@ifdef UNIT_FEATURE_A
// This section compiles because UNIT_FEATURE_A is defined
@endif

@ifndef UNIT_FEATURE_B
// This section compiles because UNIT_FEATURE_B is not defined
@endif
```

Conditional directives work inside imported units too. Units are parsed after the root module and share its defines.

#### Predefined symbols

| Symbol | Defined when |
|--------|-------------|
| `PIXELS` | Always, from the first line of every compile (also before the `module` line) |
| `WASM64` | Always (wasm64 architecture), like `PIXELS` |
| `BUILD_EXE` | The program (the root module) is an `exe`: from its `module` line on, in every module, units included |
| `BUILD_LIB` | The program (the root module) is a `lib`: from its `module` line on, in every module, units included |
| `UNITTESTMODE` | After `@unittestmode on;` in the `exe` module, from that line on (`@unittestmode off;` removes it) |


<a id="module-system-unit-testing"></a>

### 🧪 6. Unit Testing

*Test blocks after `end.`, a dedicated runner, eight assertion functions -- built into the language.*

When `@unittestmode on;` is set in an exe module, test blocks after the module's `end.` terminator are emitted and the test runner replaces the normal entry point. The `begin...end.` main body is not executed, but it must still be present. `@unittestmode` is allowed only in an exe module: in a unit or lib module it is error CMP004 at the directive line.

```pxl
// bnf_unittest_compliance.pxl (trimmed) -- from tests/compliance/bnf_unittest_compliance.pxl
module exe bnf_unittest_compliance;

@unittestmode on;

type
  TPoint = record
    x: int32;
    y: int32;
  end;

var
  init_count: int32;

routine make_point(const ax: int32; const ay: int32): TPoint;
var
  p: TPoint;
begin
  p.x := ax;
  p.y := ay;
  return p;
end;

initialize
  init_count := init_count + 1;
end;

begin
  // Replaced by the test runner when @unittestmode is on. Reaching this
  // would be a failure.
  println("MAIN BLOCK MUST NOT RUN IN UNIT TEST MODE");
  asserteq(0, 1, "main block executed in unit test mode");
end.

test "test-local variables"
var
  p: TPoint;
  total: int32;
  i: int32;
begin
  p := make_point(3, 4);
  asserteq(3, p.x);
  asserteq(4, p.y);
  total := 0;
  for i := 1 to 10 do
    total := total + i;
  end;
  asserteq(55, total, "loop inside a test block");
end;

test "initialize ran before tests"
begin
  asserteq(1, init_count, "initialize section runs once before the runner");
end;
```

Each test block has an optional string name, optional local `var` declarations, and a body containing assertions.

#### Assertions

| Function | Purpose |
|----------|---------|
| `assert(expr [, msg])` | Fail if `expr` is false |
| `asserttrue(expr [, msg])` | Fail if not true |
| `assertfalse(expr [, msg])` | Fail if not false |
| `asserteq(expected, actual [, msg])` | Fail if not equal (type-dispatched; takes the pairs `=` takes) |
| `asserteqf(expected, actual, epsilon [, msg])` | Float equality within tolerance |
| `assertnil(expr [, msg])` | Fail if not nil |
| `assertnotnil(expr [, msg])` | Fail if nil |
| `assertfail([msg])` | Unconditional failure |

In unit test mode all assertions are non-aborting. A failed assertion records the failure but continues executing the test. The runner prints `[PASS]` or `[FAIL]` per test (with the recorded failures after `[FAIL]`) and ends with `=== Results: P passed, F failed, T total ===`. Outside unit test mode, a failed assertion raises exception 1100 whose message is the failure text; it can be caught with `guard ... except` (`exccode()` = 1100). Uncaught, it is reported on stderr and the program exits with code 1.

> [!NOTE]
> **Initialize and finalize still run.** When unit test mode is on, `initialize` runs before the first test and `finalize` runs after the last. This lets you set up and tear down shared state for the test suite.


<a id="module-system-module-structure-summary"></a>

### 🏗️ 7. Module Structure Summary

*The complete skeleton, with every optional section in place.*

```pxl
module <kind> <name>;

// directives (optional, in any order, may repeat among declarations)
@buildmode release;
@addlibrarypath "$P:res/tests/libs";
@unittestmode on;

// imports (optional, may also appear among declarations)
import other_unit;

// declarations: const, type, var, routine -- in any order, repeatable
const
  VERSION: int32 = 1;

type
  MyRecord = record x: int32; y: int32; end;

var
  counter: int32;

routine do_work(): int32;
begin
  return counter + 1;
end;

// lifecycle (optional; run by the exe's startup and shutdown)
initialize
  counter := 0;
end;

finalize
  counter := 0;
end;

// main body (exe only) or module terminator
begin        // exe: entry point
  // ...
end.

// -- OR for lib/unit: --
end.

// test blocks (always parsed and checked; run only in an exe with @unittestmode on)
test "example"
begin
  asserteq(1, do_work());
end;
```

> [!NOTE]
> **`end.` with a period** marks the end of the module proper. Everything after it is test blocks. They are always parsed and semantically checked, but emitted and run only when `@unittestmode on;` is active in an exe module.

---

<p align="right"><a href="#module-system">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="js-interop"></a>

## 🔗 5. JavaScript Interop

> **Bridge wasm to the desktop**  
> Connect PIXELS code to JavaScript host APIs and reusable WebAssembly libraries.


*The wasm module computes; the Electron page does everything else.*

PIXELS programs run as WebAssembly inside an Electron window, a Chromium page with Node.js integration. Every capability the page provides -- graphics, audio, input, storage -- reaches PIXELS through JavaScript host functions declared with the `external` clause. This section covers how those declarations work, how the build pipeline resolves them, and how to write your own JS and wasm libraries.

Here is the simplest possible JS interop -- two routines imported from a `.js` file and a `.wasm` module, called from `begin..end.`:

```pxl
// JS and wasm external library example (libraries in res/tests/libs)
module exe probe_extlibs;

@addlibrarypath "$P:res/tests/libs";

// JS external -- resolved from mathjs.js in libs/
routine JsAdd(const a: int32; const b: int32): int32;
  external "mathjs" name "JsAdd";

// Wasm external -- resolved from mathlib.wasm in libs/
routine Add(const a: int64; const b: int64): int64;
  external "mathlib" name "Add";

var
  r: int64;
begin
  println("JsAdd(2, 3) = %d", JsAdd(2, 3));
  r := Add(10, 20);
  println("Add(10, 20) = %d", r);
end.
```

The JS file that satisfies `"mathjs"`:

```javascript
// mathjs.js -- JS host functions for "mathjs" import module
// Exposed to wasm as (import "mathjs" "JsAdd" ...)
var mathjs = {
  JsAdd: function(a, b) { return a + b; },
  JsMul: function(a, b) { return a * b; }
};
```

The `.wasm` file that satisfies `"mathlib"` is a foreign wasm module: it exports `Add` under that exact name and has its own memory (a PIXELS `lib` build links differently, see PIXELS Lib Modules below). Its text form:

```wat
;; mathlib.wat (assembled to mathlib.wasm by wasm-opt)
(module
  (memory $mem i64 1)
  (export "memory" (memory $mem))

  (func $mathlib.Add__int64_int64 (param $a i64) (param $b i64) (result i64)
    (local $_ret i64)
    (block $_exit
    (local.set $_ret (i64.add (local.get $a) (local.get $b)))
    br $_exit
    )
    (local.get $_ret)
  )

  (func $mathlib.Mul__int64_int64 (param $a i64) (param $b i64) (result i64)
    (local $_ret i64)
    (block $_exit
    (local.set $_ret (i64.mul (local.get $a) (local.get $b)))
    br $_exit
    )
    (local.get $_ret)
  )

  (export "Add" (func $mathlib.Add__int64_int64))

)
```

Build and run with `pixels <source> -r`. The JS lib is bundled into `output.js` inside the app's `app.asar`; the wasm lib is merged into the program binary. Both resolve at build time, not at runtime.

> [!NOTE]
> **Two kinds of external library.** A `.js` file becomes a wasm host import -- its functions are called from wasm through the import object passed to `WebAssembly.instantiate`. A `.wasm` file is merged into the program module by wasm-merge, so its exports become local functions in the final binary. The external clause is the same for both; the file found on disk determines the pipeline. A `.wasm` built from a PIXELS `lib` module is recognised by its `pxl@abi1` export and bound by signature (see [PIXELS Lib Modules](#js-interop-pixels-lib-modules)).


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🔌 The External Clause](#js-interop-the-external-clause)
- [📂 Library File Resolution](#js-interop-library-file-resolution)
- [✍️ Writing a JS Library](#js-interop-writing-a-js-library)
- [🔢 Marshalling Contract](#js-interop-marshalling-contract)
- [🌐 The PXL Shared Object](#js-interop-the-pxl-shared-object)
- [📦 Wasm Library Authoring](#js-interop-wasm-library-authoring)
- [🏗️ PIXELS Lib Modules](#js-interop-pixels-lib-modules)
- [📋 Build Pipeline Summary](#js-interop-build-pipeline-summary)

</details>

<a id="js-interop-the-external-clause"></a>

### 🔌 The External Clause

The `external` clause declares a routine whose implementation lives outside the PIXELS module -- in a JS file or a pre-compiled wasm module.

```
ExternalClause = "external" [ cstring | ident ] [ "name" cstring ] ";" .
```

| Part | Purpose |
|------|---------|
| `external` | Marks the routine as an import (no body generated) |
| `"mathjs"` | Library name (required) -- the file name without extension, and the wasm import module name |
| `name "JsAdd"` | Import function name (required) |

The grammar makes both parts optional, but the compiler requires them: an external routine or variable with no library name or no `name` symbol is error `SEM008`. Give the library name without an extension; the compiler appends `.wasm` and `.js` itself.

The library name after `external`, and the symbol after `name`, can each be a string literal or an identifier that names a string constant (declared directly or through another constant); the constant's value is used:

```pxl
const LIB_MATH = "mathjs";

routine JsAdd(const a: int32; const b: int32): int32;
  external LIB_MATH name "JsAdd";   // same as external "mathjs"
```

An undeclared identifier is error SEM001 and one that is not a string constant is error SEM008, both at the identifier. Only a plain identifier is accepted, not a unit-qualified `unit.NAME`.

#### External Variables

The grammar also supports external variable declarations:

```
VarDecl = ident ":" TypeExpr [ "=" Expression ] [ ExternalVarClause ] ";" .
ExternalVarClause = "external" [ cstring | ident ] [ "name" cstring ] .
```

As with routines, both the library name and the `name` symbol are required (`SEM008`). The emitter produces a wasm global import: `(import "lib" "sym" (global $name (mut type)))`.


<a id="js-interop-library-file-resolution"></a>

### 📂 Library File Resolution

When the compiler encounters an `external` clause, it resolves the library name to a file on disk. The search order:

1. The directory of the declaring module
2. Each `@addlibrarypath` directory, in declaration order

At each location the compiler tries `.wasm` first, then `.js`. The first match wins. Each library name is resolved once for the whole program. If nothing is found the build stops with `CMP003` ("External library not found ... (searched .wasm and .js)"). The name `wasi_snapshot_preview1` is never searched; the runtime provides it.

| File found | Pipeline |
|------------|----------|
| `.js` | Added to the JS bundle after `runtime.js` (wrapped to an IIFE by esbuild first if it is a CommonJS/ES module), passed through esbuild (minified in release/distro), and written as `output.js` inside `app.asar` |
| `.wasm` | Read for its imports and exports, then merged into the program binary by wasm-merge (exe builds). A PIXELS lib is linked by signature together with its dependencies; any other module as it is |

This is how the std units find their shims: `canvas2d.pxl` declares `external "canvas2d"`, and `canvas2d.js` sits in the same `res/libs/std` folder.

> [!TIP]
> **Wrap externals in a unit module.** Instead of declaring externals and `@addlibrarypath` in every consumer, put them in a `module unit` and let consumers `import` it. The unit owns the library resolution; consumers see clean, module-qualified calls.

```pxl
// extlibs -- unit wrapping external libraries
module unit extlibs;

@addlibrarypath "$P:res/tests/libs";

// JS external -- resolved from mathjs.js in libs/
public routine JsAdd(const a: int32; const b: int32): int32;
  external "mathjs" name "JsAdd";

// Wasm external -- resolved from mathlib.wasm in libs/
public routine Add(const a: int64; const b: int64): int64;
  external "mathlib" name "Add";

end.
```

```pxl
// probe_extlibs_unit -- consuming externals via a unit
module exe probe_extlibs_unit;

import extlibs;

var
  r: int64;
begin
  println("JsAdd(2, 3) = %d", extlibs.JsAdd(2, 3));
  r := extlibs.Add(10, 20);
  println("Add(10, 20) = %d", r);
end.
```


<a id="js-interop-writing-a-js-library"></a>

### ✍️ Writing a JS Library

A JS library is a `.js` file that exposes functions as properties of a global object. The object name must match the wasm import module name used in the `external` clause, because `index.html` passes it to wasm as `<name>: <name>`.

A library can take one of two forms:

- **Plain global script (passed through as is).** A file with no module syntax defines the object itself with `var <name> = ...`. Every std shim uses this form.
- **CommonJS or ES module (wrapped).** The build runs every external `.js` file through esbuild as an IIFE with `--global-name=<name>` and reads esbuild's metafile. If esbuild finds module exports, the wrapped output is used, so those exports become the global object; if it finds none, the file is used as is. A free `PXL` inside the wrapped code resolves to runtime.js's top-level `PXL`, so no prelude is added. The vendor shim (`phaser`) uses this form. If esbuild fails, the build warns and falls back to the raw file.

**Rules:**

1. **Use `var` for a plain global library.** Define the object with `var <name> = ...` at top level, as the std shims do; `index.html` refers to it by that global name.
2. **Every DOM or browser API call must be wrapped in `try/catch`.** No exception may unwind into wasm -- the program will abort. Return a safe default (false, -1, 0) on failure.
3. **Namespace isolation.** Use an IIFE or a plain object literal. Never reference another shim's globals; shared state goes through documented slots on the `PXL` object only.

Minimal example (the `mathjs.js` from above):

```javascript
var mathjs = {
  JsAdd: function(a, b) { return a + b; },
  JsMul: function(a, b) { return a * b; }
};
```

The same functions as a CommonJS or ES module (from `tests/libs/synth_cjs.js` and `tests/libs/synth_esm.js`, used by `probe_synth_cjs.pxl` and `probe_synth_esm.pxl`):

```javascript
module.exports = {
  Add: function(a, b) { return a + b; },
  Mul: function(a, b) { return a * b; },
  Neg: function(a) { return -a; }
};
```

```javascript
// synth_esm.js -- ES module export pattern
export function Add(a, b) { return a + b; }
export function Mul(a, b) { return a * b; }
export function Neg(a) { return -a; }
```

A std module like `canvas2d.js` uses the IIFE pattern for private state:

```javascript
var canvas2d = (function () {
  var _canvas = null;   // private -- not visible to other shims
  var _ctx = null;
  return PXL.guard('canvas2d', ['GetTextPropInto', 'ImageDataRead', 'ToDataURL'], {
    Init: function (w, h) { /* ... */ },
    Resize: function (w, h) { /* ... */ }
  });
})();
```

`PXL.guard` wraps every entry so no JS exception unwinds into wasm; the list names the routines that return BigInt.

#### How JS Libraries Wire into the Output

The build pipeline collects all external JS files, appends them after `runtime.js`, runs esbuild over the result (minified in release and distro builds), and writes it as `output.js`, which `index.html` loads with `<script src="output.js">`. The wasm instantiate call in `index.html` passes each library object as an import namespace:

```javascript
WebAssembly.instantiateStreaming(fetch('output.wasm'), {
  wasi_snapshot_preview1: wasi.wasiImport,
  mathjs: mathjs      // <-- wired automatically for each JS external
});
```

The `__PXL_EXTRA_IMPORTS__` placeholder in the template is replaced with comma-separated entries for every JS external library the program uses. The program binary itself (`output.wasm`) is streamed from `pxl://app/output.wasm`.


<a id="js-interop-marshalling-contract"></a>

### 🔢 Marshalling Contract

Numbers, strings, and JS objects cross the wasm/JS boundary according to a fixed contract. Every std module and every user shim follows the same rules.

#### Numbers

| Domain | Wasm type | Examples |
|--------|-----------|---------|
| Geometry, sizes, angles, alpha, time | `float64` | canvas coordinates, delta time, opacity |
| Counts, indices, handles, booleans | `int32` | key codes, handle IDs, true/false |
| Never pass to a DOM API | `int64` | Arrives as BigInt in JS -- the browser throws on any DOM call that receives one |

A routine declared `int64` in the `.pxl` must return `BigInt` from JS. Mark it with a `// returns BigInt` comment in the shim.

#### Strings In (PIXELS to JS)

An extern parameter typed `ptr to char` receives a pointer to a NUL-terminated UTF-8 string in wasm linear memory. The `string` type converts implicitly to `ptr to char` at the call site. On the JS side, read it with `PXL.readCStr(ptr)`.

#### Strings Out (JS to PIXELS)

Returning a string from an extern is never correct -- the JS side cannot allocate in wasm memory. Instead, the extern uses a **length-query/fill pattern**:

**Extern shape:**
```pxl
routine GetGreetingInto(const buf: ptr to char; const bufSize: int64): int64;
  external "cstr2str" name "GetGreeting";
```

**JS side (from `tests/libs/cstr2str.js`):**
```javascript
// Length query / fill, same contract as canvas2d ToDataURL. returns BigInt
GetGreeting: function (buf, size) { return PXL.writeCStr("hello from js", buf, size); },
```

`PXL.writeCStr(str, buf, size)` writes `min(len, size-1)` bytes plus a NUL terminator and returns the full byte length as `BigInt`. Passing `bufSize = 0` is a length query -- nothing is written.

**PIXELS wrapper pattern:**
```pxl
// string marshalling round-trip
var
  needed: int64;
  buf: ptr to char;
  s: string;
begin
  needed := GetGreetingInto(nil, 0);      // length query
  getmem(buf);
  resizemem(buf, needed + 1);             // allocate
  GetGreetingInto(buf, needed + 1);       // fill
  s := buf;                                // assign to managed string
  freemem(buf);                            // release raw buffer
  println("%s", cstr(s));                  // "hello from js"
end.
```

#### JS Object Handles

Browser objects (canvases, gradients, audio nodes) cannot cross the wasm boundary. The shim stores them in a handle table created by `PXL.handles()` and returns an `int32` handle to PIXELS. The PIXELS side declares a type alias: `type Gradient = int32;`. Handle 0 means "none". A `Release(h)` call frees the slot.


<a id="js-interop-the-pxl-shared-object"></a>

### 🌐 The PXL Shared Object

`runtime.js` creates a global `PXL` object that every shim and the runtime itself depend on, and also exposes it as `globalThis.PXL` so esbuild-wrapped vendor shims can reach it. It is the only communication channel between std modules.

| Slot | Set by | Read by | Purpose |
|------|--------|---------|---------|
| `moduleName` | `index.html` | `localstorage.js` | Program name from wasi args (the module name) |
| `onLoopEnd` | `index.html` | `runtime.js` (`requestEnd`) | The host's `finish`: called once, from a clean stack, when the program ends |
| `onTick` | `input.js` | `app.js` | Called at the top of every tick before any wasm call |
| `canvas` | `canvas2d.js` | `input.js`, `video.js` | The active canvas element for mouse coordinate mapping and video drawing |
| `canvasDpr` | `canvas2d.js` | `input.js` | Device pixel ratio for coordinate scaling |
| `onExit` | std modules (`canvas2d.js`, `video.js`) | `index.html` | Array of cleanup callbacks run after `_shutdown` |

**Helper methods:**

| Method | Purpose |
|--------|---------|
| `readCStr(ptr)` | Read a NUL-terminated UTF-8 string from wasm memory |
| `writeCStr(str, buf, size)` | Write UTF-8 into a wasm buffer; returns `BigInt` byte length |
| `handles()` | Factory -- returns `{alloc, get, release}` for a handle table |
| `fail(e)` | Uniform error handler: records the failure (a WASI exit keeps its code; anything else is a trap, whose stack goes to the page while `#exit` shows `failed`), marks the program ended and calls `requestEnd()`, so the host's `finish` still runs `_shutdown` (it does not rethrow) |
| `requestEnd()` | End the program: queue the host's `onLoopEnd` (`finish`) with `setTimeout(0)`, once; it never runs under a live wasm call |
| `call0(idx)`, `callFrame(idx, dt)` | Call a `routine()` / `routine(const dt: float64)` handler by table index through `_call0` / `_frame`; 0 = nil, no call. Every shim calls its handlers through these |
| `runExit()` | Fire `onExit` callbacks; leave app mode |

The instantiated program is the global `PXL_WASM` (set by `index.html`), so a shim can read wasm memory through `PXL_WASM.exports.memory`.

> [!NOTE]
> **Std modules never reference each other.** `input.js` reads `PXL.canvas` to map mouse coordinates, but it never imports anything from `canvas2d.js` directly. All cross-module communication goes through `PXL` slots. This keeps the modules independently optional.


<a id="js-interop-wasm-library-authoring"></a>

### 📦 Wasm Library Authoring

A pre-compiled foreign `.wasm` file (one not built from a PIXELS `lib` module) can be linked into a PIXELS program via wasm-merge. The program declares the import; the build pipeline merges the two modules into one binary.

**Requirements:**
- The `.wasm` module must export the functions the PIXELS program imports by name.
- It should export its `memory`, as the `mathlib` module below does.

Example `.wat` source for a wasm library (the `mathlib.wat` shown at the top of this section, trimmed):

```wat
;; mathlib.wat
(module
  (memory $mem i64 1)
  (export "memory" (memory $mem))

  (func $mathlib.Add__int64_int64 (param $a i64) (param $b i64) (result i64)
    (local $_ret i64)
    (block $_exit
    (local.set $_ret (i64.add (local.get $a) (local.get $b)))
    br $_exit
    )
    (local.get $_ret)
  )

  (export "Add" (func $mathlib.Add__int64_int64))

)
```

PIXELS side:

```pxl
routine Add(const a: int64; const b: int64): int64;
  external "mathlib" name "Add";
```

The library file name (without extension) becomes the wasm module name for the merge. wasm-opt first assembles and optimizes the program's own `.wat`; wasm-merge then combines that `.wasm` with every external `.wasm` into one binary (`--skip-export-conflicts`). The merged result is not optimized again.


<a id="js-interop-pixels-lib-modules"></a>

### 🏗️ PIXELS Lib Modules

A PIXELS program can produce a `.wasm` library instead of an Electron app. Declare the module as `lib`:

```pxl
module lib mathlib;

@outputpath "$P:res/tests/libs";

public routine Add(const a: int64; const b: int64): int64;
begin
  return a + b;
end;

routine Mul(const a: int64; const b: int64): int64;
begin
  return a * b;
end;

end.
```

Public non-external routines are exported under their mangled name `<lib>.<Name>__<param kinds>` (here `mathlib.Add__int64_int64`), so overloaded public routines are exported too; public variables are exported as `<lib>.<name>`. Constants and types have no binary form: a consumer redeclares them. The build writes `<name>.wat` and `<name>.wasm` into the output directory (`-o`, else `@outputpath`, else `output` under the current working directory); there is no JS runtime, no `app.asar` and no assets.

A PIXELS lib links only into a PIXELS `exe`: it imports its memory and every runtime routine it uses from the program that links it, so a plain wasm host cannot instantiate it. A consumer declares the routine with its real parameters, `routine Add(const a: int64; const b: int64): int64; external "mathlib" name "Add";`, and the compiler binds the export for that parameter list. A lib build links nothing; the `exe` build merges the lib and, recursively, every library the lib declares `external`, each searched in the exe's source folder, then each `@addlibrarypath` folder, then the std module folder and each vendor library folder. A lib that uses a std module (for example `canvas2d`) therefore links into any exe, whether or not the exe uses that module itself. The exe runs each lib's `initialize` before its own startup and its `finalize` after its own cleanup (see [Modules](#modules)).

> [!NOTE]
> **Link errors are reported at the `external` declaration.** A missing export (wrong name or parameter types) is CMP008, a lib built by a compiler with another lib ABI is CMP007, a dependency that is not found is CMP009, a dependency cycle is CMP010, and an unreadable or malformed `.wasm` is WRD001 / WRD002.


<a id="js-interop-build-pipeline-summary"></a>

### 📋 Build Pipeline Summary

The external library pipeline from source to output:

| Stage | JS library (.js) | Wasm library (.wasm) |
|-------|-------------------|----------------------|
| **Resolve** | Compiler finds `.js` file via search paths | Compiler finds `.wasm` file via search paths and reads its imports and exports (a PIXELS lib: its dependencies too) |
| **Collect** | Added to JS bundle after `runtime.js` (CommonJS/ES modules wrapped to an IIFE by esbuild) | Added to wasm-merge input list (PIXELS libs dependencies first) |
| **Bundle** | Concatenated, passed through esbuild (minified in release/distro) | Merged with program `.wasm` by wasm-merge (exe builds only; link-only exports stripped after a PIXELS lib merge) |
| **Package** | Written as `output.js` into `app.asar` | Merged binary written as `output.wasm` into `app.asar`, streamed from `pxl://app/` at startup |
| **Wire** | Import namespace entry added to `WebAssembly.instantiateStreaming()` | Imports resolved internally (same module) |

The result is an Electron app (`app.asar` in `bin\res\electron\<arch>\resources\`) that carries every external dependency -- JS or wasm. No library resolution happens at runtime.

Next: [Memory and Data Structures](#memory-data-structures)

---

<p align="right"><a href="#js-interop">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="memory-data-structures"></a>

## 🧠 6. Memory and Data Structures

> **Own data without losing control**  
> Understand allocation, managed strings, dynamic arrays, varargs, cleanup, and leak reporting.


*PIXELS manages memory at runtime so you rarely have to -- but gives you full control when you want it.*

Every PIXELS program runs on a single wasm64 linear memory. The runtime provides a heap allocator for dynamic data, reference-counted strings, resizable arrays, and automatic cleanup walks that free temporaries and locals at every scope exit. In the `debug` build mode (the default), the runtime also tracks allocations and reports leaks on shutdown -- a one-line diagnostic that catches every unpaired `getmem`/`freemem` in the program.

Here is heap allocation and dynamic arrays in action, trimmed from the compliance suite:

```pxl
// bnf_exe_compliance.pxl -- phases 21 + 25 (trimmed)
var mbuf: ptr to uint8;
var darr: array of int32;

// Phase 21: Memory management (getmem, freemem, resizemem, setlength)
getmem(mbuf);
freemem(mbuf);

getmem(mbuf);
resizemem(mbuf, 1024);
setlength(mbuf, 2048);
freemem(mbuf);

// Phase 25: Dynamic arrays (array of T, setlength, len, indexing)
setlength(darr, 5);
println("len after setlength = %lld", len(darr));
darr[0] := 100;
darr[4] := 500;
println("darr[0] = %d", darr[0]);
setlength(darr, 7);
darr[6] := 700;
println("len after grow = %lld", len(darr));
println("darr[6] = %d", darr[6]);
```

Build and run it in debug mode to see the leak report: from `bin\`, `pixels res\tests\compliance\bnf_exe_compliance -r` (debug is the default build mode; `-bm debug` says it explicitly). On shutdown the runtime prints `[Heap] Allocs: N, Frees: N, Leaked: 0` -- confirming every allocation was paired with a free.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🏗️ The Heap Allocator](#memory-data-structures-the-heap-allocator)
- [🔧 Memory Builtins](#memory-data-structures-memory-builtins)
- [📜 Strings](#memory-data-structures-strings)
- [📐 Dynamic Arrays](#memory-data-structures-dynamic-arrays)
- [📦 Varargs Packs](#memory-data-structures-varargs-packs)
- [🧹 Cleanup Walks](#memory-data-structures-cleanup-walks)
- [📊 Leak Report](#memory-data-structures-leak-report)

</details>

<a id="memory-data-structures-the-heap-allocator"></a>

### 🏗️ The Heap Allocator

The PIXELS heap is a free-list allocator layered over the wasm64 linear memory. There is no OS heap and no external allocator -- the runtime manages everything in the same address space the program already has.

Every allocated block carries an 8-byte header storing the block size (including the header). Free blocks chain through a singly-linked list embedded in the first 8 bytes of user data. All sizes are rounded up to 16-byte alignment, so the minimum block is 16 bytes (8 header + 8 link).

Allocation tries the free list first (first-fit), then bumps a heap pointer. If the bump exceeds the current memory, the runtime grows the linear memory automatically. Deallocation prepends the block back to the free list. Adjacent free blocks are not coalesced -- for programs with short lifetimes (games, demos, tools), the simplicity trade-off is acceptable.

> [!NOTE]
> **Static data, then the heap.** Linear memory starts with the runtime's fixed scratch areas (below offset 2048), followed by the program's static data segments (from offset 2048). The heap pointer starts at the end of static data, rounded up to 16 bytes. The initial memory is just large enough to hold the static data (at least one 64 KB page) and grows on demand, so there is no compile-time limit on static data size. A `lib` has no heap of its own: its data is one passive segment that is copied into a heap block of the exe that links it.


<a id="memory-data-structures-memory-builtins"></a>

### 🔧 Memory Builtins

Six builtins map to runtime calls. The compiler emits the appropriate wasm instructions for each.

| Builtin | Purpose | Notes |
|---------|---------|-------|
| `getmem(p)` | Allocate zero-filled memory | Size determined by the pointer's target type |
| `freemem(p)` | Free raw memory | Sets `p` to `nil` afterwards |
| `resizemem(p, n)` | Resize an allocation to `n` bytes | Copies existing data; assigns the new pointer back to `p` |
| `new(p)` | Typed allocation | Same as `getmem` -- allocates `size(T)` bytes for `ptr to T` |
| `dispose(p)` | Typed deallocation | Same as `freemem` -- frees and nils |
| `setlength(x, n)` | Resize a dynamic array or raw buffer | Dispatches by type: dynamic arrays, strings, and raw pointers each have their own runtime path |

> [!TIP]
> **Pair every allocation.** `getmem` pairs with `freemem`, `new` pairs with `dispose`. Strings and dynamic arrays need no pairing: a local releases its reference at routine exit and a global at shutdown (`setlength(arr, 0)` drops an array's reference early). In debug builds the leak report catches any mismatch.


<a id="memory-data-structures-strings"></a>

### 📜 Strings

Strings are reference-counted, heap-allocated, NUL-terminated UTF-8 values. A string variable holds a 64-bit pointer to an internal record (40 bytes):

| Offset | Field | Size | Purpose |
|--------|-------|------|---------|
| 0 | RefCount | i64 | Reference count (1+ = live, 0 = dead, -1 = immortal: a string literal) |
| 8 | Length | i64 | Byte length excluding NUL |
| 16 | Capacity | i64 | Buffer capacity excluding NUL |
| 24 | Data | i64 | Pointer to the UTF-8 byte buffer |
| 32 | Data16 | i64 | Cached UTF-16 view (built lazily on first wide-string access) |

The empty string IS `nil` (0): `""`, an empty `format()` result and every runtime operation that yields no characters give `nil`, never a record of length 0. All runtime operations are nil-safe: `nil` and `""` compare equal, `assertnil("")` passes, and `cstr` / `wstr` of `nil` point at a static NUL, never at address 0.

> [!NOTE]
> **Immortal strings.** A refcount of -1 means "never freed": AddRef and Release are no-ops for such a string. Every string literal is one. The compiler places one static record per distinct literal value in the module's data, with its UTF-16 view already built, so a literal is never allocated, copied or freed and does not count in the `[Heap]` report.

#### Reference Counting

The runtime manages string lifetimes through three operations:

- **AddRef** -- increments the reference count when a string is assigned to a new variable or passed to a routine.
- **Release** -- decrements the reference count; when it reaches zero, the runtime frees the Data buffer, the optional Data16 buffer, and the record itself (three heap frees).
- **Assign** -- AddRefs the source first (safe for self-assignment), stores the new pointer, then releases the old value.

You never call these yourself -- the compiler inserts them at every assignment, scope exit, and temporary cleanup.

Storing one element (`s[i] := c`) makes the string unique first: a string with another holder (refcount above 1) or an immortal literal is copied and the store goes into the copy, so no other holder sees the change. A store in place drops the cached Data16 view, which is rebuilt on the next wide access.

Here are the common string paths, trimmed from the compliance suite:

```pxl
// bnf_exe_compliance.pxl -- phases 3 + 3b, string lifetimes (trimmed)
// String concatenation
var v_str2: string = "hello ";
var v_str3: string = " world";
var v_cat: string;
v_cat := v_str2 + v_str3;
println("%s", cstr(v_cat));

// utf8 returns a caller-owned UTF-8 copy; valid after the source changes
var v_u8: ptr to char = utf8(v_str);
v_str := "changed";
println("%s", v_u8);
freemem(v_u8);
v_str := "hello";

// Literal operand in concat (left and right)
var v_tmp: string;
v_tmp := "hello " + v_str2;
asserteq("hello hello ", v_tmp, "literal + var");

// Concat used directly as an argument
println("%s", cstr("hello " + v_str3));

// String result discarded
greet("dropped");
```

`v_cat := v_str2 + v_str3` builds a new string (refcount 1) and releases whatever `v_cat` held before. The concatenation passed straight to `cstr(...)` and the discarded result of `greet(...)` are statement temporaries: the compiler releases them at the end of the statement (see Cleanup Walks below). `utf8()` is different -- it returns a caller-owned raw copy, not a managed string, so you release it yourself with `freemem`.

#### Concatenation and SetLength

`s1 + s2` allocates a new string with the combined content. Neither operand is modified; the result has refcount 1.

`setlength(s, n)` allocates a new string of capacity `n`, copies the existing prefix, zero-fills the tail, and releases the old string. This is useful for building strings incrementally.

#### Wide Strings

Wide strings (`wstring`) use the same record layout. The difference is that `len()` and comparison operate on the UTF-16 view (the Data16 field) rather than the raw UTF-8 bytes. The UTF-16 view is built lazily on first access and cached for subsequent calls. Concatenation delegates to the UTF-8 path -- the Data16 cache is rebuilt on demand.

#### Format Builders

`print`, `println`, and `format()` use printf-style format strings. The runtime has no printf: the compiler decomposes the literal format string at compile time into typed calls. For `print` and `println` those are direct writes (`rt_write_i64`, `rt_write_f64`, `rt_write_managed_str`, etc.) that send each piece straight to stdout. For `format()` they are a chain of typed append calls (`rt_fmt_i64`, `rt_fmt_f64`, `rt_fmt_str`, etc.) that build and return a managed string (initial capacity 64, doubling as it grows). You never interact with format builders directly.


<a id="memory-data-structures-dynamic-arrays"></a>

### 📐 Dynamic Arrays

A dynamic array is a heap-allocated contiguous block with a 16-byte header -- a reference count and the element count -- stored immediately before the first element:

```
[refcount: i64] [count: i64] [element 0] [element 1] [element 2] ...
 (ptr - 16)      (ptr - 8)    ptr ->
```

The array variable holds a pointer to element 0. `len(arr)` reads the count at `ptr - 8`. A nil pointer (0) means length 0.

A dynamic array is a shared reference, as in Delphi: after `b := a` both variables hold the same block, so `b[0] := 5` is seen through `a`. Every assignment adds a reference and the last reference to go frees the block.

All lifecycle operations go through `setlength`:

```pxl
// bnf_exe_compliance.pxl -- phase 25, dynamic arrays
var darr: array of int32;

setlength(darr, 5);
println("len after setlength = %lld", len(darr));
darr[0] := 100;
darr[1] := 200;
darr[2] := 300;
darr[3] := 400;
darr[4] := 500;
println("darr[0] = %d", darr[0]);
println("darr[2] = %d", darr[2]);
println("darr[4] = %d", darr[4]);
setlength(darr, 7);
darr[5] := 600;
darr[6] := 700;
println("len after grow = %lld", len(darr));
println("darr[6] = %d", darr[6]);
```

The first `setlength` allocates a zero-filled block; the second grows it, keeping elements 0 to 4.

When the array is shared (another variable holds the same block), `setlength` first gives this variable a private copy of the elements it keeps, so the other holders see no change. When it is unshared, growing reallocates the block and zero-fills the new slots, shrinking truncates it in place, and setting the length to 0 frees the block (the variable becomes nil).

> [!NOTE]
> **Managed element cleanup.** The compiler owns element lifetimes; the runtime never walks elements. When the last reference to an array goes, or a shrink drops elements, compiler-generated code releases each dropped element that holds references: strings, nested dynamic arrays, and records or static arrays that contain them. A private copy adds a reference to each kept element. Raw pointers (`ptr`, `ptr to T`) and overlays are not managed: free what a pointer element owns yourself. You never release managed elements before resizing.


<a id="memory-data-structures-varargs-packs"></a>

### 📦 Varargs Packs

Variadic routines (`...` parameter) receive their arguments as a heap-allocated tagged pack. Each slot stores a type tag and a value (16 bytes per slot). The runtime checks types at access time and raises error code 1003 (type mismatch) or 1004 (index out of bounds) on violations.

Varargs packs are created by the caller, passed by pointer, and freed by the cleanup walk after the call. For full syntax and usage, see the Variadic Routines section of the [Language Reference](#language-reference).


<a id="memory-data-structures-cleanup-walks"></a>

### 🧹 Cleanup Walks

The compiler generates cleanup code at three levels to ensure no managed resource leaks:

**Statement temporaries.** After every statement that produces string temporaries (concatenation results, format builder outputs), the compiler emits Release calls for each temporary. Aggregate temporaries (record or array intermediates) are freed via FreeMem.

**Routine exit.** When a routine returns, the compiler walks every local variable. Strings are released. Heap-backed locals (records, overlays, static arrays allocated on the heap) have their managed fields released, then the block itself is freed; an overlay's fields are never walked, since the active member is unknown. Dynamic array locals are released: the last reference frees the block and its managed elements.

**Program shutdown.** The `_shutdown` export runs the full teardown:

1. User shutdown handler (the shutdown routine given to `app.Run`, if any)
2. This module's `finalize` block
3. Imported units' `finalize` blocks in reverse initialization order
4. Global variable cleanup, the exact reverse of allocation: this module, then imported units in reverse order
5. Every linked PIXELS lib's teardown (its `finalize` blocks, then its global cleanup), in reverse link order, for each lib whose startup began
6. Clear the last exception record
7. Leak report (debug build mode only)

This sequence is deterministic -- finalize blocks and global cleanup always run in the same order for a given program. The reverse ordering ensures that a unit's globals are still alive when its dependents finalize.


<a id="memory-data-structures-leak-report"></a>

### 📊 Leak Report

In the `debug` build mode (emitter optimize level 0), the runtime tracks every allocation and deallocation through wrapper functions that increment two counters. On shutdown, after the full cleanup walk, the runtime prints this line to stdout:

```
[Heap] Allocs: 42, Frees: 42, Leaked: 0
```

A non-zero "Leaked" count means the program has unpaired allocations. Since the cleanup walks handle strings, dynamic arrays, and all managed temporaries automatically, a leak usually points to a `getmem` without a matching `freemem` (or a `new` without a `dispose`).

In the `release` and `distro` build modes (emitter optimize level 3), the wrappers are pass-through -- no counters, no report, no overhead. See [Build Modes](#build-modes).

> [!NOTE]
> An exception or trap that escapes `_start` or a handler is reported, the program ends, and `_shutdown` still runs its cleanup walk and the `[Heap]` report (debug).

> [!TIP]
> **Use debug builds during development.** Build with `pixels myprogram -r` (debug is the default build mode) to catch leaks early. The leak report runs after all cleanup walks, so it reflects the program's actual resource discipline, not just the final state of the heap.

Next: [BNF Grammar](#bnf-grammar)

---

<p align="right"><a href="#memory-data-structures">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="bnf-grammar"></a>

## 🧾 BNF Grammar

> **The formal language contract**  
> Exact lexical, syntax, typing, directive, runtime-facing, and output rules for PIXELS tooling and compiler work.


### 🗺️ Grammar Roadmap

| Area | Sections | What it defines |
|---|---|---|
| **Source text** | 1-5 | Lexical elements, reserved words, primitive types, operators, comments |
| **Program structure** | 6-10 | Modules, directives, declarations, routines, compound types |
| **Execution semantics** | 11-16 | Statements, expressions, intrinsics, varargs, tests, precedence |
| **Build contract** | 17 + checklist | Output packaging and grammar-maintenance rules |

<details>
<summary><strong>Jump to a grammar topic</strong></summary>

- [🧾 Syntax Notation](#bnf-syntax-notation)
- [🔎 How to Read This Grammar](#bnf-how-to-read-this-grammar)
- [🔤 1. Lexical Elements](#bnf-lexical-elements)
- [🚫 2. Reserved Words](#bnf-reserved-words)
- [🧱 3. Built-in Types](#bnf-built-in-types)
- [⚙️ 4. Operators and Delimiters](#bnf-operators-and-delimiters)
- [💬 5. Comments](#bnf-comments)
- [🧱 6. Module Structure](#bnf-module-structure)
- [🔀 7. Conditional Compilation](#bnf-conditional-compilation)
- [📦 8. Declarations](#bnf-declarations)
- [🔧 9. Routine Declarations](#bnf-routine-declarations)
- [🏷️ 10. Type Definitions](#bnf-type-definitions)
- [📋 11. Statements](#bnf-statements)
- [🧮 12. Expressions](#bnf-expressions)
- [⚡ 13. Intrinsics](#bnf-intrinsics)
- [🧺 14. Variadic Arguments](#bnf-variadic-arguments)
- [🧪 15. Unit Testing](#bnf-unit-testing)
- [🎚️ 16. Operator Precedence (Highest to Lowest)](#bnf-operator-precedence-highest-to-lowest)
- [🎯 17. Output Model](#bnf-output-model)
- [🧪 Grammar Validation Checklist](#bnf-grammar-validation-checklist)

</details>

<a id="bnf-syntax-notation"></a>

### 🧾 Syntax Notation

This section is the formal grammar reference for the PIXELS&trade; Game Toolkit language. It is intended for implementers, tooling authors, and anyone who needs exact syntax rules.

The grammar uses EBNF notation. Brackets `[` and `]` mark optional elements. Braces `{` and `}` mark repetition, zero or more times. Parentheses group alternatives. The vertical bar `|` separates alternatives. Terminal symbols are enclosed in quotes or written as lowercase literal tokens. Non-terminals are written in PascalCase.


> [!NOTE]
> 🧾 This file is intentionally formal. Use it when you need the exact grammar contract.

<a id="bnf-how-to-read-this-grammar"></a>

### 🔎 How to Read This Grammar

| Symbol | Meaning |
|--------|---------|
| `A B` | `A` followed by `B` |
| `A | B` | either `A` or `B` |
| `[ A ]` | optional `A` |
| `{ A }` | zero or more repetitions of `A` |
| `( A | B )` | grouped alternatives |
| `"text"` | literal source text |

> [!TIP]
> 💡 When implementing a parser, treat this file as the external behavior contract, not as a required internal parser architecture. Recursive descent, Pratt parsing, table-driven parsing, or another strategy can all implement the same grammar.


<a id="bnf-lexical-elements"></a>

### 🔤 1. Lexical Elements

```
letter     = "A" | ... | "Z" | "a" | ... | "z" | "_" .
digit      = "0" | ... | "9" .
hexDigit   = digit | "A" | ... | "F" | "a" | ... | "f" .
character  = (* any source character except the delimiter and line feed *) .
newline    = (* line feed (U+000A) *) .

ident      = letter { letter | digit } .
integer    = digit { digit } | "0" ( "x" | "X" ) hexDigit { hexDigit } .
float_literal = digit { digit } ( "." { digit } [ exponent ] [ floatSuffix ]
                                | exponent [ floatSuffix ]
                                | floatSuffix ) .
exponent      = ( "e" | "E" ) [ "+" | "-" ] digit { digit } .
floatSuffix   = "f" | "F" .
cstring    = '"' { character | escapeSeq } '"' .
wstring    = "w" '"' { character | escapeSeq } '"' .
escapeSeq  = "\" ( "n" | "t" | "r" | "0" | "\" | "'" | '"' | "x" hexDigit hexDigit ) .
directive  = "@" { letter | digit } .
```

- Identifiers are ASCII only. Whitespace is space, tab, carriage return, and line feed.
- A decimal point is part of a number only when it is not followed by a second `.`, so `1..10` is `1`, `..`, `10`. A leading point is not a number: `.5` is `.` followed by `5`.
- Accepted float forms include `1.5`, `1.`, `1.5e3`, `1e3`, `1f`, `1e3f`, and `1.5F`. Hex literals never take a float suffix: `0x1F` is the integer 31.
- There are no binary or octal literals, no digit separators, and no integer suffixes. A negative number is unary minus applied to a literal.
- A number must not be followed directly by a letter, digit or `_`: `123abc`, `0x1G` and `for i := 0 to 9do` are error LEX006 at the number. Separate a number from the next word with whitespace or an operator.
- A directive token is `@` followed by a name; the name is stored in lowercase, so directive names are case-insensitive.
- There is no single-quoted literal. `'`, `{`, `}`, `#`, `$`, `%`, `!`, `?`, `~`, and any non-ASCII character outside a string or comment are invalid characters (LEX003).

#### 🔢 Numeric Literal Type Rules

| Literal         | Suffix | Type      | Example         |
|----------------|--------|-----------|-----------------|
| `42`, `0x2A`   | --     | `int32` by default | integer |
| `1.5`, `1e3`   | --     | `float64` by default | float literal |
| `1.5f`, `1F`   | `f`/`F` | `float32` by default | explicit `float32` |

**Literal resolution in a typed context:**

- A literal takes the type of its target wherever the target type is known: a typed `const`, a `var` initializer, the right side of an assignment, a `match` label (scrutinee type), a `return` value (return type), a call argument (parameter type), a binary operand, and a record field initializer.
- This applies to every literal, with or without a suffix: `n: int64 := 42` produces an `int64` literal, and `x: float64 := 1.5f` produces a `float64` literal.

**Literal resolution without a context:**

- Integer literal: `int32`
- Float literal without a suffix: `float64`
- Float literal with an `f` or `F` suffix: `float32`
- Variadic arguments follow Section 14.

#### 🧵 String Literal Convention

- `"..."` -- String literal. Escape sequences processed. UTF-8 encoded.
- `w"..."` -- Wide string literal of type `wstring`. Escape sequences processed. The literal is stored as UTF-8 and the runtime builds the UTF-16 view on demand. Prefix is case-sensitive: only lowercase `w` (`W"x"` is the identifier `W` followed by a string).
- A string literal cannot span lines: a line feed or end of file before the closing quote is an error (LEX001).
- `\xHH` is the code point U+00HH, which is then UTF-8 encoded: `"\xFF"` is two bytes (`C3 BF`), not one.
- No other escapes exist (`\u`, `\a`, `\b`, `\e` are LEX005). There are no raw, triple-quoted, or multi-line string forms.

#### 🔤 Character Type Assignment Rules

The `char` and `wchar` types have no dedicated literal syntax. Characters are
assigned using string literals, variable-to-variable assignment, or string indexing.

**Valid `char` assignments:**
- `c := "x";` -- A `cstring` literal of exactly one UTF-8 code unit (one ASCII character).
- `c := d;` -- Where `d` is also of type `char`.
- `c := s[i];` -- Indexing a `string` yields a `char`: UTF-8 code unit `i`.

**Valid `wchar` assignments:**
- `wc := w"x";` -- A `wstring` literal of exactly one UTF-16 code unit.
- `wc := wd;` -- Where `wd` is also of type `wchar`.
- `wc := ws[i];` -- Indexing a `wstring` yields a `wchar`: UTF-16 code unit `i`.

A literal assigned to a `char` must be exactly one UTF-8 code unit (ASCII), and one assigned to a `wchar` exactly one UTF-16 code unit; anything else, including `""`, is error SEM003. Use `"\0"` for NUL. The same rule holds for a literal compared with a `char` or `wchar` (`=`, `<>`, the ordering operators) and for `asserteq`, which takes the literal rule of `=`: `c = "ab"` is error SEM003 at the literal.

**String indexing.** A `string` or `wstring` indexes from 0. `s[i]` is UTF-8 code unit `i` of `s`, the same byte as `cstr(s)[i]`; `ws[i]` is UTF-16 code unit `i`. `s[i] := c` and `ws[i] := wc` are legal: the string is made unique first (copy-on-write), so every other holder of the old text keeps it. The string must itself be a variable or other location (SEM016 otherwise). `@s[i]` is error SEM003; use `cstr(s)` for a pointer to the bytes. A `debug` build raises exception 1005 for an index outside `0..len(s)-1`; `release` and `distro` builds do not check the index.


<a id="bnf-reserved-words"></a>

### 🚫 2. Reserved Words

Keywords and built-in type names are **case-insensitive**: `BEGIN`, `Begin`, and
`begin` are the same keyword, and `Int32` is `int32`. Identifiers keep the
spelling used in the source.

```
address    align      and        array      assert     asserteq
asserteqf  assertfalse assertfail assertnil assertnotnil asserttrue
begin      break      choices    const      continue
cstr       dispose    div        do         downto
else       end        except     exccode    excmsg
external   false      finalize   finally    format
for        forward    freemem    getmem     guard
if         import     in         initialize is         len
match      mod        module     new
nil        not        of         or         overlay
packed     paramcount paramstr   print      ptr
println    public     record     repeat     resizemem
return     routine    set        setlength  shl
shr        size       test       then       throw
throwcode  to         true       type       until      utf8
var        varargs    while      wstr       xor
```

The built-in type names of Section 3 (`int8` through `wstring`) are also
reserved and can never be used as identifiers.

> [!NOTE]
> The identifiers `exe`, `lib`, and `unit` are contextual. They have special meaning only in the `ModuleKind` position and may be used as ordinary identifiers elsewhere. Unlike keywords they are matched case-sensitively and must be written in lowercase. Unit modules are `.pxl` source files that are compiled inline into the importing module rather than producing separate output.


<a id="bnf-built-in-types"></a>

### 🧱 3. Built-in Types

```
int8       int16      int32      int64
uint8      uint16     uint32     uint64
float32    float64
bool
char       wchar
string     wstring
ptr
varargs
```

`varargs` is a keyword (Section 2) that also names the variadic pack type; it
is used only as described in Section 14.

#### 📏 Type Sizes

| Type        | Size (bytes) | Description            |
|-------------|-------------|------------------------|
| `int8`      | 1           | Signed 8-bit integer   |
| `int16`     | 2           | Signed 16-bit integer  |
| `int32`     | 4           | Signed 32-bit integer  |
| `int64`     | 8           | Signed 64-bit integer  |
| `uint8`     | 1           | Unsigned 8-bit integer |
| `uint16`    | 2           | Unsigned 16-bit integer|
| `uint32`    | 4           | Unsigned 32-bit integer|
| `uint64`    | 8           | Unsigned 64-bit integer|
| `float32`   | 4           | 32-bit IEEE 754 float  |
| `float64`   | 8           | 64-bit IEEE 754 float  |
| `bool`      | 1           | Boolean (0 or 1)       |
| `char`      | 1           | 8-bit character        |
| `wchar`     | 2           | 16-bit wide character  |
| `string`    | 8 (pointer) | Managed UTF-8 string   |
| `wstring`   | 8 (pointer) | Managed UTF-16 string  |
| `ptr`       | 8           | Untyped pointer        |
| `varargs`   | 8 (pointer) | Variadic argument pack (see Section 14) |


<a id="bnf-operators-and-delimiters"></a>

### ⚙️ 4. Operators and Delimiters

```
+    -    *    /    =    <>   <    >    <=   >=
:=   +=   -=   *=   /=
:    ;    ,    .    ..   ...  ^    |    &
(    )    [    ]
```

#### 🧠 Operator Semantics

- `:=` -- Assignment
- `=` -- Equality comparison
- `<>` -- Not equal
- `^` -- Postfix: pointer dereference. In a type position: pointer type (Section 10)
- `address of` -- Prefix: address-of (Section 12)
- `...` -- Variadic marker in a parameter list (Section 9)
- `|`, `&` -- Reserved tokens (lexed, not accepted by the grammar)
- `@` -- Starts a directive (Section 1, Section 7)


<a id="bnf-comments"></a>

### 💬 5. Comments

```
Comment    = "//" { character } ( newline | (* end of file *) )
           | "/*" { character | Comment } "*/" .
```

- `//` -- Line comment. Ends at the line feed or at the end of the file.
- `/* ... */` -- Block comment. May be nested. An unterminated block comment is an error (LEX002).
- Comments are recognized only between tokens: `//` or `/*` inside a string literal is string content.

> [!NOTE]
> `(* *)` and `{ }` are not comment delimiters in PIXELS.


<a id="bnf-module-structure"></a>

### 🧱 6. Module Structure

```
Module        = "module" ModuleKind ident ";" [ Directives ] [ ImportClause ]
                { Declaration | Directive | ImportClause }
                [ "initialize" StatementSeq [ "end" ] [ ";" ] ]
                [ "finalize" StatementSeq [ "end" ] [ ";" ] ]
                ( MainBody | "end" "." )
                { TestBlock } .

MainBody      = "begin" StatementSeq "end" "." .   (* required for exe, not allowed for unit *)

ModuleKind    = "exe" | "lib" | "unit" .

Directives    = { Directive } .
Directive     = "@" ident [ DirectiveValue ] ";" .
DirectiveValue = ( cstring | integer | float_literal | ident )
                 { cstring | integer | float_literal | ident } .

ImportClause  = "import" ident { "," ident } ";" .

TestBlock     = "test" [ cstring ] [ ";" ] [ "var" { VarDecl } ]
                "begin" StatementSeq "end" [ ";" ] .
```

> [!NOTE]
> **Module name.** The module identifier must equal the source file name
> without extension (case-insensitive). `module exe demo;` must live in
> `demo.pxl`. Source files always use the `.pxl` extension: the compiler
> replaces any other extension given on the command line with `.pxl`.

> [!NOTE]
> **Main body.** An `exe` module must have a `begin ... end.` main body and a
> `unit` module must not (error SEM007 either way). A `lib` module may have one.

> [!NOTE]
> **Directives and imports among declarations.** Non-conditional directives
> and additional `import` clauses may appear anywhere in the declaration
> section, not only in the header.

> [!NOTE]
> **Module lifecycle: `initialize` and `finalize`.** The `initialize` and `finalize`
> blocks are module lifecycle hooks. `initialize` runs at startup (before the
> main body or the test runner), `finalize` runs at shutdown. Both are optional
> and the parser accepts them on every module kind. They are separate from `begin`,
> which is the main program body for exe modules. The closing `end` and `;` are
> optional: an `initialize` body also ends at `finalize`, `begin`, or `test`, and a
> `finalize` body also ends at `begin` or `test`.

> [!IMPORTANT]
> **Only units are imported.** An `import` clause names a `unit` module. An
> `exe` module builds an Electron app and a `lib` module builds a `.wasm`: each
> produces its own output, so neither can be imported into another module. A
> `unit` produces no output of its own; it becomes part of every module that
> imports it. One compile is one program: the source module plus every unit it
> imports. Importing an `exe` or `lib` module is error CMP006 at the `import`;
> a library is reached only through `external` declarations. A unit import
> cycle (`a` imports `b`, `b` imports `a`) is error CMP011 at the `import` that
> closes the cycle.

> [!IMPORTANT]
> **Exports and externals.** A module exports every `public` declaration --
> const, type, var and routine. Compiled code in a `.wasm` or `.js` library is
> reached only through `external` declarations (Section 9), which any module
> kind may declare: an `exe`, a `lib` or a `unit`.

> [!IMPORTANT]
> **Module qualification rule.** All public symbols from an imported module must be
> accessed using full module qualification: `moduleName.symbolName`. Unqualified
> access to imported symbols is a compile error. This applies to routines, types,
> variables, and constants alike. If modules A and B both export a symbol `Foo`,
> they are distinguished as `A.Foo` and `B.Foo` -- there is no ambiguity.

> [!NOTE]
> An importer reaches only `public` members; any other is error SEM010 at the access.

> [!NOTE]
> **Directive termination.** Every directive is terminated by `;` -- with one
> exception: the seven conditional-compilation directives (Section 7:
> `@define`, `@undef`, `@ifdef`, `@ifndef`, `@elseif`, `@else`, `@endif`)
> take **no** terminator.

> [!NOTE]
> **Test blocks.** Test blocks appear after `end.`. They are always parsed and
> checked, but they are only compiled into the output and run when
> `@unittestmode on;` is active in an `exe` module (which always has a main body).
> Each test block has an optional string name, optional local variables, and a
> body. When unittest mode is on, the test runner takes the place of the main
> body. Test blocks have access to all module declarations.


<a id="bnf-conditional-compilation"></a>

### 🔀 7. Conditional Compilation

```
ConditionalDirective = DefineDir | UndefDir | IfdefDir | IfndefDir
                     | ElseIfDir | ElseDir | EndifDir .

DefineDir   = "@define" ident .
UndefDir    = "@undef" ident .
IfdefDir    = "@ifdef" ident .
IfndefDir   = "@ifndef" ident .
ElseIfDir   = "@elseif" ident .
ElseDir     = "@else" .
EndifDir    = "@endif" .
```

A missing identifier is PAR020, an unmatched `@else`/`@elseif`/`@endif` is
PAR021, and an unterminated conditional block is PAR022.

#### 📜 Known Directives

All directives below are terminated by `;`. Bare identifiers are the canonical
form for enumerated values; quoted strings are reserved for paths and free text.

**Module-level directives** (appear after `module` header, before or among declarations):

- `@buildmode debug|release|distro;` -- Sets the build mode (bare identifier). `debug` is the default and runs wasm-opt at `-O0`; `release` and `distro` run it at `-O3`; `distro` also packages a zip (Section 17). Any other value is error CMP001. The CLI `-bm`/`--buildmode` flag overrides it.
- `@outputpath "path";` -- Sets the output directory (default: `output` under the current working directory). It receives a `lib` module's `.wasm`, the `distro` zip, and build temporaries. An `exe` app is always written into the bundled Electron folder (Section 17). The CLI `-o`/`--output` flag overrides it.
- `@addlibrarypath "path";` -- Adds a directory to the one search path used by `import` (units) and `external` (libraries, Section 9). The whole program shares the list: each module's entries join it, in declaration order and wherever they stand in the module, before that module's own imports are resolved, so a module can import a unit from a directory it adds itself.
- `@modulepath` -- Removed; using it is error CMP001. Use `@addlibrarypath`.
- `@unittestmode on|off;` -- Enables or disables test block compilation and the test runner (bare identifier).
- `@exeicon "path";` -- Sets the `.ico` file patched into the executable of a `distro` build. Applied to `win-x64` distro builds only.
- **Version info** -- a `win-x64` `distro` build always stamps version information into its executable (otherwise it would carry Electron's own). These directives set its fields; each is optional, `exe` modules only:
  - `@vimajor number;` `@viminor number;` `@vipatch number;` -- The version number, each a whole number from 0 to 65535 (default `0.0.0`). Any other value is error CMP001.
  - `@viproductname "text";` -- Product name (default: the module name).
  - `@videscription "text";` -- File description (default: the module name).
  - `@vifilename "text";` -- Original filename (default: `<module>.exe`).
  - `@vicompanyname "text";` -- Company name (default: empty).
  - `@vicopyright "text";` -- Copyright string (default: empty).

  A failed icon or version info patch fails the build (BUILD003).
- `@assets "source_path" "virtual_path" ["pattern"];` -- Maps every file under `"source_path"` (recursive) whose name matches `"pattern"` (default `*`; e.g. `*.ogg`, `intro.mp4`) into the app's assets. Each key is `"virtual_path"/` plus the file's path relative to `"source_path"`, so `@assets "$P:res/assets/audio" "assets/audio" "*.ogg";` yields keys like `assets/audio/sfx/samp0.ogg`. `"virtual_path"` must be relative, with no `.` or `..` segments. `debug` and `release` builds serve the files in place (no copy); a `distro` build copies them to `resources/__assets/<key>` (Section 17). Valid in `exe` modules only (CMP004). A missing argument is error CMP001; a missing source directory or a key reserved by the app (`index.html`, `output.js`, `output.wasm`, `__assets.json`) is error BUILD003. The first mapping of a key wins: the same file reached again is silent, a different file under the same key is a BUILD003 warning.
- `@asset` -- Removed; using it is error CMP001. Use `@assets` with a file-name pattern.
- `@message hint|warn|error|fatal "text";` -- Emits a compiler diagnostic with the given severity and message text at the directive's source location.

An unknown directive name is error CMP001. An invalid `@unittestmode` or
`@message` value is a warning.

> [!NOTE]
> **Directives in imported units.** In a `unit` module only `@addlibrarypath`
> and `@message` take effect. Any other directive in a unit is
> error CMP004; an unknown name is error CMP001.

##### Path resolution

Every directive taking a `"path"` resolves it the same way. An absolute path is
used as-is. A relative path resolves against the current working directory of
the compiler process.

An optional prefix overrides that base:

| Prefix | Base | Use for |
|---|---|---|
| `$P:` | Directory of the running compiler executable | Shipped assets under the compiler's own `res` tree |
| `$D:` | Current working directory | Paths relative to where the compiler was invoked |
| `$S:` | Same as no prefix (the current working directory for directives) | Explicit spelling of the default |

The prefix is matched case-insensitively and only at the very start of the
string. A path containing `$P:` anywhere else is left alone.

`$P:` is the correct choice for any module meant to be compiled from another
folder. A relative path such as `@assets "res/images" "images"` only works when the
compiler is started from the folder that contains `res`; the `$P:` form always
finds the file shipped beside the compiler:

```
@exeicon "$P:res/assets/icons/pixels.ico";
@assets "$P:res/assets/images" "assets/images" "pixels.png";
```

**Statement-level directives:**

Only the conditional-compilation directives (`@ifdef`, `@ifndef`, `@elseif`,
`@else`, `@endif`, `@define`, `@undef`) and `@message` are accepted at statement
level. Any other directive there is error PAR009 at the directive, and parsing
continues. There is no `@breakpoint` directive.

> [!NOTE]
> **Conditionals in imported units.** The conditional-compilation directives
> (`@define`, `@undef`, `@ifdef`, `@ifndef`, `@elseif`, `@else`, `@endif`)
> take no terminator and also work inside imported unit modules. One set of
> defines is shared by the main module and every unit parsed after it (e.g.
> `PIXELS`, `WASM64`).

#### 🏁 Predefined Symbols

| Symbol               | Defined when                          |
|----------------------|---------------------------------------|
| `PIXELS`             | Always, from the first line of every compile (also before the `module` header) |
| `WASM64`             | Always (wasm64 architecture), like `PIXELS` |
| `BUILD_EXE`          | The program (the root module) is an `exe`: from its `module` header on, in every module, units included |
| `BUILD_LIB`          | The program (the root module) is a `lib`: from its `module` header on, in every module, units included |
| `UNITTESTMODE`       | After `@unittestmode on;` in the `exe` module, from that line on (`@unittestmode off;` removes it) |


<a id="bnf-declarations"></a>

### 📦 8. Declarations

```
Declaration     = [ "public" ] ( ConstSection | TypeSection | VarSection | RoutineDecl )
                | [ "public" ] ForwardDecl .

ConstSection    = "const" { ConstDecl } .
ConstDecl       = ident [ ":" TypeExpr ] "=" Expression ";" .

TypeSection     = "type" { TypeDecl } .
TypeDecl        = ident "=" TypeDef ";" .

VarSection      = "var" { VarDecl } .
VarDecl         = ident ":" TypeExpr [ "=" Expression ] [ ExternalVarClause ] ";" .
ExternalVarClause = "external" ( cstring | ident ) "name" cstring .

ForwardDecl     = "forward" ( ForwardType | ForwardRoutine ) .
ForwardType     = "type" ident ";" .
ForwardRoutine  = "routine" ident [ FormalParams ] [ ":" TypeExpr ] ";" .
```

> [!NOTE]
> **`public` placement.** `public` precedes the section keyword (`const`,
> `type`, `var`), `routine`, or `forward`, and applies to every declaration
> in that section. It is not accepted on individual entries inside a section.

> [!NOTE]
> **External parts are required.** The parser accepts `external` with the
> library or the `name` part left out, but the semantic pass requires both
> (error SEM008). The same rule applies to routines (Section 9).

> [!IMPORTANT]
> **Forward declaration semantics.** A `forward` declaration introduces a name
> before its full definition appears. The full declaration must appear later in
> the same module; a forward-declared type name then resolves to that full
> declaration. For routines, the forward carries the full signature, so calls
> are valid immediately. If a forward declaration has no matching full
> declaration by module end, it is a compile error (SEM006). The full
> declaration must match the forward exactly: parameter count, parameter
> modes, parameter types, return type, and the `...` variadic marker
> (error SEM012 on mismatch).


<a id="bnf-routine-declarations"></a>

### 🔧 9. Routine Declarations

```
RoutineDecl     = "routine" ident [ FormalParams ] [ ":" TypeExpr ] ";"
                  ( ExternalClause | RoutineBody ) .

FormalParams    = "(" [ ParamList ] ")" .
ParamList       = ParamDecl { ";" ParamDecl } [ ";" "..." ] | "..." .
ParamDecl       = [ "var" | "const" ] ident ":" TypeExpr .

ExternalClause  = "external" ( cstring | ident ) "name" cstring ";" .

RoutineBody     = { "type" { TypeDecl }
                  | "const" { ConstDecl }
                  | "var" { VarDecl } }
                  "begin" StatementSeq "end" [ ";" ] .
```

> [!NOTE]
> **Local sections.** `type`, `const`, and `var` sections inside a routine
> may appear in any order and may repeat. `public` is not accepted on them.

> [!NOTE]
> **No linkage spec.** PIXELS has no `clink` or `cpplink` keywords. All routines
> use unconditional name mangling in the wasm output. Overloading is always
> available -- no opt-in required.

> [!IMPORTANT]
> **Arity is checked on every call.** A call to a non-variadic routine must
> pass exactly `Params.Count` arguments; a call to a variadic routine must
> pass at least that many (error SEM009 otherwise). The extra arguments are
> packed for the callee (Section 14).

#### 🔄 Routine Overloading

Multiple routines with the same name but different parameter signatures are
permitted unconditionally. A signature is the parameter count, the variadic
marker, and the parameter types; parameter modes (`var`, `const`) are not part
of it, so two routines that differ only in modes are a duplicate (SEM002). A
variadic routine `f(a: int32; ...)` and a fixed routine `f(a: int32)` are
distinct signatures. Overload resolution at the call site first looks for a
non-variadic routine whose parameter count matches and whose parameter types
equal the argument types exactly; failing that, a variadic routine whose fixed
parameters match the leading arguments. No implicit conversion is tried; no
match is error SEM011. The emitter always generates mangled wasm names
(`$<module>.<name>__<sig>`, with a trailing `__va` for variadic routines) for
all functions.

```
routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

routine add(const a: float64; const b: float64): float64;
begin
  return a + b;
end;
```

#### 🔗 External Clause Semantics

The `external` clause declares a routine that is provided by an external JS or
wasm module, resolved at build time. The value after `external` names the
library to import from, and `name` gives the symbol inside that library. From
`bin\res\libs\std\audio.pxl`:

```
public routine Play(const s: Sound): Voice;
  external "audio" name "Play";
```

The library name is given without an extension. In place of either string (after
`external` or after `name`), a plain identifier names a string constant, declared
directly or through another constant, and its value is used:
`const LIB_MATH = "mathjs";` then `external LIB_MATH name "JsAdd";`. An undeclared
identifier is error SEM001, one that is not a string constant is error SEM008,
both at the identifier.

**Resolution rules** for the library name:

- The compiler searches the declaring module's own directory first, then each
  `@addlibrarypath` directory in order. In each directory `<name>.wasm` is
  tried before `<name>.js`. A library that is not found is error CMP003.
- `wasi_snapshot_preview1` is provided by the runtime and is never searched.
- `.js` -- JavaScript host import. The file is bundled by esbuild into
  `output.js` inside the app (Section 17). The library name becomes the wasm
  import namespace, satisfied by the JS global object of the same name.
- `.wasm` -- WebAssembly module. The compiler reads the file's import and
  export lists; a file that cannot be read is error WRD001 and one that is not
  well-formed wasm is error WRD002, both at the `external` declaration.
  - A **PIXELS library** (built from a `lib` module; it exports `pxl@abi1`) is
    linked by symbol. An external routine binds the library's export for its
    own parameter list: `external "mylib" name "Add"` declared with two `int64`
    parameters binds `mylib.Add__int64_int64`, so each overload of a public
    routine is reached by declaring its parameters. An external variable binds
    `mylib.<name>`. No such export is error CMP008; a library built for
    another ABI (`pxl@abi<N>`) is error CMP007 -- rebuild it.
  - A PIXELS library's own imports are its dependencies. An `exe` build
    resolves each one (other than `pxl`) like its own externals -- the exe's
    source directory, then each `@addlibrarypath` directory -- and then the
    std module folder and each vendor library folder, `.wasm` before `.js` in
    each, recursively. A dependency that is not found is error CMP009 and a
    dependency cycle is error CMP010, both at the `external` declaration that
    brought the library in.
  - Any other `.wasm` is a foreign module, merged into the output via
    wasm-merge as it is.

> [!TIP]
> 💡 A plain-script external JS library must define a global object named
> after the library, with one property per `name` symbol, as
> `bin\res\libs\std\audio.js` does with `var audio = (function () { ... })();`.
> A library written as a CommonJS or ES module is wrapped by esbuild into such a
> global automatically.


<a id="bnf-type-definitions"></a>

### 🏷️ 10. Type Definitions

```
TypeDef         = RecordType | OverlayType | ArrayType
                | PointerType | SetType | ChoicesType | RoutineType | TypeExpr .

RecordType      = "record" [ "packed" ] [ "align" "(" [ integer ] ")" ]
                  [ "(" TypeExpr ")" ]
                  { FieldDecl | AnonOverlay } "end" .

OverlayType     = "overlay" { FieldDecl | AnonRecord } "end" .
AnonRecord      = "record" [ "packed" ] { FieldDecl | AnonOverlay } "end" ";" .
AnonOverlay     = "overlay" { FieldDecl | AnonRecord } "end" ";" .

FieldDecl       = ident ":" TypeExpr [ ":" integer ] ";" .

ArrayType       = "array" [ "[" ArrayBounds "]" ] "of" TypeExpr .
ArrayBounds     = Expression ".." Expression .

PointerType     = ( "ptr" | "^" ) [ "to" [ "const" ] TypeExpr ] .

SetType         = "set" [ "of" Expression [ ".." Expression ] ] .

ChoicesType     = "choices" "(" ChoicesValue { "," ChoicesValue } ")" .
ChoicesValue    = ident [ "=" Expression ] .

RoutineType     = "routine" [ FormalParams ] [ ":" TypeExpr ] .

TypeExpr        = QualIdent
                | PointerType
                | ArrayType
                | SetType .

QualIdent       = ident [ "." ident ] .
```

> [!NOTE]
> **Array bounds** are constant expressions (`array[0..N-1] of int32` is
> valid). `array of T` with no brackets is a dynamic array; `array[] of T`
> is not accepted. A static array indexes from its declared low bound
> (`array[1..3] of int32` takes `1`, `2` and `3`); a dynamic array indexes
> from 0. A `debug` build raises exception 1005 for an index outside the
> bounds; `release` and `distro` builds do not check it, so never rely on
> catching 1005. Indexing a `ptr to T` gives element `i` of type `T` (address +
> i * size of `T`) and is never checked; indexing an untyped pointer or any other
> non-indexable value is error SEM003. **Set** bounds
> are likewise expressions; `set of T` with a
> single expression names an element type or a single bound. **Qualified
> type names** are exactly `Module.Type` -- one qualifier. `^` is an
> alternative spelling of `ptr`: `^ to T` equals `ptr to T` and a bare `^` is
> an untyped pointer. `^T` (without `to`) is not accepted.

> [!NOTE]
> **Choices values.** A `choices` value expression must fold to a constant
> integer (literals, unary `-`, `+ - * div mod and or xor shl shr`, and integer
> constants); anything else is error SEM008. Values are `int32`, and a value
> without `=` is the previous value plus one.

> [!NOTE]
> `choices` is used instead of `enum`,
> and `overlay` instead of `union`. Anonymous overlays and records can nest
> inside each other for data interop. Records support single inheritance
> via `record(BaseType)` syntax and bit fields via `fieldname: type : width`.


<a id="bnf-statements"></a>

### 📋 11. Statements

```
StatementSeq    = { Statement } .

Statement       = Assignment | CallStmt | IfStmt | WhileStmt | ForStmt
                | RepeatStmt | BreakStmt | ContinueStmt
                | MatchStmt | ReturnStmt | GuardStmt | RaiseStmt
                | NewStmt | DisposeStmt
                | GetMemStmt | FreeMemStmt | ResizeMemStmt | SetLengthStmt
                | PrintStmt
                | AssertStmt | InlineVarDecl | ConditionalDirective .

InlineVarDecl   = "var" VarDecl .

Assignment      = Expression ( ":=" | "+=" | "-=" | "*=" | "/=" ) Expression [ ";" ] .

CallStmt        = Expression [ ";" ] .

IfStmt          = "if" Expression "then" StatementSeq [ "else" StatementSeq ] "end" [ ";" ] .

WhileStmt       = "while" Expression "do" StatementSeq "end" [ ";" ] .

ForStmt         = "for" ident ":=" Expression ( "to" | "downto" ) Expression
                  "do" StatementSeq "end" [ ";" ] .

RepeatStmt      = "repeat" StatementSeq "until" Expression [ ";" ] .

BreakStmt       = "break" [ ";" ] .
ContinueStmt    = "continue" [ ";" ] .

MatchStmt       = "match" Expression "of" { MatchArm } [ "else" StatementSeq ] "end" [ ";" ] .
MatchArm        = MatchLabel { "," MatchLabel } ":" StatementSeq .
MatchLabel      = Expression [ ".." Expression ] .

ReturnStmt      = "return" [ Expression ] [ ";" ] .

GuardStmt       = "guard" StatementSeq
                  [ "except" StatementSeq ] [ "finally" StatementSeq ] "end" [ ";" ] .

RaiseStmt       = ( "throw" "(" Expression ")"
                  | "throwcode" "(" Expression "," Expression ")" ) [ ";" ] .

NewStmt         = "new" "(" Expression ")" [ ";" ] .
DisposeStmt     = "dispose" "(" Expression ")" [ ";" ] .
GetMemStmt      = "getmem" "(" Expression ")" [ ";" ] .
FreeMemStmt     = "freemem" "(" Expression ")" [ ";" ] .
ResizeMemStmt   = "resizemem" "(" Expression "," Expression ")" [ ";" ] .
SetLengthStmt   = "setlength" "(" Expression "," Expression ")" [ ";" ] .
PrintStmt       = ( "print" | "println" ) "(" [ Expression { "," Expression } ] ")" [ ";" ] .
```

> [!NOTE]
> **Empty statements.** A stray `;` where a statement is expected is a
> parse error (PAR006); the only place a bare `;` is tolerated is between
> `match` arms.

> [!NOTE]
> **Assignments and calls.** The target of an assignment is parsed as an
> expression (a designator, a dereference, an index, and so on). Any
> expression that is not followed by an assignment operator is a call
> statement. An inline `var` takes one full `VarDecl`, including an optional
> `external` clause.

> [!NOTE]
> **`print`/`println` are printf-style.** When the first argument is a string
> literal, it is a format string and the remaining arguments are consumed by
> its `%` specs, so `println("100%%")` prints `100%`. Otherwise every argument
> is printed with its default formatting. The
> accepted specs are `%d %i %u %x %X %f %e %E %g %G %s %c %p` and `%%`, with
> optional flags (`- + 0 #` and space), width, `.N` precision, and `h`/`l`
> length modifiers (`%lld` works); flags and width are accepted but ignored,
> `%i` acts as `%d`, and `%e %E %g %G` act as `%f`. The same spec set is used
> by the `format` intrinsic (Section 13). Every spec needs an argument and
> every argument a spec: a spec with no argument is error SEM009 at the call,
> an argument with no spec is error SEM009 at that argument. A `%` that starts
> no spec, such as a lone `%`, is printed as it is.

> [!NOTE]
> `break` and `continue` are valid only inside a `while`, `for`, or `repeat`
> body (compile error SEM004 otherwise). `break` exits the innermost loop;
> `continue` starts its next iteration. In a `for` loop, `continue` moves on
> to the next value; in a `repeat` loop, it tests the `until` condition.

> [!NOTE]
> **`for` loop variable.** If the identifier after `for` names an integer
> variable declared earlier in this module (a local or a module variable), the
> loop drives that variable: after the loop it holds the end value, the value
> `break` left it at, or its old value when the loop ran zero times. Otherwise
> the loop declares its own variable, scoped to the loop and typed from its
> bounds (the wider of the start and end types; `1 to 10` gives `int32`). Both
> bounds are evaluated once. Assigning to the loop variable in the body is
> compile error SEM017, and so is a loop name that is a parameter, a constant,
> an imported variable or the variable of an enclosing loop; a non-integer
> variable is SEM003.

> [!NOTE]
> **`while` loops have no `begin`.** The syntax is `while <expr> do <stmts> end` --
> the `do` keyword opens the body and `end` closes it. No `begin` is used.

> [!NOTE]
> **`guard`.** Both `except` and `finally` are optional. `guard` catches
> exceptions raised by `throw`, `throwcode`, and the runtime; wasm traps and
> JavaScript exceptions are not caught.

#### 🧪 Assert Statements (Unit Testing)

Assert statements are available in all code but are primarily used inside test blocks.
All assertions continue after failure -- failures accumulate and are reported per test.
The compiler handles all test infrastructure automatically. When `@unittestmode on;` is active, test blocks are compiled, registered, and executed by the built-in test runner.
The compiler injects source file and line number automatically.

```
AssertStmt      = ( "assert" "(" Expression [ "," Expression ] ")"
                  | "asserttrue" "(" Expression [ "," Expression ] ")"
                  | "assertfalse" "(" Expression [ "," Expression ] ")"
                  | "asserteq" "(" Expression "," Expression [ "," Expression ] ")"
                  | "asserteqf" "(" Expression "," Expression "," Expression [ "," Expression ] ")"
                  | "assertnil" "(" Expression [ "," Expression ] ")"
                  | "assertnotnil" "(" Expression [ "," Expression ] ")"
                  | "assertfail" "(" [ Expression ] ")" ) [ ";" ] .
```

- `assert(expr [, message])` -- Fails if `expr` is false.
- `asserttrue(expr [, message])` -- Fails if `expr` is not true.
- `assertfalse(expr [, message])` -- Fails if `expr` is not false.
- `asserteq(expected, actual [, message])` -- Fails if values are not equal. It takes the operand pairs `=` takes: two numbers are compared at the wider type, and any other pair must be one `=` can compare (error SEM003 at `actual` otherwise). Type-dispatched on the first operand: the compiler selects the comparison for string, wstring, float, bool, char, wchar, unsigned, pointer, or integer operands. The optional third argument is a message.
- `asserteqf(expected, actual, epsilon [, message])` -- Float equality within a tolerance. Fails if `|expected - actual| > epsilon`. All operands must be numbers and are converted to `float64`. The optional fourth argument is a message.
- `assertnil(expr [, message])` -- Fails if `expr` is not nil.
- `assertnotnil(expr [, message])` -- Fails if `expr` is nil.
- `assertfail(["message"])` -- Unconditional failure, with an optional message.

`assert`, `asserttrue` and `assertfalse` take a `bool`; `assertnil` and `assertnotnil` take a pointer, dynamic array, string or routine value. A message is a `string`, printed after the failure report as ` (message)`. A wrong number of arguments is error SEM009 at the assert; an argument of the wrong kind is error SEM003 at that argument.


<a id="bnf-expressions"></a>

### 🧮 12. Expressions

```
Expression      = SimpleExpr { RelOp SimpleExpr } .
RelOp           = "=" | "<>" | "<" | ">" | "<=" | ">=" | "in" .

SimpleExpr      = Term { AddOp Term } .
AddOp           = "+" | "-" | "or" | "xor" .

Term            = Factor { MulOp Factor } .
MulOp           = "*" | "/" | "div" | "mod" | "and" | "shl" | "shr" .

Factor          = "not" Factor | "-" Factor | "+" Factor
                | "address" "of" Factor | Primary .

Primary         = integer | float_literal | cstring | wstring
                | "true" | "false" | "nil"
                | SetLiteral | RecordLiteral
                | "(" Expression ")" { Selector }
                | Designator | Intrinsic | VarArgsAccess
                | TypeCast { Selector }
                | primitive .

Designator      = ident { Selector } .
Selector        = "." ident | "[" Expression "]" | "^" | "(" [ ArgList ] ")" .

ArgList         = Expression { "," Expression } .

SetLiteral      = "[" [ SetElement { "," SetElement } ] "]" .
SetElement      = Expression [ ".." Expression ] .

RecordLiteral   = ident "(" FieldInit { "," FieldInit } ")" .
FieldInit       = ident ":" Expression .

TypeCast        = primitive "(" Expression ")" .
```

> [!NOTE]
> **Operators are left-associative at every level**, relational included:
> `a < b = c` parses as `(a < b) = c`. **Unary operators** (`not`, `-`, `+`,
> `address of`) apply to a single factor, so `-a * b` is `(-a) * b` and
> `-a shr 1` is `(-a) shr 1`. **Type casts** use a built-in type
> keyword only (`int32(x)`, `float64(n)`); `Name(x)` with a user type name
> is a call. A bare built-in type name is a valid Primary so that
> `size(int32)` works. Selectors may follow a parenthesized expression or a
> cast: `(p^).x`, `int32(v)^`. A record literal uses an unqualified type name.

> [!NOTE]
> **Result types.** Relational operators and `in` yield `bool`. `not` is logical
> on a `bool` (result `bool`) and bitwise on an integer (result the operand's
> type: `not 5` is `-6`, and `not` of a `uint8` holding 5 is `250`); on any other
> operand it is error SEM003. `address of` yields an untyped pointer.
>
> **Comparing aggregates.** Records, overlays and static arrays cannot be
> compared with `=`, `<>`, the ordering operators or `match` (error SEM003): compare their
> fields or elements. Sets, strings, pointers and routine values compare with
> `=` and `<>`; dynamic arrays compare by reference.

#### 📍 Pointer Operations

- `address of expr` -- Returns a pointer to the operand.
- `expr^` -- Postfix (selector): dereference. Follows the pointer to its target.


<a id="bnf-intrinsics"></a>

### ⚡ 13. Intrinsics

```
Intrinsic       = LenExpr | SizeExpr | Utf8Expr | CStrExpr | WStrExpr
                | ParamCountExpr | ParamStrExpr | ExcCodeExpr | ExcMsgExpr
                | FormatExpr .

LenExpr         = "len" "(" Expression ")" .
SizeExpr        = "size" "(" Expression ")" .
Utf8Expr        = "utf8" "(" Expression ")" .
CStrExpr        = "cstr" "(" Expression ")" .
WStrExpr        = "wstr" "(" Expression ")" .
ParamCountExpr  = "paramcount" "(" ")" .
ParamStrExpr    = "paramstr" "(" Expression ")" .
ExcCodeExpr     = "exccode" "(" ")" .
ExcMsgExpr      = "excmsg" "(" ")" .
FormatExpr      = "format" "(" cstring { "," Expression } ")" .
```

| Intrinsic | Result type |
|---|---|
| `len`, `size`, `paramcount` | `int64` |
| `exccode` | `int32` |
| `paramstr`, `excmsg`, `format` | `string` |
| `utf8`, `cstr`, `wstr` | untyped pointer |

> [!NOTE]
> `format(fmt, ...)` builds a managed `string` from a printf-style format
> literal and its arguments, using the same `%` specs as `print`/`println`
> (Section 11). The format string must be a string literal (SEM003 otherwise).
> Calls nest freely: `format("%s!", format("%d", n))`.

> [!NOTE]
> `len` returns the length of strings, wide strings, and dynamic arrays.
> `size` returns the byte size of a type or expression, computed at compile
> time. Its argument is parsed as an expression, so type names work
> (`size(int32)`, `size(TPoint)`, `size(Module.T)`) but structural types such
> as `ptr to T` or `array ... of T` must be given a type name first. `utf8`
> converts a string to a newly allocated, raw UTF-8 buffer -- NOT a managed
> string; the buffer is owned by the caller. `cstr` returns a BORROWED raw
> UTF-8 pointer into an existing managed string's own storage -- it
> allocates nothing and must never be freed, and the pointer is valid only
> while the owning string is alive. `wstr` is the UTF-16 counterpart of
> `cstr`: it returns a BORROWED pointer to UTF-16 data that the runtime
> builds once and CACHES on the string itself, so repeat calls are free and
> the buffer must never be freed by the caller. Memory management
> (`new`/`dispose`/`getmem`/`freemem`/`resizemem`/`setlength`) is defined in
> Statements (Section 11).

> [!NOTE]
> Every intrinsic checks its arguments: a wrong number of arguments is error
> SEM009 at the call, and an argument of the wrong kind is error SEM003 at that
> argument. `len` takes a string, wide string or array; `utf8`, `cstr` and
> `wstr` take a `string` or `wstring`; `paramstr` takes an integer.


<a id="bnf-variadic-arguments"></a>

### 🧺 14. Variadic Arguments

```
ParamList       = ParamDecl { ";" ParamDecl } [ ";" "..." ] | "..." .

VarArgsAccess   = "varargs" "." "next" "(" TypeExpr ")"
                | "varargs" "." "get" "(" Expression "," TypeExpr ")"
                | "varargs" "." "reset" "(" ")"
                | "varargs" "." "copy" "(" ")"
                | "varargs" "." "count" .
```

- `varargs.next(TypeExpr)` -- Retrieves and consumes the next variadic argument. Result type is `TypeExpr`.
- `varargs.get(Expression, TypeExpr)` -- Retrieves the argument at the given zero-based index without advancing the cursor.
- `varargs.reset()` -- Resets the cursor back to the first argument.
- `varargs.count` -- Total number of variadic arguments passed (`int32`).
- `varargs.copy()` -- Returns a new `varargs` value: an independent copy of the pack including its cursor position. Assign it to a local of type `varargs`; it is released automatically when the routine exits.

> [!IMPORTANT]
> **Semantics.**
> - `...` is the only variadic marker and must be the last entry in the
>   parameter list. `varargs.*` is valid only inside a routine declared with
>   `...` (error SEM013 elsewhere).
> - Every packed argument carries its static type. A bare integer literal
>   packs as `int32`, or as `int64` when it does not fit in 32 bits; a float
>   literal packs as `float64`, or as `float32` when it has an `f`/`F` suffix;
>   a string literal packs as `string`.
> - `next(T)` and `get(i, T)` verify at runtime that the stored type is `T`
>   and that `i` is in range. A mismatch raises a runtime exception
>   (code 900 for type, 901 for index) with a descriptive message; there is
>   no C-style untyped access.
> - The pack is owned by the caller and released when the calling statement
>   completes. Strings inside the pack are reference-counted through it.

```
routine sum(...): int32;
var
  i: int32;
  total: int32;
begin
  total := 0;
  for i := 0 to varargs.count - 1 do
    total += varargs.next(int32);
  end;
  return total;
end;

// sum(1, 2, 3) = 6
```


<a id="bnf-unit-testing"></a>

### 🧪 15. Unit Testing

Test blocks appear after the module's `end.`. They are always parsed and
checked, and they are compiled and run only when the `@unittestmode on;`
directive is active in an `exe` module. When `@unittestmode on;` is active:

1. The compiler parses test blocks after `end.`
2. Each test block is compiled as a parameterless routine
3. The built-in test runner runs in place of the main body; the main body still has to be present (an `exe` without one is error SEM007) but its statements do not run

```
TestBlock     = "test" [ cstring ] [ ";" ] [ "var" { VarDecl } ]
                "begin" StatementSeq "end" [ ";" ] .
```

#### Example

Trimmed from `bin\res\tests\compliance\bnf_unittest_compliance.pxl`:

```
module exe bnf_unittest_compliance;

@unittestmode on;

var
  init_count: int32;

routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

routine mul(const a: int32; const b: int32): int32;
begin
  return a * b;
end;

initialize
  init_count := init_count + 1;
end;

finalize
  println("finalize ran");
end;

begin
  // Replaced by the test runner when @unittestmode is on. Reaching this
  // would be a failure.
  println("MAIN BLOCK MUST NOT RUN IN UNIT TEST MODE");
  asserteq(0, 1, "main block executed in unit test mode");
end.

test "integer arithmetic"
begin
  asserteq(3, add(1, 2));
  asserteq(0, add(-1, 1));
  asserteq(-3, add(-1, -2));
  asserteq(12, mul(3, 4));
  asserteq(0, mul(0, 99));
end;

test "initialize ran before tests"
begin
  asserteq(1, init_count, "initialize section runs once before the runner");
end;
```


<a id="bnf-operator-precedence-highest-to-lowest"></a>

### 🎚️ 16. Operator Precedence (Highest to Lowest)

| Precedence | Operators                                        |
|------------|--------------------------------------------------|
| 1 (highest)| `not` `-` (unary) `+` (unary) `address of`      |
| 2          | `*` `/` `div` `mod` `and` `shl` `shr`           |
| 3          | `+` `-` `or` `xor`                               |
| 4 (lowest) | `=` `<>` `<` `>` `<=` `>=` `in`                  |


<a id="bnf-output-model"></a>

### 🎯 17. Output Model

PIXELS compiles a module to wasm64 (memory64) and packages it according to the
module kind:

| Module kind | Output |
|---|---|
| `exe` | An Electron app: `app.asar` written to `bin\res\electron\<target>\resources\` |
| `lib` | `<outputpath>\<module>.wasm` (the `.wat` is left beside it); no JS, no Electron. It imports its memory and runtime from the `exe` that links it, so only a PIXELS `exe` build can use it |
| `unit` | No output; the module is only validated |

The output is named after the module name in the `module` header. The target is
`win-x64` (default) or `linux-x64`, chosen with the CLI `-t`/`--target` flag.

For an `exe`, `app.asar` contains:

1. **`output.wasm`** -- the compiled module. The generated `.wat` is assembled and
   optimized by wasm-opt; every linked PIXELS library (dependencies first) and
   every foreign external `.wasm` are merged in with wasm-merge. Each linked
   library's `initialize` runs before the exe's startup and its `finalize` after
   the exe's cleanup. A `lib` build merges nothing.
2. **`output.js`** -- the JS host layer: `runtime.js` (the WASI shim and the asset
   system) plus every external `.js` library resolved through `external`
   clauses, passed through esbuild.
3. **`index.html`** -- the page that loads `output.js`, fetches the asset view
   (`__assets.json`), then streams `output.wasm` from `pxl://app/` and
   instantiates it with its imports.
4. **`main.js`**, **`preload.js`**, **`package.json`** -- the Electron main
   process entry, which opens the window and loads `index.html`.

Assets declared with `@assets` are not placed inside `app.asar`; it holds only
`assets.json`, which maps each key to its file and MIME type. `debug` and
`release` builds serve the files in place from their source paths over
`pxl://app/<key>`; a `distro` build copies them to `resources/__assets/<key>`
beside `app.asar` inside the zip.

The build mode (`@buildmode`, or the CLI `-bm`/`--buildmode` flag) controls
optimization and packaging:

| Build mode | wasm-opt | JS | Packaging |
|---|---|---|---|
| `debug` (default) | `-O0` | not minified | app written into the Electron folder |
| `release` | `-O3` | minified | app written into the Electron folder, menu bar hidden, DevTools off |
| `distro` | `-O3` | minified | as `release`, then zipped |

A `distro` build copies the whole Electron folder, renames `electron(.exe)` to
the module name, applies the `@exeicon` icon and the `@vi*` version information (`win-x64`
only), and writes `<outputpath>\<module>-<target>.zip`. The CLI `-r`/`--run` flag
starts the built app with the bundled Electron after a `debug` or `release`
build; it is ignored for `distro` (warning CMP002).

> [!IMPORTANT]
> `debug` and `release` builds write into the shared
> `bin\res\electron\<target>\` folder and replace whatever app was built there
> before. Only a `distro` build produces a shippable file, the zip.

> [!TIP]
> 💡 The wasm module declares imports that `index.html` satisfies:
> `wasi_snapshot_preview1.*` for WASI calls (fd_write, clock_time_get, etc.)
> and one namespace per external JS library, named after the library.


<a id="bnf-grammar-validation-checklist"></a>

### 🧪 Grammar Validation Checklist

Use this checklist when updating the grammar or adding syntax:

- 🔤 Lexical rules define the token shape before parser rules depend on it
- 🚫 Reserved words are listed before examples rely on them
- 🧱 New type forms appear in both the type grammar and any reference sections
- 🔧 New routine syntax is reflected in declarations, statements, and examples where applicable
- 🧮 Operator changes update precedence and expression grammar together
- 🧪 Unit-test syntax matches the assertion helper documentation
- 🧭 Any new directive is added to the known directive table and the conditional compilation section
- 🎯 Directives that affect the build (`@buildmode`, `@outputpath`, `@assets`, `@exeicon`) stay consistent with the Output Model (Section 17)
- 📌 No defect is documented as a limitation: a bug found while writing docs goes into a plan and is fixed, and the docs describe the correct behavior. Only inherent limits of the design or platform (e.g. wasm32 = 4 GB) are documented as limits

> [!WARNING]
> 🧯 Keep grammar changes synchronized with examples. A grammar rule that accepts syntax not shown anywhere else is hard for users to discover, and an example that violates the grammar is worse than no example at all.

---

<p align="right"><a href="#bnf-grammar">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="standard-library"></a>

## 📦 7. Standard Library

> **The game-facing API**  
> Build loops, draw, read input, play media, store state, control the window, and integrate vendor libraries.


*Nine std modules and one vendor library ship with PIXELS - import one, call its routines, and the build wires its JavaScript shim into your game for you.*

PIXELS is a general-purpose, game-first language: write Pascal-style code, get a desktop game or app. Your program runs as an Electron app, and its page already has a canvas, an audio mixer, a gamepad API, a DOM, and persistent storage. The standard library is a set of thin PIXELS wrappers over these APIs, grouped the way a game uses them: `app` (lifecycle, game loop, window, timers), `canvas2d` (drawing), `input` (keyboard, mouse, gamepad), `audio`, `video`, `localstorage` (save data), `browser` (message box, web links), `dom` (page elements for menus and tools) and `sqlite3` (SQLite databases). For bigger games, a vendor library binds a full engine: `phaser` (Phaser 4.2.0).

Each std module is a `module unit` in `res/libs/std/` backed by a JavaScript shim of the same name; the two are paired so that `import canvas2d;` gives you the full HTML5 Canvas 2D surface with no configuration. Vendor libraries live one folder per library in `res/libs/vendor/`. Modules couple only through documented hook slots on the shared `PXL` object in runtime.js - they never reference each other's globals.

<!-- Source: repo/bin/res/libs/std/*.pxl (9 units), repo/bin/res/libs/vendor/phaser/phaser.pxl:16, runtime/runtime.js:23-53 -->

Every extern in every std module follows the marshalling contract described in [JavaScript Interop](#js-interop): geometry and time are `float64`, counts and handles are `int32`, strings cross as `ptr to char`, and JS objects live in a `PXL.handles()` table as `int32` aliases (0 = none). Routines that return text use a private `...Into(buf, bufSize)` extern plus a public wrapper that returns a `string`, so you only ever see the `string` form.

| Library | Kind | Public routines |
|---------|------|-----------------|
| `app` | std | 26 |
| `canvas2d` | std | 151 |
| `input` | std | 20 |
| `audio` | std | 29 |
| `video` | std | 23 |
| `localstorage` | std | 14 |
| `browser` | std | 2 |
| `dom` | std | 49 |
| `sqlite3` | std | 33 |
| `phaser` | vendor | 613 |


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🎞️ app -- Lifecycle, Loop, Window, Timers](#standard-library-app-lifecycle-loop-window-timers)
- [🖼️ canvas2d -- 2D Drawing](#standard-library-canvas2d-2d-drawing)
- [🎮 input -- Keyboard, Mouse, and Gamepad](#standard-library-input-keyboard-mouse-and-gamepad)
- [🔊 audio -- Sound Effects and Music](#standard-library-audio-sound-effects-and-music)
- [🎬 video -- Video Playback](#standard-library-video-video-playback)
- [💾 localstorage -- Persistent Storage](#standard-library-localstorage-persistent-storage)
- [💬 browser -- Message Box and Links](#standard-library-browser-message-box-and-links)
- [🧩 dom -- Page Elements](#standard-library-dom-page-elements)
- [🗄️ sqlite3 -- SQLite Databases](#standard-library-sqlite3-sqlite-databases)
- [🧰 Vendor Libraries](#standard-library-vendor-libraries)
- [🔗 Cross-Module Dependencies](#standard-library-cross-module-dependencies)
- [📋 Example-to-Module Map](#standard-library-example-to-module-map)

</details>

<a id="standard-library-app-lifecycle-loop-window-timers"></a>

### 🎞️ app -- Lifecycle, Loop, Window, Timers

*The application: keep the program alive, run a fixed-step game loop, control the window, and schedule timers.*

<!-- Source: repo/bin/res/libs/std/app.pxl:22-137; app.js:29-158; repo/src/PIXELS.Build.pas:584-620 (finish, close-request, _start) -->

A program whose main block returns without calling `app.Run` ends there: the page calls `_shutdown` and the program is over. `app.Run` keeps it alive. It registers your Update, Render and Shutdown routines and returns at once; after `_start` returns, the page's `requestAnimationFrame` drives the loop. Update runs at a fixed time step (default 60 per second), so movement and physics do not depend on the display rate. Render runs once per display refresh. The program ends through `app.Quit`, `app.Close`, an accepted window close, or a failure in any handler; the page then calls `_shutdown` from a clean stack, which runs your Shutdown routine once before the teardown.

```pxl
// app_loop.pxl -- fixed-step update + render
module exe app_loop;

@exeicon "$P:res/assets/icons/pixels.ico";

import 
  canvas2d,
  app;

var
  x: float64;
  updates: int64;

routine Update(const dt: float64);
begin
  x := x + 120.0 * dt;
  if x > 800.0 then
    x := 0.0;
  end;

  updates := updates + 1;
  if updates = 600 then
    app.Quit();
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#000");
  canvas2d.FillRect(0.0, 0.0, 800.0, 600.0);
  canvas2d.SetFillStyle("#0f0");
  canvas2d.FillRect(x, 280.0, 40.0, 40.0);
end;

routine Shutdown();
begin
  println("shutdown handler");
end;

begin
  x := 0.0;
  updates := 0;
  canvas2d.Init(800, 600);
  println("setup done, loop running");  
  app.Run(Update, Render, Shutdown);
end.
```

Any handler may be `nil`. `app.Run(nil, Render, Shutdown)` draws without an update step; with Update and Render both `nil` there is no loop, and the program lives on timers and window events alone.

#### Types

These are declared `public` in app.pxl; you pass ordinary routines with matching signatures.

| Type | Definition |
|------|------------|
| `UpdateProc` | `routine(const dt: float64)` -- fixed step, called 0..N times per tick |
| `RenderProc` | `routine()` -- once per display refresh |
| `ShutdownProc` | `routine()` -- called once, before the teardown |
| `EventProc` | `routine()` -- close request, resize, focus, visibility, timers |
| `Timer` | `int32` -- timer handle, 0 = none |

#### Lifecycle

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Run` | `(const update: UpdateProc; const render: RenderProc; const shutdown: ShutdownProc)` | Keep the program alive after the main block returns and start the loop. Only the first call counts. |
| `Quit` | `()` | End the program at the next clean point. The window stays open and shows the exit line. Inside a close handler it accepts the close. |
| `Close` | `()` | End the program and close the window. |
| `IsRunning` | `(): bool` | True from `Run` until the program ends; still true while paused. |
| `SetCloseHandler` | `(const handler: EventProc)` | Called when the player closes the window. The close is vetoed unless the handler calls `Quit` or `Close`. `nil` (the default) = a window close ends the program. |

#### Loop

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetTargetFPS` | `(const fps: float64)` | Fixed update rate (default 60); `dt` = 1 / fps. Values <= 0 are ignored. |
| `Time` | `(): float64` | Seconds since `Run`; 0 before `Run`. |
| `FPS` | `(): float64` | Measured display rate, refreshed every 0.5 s; 0 until the first sample. |
| `Pause` | `()` | Stop calling Update and Render. Timers and window events keep firing. |
| `Resume` | `()` | Restart the loop, with no catch-up for the paused time. |
| `IsPaused` | `(): bool` | True between `Pause` and `Resume`. |

#### Window

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetTitle` | `(const title: ptr to char)` | Set the window title (the page title and the native title bar). |
| `GetTitle` | `(): string` | Current window title. |
| `SetSize` | `(const w: float64; const h: float64)` | Set the window content size, in CSS pixels. |
| `Width`, `Height` | `(): float64` | Current content width / height, in CSS pixels. |
| `SetFullscreen` | `(const on: bool)` | Enter or leave fullscreen. |
| `IsFullscreen` | `(): bool` | True while fullscreen. |
| `HasFocus` | `(): bool` | True while the window has keyboard focus. |
| `IsVisible` | `(): bool` | False while the page is hidden (`document.hidden`). |
| `SetResizeHandler` | `(const handler: EventProc)` | Called when the window is resized; read `Width` / `Height` inside. `nil` = off. |
| `SetFocusHandler` | `(const handler: EventProc)` | Called when the window gains or loses focus; read `HasFocus` inside. `nil` = off. |
| `SetVisibilityHandler` | `(const handler: EventProc)` | Called when the page is hidden or shown; read `IsVisible` inside. `nil` = off. |

#### Timers

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `After` | `(const ms: float64; const handler: EventProc): Timer` | Call `handler` once after `ms` milliseconds. Returns 0 if `handler` is `nil` or the program has ended. |
| `Every` | `(const ms: float64; const handler: EventProc): Timer` | Call `handler` every `ms` milliseconds until cancelled. |
| `Cancel` | `(const timer: Timer)` | Stop a timer. 0, an unknown handle or a one-shot timer that already fired is ignored. |

Loop details: each tick first snapshots input, then runs Update at the fixed step -- at most 8 steps per tick, with the elapsed time clamped to 0.1 s after a stall (excess time is dropped) -- then calls Render once, skipped while the page is hidden. `Quit` or `Pause` inside Update ends that tick's remaining updates and skips its Render. Every live timer is cleared when the program ends.

> [!TIP]
> **`_start` returns immediately.** Unlike a native program, the PIXELS entry point sets up state, calls `app.Run`, then returns. The page's animation loop takes over. This is the normal lifecycle for any graphical PIXELS game.


<a id="standard-library-canvas2d-2d-drawing"></a>

### 🖼️ canvas2d -- 2D Drawing

*The full HTML5 Canvas 2D API, DPI-aware, with convenience wrappers for common shapes.*

<!-- Source: repo/bin/res/libs/std/canvas2d.pxl:18-609; canvas2d.js:81, 125, 135, 149 -->

`canvas2d.Init(w, h)` creates a canvas at the given logical size. The backing store is scaled by `devicePixelRatio` automatically -- you work in CSS pixels and the output is sharp on every display. Colours, fonts, and enum-like properties are CSS strings; the module provides named constants so you never write a magic string. Images are `Image` handles: `LoadImage(assetKey)` returns one at once, and it can be drawn once `ImageReady` is true.

```pxl
// house.pxl -- static 2D drawing (trimmed)
module exe house;

import
  canvas2d;

begin
  canvas2d.Init(800, 600);
  canvas2d.Clear(100, 149, 237);                    // sky
  canvas2d.Rect(0, 400, 800, 200, 34, 139, 34);     // ground
  canvas2d.Rect(250, 250, 200, 150, 178, 102, 51);  // house
  canvas2d.Circle(650, 100, 60, 255, 223, 0);       // sun
  println("Canvas demo rendered.");
end.
```

#### Types

| Type | Kind | Purpose |
|------|------|---------|
| `Gradient` | `int32` handle | JS `CanvasGradient`; release with `GradientRelease` |
| `Pattern` | `int32` handle | JS `CanvasPattern`; release with `PatternRelease` |
| `Path` | `int32` handle | JS `Path2D`; release with `PathRelease` |
| `ImageData` | `int32` handle | JS `ImageData`; release with `ImageDataRelease` |
| `TextMetrics` | record, 12 × `float64` | Width, bounding boxes, baselines |
| `Matrix` | record, 6 × `float64` | DOMMatrix fields a..f |

#### Constants

88 public constants. All are `string` constants matching CSS values except the `TEXT_PROP_*` group, which are `int32` selectors 0..9. Use the string constants with the corresponding Set* routines.

| Group | Count | Examples |
|-------|-------|---------|
| Line cap | 3 | `LINE_CAP_BUTT`, `LINE_CAP_ROUND`, `LINE_CAP_SQUARE` |
| Line join | 3 | `LINE_JOIN_MITER`, `LINE_JOIN_ROUND`, `LINE_JOIN_BEVEL` |
| Fill rule | 2 | `FILL_RULE_NON_ZERO`, `FILL_RULE_EVEN_ODD` |
| Text align | 5 | `TEXT_ALIGN_START` .. `TEXT_ALIGN_CENTER` |
| Text baseline | 6 | `BASELINE_TOP` .. `BASELINE_BOTTOM` |
| Direction | 3 | `DIRECTION_LTR`, `DIRECTION_RTL`, `DIRECTION_INHERIT` |
| Font kerning | 3 | `KERNING_AUTO`, `KERNING_NORMAL`, `KERNING_NONE` |
| Font stretch | 9 | `STRETCH_ULTRA_CONDENSED` .. `STRETCH_ULTRA_EXPANDED` |
| Font variant caps | 7 | `VARIANT_CAPS_NORMAL` .. `VARIANT_CAPS_TITLING` |
| Text rendering | 4 | `RENDERING_AUTO` .. `RENDERING_GEOMETRIC_PRECISION` |
| Placement | 4 | `PLACE_FLOW`, `PLACE_CENTER`, `PLACE_FILL`, `PLACE_WINDOW` |
| Text property (int) | 10 | `TEXT_PROP_FONT` (0) .. `TEXT_PROP_TEXT_RENDERING` (9) |
| Smoothing quality | 3 | `SMOOTHING_LOW`, `SMOOTHING_MEDIUM`, `SMOOTHING_HIGH` |
| Composite operation | 26 | `COMPOSITE_SOURCE_OVER` .. `COMPOSITE_LUMINOSITY` |

#### Routines by Category

151 public routines: 133 direct externs plus 18 PIXELS-side wrappers.

**Setup and canvas element**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Init` | `(const w: int32; const h: int32)` | Create a canvas at logical size |
| `InitOn` | `(const id: ptr to char; const w: int32; const h: int32): bool` | Attach to an existing DOM element |
| `Resize` | `(const w: int32; const h: int32)` | Resize the canvas |
| `Width` / `Height` | `(): int32` | Logical canvas size |
| `ViewportWidth` / `ViewportHeight` | `(): int32` | Window inner size |
| `SetBackground` | `(const css: ptr to char)` | Page background colour |
| `SetPlacement` | `(const mode: ptr to char)` | `PLACE_FLOW` / `CENTER` / `FILL` / `WINDOW` |

**State:** `Save`, `Restore`, `Reset`. `Reset` clears the canvas and restores every default setting; display scaling is kept.

**Rectangles:** `ClearRect`, `FillRect`, `StrokeRect` -- all `(x, y, w, h: float64)`

**Path building:** `BeginPath`, `ClosePath`, `MoveTo`, `LineTo`, `Arc`, `ArcTo`, `BezierCurveTo`, `QuadraticCurveTo`, `Ellipse`, `PathRect`, `RoundRect`, `RoundRect4`

**Path drawing:** `Fill`, `FillRule`, `Stroke`, `Clip`, `ClipRule`, plus Path2D variants (`FillPath`, `FillPathRule`, `StrokePath`, `ClipPath`) and hit-testing (`IsPointInPath`, `IsPointInPathRule`, `IsPointInStroke`, `IsPointInPath2D`, `IsPointInStroke2D`)

**Path2D objects:** `PathCreate`, `PathCreateSVG`, `PathRelease`, `PathMoveTo`, `PathLineTo`, `PathArc`, `PathArcTo`, `PathBezierCurveTo`, `PathQuadraticCurveTo`, `PathEllipse`, `PathAddRect`, `PathRoundRect`, `PathClosePath`, `PathAddPath`

**Line styles:** `SetLineWidth`, `GetLineWidth`, `SetLineCap`, `SetLineJoin`, `SetMiterLimit`, `SetLineDash`, `SetLineDashOffset`

**Fill and stroke style:** `SetFillStyle`, `SetStrokeStyle`, `SetFillRGB`, `SetStrokeRGB`, `SetFillGradient`, `SetStrokeGradient`, `SetFillPattern`, `SetStrokePattern`

**Gradients and patterns:** `CreateLinearGradient`, `CreateRadialGradient`, `CreateConicGradient`, `AddColorStop`, `CreatePattern`, `GradientRelease`, `PatternRelease`

**Compositing:** `SetGlobalAlpha`, `GetGlobalAlpha`, `SetGlobalCompositeOperation`, `SetFilter`

**Shadows:** `SetShadowColor`, `SetShadowBlur`, `SetShadowOffsetX`, `SetShadowOffsetY`

**Text:** `SetFont`, `SetTextAlign`, `SetTextBaseline`, `SetDirection`, `SetLetterSpacing`, `SetWordSpacing`, `SetFontKerning`, `SetFontStretch`, `SetTextRendering`, `SetFontVariantCaps`, `FillText`, `FillTextMax`, `StrokeText`, `StrokeTextMax`, `MeasureTextWidth`, `FillTextLines`, `StrokeTextLines`, `FillTextWrapped`, `StrokeTextWrapped`, `LoadFont`, `FontsReady`

**Transforms:** `Translate`, `Rotate`, `Scale`, `Transform`, `SetTransform`, `ResetTransform`

**Images:** `LoadImage`, `ImageReady`, `ReleaseImage`, `DrawImageAt`, `DrawImageSize`, `DrawImageRect`, `DrawImageScaled`, `SetImageSmoothingEnabled`, `SetImageSmoothingQuality`, `ImageWidth`, `ImageHeight`

**Pixel data (ImageData):** `CreateImageData`, `GetImageData`, `ImageDataWidth`, `ImageDataHeight`, `ImageDataRead`, `ImageDataWrite`, `PutImageData`, `PutImageDataDirty`, `ImageDataRelease`

**Convenience wrappers:** `Clear(r, g, b)`, `Rect(x, y, w, h, r, g, b)`, `Circle(x, y, radius, r, g, b)`, `Line(x1, y1, x2, y2, r, g, b, width)`, `DrawImage(img, x, y, w, h)` (all `int32` arguments, kept for the existing demos), plus `MeasureText(text, var m)`, `GetTransform(var m)`, `ToDataURL(mime): string`, and ten text-property getters (`GetFont` .. `GetTextRendering`)

> [!NOTE]
> **Placement modes.** `PLACE_FLOW` (default) puts the canvas in the page flow alongside the developer console. `PLACE_CENTER` centres it at a fixed size (splash screens). `PLACE_FILL` letterboxes to the window at the logical resolution (games). `PLACE_WINDOW` makes the logical size follow the window (apps, dashboards). See `examples/responsive_canvas.pxl` for a PLACE_WINDOW demo.

> [!NOTE]
> **Similar names.** `canvas2d.Rect` is the `int32` convenience wrapper that fills a coloured rectangle; `canvas2d.PathRect` adds a rectangle to the current path. The `PLACE_*` constants exist in both `canvas2d` and `video` with the same values.

> [!NOTE]
> **Everything scales with the display.** Every length the program gives canvas2d is in logical pixels, including the lengths inside a `SetFilter` string (`blur(5px)`, `drop-shadow(2px 2px 4px black)`) and the shadow blur and offsets: at a 150% display scale all of them come out 1.5x, like the drawing itself. A resize or a display-scale change (another monitor, zoom) keeps every setting and the transform.


<a id="standard-library-input-keyboard-mouse-and-gamepad"></a>

### 🎮 input -- Keyboard, Mouse, and Gamepad

*Snapshotted once per tick: Down (held), Pressed (just went down), Released (just went up).*

<!-- Source: repo/bin/res/libs/std/input.pxl:21-123; input.js:67-71, 89, 131, 169 -->

The input module reads keyboard, mouse, and gamepad state. State is snapshotted at the top of every `app.Run` tick (via the `PXL.onTick` hook) so it is consistent for the entire Update call. Keys are physical USB HID codes -- layout-independent. Mouse position is in canvas pixels and requires `canvas2d.Init` (or `InitOn`); the context menu is suppressed on the canvas. Gamepads 0..3 use the standard mapping with a configurable radial deadzone on sticks.

```pxl
// input_square.pxl -- keyboard + mouse input (trimmed)
module exe input_square;

import
  canvas2d,
  app,
  input;

const
  W = 800;
  H = 600;
  SPEED = 200.0;

var
  x: float64;
  y: float64;

routine Update(const dt: float64);
begin
  if input.KeyDown(input.KEY_LEFT) then
    x := x - SPEED * dt;
  end;
  if input.KeyDown(input.KEY_RIGHT) then
    x := x + SPEED * dt;
  end;
  if input.MousePressed(input.MOUSE_LEFT) then
    x := input.MouseX();
    y := input.MouseY();
  end;
  if input.KeyPressed(input.KEY_ESCAPE) then
    app.Quit();
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#000");
  canvas2d.FillRect(0.0, 0.0, 800.0, 600.0);
  canvas2d.SetFillStyle("#0f0");
  canvas2d.FillRect(x - 20.0, y - 20.0, 40.0, 40.0);
end;

begin
  x := 400.0;
  y := 300.0;
  canvas2d.Init(W, H);
  canvas2d.SetPlacement(canvas2d.PLACE_FILL);  
  app.SetTitle("PIXELS: Input");    
  app.Run(Update, Render, nil);
end.
```

#### Constants

| Group | Count | Notes |
|-------|-------|-------|
| `KEY_*` | 103 | USB HID usage codes (page 0x07). `KEY_A`..`KEY_Z`, `KEY_0`..`KEY_9`, `KEY_ENTER`, `KEY_ESCAPE`, `KEY_SPACE`, punctuation, F1..F12, navigation and arrow keys, numpad, modifiers (`KEY_CONTROL_LEFT` .. `KEY_META_RIGHT`). |
| `MOUSE_*` | 5 | `MOUSE_LEFT`, `MOUSE_MIDDLE`, `MOUSE_RIGHT`, `MOUSE_BACK`, `MOUSE_FORWARD` |
| `PAD_*` | 17 | Standard gamepad buttons: `PAD_A`/`B`/`X`/`Y`, bumpers, triggers, back/start, sticks, d-pad, guide |
| `AXIS_*` | 4 | `AXIS_LEFT_X`, `AXIS_LEFT_Y`, `AXIS_RIGHT_X`, `AXIS_RIGHT_Y` |

#### Routines

**Keyboard**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `KeyDown` | `(const key: int32): bool` | Held during this tick |
| `KeyPressed` | `(const key: int32): bool` | Went down since previous tick |
| `KeyReleased` | `(const key: int32): bool` | Went up since previous tick |
| `AnyKeyPressed` | `(): bool` | Any key went down |

**Mouse**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `MouseDown` / `MousePressed` / `MouseReleased` | `(const button: int32): bool` | Button state |
| `MouseX` / `MouseY` | `(): float64` | Canvas-pixel position |
| `MouseDeltaX` / `MouseDeltaY` | `(): float64` | Movement since previous tick |
| `MouseWheel` | `(): float64` | Scroll amount (positive = down) |

**Gamepad**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `GamepadConnected` | `(const pad: int32): bool` | Gamepad 0..3 present |
| `GamepadDown` / `GamepadPressed` / `GamepadReleased` | `(const pad: int32; const button: int32): bool` | Button state |
| `GamepadButtonValue` | `(const pad: int32; const button: int32): float64` | 0..1 (analog triggers) |
| `GamepadAxis` | `(const pad: int32; const axis: int32): float64` | -1..1 with deadzone |
| `GamepadAxisRaw` | `(const pad: int32; const axis: int32): float64` | -1..1 raw |
| `SetDeadzone` | `(const dz: float64)` | Radial deadzone for sticks, clamped to 0..0.99 |

> [!TIP]
> **Input needs both app and canvas2d.** State is snapshotted by `PXL.onTick`, which app.js fires at the top of every tick of the `app.Run` loop. Mouse coordinates are mapped through `PXL.canvas` and `PXL.canvasDpr`, which `canvas2d.Init` sets. Without both, input routines return stale or zero values.

> [!NOTE]
> **`input.KEY_*` are not `phaser.KEY_*`.** `input` key constants are USB HID codes (`input.KEY_A` = 4); the `phaser` vendor library uses DOM keyCodes (`phaser.KEY_A` = 65). Pass each module its own constants.


<a id="standard-library-audio-sound-effects-and-music"></a>

### 🔊 audio -- Sound Effects and Music

*Decoded sound effects with per-voice control, plus one streamed music track at a time.*

<!-- Source: repo/bin/res/libs/std/audio.pxl:22-111; audio.js:29-33, 113, 128, 162 -->

Sounds are short audio clips loaded from `@assets` files and fully decoded into memory. Each `Play` starts a Voice -- an active instance you can stop, pan, or pitch-shift independently. Multiple Voices can play the same Sound simultaneously. Music is a single streamed track (one at a time) with transport controls and a fade function. Three gain buses -- master, sfx, and music -- let you mix volumes globally.

```pxl
// audio_player.pxl -- loading and playing audio (trimmed)
module exe audio_player;

import 
  audio,
  canvas2d,
  app,
  input;

@assets "$P:res/assets/audio" "assets/audio" "*.ogg";

var
  sfx: audio.Sound;
  song: audio.Music;

routine Update(const dt: float64);
begin
  if input.KeyPressed(input.KEY_ESCAPE) then
    app.Quit();
  end;
  if input.KeyPressed(input.KEY_1) then
    audio.Play(sfx);
  end;
  if input.KeyPressed(input.KEY_M) then
    if audio.IsMusicPlaying() then
      audio.StopMusic();
    else
      audio.PlayMusic(song, true);
    end;
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#101820");
  canvas2d.FillRect(0.0, 0.0, 800.0, 600.0);
end;

begin
  canvas2d.Init(800, 600);
  sfx := audio.LoadSound("assets/audio/sfx/samp0.ogg");
  song := audio.LoadMusic("assets/audio/music/song01.ogg");
  app.Run(Update, Render, nil);
end.
```

The full example (`examples/audio_player.pxl`) plays sfx on keys 1-5, toggles a looping engine voice with Space (pitch follows the mouse X), and streams music with M/P/F controls.

#### Types

| Type | Kind | Purpose |
|------|------|---------|
| `Sound` | `int32` handle | Decoded audio buffer; 0 = none |
| `Voice` | `int32` handle | Active playing instance; 0 = none |
| `Music` | `int32` handle | Streamed track; 0 = none |

#### Routines

**Context**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Unlock` | `(): bool` | Resume audio context; true when running |
| `IsReady` | `(): bool` | All LoadSound decodes finished |

**Sounds (sfx)**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `LoadSound` | `(const asset: ptr to char): Sound` | Load by asset key; 0 if missing |
| `ReleaseSound` | `(const s: Sound)` | Free the decoded buffer |
| `Play` | `(const s: Sound): Voice` | Play at default settings (vol 1, pitch 1, centre pan, no loop) |
| `PlayEx` | `(const s: Sound; const volume: float64; const pitch: float64; const pan: float64; const loop: bool): Voice` | Full control |
| `StopVoice` | `(const v: Voice)` | Stop a playing instance |
| `SetVoiceVolume` | `(const v: Voice; const volume: float64)` | |
| `SetVoicePan` | `(const v: Voice; const pan: float64)` | -1 (left) .. 1 (right) |
| `SetVoicePitch` | `(const v: Voice; const pitch: float64)` | Playback rate; 1.0 = normal |
| `IsVoicePlaying` | `(const v: Voice): bool` | False once ended or stopped |
| `StopAllSounds` | `()` | Stop every active Voice |

**Music**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `LoadMusic` | `(const asset: ptr to char): Music` | Streamed by asset key; 0 if missing |
| `ReleaseMusic` | `(const m: Music)` | |
| `PlayMusic` | `(const m: Music; const loop: bool)` | Start from beginning; stops the current track |
| `StopMusic` / `PauseMusic` / `ResumeMusic` | `()` | Transport controls |
| `IsMusicPlaying` | `(): bool` | |
| `MusicPosition` / `MusicDuration` | `(): float64` | Seconds; duration is 0 until the page knows |
| `SeekMusic` | `(const seconds: float64)` | |
| `FadeMusic` | `(const toVolume: float64; const seconds: float64)` | Ramp the music bus |

**Buses**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetMasterVolume` / `GetMasterVolume` | `(const volume: float64)` / `(): float64` | 0..1 |
| `SetSfxVolume` / `GetSfxVolume` | same | |
| `SetMusicVolume` / `GetMusicVolume` | same | |

> [!NOTE]
> **Sound from the first frame.** A PIXELS app plays sound as soon as it asks, like a native game: `Play` and `PlayMusic` work from the first frame, with no click or key press needed first. `Unlock()` reports whether audio is live. A missing asset logs a console warning and returns 0.


<a id="standard-library-video-video-playback"></a>

### 🎬 video -- Video Playback

*Load an embedded or external video, then draw it onto the canvas or show it as a page element.*

<!-- Source: repo/bin/res/libs/std/video.pxl:23-109; video.js:14, 101, 115-116, 156, 161; repo/src/PIXELS.Build.pas:1383 (DoWriteAssetManifest), 1848 (distro zip) -->

The video module wraps `HTMLVideoElement`. Load a clip from an `@assets` file (.mp4 or .webm) or an external URL, then choose one of two rendering modes: **Draw** paints the current frame onto the canvas2d surface every render tick (composited with your own drawing), or **Show** places the video element itself in the page using the same `PLACE_*` modes as canvas2d. `debug` and `release` builds serve clips in place; a `distro` build copies them as plain files into `resources/__assets/`, so they add only their own size.

```pxl
// video_player.pxl -- loading and playing video (trimmed)
module exe video_player;

import
  canvas2d,
  app,
  input,
  video;

@assets "$P:res/assets/video" "assets/video" "intro.mp4";

var
  clip: video.Video;

routine Update(const dt: float64);
begin
  if input.KeyPressed(input.KEY_ESCAPE) then
    app.Quit();
  end;
  if input.KeyPressed(input.KEY_SPACE) then
    if video.IsPlaying(clip) then
      video.Pause(clip);
    else
      video.Play(clip);
    end;
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#000000");
  canvas2d.FillRect(0.0, 0.0, 960.0, 600.0);
  video.Draw(clip, 20.0, 200.0, 640.0, 360.0);
end;

begin
  canvas2d.Init(960, 600);
  clip := video.Load("assets/video/intro.mp4");
  app.Run(Update, Render, nil);
end.
```

In the render callback, either `video.Draw(clip, x, y, w, h)` to composite on your canvas, or call `video.Show(clip, video.PLACE_CENTER)` once to show the element itself (`video.Hide` removes it). The full example (`examples/video_player.pxl`) toggles between the two with D.

#### Types and Constants

| Name | Kind | Purpose |
|------|------|---------|
| `Video` | `int32` handle | HTMLVideoElement; 0 = none |
| `PLACE_FLOW` / `PLACE_CENTER` / `PLACE_FILL` / `PLACE_WINDOW` | `string` | Same placement modes as canvas2d |

#### Routines

**Lifetime**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Load` | `(const asset: ptr to char): Video` | Load by asset key; 0 if missing |
| `LoadURL` | `(const url: ptr to char): Video` | External URL, loaded with `crossOrigin = anonymous` (canvas drawing needs CORS) |
| `Release` | `(const v: Video)` | Free the handle |

**Transport**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Play` / `Pause` / `Stop` | `(const v: Video)` | Stop pauses and rewinds to 0 |
| `Seek` | `(const v: Video; const seconds: float64)` | |
| `SetVolume` | `(const v: Video; const volume: float64)` | 0..1 |
| `SetLoop` / `SetMuted` | `(const v: Video; const value: bool)` | |
| `SetPlaybackRate` | `(const v: Video; const rate: float64)` | 1.0 = normal |

**State**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `IsReady` | `(const v: Video): bool` | Metadata loaded, frames available |
| `IsPlaying` / `IsEnded` / `IsMuted` | `(const v: Video): bool` | |
| `Position` / `Duration` | `(const v: Video): float64` | Seconds; duration is 0 until metadata loads |
| `Width` / `Height` | `(const v: Video): int32` | 0 until metadata loads |

**Rendering**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Draw` | `(const v: Video; const dx: float64; const dy: float64; const dw: float64; const dh: float64)` | Paint current frame onto canvas2d |
| `DrawRect` | `(const v: Video; const sx: float64; const sy: float64; const sw: float64; const sh: float64; const dx: float64; const dy: float64; const dw: float64; const dh: float64)` | Source rect to dest rect |
| `Show` | `(const v: Video; const mode: ptr to char)` | Place the element in the page |
| `Hide` | `(const v: Video)` | Remove the element |

> [!NOTE]
> **Sound from the first frame.** As with audio, playback starts at once, with sound, and needs no user gesture.


<a id="standard-library-localstorage-persistent-storage"></a>

### 💾 localstorage -- Persistent Storage

*Key-value persistence backed by `window.localStorage`, scoped to your app - ideal for save data and high scores.*

<!-- Source: repo/bin/res/libs/std/localstorage.pxl:20-106; localstorage.js:14, 22-26 -->

The localstorage module provides simple string and typed key-value storage that survives page reloads. Keys are automatically prefixed with `PXL.moduleName + ":"` (your project name), so multiple PIXELS programs that share a storage origin never collide. Nothing raises -- a missing key returns your default, a failed write returns `false`.

```pxl
// run_counter.pxl -- persistent run counter (trimmed)
module exe run_counter;

import 
  localstorage;

var 
  runs: int64;

begin
  runs := localstorage.GetInt("runs", 0) + 1;
  localstorage.SetInt("runs", runs);
  println("runs = %lld (reload the page: this must increment)", runs);
end.
```

#### Routines

**Core**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Available` | `(): bool` | Probes localStorage with a throwaway key |
| `SetItem` | `(const key: ptr to char; const value: ptr to char): bool` | False on quota or security error |
| `GetItem` | `(const key: string; const default: string): string` | Returns `default` if key missing |
| `RemoveItem` | `(const key: ptr to char)` | |
| `Clear` | `()` | Removes only this app's prefixed keys |
| `Length` | `(): int32` | Count of this app's keys |
| `Key` | `(const index: int32): string` | Empty string if out of range |
| `HasItem` | `(const key: ptr to char): bool` | |

**Typed helpers**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetInt` / `GetInt` | `(const key: ptr to char; const value: int64): bool` / `(const key: ptr to char; const default: int64): int64` | Shim converts to/from text |
| `SetFloat` / `GetFloat` | `(const key: ptr to char; const value: float64): bool` / `(const key: ptr to char; const default: float64): float64` | |
| `SetBool` / `GetBool` | `(const key: ptr to char; const value: bool): bool` / `(const key: ptr to char; const default: bool): bool` | |

> [!TIP]
> **Isolation.** Every PIXELS app is served from the same origin, `pxl://app/`, but each app keeps its storage in its own data folder, named after the program. The key prefix is a second guard: `Length`, `Key` and `Clear` only ever see and remove this program's keys.


<a id="standard-library-browser-message-box-and-links"></a>

### 💬 browser -- Message Box and Links

*Show a message box, or open a web page in the player's browser.*

<!-- Source: repo/bin/res/libs/std/browser.pxl:19-28; browser.js:18-41; repo/src/PIXELS.Build.pas (PXL_ELECTRON_MAIN_JS: openWebUrl, open-url) -->

`Alert` shows a native message box over the game window and blocks until the player dismisses it. `OpenURL` opens an `http` or `https` page in the player's default browser; any other scheme is refused. The window title and closing the window live in the [app](#standard-library-app-lifecycle-loop-window-timers) module.

```pxl
// browser services
module exe links;

import
  browser;

begin
  if not browser.OpenURL("https://getpixels.org") then
    browser.Alert("Could not open the link.");
  end;
end.
```

#### Routines

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Alert` | `(const AMessage: ptr to char)` | Show a native message box; blocks until dismissed |
| `OpenURL` | `(const AURL: ptr to char): bool` | Open an http(s) URL in the player's default browser; false if it was not opened (another scheme, or not running in Electron) |

> [!NOTE]
> **`Alert` blocks the JavaScript thread.** Nothing else runs, including the `app.Run` loop and timers, until the player dismisses it.


<a id="standard-library-dom-page-elements"></a>

### 🧩 dom -- Page Elements

*Build HTML menus, HUDs, and tool panels with element handles and poll-model events.*

<!-- Source: repo/bin/res/libs/std/dom.pxl:16-273; dom.js:18-402 -->

The dom module creates and edits page elements from PIXELS: create an element, style it, append it to the page, and listen for events. Every element is an `Element` handle (`int32`, 0 = none). Events use a **poll model** that fits the game loop: `Listen` starts queueing events of one type on one element, and in Update you drain the queue with `NextEvent`, which pops the oldest event into a "last event" slot that `EventX`, `EventY`, `EventKeyCode`, `EventButton`, and `EventValue` read. Every shim entry is wrapped in `try`/`catch` and returns 0 or `""` on failure.

```pxl
// dom_playground.pxl -- build elements, poll events (trimmed)
module exe dom_playground;

import 
  dom,
  app,
  input;

var
  body:        dom.Element;
  statsElem:   dom.Element;
  btnAdd:      dom.Element;
  totalClicks: int32;

routine Update(const dt: float64);
begin
  // ESC quits
  if input.KeyPressed(input.KEY_ESCAPE) then
    app.Quit();
    return;
  end;

  while dom.NextEvent(btnAdd, "click") do
    totalClicks := totalClicks + 1;
    dom.SetText(statsElem, format("%d clicks", totalClicks));
  end;
end;

routine Render();
begin
  // DOM rendering is immediate -- nothing to batch
end;

routine Shutdown();
begin
  dom.Remove(btnAdd);
  dom.Remove(statsElem);
  dom.Release(body);
end;

begin
  totalClicks := 0;
  body := dom.Body();

  // app mode: hides the dev console while running; runtime removes it on exit
  dom.AddClass(body, "pxl-app");

  statsElem := dom.Create("div");
  dom.SetStyle(statsElem, "font-size", "15px");
  dom.AppendTo(statsElem, body);

  btnAdd := dom.Create("button");
  dom.SetText(btnAdd, "+ Add Row");
  dom.Listen(btnAdd, "click");
  dom.AppendTo(btnAdd, body);

  app.Run(Update, Render, Shutdown);
end.
```

#### Types

| Type | Kind | Purpose |
|------|------|---------|
| `Element` | `int32` handle | DOM element; 0 = none |

#### Routines

49 public routines. Unless noted, the first parameter is `const elem: Element`.

**Lifecycle and tree**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Create` | `(const tag: ptr to char): Element` | New detached element |
| `Query` | `(const selector: ptr to char): Element` | First match of a CSS selector; 0 if none |
| `Body` | `(): Element` | The page `<body>` |
| `Release` | `(elem)` | Free the handle and remove its listeners |
| `Remove` | `(elem)` | Detach from the page, then release the handle |
| `AppendTo` | `(const child: Element; const parent: Element)` | |
| `InsertBefore` | `(const newNode: Element; const ref: Element)` | |
| `Clone` | `(elem): Element` | Deep copy |
| `Parent` / `FirstChild` / `NextSibling` | `(elem): Element` | Element navigation; 0 at the end |
| `ChildCount` | `(elem): int32` | |

**Attributes and content**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetAttr` / `GetAttr` | `(elem; const attrName: ptr to char; const value: ptr to char)` / `(elem; const attrName: ptr to char): string` | |
| `RemoveAttr` / `HasAttr` | `(elem; const attrName: ptr to char)` / `...: bool` | |
| `SetText` / `GetText` | `(elem; const text: ptr to char)` / `(elem): string` | Text content |
| `SetHTML` / `GetHTML` | `(elem; const html: ptr to char)` / `(elem): string` | Inner HTML |
| `SetValue` / `GetValue` | `(elem; const val: ptr to char)` / `(elem): string` | Form control value |

**Style and classes**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `SetStyle` / `GetStyle` | `(elem; const prop: ptr to char; const val: ptr to char)` / `(elem; const prop: ptr to char): string` | Inline CSS property |
| `AddClass` / `RemoveClass` / `ToggleClass` | `(elem; const cls: ptr to char)` | |
| `HasClass` | `(elem; const cls: ptr to char): bool` | |

**State and geometry**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Show` / `Hide` / `IsVisible` | `(elem)` / `(elem): bool` | Hide sets `display: none`; Show clears it |
| `Focus` / `Blur` | `(elem)` | |
| `Enable` / `Disable` / `IsEnabled` | `(elem)` / `(elem): bool` | |
| `GetX` / `GetY` / `GetWidth` / `GetHeight` | `(elem): float64` | From `getBoundingClientRect` |

**Events (poll model)**

| Routine | Signature | Purpose |
|---------|-----------|---------|
| `Listen` / `Unlisten` | `(elem; const eventType: ptr to char)` | Start / stop queueing events of this type; `Unlisten` drops queued events |
| `HasEvent` | `(elem; const eventType: ptr to char): bool` | Queue not empty |
| `NextEvent` | `(elem; const eventType: ptr to char): bool` | Pop the oldest event into the last-event slot; false when empty |
| `EventX` / `EventY` | `(): float64` | `clientX` / `clientY` of the last event |
| `EventKeyCode` / `EventButton` | `(): int32` | `keyCode` / `button` of the last event |
| `EventValue` | `(): string` | `target.value` of the last event (inputs, selects) |

> [!TIP]
> **One handle per element.** Every routine that returns an `Element` returns that element's handle, so `Query`, `Parent`, `FirstChild`, `NextSibling` and `Body` give back the same value each time for the same element and `=` compares elements. `Clone` returns a new element with its own handle. `Release` frees the handle (like `Free`); `Remove` also detaches the element. A released handle is stale: routines ignore it and return 0 / false.


<a id="standard-library-sqlite3-sqlite-databases"></a>

### 🗄️ sqlite3 -- SQLite Databases

*Real SQLite databases with the familiar C-API shape: open, prepare, bind, step, read columns.*

<!-- Source: repo/bin/res/libs/std/sqlite3.pxl, repo/bin/res/libs/std/sqlite3.js -->

Wraps Electron’s built-in `node:sqlite` as a C-API-shaped cursor interface: open a `Database`, `Prepare` a `Statement`, `Bind` parameters (1-based), `Step` through rows (`SQLITE_ROW` per row, `SQLITE_DONE` at the end), read `Column` values (0-based), and `Finalize`. Relative paths resolve under `DataDir()` (the app’s private data folder); pass `MEMORY` for an in-memory database. Nothing raises -- failures return `0` / `false` and set `ErrCode` / `ErrMsg`.

```pxl
// sqlite_basics.pxl -- open, insert, query
module exe sqlite_basics;

import
  sqlite3;

var
  db: sqlite3.Database;
  st: sqlite3.Statement;
  rc: int32;
begin
  db := sqlite3.Open(sqlite3.MEMORY);
  sqlite3.Exec(db, "create table demo (id integer primary key, name text)");

  st := sqlite3.Prepare(db, "insert into demo values (?, ?)");
  sqlite3.BindInt(st, 1, 1);
  sqlite3.BindText(st, 2, "Alice");
  sqlite3.Step(st);
  sqlite3.Finalize(st);

  st := sqlite3.Prepare(db, "select id, name from demo");
  rc := sqlite3.Step(st);
  while rc = sqlite3.SQLITE_ROW do
    println("%d %s", sqlite3.ColumnInt(st, 0), sqlite3.ColumnText(st, 1));
    rc := sqlite3.Step(st);
  end;
  sqlite3.Finalize(st);

  sqlite3.Close(db);
end.
```

#### Types

| Type | Underlying | Meaning |
|------|-----------|---------|
| `Database` | `int32` | Handle to an open database (0 = none / invalid) |
| `Statement` | `int32` | Handle to a prepared statement (0 = none / invalid) |

#### Constants

| Constant | Value | Meaning |
|----------|-------|---------|
| `MEMORY` | `":memory:"` | Opens a private in-memory database |
| `SQLITE_OK` | `0` | Success |
| `SQLITE_ERROR` | `1` | Generic error |
| `SQLITE_MISUSE` | `21` | API misuse |
| `SQLITE_ROW` | `100` | `Step` has another row ready |
| `SQLITE_DONE` | `101` | `Step` finished (no more rows) |
| `SQLITE_INTEGER` | `1` | Column type: integer |
| `SQLITE_FLOAT` | `2` | Column type: float |
| `SQLITE_TEXT` | `3` | Column type: text |
| `SQLITE_BLOB` | `4` | Column type: blob |
| `SQLITE_NULL` | `5` | Column type: null |

#### Database Lifecycle

| Routine | Signature | Returns |
|---------|-----------|---------|
| `Open` | `(const path: ptr to char): Database` | Handle, or `0` on failure |
| `Close` | `(const db: Database): bool` | `false` if `db` is invalid |
| `IsOpen` | `(const db: Database): bool` | Whether `db` is a valid open handle |
| `Exec` | `(const db: Database; const sql: ptr to char): bool` | Runs SQL that returns no rows |
| `Changes` | `(const db: Database): int64` | Rows changed by last INSERT/UPDATE/DELETE |
| `LastInsertId` | `(const db: Database): int64` | Rowid of last successful INSERT |
| `DataDir` | `(): string` | Folder that relative paths resolve under |

#### Transactions

| Routine | Signature | Returns |
|---------|-----------|---------|
| `Begin` | `(const db: Database): bool` | Starts a transaction |
| `Commit` | `(const db: Database): bool` | Commits the current transaction |
| `Rollback` | `(const db: Database): bool` | Rolls back the current transaction |
| `InTransaction` | `(const db: Database): bool` | Whether a transaction is active |

#### Statement Lifecycle

| Routine | Signature | Returns |
|---------|-----------|---------|
| `Prepare` | `(const db: Database; const sql: ptr to char): Statement` | Handle, or `0` on failure |
| `Finalize` | `(const st: Statement)` | Releases the statement |
| `Reset` | `(const st: Statement)` | Restarts from first row; bindings kept |
| `ClearBindings` | `(const st: Statement)` | Sets every param to NULL and restarts |

#### Binding (1-based index)

| Routine | Signature | Returns |
|---------|-----------|---------|
| `BindInt` | `(const st: Statement; const idx: int32; const value: int32): bool` | `false` on bad handle or idx < 1 |
| `BindInt64` | `(const st: Statement; const idx: int32; const value: int64): bool` | |
| `BindDouble` | `(const st: Statement; const idx: int32; const value: float64): bool` | |
| `BindText` | `(const st: Statement; const idx: int32; const value: ptr to char): bool` | |
| `BindBlob` | `(const st: Statement; const idx: int32; const buf: ptr to uint8; const bufSize: int64): bool` | Copies `bufSize` bytes immediately |
| `BindNull` | `(const st: Statement; const idx: int32): bool` | |

#### Stepping

| Routine | Signature | Returns |
|---------|-----------|---------|
| `Step` | `(const st: Statement): int32` | `SQLITE_ROW`, `SQLITE_DONE`, or error code |

#### Column Access (0-based index)

| Routine | Signature | Returns |
|---------|-----------|---------|
| `ColumnCount` | `(const st: Statement): int32` | Number of result columns |
| `ColumnType` | `(const st: Statement; const col: int32): int32` | One of `SQLITE_INTEGER` / `FLOAT` / `TEXT` / `BLOB` / `NULL` |
| `ColumnInt` | `(const st: Statement; const col: int32): int32` | Integer value |
| `ColumnInt64` | `(const st: Statement; const col: int32): int64` | 64-bit integer value |
| `ColumnDouble` | `(const st: Statement; const col: int32): float64` | Float value |
| `ColumnText` | `(const st: Statement; const col: int32): string` | Text value (`""` for NULL) |
| `ColumnBytes` | `(const st: Statement; const col: int32): int64` | Byte length (text as UTF-8), 0 for NULL |
| `ColumnBlob` | `(const st: Statement; const col: int32; const buf: ptr to uint8; const bufSize: int64): int64` | Copies up to `bufSize` bytes; returns full length |
| `ColumnName` | `(const st: Statement; const col: int32): string` | Column name (`""` if out of range) |

#### Error Reporting

| Routine | Signature | Returns |
|---------|-----------|---------|
| `ErrCode` | `(const db: Database): int32` | Last error code (`SQLITE_OK` when last call succeeded); `db = 0` reports last failed `Open()` |
| `ErrMsg` | `(const db: Database): string` | Human-readable error message (`""` when none); `db = 0` reports last failed `Open()` |

> [!TIP]
> **Binding is 1-based, columns are 0-based.** This matches the SQLite C API convention. `BindInt(st, 1, val)` sets the first `?` parameter; `ColumnInt(st, 0)` reads the first result column.

> [!TIP]
> **Use `Exec` for DDL and one-shot writes.** `Prepare` / `Step` / `Finalize` is only needed when you want to bind parameters or read result rows.

> [!NOTE]
> **Relative paths resolve under `DataDir()`.** This is the app’s private data folder (typically `%APPDATA%/<appname>`). Pass an absolute path to place the database elsewhere. `MEMORY` creates a private in-memory database that vanishes when closed.


<a id="standard-library-vendor-libraries"></a>

### 🧰 Vendor Libraries

*A full game engine bound to PIXELS: Phaser 4 for 2D.*

<!-- Source: repo/bin/res/libs/vendor/README.md:1-4; vendor/phaser/phaser.pxl:1-1550; vendor/phaser/phaser.js:1-100; repo/src/PIXELS.Build.pas:838-886 -->

Vendor libraries live in `res/libs/vendor/<name>/`: one folder per library holding the upstream minified bundle, a PIXELS `module unit` (`<name>.pxl`), and a JavaScript shim (`<name>.js`). You use them exactly like std modules - `import phaser;` - and the build bundles the shim together with the upstream library (vendor shims are CommonJS files that `require` the bundle, so the build runs them through esbuild).

| Library | Upstream | Public routines | Example |
|---------|----------|-----------------|---------|
| `phaser` | Phaser 4.2.0 (`phaser.min.js`) | 613 in 28 sections, plus 95 constants | `examples/phaser_demo.pxl` |

The library takes over the whole window: `Init` adds the `pxl-app` class to the page body (hiding the developer console) and creates a fixed, full-window container for the engine's canvas. You still drive your game with `app.Run`; the engine keeps its own renderer.


#### 👾 phaser -- Phaser 4 Game Framework

`phaser` exposes a large part of the Phaser 4 API as flat routines. Conventions (phaser.pxl header):

- Every Phaser object (sprite, text, tween, timer, camera, tilemap, ...) crosses as an `int32` handle; 0 = none.
- Strings are `ptr to char`, geometry is `float64`, and counts, handles, colours, and **booleans are `int32`** (compare with `<> 0`).
- Config setters (`SetRenderer`, `SetPhysics`, `SetFPS`, `SetPixelArt`, `SetTransparent`, `SetAntiAlias`, `SetRoundPixels`, `SetGamepadInput`) must be called **before** `Init`.
- `Init(const AWidth: int32; const AHeight: int32): int32` boots the game with Phaser's FIT scale mode and CENTER_BOTH, and asks Electron to size the window content to `AWidth` x `AHeight` (IPC `set-content-size`). The default physics engine is arcade with zero gravity.
- The Phaser scene boots asynchronously. Poll `IsReady() <> 0` in Update before you create objects; operations issued before the scene exists are queued and run once it does.
- Animations, tweens, and particle emitters use a config-accumulator style: set properties one call at a time (`TweenSetTarget`, `TweenSetProp`, `TweenSetDuration`, ...), then create with one call (`TweenAdd`).
- Timers and events are polled: `TimerHasFired(handle)`, `EventGameBlur()`, and so on.

```pxl
// phaser_demo.pxl -- Phaser 4 vendor lib (trimmed)
module exe phaser_demo;

import
  phaser,
  app;

var
  LReady: int32;
  LPaddle: int32;

// Called once when Phaser scene becomes ready
routine SetupScene();
begin
  phaser.SetBackgroundColor(12, 18, 36);
  phaser.SetGravity(0.0, 400.0);

  // Paddle -- player-controlled
  LPaddle := phaser.AddRectangle(400.0, 550.0, 120.0, 16.0, 3394815);
  phaser.PhysicsAddExisting(LPaddle);
  phaser.SetImmovable(LPaddle, 1);
  phaser.SetAllowGravity(LPaddle, 0);

  phaser.AddText(200.0, 56.0, "Arrows = move paddle | ESC = quit", 14, 8421504);
end;

routine Update(const dt: float64);
var
  LPx: float64;
begin
  // ESC to quit
  if phaser.IsKeyJustDown(phaser.KEY_ESC) <> 0 then
    app.Quit();
  end;

  // Wait for Phaser scene to be ready before doing anything
  if LReady = 0 then
    if phaser.IsReady() <> 0 then
      SetupScene();
      LReady := 1;
    end;
    return;
  end;

  LPx := phaser.GetX(LPaddle);
  if phaser.IsKeyDown(phaser.KEY_LEFT) <> 0 then
    LPx := LPx - 400.0 * dt;
  end;
  if phaser.IsKeyDown(phaser.KEY_RIGHT) <> 0 then
    LPx := LPx + 400.0 * dt;
  end;
  phaser.SetX(LPaddle, LPx);
end;

routine Render();
begin
end;

routine Shutdown();
begin
  phaser.Destroy();
end;

begin
  LReady := 0;
  phaser.SetPhysics(phaser.PHYSICS_ARCADE);
  phaser.Init(800, 600);

  app.SetTargetFPS(60.0);
  app.Run(Update, Render, Shutdown);
end.
```

**Constants** (95, `public const`, all `int32`)

| Group | Count | Examples |
|-------|-------|---------|
| `SCALE_*` | 4 | `SCALE_NONE`, `SCALE_FIT`, `SCALE_ENVELOP`, `SCALE_RESIZE` |
| `CENTER_*` | 4 | `CENTER_NONE`, `CENTER_BOTH`, `CENTER_HORIZONTAL`, `CENTER_VERTICAL` |
| `RENDERER_*` | 3 | `RENDERER_AUTO`, `RENDERER_CANVAS`, `RENDERER_WEBGL` |
| `PHYSICS_*` | 3 | `PHYSICS_NONE`, `PHYSICS_ARCADE`, `PHYSICS_MATTER` |
| `BLEND_*` | 5 | `BLEND_NORMAL`, `BLEND_ADD`, `BLEND_MULTIPLY`, `BLEND_SCREEN`, `BLEND_ERASE` |
| `KEY_*` | 60 | DOM keyCodes: `KEY_A` (65) .. `KEY_Z`, `KEY_0` .. `KEY_9`, arrows, `KEY_SPACE`, `KEY_ENTER`, `KEY_ESC`, `KEY_SHIFT`, `KEY_CTRL`, `KEY_ALT`, `KEY_TAB`, `KEY_BACKSPACE`, `KEY_F1` .. `KEY_F12` |
| `GAMEPAD_*` | 16 | `GAMEPAD_A` .. `GAMEPAD_Y`, `GAMEPAD_L1`/`R1`/`L2`/`R2`, `GAMEPAD_SELECT`, `GAMEPAD_START`, `GAMEPAD_L3`/`R3`, d-pad |

**API areas** (section numbers as in phaser.pxl; there is no section 3)

| Section | Routines | Key entry points |
|---------|----------|------------------|
| 1. Core & Game Lifecycle | 20 | `SetRenderer`, `SetPhysics`, `SetPixelArt`, `Init`, `IsReady`, `Pause`, `Resume`, `Destroy`, `SetBackgroundColor` |
| 2. Scale Manager | 18 | `SetScaleMode`, `SetAutoCenter`, `GetGameWidth`, `SetZoom`, `StartFullscreen`, `LockOrientation` |
| 4. Game Objects (shared methods) | 36 | `SetPosition`, `SetX`, `GetX`, `SetScale`, `SetOrigin`, `SetDepth`, `SetObjData` |
| 5. Sprites & Images | 26 | `AddSprite`, `AddImage`, `AddTileSprite`, `SetTexture`, `SetFrame`, `SpritePlay` |
| 6. Shapes | 14 | `AddRectangle`, `AddCircle`, `AddEllipse`, `AddTriangle`, `AddLine`, `AddStar` |
| 7. Text | 20 | `AddText`, `SetText`, `GetText`, `SetFont` |
| 8. Containers & Groups | 31 | `AddContainer`, `ContainerAdd`, `ContainerRemove` |
| 9. Graphics (freeform drawing) | 25 | `AddGraphics`, `GfxClear`, `GfxFillStyle`, `GfxLineStyle`, `GfxMoveTo`, `GfxLineBetween` |
| 10. Animations | 18 | `AnimSetKey`, `AnimSetFrames`, `AnimSetFrameRate` |
| 11. Tweens | 29 | `TweenSetTarget`, `TweenSetProp`, `TweenSetDuration`, `TweenSetEase`, `TweenAdd` |
| 12. Arcade Physics | 40 | `SetGravity`, `PhysicsAddExisting`, `SetVelocity`, `PhysicsCollide`, `AddPhysicsCircle` |
| 13. Matter Physics | 20 | `MatterSetGravity`, `MatterAddRect`, `MatterAddCircle` |
| 14. Input - Keyboard | 17 | `KeyboardAddKey`, `KeyboardCreateCursorKeys`, `IsKeyDown`, `IsKeyJustDown`, `KeyDuration` |
| 15. Input - Pointer | 19 | `PointerX`, `PointerY`, `PointerWorldX`, `PointerIsDown` |
| 16. Input - Gamepad | 21 | `GamepadTotal`, `GamepadGetPad`, `GamepadLeftStickX` |
| 17. Audio | 24 | `SoundAdd`, `SoundPlay`, `SoundPlayConfig`, `SoundInstancePlay` |
| 18. Loader | 13 | `LoadImage`, `LoadSpriteSheet`, `LoadAtlas`, `LoadAudio`, `LoadJSON` |
| 19. Cameras | 28 | `CameraSetScroll`, `CameraSetZoom`, `CameraShake`, `CameraFlash`, `CameraFadeIn` |
| 20. Tilemaps | 33 | `TilemapCreate`, `TilemapAddTileset`, `TilemapCreateLayer`, `TilePutAt` |
| 21. Particles | 33 | `ParticleSetTexture`, `ParticleSetSpeed`, `ParticleSetScale` |
| 22. Time / Timers | 16 | `TimerAdd`, `TimerDelayed`, `TimerHasFired` |
| 23. Data Manager | 21 | `DataSet`, `DataSetStr`, `DataGetF64`, `DataGetStr`, `GODataGetStr`, `RegistryGetStr` |
| 24. FX | 20 | `FxAddGlow`, `FxAddShadow`, `FxAddBloom`, `FxAddBlur` |
| 25. Math | 15 | `MathBetween`, `MathFloatBetween`, `MathAngleBetween`, `MathClamp` |
| 26. Textures | 17 | `TextureExists`, `TextureGetWidth`, `RenderTexCreate` |
| 27. Video | 17 | `VideoCreate`, `VideoLoadURL`, `VideoPlay` |
| 28. Curves & Paths | 16 | `PathCreate`, `PathLineTo`, `PathSplineTo` |
| 29. Events (polling) | 6 | `EventScenePaused`, `EventGameBlur`, `EventGameHidden` |

For exact signatures, read `res/libs/vendor/phaser/phaser.pxl`; each section above starts at a `// N. <name>` banner.

The string getters `GetText`, `DataGetStr`, `GODataGetStr` and `RegistryGetStr` return a `string`, empty when the text or key is missing.

> [!NOTE]
> **Two key-code tables.** `phaser.KEY_*` are DOM keyCodes (`phaser.KEY_A` = 65); `input.KEY_*` are USB HID codes (`input.KEY_A` = 4). Use `phaser.IsKeyDown` with `phaser.KEY_*`, and `input.KeyDown` with `input.KEY_*`.


<a id="standard-library-cross-module-dependencies"></a>

### 🔗 Cross-Module Dependencies

<!-- Source: runtime/runtime.js:20-50; std/app.js:44-65, 106-121; std/input.js:67-71, 131; std/canvas2d.js:81, 125, 135, 149; std/video.js:101, 156, 161; std/localstorage.js:26; std/browser.js:25-41; repo/src/PIXELS.Build.pas:584-614 -->

No std module imports another. All coupling flows through documented hook slots on the `PXL` object in runtime.js.

| Module | Depends on (via PXL) | Notes |
|--------|----------------------|-------|
| app | -- | Fires `PXL.onTick` at the top of each tick; sets `PXL.keepAlive`, `PXL.shutdownHandler` and `PXL.closeHandler` for the page; `Quit` / `Close` end the program through `PXL.requestEnd` |
| canvas2d | -- | Sets `PXL.canvas` and `PXL.canvasDpr`; pushes a `PXL.onExit` callback |
| input | app, canvas2d | Sets `PXL.onTick` (fired by app); mouse coords via `PXL.canvas` / `PXL.canvasDpr` (canvas2d) |
| audio | -- | Standalone |
| video | canvas2d (Draw mode) | Draw reads `PXL.canvas`; Show mode is standalone; pushes a `PXL.onExit` callback |
| localstorage | -- | Reads `PXL.moduleName` for key prefix |
| browser | -- | Standalone; `Alert` and `OpenURL` are sync IPC to `main.js` |
| dom | -- | Standalone; own `PXL.handles()` table |
| sqlite3 | -- | Standalone; own `PXL.handles()` table |
| phaser | -- | Standalone vendor library; drive it from `app.Run` |


<a id="standard-library-example-to-module-map"></a>

### 📋 Example-to-Module Map

All 16 examples live in `res/examples/`.

| Example | Modules | What it demonstrates |
|---------|---------|----------------------|
| `hello.pxl` | (none) | Console output only |
| `app_loop.pxl` | app, canvas2d | Basic game loop, Shutdown handler, clean leak report |
| `house.pxl` | canvas2d | Static shape drawing |
| `canvas2d_tour.pxl` | app, canvas2d | Canvas API showcase: Path2D, gradients, MeasureText, ImageData, ToDataURL |
| `scale_image.pxl` | app, canvas2d | `@assets` image loaded on demand (`LoadImage`/`ImageReady`), drawn scaled |
| `text_rendering.pxl` | app, canvas2d, input | Fonts from `@assets`, wrapping, metrics, text getters |
| `responsive_canvas.pxl` | app, canvas2d, input | `PLACE_WINDOW` responsive layout |
| `input_square.pxl` | app, canvas2d, input | Keyboard, mouse, and gamepad demo |
| `particles.pxl` | app, canvas2d, input | Additive particle trails with gravity |
| `bouncing_squares.pxl` | app, canvas2d, input, localstorage | Game with persistence (best time saved on shutdown) |
| `audio_player.pxl` | app, audio, canvas2d, input | Audio playback |
| `video_player.pxl` | app, canvas2d, input, video | Video playback, Draw vs Show |
| `run_counter.pxl` | localstorage | Console-only persistence |
| `dom_playground.pxl` | app, dom, input | DOM tile grid, buttons, theme toggle, poll-model events |
| `phaser_demo.pxl` | app, phaser | Phaser 4: arcade physics, shapes, text, graphics, tweens, keyboard, camera FX, timers |
| `sqlite3_demo.pxl` | sqlite3 | Database CRUD, blobs, transactions, error handling |

To build your own std-style module, see [JavaScript Interop](#js-interop) for the marshalling contract and shim authoring guide.

Next: [Runtime](#runtime-library)

---

<p align="right"><a href="#standard-library">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="runtime-library"></a>

## ⚙️ 8. Runtime

> **What powers every executable**  
> See how the wasm runtime, JavaScript host, Electron shell, assets, and startup lifecycle fit together.


*Three layers make every PIXELS program run: a wasm runtime baked into the binary, a JavaScript host layer that bridges wasm to the desktop window, and a generated Electron app shell that wires them together.*

A PIXELS game is an Electron app, but it is not magic. Inside `app.asar` are three layers, each with a clear job. `runtime.wat` is hand-written WebAssembly that ships inside the wasm module itself -- heap allocation, strings, exceptions, console I/O, the test runner. `runtime.js` is the JavaScript side -- the WASI preview1 shim, the shared `PXL` helper object that every std module depends on, and the `PxlAssets` asset loader; it is bundled into `output.js`. The generated `main.js` and `index.html` are the app shell: `main.js` opens the window, and `index.html` loads `output.js`, streams `output.wasm` from `pxl://app/`, instantiates the module, and manages the startup-to-shutdown lifecycle. You never touch these files directly. The compiler's build pipeline (`PIXELS.Build`) generates and packs them into `bin\res\electron\<arch>\resources\app.asar`.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🧱 runtime.wat -- The Wasm Runtime](#runtime-library-runtime-wat-the-wasm-runtime)
- [🌐 runtime.js -- The JavaScript Host](#runtime-library-runtime-js-the-javascript-host)
- [🚀 Startup and Shutdown Lifecycle](#runtime-library-startup-and-shutdown-lifecycle)
- [📤 Exe Exports](#runtime-library-exe-exports)
- [🛡️ Exception Handling](#runtime-library-exception-handling)
- [📦 Embedded Assets](#runtime-library-embedded-assets)
- [🎚️ Build Modes](#runtime-library-build-modes)
- [🔧 JS Pipeline](#runtime-library-js-pipeline)
- [🧪 Unit Test Mode](#runtime-library-unit-test-mode)

</details>

<a id="runtime-library-runtime-wat-the-wasm-runtime"></a>

### 🧱 runtime.wat -- The Wasm Runtime

The emitter includes `runtime.wat` verbatim into every exe module (lib modules do not get it: a lib imports its memory and the runtime routines it uses from `"pxl"`, the exe it is linked into). Its functions are real wasm functions in the same module as your code -- not JS imports.

runtime.wat imports exactly four WASI preview1 functions:

| Import | Used by |
|--------|---------|
| `fd_write` | All console output (`print` / `println`) on fd 1 (stdout); the unhandled-exception report on fd 2 (stderr) |
| `proc_exit` | `RT_Halt`: exit code 1 after an unhandled exception (reported on stderr) or a failed unit-test run |
| `args_sizes_get` | Command-line argument init (`RT_InitCommandLine`) |
| `args_get` | Command-line argument init (`RT_InitCommandLine`) |

These are the only imports from `wasi_snapshot_preview1` that the runtime needs. All other host API access goes through JS imports in custom namespaces, one per external JS library (canvas2d, input, audio, etc.).

#### Function Table

```wat
(type $rt_void_func (func))
(type $rt_thunk_type (func (param i64)))
(table $rt_functable 256 funcref)
```

Slot 0 is reserved (`nil`). The emitter populates the table with `elem` declarations for routine references. A routine used as a value is its `int32` index in this table. Maximum 255 user routines per module.

#### Memory

```wat
(memory $mem i64 <pages>)
(export "memory" (memory $mem))
```

The emitter declares the memory, not runtime.wat. memory64 addressing (i64 pointers). The initial size is just large enough for the module's static data: the heap starts at the 16-aligned end of static data, and `<pages>` is that address rounded up to whole 64 KB pages (at least 1). There is no maximum and no static-data size limit; the heap allocator grows the memory as needed via `memory.grow`. A lib module declares no memory of its own: it imports the exe's. See [Memory](#memory-data-structures) for the allocator and string runtime details.


<a id="runtime-library-runtime-js-the-javascript-host"></a>

### 🌐 runtime.js -- The JavaScript Host

runtime.js is the JS-side runtime. The build concatenates it with the JS shims your program uses into `output.js`, which `index.html` loads with a `<script>` tag. It contains three subsystems.

#### The PXL Shared Object

`PXL` is the single namespace that every std module shim reads from and writes to. Modules never reference each other directly -- all coupling flows through these documented slots. runtime.js also publishes it as `globalThis.PXL`. A free `PXL` inside an esbuild-wrapped shim resolves to that top-level `PXL`; the build adds no prelude.

| Slot | Type | Set by | Read by |
|------|------|--------|---------|
| `moduleName` | string | index.html | std modules (localstorage key prefix, window title) |
| `onLoopEnd` | function \| null | index.html (`finish`) | `PXL.requestEnd` (fires it once, from a clean stack, when the program ends) |
| `onTick` | function \| null | input.js | app.js (fired every tick before any wasm call) |
| `canvas` | HTMLCanvasElement \| null | canvas2d.Init | input.js (mouse coordinate mapping) |
| `canvasDpr` | number | canvas2d | input.js |
| `onExit` | callback array | std modules push | index.html (fired after `_shutdown`) |
| `keepAlive` | bool | app.Run | index.html (the program stays up after `_start`) |
| `shutdownHandler` | number | app.Run | index.html (passed to `_shutdown`) |
| `closeHandler` | number | app.SetCloseHandler | index.html (window close request) |
| `quitRequested`, `closePending` | bool | app.Quit / app.Close | index.html (close veto; close the window after shutdown) |
| `exitStatus` | number | runtime.js (highest `proc_exit` code) | index.html (`exit code: N`) |
| `ended`, `shuttingDown`, `endQueued`, `trapped`, `depth` | internal | runtime.js / index.html | lifecycle state |
| `window` | object | runtime.js | std modules (the one sender of window IPC: title, size, fullscreen) |

Helper methods available to every shim:

| Method | Purpose |
|--------|---------|
| `readCStr(ptr)` | Read NUL-terminated UTF-8 from wasm memory at a BigInt address |
| `writeCStr(str, buf, size)` | Encode UTF-8 into wasm memory; returns full byte length as BigInt |
| `handles()` | Create a handle table (alloc / get / release; slot 0 = none) |
| `fail(e)` | Uniform error path -- `WASIProcExit` is a normal stop (shows `exit code: N`), anything else writes the stack to `#err` and shows `failed` |
| `runExit()` | Fire `onExit` callbacks, remove the `pxl-app` body class (restores the console area) |

The wasm instance itself is published as the global `PXL_WASM`; `readCStr` and `writeCStr` read its memory.

#### The WASI Preview1 Shim

A WASI preview1 implementation for memory64, forked from `@bjorn3/browser_wasi_shim` v0.4.2 (MIT OR Apache-2.0). All pointer and size parameters use BigInt (i64); file descriptors stay i32.

Key implemented calls:

| Category | Functions |
|----------|-----------|
| Args | `args_sizes_get`, `args_get` |
| Environ | `environ_sizes_get`, `environ_get` |
| Clock | `clock_res_get`, `clock_time_get` (realtime + monotonic via `performance.now`) |
| File I/O | `fd_read`, `fd_write`, `fd_pread`, `fd_pwrite`, `fd_seek`, `fd_tell`, `fd_close`, `fd_fdstat_get`, `fd_filestat_get`, `fd_prestat_get`, `fd_prestat_dir_name`, `fd_readdir` (plus the remaining `fd_*` calls) |
| Paths | `path_open`, `path_filestat_get`, `path_create_directory`, `path_remove_directory`, `path_rename`, `path_unlink_file`, `path_link`, `path_readlink` (in-memory file system) |
| Process | `proc_exit` (throws `WASIProcExit`), `proc_raise` |
| Random | `random_get` (`crypto.getRandomValues`) |
| Misc | `sched_yield` (no-op), `poll_oneoff` (a single clock subscription, busy-waits) |

A few calls return "not supported" (errno 58): `fd_fdstat_set_flags`, `fd_fdstat_set_rights`, `fd_filestat_set_times`, `path_filestat_set_times`, `path_symlink` and `proc_raise`. The `sock_*` calls return 58 for an open fd and bad descriptor (errno 8) for an fd that is not open. No WASI call throws.

Console I/O maps three file descriptors: fd 0 = stdin (empty), fd 1 = stdout (line-buffered, renders to `#out` with ANSI colour support and is also sent to `console.log`), fd 2 = stderr (renders to `#err`).

> [!NOTE]
> **ANSI colour in the output pane.** The stdout and stderr handlers in `index.html` include an SGR parser that converts escape codes to styled HTML spans, each pane with its own state. Supported: the full set listed in [ANSI Colour Output](#debugging-ansi-colour-output) -- bold, dim, italic, underline, 16-colour, 256-colour and truecolour foreground and background, and their resets. Your PIXELS `println` calls with ANSI escapes render in colour just as they would in a native terminal.

#### The Embedded Asset System

Assets (see [Embedded Assets](#embedded-assets) below) are never embedded in `app.asar` or preloaded. `main.js` serves every key of the build manifest under the page's own origin, `pxl://app/<key>`: debug and release builds read the source files in place, a distro build reads `resources\__assets\<key>`. Requests support byte ranges, so audio and video stream and seek. A key is the `/`-separated virtual path (for example `assets/images/pixels.png`); lookup is by exact key only, so `..` or absolute names reach nothing outside the key space.

There is no wasm-side asset API. `.pxl` code uses the std routines that take asset names, such as `canvas2d.LoadImage` or `audio.LoadSound`.

**JS-side helpers** (`PxlAssets`, for std module shims and your own JS):

| Helper | Returns |
|--------|---------|
| `init()` | Promise, runs once: fetches the asset view `__assets.json` (`{key: {size, mime}}`). `index.html` awaits it before instantiating the module, so the lookups below answer synchronously. A key whose file is missing is left out of the view |
| `exists(name)` | `true` when the key is in the view |
| `size(name)` | Byte size, `-1` when missing |
| `mime(name)` | MIME type, `''` when missing |
| `url(name)` | URL for any loader (fetch, XHR, `<img>`, `<audio>`, `<video>`, CSS); reads nothing itself |
| `arrayBuffer(name)` `blob(name)` `text(name)` | Promise of the contents, fetched on demand; rejects when the asset is missing or the read fails |

A name may use `\` for `/` and may start with `./` or `/`. Any JS code can also `fetch` an asset by its key.


<a id="runtime-library-startup-and-shutdown-lifecycle"></a>

### 🚀 Startup and Shutdown Lifecycle

The generated Electron app drives the full lifecycle. `app.asar` contains `package.json`, `main.js`, `preload.js`, `index.html`, `output.js`, `output.wasm` and the asset manifest `assets.json`; the assets themselves are served from their source files (debug/release) or from `resources\__assets\` (distro). Understanding the lifecycle helps when debugging console output or writing custom JS host code.

#### Startup Sequence

1. Electron runs `main.js`, which opens an 800x600 window (content size, fixed in the template; the canvas can resize it later through the `set-content-size` IPC message) with `nodeIntegration` on and `contextIsolation` off, and loads `pxl://app/index.html`, the app origin served by `main.js`. In release and distro builds `main.js` also hides the menu bar and disables DevTools; debug builds keep the default Electron menu, and DevTools can be opened there (no build mode opens them automatically). On linux-x64 under WSL2 with a GPU (`/dev/dxg`), `main.js` first relaunches itself once with Mesa's d3d12 driver selected, so WebGL runs on the GPU. `preload.js` is an empty placeholder.
2. `index.html` loads `output.js` (runtime.js plus the JS shims)
3. Build the WASI instance: program name = module name, empty environment, fd 1 to `#out` and `console.log`, fd 2 to `#err`
4. Await `PxlAssets.init()`, which fetches the asset view `__assets.json`
5. Fetch `output.wasm` from `pxl://app/` (served as `application/wasm`)
6. `WebAssembly.instantiateStreaming(...)` with these import namespaces: `wasi_snapshot_preview1` (WASI shim) and one namespace per external JS library in use (std, vendor, or your own)
7. Set `window.PXL_WASM` and `PXL.moduleName`, set `PXL.onLoopEnd = finish`, listen for `close-request` from `main.js`, then call `_start()` through `PXL.enter`

#### After _start Returns

8. If the program called `app.Run` (`PXL.keepAlive`), it stays up: the `app.Run` loop, timers and window events call into wasm through `PXL.call0` / `PXL.callFrame`, and a `pagehide` listener ends it as a fallback
9. Otherwise: call `PXL.requestEnd()`

A program ends through `app.Quit`, `app.Close`, an accepted window close, a failure in `_start` or in any handler, or a main block that returns without `app.Run`. Each of these goes through `PXL.requestEnd`, which queues `finish()` with `setTimeout(0)`, once: `finish()` never runs under a live wasm call.

#### finish()

1. Mark the program ended and call `_shutdown` with `PXL.shutdownHandler` (the shutdown routine given to `app.Run`, or 0). `_shutdown` calls your shutdown handler first, then runs finalization, global cleanup, and the leak report.
2. Unless the program trapped, show `exit code: N` in the `#exit` line (N is the highest `proc_exit` code; the line is visible when N is not 0)
3. Call `PXL.runExit()` -- fires `onExit` callbacks, drops app-mode styling
4. If the window is closing, send `shutdown-complete` to `main.js`

`finish()` runs at most once. A window close goes through it too: `main.js` cancels the close and sends `close-request` to the page. If the program set a close handler (`app.SetCloseHandler`), the page calls it, and unless the handler called `app.Quit` or `app.Close` the page answers `close-vetoed` and the window stays open. Otherwise the page answers `close-accepted`, ends the program, and sends `shutdown-complete` after `finish()`; `main.js` then destroys the window. If the page does not answer within 3 seconds, or has not finished 3 seconds after accepting, the window is destroyed anyway. `main.js` also handles `set-title`, `set-content-size` and `set-fullscreen` (sent by `PXL.window`) and `show-message` and `open-url` (sent by the `browser` module).

A trap shows its error stack in the `#err` element, and the `#exit` line shows `failed`. An exception that reaches an entry point is reported on stderr and ends the program with exit code 1. A non-zero exit code is shown even when the page is in app mode (canvas visible, console hidden). A failure inside an `app.Run` handler ends the program through `PXL.fail`, so `finish()` still runs.

The Electron process exits with the program's status: `finish()` sends it to `main.js` (`exit-status`; at least 1 after a trap) and `main.js` exits with it. A window destroyed because the page never finished (the 3-second timers) exits with 1.


<a id="runtime-library-exe-exports"></a>

### 📤 Exe Exports

An exe module always exports these five symbols. Every exe has a main body (an empty `begin end.` counts), and the host always calls `_start`, so the four functions exist in every exe, in unit test mode too:

| Export | Signature | Purpose |
|--------|-----------|---------|
| `_start` | `() -> void` | Entry point -- init, main body, return |
| `_shutdown` | `(idx: i32) -> void` | Teardown -- user handler, finalize, cleanup, leak report |
| `_frame` | `(idx: i32, dt: f64) -> void` | Trampoline: calls `routine(const x: float64)` at table[idx] |
| `_call0` | `(idx: i32) -> void` | Trampoline: calls `routine()` at table[idx] |
| `memory` | memory i64 | Linear memory (exported for JS access) |

Lib modules carry no runtime and no function table. They export the marker global `pxl@abi1`, `<lib>@init` / `<lib>@final`, their `public` routines under mangled names and their `public` variables as `<lib>.<name>`; memory and runtime routines are imports from `"pxl"`. An exe that links a PIXELS lib also exports the runtime routines a lib may import; after the merge those link-only exports are stripped, so the final module exports exactly the table above.

#### _start Internals

1. Allocate composite and memory-homed locals
2. Call `<lib>@init` of each linked PIXELS lib, dependency-first (a lib's var initializers and `initialize` section); a failure skips the rest of `_start`
3. Evaluate expression-based constants (imported units first, then exe)
4. Allocate heap-backed global variables (imported units first, then exe)
5. For each imported unit, dependency-first (a unit reached only through another unit included, each once): run its variable initializers, then its `initialize` section
6. Run this module's variable initializers (e.g. `x: int32 = 10`)
7. Execute this module's `initialize` section
8. (Unit test mode: register tests, run `RT_TestRunAll`, skip main body)
9. (Normal mode: execute `begin`..`end.` statements)
10. Release temporary locals, return to JS

#### _shutdown Internals

Every step that can raise runs under its own guard: a raise is reported and the rest of the teardown still runs.

1. Call user shutdown handler via `call_indirect` (if idx != 0)
2. Execute this module's `finalize` section
3. Execute unit `finalize` sections, in **reverse** initialization order
4. Run the registered runtime finalizers (last registered first)
5. Global cleanup, the exact reverse of allocation: this module, then imported units (reverse order)
6. Call `<lib>@final` of each linked PIXELS lib in reverse link order, only for libs whose `@init` was entered (after the exe cleanup, because an exe global may still point into lib data)
7. Free the command-line buffers and clear the exception state
8. Report leaks (debug build mode only -- see [Build Modes](#build-modes))
9. If any step raised, end with exit code 1

> [!TIP]
> **The window owns the loop.** `_start` returns immediately after `app.Run` sets up the loop. The page's `requestAnimationFrame` drives subsequent ticks. `_shutdown` is called from a clean JS stack -- never from inside a wasm call. This is why `app.Quit()` only requests the end; the actual shutdown runs once the current wasm call has returned.


<a id="runtime-library-exception-handling"></a>

### 🛡️ Exception Handling

PIXELS uses native wasm exception handling (tags, `try_table`, `catch`, `throw`). No emulation, no polyfill.

#### The Exception Tag

The wasm module defines one tag that carries an error code and a message pointer:

```wat
(tag $myr_exn (param i32 i64))
;;  code ─┘     └─ message (managed string ptr, or 0)
```

Two globals hold the exception of the innermost running `except` body: `$rt_exc_code` (i32) and `$rt_exc_msg` (i64, managed string). A caught exception is installed there on entry to the `except` body and the previous one is restored on every exit from it.

#### Runtime Exception Codes

| Code | Meaning |
|------|---------|
| 1000 | Software exception (default for `throw`) |
| 1001 | Set element outside 0..63; `excmsg()` is `set element <n> is out of range 0..63` |
| 1002 | Division by zero; `excmsg()` is `division by zero` |
| 1003 | Varargs type mismatch |
| 1004 | Varargs index out of bounds |
| 1005 | String or array index out of range, `debug` builds only; `excmsg()` is `index <i> is out of range <lo>..<hi>` |
| 1100 | Failed assertion outside unit test mode; `excmsg()` is the failure text |

Codes 1000 to 1999 are reserved for the runtime and compiler.

User code raises exceptions with `throw` (code 1000) or `throwcode` (any code):

```pxl
// bnf_exe_compliance.pxl -- phase 24, exception handling (trimmed)
guard
  throw("test error");
  println("should not print");
except
  println("caught, code=%lld, msg=%s", exccode(), excmsg());
end;

guard
  throwcode(42, "custom error");
except
  println("code=%lld, msg=%s", exccode(), excmsg());
end;

guard
  throw("err2");
except
  println("except caught");
finally
  println("finally2 runs");
end;

// hw exception: div by zero
guard
  x := 10 div get_zero();
  println("should not print: %d", x);
except
  println("hw caught, code=%lld, msg=%s", exccode(), excmsg());
end;
```

The `guard`/`except`/`finally` block compiles to wasm's `try_table` with a catch clause for the exception tag. `exccode()` returns the integer code (`int32`); `excmsg()` returns the message string. Both read the exception of the innermost `except` body that is running, including from routines it calls; outside any `except` body they return 0 and an empty string. Leaving an `except` body by any path restores the previous exception, and a `finally` body sees the enclosing handler's exception, not the one in flight. Runtime codes: 1000 bare `throw`, 1001 set element out of range, 1002 integer division by zero, 1003 variadic argument type mismatch, 1004 variadic argument index out of range, 1005 index out of range (`debug` builds), 1100 failed assertion; 1000 to 1999 are reserved.

Integer `div` and `mod` by zero are not left to the hardware: the compiler wraps the divisor in a runtime check that raises code 1002, which is why the guard above catches it. Only the `$myr_exn` tag is caught. Real wasm traps (`unreachable`, out-of-bounds access, a failed memory grow) and JavaScript exceptions cannot be caught by `guard`.

> [!NOTE]
> **Nested guards.** Guard blocks nest freely. An inner `guard` handles exceptions raised in its own body; an exception raised inside an `except` body propagates to the enclosing `guard`.


<a id="embedded-assets"></a>

### 📦 Embedded Assets

The `@assets` directive maps files into the app at build time. Debug and release builds serve them in place from their source files; a distro build copies them to `resources\__assets\` beside `app.asar` inside the zip. At runtime the page reads an asset only when a std shim or your JS asks for it, over `pxl://app/<key>`, with no network requests.

```pxl
// scale_image.pxl -- drawing a bundled image (header comment trimmed)
module exe scale_image;

@exeicon "$P:res/assets/icons/pixels.ico";
@assets "$P:res/assets/images" "assets/images" "pixels.png";

import
  canvas2d,
  app;

var
  img: canvas2d.Image;

routine Render();
begin
  if canvas2d.ImageReady(img) then
    canvas2d.DrawImage(img, 18, 136, 603, 208);
    println("Asset demo: image drawn");
    app.Quit();
  end;
end;

routine Shutdown();
begin
  canvas2d.ReleaseImage(img);
end;

begin
  canvas2d.Init(640, 480);
  canvas2d.SetPlacement(canvas2d.PLACE_FILL);
  img := canvas2d.LoadImage("assets/images/pixels.png");
  if img = 0 then
    println("LoadImage FAILED");
  else
    app.Run(nil, Render, Shutdown);
  end;
end.
```

#### Build Pipeline

1. The compiler collects asset entries. `@assets "source_path" "virtual_path" ["pattern"]` adds every file under `source_path` (recursively) that matches `pattern` (default `*`); each key is `virtual_path/` plus the file's path relative to `source_path` (for example `assets/audio/sfx/samp0.ogg`).
2. The build writes the manifest `assets.json` (key -> file and MIME type) into `app.asar`: absolute source paths in debug and release (as `/mnt/<drive>/...` for linux-x64, which runs under WSL), keys in a distro build, which also copies each file to `resources\__assets\<key>`
3. At startup, `PxlAssets.init()` fetches the asset view; file contents are read on demand

A relative `source_path` resolves against the current working directory of the compiler (no prefix is the same as `$S:`); `$P:` paths (relative to `pixels.exe`) and absolute paths work from any folder.

#### Wasm-Side Access

There is no wasm-side asset API. The std modules use the JS-side `PxlAssets` helpers (`url`, `blob`, `arrayBuffer`) to feed assets directly to the page's media APIs without copying through wasm memory, and any JS code can `fetch` an asset by its key.


<a id="runtime-library-build-modes"></a>

### 🎚️ Build Modes

The build mode (`-bm` / `--buildmode` on the command line, or the `@buildmode` directive; the command line wins) controls both the wasm-opt pass and emitter behaviour. For the CLI flags and output locations, see [Build Modes](#build-modes) in the CLI Reference.

| Mode | wasm-opt flag | Emitter level | Description |
|------|---------------|---------------|-------------|
| `debug` (default) | `-O0` | 0 | No optimization. Leak counters enabled. JS not minified. Default Electron menu. |
| `release` | `-O3` | 3 | Aggressive optimization, minified JS, menu bar hidden, DevTools off |
| `distro` | `-O3` | 3 | Same as release, plus a shippable `<name>-<arch>.zip` in the output folder |

debug and release builds write the app into the shared `bin\res\electron\<arch>\` folder (overwritten by every build); only distro produces a file you can ship.

#### Emitter Behaviour at O0 vs O3

| O0 (debug) | O3 (release, distro) |
|------------|----------------------|
| `RT_GetMem` / `RT_FreeMem` wrappers count every allocation and free | Direct pass-through wrappers (no counting) |
| `_shutdown` prints `[Heap] Allocs: N, Frees: N, Leaked: N` | No leak report |
| Globals `$rt_alloc_count`, `$rt_free_count` emitted | Not emitted |

#### Wasm Features Always Enabled

Regardless of build mode, wasm-opt runs with these feature flags:

```
--enable-memory64
--enable-bulk-memory
--enable-nontrapping-float-to-int
--enable-exception-handling
--enable-multivalue
```

> [!TIP]
> **Start with debug.** During development, the default `debug` mode (no `-bm` flag, no `@buildmode` directive) gives you the heap leak report at shutdown. Once the program runs cleanly, build with `-bm release`, and use `-bm distro` when you want a zip to ship.


<a id="runtime-library-js-pipeline"></a>

### 🔧 JS Pipeline

The build pipeline assembles all JavaScript into one file, `output.js`, which is packed into `app.asar` and loaded by `index.html`.

```
runtime.js                  (always included)
  +
Std shims (bin/res/libs/std/<lib>.js)
  +
Vendor shims (bin/res/libs/vendor/<lib>/<lib>.js)
  +
User JS (<lib>.js beside the declaring unit or on @addlibrarypath)
  =
Combined -> esbuild (--minify in release/distro) -> output.js
```

Only the JS libraries your program's `external` declarations name are included. A library that uses CommonJS or ES module syntax is first wrapped by esbuild into an IIFE whose global name is the library name; a plain global-style script is appended as is. The final esbuild pass over the combined file does not bundle; it minifies in release and distro builds only. The `--legal-comments=inline` flag preserves `/*!` attribution comments from third-party libraries.

#### HTML Template Placeholders

The app shell is generated from three templates in `PIXELS.Build.pas`: `main.js`, `preload.js` (an empty placeholder, nothing to replace) and `index.html`. Their placeholders:

| Placeholder | Replaced with |
|-------------|---------------|
| `main.js` width, height | Window content size, always 800 and 600 |
| `main.js` frame | `true` (framed window) |
| `main.js` menu line | Menu-bar hiding calls in release and distro; empty in debug |
| `index.html` title, heading, program name | The module name (page `<title>`, `<h1>`, WASI `args[0]`) |
| `__PXL_EXTRA_IMPORTS__` | Import object entries (`name: name`) for each external JS library |


<a id="runtime-library-unit-test-mode"></a>

### 🧪 Unit Test Mode

When `@unittestmode on;` is active, `_start` registers every `test` block (via `RT_TestRegister`) and runs `RT_TestRunAll` instead of the main body. The module still needs a `begin`..`end.` main body, because the runner lives in `_start`. The runner prints a header, `Running N test(s)...`, one `[PASS]` or `[FAIL]` line per test (failure details follow a `[FAIL]` line), and a closing `=== Results: P passed, F failed, T total ===` line, using ANSI colours. The process exit code is 1 when any test fails and 0 otherwise, on both hosts. With no test blocks the runner prints `No tests registered.` and exits 0; the main body does not run either way.

See the Testing section in the Language Reference for the assertion functions and test block syntax.

Next: [Debugging](#debugging)

---

<p align="right"><a href="#runtime-library">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="debugging"></a>

## 🐛 9. Diagnostics

> **Diagnose what the game is doing**  
> Use debug builds, leak reporting, source mapping, DevTools, and conditional diagnostics.


*PIXELS has no source-level debugger. What it has fits how PIXELS programs run: a leak detector, coloured console output, error mapping back to your source, and the Chromium page your game runs in.*

PIXELS games run inside an Electron window, so the debugging story is largely the Chromium page's debugging story -- plus a few compiler features that make it practical. The `debug` build mode (the default) is the diagnostic mode: the output is unoptimized and includes a heap leak report at shutdown. ANSI escape codes render in colour in the output pane. Compiler errors from the wasm layer are mapped back to your `.pxl` source lines. And conditional compilation lets you gate debug-only code behind a symbol you define yourself.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🎚️ Build Modes](#debugging-build-modes)
- [🔍 Heap Leak Report](#debugging-heap-leak-report)
- [🎨 ANSI Colour Output](#debugging-ansi-colour-output)
- [🗺️ Compiler Error Mapping](#debugging-compiler-error-mapping)
- [🖥️ Browser DevTools](#debugging-browser-devtools)
- [🔀 Conditional Compilation for Debug Code](#debugging-conditional-compilation-for-debug-code)

</details>

<a id="debugging-build-modes"></a>

### 🎚️ Build Modes

The `-bm` / `--buildmode` CLI flag or the `@buildmode` directive selects the build mode, which controls both the wasm-opt pass and emitter behaviour. `debug` is the default and the primary diagnostic mode. The CLI flag overrides the directive.

| Mode | wasm-opt flag | Description |
|-------|---------------|-------------|
| `debug` | `-O0` | No optimization. Leak counters enabled. JS not minified. Default Electron menu bar. |
| `release` | `-O3` | Aggressive optimization, minified JS, menu bar hidden, DevTools off |
| `distro` | `-O3` | Same as release, plus a shippable `<name>-<arch>.zip` in the output folder (`-r` gives warning CMP002 and runs nothing) |

Set the mode per file with a directive:

```pxl
@buildmode release;
```

Or from the command line:

```
pixels myprogram -r -bm release
```

> [!TIP]
> **Start with debug.** Omit the `@buildmode` directive and the `-bm` flag during development -- the default gives you the leak report. Switch to `-bm release` for release builds. See [Build Modes](#build-modes) in the CLI Reference for the flags and output locations.


<a id="debugging-heap-leak-report"></a>

### 🔍 Heap Leak Report

In the `debug` build mode (emitter optimize level 0), the emitter generates a leak counter that prints to stdout at shutdown -- the window's output pane and the DevTools console:

```
[Heap] Allocs: 12, Frees: 12, Leaked: 0
```

Every `getmem`, `new`, string allocation, and dynamic array resize is counted. If `Leaked` is greater than zero, the program has a memory leak -- a heap object was allocated but never freed before shutdown.

```pxl
// app_loop.pxl -- game loop with zero leaks (header comment trimmed)
// Source: examples/app_loop.pxl
module exe app_loop;

@exeicon "$P:res/assets/icons/pixels.ico";

import 
  canvas2d,
  app;

var
  x: float64;
  updates: int64;

routine Update(const dt: float64);
begin
  x := x + 120.0 * dt;
  if x > 800.0 then
    x := 0.0;
  end;

  updates := updates + 1;
  if updates = 600 then
    app.Quit();
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#000");
  canvas2d.FillRect(0.0, 0.0, 800.0, 600.0);
  canvas2d.SetFillStyle("#0f0");
  canvas2d.FillRect(x, 280.0, 40.0, 40.0);
end;

routine Shutdown();
begin
  println("shutdown handler");
end;

begin
  x := 0.0;
  updates := 0;
  canvas2d.Init(800, 600);
  println("setup done, loop running");  
  app.Run(Update, Render, Shutdown);
end.
```

Build in debug mode (the default) and run it with `-r`. After 600 updates the loop stops (closing the window has the same effect), the shutdown handler prints, `_shutdown` tears everything down, and the `[Heap]` line appears. A clean program shows `Leaked: 0`.

> [!NOTE]
> **release and distro suppress the report.** The leak counters add overhead, so they are only emitted in the debug build mode. A release or distro build produces no `[Heap]` output.
<!-- Source: PIXELS.Emitter.pas:3950-3992 (RT_ReportLeaks), PIXELS.Emitter.pas:4272-4274 (call site) -->

> [!NOTE]
> An exception or trap that escapes `_start` or a handler is reported, the program ends, and `_shutdown` still runs its cleanup walk and the `[Heap]` report (debug).


<a id="debugging-ansi-colour-output"></a>

### 🎨 ANSI Colour Output

The generated `index.html` includes an SGR parser that converts ANSI escape codes in `println` output to styled `<span>` elements in the window's output pane.
<!-- Source: PIXELS.Build.pas:258-289 (writeAnsi in PXL_ELECTRON_INDEX_HTML) -->

Supported SGR codes:

| Code | Effect |
|------|--------|
| 0 (or empty) | Reset all attributes |
| 1 | Bold |
| 2 | Dim |
| 3 | Italic |
| 4 | Underline |
| 22 | Normal intensity (neither bold nor dim) |
| 23 | Not italic |
| 24 | Not underlined |
| 30--37 | Standard foreground colours (black, red, green, yellow, blue, magenta, cyan, white) |
| 39 | Default foreground colour |
| 40--47 | Standard background colours |
| 49 | Default background colour |
| 90--97 | Bright foreground colours |
| 100--107 | Bright background colours |
| 38;5;n / 48;5;n | Foreground / background from the 256-colour xterm palette |
| 38;2;r;g;b / 48;2;r;g;b | Foreground / background truecolour (each part 0..255) |

```pxl
// ANSI colour example (not a shipped file -- illustrative)
println("\x1b[1;32mPASS\x1b[0m test_math");
println("\x1b[1;31mFAIL\x1b[0m test_string");
```

The output renders with green "PASS" and red "FAIL" in the output pane, just as it would in a native terminal. The compiler's own test runner uses ANSI codes for pass/fail markers.

> [!NOTE]
> **Other codes and escapes.** Any other SGR code is skipped on its own, and a truncated 256-colour or truecolour form ends that sequence. Escapes that are not SGR (cursor movement, clearing) are not rendered. The output and error panes keep separate styling, so a colour set in one never carries into the other.


<a id="debugging-compiler-error-mapping"></a>

### 🗺️ Compiler Error Mapping

When wasm-opt reports an error (typically a validation failure in the generated `.wat`), the compiler maps the WAT line number back to the original `.pxl` source file and line. You see an error pointing at your code, not at a `.wat` line you never wrote.
<!-- Source: PIXELS.Build.pas:728-805 (DoParseWasmOptErrors) -->

The build reads each wasm-opt error line of the form `path:LINE:COL: error: message`, looks the WAT line up in the source map the emitter builds while generating the `.wat`, and reports the error at the matching `.pxl` location. If a line has no mapping, the raw wasm-opt line is reported instead.

This is internal to the compiler's error reporting pipeline. It is not a user-facing debug tool -- it exists so that build errors are actionable without understanding the intermediate `.wat` output. It applies only at build time; runtime exceptions are reported by the page (see below), not mapped to source lines.


<a id="debugging-browser-devtools"></a>

### 🖥️ Browser DevTools

PIXELS does not ship a custom debugger. The game window is a Chromium page inside Electron, so Chromium's developer tools are the debugging environment when they are open. No build mode opens DevTools automatically. Debug builds keep Electron's default menu bar; release and distro builds hide it.

**Console tab.** All `println` output (stdout) is also sent to `console.log`, one call per line. JS warnings from std module shims (`console.warn`) also surface here. In app mode (when the canvas takes over the window), the output pane is hidden -- but the runtime failure handler (`PXL.fail` in `runtime.js`) writes the error stack to the `#err` pane and ends app mode, so an uncaught exception or trap is visible in the window even without DevTools.
<!-- Source: runtime.js:58-75 (PXL.fail) -->

**Sources tab.** The wasm module appears under `wasm://` in the source tree. The built-in wasm inspector can show disassembled wasm instructions. In the debug build mode the output is unoptimized (`-O0`) and maps more directly to your source structure; in release and distro builds, wasm-opt `-O3` may restructure the code.

**Network tab.** Asset loads appear as requests to `pxl://app/<key>`, next to `index.html`, `output.wasm` and `__assets.json`. `main.js` serves them from the source files (debug/release) or `resources\__assets\` (distro), with byte ranges for audio and video. Other traffic comes from your own code or a library that loads a URL (for example `video.LoadURL`).

> [!TIP]
> **Read the window first.** `println` output, the leak report, and uncaught errors all land in the window's own output area once app mode ends, so the output pane is usually the first place to look when something goes wrong.


<a id="debugging-conditional-compilation-for-debug-code"></a>

### 🔀 Conditional Compilation for Debug Code

PIXELS does not define `DEBUG` or `RELEASE` symbols, and the build mode does not define any symbol. If you want debug-only code, define your own symbol with `@define` and gate it with `@ifdef`:

```pxl
// bnf_exe_compliance.pxl -- conditional compilation (trimmed)
// Source: tests/compliance/bnf_exe_compliance.pxl:1022-1083
var cc_result: int32 = 0;

// @ifdef with predefined symbol
@ifdef PIXELS
  cc_result := cc_result + 1;
@endif

// @ifdef/@else
@ifdef NONEXISTENT_SYMBOL
  cc_result := cc_result + 100;
@else
  cc_result := cc_result + 1;
@endif

// @define/@ifdef
@define MY_TEST_SYMBOL
@ifdef MY_TEST_SYMBOL
  cc_result := cc_result + 1;
@endif

// @undef/@ifdef/@else
@undef MY_TEST_SYMBOL
@ifdef MY_TEST_SYMBOL
  cc_result := cc_result + 100;
@else
  cc_result := cc_result + 1;
@endif

// @elseif
@ifdef NONEXISTENT_SYMBOL
  cc_result := cc_result + 100;
@elseif PIXELS
  cc_result := cc_result + 1;
@else
  cc_result := cc_result + 100;
@endif

// Nested @ifdef
@ifdef PIXELS
  @ifdef WASM64
    cc_result := cc_result + 1;
  @endif
@endif

// Module kind defines
@ifdef BUILD_EXE
  cc_result := cc_result + 1;
@endif
```

#### Predefined Symbols

| Symbol | Defined when |
|--------|--------------|
| `PIXELS` | Always |
| `WASM64` | Always |
| `BUILD_EXE` | Module kind is `exe` |
| `BUILD_LIB` | Module kind is `lib` |
<!-- Source: PIXELS.Parser.pas:682-693 -->

These are the only symbols the parser predefines. `WINDOWS`, `LINUX`, `DEBUG`, `RELEASE` do not exist. `@unittestmode on;` also defines `UNITTESTMODE`, and tools that embed the compiler can add symbols through `TPxlCompiler.SetDefine`. See the Conditional Compilation section in the [Language Reference](#language-reference) for the full directive syntax.

`PIXELS` and `WASM64` are defined from the first line of every compile, before the `module` line. `BUILD_EXE` and `BUILD_LIB` name the kind of the program (the root module) and are visible in every module, units included. `UNITTESTMODE` is defined from the `@unittestmode on;` line of the `exe` module on.

> [!WARNING]
> **No conditional `@define` from the command line.** Symbols can only be defined in source code with `@define`. There is no `-D` flag or equivalent. If you need a build-wide symbol, define it in the main module: the main module is parsed first and one define table is shared by the whole compile, so a symbol still defined at the end of the main module is visible in every imported unit.

Next: [Code Style](#code-style)

---

<p align="right"><a href="#debugging">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="code-style"></a>

## 📐 10. Code Style

> **Make PIXELS code feel native**  
> Use the conventions followed by the toolkit, examples, and standard modules.


*Consistent naming, formatting, and file layout keep PIXELS code readable -- whether it is yours or someone else's.*

PIXELS conventions are few and predictable. Types are PascalCase with no prefix, variables are camelCase, constants are UPPER_CASE, and every value parameter takes `const`. The standard modules and the shipped examples largely follow these rules (the exceptions are noted below), so adopting them means your code reads like the rest of the toolkit.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🏷️ Naming Conventions](#code-style-naming-conventions)
- [📄 File Organization](#code-style-file-organization)
- [💬 Comments](#code-style-comments)
- [🔤 Formatting Guidelines](#code-style-formatting-guidelines)
- [📦 Visibility](#code-style-visibility)
- [✅ Example: Well-Structured Source File](#code-style-example-well-structured-source-file)

</details>

<a id="code-style-naming-conventions"></a>

### 🏷️ Naming Conventions

| Category | Style | Example |
|----------|-------|---------|
| Types | PascalCase, no prefix | `Point`, `Color`, `TextMetrics` |
| Variables | camelCase | `count`, `totalScore`, `isReady` |
| Constants | UPPER_CASE with underscores | `MAX_SIZE`, `LINE_CAP_BUTT`, `PI` |
| Routines | camelCase or snake_case | `add`, `getLength`, `make_point` |
| Module names | lowercase, same as the file name | `mathlib`, `canvas2d`, `localstorage` |

> [!NOTE]
> **No T prefix on types.** If you are coming from Delphi or Object Pascal, write `Point` instead of `TPoint`, `Color` instead of `TColor`. PIXELS types stand on their own name.


<a id="code-style-file-organization"></a>

### 📄 File Organization

A typical `.pxl` source file follows this structure:

```pxl
module <kind> <name>;

// imports
import other_module;

// constants
const
  MY_CONST: int32 = 42;

// types
type
  MyRecord = record
    x: int32;
    y: int32;
  end;

// routines
routine helper(const a: int32): int32;
begin
  return a * 2;
end;

// public API
public routine doWork(const value: int32): int32;
begin
  return helper(value) + MY_CONST;
end;

// initialization (optional)
initialize
  println("module loaded");
end;

// finalization (optional)
finalize
  println("module unloaded");
end;

// main body (exe modules only)
begin
  println("Hello, PIXELS!");
end.
```

The module declaration is always first, followed by imports, then declarations (constants, types, variables, routines), optional initialize/finalize blocks, and the closing `end.` (with a main body for `exe` modules).


<a id="code-style-comments"></a>

### 💬 Comments

PIXELS supports two comment styles:

```pxl
// Line comment -- everything after // to end of line

/* Block comment
   Can span multiple lines
   and can be /* nested */ safely */
```

Use line comments for short annotations. Use block comments for longer explanations or temporarily disabling code. The `(* *)` and `{ }` comment styles from traditional Pascal are **not** supported.


<a id="code-style-formatting-guidelines"></a>

### 🔤 Formatting Guidelines

**Indentation.** Use consistent indentation (two or four spaces). Pick one and stick with it throughout your project.

**Semicolons.** End every statement with a semicolon. The compiler treats the `;` after a statement as optional, but writing it keeps code uniform; after declarations and directives it is required. The `end` that closes a block also takes a semicolon (`end;`), except the final `end.` that closes the module.

**String literals.** PIXELS uses double quotes for both strings and characters: `"hello"`, `"A"`. Single quotes are not valid.

**Control structures.** `if`, `while`, `for`, `match`, and `guard` always terminate with `end;`. There are no single-statement forms without `end`. The `then` keyword follows the condition in `if` statements, and `else` appears on its own line:

```pxl
if x > 0 then
  println("positive");
end;

if x > 0 then
  println("positive");
  count += 1;
else
  println("non-positive");
end;
```

**Routine parameters.** Separate parameters with semicolons. Use `const` on every value parameter:

```pxl
routine move(const x: int32; const y: int32; const speed: float64): bool;
```

Use `var` only when the callee writes through the parameter. This is the convention used throughout the std modules. The vendor binding (`phaser`) and the `browser` module name their parameters with an `A` prefix (`ATitle`, `AWidth`), and the vendor binding uses `int32` where a `bool` would be expected; treat those as exceptions rather than the house style.

**Formatted output.** `println` and `print` use printf-style formatting: `println("x = %d, name = %s", x, name);`. Format specifiers follow C conventions (`%d`, `%s`, `%f`, `%x`, etc.).

**Blank lines.** Use blank lines to separate logical sections: between routines, between groups of related declarations, and before/after initialize/finalize blocks.


<a id="code-style-visibility"></a>

### 📦 Visibility

Declarations are private by default. Use the `public` keyword to export a declaration from a module:

```pxl
public const API_VERSION: int32 = 1;       // visible to importers
const INTERNAL_LIMIT: int32 = 256;          // private

public routine calculate(const x: int32): int32;  // exported
routine helper(const x: int32): int32;             // private
```

When consuming imported symbols, always qualify them with the module name:

```pxl
import mathlib;
var result: int32 = mathlib.add(2, 3);
```

> [!NOTE]
> An importer reaches only `public` members; any other is error SEM010 at the access.


<a id="code-style-example-well-structured-source-file"></a>

### ✅ Example: Well-Structured Source File

```pxl
// geometry.pxl -- a reusable geometry unit
// Source: illustrative (follows std module conventions)
module unit geometry;

// -- Constants --

public const ORIGIN_X: int32 = 0;
public const ORIGIN_Y: int32 = 0;

// -- Types --

public type
  Point = record
    x: int32;
    y: int32;
  end;

public type
  Rect = record
    left: int32;
    top: int32;
    width: int32;
    height: int32;
  end;

// -- Public API --

public routine makePoint(const px: int32; const py: int32): Point;
var
  result: Point;
begin
  result.x := px;
  result.y := py;
  return result;
end;

public routine area(const r: Rect): int32;
begin
  return r.width * r.height;
end;

public routine contains(const r: Rect; const p: Point): bool;
begin
  return (p.x >= r.left) and (p.x < r.left + r.width)
     and (p.y >= r.top) and (p.y < r.top + r.height);
end;

// -- Module lifecycle --

initialize
  println("geometry loaded");
end;

end.
```

> [!TIP]
> **Keep routines short and focused.** If a routine grows beyond a screenful, split it into smaller helpers. Group related routines together and separate groups with blank lines and a short comment header.

Next: [Common Tasks](#common-tasks)

---

<p align="right"><a href="#code-style">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="common-tasks"></a>

## 🛠️ 11. Common Tasks

> **Recipes you can lift directly**  
> Copy working patterns for the tasks you will reach for most often while building a game.


*Practical recipes for everyday PIXELS work -- each one a working program you can build and run.*

Every recipe below is lifted from a shipped example or test file in the PIXELS distribution (`bin\res\examples\` and `bin\res\tests\`), except where a block is marked illustrative. Build any of them with `pixels <name> -r` and the program runs in an Electron window as soon as the build finishes.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [📝 Hello World](#common-tasks-hello-world)
- [🔄 Game Loop](#common-tasks-game-loop)
- [🎨 Drawing on Canvas](#common-tasks-drawing-on-canvas)
- [⌨️ Handling Input](#common-tasks-handling-input)
- [🔊 Playing Sound](#common-tasks-playing-sound)
- [🎬 Playing Video](#common-tasks-playing-video)
- [💾 Persistent Storage](#common-tasks-persistent-storage)
- [📦 Embedding Assets](#common-tasks-embedding-assets)
- [🌐 Calling JavaScript](#common-tasks-calling-javascript)
- [📤 Shipping a .wasm Library](#common-tasks-shipping-a-wasm-library)
- [⚡ Exception Handling](#common-tasks-exception-handling)
- [📋 Records and Pointers](#common-tasks-records-and-pointers)
- [📊 Dynamic Arrays](#common-tasks-dynamic-arrays)
- [🧪 Unit Tests](#common-tasks-unit-tests)
- [🔀 Conditional Compilation](#common-tasks-conditional-compilation)

</details>

<a id="common-tasks-hello-world"></a>

### 📝 Hello World

The smallest PIXELS program: a module declaration, a `begin` block, and a call to `println`.

```pxl
// hello.pxl (trimmed)
// Source: examples/hello.pxl
module exe hello;

@exeicon "$P:res/assets/icons/pixels.ico";

begin
  println("Hello, I am %s! 🚀🔥✨", "PIXELS");

  var i: int32 = 0;
  var s: string = "PIXELS™ " + "Game Toolkit";

  println(s);

  for i := 1 to 10 do
    println("%d", i);
  end
end.
```

Build and run: `pixels hello -r`. An Electron window opens, the output appears in its console pane followed by the exit code, and the program ends. Note the `for` loop: the loop variable is a plain identifier (`for i := 1 to 10 do`), not an inline `var` declaration. The `@exeicon` line only matters for distro builds, where it sets the icon of the packaged `.exe`.


<a id="common-tasks-game-loop"></a>

### 🔄 Game Loop

A game loop with update, render, and shutdown callbacks, run by the `app` module. The Electron renderer owns the animation loop -- the main body returns immediately after `app.Run`, and `requestAnimationFrame` drives the tick cycle.

```pxl
// app_loop.pxl (trimmed)
// Source: examples/app_loop.pxl
module exe app_loop;

import
  canvas2d,
  app;

var
  x: float64;
  updates: int64;

routine Update(const dt: float64);
begin
  x := x + 120.0 * dt;
  if x > 800.0 then
    x := 0.0;
  end;

  updates := updates + 1;
  if updates = 600 then
    app.Quit();
  end;
end;

routine Render();
begin
  canvas2d.SetFillStyle("#000");
  canvas2d.FillRect(0.0, 0.0, 800.0, 600.0);
  canvas2d.SetFillStyle("#0f0");
  canvas2d.FillRect(x, 280.0, 40.0, 40.0);
end;

routine Shutdown();
begin
  println("shutdown handler");
end;

begin
  x := 0.0;
  updates := 0;
  canvas2d.Init(800, 600);
  println("setup done, loop running");
  app.Run(Update, Render, Shutdown);
end.
```

`app.Run` takes three routine references (any of them may be `nil`): `Update(dt)` is called at a fixed step (60 per second by default, see `app.SetTargetFPS`), and `Render()` once per tick. After `app.Quit()` the program ends at the next clean point: the page calls `_shutdown`, which runs your `Shutdown()` handler first, then the `finalize` sections, then frees globals and (in debug builds) prints the leak report.


<a id="common-tasks-drawing-on-canvas"></a>

### 🎨 Drawing on Canvas

A static scene drawn with the `canvas2d` module. No `app.Run` needed -- just `Init`, draw calls, and `end.`

```pxl
// house.pxl (trimmed)
// Source: examples/house.pxl
module exe house;

import
  canvas2d;

begin
  // Create an 800x600 canvas
  canvas2d.Init(800, 600);

  // Sky
  canvas2d.Clear(100, 149, 237);

  // House body
  canvas2d.Rect(250, 250, 200, 150, 178, 102, 51);

  // Door
  canvas2d.Rect(325, 320, 50, 80, 101, 67, 33);

  // Sun
  canvas2d.Circle(650, 100, 60, 255, 223, 0);

  println("Canvas demo rendered.");
end.
```

For animated drawing, combine `canvas2d` with `app.Run` as shown in the game loop recipe. The `canvas2d` module provides rectangles, paths, arcs, gradients, patterns, text, images, transforms, and pixel access; `Clear`, `Rect`, `Circle`, and `Line` used here are its integer convenience routines. See the [Standard Library](#standard-library) for the full API.


<a id="common-tasks-handling-input"></a>

### ⌨️ Handling Input

Keyboard, mouse, and gamepad input via the `input` module. Input state is snapshotted once per tick of the `app.Run` loop, so it only updates while that loop is running.

```pxl
// input_square.pxl (trimmed)
// Source: examples/input_square.pxl
module exe input_square;

import
  canvas2d,
  app,
  input;

const
  W = 800;
  H = 600;
  SPEED = 200.0;

var
  x: float64;
  y: float64;

routine Update(const dt: float64);
begin
  if input.KeyDown(input.KEY_LEFT) then
    x := x - SPEED * dt;
  end;
  if input.KeyDown(input.KEY_RIGHT) then
    x := x + SPEED * dt;
  end;

  x := x + input.GamepadAxis(0, input.AXIS_LEFT_X) * SPEED * dt;

  if input.MousePressed(input.MOUSE_LEFT) then
    x := input.MouseX();
    y := input.MouseY();
  end;
  if input.KeyPressed(input.KEY_ESCAPE) then
    app.Quit();
  end;
end;

// ... Render and Shutdown callbacks, then in the main body:
  canvas2d.Init(W, H);
  canvas2d.SetPlacement(canvas2d.PLACE_FILL);
  app.SetTitle("PIXELS: Input");
  app.Run(Update, Render, Shutdown);
```

`KeyDown` returns true every tick the key is held. `KeyPressed` returns true only on the tick the key goes down, ignoring auto-repeat, and `KeyReleased` on the tick it goes up. Mouse buttons and gamepad buttons follow the same Down/Pressed/Released pattern; key codes are physical (layout independent), and mouse coordinates are in canvas pixels once `canvas2d.Init` has run. `app.SetTitle` sets the window title.


<a id="common-tasks-playing-sound"></a>

### 🔊 Playing Sound

Sound effects and music via the `audio` module. Audio files are registered as assets with `@assets`.

```pxl
// audio_player.pxl (trimmed)
// Source: examples/audio_player.pxl
module exe audio_player;

import
  audio,
  canvas2d,
  app,
  input;

@assets "$P:res/assets/audio" "assets/audio" "*.ogg";

var
  sfx: array[0..4] of audio.Sound;
  engine: audio.Sound;
  engineVoice: audio.Voice;
  song: audio.Music;

routine Update(const dt: float64);
begin
  if input.KeyPressed(input.KEY_1) then
    audio.Play(sfx[0]);
  end;
  if input.KeyPressed(input.KEY_4) then
    audio.PlayEx(sfx[3], 0.8, 1.0, -0.8, false);
  end;
  if input.KeyPressed(input.KEY_SPACE) then
    if audio.IsVoicePlaying(engineVoice) then
      audio.StopVoice(engineVoice);
      engineVoice := 0;
    else
      engineVoice := audio.PlayEx(engine, 0.7, 1.0, 0.0, true);
    end;
  end;
  if input.KeyPressed(input.KEY_M) then
    if audio.IsMusicPlaying() then
      audio.StopMusic();
    else
      audio.SetMusicVolume(1.0);
      audio.PlayMusic(song, true);
    end;
  end;
end;

// ... Render and Shutdown callbacks, then in the main body:
  sfx[0] := audio.LoadSound("assets/audio/sfx/digthis.ogg");
  sfx[3] := audio.LoadSound("assets/audio/sfx/samp0.ogg");
  engine := audio.LoadSound("assets/audio/sfx/engine_player.ogg");
  song := audio.LoadMusic("assets/audio/music/song01.ogg");
  app.Run(Update, Render, Shutdown);
```

A `Sound` is a short effect decoded into memory; every `Play` or `PlayEx(sound, volume, pitch, pan, loop)` starts a new `Voice` you can stop or retune. `Music` is one streamed track at a time with pause, resume, seek, and `FadeMusic`. Decoding is asynchronous, so poll `audio.IsReady()` if you need to know when sounds are usable. Sound works from the first frame: no click or key press is needed before `Play` or `PlayMusic`. `audio.Unlock()` reports whether audio is live.

> [!NOTE]
> **Assets.** The `@assets` directive registers every matching file under the source folder. `debug` and `release` builds serve the files in place (no copy); a `distro` build copies them into the app's `resources\__assets\` folder. At run time `audio.LoadSound` and `audio.LoadMusic` look the virtual path up in the asset manifest. A missing asset gives a console warning and a 0 handle, not an exception.


<a id="common-tasks-playing-video"></a>

### 🎬 Playing Video

Video playback via the `video` module. Two display modes: draw the current frame onto the canvas2d surface, or show the video element itself in the page.

```pxl
// video_player.pxl (trimmed)
// Source: examples/video_player.pxl
module exe video_player;

import
  canvas2d,
  app,
  input,
  video;

@assets "$P:res/assets/video" "assets/video" "intro.mp4";
@assets "$P:res/assets/video" "assets/video" "explainer.webm";

var
  clips: array[0..1] of video.Video;
  cur: int32;
  drawMode: bool;

routine Current(): video.Video;
begin
  return clips[cur];
end;

routine ApplyDisplay();
begin
  if drawMode then
    video.Hide(Current());
  else
    video.Show(Current(), video.PLACE_CENTER);
  end;
end;

// ... in Render, when drawMode is on:
    video.Draw(v, VIEW_X, VIEW_Y, VIEW_W, VIEW_H);

// ... in the main body:
  clips[0] := video.Load("assets/video/intro.mp4");
  clips[1] := video.Load("assets/video/explainer.webm");
  ApplyDisplay();
  app.Run(Update, Render, Shutdown);
```

`video.Show` places the element in the page using the same placement modes as canvas2d: `video.PLACE_FLOW`, `PLACE_CENTER`, `PLACE_FILL`, or `PLACE_WINDOW`. For compositing onto the canvas, call `video.Draw(v, x, y, w, h)` inside a `Render` callback instead (or `DrawRect` for a source sub-rectangle). `Play`, `Pause`, `Stop`, `Seek`, `SetLoop`, and `SetMuted` control playback; `Width` and `Height` stay 0 until the clip's metadata has loaded, so poll `IsReady`. Sound plays from the first frame, as with the `audio` module.


<a id="common-tasks-persistent-storage"></a>

### 💾 Persistent Storage

Key-value persistence across runs via the `localstorage` module.

```pxl
// run_counter.pxl (trimmed)
// Source: examples/run_counter.pxl
module exe run_counter;

import
  localstorage;

var
  runs: int64;

begin
  if localstorage.Available() then
    println("localStorage available");
  else
    println("localStorage NOT available -- nothing below will persist");
  end;

  runs := localstorage.GetInt("runs", 0) + 1;
  localstorage.SetInt("runs", runs);
  println("runs = %lld (reload the page: this must increment)", runs);
end.
```

Keys are automatically prefixed with the program's module name, so two different programs using the same key name do not collide, and `Clear` removes only your own keys. `SetItem`/`GetItem`, `SetFloat`/`GetFloat`, `SetBool`/`GetBool`, `RemoveItem`, `HasItem`, `Length`, and `Key` round out the API. Nothing raises: a missing key returns the default you pass, and a failed write returns false.

> [!TIP]
> **Check availability first.** `localstorage.Available()` returns false when storage is blocked, in which case writes fail and reads return your defaults.


<a id="common-tasks-embedding-assets"></a>

### 📦 Embedding Assets

The `@assets` directive maps files into the app. Each file's key is the virtual path plus its path relative to the source folder. `debug` and `release` builds serve the files in place; a `distro` build copies them into `resources\__assets\` next to `app.asar`. Valid in `exe` modules only.

```pxl
// scale_image.pxl (trimmed)
// Source: examples/scale_image.pxl
module exe scale_image;

@exeicon "$P:res/assets/icons/pixels.ico";
@assets "$P:res/assets/images" "assets/images" "pixels.png";

import
  canvas2d,
  app;

var
  img: canvas2d.Image;

routine Render();
begin
  if canvas2d.ImageReady(img) then
    canvas2d.DrawImage(img, 18, 136, 603, 208);
    println("Asset demo: image drawn");
    app.Quit();
  end;
end;

routine Shutdown();
begin
  canvas2d.ReleaseImage(img);
end;

begin
  canvas2d.Init(640, 480);
  canvas2d.SetPlacement(canvas2d.PLACE_FILL);
  img := canvas2d.LoadImage("assets/images/pixels.png");
  if img = 0 then
    println("LoadImage FAILED");
  else
    app.Run(nil, Render, Shutdown);
  end;
end.
```

Images load on demand: `canvas2d.LoadImage` returns a handle at once (0 = asset missing), and the fetch and decode finish later. Draw only once `canvas2d.ImageReady` is true, and free the image with `ReleaseImage`. For bulk registration, give `@assets` a pattern (default `*`): `@assets "$P:res/assets/audio" "assets/audio" "*.ogg";` adds every `.ogg` below the folder recursively, keyed like `assets/audio/sfx/samp0.ogg`. See the [Module System](#module-system) for the full directive syntax.

A relative path in a directive resolves against the current working directory of the compiler, so the examples use `$P:` (the folder of `pixels.exe`); an absolute path works from any folder too.


<a id="common-tasks-calling-javascript"></a>

### 🌐 Calling JavaScript

Write a JS namespace object, declare its functions as `external` in PIXELS, and the compiler wires them together at build time.

**synth_iife.js** (the JS side):

```javascript
// Source: tests/libs/synth_iife.js
var synth_iife = {
  Add: function(a, b) { return a + b; },
  Mul: function(a, b) { return a * b; },
  Neg: function(a) { return -a; }
};
```

**probe_synth_iife.pxl** (the PIXELS side):

```pxl
// probe_synth_iife.pxl (trimmed)
// Source: tests/probe/probe_synth_iife.pxl
module exe probe_synth_iife;

@addlibrarypath "$P:res/tests/libs";

routine Add(const a: int32; const b: int32): int32;
  external "synth_iife" name "Add";

routine Mul(const a: int32; const b: int32): int32;
  external "synth_iife" name "Mul";

begin
  println("IIFE Add(2,3) = %d", Add(2, 3));
  println("IIFE Mul(4,5) = %d", Mul(4, 5));
end.
```

The `external "synth_iife"` clause tells the compiler to look for `synth_iife.wasm`, then `synth_iife.js`, first in the declaring module's folder and then in each `@addlibrarypath` folder. The `name "Add"` maps the PIXELS routine to the JS property name. A plain global object like this is bundled as-is; CommonJS or ES-module files are wrapped by esbuild at build time. Numbers cross as-is; strings cross as `ptr to char` (pointers arrive in JS as BigInt), which the JS side reads with `PXL.readCStr` and fills with `PXL.writeCStr`. See [JS Interop](#js-interop) for the full marshalling contract.


<a id="common-tasks-shipping-a-wasm-library"></a>

### 📤 Shipping a .wasm Library

A `module lib` produces a `.wasm` library that PIXELS `exe` programs link in (like a C `.lib`); it imports its memory and runtime from the exe, so a plain wasm host cannot use it.

```pxl
// mathlib.pxl (illustrative)
module lib mathlib;

public routine Add(const a: int64; const b: int64): int64;
begin
  return a + b;
end;

routine Mul(const a: int64; const b: int64): int64;
begin
  return a * b;
end;

end.
```

Build: `pixels mathlib`. The output is `mathlib.wasm` (plus the intermediate `mathlib.wat`) in the output folder (`-o`, else `@outputpath`, else `output\` under the current directory); no Electron app is built for a lib. Only `public` routines are exported, under mangled names (`Add` as `mathlib.Add__int64_int64`), so `Mul` is not; overloaded public routines are exported too. A consuming program declares `routine Add(const a: int64; const b: int64): int64; external "mathlib" name "Add";` with the real parameters, and when the build finds `mathlib.wasm` on the library search path it links it into the program with `wasm-merge`, together with every library `mathlib` itself declares `external`, and runs its `initialize` / `finalize` blocks. Ship `mathlib.wasm` with those libraries: the consuming program finds them in its own folder or an `@addlibrarypath` folder; std and vendor modules are found in their own folders. See [JS Interop](#js-interop) for details.


<a id="common-tasks-exception-handling"></a>

### ⚡ Exception Handling

`guard`/`except`/`finally` blocks catch software exceptions (`throw`, `throwcode`) and the errors the runtime raises itself, such as integer division by zero.

```pxl
// bnf_exe_compliance.pxl (trimmed)
// Source: tests/compliance/bnf_exe_compliance.pxl:878-927
  // guard/except with throw
  guard
    throw("test error");
    println("should not print");
  except
    println("caught, code=%lld, msg=%s", exccode(), excmsg());
  end;

  // guard/except with throwcode
  guard
    throwcode(42, "custom error");
  except
    println("code=%lld, msg=%s", exccode(), excmsg());
  end;

  // guard/finally (no except)
  guard
    println("guard-finally body");
  finally
    println("finally runs");
  end;
  println("after guard-finally");

  // guard/except/finally
  guard
    throw("err2");
  except
    println("except caught");
  finally
    println("finally2 runs");
  end;

  // hw exception: div by zero
  guard
    x := 10 div get_zero();
    println("should not print: %d", x);
  except
    println("hw caught, code=%lld, msg=%s", exccode(), excmsg());
  end;
```

`exccode()` returns the error code as an `int32`: 1000 for a bare `throw`, the value you pass to `throwcode`, or a runtime code (1002 for division by zero; `%d` is enough to print it, the `ll` length modifier above is accepted and ignored). Codes 1000 to 1999 are reserved for the runtime and compiler; pick `throwcode` values from 1 to 1073741823 outside that range. `excmsg()` returns the message string. Nested `guard` blocks and exceptions propagating out of called routines both work. Genuine WebAssembly traps (out-of-bounds memory, `unreachable`) and JavaScript errors are not catchable: they end the program and the error appears in the window.


<a id="common-tasks-records-and-pointers"></a>

### 📋 Records and Pointers

Records group related fields. They can live on the stack or be heap-allocated with `new`/`dispose`.

```pxl
// bnf_exe_compliance.pxl (trimmed)
// Source: tests/compliance/bnf_exe_compliance.pxl:164-167, 994-995, 1180-1198
  Point = record
    x: int32;
    y: int32;
  end;

  // Basic int fields
  var rp: Point = Point(x: 42, y: 99);

  // Allocate a record on the heap
  var hp: ptr to Point;
  new(hp);
  hp^.x := 42;
  hp^.y := 99;

  // Modify through ptr
  hp^.x := hp^.x + 10;

  // Dispose sets ptr to nil
  dispose(hp);
```

A pointer type is written `ptr to T` (`^` also works in place of `ptr`); dereference with `^` after the name. `dispose` frees the block and sets the pointer to `nil`. Records also support `packed` (no padding), `align(N)` (minimum alignment), inheritance (`record(Base)`), and anonymous overlay sections. See the [Language Reference](#language-reference) for the full type definition syntax.


<a id="common-tasks-dynamic-arrays"></a>

### 📊 Dynamic Arrays

Heap-allocated, resizable arrays managed with `setlength` and `len`.

```pxl
// bnf_exe_compliance.pxl (trimmed)
// Source: tests/compliance/bnf_exe_compliance.pxl:241, 244, 858-872
var arr5: array[0..4] of int32;
var darr: array of int32;

  setlength(darr, 5);
  println("len after setlength = %lld", len(darr));
  darr[0] := 100;
  darr[1] := 200;
  darr[2] := 300;
  println("darr[0] = %d", darr[0]);
  setlength(darr, 7);
  darr[5] := 600;
  darr[6] := 700;
  println("len after grow = %lld", len(darr));
  println("darr[6] = %d", darr[6]);
```

Static arrays use a fixed range: `var arr5: array[0..4] of int32;`. Dynamic arrays start at length zero and grow with `setlength`; `len` returns the length as an `int64`. Static arrays are indexed from their declared lower bound, dynamic arrays from 0. See [Memory](#memory-data-structures) for how dynamic arrays interact with the heap.


<a id="common-tasks-unit-tests"></a>

### 🧪 Unit Tests

Test blocks after `end.` run in place of the normal main body when `@unittestmode` is on.

```pxl
// bnf_unittest_compliance.pxl (trimmed)
// Source: tests/compliance/bnf_unittest_compliance.pxl
module exe bnf_unittest_compliance;

@unittestmode on;

routine add(const a: int32; const b: int32): int32;
begin
  return a + b;
end;

routine half(const v: float64): float64;
begin
  return v / 2.0;
end;

begin
  // Replaced by the test runner when @unittestmode is on. Reaching this
  // would be a failure.
  println("MAIN BLOCK MUST NOT RUN IN UNIT TEST MODE");
  asserteq(0, 1, "main block executed in unit test mode");
end.

test "integer arithmetic"
begin
  asserteq(3, add(1, 2));
  asserteq(0, add(-1, 1));
  asserteq(-3, add(-1, -2));
end;

test "float arithmetic"
begin
  asserteqf(1.5, half(3.0), 0.0001);
  asserteqf(0.0, half(0.0), 0.0001);
end;

test "test-local variables"
var
  total: int32;
  i: int32;
begin
  total := 0;
  for i := 1 to 10 do
    total := total + i;
  end;
  asserteq(55, total, "loop inside a test block");
end;
```

Assertions: `asserteq(expected, actual)` with an optional 3rd message argument, `asserteqf(expected, actual, epsilon)` with an optional 4th message argument, the one-argument forms `assert`, `asserttrue`, `assertfalse`, `assertnil`, and `assertnotnil`, and `assertfail` with an optional message. Failures are non-aborting -- every test runs, the runner prints `[PASS]`/`[FAIL]` per test and a results summary. The module still needs its `begin ... end.` main body: the runner takes its place in test mode. Build and run with `pixels bnf_unittest_compliance -r`.


<a id="common-tasks-conditional-compilation"></a>

### 🔀 Conditional Compilation

Define symbols with `@define`, test with `@ifdef`/`@ifndef`, branch with `@else`/`@elseif`, close with `@endif`. These directives take no trailing `;`.

```pxl
// bnf_exe_compliance.pxl (trimmed)
// Source: tests/compliance/bnf_exe_compliance.pxl:1026-1081
  // @ifdef with predefined symbol
  @ifdef PIXELS
    cc_result := cc_result + 1;
  @endif

  // @ifdef/@else
  @ifdef NONEXISTENT_SYMBOL
    cc_result := cc_result + 100;
  @else
    cc_result := cc_result + 1;
  @endif

  // @define/@ifdef
  @define MY_TEST_SYMBOL
  @ifdef MY_TEST_SYMBOL
    cc_result := cc_result + 1;
  @endif

  // @undef/@ifdef/@else
  @undef MY_TEST_SYMBOL
  @ifdef MY_TEST_SYMBOL
    cc_result := cc_result + 100;
  @else
    cc_result := cc_result + 1;
  @endif

  // @elseif
  @ifdef NONEXISTENT_SYMBOL
    cc_result := cc_result + 100;
  @elseif PIXELS
    cc_result := cc_result + 1;
  @else
    cc_result := cc_result + 100;
  @endif

  // Nested @ifdef
  @ifdef PIXELS
    @ifdef WASM64
      cc_result := cc_result + 1;
    @endif
  @endif

  // Module kind defines
  @ifdef BUILD_EXE
    cc_result := cc_result + 1;
  @endif
```

Four predefined symbols are available: `PIXELS`, `WASM64`, `BUILD_EXE` (when the program, the root module, is an `exe`), and `BUILD_LIB` (when it is a `lib`); all four are visible in imported units too. There are no `DEBUG` or `RELEASE` builtins -- define your own with `@define`. See the [Language Reference](#language-reference) and [Module System](#module-system) for the full directive syntax.

> [!NOTE]
> **No `-D` flag.** Symbols can only be defined in source code. A symbol defined with `@define` in the main module stays defined for the units parsed after it, so put build-wide symbols at the top of the main module.

Next: [Contributing](#contributing)

---

<p align="right"><a href="#common-tasks">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="editor"></a>

## ✏️ 12. Editor

> **Write, build and run PIXELS code in one window**  
> A Monaco-based code editor with the PIXELS language server built in: live errors, completion, navigation, and one-key build and run.


*The PIXELS Editor ships with the toolkit. Its editing surface is Monaco, the editor inside VS Code, and its language intelligence comes from the PIXELS compiler itself -- so what the editor tells you about your code is what the compiler will say.*

The editor is an Electron app of its own, `bin\res\editor\editor.exe`, beside the compiler. Like the rest of the toolkit it needs nothing installed. In the background it starts `pixels.exe --lsp`, the compiler's language server: diagnostics, completion, hover, navigation and rename all come from the same front end that compiles your program, never from a second parser guessing at your code. Build and Run call `pixels.exe` with exactly the flags you would type on the command line.


<details>
<summary><strong>Jump to a topic</strong></summary>

- [🚀 Starting the Editor](#editor-starting)
- [🖼️ The Window](#editor-window)
- [📂 Files and Folders](#editor-files-and-folders)
- [▶️ Build and Run](#editor-build-and-run)
- [🧠 Language Features](#editor-language-features)
- [🧭 Navigation](#editor-navigation)
- [⌨️ Keyboard Shortcuts](#editor-keyboard-shortcuts)

</details>

<a id="editor-starting"></a>

### 🚀 Starting the Editor

Start it from the command line with the `editor` command, optionally followed by the files to open:

```
pixels editor
pixels editor game.pxl
pixels editor game.pxl levels.pxl
```

`pixels editor` starts the editor and returns at once. Each file argument opens in its own tab; relative paths resolve against the directory you ran the command in. You can also start `bin\res\editor\editor.exe` directly.

> [!TIP]
> **The editor remembers where you left off.** The open folders, the open tabs and the active tab come back the next time you start it. This state lives in `bin\res\editor\data\` beside `editor.exe`, not in your user profile, so the toolkit folder stays self-contained.

<a id="editor-window"></a>

### 🖼️ The Window

| Area | What it holds |
|---|---|
| **Title bar** | The PIXELS logo, which opens the command menu. File buttons: New, Open, Save, Save As, Save All, Rename. Build buttons: Build, Run, Stop. The build mode (`debug`, `release`, `distro`) and target (`win-x64`, `linux-x64`) selectors |
| **Explorer** (left) | Every open folder as a tree, plus the optional Examples folder |
| **Tabs** | One tab per open file, each marked when it has unsaved changes |
| **Editor** | The Monaco editing surface, with PIXELS syntax and semantic highlighting |
| **Bottom panel** | `OUTPUT` (build and program output), `PROBLEMS` (errors and warnings) and `CALL HIERARCHY`. Drag its edge to resize it; the arrow button collapses it |
| **Status bar** | The build state (building, running, ok, failed) and the error and warning counts |

> [!NOTE]
> **There is no menu bar.** It is hidden to keep the window clean. Every command is on the logo button, and all keyboard shortcuts work without it.

<a id="editor-files-and-folders"></a>

### 📂 Files and Folders

- **Open Folder** adds a folder to the explorer. Several folders can be open at once; **Close All Folders** removes them all.
- The tree expands a level at a time and lists `.pxl` files first. Click a file to open it in a tab.
- The explorer follows the disk: files created, renamed or deleted outside the editor show up on their own. The refresh button re-reads the tree on demand.
- **Show Examples** (a checkbox on the logo menu) adds an `Examples` folder with the example programs from `bin\res\examples`.
- **Save** is greyed out when the active tab has nothing to save, and **Save All** when no tab has.
- **Rename** renames the active file on disk, saving it first if needed, and keeps its tab open.
- Closing a tab with unsaved changes asks first, and so does quitting the editor with any unsaved tab.

<a id="editor-build-and-run"></a>

### ▶️ Build and Run

| Command | Key | What it does |
|---|---|---|
| **Build** | `Ctrl+B` | Saves, then compiles the active file: `pixels <file> -bm <mode> -t <target>` with the two selectors' values |
| **Run** | `F5` | The same as Build, plus `-r`: the game starts when the build succeeds |
| **Stop** | `Shift+F5` | Ends the build or the running game, including every process it started |

Only one build or run happens at a time. Compiler output streams into the `OUTPUT` pane as it is produced, and the status bar shows how it ended.

Compile errors land in three places at once: the `PROBLEMS` list, a squiggle under the offending code, and a tint over the whole error line. Click a problem to jump to it, opening its file if needed.

> [!NOTE]
> **Run with `distro` selected builds the zip only.** The compiler ignores `-r` for `distro` builds (warning `CMP002`). Unzip the package and start its executable to try it -- see [Build Modes](#build-modes).

<a id="editor-language-features"></a>

### 🧠 Language Features

Everything in this table is answered by the PIXELS language server, so it understands the same modules, imports and declarations the compiler does.

| Feature | What you get |
|---|---|
| **Live diagnostics** | Errors and warnings appear while you type, shortly after you pause. They are merged with the last build's errors in `PROBLEMS` |
| **Completion** | Keywords, declarations and routines as you type (`Ctrl+Space` to ask), including snippets for common constructs |
| **Signature help** | The parameter list of the routine you are calling, built-in intrinsics included, with the current parameter highlighted |
| **Hover** | Information about the symbol under the mouse |
| **Highlighting** | Every other use of the symbol under the cursor is highlighted in the file |
| **Semantic highlighting** | Colours based on what each name actually is, not only on its spelling |
| **Rename symbol** | `F2` renames a symbol at its declaration and every use |
| **Folding** | Collapse routines and blocks from the gutter |
| **Outline** | `Ctrl+Shift+O` lists the file's declarations; type to filter |
| **Inlay hints** | Extra inline information the server adds to your code |
| **Code actions** | Quick fixes the server offers for a problem (the light bulb) |
| **Format Document** | `Shift+Alt+F` re-indents the file and normalises the spacing between tokens; comments, blank lines, string literals and keyword spelling are kept |

> [!TIP]
> **Formatting never guesses.** The formatter works from the compiler's own token stream and changes only the lines that need it. If the file does not lex or its blocks do not balance, it changes nothing. Indent size, tabs or spaces, spacing around `:=`, operators, commas and colons, blank-line limit, trailing whitespace and the final newline are set in **Preferences > Format Settings**, which opens `settings.json` from the editor's `data` folder in a tab; saving it applies the settings at once.

<a id="editor-navigation"></a>

### 🧭 Navigation

| Command | Key | What it does |
|---|---|---|
| **Go to Definition** | `F12` | Jumps to the declaration, opening its file in a tab when it lives in another module |
| **Go to Type Definition** | -- | Jumps to the declaration of the symbol's type (right-click menu, or `F1` and type its name) |
| **Find References** | `Shift+F12` | Lists every use of the symbol |
| **Go to Symbol in Workspace** | `Ctrl+T` | A quick pick of every symbol the language server knows; type to filter, `Enter` to jump |
| **Show Call Hierarchy** | `Shift+Alt+H` | Shows the routine under the cursor in the `CALL HIERARCHY` panel; expand a node to follow its calls further |

<a id="editor-keyboard-shortcuts"></a>

### ⌨️ Keyboard Shortcuts

| Key | Command |
|---|---|
| `Ctrl+N` | New file |
| `Ctrl+O` | Open file |
| `Ctrl+S` | Save |
| `Ctrl+Shift+S` | Save As |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Shift+Alt+F` | Format Document |
| `Ctrl+B` | Build |
| `F5` | Run |
| `Shift+F5` | Stop |
| `Ctrl+T` | Go to Symbol in Workspace |
| `Shift+Alt+H` | Show Call Hierarchy |
| `F12` / `Shift+F12` | Go to Definition / Find References |
| `F2` | Rename symbol |
| `Ctrl+Space` | Trigger completion |
| `Ctrl+Shift+O` | Outline of the current file |
| `Ctrl+0` / `Ctrl+=` / `Ctrl+-` | Reset zoom / zoom in / zoom out |
| `F11` | Full screen |

> [!TIP]
> **Monaco's own keys work too.** Multi-cursor editing (`Alt+Click`), line moves (`Alt+Up`/`Alt+Down`), comment toggling (`Ctrl+/`) and the command palette (`F1`) all behave as they do in VS Code.

---

<p align="right"><a href="#editor">↑ Back to section top</a> · <a href="#documentation-guide">Documentation guide</a></p>

<a id="contributing"></a>

## 🤝 Contributing

> **Build PIXELS with us**  
> Report issues, improve examples and docs, propose focused changes, or support continued development.


PIXELS is developed by tinyBigGAMES. Whether you are fixing a bug, improving documentation, improving examples, or proposing a feature, contributions are welcome.

| Contribution | Best Way to Help |
|--------------|------------------|
| 🐞 Bug report | Open an issue with a minimal reproduction and the exact command used |
| 💡 Feature idea | Describe the real use case first, then the proposed syntax or behavior |
| 🧾 Documentation fix | Point to the section and explain what was unclear or missing |
| 🧪 Test case | Include the smallest `.pxl` file that proves the behavior |
| 🔧 Pull request | Keep the change focused and explain the before/after behavior |

> [!TIP]
> 🚀 Small, focused contributions are the easiest to review and the fastest to land.

## 💖 Support the Project

If PIXELS saves you time, helps you learn, or sparks something useful:

- ⭐ **Star the repo**: it costs nothing and helps others find the project
- 🗣️ **Spread the word**: write a post, mention it in a community, or share a screenshot
- 💬 **Join the community**: show what you are building and help shape what comes next
- 🧪 **Try examples**: real usage finds issues that synthetic tests miss
- 💖 **[Become a sponsor](https://github.com/sponsors/tinyBigGAMES)**: sponsorship directly funds development, examples, and documentation

## 📜 License

PIXELS is licensed under the **Apache License, Version 2.0**. See [LICENSE](https://github.com/tinyBigGAMES/PIXELS?tab=License-1-ov-file) for details.

Apache 2.0 is a permissive open source license that lets you use, modify, and distribute PIXELS freely in both open source and commercial projects. You are not required to release your own source code. Attribution is required: keep the copyright notice and license file in place.

## 🔗 Links

- 🌐 [Homepage](https://getpixels.org)
- 🧑‍💻 [GitHub](https://github.com/tinyBigGAMES/PIXELS)
- 💬 [Discord](https://discord.gg/Wb6z8Wam7p)
- 🦋 [Bluesky](https://bsky.app/profile/tinybiggames.com)  
- 👥 [Facebook Group](https://www.facebook.com/groups/getpixels)
- 🎮 [tinyBigGAMES](https://tinybiggames.com)

---

<div align="center">

**💎 PIXELS&trade;** - Write Pascal-style code. Ship games to the desktop.

Copyright &copy; 2026-present tinyBigGAMES&trade; LLC<br/>All Rights Reserved.

</div>
