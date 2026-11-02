# kittyscript starter kit

A kittyscript module is a small Zig program compiled to WebAssembly that runs
inside supported apps. It reads the scene, draws 2D and 3D overlays, declares
user settings, and reacts to the app's tick and frame callbacks.

Full API documentation: <https://kittyscript.com/docs/>

## Getting started in VS Code

1. Open this folder (the one with `build.zig`) and choose **Yes, I trust the
   authors**; the Zig extension does not run in Restricted Mode.
2. Install the recommended **Zig Language** extension (`ziglang.vscode-zig`);
   it downloads Zig 0.16 and the language server, and the version shows in the
   status bar.
3. Open `src/root.zig` for completion, hover docs, go-to-definition into
   `sdk/`, errors on save, and format on save.
4. The **kittyscript** extension installs itself when the folder opens (the
   `kittyscript: install extension` task runs `kittycli vscode`). Sign in from
   its side bar, or run `./kittycli login` (Windows: `.\kittycli.exe login`).

Examples get the same editor support.

## The kittyscript extension

The cat icon in the activity bar opens the **kittyscript** side bar: module
name and version, the signed-in account, **Check**, **Update SDK**, **Test
once**, **Start/Stop live test**, **Push**, **Pull**, **Status**,
**Publish…**, **Share link**, **My modules**, and the API docs. The status bar
shows the account or the running live test and opens the same list; every
action is also in the Command Palette as `kittyscript: …`.

Each action runs `kittycli` as a VS Code task, so its output appears in the
terminal panel and compile errors from **Check** and the live test appear in
the Problems panel. **Publish…** asks for confirmation in that terminal.

`kittycli` keeps the extension at the version it bundles: it installs or
updates it whenever it runs in a VS Code terminal (`kittycli vscode` does so
explicitly, `KITTY_NO_VSCODE=1` turns it off). The extension uses the project's
`kittycli`, then one on `PATH`, then downloads one; the
`kittyscript.kittycliPath` setting overrides that.

## Run it live

From the side bar: **Sign in…**, then **Start live test**. From a VS Code
terminal (the Zig extension puts Zig on its `PATH`, which `kittycli` needs for
the local compile check):

```bash
./kittycli login          # sign in
./kittycli test --watch   # compile, upload, live-load; repeats when src/ changes
./kittycli test --stop    # turn live testing off
./kittycli install --app deadlock   # enable the module in an app
./kittycli publish        # publish a stable version
```

On Windows use `.\kittycli.exe`; if `./kittycli` is not executable, run
`chmod +x kittycli`. Outside VS Code, Zig 0.16.x must be on `PATH` (or set
`KITTY_ZIG`).

`test` checks locally, uploads `src/`, compiles on the server, and loads the
module into your running session without publishing. Replace the placeholder
`name` and `description` in `module.toml` before `publish`.

`test` only marks a live-test session; the module loads in an app once it is
enabled there. `kittycli install --list` shows the candidate apps (in VS Code:
**Install in App…**).

## Project layout

| Path | What it is |
| --- | --- |
| `src/root.zig` | Your module. Only `src/` is uploaded. |
| `examples/` | 25 standalone modules (see below). |
| `sdk/` | SDK for the editor and local checks; `kittycli update` refreshes it. |
| `module.toml` | Publish manifest: name, description, version, pricing, visibility. |
| `build.zig`, `build.zig.zon` | Build setup; `zig build check` checks `src/` and every example. |

## Module basics

```zig
const sdk = @import("sdk");

export fn onLoad() void {}                  // enabled
export fn onUnload() void {}                // disabled
export fn onTick(_: f32, _: i32) void {}    // per simulation tick
export fn onFrame(_: f32, _: i32) void {}   // per rendered frame
export fn onUIFrame(_: f32, _: i32) void {} // per UI frame
```

Export only the callbacks you need. The tick and frame callbacks receive
`dt: f32` (elapsed seconds) and `frame: i32` (a counter); name unused
parameters `_`. Draw from `onFrame` or `onUIFrame`.

App-specific types come from the app's package: `@import("overwatch")`,
`@import("deadlock")`, or `@import("eft")` (no public
declarations yet). Modules target `wasm32-freestanding`: use fixed-size buffers
and the SDK's math helpers, as every example does.

## Examples

Each folder is a complete module; its `src/root.zig` header describes it. Copy
that file over yours to start from one.

| # | Example | Shows |
| --- | --- | --- |
| 01 | [hello-lifecycle](examples/01-hello-lifecycle) | lifecycle, logging, counters |
| 02 | [settings-fields](examples/02-settings-fields) | all setting types and controls |
| 03 | [keybinds-and-input](examples/03-keybinds-and-input) | key binds, input state |
| 04 | [drawing-2d](examples/04-drawing-2d) | 2D primitives |
| 05 | [hud-fps](examples/05-hud-fps) | frame-rate and frame-time HUD |
| 06 | [custom-crosshair](examples/06-custom-crosshair) | settings-driven crosshair |
| 07 | [actor-boxes](examples/07-actor-boxes) | world-to-screen actor boxes |
| 08 | [health-bars](examples/08-health-bars) | health, armor, shield bars |
| 09 | [skeleton-bones](examples/09-skeleton-bones) | skeletons and bones |
| 10 | [drawing-3d](examples/10-drawing-3d) | 3D primitives |
| 11 | [radar-minimap](examples/11-radar-minimap) | circular radar |
| 12 | [gradients-textures](examples/12-gradients-textures) | gradients and textures |
| 13 | [trace-visibility](examples/13-trace-visibility) | ray casts, line of sight |
| 14 | [target-selection](examples/14-target-selection) | tracking, locking, projectile lead |
| 15 | [local-actor-guns](examples/15-local-actor-guns) | local actor, guns, abilities |
| 16 | [overlay-ui-elements](examples/16-overlay-ui-elements) | in-overlay UI elements |
| 17 | [timers-and-dt](examples/17-timers-and-dt) | `dt`-driven timers |
| 18 | [math-primitives](examples/18-math-primitives) | vectors, quaternions, matrices |
| 19 | [util-helpers](examples/19-util-helpers) | random, text, color helpers |
| 20 | [actor-roster](examples/20-actor-roster) | actor roster, per-actor settings |
| 21 | [benchmark-profiler](examples/21-benchmark-profiler) | profiler readout |
| 22 | [overwatch-actors](examples/22-overwatch-actors) | `overwatch` behavioral class, hitbox scale, prop types |
| 23 | [deadlock-actors](examples/23-deadlock-actors) | `deadlock` actor `eq` predicates, teams, projectile intercept |
| 24 | [slot-overrides](examples/24-slot-overrides) | inherit or replace provider slot values |
| 25 | [hero-slot-overrides](examples/25-hero-slot-overrides) | per-hero overrides of declared slot values (`overwatch`) |
| 26 | [view-direction](examples/26-view-direction) | last read vs this tick's view, writing on top of or in place of the mouse |

## module.toml

`module.toml` holds the publish metadata; the website slug comes from `name`.

| Key | Meaning |
| --- | --- |
| `name` | Display name; rename with `kittycli publish --name` or `edit --name`. |
| `description` | Short description shown on the module page. |
| `version` | Published version; `publish` writes it back. |
| `price_kind` | `free`, `one_time`, `subscription`, or `both`. |
| `price_mc`, `daily_price_mc`, `onetime_price_mc` | Prices in MC. |
| `priority` | Listing priority: `10`, `15`, `20`, `25`, or `30`. |
| `apps` | App slugs the module supports; empty means all apps. |
| `opensource` | Publish the source with the module. |
| `public` | List publicly. Free modules only; locked after the first stable publish. |

`publish` uses `--version` when given (it must exceed the current stable
version), else the manifest `version` when ahead of it, else the next patch;
the first publish is `1.0.0`.

## kittycli commands

Global options: `-C, --dir <DIR>` sets the project directory (default `.`);
`--api <URL>` (or `KITTY_API`) sets the API base URL (default
`https://api.kittyscript.com`).

| Command | What it does |
| --- | --- |
| `login [--username NAME] [--password-stdin]` | Sign in; reads `KITTY_USERNAME` / `KITTY_PASSWORD`. |
| `logout` / `whoami` | Clear stored credentials / show the account. |
| `list` / `status` | List your modules / show status and local-server file differences. |
| `init [DIR]` | Scaffold a project or refresh templates and `sdk/` (never overwrites `src/root.zig` or `module.toml`). Offline. |
| `update [DIR] [--dry-run]` | Switch to the bundled SDK: replace `sdk/`, refresh templates, migrate, check; `--dry-run` prints the plan. Offline. |
| `clone <ID\|SLUG> [DIR]` | Download your module or fork a public one you don't own. |
| `pull` | Download the module source into `src/`. |
| `push [--no-check]` | Upload `src/`, creating the module if needed; runs the local check unless `--no-check`. |
| `check [DIR]` | Compile-check locally. Offline. |
| `test [--watch] [--stop]` | Check, upload, compile on the server, enable live testing (creates the module). `--watch` repeats on `src/` changes; `--stop` disables live testing. |
| `install [--list] [--json] [--app SLUG ...]` | Enable the module for the apps you pick (creates the module first). `--list` shows the candidate apps with their installed state, `--json` prints them as `[{"slug","name","installed"}]`. |
| `publish [--yes]` | Publish a stable version (flags below); creates `module.toml` when missing (then `--name`/`--description` are required) and records changed flags. |
| `edit` | Edit module metadata and visibility on the server and in `module.toml`. |
| `media list` / `media upload <FILE>` / `media delete <ID>` | Manage module images (png, jpeg, webp). |
| `share` | Create a claim link for the module. |
| `delete [--yes]` | Delete the module (`--yes` skips confirmation). |
| `sdk path` / `sdk extract [DIR]` | Print the SDK directory used for local checks, or extract the bundled SDK (default `./sdk`). |
| `vscode [--force]` | Install or update the bundled kittyscript VS Code extension; `--force` reinstalls it. |

`publish` and `edit` share `--name`, `--description`, `--price-kind` (`free`,
`one_time`, `subscription`, `both`), `--price`, `--daily-price`, `--onetime-price`,
and `--public`/`--private`; `publish` adds `--version X.Y.Z`, `--app SLUG`
(repeatable), `--priority N`, and `--opensource`/`--closed-source`.

Before every command, `kittycli` replaces itself with a newer release when one
exists (`KITTY_NO_UPDATE` skips this). Each run reports its version, OS,
architecture, command, executable SHA-256, and self-update result to the
kittyscript API — anonymously when signed out, linked to your account when
signed in.

## Troubleshooting

- **Wrong Zig version, no completion, or unexplained errors.** Modules and the
  editor need Zig 0.16.x; the status bar shows the active version. If it is
  missing, run **Zig Setup: Install Zig** from the Command Palette, then **ZLS
  language server: Start / Restart Language Server**. A `zig.path` setting must
  point to a 0.16.x build; other errors appear in the **ZLS language server**
  channel of the Output panel.
- **`@import("sdk")` is not found.** Open the project root (the folder with
  `build.zig`) in VS Code, not `src/` or an example folder.
- **No kittyscript icon in the activity bar.** Run `./kittycli vscode` in a VS
  Code terminal; it reports the installed and bundled versions. The extension
  needs a trusted folder, and its log is the **kittyscript** channel of the
  Output panel.
